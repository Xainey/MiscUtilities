if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename CreateShortcut.psd1 -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
}
else
{
    # Fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename CreateShortcut.psd1 -BaseDirectory "${PSScriptRoot}\en-US"
}

function Test-Writtable
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath
    )
    try
    {
        [io.file]::OpenWrite($FilePath).close()
    }
    catch
    {
        return $false
    }

    return $true
}

function Get-ShorcutMeta
{
    [CmdletBinding()]
    param (
        [string] $ShortcutPath
    )

    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut( `
        $PSCmdlet.GetUnresolvedProviderPathFromPSPath($ShortcutPath))
    
    $ShorcutEntry = [PSObject] @{
        TargetPath             = $shortcut.TargetPath
        FullName               = $shortcut.FullName
    }

    return $ShorcutEntry
}

function Set-Shortcut
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShortcutName,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShortcutPath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $TargetPath
    )

    $shortcutFile = Join-Path $ShortcutPath "$ShortcutName.lnk"
    $parent = Split-Path -Path $shortcutFile -Parent

    if (Test-Path -Path $parent)
    {
        if ( !(Test-Writtable -FilePath $shortcutFile) )
        {
            # throw $LocalizedData.UnableToWriteOutput -f $shortcut
            Write-Verbose -Message ($LocalizedData.UnableToWriteOutput -f $shortcutFile)
        }

        try
        {
            $wshShell = New-Object -ComObject WScript.Shell
            $shortcut = $wshShell.CreateShortcut(`
                $PSCmdlet.GetUnresolvedProviderPathFromPSPath($shortcutFile))
            $shortcut.TargetPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($TargetPath)
            $shortcut.Save()
        }
        catch [Exception]
        {
            Write-Verbose -Message ($LocalizedData.ErrorSavingShortcut -f $ShortcutPath)

        }
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ParentDoesNotExist -f $ShortcutPath)
        throw $_
    }

}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateSet("Present", "Absent")]
        [string] $Ensure = "Present",
        
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShortcutName,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShortcutPath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $TargetPath
    )

    try
    {
        Write-Verbose -Message $LocalizedData.CheckingShorcutFileEntry
             
        $fullPath   = Join-Path $ShortcutPath "$ShortcutName.lnk"
        $fileExist  = Test-Path -Path $fullPath
        
        if ($Ensure -eq "Present")
        {
            if ($fileExist)
            {
                if ((Get-ShorcutMeta -ShortcutPath $fullPath).TargetPath -eq $TargetPath)
                {
                    Write-Verbose -Message ($LocalizedData.ShortcutFileEntryFound -f `
                        $fullPath, $TargetPath)
                    return $true
                }
                else
                {
                    Write-Verbose -Message ($LocalizedData.ShortcutFileTargetDiff -f $fullPath)
                    return $false
                }
            }
            else
            {
                Write-Verbose -Message $LocalizedData.ShortcutFileEntryShouldExist
                return $false
            }
        }
        else
        {
            if ($fileExist)
            {
                Write-Verbose -Message $LocalizedData.ShortcutFileShouldNotExist
                return $false
            }
            else
            {
                Write-Verbose -Message ($LocalizedData.ShortcutFileEntryNotFound -f $fullPath)
                return $true
            }
        }
        
    }
    catch
    {
        $exception = $_
        Write-Verbose -Message ($LocalizedData.AnErrorOccurred -f $name, $exception.message)
        while ($null -ne $exception.innerException)
        {
            $exception = $exception.innerException
            Write-Verbose -Message ($LocalizedData.InnerException -f $name, $exception.message)
        }
    }
    
}

function Set-TargetResource 
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [ValidateSet("Present", "Absent")]
        [string] $Ensure = "Present",
        
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShortcutName,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShortcutPath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $TargetPath
    )

    $shortcutFile = (Join-Path $ShortcutPath "$ShortcutName.lnk")
    
    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ($LocalizedData.CreatingShortcutFileEntry -f $shortcutFile)
        Set-Shortcut -ShortcutName $ShortcutName -ShortcutPath $ShortcutPath -TargetPath $TargetPath
        Write-Verbose -Message ($LocalizedData.ShortcutFileEntryAdded -f $shortcutFile)        
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.RemovingShortcutFileEntry -f $shortcutFile)
        Remove-Item -Path $shortcutFile
        Write-Verbose -Message ($LocalizedData.ShortcutFileEntryRemoved -f $shortcutFile)
    }

}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]    
    param
    (       
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShortcutName,        

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShortcutPath,    

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $TargetPath        
    )

    $configuration =
    @{
        ShortcutName = $ShortcutName
        ShortcutPath = $ShortcutPath
        TargetPath   = $TargetPath
    }

    Write-Verbose -Message $LocalizedData.CheckingShorcutFileEntry

    $shortcutFile = (Join-Path $ShortcutPath "$ShortcutName.lnk")                     

    if (Test-TargetResource -ShortcutName $ShortcutName -ShortcutPath $ShortcutPath `
        -TargetPath $TargetPath)
    {
        Write-Verbose -Message ($LocalizedData.ShortcutFileEntryFound -f $shortcutFile, $TargetPath)
        $configuration.Add('Ensure','Present')
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ShortcutFileEntryNotFound -f $shortcutFile)
        $configuration.Add('Ensure','Absent')
    }

    return $configuration
}