#tag Class
Protected Class SIAController
	#tag Method, Flags = &h0
		Sub close()
		  siaSocket.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ConnectedEvent(thisSocket As IPCSocket)
		  // if other instance is already listening, parse arguments and close
		  if not answerReceived then
		    answerReceived = true
		    otherInstanceExists = true
		    dim urlSchemeArgs as String = parseUrlSchemeWindows(System.CommandLine)
		    if urlSchemeArgs.Len > 0 then
		      siaSocket.Write(urlSchemeArgs)
		    end
		    siaSocket.Flush
		    siaSocket.Close
		    app.initApplication
		  end
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableEvent(thisSocket As IPCSocket)
		  // url scheme is recieved here on windows
		  app.useParams(thisSocket.ReadAll)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ErrorEvent(thisSocket As IPCSocket)
		  // error 102 always occurs if another instance connects, passes an url and closes connection -> retry listening
		  // error 103 is expected if other instance is already running -> pass url and close connection
		  // error 105 occurs if other instance did not close listening connection before closing -> should work on retry listening
		  
		  dim siaErrorCode as Integer
		  siaErrorCode = thisSocket.LastErrorCode
		  // count unexpected errors in order to not get stuck in a loop by always retrying
		  if not siaErrorCode = 103 and not siaErrorCode = 102 then
		    errorCounter = errorCounter + 1
		    if errorCounter >= maxErrors then
		      siaSocket.Close
		      return
		    end
		  end
		  
		  // if no other instance is listening, make this the only instance and init application after listening
		  if siaErrorCode = 103 then
		    answerReceived = true
		    otherInstanceExists = false
		  end
		  
		  // try reconnect/listen on all other error codes too
		  if not answerReceived then
		    siaSocket.Close
		    siaSocket.Connect
		  elseif not otherInstanceExists then
		    siaSocket.Close
		    siaSocket.Listen
		  end
		  
		  if siaErrorCode = 103 then
		    app.initApplication
		  end
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function parseUrlSchemeMac(theEvent as AppleEvent) As String
		  // myscheme:hello_world -> hello_world
		  try
		    dim urlSchemeParts() as string = DecodeURLComponent(theEvent.StringParam("----")).DefineEncoding(encodings.UTF8).Split(":")
		    return urlSchemeParts(1)
		  catch exc as OutOfBoundsException
		    return ""
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function parseUrlSchemeWindows(appCall as String) As String
		  // "C:\url-scheme.exe" "myscheme:hello_world" -> hello_world
		  try
		    dim appCallParts() as String = appCall.Split(" ")
		    dim urlSchemeParts() as String = appCallParts(1).ReplaceAll("""", "").Split(":")
		    return urlSchemeParts(1)
		  catch exc as OutOfBoundsException
		    return ""
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub prepareSIASocket()
		  siaSocket = new IPCSocket
		  siaSocket.Path = SpecialFolder.Temporary.Child("com.cranberrystackcookie.url-scheme.siasocket").NativePath
		  
		  AddHandler siaSocket.Connected, AddressOf ConnectedEvent
		  AddHandler siaSocket.DataAvailable, AddressOf DataAvailableEvent
		  AddHandler siaSocket.Error, AddressOf ErrorEvent
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub registerUrlSchemeWindows()
		  // registry entry only has to be created once the application is installed or moved
		  // it requires the application to be run as admininstrator
		  #if TargetWindows then
		    try
		      Dim reg As New RegistryItem("HKEY_CLASSES_ROOT")
		      reg = reg.AddFolder("myscheme") // insert url scheme for windows here
		      reg.DefaultValue = "Url Scheme Test"
		      reg.Value("URL Protocol") = ""
		      Dim defaultIcon As RegistryItem = reg.AddFolder("DefaultIcon")
		      defaultIcon.DefaultValue = """" + App.ExecutableFile.NativePath + """,1"
		      
		      Dim commandItem As RegistryItem = reg.AddFolder("shell").AddFolder("open").AddFolder("command")
		      commandItem.DefaultValue = """" + App.ExecutableFile.NativePath + """ ""%1"""
		    catch exc as RegistryAccessErrorException
		    end try
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub searchOtherInstances()
		  prepareSIASocket
		  siaSocket.Connect
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		answerReceived As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private errorCounter As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private maxErrors As Integer = 5
	#tag EndProperty

	#tag Property, Flags = &h0
		otherInstanceExists As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private siaSocket As IPCSocket
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="answerReceived"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="otherInstanceExists"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
