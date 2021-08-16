package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class GetAsnEvent extends CairngormEvent
	{
		public static const GET_ASN:String = "getAsn";
		
		private var _avatarId:uint;
				
		public function GetAsnEvent(avatarId:uint, type:String = GET_ASN)
		{
			super(type);
			_avatarId = avatarId;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
	}
}