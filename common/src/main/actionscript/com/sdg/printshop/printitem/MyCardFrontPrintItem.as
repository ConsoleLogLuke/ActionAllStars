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
	
	public class MyCardFrontPrintItem extends Sprite implements IPrintItem
	{
		private var previewReady:Boolean = false;
		private var pageReady:Boolean = false;
		private var printPreview:Sprite = new Sprite();
		private var previewBitmap:Bitmap;
		private var printPage:Sprite = new Sprite();
		private var printBitmap:Bitmap;
		private var av:Avatar = ModelLocator.getInstance().avatar;
		private var card:AvatarCardFront;
		
		private const printOffsetX:uint = 12;
		private const printOffsetY:uint = 9;
		
		public function MyCardFrontPrintItem()
		{
			card = new AvatarCardFront(av, 320, 450);
			card.init();
			card.addEventListener(Event.COMPLETE,onCardReady);
		}

		protected function buildPrintObjects():void
		{
			var printBitmap:Bitmap = card.getScaledBitmap(1.7,true);
			
			printPage.graphics.beginFill(0xffffff,1);
			printPage.graphics.drawRect(0,0,600,840);
			
			printPage.addChild(printBitmap);
			printBitmap.x = printOffsetX;
			printBitmap.y = printOffsetY;
			
			dispatchEvent(new PrintShopEvent(PrintShopEvent.PAGE_COMPLETE));
			pageReady =  true;
			
			card.scaleX = 0.7;
			card.scaleY = 0.7;
			
			printPreview.addChild(card)
			
			printPreview.rotation += 2;
			
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
			return this.printOffsetY;
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