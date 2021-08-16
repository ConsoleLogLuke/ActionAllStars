package com.sdg.store.catalog
{
	import com.sdg.mvc.IView;
	import com.sdg.mvc.ViewBase;
	import com.sdg.net.QuickLoader;
	import com.sdg.store.util.StoreUtil;
	import com.sdg.store.StoreConstants;	
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class StoreCatalogStoreSelectView extends ViewBase implements IView
	{
		protected var _messageField:TextField;
		protected var _background:DisplayObject;
		protected var _mlbButton:Sprite;
		protected var _nbaButton:Sprite;
		protected var _aasButton:Sprite;
		protected var _vertButton:Sprite;
		
		public function StoreCatalogStoreSelectView(width:Number, height:Number)
		{
			super();
			init(width, height);
			
			// Create the message field.
			_messageField = new TextField();
			_messageField.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff);
			_messageField.autoSize = TextFieldAutoSize.LEFT;
			_messageField.text = 'Access one of our shops:';
			_messageField.embedFonts = true;
			addChild(_messageField);
			
			// Create store buttons.
			_mlbButton = new QuickLoader(StoreUtil.GetAssetPath() + 'mlb_logo.swf', render);
			_mlbButton.buttonMode = true;
			_mlbButton.addEventListener(MouseEvent.CLICK, onMlbClick);
			addChild(_mlbButton);
			_nbaButton = new QuickLoader(StoreUtil.GetAssetPath() + 'nba_logo.swf', render);
			_nbaButton.buttonMode = true;
			_nbaButton.addEventListener(MouseEvent.CLICK, onNbaClick);
			addChild(_nbaButton);
			_aasButton = new QuickLoader(StoreUtil.GetAssetPath() + 'aas_logo.swf', render);
			_aasButton.buttonMode = true;
			_aasButton.addEventListener(MouseEvent.CLICK, onAasClick);
			addChild(_aasButton);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override public function destroy():void
		{
			super.destroy();
			
			// Remove event listeners.
			_mlbButton.removeEventListener(MouseEvent.CLICK, onMlbClick);
			_nbaButton.removeEventListener(MouseEvent.CLICK, onNbaClick);
			_aasButton.removeEventListener(MouseEvent.CLICK, onAasClick);
		}
		
		override public function render():void
		{
			super.render();
			
			// Position the message field.
			_messageField.x = 20;
			_messageField.y = _height / 2 - _messageField.height / 2;
			
			// Determine area used for store buttons.
			var rectX:Number = _messageField.x + _messageField.width + 20;
			var btnMargin:Number = 5;
			var buttonArea:Rectangle = new Rectangle(rectX, 0, _width - rectX - 10, _height);
			var btnW:Number = (buttonArea.width - (btnMargin * 4)) / 3;
			var btnH:Number = buttonArea.height - btnMargin * 6;
			// Scale store buttons.
			scaleButton(_mlbButton);
			scaleButton(_nbaButton);
			scaleButton(_aasButton);
			// Position store buttons.
			_mlbButton.x = buttonArea.x + btnMargin + btnW / 2 - _mlbButton.width / 2;
			_mlbButton.y = buttonArea.height / 2 - _mlbButton.height / 2;
			_nbaButton.x = buttonArea.x + btnW + btnMargin + btnW / 2 - _nbaButton.width / 2;
			_nbaButton.y = buttonArea.height / 2 - _nbaButton.height / 2;
			_aasButton.x = buttonArea.x + (btnW + btnMargin) * 2 + btnW / 2 - _aasButton.width / 2;
			_aasButton.y = buttonArea.height / 2 - _aasButton.height / 2;
			
			
			// Scale the backgorund.
			if (_background != null)
			{
				_background.width = _width;
				_background.height = _height;
			}
			
			function scaleButton(btn:Sprite):void
			{
				var btnScale:Number = Math.min(btnW / btn.width, btnH / btn.height);
				btn.width *= btnScale;
				btn.height *= btnScale;
			}
		}
		
		protected function createDeafultStoreButton():Sprite
		{
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0xffffff);
			s.graphics.drawRect(0, 0, 40, 40);
			s.graphics.endFill();
			return s;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set background(value:DisplayObject):void
		{
			// Remove previous.
			if (_background != null)
			{
				removeChild(_background);
			}
			
			// Set new one.
			_background = value;
			addChildAt(_background, 0);
			
			render();
		}
		
		public function set mlbButton(value:Sprite):void
		{
			// Remove previous.
			if (_mlbButton != null)
			{
				removeChild(_mlbButton);
			}
			
			// Set new one.
			_mlbButton = value;
			addChild(_mlbButton);
			
			render();
		}
		
		public function set nbaButton(value:Sprite):void
		{
			// Remove previous.
			if (_nbaButton != null)
			{
				removeChild(_nbaButton);
			}
			
			// Set new one.
			_nbaButton = value;
			addChild(_nbaButton);
			
			render();
		}
		
		public function set aasButton(value:Sprite):void
		{
			// Remove previous.
			if (_aasButton != null)
			{
				removeChild(_aasButton);
			}
			
			// Set new one.
			_aasButton = value;
			addChild(_aasButton);
			
			render();
		}
		
		public function set vertButton(value:Sprite):void
		{
			// Remove previous.
			if (_vertButton != null)
			{
				removeChild(_vertButton);
			}
			
			// Set new one.
			_vertButton = value;
			addChild(_vertButton);
			
			render();
		}
		
		//////////////////////
		// EVENT HANDLERS
		//////////////////////
		
		protected function onMlbClick(e:MouseEvent):void
		{
			dispatchEvent(new StoreCatalogStoreSelectEvent(StoreCatalogStoreSelectEvent.STORE_SELECT, StoreConstants.STORE_ID_MLB));
		}
		
		protected function onNbaClick(e:MouseEvent):void
		{
			dispatchEvent(new StoreCatalogStoreSelectEvent(StoreCatalogStoreSelectEvent.STORE_SELECT, StoreConstants.STORE_ID_NBA));
		}
		
		protected function onAasClick(e:MouseEvent):void
		{
			dispatchEvent(new StoreCatalogStoreSelectEvent(StoreCatalogStoreSelectEvent.STORE_SELECT, StoreConstants.STORE_ID_RIVERWALK));
		}
		
	}
}