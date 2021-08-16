package com.sdg.ui
{
	import com.sdg.buttonstyle.AASButtonStyles;
	import com.sdg.controls.AASDialogButton;
	import com.sdg.display.AlignType;
	import com.sdg.display.Container;
	import com.sdg.display.PrizeOfTheWeekStamps;
	import com.sdg.display.Stack;
	import com.sdg.font.FontStyles;
	import com.sdg.model.ModelLocator;
	import com.sdg.utils.MainUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class UITriviaStamps extends UITriviaAlert
	{
		private const NO_NEW_STAMP:String = 'You already received a stamp today.\nPlay again tomorrow for more stamps!';
		private const ALREADY_WON_PRIZE:String = 'You already won this Grand Prize.';
		private var _stampLimit:int;
		private var _stampCount:int;
		private var _remainingStamps:int;
		private var _copy:String;
		private var _prizeOfTheWeek:PrizeOfTheWeekStamps;
		//private var _userIsPremium:Boolean;
		private var _drawLayer:Sprite;
		private var _upsellContainer:Container;
		private var _prizeThumbnailURL:String;
		
		//public function UITriviaStamps(stampCount:int = 0, newStamp:Boolean = false, userIsPremium:Boolean = true, prizeThumbnailURL:String = '')
		public function UITriviaStamps(stampCount:int = 0, newStamp:Boolean = false, prizeThumbnailURL:String = '')
		{
			super();
			
			// Set initial values.
			_stampLimit = 7;
			_stampCount = stampCount;
			_remainingStamps = _stampLimit - _stampCount;
			//_userIsPremium = userIsPremium;
			_prizeThumbnailURL = prizeThumbnailURL;
			if (newStamp != true)
			{
				_copy = (_remainingStamps > 0) ? NO_NEW_STAMP : ALREADY_WON_PRIZE;
			}
			else
			{
				var moreStamps:String = (_remainingStamps > 1) ? _remainingStamps + ' stamps' : '1 stamp';
				_copy = (_remainingStamps > 0) ? 'Congratulations!\nYou received your Trivia stamp for the day.\nYou are only ' + moreStamps + ' away from the grand prize!' : 'Congratulations!\nYou won the Grand Prize!';
			}
			
			//if (_userIsPremium != true && _stampCount > 6) _copy = '';
			
			// Main content.
			var container:Container;
			var mainContent:Container = new Container();
			mainContent.paddingLeft = mainContent.paddingRight = 10;
			_middle.content = mainContent;
			
			var middleStack:Stack = new Stack(AlignType.VERTICAL, 10);
			middleStack.equalizeSize = true;
			mainContent.content = middleStack;
			
			var text:TextField = new TextField();
			text.autoSize = TextFieldAutoSize.CENTER;
			text.defaultTextFormat = new TextFormat('GillSans', 24, 0x1a3968, true, null, null, null, null, TextFormatAlign.CENTER);
			text.styleSheet = FontStyles.GILL_SANS;
			text.embedFonts = true;
			text.text = _copy;
			container = new Container();
			container.alignX = AlignType.MIDDLE;
			container.content = text;
			middleStack.addContainer(container);
			
			_prizeOfTheWeek = new PrizeOfTheWeekStamps(580, 220, _stampCount, newStamp, _prizeThumbnailURL);
			//if (_userIsPremium != true) _prizeOfTheWeek.transform.colorTransform = new ColorTransform(0.5, 0.5, 0.5, 1, 200, 200, 200);
			middleStack.addContainer(_prizeOfTheWeek);
			
			_render();
			
//			if (_userIsPremium != true && _stampCount > 6)
//			{
//				_drawLayer = new Sprite();
//				var alpha:Number = 0.8;
//				var stampBoxArea:Rectangle = _prizeOfTheWeek.getRect(this);
//				_addChild(_drawLayer);
//				_drawLayer.graphics.beginFill(0xffffff, alpha);
//				_drawLayer.graphics.lineStyle(6, 0xffffff, 1);
//				_drawLayer.graphics.drawRoundRect(stampBoxArea.x, stampBoxArea.y, stampBoxArea.width, stampBoxArea.height, 18, 18);
//				
//				_upsellContainer = new Container(stampBoxArea.width, stampBoxArea.height, false);
//				_upsellContainer.x = stampBoxArea.x;
//				_upsellContainer.y = stampBoxArea.y;
//				_upsellContainer.alignX = _upsellContainer.alignY = AlignType.MIDDLE;
//				_addChild(_upsellContainer);
//				
//				var upsellText:TextField = new TextField();
//				var format:TextFormat = text.defaultTextFormat;
//				format.bold = false;
//				upsellText.autoSize = TextFieldAutoSize.CENTER;
//				upsellText.defaultTextFormat = format;
//				upsellText.styleSheet = FontStyles.GILL_SANS;
//				upsellText.filters = [new GlowFilter(0xffffff)];
//				upsellText.embedFonts = true;
//				upsellText.htmlText = 'Sorry!\nYou need to upgrade to a\n<b>Premium Membership</b>\nto win the Grand Prize!';
//				_upsellContainer.content = upsellText;
//				
//				// Create new buttons for upsell.
//				var btnStack:Stack = new Stack(AlignType.HORIZONTAL, 40);
//				var upsellBtn:AASDialogButton = new AASDialogButton('Go Premium', 140, 40, AASButtonStyles.BLUE_BUTTON);
//				upsellBtn.label.embedFonts = true;
//				upsellBtn.addEventListener(MouseEvent.CLICK, _onUpsellClick);
//				btnStack.addContainer(upsellBtn);
//				var okBtn:AASDialogButton = new AASDialogButton('No Thanks');
//				okBtn.label.embedFonts = true;
//				okBtn.addEventListener(MouseEvent.CLICK, _okClick);
//				btnStack.addContainer(okBtn);
//				_bottom.content = btnStack;
//			}
		}
		
		public function animate():void
		{
			_prizeOfTheWeek.animate();
		}
		
//		private function _onUpsellClick(e:MouseEvent):void
//		{
//			// Send to premium mebership page.
//			//MainUtil.postAvatarIdToURL('membership.jsp', ModelLocator.getInstance().avatar.id);
//			MainUtil.navigateToMonthFreePage();
//		}
		
	}
}