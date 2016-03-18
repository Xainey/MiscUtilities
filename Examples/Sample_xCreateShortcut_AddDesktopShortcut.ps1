configuration Sample_xCreateShortcut_AddDesktopShortcut
{
    param
    (
        [string[]] $NodeName = 'localhost'
    )

    Import-DscResource -Module xMiscUtilities

    Node $NodeName
    {
        xCreateShortcut AddPublicNotepadShortcut
        {
            Ensure          = "Present"
            ShortcutPath    = "C:\Users\Public\Desktop"
            ShortcutName    = "Notepad"
            TargetPath      = "C:\Windows\System32\notepad.exe"
        }
    }
}

Sample_xCreateShortcut_AddDesktopShortcut
Start-DscConfiguration -Verbose -Wait -Force Sample_xCreateShortcut_AddDesktopShortcut