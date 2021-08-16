package com.sdg.components.controls
{
	import com.sdg.components.renderers.CustomDropdownRenderer;
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.List;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.ClassFactory;
	import mx.events.MoveEvent;

	public class CustomDropdown extends List
	{
		public var parentDisplay:DisplayObject;
		
		public function CustomDropdown()
		{
			super();
			
			setStyle("borderStyle", "none");
			setStyle("selectionColor", 0x924059);
			setStyle("textSelectedColor", 0xffffff);
			setStyle("rollOverColor", 0x893c54);
			setStyle("textRollOverColor", 0xffffff);
			
			itemRenderer = new ClassFactory(CustomDropdownRenderer);
			
			addEventListener(MoveEvent.MOVE, onMove, false, 0, true);
			refreshPosition();
		}
		
		private function isItemEnabled(event:MouseEvent):Boolean
		{
			var item:IListItemRenderer = mouseEventToItemRenderer(event);
			
			// its enabled unless enabled is set to false
			if (item != null && item.data != null && item.data.enabled == false)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		override protected function mouseOverHandler(event:MouseEvent):void
		{
			// only do something if item is not disabled
			if (isItemEnabled(event))
			{
				super.mouseOverHandler(event);
			}
		}
		
		override protected function mouseDownHandler(event:MouseEvent):void
		{
			// only do something if item is not disabled
			if (isItemEnabled(event))
			{
				super.mouseDownHandler(event);
			}
		}
		
		override protected function mouseUpHandler(event:MouseEvent):void
		{
			// only do something if item is not disabled
			if (isItemEnabled(event))
			{
				super.mouseUpHandler(event);
			}
		}
		
		override protected function mouseClickHandler(event:MouseEvent):void
		{
			// only do something if item is not disabled
			if (isItemEnabled(event))
			{
				super.mouseClickHandler(event);
			}
		}
		
		override protected function mouseDoubleClickHandler(event:MouseEvent):void
		{
			// only do something if item is not disabled
			if (isItemEnabled(event))
			{
				super.mouseDoubleClickHandler(event);
			}
			else
			{
				event.preventDefault();
			}
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			event.stopPropagation();
		}        
		
		private function onMove(event:MoveEvent):void
		{
			refreshPosition();
		}
		
		private function refreshPosition():void
		{
			if (parentDisplay == null) return;
			
			var parentGlobalPoint:Point = parentDisplay.localToGlobal(new Point(0, 0));
			
			x = parentGlobalPoint.x + parentDisplay.width/2 - width/2;
		}
	}
}