package com.sdg.components.controls
{
	import flash.display.DisplayObject;
	
	import mx.controls.List;
	
	public class MessagesList extends List
	{
		public function MessagesList()
		{
			super();
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			super.addChildAt(child, 0);
			return child;
		}
	}
}