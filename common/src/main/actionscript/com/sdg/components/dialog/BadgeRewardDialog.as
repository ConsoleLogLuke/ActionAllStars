package com.sdg.components.dialog
{
	import com.sdg.components.controls.store.StoreNavBar;
	import com.sdg.display.LineStyle;
	import com.sdg.graphics.GradientStyle;
	import com.sdg.graphics.RoundRectStyle;
	import com.sdg.manager.LevelManager;
	import com.sdg.model.BadgeRewardMessage;
	import com.sdg.net.Environment;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;

	public class BadgeRewardDialog extends Canvas implements ISdgDialog
	{
		protected var _manager:LevelManager;
		
		private var _loader:Loader;
		
		private var _level:int;
		
		private var _rawMsgText:BadgeRewardMessage;
		
		// Main Components
		private var _image:DisplayObject;
		private var _background:Sprite;
		private var _gridBackground:DisplayObject;
		private var _border:Sprite;
		private var _topLineText:TextField;
		private var _levelAnnouncement:TextField;
		private var _unlockText:TextField;
		private var _itemDescription1:TextField;
		private var _itemDescription2:TextField;
		private var _continueButton:StoreNavBar;
		
		public function BadgeRewardDialog()
		{
			super();
			
			this.x = 50;
			this.y = 50;
			this.width = 620;
			this.height = 500;
			
			// Set Border
			_border = new Sprite();
			this.rawChildren.addChild(_border);
			
			var gradientBoxMatrix:Matrix = new Matrix();

			gradientBoxMatrix.createGradientBox(620, 500, Math.PI/2);
			_border.graphics.beginGradientFill(GradientType.LINEAR, [0x666666, 0xffffff, 0x666666], [1, 1, 1], [0, 128, 255], gradientBoxMatrix);
			_border.graphics.drawRect(0, 0, 620, 500);
			_border.graphics.endFill();
			
			// Set Background
			_background = new Sprite();
			this.rawChildren.addChild(_background);
			
			gradientBoxMatrix.createGradientBox(width-16, height-16, Math.PI/2);
			_background.graphics.beginGradientFill(GradientType.LINEAR, [0x063040, 0x0e526c], [1, 1], [0, 255], gradientBoxMatrix);
			
			_background.graphics.drawRect(0, 0, width-16, height-16);
			_background.graphics.endFill();
			_background.x = _border.width/2 - _background.width/2;
			_background.y = _border.height/2 - _background.height/2;
			_background.filters = [new GlowFilter(0x222222, 1, 11, 11, 2, 1, true)];
			
			// Place Buttons
			//buildButton(80,425,235,"TELL YOUR FRIENDS","TELL YOUR FRIENDS","onMessageButtonClick");
			buildButton(235,430,156,"CONTINUE","CLOSING...","onCloseButtonClick");
			
			//Header Text
			_topLineText = new TextField();
			this.rawChildren.addChild(_topLineText);
			_topLineText.embedFonts = true;
			_topLineText.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xffffff, true);
			_topLineText.autoSize = TextFieldAutoSize.CENTER;
			_topLineText.selectable = false;
			_topLineText.text = "Good Job" 
			_topLineText.x = 75;
			_topLineText.y = 15;
			_topLineText.width = 470;
			
			_levelAnnouncement = new TextField();
			this.rawChildren.addChild(_levelAnnouncement);
			_levelAnnouncement.embedFonts = true;
			_levelAnnouncement.defaultTextFormat = new TextFormat('EuroStyle', 20, 0xffffff, false);
			_levelAnnouncement.autoSize = TextFieldAutoSize.CENTER;
			_levelAnnouncement.selectable = false;
			_levelAnnouncement.text = "You Are Now A New Level";
			_levelAnnouncement.x = 75;
			_levelAnnouncement.y = 55;
			_levelAnnouncement.width = 470;
			
//			_unlockText = new TextField();
//			this.rawChildren.addChild(_unlockText);
//			_unlockText.embedFonts = true;
//			_unlockText.defaultTextFormat = new TextFormat('EuroStyle', 15, 0xffffff, true);
//			_unlockText.autoSize = TextFieldAutoSize.CENTER;
//			_unlockText.selectable = false;
//			_unlockText.text = "You've Unlocked:" 
//			_unlockText.x = 150;
//			_unlockText.y = 333;
//			_unlockText.width = 300;
			
			_itemDescription1 = new TextField();
			this.rawChildren.addChild(_itemDescription1);
			_itemDescription1.embedFonts = true;
			_itemDescription1.defaultTextFormat = new TextFormat('EuroStyle', 15, 0xffffff, true);
			_itemDescription1.autoSize = TextFieldAutoSize.CENTER;
			_itemDescription1.selectable = false;
			_itemDescription1.text = "New Items" 
			_itemDescription1.x = 158;
			_itemDescription1.y = 343;
			_itemDescription1.width = 300;
			
			_itemDescription2 = new TextField();
			this.rawChildren.addChild(_itemDescription2);
			_itemDescription2.embedFonts = true;
			_itemDescription2.defaultTextFormat = new TextFormat('EuroStyle', 15, 0xffffff, true);
			_itemDescription2.autoSize = TextFieldAutoSize.CENTER;
			_itemDescription2.selectable = false;
			_itemDescription2.text = "New Items" 
			_itemDescription2.x = 158;
			_itemDescription2.y = 363;
			_itemDescription2.width = 300;
			
			// Placeholder objects added
			_gridBackground = new Sprite();
			_image = new Sprite();
			rawChildren.addChild(_gridBackground);
			rawChildren.addChild(_image);
		}
		
		public function init(params:Object):void
		{
			_level =  params.level as int;
			_rawMsgText = params.msg as BadgeRewardMessage;
			_image = params.image as DisplayObject;
			_gridBackground = params.grid as DisplayObject;
			
			populateDialogText();
			positionGridImage();
			positionItemImage();
		}
		
		private function populateDialogText():void
		{
			_topLineText.text = _rawMsgText.init;
			_levelAnnouncement.text = _rawMsgText.lev1;
			_itemDescription1.text = _rawMsgText.item1;
			_itemDescription2.text = _rawMsgText.item2;
		}
		
		private function positionGridImage():void
		{
				_gridBackground.x = 70;
				_gridBackground.y = 100;
				rawChildren.addChild(_gridBackground);
				_gridBackground.alpha = .5;
		}
		
		// Done Last, so re-organize child objects
		private function positionItemImage():void
		{
			_image.x = 118;
			_image.y = 130;
			rawChildren.addChild(_image);
		}
		
		private function buildButton(x:int,y:int,width:uint,initialText:String,onClickText:String,callable:String):void
		{
			var button:StoreNavBar = new StoreNavBar(width, 30, initialText);
			button.roundRectStyle = new RoundRectStyle(15, 15);
			button.labelFormat = new TextFormat('EuroStyle', 20, 0x9D330B, true);
			button.buttonMode = true;
			if (callable == "onCloseButtonClick")
			{
				button.addEventListener(MouseEvent.CLICK, onCloseButtonClick);
			}
			button.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			button.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			this.rawChildren.addChild(button);
			
			button.labelX = button.width/2 - button.labelWidth/2;

			setDefaultButton(button);
				
			button.x = x;
			button.y = y;
			
			function onButtonMouseOver(event:MouseEvent):void
			{
				setMouseOverButton(event.currentTarget);
			}
				
			function onButtonMouseOut(event:MouseEvent):void
			{
				setDefaultButton(event.currentTarget);
			}
				
			function onCloseButtonClick(event:MouseEvent):void
			{
				// Remove Listeners
				button.removeEventListener(MouseEvent.CLICK, onCloseButtonClick);
				button.removeEventListener(MouseEvent.MOUSE_OVER,onButtonMouseOver);
				button.removeEventListener(MouseEvent.MOUSE_OUT,onButtonMouseOut);
					
				// Set New Appearance
				setMouseOverButton(event.currentTarget);
					
				// Change Text
				button.label = onClickText;
				
				onCloseClick(event);
			}
			
			function setDefaultButton(button:StoreNavBar):void
			{
				button.labelColor = 0x9D330B;
				button.borderStyle = new LineStyle(0x913300, 1, 1);
				
				var gradientBoxMatrix:Matrix = new Matrix();
				gradientBoxMatrix.createGradientBox(button.width, button.height, Math.PI/2, 0, 0);
				button.gradient = new GradientStyle(GradientType.LINEAR, [0xF7D85B, 0xD88616], [1, 1], [0, 255], gradientBoxMatrix);
			}
			
			function setMouseOverButton(button:StoreNavBar):void
			{
				button.labelColor = 0xffcc33;
				button.borderStyle = new LineStyle(0xff9900, 1, 1);
				
				var gradientBoxMatrix:Matrix = new Matrix();
				gradientBoxMatrix.createGradientBox(button.width, button.height, Math.PI/2, 0, 0);
				button.gradient = new GradientStyle(GradientType.LINEAR, [0xd18500, 0xa54c0a], [1, 1], [0, 255], gradientBoxMatrix);
			}
		}
		
		public function close():void
		{
			PopUpManager.removePopUp(this);
		}
		
		///////////////////////
		// Listeners
		///////////////////////
		
		private function onGridLoaded(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, onGridLoaded);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onGridIOError);
			
			try
			{
				_gridBackground = DisplayObject(e.currentTarget.content);

				_gridBackground.x = 70;
				_gridBackground.y = 100;
				rawChildren.addChild(_gridBackground);
				_gridBackground.alpha = .5;
			}
			catch(e:Error)
			{
				trace("Badge Earned Dialog error: " + e.message);
			}
		}
		
		private function onGridIOError(ioe:IOErrorEvent):void
		{
			ioe.currentTarget.removeEventListener(Event.COMPLETE, onGridLoaded);
			ioe.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onGridIOError);
			
			trace("LevelEarnedDialog.onIOError: "+ioe);
		}
		
		private function onImageLoaded(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, onImageLoaded);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
			
			try
			{
				_image = DisplayObject(e.currentTarget.content);

				_image.x = 105;
				_image.y = 130;
				rawChildren.addChild(_image);
			}
			catch(e:Error)
			{
				trace("Level Image Error: "+e);
			}
		}
		
		private function onImageIOError(ioe:IOErrorEvent):void
		{
			ioe.currentTarget.removeEventListener(Event.COMPLETE, onImageLoaded);
			ioe.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
			
			trace("LevelEarnedDialog.onIOError: "+ioe);
		}
		
		public function onCloseClick(e:Event):void
		{
			this.close();
		}
		
	}
}