package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class AvatarUpdateEvent extends CairngormEvent
	{
		public static const TOKENS_UPDATE:String = "tokens update";
		public static const TOKENS_TO_SHOW_UPDATE:String = "tokens to show update";
		public static const SUBLEVEL_UPDATE:String = "sublevel update";
		
		public var intValue:int;
		
		public function AvatarUpdateEvent(type:String,value:int = 0)
		{
			super(type);
			
			intValue = value;
		}
	}
}