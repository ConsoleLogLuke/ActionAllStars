package com.sdg.utils {
	
	import flash.system.fscommand;

	public class FlashOut3
	{
		public static function trace(msg:Object):void
		{
			fscommand("trace", msg.toString());
		}
	}
}
