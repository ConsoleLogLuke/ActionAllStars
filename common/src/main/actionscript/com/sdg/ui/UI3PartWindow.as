package com.sdg.ui
{
	import com.sdg.display.AlignType;
	import com.sdg.display.Container;
	import com.sdg.display.Stack;

	public class UI3PartWindow extends Container
	{
		protected var _mainStack:Stack;
		protected var _top:Container;
		protected var _middle:Container;
		protected var _bottom:Container;
		
		public function UI3PartWindow()
		{
			super();
			
			// Create the main stack.
			// The main stack will contain 3 vertically aligned containers: Top, Middle and Bottom.
			_mainStack = new Stack(AlignType.VERTICAL, 12);
			_mainStack.equalizeSize = true;
			
			// Create each of the 3 main containers and add them to the main stack.
			_top = new Container();
			_middle = new Container();
			_bottom = new Container();
			_top.alignX = AlignType.MIDDLE;
			_bottom.alignX = AlignType.MIDDLE;
			_bottom.alignY = AlignType.MIDDLE;
			_mainStack.addMultipleContainers([_top, _middle, _bottom]);
			
			// Set the content of this Container as the main stack.
			content = _mainStack;
		}
		
	}
}