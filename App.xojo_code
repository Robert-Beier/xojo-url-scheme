#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Close()
		  // IPCSocket has to be closed or there will be an error in the next listening instance
		  if siaContr <> nil then
		    siaContr.close
		  end
		End Sub
	#tag EndEvent

	#tag Event
		Function HandleAppleEvent(theEvent As AppleEvent, eventClass As String, eventID As String) As Boolean
		  // url scheme is recieved here on mac
		  if eventClass = "GURL"  and siaContr <> nil then
		    return siaContr.HandleAppleEvent(theEvent, eventClass)
		  end
		  return false
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  siaContr = new SIAController
		  AddHandler siaContr.DataAvailable, AddressOf app.siaUseParams
		  AddHandler siaContr.InitApplication, AddressOf app.initApplication
		  #if TargetWindows then
		    siaContr.registerUrlSchemeWindows // should be moved to installer in final application
		  #endif
		  siaContr.searchOtherInstances
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub initApplication(thisSiaContr As SIAController)
		  // initApplication is required, because searchOtherInstances is an async method and the application would continue initializing in the open event, before knowing, if it even should
		  LogWindow.LogListBox.AddRow("initApplication")
		  siaContr.initApplicationDone
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub siaUseParams(thisSiaContr As SIAController, params as String)
		  LogWindow.LogListBox.AddRow(params)
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
