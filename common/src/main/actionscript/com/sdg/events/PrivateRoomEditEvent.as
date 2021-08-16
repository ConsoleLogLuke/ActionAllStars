/**
* ...
* @author Lance Sanders
* @version 0.1
*/
package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;

	public class PrivateRoomEditEvent extends CairngormEvent
	{
		public static const EDIT_PRIVATE_ROOM:String = "editPrivateRoom";
		public static const SAVE_PRIVATE_ROOM:String = "savePrivateRoom";
		public static const REVERT_PRIVATE_ROOM:String = "revertPrivateRoom";
		public static const UPDATE_PRIVATE_ROOM:String = "updatePrivateRoom";
		
		public function PrivateRoomEditEvent(type:String)
		{
			super(type);
		}
	}
}