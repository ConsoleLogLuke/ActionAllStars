/**
* ...
* @author Lance Sanders
* @version 0.1
*/
package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;

	public class AvatarApparelEvent extends CairngormEvent
	{
		public static const AVATAR_APPAREL:String = "avatarApparel";
		public static const AVATAR_APPAREL_COMPLETED:String = "avatarApparelCompleted";
		public static const AVATAR_APPAREL_CHANGED:String = "avatarApparelChanged";
		
		public var _avatar:Avatar;
		private var _oldItem:InventoryItem;
		private var _newItem:InventoryItem;
		
		public function AvatarApparelEvent(avatar:Avatar, type:String = AVATAR_APPAREL, oldApparelItem:InventoryItem = null, newApparelItem:InventoryItem = null)
		{
			super(type);
			this._avatar = avatar;
			_oldItem = oldApparelItem;
			_newItem = newApparelItem;
		}
		
		public function get avatar():Avatar
		{
			return _avatar;
		}
		
		public function get oldItem():InventoryItem
		{
			return _oldItem;
		}

		public function get newItem():InventoryItem
		{
			return _newItem;
		}
	}
}