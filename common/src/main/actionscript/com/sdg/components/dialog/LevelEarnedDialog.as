package com.sdg.components.dialog
{
	import com.sdg.components.controls.store.StoreNavBar;
	import com.sdg.display.LineStyle;
	import com.sdg.graphics.GradientStyle;
	import com.sdg.graphics.RoundRectStyle;
	import com.sdg.manager.LevelManager;
	import com.sdg.model.LevelMessage;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;

	public class LevelEarnedDialog extends Canvas implements ISdgDialog
	{
		public static const GRID_BACKGROUND:String = "/test/gameSwf/gameId/71/gameFile/popUp_gridTexture.swf";
		
		protected var _manager:LevelManager;
		
		private var _loader:Loader;
		
		private var _level:int;
		
		private var _rawMsgText:LevelMessage;
		
		// Main Components
		private var _image:DisplayObject;
		private var _background:Sprite;
		private var _gridBackground:DisplayObject;
		private var _border:Sprite;
		private var _topLineText:TextField;
		private var _levelAnnouncement1:TextField;
		private var _levelAnnouncement2:TextField;
		private var _unlockText:TextField;
		private var _itemDescription:TextField;
		private var _continueButton:StoreNavBar;
		private var _blakeIcon:Sprite;
		
		
		public function LevelEarnedDialog()
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
			buildButton(230,432,156,"CONTINUE","CLOSING...","onCloseButtonClick");
			
			//Header Text
			_topLineText = new TextField();
			this.rawChildren.addChild(_topLineText);
			_topLineText.embedFonts = true;
			_topLineText.defaultTextFormat = new TextFormat('EuroStyle', 25, 0xffffff, true);
			_topLineText.autoSize = TextFieldAutoSize.CENTER;
			_topLineText.selectable = false;
			_topLineText.text = "Good Job" 
			_topLineText.x = 73;
			_topLineText.y = 13;
			_topLineText.width = 470;
			
			_levelAnnouncement1 = new TextField();
			this.rawChildren.addChild(_levelAnnouncement1);
			_levelAnnouncement1.embedFonts = true;
			_levelAnnouncement1.defaultTextFormat = new TextFormat('EuroStyle', 20, 0xffffff, true);
			_levelAnnouncement1.autoSize = TextFieldAutoSize.CENTER;
			_levelAnnouncement1.selectable = false;
			_levelAnnouncement1.text = "You Are Now A New Level";
			_levelAnnouncement1.x = 73;
			_levelAnnouncement1.y = 50;
			_levelAnnouncement1.width = 470;
			
			_levelAnnouncement2 = new TextField();
			this.rawChildren.addChild(_levelAnnouncement2);
			_levelAnnouncement2.embedFonts = true;
			_levelAnnouncement2.defaultTextFormat = new TextFormat('EuroStyle', 20, 0xffffff, true);
			_levelAnnouncement2.autoSize = TextFieldAutoSize.CENTER;
			_levelAnnouncement2.selectable = false;
			_levelAnnouncement2.text = "";
			_levelAnnouncement2.x = 73;
			_levelAnnouncement2.y = 75;
			_levelAnnouncement2.width = 470;
			
			_unlockText = new TextField();
			this.rawChildren.addChild(_unlockText);
			_unlockText.embedFonts = true;
			_unlockText.defaultTextFormat = new TextFormat('EuroStyle', 15, 0xffffff, true);
			_unlockText.autoSize = TextFieldAutoSize.CENTER;
			_unlockText.selectable = false;
			_unlockText.text = "You've Unlocked:" 
			_unlockText.x = 73;
			_unlockText.y = 349;
			_unlockText.width = 470;
			
			_itemDescription = new TextField();
			this.rawChildren.addChild(_itemDescription);
			_itemDescription.embedFonts = true;
			_itemDescription.defaultTextFormat = new TextFormat('EuroStyle', 15, 0xffffff, true);
			_itemDescription.autoSize = TextFieldAutoSize.CENTER;
			_itemDescription.selectable = false;
			_itemDescription.text = "New Items" 
			_itemDescription.x = 73;
			_itemDescription.y = 371;
			_itemDescription.width = 470;
			
			// Placeholder objects added
			_gridBackground = new Sprite();
			_image = new Sprite();
			rawChildren.addChild(_gridBackground);
			rawChildren.addChild(_image);
			
			_blakeIcon = new QuickLoader(Environment.getAssetUrl()+'/test/gameSwf/gameId/99/gameFile/blake-circle-01.png', onBlakeIconLoadComplete,null,3);
		}
		
		public function init(params:Object):void
		{
			_level =  params.level as int;
			_rawMsgText = params.msg as LevelMessage;
			_image = params.image as DisplayObject;
			_gridBackground = params.grid as DisplayObject;
			
			populateDialogText();
			positionGridImage();
			positionItemImage();
		}
		
//		private function organizeChildren():void
//		{
//			this.rawChildren.setChildIndex(_border,0);
//			this.rawChildren.setChildIndex(_background,1);
//			this.rawChildren.setChildIndex(_gridBackground,2);
//			this.rawChildren.setChildIndex(_continueButton,3);
//			this.rawChildren.setChildIndex(_image,4);
//			this.rawChildren.setChildIndex(_topLineText,5);
//			this.rawChildren.setChildIndex(_levelAnnouncement,6);
//			this.rawChildren.setChildIndex(_unlockText,7);
//			this.rawChildren.setChildIndex(_itemDescription,8);
//		}
		
		private function populateDialogText():void
		{
			_topLineText.text = _rawMsgText.init;
			_levelAnnouncement1.text = _rawMsgText.lev1;
			_levelAnnouncement2.text = _rawMsgText.lev2;
			_unlockText.text = _rawMsgText.unlck1;
			_itemDescription.text = _rawMsgText.unlck2;
		}
		
		private function positionGridImage():void
		{
				_gridBackground.x = 65;
				_gridBackground.y = 105;
				rawChildren.addChild(_gridBackground);
				_gridBackground.alpha = .5;
		}
		
		// Done Last, so re-organize child objects
		private function positionItemImage():void
		{
			_image.x = 115;
			_image.y = 135;
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
		
		private function onBlakeIconLoadComplete():void
		{
			this.rawChildren.addChild(_blakeIcon);
			_blakeIcon.x = -60;
			_blakeIcon.y = -60;
			//_blakeIcon.scaleX = 1;
			//_blakeIcon.scaleY = 1;
		}
		
//		private function onGridLoaded(e:Event):void
//		{
//			e.currentTarget.removeEventListener(Event.COMPLETE, onGridLoaded);
//			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onGridIOError);
//			
//			try
//			{
//				_gridBackground = DisplayObject(e.currentTarget.content);
//
//				_gridBackground.x = 70;
//				_gridBackground.y = 100;
//				rawChildren.addChild(_gridBackground);
//				_gridBackground.alpha = .5;
//				
//				//organizeChildren();
//			}
//			catch(e:Error)
//			{
//				trace("Badge Earned Dialog error: " + e.message);
//			}
//		}
//		
//		private function onGridIOError(ioe:IOErrorEvent):void
//		{
//			ioe.currentTarget.removeEventListener(Event.COMPLETE, onGridLoaded);
//			ioe.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onGridIOError);
//			
//			trace("LevelEarnedDialog.onIOError: "+ioe);
//		}
		
//		private function onImageIOError(ioe:IOErrorEvent):void
//		{
//			ioe.currentTarget.removeEventListener(Event.COMPLETE, onImageLoaded);
//			ioe.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
//			
//			trace("LevelEarnedDialog.onIOError: "+ioe);
//		}
		
		public function onCloseClick(e:Event):void
		{
			this.close();
		}
		
	}
}