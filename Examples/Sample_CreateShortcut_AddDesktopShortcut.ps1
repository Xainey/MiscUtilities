configuration Sample_CreateShortcut_AddDesktopShortcut
{
    param
    (
        [string[]] $NodeName = 'localhost'
    )

    Import-DscResource -Module MiscUtilities

    Node $NodeName
    {
        CreateShortcut AddPublicNotepadShortcut
        {
            Ensure          = "Present"
            ShortcutPath    = "C:\Users\Public\Desktop"
            ShortcutName    = "Notepad"
            TargetPath      = "C:\Windows\System32\notepad.exe"
        }
    }
}

Sample_CreateShortcut_AddDesktopShortcut
Start-DscConfiguration -Verbose -Wait -Force Sample_CreateShortcut_AddDesktopShortcut