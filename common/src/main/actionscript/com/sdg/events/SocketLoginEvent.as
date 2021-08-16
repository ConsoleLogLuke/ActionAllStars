/**
* ...
* @author Lance Sanders
* @version 0.1
*/
package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;

	public class SocketLoginEvent extends CairngormEvent
	{
		public static const SOCKET_LOGIN:String = "socketLogin";
		
		public var serverId:uint;
		
		public function SocketLoginEvent(serverId:uint)
		{
			super(SOCKET_LOGIN);
			this.serverId = serverId;
		}
	}
}