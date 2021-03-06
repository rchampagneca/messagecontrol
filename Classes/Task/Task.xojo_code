#tag Class
Protected Class Task
Inherits Thread
	#tag Event
		Sub Run()
		  InternalPushEvent( New TaskEvent( TaskEvent.Types.Begin ) )
		  
		  Try
		    RaiseEvent Run
		  Catch exc As ThreadEndException
		    // FIXME: we probably want to make sure this isn't being sent because
		    // the app is quitting?
		    InternalPushEvent( New TaskEvent( TaskEvent.Types.Killed ) )
		    Raise exc
		  End Try
		  
		  InternalPushEvent( New TaskEvent( TaskEvent.Types.Finished ) )
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h1000
		Sub Constructor()
		  mLock = New CriticalSection
		  mTimer = New Timer
		  AddHandler mTimer.Action, WeakAddressOf InternalDispatchEvents
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InternalDispatchEvents(sender as Timer)
		  // Takes the events in the queue and dispatches them to the correct event handler.
		  //
		  // NOTE: must be called from the main thread.
		  
		  While True
		    Dim currentEvent As TaskEvent
		    
		    mLock.Enter
		    If mEvents.UBound >= 0 Then
		      currentEvent = mEvents( 0 )
		      mEvents.Remove( 0 )
		    Else
		      mLock.Leave
		      Exit Sub
		    End If
		    mLock.Leave
		    
		    Select Case currentEvent.type
		    Case TaskEvent.Types.Begin
		      RaiseEvent Begin
		    Case TaskEvent.Types.UpdateUI
		      RaiseEvent UpdateUI( currentEvent.Arguments )
		    Case TaskEvent.Types.Finished
		      RaiseEvent Finished
		    Case TaskEvent.Types.Killed
		      RaiseEvent Killed
		    End Select
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InternalPushEvent(evt as TaskEvent)
		  // Adds an event to the event queue. This can be called from any thread, but is
		  // usually called from the non-main thread.
		  
		  mLock.Enter
		  mEvents.Append( evt )
		  mTimer.Period = 0
		  mTimer.Mode = Timer.ModeSingle
		  mLock.Leave
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateUI(args as Dictionary)
		  // Adds an UpdateUI event to the queue, which will eventually be dequeued
		  // on the main thread and raise the UpdateUI event.
		  
		  Dim evt As New TaskEvent( TaskEvent.Types.updateUI )
		  evt.Arguments = args
		  internalPushEvent( evt )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateUI(paramarray args as Pair)
		  // Adds an UpdateUI event to the queue, which will eventually be dequeued
		  // on the main thread and raise the UpdateUI event.
		  //
		  // This specific method is a convenience function in order to be able to
		  // use Pair literals. For example:
		  //   UpdateUI( "progress": 10, "total_progress": 100 )
		  
		  Dim d As New Dictionary
		  For Each arg As Pair In args
		    d.Value( arg.Left ) = arg.Right
		  Next
		  
		  Self.UpdateUI( d )
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Begin()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Finished()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Killed()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Run()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UpdateUI(args as Dictionary)
	#tag EndHook


	#tag Property, Flags = &h21
		#tag Note
			The queue of pending events. This is protected by mLock in order to provide
			thread safety.
		#tag EndNote
		Private mEvents() As TaskEvent
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLock As CriticalSection
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			This timer is used to punt events from the thread onto the main thread, where
			InternalDispatchEvents will process all of the queued events.
		#tag EndNote
		Private mTimer As Timer
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Priority"
			Visible=true
			Group="Behavior"
			InitialValue="5"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StackSize"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
