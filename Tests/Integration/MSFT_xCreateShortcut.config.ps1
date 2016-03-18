$TestShortcut = [PSObject]@{
    Ensure          = 'Present'
    ShortcutPath    = 'C:\Users\Public\Desktop'
    ShortcutName    = 'Notepad'
    TargetPath      = 'C:\Windows\System32\notepad.exe'
}

configuration MSFT_xCreateShortcut_config
{   
    Import-DscResource -ModuleName xMiscUtilities
    
    node localhost
    {
        xCreateShortcut Integration_Test
        {
            Ensure          = $TestShortcut.Ensure
            ShortcutPath    = $TestShortcut.ShortcutPath
            ShortcutName    = $TestShortcut.ShortcutName
            TargetPath      = $TestShortcut.TargetPath
        }
    }
}
