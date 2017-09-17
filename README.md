# Summary
An PowerShell class for utilizing the API's for SONARR.

# Requirements
Minimum PS Version of 5.0 -- https://www.microsoft.com/en-us/download/details.aspx?id=54616

# How-To-Use
There are a couple of ways to import the class in your script or session:

1. Read Content and Execute
  * Quickest and dirtiest way to import the module  
  ``$content = Get-Content "<path to module>"``    
  ``Invoke-Expression $content``

2. Putting ``using <path to module>`` at the beginning of your script.
  * Only downside to this method is that module path must be ABSOLUTE and does not accept variables.
 
3. Using this command sequence:

      ``Import-Module <path to module>``  
      ``$sonarr = & (Get-Module Sonarr).NewBoundScriptBlock({[SonarrPVR]::new("<your sonarr URL>")})``
   This creates an object called "$sonarr" in your session or script, and is not limited to absolute paths.
   
# Notes
For more information about PowerShell Classes in 5.0, go to https://xainey.github.io/2016/powershell-classes-and-concepts/
