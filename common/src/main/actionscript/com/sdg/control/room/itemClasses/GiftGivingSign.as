package com.sdg.control.room.itemClasses
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.resource.IRemoteResource;
	import com.sdg.components.dialog.InteractiveSignDialog;
	import com.sdg.display.RoomItemSWF;
	import com.sdg.events.ItemPurchaseEvent;
	import com.sdg.events.RoomCheckEvent;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.StoreCategory;
	import com.sdg.model.StoreItem;
	import com.sdg.store.StoreConstants;
	import com.sdg.store.transaction.FreeItemAtom;
	import com.sdg.utils.MainUtil;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class GiftGivingSign extends RoomItemController
	{
		private var _giftGivingSignDisplay:MovieClip;
		private var _resource:IRemoteResource;
		public static const idGiftMapping:Object = {683:6611,
													684:6613};
													
		public static const idGiftCheckMapping:Object = {683:6611,
													684:6613};	
													
		public static const idSecondGiftMapping:Object = {683:0,
													684:0};

		public function GiftGivingSign()
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
			
			var gift:FreeItemAtom = new FreeItemAtom(getGiftItem(this.item.id),getGiftItemCheck(this.item.id),true);
			
			if (getSecondaryGiftItem(this.item.id) > 0)
        	{
        		var gift2:FreeItemAtom = new FreeItemAtom(getSecondaryGiftItem(this.item.id),getSecondaryGiftItem(this.item.id),true);
        	}
			
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
			_giftGivingSignDisplay = temp as MovieClip;
		}
        
        private function getGiftItem(invId:int):int
        {
        	return idGiftMapping[invId];
        }
        
        // returns 0 if no item
        private function getSecondaryGiftItem(invId:int):int
        {
        	return idSecondGiftMapping[invId];
        }
        
        private function getGiftItemCheck(invId:int):int
        {
        	return idGiftCheckMapping[invId];
        }
	}
}