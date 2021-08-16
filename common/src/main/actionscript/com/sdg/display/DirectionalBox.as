package com.sdg.display
{
	import flash.display.DisplayObject;
	
	import mx.containers.Box;
	
	[Bindable]
	public class DirectionalBox extends Box
	{
		public var addChildInReverse:Boolean = false;
		
		public function DirectionalBox():void
		{
			super();
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (!addChildInReverse)
				super.addChild(child);
			else
				super.addChildAt(child, 0);
			
			return child;
		}
		
		public function get lastChildAdded():DisplayObject
		{
			var child:DisplayObject = null;
			if (numChildren > 0)
			{
				if (!addChildInReverse)
					child = getChildAt(numChildren - 1);
				else
					child = getChildAt(0);
			}
			return child;
		}
		
		public function get firstChildAdded():DisplayObject
		{
			var child:DisplayObject = null;
			if (numChildren > 0)
			{
				if (!addChildInReverse)
					child = getChildAt(0);
				else
					child = getChildAt(numChildren - 1);
			}
			return child;
		}
	}
}