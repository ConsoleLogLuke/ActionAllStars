/**
* ...
* @author Lance Sanders
* @version 0.1
*/
package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;

	public class InventoryListEvent extends CairngormEvent
	{
		public static const LIST:String = "customizerList";
		public static const LIST_COMPLETED:String = "customizerListCompleted";
		public static const LIST_FAILED:String = "inventory list failed";
		
		public var avatarId:uint;
		public var itemTypeId:uint;
		
		public function InventoryListEvent(avatarId:uint, itemTypeId:uint, type:String = LIST)
		{
			super(type);
			this.avatarId = avatarId;
			this.itemTypeId = itemTypeId;
		}
	}
}