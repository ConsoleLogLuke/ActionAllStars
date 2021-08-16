/**
* ...
* @author Lance Sanders
* @version 0.1
*/
package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.model.Avatar;

	public class AvatarApparelSaveEvent extends CairngormEvent
	{
		public static const AVATAR_APPAREL_SAVE:String = "avatarApparelSave";
		public static const SAVE_SUCCESS:String = "avatar apparel save success";
		
		public var avatar:Avatar;

		
		public function AvatarApparelSaveEvent(avatar:Avatar, type:String = AVATAR_APPAREL_SAVE)
		{
			super(type);
			this.avatar = avatar;
		}
	}
}