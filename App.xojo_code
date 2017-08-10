#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Close()
		  siaContr.close
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  siaContr = new SIAController
		  siaContr.searchOtherInstances
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub log(logMessage as String)
		  LogWindow.LogListBox.AddRow(logMessage)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub siaAnswerReceived()
		  if not siaContr.answerReceived then
		    LogWindow.LogListBox.AddRow("no answer received")
		  else
		    LogWindow.LogListBox.AddRow("answer received")
		    if siaContr.otherInstanceExists then
		      quit
		    end
		  end
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
