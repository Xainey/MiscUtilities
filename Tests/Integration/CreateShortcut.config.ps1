$TestShortcut = [PSObject]@{
    Ensure          = 'Present'
    ShortcutPath    = 'C:\Users\Public\Desktop'
    ShortcutName    = 'Notepad'
    TargetPath      = 'C:\Windows\System32\notepad.exe'
}

configuration CreateShortcut_config
{
    param
    (
        [string[]] $NodeName = 'localhost'
    )
    
    Import-DscResource -ModuleName MiscUtilities
    
    Node $NodeName
    {
        CreateShortcut Integration_Test
        {
            Ensure          = $TestShortcut.Ensure
            ShortcutPath    = $TestShortcut.ShortcutPath
            ShortcutName    = $TestShortcut.ShortcutName
            TargetPath      = $TestShortcut.TargetPath
        }
    }
}
