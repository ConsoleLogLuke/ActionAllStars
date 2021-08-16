package com.sdg.printshop.printitem
{
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.printshop.PrintShopEvent;
	import com.sdg.utils.BitmapUtil;
	import com.sdg.view.avatarcard.AvatarCardFront;
	import com.sdg.view.avatarcard.AvatarCardReferFriendBack;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class ReferAFriendPrintableItem extends Sprite implements IPrintItem
	{
		private const GRID_URL:String = Environment.getAssetUrl()+"/test/gameSwf/gameId/99/gameFile/printshop_foldable_grid.swf";
		
		private var previewReady:Boolean = false;
		private var pageReady:Boolean = false;
		private var printPreview:Sprite = new Sprite();
		private var previewBitmap:Bitmap;
		private var printPage:Sprite = new Sprite();
		private var printBitmap:Bitmap;
		private var av:Avatar = ModelLocator.getInstance().avatar;
		private var front1:AvatarCardFront;
		private var front2:AvatarCardFront;
		private var front3:AvatarCardFront;
		private var back1:AvatarCardReferFriendBack;
		private var back2:AvatarCardReferFriendBack;
		private var back3:AvatarCardReferFriendBack;
		private var grid:DisplayObject;
		
		private var f1Success:Boolean = false;
		private var f2Success:Boolean = false;
		private var f3Success:Boolean = false;
		private var b1Success:Boolean = false;
		private var b2Success:Boolean = false;
		private var b3Success:Boolean = false;
		private var gridSuccess:Boolean = false;
		private const printOffsetX:uint = 557;
		private const printOffsetY:uint = 59;
		private const margin:uint = 60;
		
		public function ReferAFriendPrintableItem()
		{
			front1 = new AvatarCardFront(av, 320, 450);
			front1.init();
			front1.addEventListener(Event.COMPLETE,onFront1Ready);
			front2 = new AvatarCardFront(av, 320, 450);
			front2.init();
			front2.addEventListener(Event.COMPLETE,onFront2Ready);
			front3 = new AvatarCardFront(av, 320, 450);
			front3.init();
			front3.addEventListener(Event.COMPLETE,onFront3Ready);
			back1 = new AvatarCardReferFriendBack(av, 320, 450);
			back1.addEventListener(Event.COMPLETE,onBack1Ready);
			back1.init();
			back2 = new AvatarCardReferFriendBack(av, 320, 450);
			back2.addEventListener(Event.COMPLETE,onBack2Ready);
			back2.init();
			back3 = new AvatarCardReferFriendBack(av, 320, 450);
			back3.addEventListener(Event.COMPLETE,onBack3Ready);
			back3.init();
			
			grid = new QuickLoader(GRID_URL, onGridLoaded);
		}
		
		protected function buildPrintObjects():void
		{
			var foldableCard:Sprite = new Sprite();
			
			foldableCard.addChild(front1);
			front1.x = 1;
			front1.y = 1;
			
			foldableCard.addChild(front2);
			front2.x = 321 + margin;
			front2.y = 1;
			
			foldableCard.addChild(front3);
			front3.x = 641 + margin + margin;
			front3.y = 1;
			
			foldableCard.addChild(back1);
			back1.x = 321;
			back1.y = 901;
			back1.rotation += 180;
			
			foldableCard.addChild(back2);
			back2.x = 641 + margin;
			back2.y = 901;
			back2.rotation += 180;
			
			foldableCard.addChild(back3);
			back3.x = 961 + margin + margin;
			back3.y = 901;
			back3.rotation += 180;
			
			var foldableMap:Bitmap = BitmapUtil.spriteToBitmap(foldableCard,true);
			
			foldableMap.scaleX *= .36;
			foldableMap.scaleY *= .36;
			
			this.printPreview.addChild(foldableMap);
			printPreview.rotation -= 3;
			dispatchEvent(new PrintShopEvent(PrintShopEvent.PREVIEW_COMPLETE));
			previewReady = true;
			
			foldableCard.addChild(grid);
			grid.x = 0;
			grid.y = 0;

			var foldablePrintMap:Bitmap = BitmapUtil.spriteToBitmap(foldableCard,true);
			
			foldablePrintMap.scaleX *= .6;
			foldablePrintMap.scaleY *= .6;
			
			printPage.graphics.beginFill(0xffffff,1);
			printPage.graphics.drawRect(0,0,612,792);
			
			foldablePrintMap.rotation += 90;
			printPage.addChild(foldablePrintMap);
			foldablePrintMap.x = printOffsetX;
			foldablePrintMap.y = printOffsetY;
			dispatchEvent(new PrintShopEvent(PrintShopEvent.PAGE_COMPLETE));
			pageReady =  true;
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
			return LoggingUtil.PRINT_SHOP_FOLDABLE_CARDS;
		}
		
		protected function successCheck():void
		{
			if (f1Success&&f2Success&&f3Success&&b1Success&&b2Success&&b3Success&&gridSuccess)
			{
				buildPrintObjects();
			}
		}
		
		//////////////////////////
		// EVENT LISTENER
		//////////////////////////
		
		protected function onFront1Ready(e:Event):void
		{
			f1Success = true;
			successCheck();
		}
		
		protected function onFront2Ready(e:Event):void
		{
			f2Success = true;
			successCheck();
		}
		
		protected function onFront3Ready(e:Event):void
		{
			f3Success = true;
			successCheck();
		}
		
		protected function onBack1Ready(e:Event):void
		{
			b1Success = true;
			successCheck();
		}

		protected function onBack2Ready(e:Event):void
		{
			b2Success = true;
			successCheck();
		}
		
		protected function onBack3Ready(e:Event):void
		{
			b3Success = true;
			successCheck();
		}
		
		protected function onGridLoaded():void
		{
			gridSuccess = true;
			successCheck();
		}
		
	}
}