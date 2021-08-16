package com.sdg.core
{
	import flash.events.EventDispatcher;
	
	public class NullProgressInfo extends EventDispatcher implements IProgressInfo
	{
		public function get bytesLoaded():uint
		{
			return 1;
		}

		public function get bytesTotal():uint
		{
			return 1;
		}

		public function get complete():Boolean
		{
			return true;
		}

		public function get pending():Boolean
		{
			return false;
		}
	}
}