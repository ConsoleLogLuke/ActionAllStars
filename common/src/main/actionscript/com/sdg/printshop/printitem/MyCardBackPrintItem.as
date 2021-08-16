package com.sdg.printshop.printitem
{
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.printshop.PrintShopEvent;
	import com.sdg.view.avatarcard.*;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class MyCardBackPrintItem extends Sprite implements IPrintItem
	{
		public var previewReady:Boolean = false;
		public var pageReady:Boolean = false;
		public var printPreview:Sprite = new Sprite();
		public var previewBitmap:Bitmap;
		public var printPage:Sprite = new Sprite();
		public var printBitmap:Bitmap;
		private var av:Avatar = ModelLocator.getInstance().avatar;
		private var card:AvatarCardBack;
		
		private const printOffsetX:uint = 0;
		private const printOffsetY:uint = 0;
		
		public function MyCardBackPrintItem()
		{
			card = new AvatarCardBack(av, 320, 450);
			card.init();
			card.addEventListener(Event.COMPLETE,onCardReady);
		}

		protected function buildPrintObjects():void
		{
			var printBitmap:Bitmap = card.getScaledBitmap(1.7,false);
			printPage.addChild(printBitmap);
			
			dispatchEvent(new PrintShopEvent(PrintShopEvent.PAGE_COMPLETE));
			pageReady =  true;
			
			card.scaleX = 0.7;
			card.scaleY = 0.7;
			
			printPreview.addChild(card)
			
			dispatchEvent(new PrintShopEvent(PrintShopEvent.PREVIEW_COMPLETE));
			previewReady = true;
		}

		public function getPrintPreview():Sprite
		{
			return this.printPreview;
		}
		
		public function getPrintPage():Sprite
		{
			return this.printPage;
		}
		
		public function getPrintOffsetX():uint
		{
			return this.printOffsetX;
		}
		
		public function getPrintOffsetY():uint
		{
			return this.printOffsetY
		}
		
		public function getLoggingId():int
		{
			return LoggingUtil.PRINT_SHOP_MY_CARD_FRONT;
		}
		
		////////////////////////////
		// EVENT LISTENERS
		////////////////////////////
		
		protected function onCardReady(e:Event):void
		{
			card.removeEventListener(Event.COMPLETE,onCardReady);
			
			buildPrintObjects();
		}

	}
}