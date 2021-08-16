package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetPetListEvent extends CairngormEvent
	{
		public static const GET_PET_LIST:String = "getPetListEvent";
		public static const GET_PET_LIST_COMPLETED:String = "getPetListCompleted";
		
		private var _avatarId:uint;
		private var _petIdArray:Array;
		
		public function GetPetListEvent(type:String,avatarId:int)
		{
			super(type);
			_avatarId = avatarId;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
		
		public function set petIdArray(value:Array):void
		{
			_petIdArray = value;
		}
		
		public function get petIdArray():Array
		{
			return _petIdArray;
		}
	}
}