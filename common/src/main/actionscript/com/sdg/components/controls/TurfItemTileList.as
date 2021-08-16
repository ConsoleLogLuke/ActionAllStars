package com.sdg.components.controls
{
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	public class TurfItemTileList extends ItemTileList
	{
		protected var _imageProxy:IUIComponent;
		
		public function TurfItemTileList()
		{
			super();
		}
		
		override protected function dragStartHandler(event:DragEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			
			var dragSource:DragSource = new DragSource();
			addDragData(dragSource);
			
			_imageProxy = dragImage;
			
			DragManager.doDrag(this, dragSource, event, _imageProxy, 0, 0, .5, dragMoveEnabled);
		}
		
		public function get proxyImage():IUIComponent
		{
			return _imageProxy;
		}
	}
}
