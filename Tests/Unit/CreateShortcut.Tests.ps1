$Global:DSCModuleName      = 'MiscUtilities'
$Global:DSCResourceName    = 'CreateShortcut'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization
        $MockShortcutEntry = [PSCustomObject] @{
            ShortcutName            = 'Notepad'
            ShortcutPath            = 'C:\Users\Public\Desktop'
            TargetPath              = 'C:\Windows\System32\notepad.exe'
        }

        $ShortcutEntry = [PSObject]@{
            ShortcutName            = $MockShortcutEntry.ShortcutName
            ShortcutPath            = $MockShortcutEntry.ShortcutPath
            TargetPath              = $MockShortcutEntry.TargetPath
        }
        #endregion

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'Shortcut file entry does not exist' {
                Mock Test-TargetResource
                It 'Should return ensure as absent' {
                    $Result = Get-TargetResource @ShortcutEntry
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Test-TargetResource -Exactly 1
                }
                It 'Should not throw' {
                    {Get-TargetResource @ShortcutEntry} | Should Not Throw
                }                   
            }
    
            Context 'Shortcut file entry exists' {
                Mock Test-TargetResource -MockWith { $true }
                It 'Should return shortcut entry' {
                    $Result = Get-TargetResource @ShortcutEntry
                    $Result.Ensure                 | Should Be 'Present'
                    $Result.ShortcutName           | Should Be $ShortcutEntry.ShortcutName
                    $Result.ShortcutPath           | Should Be $ShortcutEntry.ShortcutPath
                    $Result.TargetPath             | Should Be $ShortcutEntry.TargetPath
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Test-TargetResource -Exactly 1
                }
                It 'Should not throw' {
                    {Get-TargetResource @ShortcutEntry} | Should Not Throw
                }   
            }
    
        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

             Context 'Shortcut file entry exists and it should' {
                Mock Get-ShorcutMeta { return @{TargetPath = $ShortcutEntry.TargetPath} }
                Mock Test-Path -MockWith { $true }
                
                It 'should return true' {
                    $newEntry = $ShortcutEntry.Clone()
                    $newEntry.Ensure = 'Present'
                    Test-TargetResource @newEntry | Should Be $true
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-ShorcutMeta -Exactly 1
                    Assert-MockCalled -commandName Test-Path -Exactly 1
                }
             }
             
             Context 'Shortcut file entry exists but target is wrong' {
                Mock Get-ShorcutMeta { return @{TargetPath = "c:\wrong.exe"} }
                Mock Test-Path -MockWith { $true }
                
                It 'should return false' {
                    $newEntry = $ShortcutEntry.Clone()
                    $newEntry.Ensure = 'Present'                    
                    Test-TargetResource @newEntry | Should Be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-ShorcutMeta -Exactly 1
                    Assert-MockCalled -commandName Test-Path -Exactly 1
                }
             }  
                        
             Context 'Shortcut file entry does not exist but it should' {
                Mock Get-ShorcutMeta { return @{TargetPath = $ShortcutEntry.TargetPath} }
                Mock Test-Path -MockWith { $false }
                                 
                It 'should return false' {
                    $newEntry = $ShortcutEntry.Clone()
                    $newEntry.Ensure = 'Present'                    
                    Test-TargetResource @newEntry | Should Be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-ShorcutMeta -Exactly 0
                    Assert-MockCalled -commandName Test-Path -Exactly 1
                }
             }
             
             Context 'Shortcut file entry exists but it should not' {
                Mock Get-ShorcutMeta { return @{TargetPath = $ShortcutEntry.TargetPath} }
                Mock Test-Path -MockWith { $true }
                                 
                It 'should return false' {
                    $newEntry = $ShortcutEntry.Clone()
                    $newEntry.Ensure = 'Absent'                    
                    Test-TargetResource @newEntry | Should Be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-ShorcutMeta -Exactly 0
                    Assert-MockCalled -commandName Test-Path -Exactly 1
                }
             }
             
             Context 'Shortcut file entry does not exist and it should not' {
                Mock Get-ShorcutMeta { return @{TargetPath = $ShortcutEntry.TargetPath} }
                Mock Test-Path -MockWith { $false }
                                 
                It 'should return true' {
                    $newEntry = $ShortcutEntry.Clone()
                    $newEntry.Ensure = 'Absent'                    
                    Test-TargetResource @newEntry | Should Be $true
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-ShorcutMeta -Exactly 0
                    Assert-MockCalled -commandName Test-Path -Exactly 1
                }
             }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'Shortcut file entry does not exist but should' {
                Mock Set-Shortcut
                Mock Remove-Item

                It 'Should not throw' {
                    {
                        $newEntry = $ShortcutEntry.Clone()
                        $newEntry.Ensure = 'Present'
                        Set-TargetResource @newEntry
                    } | Should Not Throw
                }     
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Set-Shortcut -Exactly 1
                    Assert-MockCalled -commandName Remove-Item -Exactly 0
                }
            }
    
            Context 'Shortcut file entry exists but should not' {
                Mock Set-Shortcut
                Mock Remove-Item

                It 'Should not throw' {
                    {
                        $newEntry = $ShortcutEntry.Clone()
                        $newEntry.Ensure = 'Absent'
                        Set-TargetResource @newEntry
                    } | Should Not Throw
                }     
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Set-Shortcut -Exactly 0
                    Assert-MockCalled -commandName Remove-Item -Exactly 1
                }
            }

        }
        #endregion

        # Pester Tests for any Helper Cmdlets

        #region Function Set-Shortcut
        Describe "$($Global:DSCResourceName)\Set-Shortcut" {
            
            BeforeAll {
                $ShortcutName = 'Notepad'
                $ShortcutPath = 'TestDrive:\'
                $TargetPath   = 'C:\Windows\System32\notepad.exe'

                Set-Shortcut -ShortcutName $ShortcutName -ShortcutPath $ShortcutPath -TargetPath $TargetPath
            }
            
            Context 'ProviderPath Resolution' {
                It 'Exists' {
                    $ShortcutPath = Join-Path (resolve-path 'TestDrive:\').ProviderPath 'Notepad.lnk'
                    $ShortcutPath | Should Exist           
                }
                It 'Has the correct targetPath' {
                    $ShortcutPath = Join-Path (resolve-path 'TestDrive:\').ProviderPath 'Notepad.lnk'
                    $TargetPath   = 'C:\Windows\System32\notepad.exe'
                    (Get-ShorcutMeta -ShortcutPath $ShortcutPath).TargetPath | Should Be $TargetPath
                }
            }
            
            Context 'Pester TestDrive Path' {
                It 'Exists' {
                    $ShortcutPath = 'TestDrive:\Notepad.lnk'
                    $ShortcutPath | Should Exist
                }
                It 'Has the correct targetPath' {
                    $ShortcutPath = 'TestDrive:\Notepad.lnk'
                    $TargetPath   = 'C:\Windows\System32\notepad.exe'
                    (Get-ShorcutMeta -ShortcutPath $ShortcutPath).TargetPath | Should Be $TargetPath
                }
            }
            
            Context 'Set-Shorcut' {
                It 'Creates a shortcut properly' {
                    Mock Test-Writtable { return $true }

                    $ShortcutName = 'Notepad'
                    $ShortcutPath = 'TestDrive:\Exists'
                    $TargetPath   = 'C:\Windows\System32\notepad.exe'

                    New-Item $ShortcutPath -type directory
                    Set-Shortcut -ShortcutName $ShortcutName -ShortcutPath $ShortcutPath -TargetPath $TargetPath
                    Join-Path $ShortcutPath "$ShortcutName.lnk" | Should Exist
                }
                It 'Overwrites existing shortcuts' {
                    Mock Test-Writtable { return $true }

                    $ShortcutName = 'Notepad'
                    $ShortcutPath = 'TestDrive:\Overwrite'
                    $TargetPath   = 'C:\Windows\System32\notepad.exe'
                    $TargetPath2  = 'C:\Windows\System32\Magnify.exe'

                    New-Item $ShortcutPath -type directory
                    Set-Shortcut -ShortcutName $ShortcutName -ShortcutPath $ShortcutPath -TargetPath $TargetPath
                    Set-Shortcut -ShortcutName $ShortcutName -ShortcutPath $ShortcutPath -TargetPath $TargetPath2    
                    (Get-ShorcutMeta -ShortcutPath "$ShortcutPath\$ShortcutName.lnk").TargetPath | Should Be $TargetPath2
                }
                It 'Fails if parent path does not exist' {
                    $ShortcutName = 'Notepad'
                    $ShortcutPath = 'TestDrive:\NotExist'
                    $TargetPath   = 'C:\Windows\System32\notepad.exe'

                    { Set-Shortcut -ShortcutName $ShortcutName -ShortcutPath $ShortcutPath -TargetPath $TargetPath } | Should throw
                }
                It 'Fails is shortcut path is not writtable' {
                    Mock Test-Writtable { return $false }

                    $ShortcutName = 'Notepad'
                    $ShortcutPath = 'TestDrive:\Readonly'
                    $TargetPath   = 'C:\Windows\System32\notepad.exe'

                    { Set-Shortcut -ShortcutName $ShortcutName -ShortcutPath $ShortcutPath -TargetPath $TargetPath } | Should throw
                }
            }
            
        }
        #endregion

    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}