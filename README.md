[![Build status](https://ci.appveyor.com/api/projects/status/pxuqp2klswq54o8c/branch/master?svg=true)](https://ci.appveyor.com/project/Xainey/miscutilities/branch/master)

# Notes:
* This repo is a test run for creating a basic Powershell Desired State Configuration (DSC) resource.
* For lack of a better naming sense, I've used MiscUtilities and CreateShortcut.
* Follows advice and examples from:
    * [Style Guidelines](https://github.com/PowerShell/DscResources/blob/master/StyleGuidelines.md)
    * [Design Checklist](https://blogs.msdn.microsoft.com/powershell/2014/11/18/powershell-dsc-resource-design-and-testing-checklist/)
    * [Daniel Scott-Raynsford DSC Tutorial Series](https://dscottraynsford.wordpress.com/2015/12/14/creating-professional-dsc-resources-part-1/)
    * [xNetworking Resource](https://github.com/PowerShell/xNetworking/tree/master/DSCResources)
* Feel free to make suggestions.

## Meeting Coding Standards    
* Localization file structure created in **en-US** dir vs adding at the top of the module `.psm1` file in a **Data** section.
* ~~Module name prefix was set to *MSFT_*, being that this is reserved for Microsoft it should be changed.~~
* MOF based module vs. class based for WMF backwards compatibility.
* Nested Logic in **Test-TargetResource** contains 3 levels -- low complexity but could be refactored.
* Localization keys and `$LocalizedData` have all been capitalized. 

# MiscUtilities

The **MiscUtilities** module contains the following resources:
* **CreateShorcut**

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

## Resources

* **CreateShorcut** creates a shortcut .lnk in the specified location.

### CreateShorcut

* **ShortcutName**: Specifies the name of the .lnk file. Mandatory.
* **ShortcutPath**: Specifies the root path of the shortcut file. Mandatory.
* **TargetPath**: Specifies the target path of the shortcut. Mandatory.
* **Ensure**: Specifies if the shortcut file should be created or deleted. { Present | Absent }.

## Versions

### Unreleased

* N/A

### 1.0.5.0

* Removed `x` and `MSFT_` prefixes from all Modules.

### 1.0.0.0

* Initial release with the following resources:
    * xCreateShortcut

## Examples

### Create a Desktop shortcut for all users to notepad

This configuration will add a shortcut to notepad.exe the public users desktop.

```powershell
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
```
