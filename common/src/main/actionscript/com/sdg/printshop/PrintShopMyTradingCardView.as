package com.sdg.printshop
{
	import com.sdg.logging.LoggingUtil;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.printshop.printpreview.ExternalLinkContainer;
	import com.sdg.printshop.printpreview.PrintPreviewContainer;
	import com.sdg.ui.GoodCloseButton;
	import com.sdg.ui.RoundCornerCloseButton;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class PrintShopMyTradingCardView extends Sprite
	{
		private const BG_URL:String = Environment.getAssetUrl()+"/test/gameSwf/gameId/99/gameFile/printshop_background.swf";
		
		protected var _background:DisplayObject;
		protected var _closeButton:GoodCloseButton;
		protected var _baseballCards:PrintPreviewContainer;
		protected var _standups:ExternalLinkContainer;
		protected var _standups2:ExternalLinkContainer;
		protected var _poster:PrintPreviewContainer;
		
		public function PrintShopMyTradingCardView()
		{
			super();
			
			init();
		}
		
		public function init():void
		{
			_background = new QuickLoader(BG_URL, onBgLoaded, onBgError);
		}
		
		protected function initDisplayItems():void
		{
			_standups = new ExternalLinkContainer("http://printshop.s3.amazonaws.com/Egg_Wraps.pdf?AWSAccessKeyId=1RHPA6BFM8GC5X0V3C02&Expires=1662553100&Signature=LGVMsR9vN7xuOpH2xOFEI/DOgL4%3D",LoggingUtil.PRINT_SHOP_EASTER_2011,85,567);
			this.addChild(_standups);
			
			_standups2 = new ExternalLinkContainer("http://printshop.s3.amazonaws.com/NBA_All-Star_Stand-ups.pdf?AWSAccessKeyId=1RHPA6BFM8GC5X0V3C02&Expires=1927238612&Signature=BzBIJGMOGVrJss98S4RQSuVvoo8%3D",LoggingUtil.PRINT_SHOP_ALLSTAR_STANDUPS,354,567);
			this.addChild(_standups2);
			
			_poster = new PrintPreviewContainer(6043,15,372);
			this.addChild(_poster);
			_poster.x = 625;
			_poster.y = 195;
			
			_closeButton = new RoundCornerCloseButton("Close");
			_closeButton.addEventListener(MouseEvent.CLICK,onCloseClick);
			_closeButton.buttonMode = true;
			_closeButton.x = 867;
			_closeButton.y = 40;
			this.addChild(_closeButton);
		}
		
		////////////////////////
		// EVENT LISTENERS
		////////////////////////
		protected function onBgLoaded():void
		{
			_background.x = 0;
			_background.y = 0;
			this.addChild(_background);
			
			initDisplayItems();
		}
		
		protected function onBgError():void
		{
			dispatchEvent(new PrintShopEvent(PrintShopEvent.CLOSE_SHOP));
		}
		
		protected function onCloseClick(e:MouseEvent):void
		{
			_closeButton.removeEventListener(MouseEvent.CLICK,onCloseClick);
			
			dispatchEvent(new PrintShopEvent(PrintShopEvent.CLOSE_SHOP));
		}
		
	}
}