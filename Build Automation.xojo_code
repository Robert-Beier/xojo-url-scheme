#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin IDEScriptBuildStep addUrlSchemeToPlist , AppliesTo = 0
					// insert url scheme for mac here (replace MyScheme and myscheme)
					Dim appPath As String = CurrentBuildLocation + "/" + CurrentBuildAppName +".app"
					call DoShellCommand("/usr/libexec/PlistBuddy -c ""add :CFBundleURLTypes array"" " + appPath + "/Contents/Info.plist" )
					call DoShellCommand("/usr/libexec/PlistBuddy -c ""add :CFBundleURLTypes:0 dict"" " + appPath + "/Contents/Info.plist" )
					call DoShellCommand("/usr/libexec/PlistBuddy -c ""add :CFBundleURLTypes:0:CFBundleURLName string 'MyScheme'"" " +appPath + "/Contents/Info.plist" )
					call DoShellCommand("/usr/libexec/PlistBuddy -c ""add :CFBundleURLTypes:0:CFBundleURLSchemes array"" " + appPath + "/Contents/Info.plist" )
					call DoShellCommand("/usr/libexec/PlistBuddy -c ""add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string 'myscheme'"" " + appPath + "/Contents/Info.plist" )
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
			End
#tag EndBuildAutomation
