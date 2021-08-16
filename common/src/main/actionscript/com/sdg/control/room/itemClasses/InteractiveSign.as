package com.sdg.control.room.itemClasses
{
	import com.sdg.business.resource.IRemoteResource;
	import com.sdg.components.dialog.InteractiveSignDialog;
	import com.sdg.display.RoomItemSWF;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.utils.MainUtil;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class InteractiveSign extends RoomItemController
	{
		private var _interactiveSignDisplay:MovieClip;
		private var _resource:IRemoteResource;
		
		public function InteractiveSign()
		{
			super();
		}
		
		protected function showSignDialog():void
		{
			MainUtil.showDialog(InteractiveSignDialog,{itemId:super.item.itemId,invId:this.item.id},false,false);
		}
		
		override protected function mouseClickHandler(event:MouseEvent):void
		{
			LoggingUtil.sendSignClickLogging(this.item.id);
			
			showSignDialog();
		}
		
		override protected function itemResourcesCompleteHandler(event:Event):void
		{
			super.itemResourcesCompleteHandler(event);
			RoomItemSWF(display).addEventListener(RoomItemDisplayEvent.CONTENT, loadCompleteHandler);
		}
		
		protected function loadCompleteHandler(event:Event):void
		{
			if (display == null) return;
			
			var swf:RoomItemSWF = RoomItemSWF(display);
			var temp:Object = Object(swf.content);
			_interactiveSignDisplay = temp as MovieClip;
			//_interactiveSignDisplay.addEventListener(MouseEvent.CLICK, showSignDialog);
		}
		
	}
}