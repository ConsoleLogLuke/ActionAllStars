package it.gotoandplay.smartfoxserver
{
	import flash.events.Event;
	
	/**
	 * 
	 * SFSEvent class
	 * 
	 * @version 	1.0.5
	 * @status 		beta
	 * @author 		Marco Lapi
	 * 
	 * (c) 2006 gotoAndPlay()
	 * www.gotoandplay.it
	 * www.smartfoxserver.com
	 * 
	 */
	public class SFSEvent extends Event
	{
		// Public event type constants ...
		public static const onConnectionLost:String = "onConnectionLost"
		public static const onCreateRoomError:String = "onCreateRoomError"
		//public static const onConnect:String = "onConnect"
		public static const onConnection:String = "onConnection"
		public static const onJoinRoom:String = "onJoinRoom"
		public static const onJoinRoomError:String = "onJoinRoomError"
		public static const onLogin:String = "onLogin"
		public static const onObjectReceived:String = "onObjectReceived"
		public static const onPublicMessage:String = "onPublicMessage"
		public static const onPrivateMessage:String = "onPrivateMessage"
		public static const onAdminMessage:String = "onAdminMessage"
		public static const onModeratorMessage:String = "onModMessage"
		public static const onRoomAdded:String = "onRoomAdded"
		public static const onRoomDeleted:String = "onRoomDeleted"
		public static const onRoomLeft:String = "onRoomLeft"
		public static const onRoomListUpdate:String = "onRoomListUpdate"
		public static const onRoomVariablesUpdate:String = "onRoomVariablesUpdate"
		public static const onRoundTripResponse:String = "onRoundTripResponse"
		public static const onUserCountChange:String = "onUserCountChange"
		public static const onUserEnterRoom:String = "onUserEnterRoom"
		public static const onUserLeaveRoom:String = "onUserLeaveRoom"
		public static const onUserVariablesUpdate:String = "onUserVariablesUpdate"
		public static const onExtensionResponse:String = "onExtensionResponse"
		public static const onSpectatorSwitched:String = "onSpectatorSwitched"
		public static const onBuddyList:String = "onBuddyList"
		public static const onBuddyListUpdate:String = "onBuddyListUpdate"
		public static const onBuddyListError:String = "onBuddyListError"
		public static const onBuddyRoom:String = "onBuddyRoom"
		public static const onRandomKey:String = "onRandomKey"
		
		public var params:Object
		
		/**
		 * Constructor
		 * 
		 * @type	the type of event
		 * @params	the parameters object for the event
		 */
		public function SFSEvent(type:String, params:Object)
		{
			super(type)
			this.params = params
		}
		
		/**
		 * Creates and returns a copy of the current instance.
		 * @return	A copy of the current instance.
		 */
		public override function clone():Event
		{
			return new SFSEvent(this.type, this.params)
		}
		
		
		/**
		 * Returns a String containing all the properties of the current
		 * instance.
		 * @return A string representation of the current instance.
		 */
		public override function toString():String
		{
			return formatToString("SFSEvent", "type", "bubbles", "cancelable", "eventPhase", "params")
		}
	}
}