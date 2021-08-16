/**
* ...
* @author Lance Sanders
* @version 0.1
*/
package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;

	public class AvatarListEvent extends CairngormEvent
	{
		public static const LIST:String = "list";
		
		public var username:String;
		
		public function AvatarListEvent(username:String)
		{
			super(LIST);
			this.username = username;
		}
	}
}