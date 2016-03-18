$TestShortcut = [PSObject]@{
    Ensure          = 'Present'
    ShortcutPath    = 'C:\Users\Public\Desktop'
    ShortcutName    = 'Notepad'
    TargetPath      = 'C:\Windows\System32\notepad.exe'
}

configuration MSFT_xCreateShortcut_config
{
    param
    (
        [string[]] $NodeName = 'localhost'
    )
    
    Import-DscResource -ModuleName xMiscUtilities
    
    Node $NodeName
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
