#tag Class
Protected Class SIAController
	#tag Method, Flags = &h0
		Sub close()
		  if siaSocket <> nil then
		    siaSocket.Close
		  end
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ConnectedEvent(thisSocket As IPCSocket)
		  // if other instance is already listening, parse parameters and close
		  if not responseRecieved then
		    dim urlSchemeParams as String = parseUrlSchemeWindows(System.CommandLine)
		    if urlSchemeParams.Len > 0 then
		      siaSocket.Write(urlSchemeParams)
		    end
		    siaSocket.Flush
		    siaSocket.Close
		    quit
		  end
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableEvent(thisSocket As IPCSocket)
		  // url scheme is recieved here on windows
		  useParams(thisSocket.ReadAll)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ErrorEvent(thisSocket As IPCSocket)
		  // error 102 always occurs if another instance connects, passes an url and closes connection -> retry listening
		  // error 103 is expected no other instance is running -> start listening
		  // error 105 occurs if other instance is still listening (also if instance is closed, but did not close listening socket) -> should work on retry listening
		  
		  dim siaErrorCode as Integer = thisSocket.LastErrorCode
		  // count unexpected errors in order to not get stuck in a loop by always retrying
		  if not siaErrorCode = 103 and not siaErrorCode = 102 then
		    errorCounter = errorCounter + 1
		    if errorCounter >= maxErrors then
		      siaSocket.Close
		      InitApplication // if something goes wrong with the IPCSocket, the application should still start
		      return
		    end
		  end
		  
		  // if no other instance is listening, make this the only instance and init application after listening
		  if siaErrorCode = 103 then
		    responseRecieved = true
		  end
		  
		  // try reconnect/listen on all other error codes too
		  if not responseRecieved then
		    siaSocket.Close
		    siaSocket.Connect
		  else
		    siaSocket.Close
		    siaSocket.Listen
		  end
		  
		  if siaErrorCode = 103 then
		    useParams(parseUrlSchemeWindows(System.CommandLine))
		    InitApplication
		  end
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HandleAppleEvent(theEvent As AppleEvent, eventClass As String) As Boolean
		  if eventClass = "GURL" then
		    dim urlSchemeParams as String = parseUrlSchemeMac(theEvent)
		    useParams(urlSchemeParams)
		    return true
		  end if
		  return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub initApplicationDone()
		  isInitApplicationDone = true
		  useParams(lastUrlParamsBeforeInit)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function parseUrlSchemeMac(theEvent as AppleEvent) As String
		  // myscheme:hello_world -> hello_world
		  try
		    dim urlSchemeParts() as string = DecodeURLComponent(theEvent.StringParam("----")).DefineEncoding(encodings.UTF8).Split(":")
		    return urlSchemeParts(1)
		  catch exc as OutOfBoundsException
		    return ""
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function parseUrlSchemeWindows(callText as String) As Text
		  // "C:\url-scheme.exe" "myscheme:hello_world" -> hello_world
		  // parser also handles spaces in path ("C:\url scheme.exe" "myscheme:hello_world")->(hello_world) as well as colons in url scheme ("C:\url-scheme.exe" "myscheme:hello_world:2")->(hello_world:2)
		  // parser can't handle multiple  double quotes after another, yet. Will be fixed
		  // but parser can't recognize, if there is more than one command line argument ("C:\url-scheme.exe" "myscheme:hello_world" "something")->(hello_world" "something)
		  dim callTextParts() As Text = callText.ToText.Split("""")
		  dim urlSchemeParts() As Text
		  dim urlScheme As Text
		  dim urlSchemeParams As Text
		  
		  if callTextParts.Ubound > 3 then
		    if callTextParts.Ubound = 4 and callTextParts(3).Length > 0  then
		      urlScheme = callTextParts(3)
		    else
		      call callTextParts.Pop
		      for indexRmCallTextParts As Integer = 0 to 2
		        callTextParts.Remove(0)
		      next
		      urlScheme = Text.Join(callTextParts, """")
		    end
		    urlSchemeParts = urlScheme.Split(":")
		    if urlSchemeParts.Ubound > 0  then
		      if urlSchemeParts.Ubound = 1 and urlSchemeParts(1).Length > 0  then
		        urlSchemeParams = urlSchemeParts(1)
		      else
		        urlSchemeParts.Remove(0)
		        urlSchemeParams = Text.Join(urlSchemeParts, ":")
		      end
		      return urlSchemeParams
		    else
		      return ""
		    end
		  else
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
		  #if TargetWindows then
		    prepareSIASocket
		    siaSocket.Connect
		  #elseif TargetMacOS
		    InitApplication
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub useParams(urlSchemeParams As String)
		  if isInitApplicationDone then
		    if urlSchemeParams.Len > 0 then
		      DataAvailable(urlSchemeParams)
		    end
		  else
		    lastUrlParamsBeforeInit = urlSchemeParams
		  end
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event DataAvailable(data As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event InitApplication()
	#tag EndHook


	#tag Property, Flags = &h21
		Private errorCounter As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private isInitApplicationDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private lastUrlParamsBeforeInit As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private maxErrors As Integer = 5
	#tag EndProperty

	#tag Property, Flags = &h21
		Private otherInstanceExists As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private responseRecieved As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private siaSocket As IPCSocket
	#tag EndProperty


	#tag ViewBehavior
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
