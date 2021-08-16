package com.sdg.model.button
{
	import flash.display.Sprite;
	
	public class ButtonDefinition extends Object
	{
		public var display:Sprite;
		public var clickEvent:String;
		public var label:String;
		public var children:Array;
		public var eventParams:Object;
		
		public function ButtonDefinition(display:Sprite, clickEvent:String, label:String, children:Array, eventParams:Object)
		{
			super();
			
			this.display = display;
			this.clickEvent = clickEvent;
			this.label = label;
			this.children = children;
			this.eventParams = eventParams;
		}
		
	}
}