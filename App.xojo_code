#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Close()
		  // IPCSocket has to be closed or there will be an error in the next listening instance
		  #if TargetWindows then
		    if siaContr <> nil then
		      siaContr.close
		    end
		  #endif
		End Sub
	#tag EndEvent

	#tag Event
		Function HandleAppleEvent(theEvent As AppleEvent, eventClass As String, eventID As String) As Boolean
		  // url scheme is recieved here on mac
		  if eventClass = "GURL" then
		    dim urlSchemeParams as String = siaContr.parseUrlSchemeMac(theEvent)
		    if urlSchemeArgs.Len > 0 then
		      useParams(urlSchemeParams)
		    end
		    return true
		  end if
		  return false
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  siaContr = new SIAController
		  // single instance application is only needed on windows
		  // on MacOS url schemes work with the handleAppleEvent
		  #if TargetWindows then
		    siaContr.registerUrlSchemeWindows // should be moved to installer in final application
		    siaContr.searchOtherInstances
		  #elseif TargetMacOS
		    initApplication
		  #endif
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub initApplication()
		  // application source code starts here after SIA check
		  if siaContr <> nil then
		    if not siaContr.answerReceived then
		      log("no answer received")
		    else
		      log("answer received")
		      if siaContr.otherInstanceExists then
		        quit
		      else
		        dim urlSchemeParams as String = siaContr.parseUrlSchemeWindows(System.CommandLine)
		        if urlSchemeArgs.Len > 0 then
		          useParams(urlSchemeParams)
		        end
		      end
		    end
		  end
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub log(logMessage as String)
		  LogWindow.LogListBox.AddRow(logMessage)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub useParams(params as String)
		  log(params)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private siaContr As SIAController
	#tag EndProperty


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
