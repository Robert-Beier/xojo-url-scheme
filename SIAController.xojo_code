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
		    siaSocket.Write("I obey!") // TODO insert args
		    siaSocket.Flush
		    siaSocket.Close
		    app.siaAnswerReceived
		  end
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableEvent(thisSocket As IPCSocket)
		  app.log(thisSocket.ReadAll)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ErrorEvent(thisSocket As IPCSocket)
		  dim siaErrorCode as Integer
		  siaErrorCode = thisSocket.LastErrorCode
		  if not siaErrorCode = 103 and not siaErrorCode = 102 then
		    errorCounter = errorCounter + 1
		    if errorCounter >= maxErrors then
		      siaSocket.Close
		      return
		    end
		  end
		  
		  // if no other instance is listening, make this the only instance
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
		    app.siaAnswerReceived
		  end
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub prepareSIASocket()
		  siaSocket = new IPCSocket
		  siaSocket.Path = SpecialFolder.Temporary.Child("com.mydomain.appname.socket").NativePath
		  
		  AddHandler siaSocket.Connected, AddressOf ConnectedEvent
		  AddHandler siaSocket.DataAvailable, AddressOf DataAvailableEvent
		  AddHandler siaSocket.Error, AddressOf ErrorEvent
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
