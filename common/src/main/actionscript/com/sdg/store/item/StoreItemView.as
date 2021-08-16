package com.sdg.store.item
{
	import com.sdg.mvc.ViewBase;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class StoreItemView extends ViewBase implements IStoreItemView
	{
		private static const _STROKE:GlowFilter = new GlowFilter(0, 1, 4, 4, 10);
		
		protected var _thumbnail:DisplayObject;
		protected var _numTokensTF:TextField;
		protected var _buyButton:DisplayObject;
		protected var _thumbContainer:Sprite;
		protected var _ownedBanner:Sprite;
		protected var _ownedTextField:TextField;
		protected var _tokenContainer:Sprite;
		protected var _tokenIcon:Sprite;
		
		protected var _itemName:String;
		protected var _levelRequirement:int;
		protected var _isLocked:Boolean;
		protected var _itemTypeId:uint;
		protected var _itemId:uint;
		protected var _purchasedAmount:uint;
		protected var _listOrderId:uint;
		protected var _homeTurfValue:uint;
		
		private var _isAffordable:Boolean;
		
		public function StoreItemView()
		{
			super();
			
			// Defaults.
			_purchasedAmount = 0;
			_listOrderId = 0;
			_isAffordable = true;
			
			// Text format to be used.
			var tokenPriceColor:uint = (_isAffordable) ? 0xffffff : 0xfe8d8d;
			var tf:TextFormat = new TextFormat('EuroStyle', 12, tokenPriceColor, true);
			
			// Create thumbnail container.
			_thumbContainer = new Sprite();
			_thumbContainer.doubleClickEnabled = true;
			_thumbContainer.addEventListener(MouseEvent.CLICK, onThumbnailClick);
			_thumbContainer.addEventListener(MouseEvent.DOUBLE_CLICK, onThumbnailDoubleClick);
			_thumbContainer.addEventListener(MouseEvent.ROLL_OVER, onThumbnailRollOver);
			_thumbContainer.addEventListener(MouseEvent.ROLL_OUT, onThumbnailRollOut);
			addChild(_thumbContainer);
			
			// Token container.
			_tokenContainer = new Sprite();
			addChild(_tokenContainer);
			
			// Token icon.
			_tokenIcon = new ShopToken();
			var tokenSize:Number = 20;
			var tokenScale:Number = Math.min(tokenSize / _tokenIcon.width, tokenSize / _tokenIcon.height);
			_tokenIcon.width *= tokenScale;
			_tokenIcon.height *= tokenScale;
			_tokenContainer.addChild(_tokenIcon);
			
			// Number of tokens text field.
			_numTokensTF = new TextField();
			_numTokensTF.embedFonts = true;
			_numTokensTF.defaultTextFormat = tf;
			_numTokensTF.autoSize = TextFieldAutoSize.LEFT;
			_numTokensTF.text = '0';
			_numTokensTF.selectable = false;
			_numTokensTF.filters = [_STROKE];
			_tokenContainer.addChild(_numTokensTF);
			
			// Buy button.
			_buyButton = getNewBuyButton();
			_buyButton.addEventListener(MouseEvent.CLICK, onBuyClick);
			addChild(_buyButton);
			
			_ownedBanner = new Sprite();
			addChild(_ownedBanner);
			_ownedTextField = new TextField();
			_ownedTextField.embedFonts = true;
			_ownedTextField.defaultTextFormat = new TextFormat('EuroStyle', 11, 0xffffff, true);
			_ownedTextField.autoSize = TextFieldAutoSize.LEFT;
			_ownedTextField.selectable = false;
			_ownedBanner.addChild(_ownedTextField);
			
			_levelRequirement = 0;
			_isLocked = false;
		}
		
		override public function init(width:Number, height:Number):void
		{
			super.init(width, height);
			render();
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			// Remove event listeners.
			_thumbContainer.removeEventListener(MouseEvent.CLICK, onThumbnailClick);
			_thumbContainer.removeEventListener(MouseEvent.DOUBLE_CLICK, onThumbnailDoubleClick);
			_thumbContainer.removeEventListener(MouseEvent.ROLL_OVER, onThumbnailRollOver);
			_thumbContainer.removeEventListener(MouseEvent.ROLL_OUT, onThumbnailRollOut);
			_buyButton.removeEventListener(MouseEvent.CLICK, onBuyClick);
		}
		
		override public function render():void
		{
			super.render();
			
			// Render the thumbnail.
			renderThumbnail();
			
			// Tokens.
			_numTokensTF.x = _tokenIcon.width + 5;
			_tokenContainer.x = _width / 2 - _tokenContainer.width / 2;
			_tokenContainer.y = _height - detailsHeight;
			
			// Buy.
			renderBuyButton();
		}
		
		protected function renderThumbnail():void
		{
			if (_thumbnail == null) return;
			
			var maxWidth:Number = _width;
			var maxHeight:Number = _height - detailsHeight - 5;
			
			// Scale the thumbnail within max width and height.
			var scale:Number = Math.min(maxWidth / _thumbnail.width, maxHeight / _thumbnail.height);
			_thumbnail.width *= scale;
			_thumbnail.height *= scale;
			
			_thumbnail.x = _width/2 - _thumbnail.width/2;
			_thumbnail.y = maxHeight/2 - _thumbnail.height/2;
		}
		
		private function renderBuyButton():void
		{
			_buyButton.x = _width / 2 - _buyButton.width / 2;
			_buyButton.y = _tokenContainer.y + _tokenContainer.height + 5;
		}
		
		private function getNewBuyButton():DisplayObject
		{
			var newBuyButton:DisplayObject;
			
			if (_isAffordable)
			{
				if (_isLocked)
				{
					newBuyButton = new BuyLevelButton();
					BuyLevelButton(newBuyButton).setLevel(_levelRequirement);
				}
				else
				{
					newBuyButton = new BuyButton();
				}
			}
			else
			{
				newBuyButton = new BuyDisabledButton();
			}
			
			return newBuyButton;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		protected function get detailsHeight():Number
		{
			return _tokenContainer.height + _buyButton.height + 15;
		}
		
		public function get thumbnail():DisplayObject
		{
			return _thumbnail;
		}
		public function set thumbnail(value:DisplayObject):void
		{
			if (_thumbnail != null)
			{
				_thumbContainer.removeChild(_thumbnail);
			}
			
			// Set the new one.
			_thumbnail = value;
			_thumbContainer.addChild(_thumbnail);
			
			renderThumbnail();
		}
		
		public function set itemName(value:String):void
		{
			_itemName = value;
		}
		
		public function get itemName():String
		{
			return _itemName;
		}
		
		public function set numTokens(value:int):void
		{
			_numTokensTF.text = String(value);
			
			render();
		}
		
		public function get numTokens():int
		{
			return int(_numTokensTF.text);
		}
		
		public function get levelRequirement():int
		{
			return _levelRequirement;
		}
		public function set levelRequirement(value:int):void
		{
			_levelRequirement = value;
			
			// Set new buy button.
			buyButton = getNewBuyButton();
		}
		
		public function get isLocked():Boolean
		{
			return _isLocked;
		}
		public function set isLocked(value:Boolean):void
		{
			if (value == _isLocked) return;
			_isLocked = value;
			
			// Set new buy button.
			buyButton = getNewBuyButton();
		}
		
		public function get itemTypeId():uint
		{
			return _itemTypeId;
		}
		public function set itemTypeId(value:uint):void
		{
			_itemTypeId = value;
		}
		
		public function get itemId():uint
		{
			return _itemId;
		}
		public function set itemId(value:uint):void
		{
			_itemId = value;
		}
		
		public function get purchasedAmount():int
		{
			return 0;
		}
		public function set purchasedAmount(value:int):void
		{
			if (value == _purchasedAmount) return;
			_purchasedAmount = value;
			
			if (_purchasedAmount == 0)
				_ownedBanner.visible = false;
			else
			{
				_ownedBanner.graphics.beginFill(0x000000, .6);
				_ownedBanner.graphics.drawRoundRect(0, 0, 90, 20, 10, 10);
				_ownedBanner.graphics.endFill();
				
				_ownedTextField.text = "OWNED: " + _purchasedAmount;
				_ownedTextField.x = _ownedBanner.width / 2 - _ownedTextField.width / 2;
				_ownedBanner.rotation = -25;
				_ownedBanner.y = _thumbnail.height - 25;
				
				
				
				_ownedBanner.visible = true;
			}
		}
		
		public function get listOrderId():uint
		{
			return _listOrderId;
		}
		public function set listOrderId(value:uint):void
		{
			_listOrderId = value;
		}
		
		public function get homeTurfValue():uint
		{
			return _homeTurfValue;
		}
		public function set homeTurfValue(value:uint):void
		{
			if (value == _homeTurfValue) return;
			_homeTurfValue = value;
		}
		
		public function get isAffordable():Boolean
		{
			return _isAffordable;
		}
		public function set isAffordable(value:Boolean):void
		{
			if (value == _isAffordable) return;
			_isAffordable = value;
			var tokenPriceColor:uint = (_isAffordable) ? 0xffffff : 0xfe8d8d;
			var tf:TextFormat = new TextFormat('EuroStyle', 12, tokenPriceColor, true);
			_numTokensTF.setTextFormat(tf);
			
			// Set new buy button.
			buyButton = getNewBuyButton();
		}
		
		public function get buyButton():DisplayObject
		{
			return _buyButton;
		}
		public function set buyButton(value:DisplayObject):void
		{
			// Remove previous buy button.
			if (_buyButton)
			{
				removeChild(_buyButton);
				_buyButton.removeEventListener(MouseEvent.CLICK, onBuyClick);
			}
			
			// Set new buy button.
			_buyButton = value;
			_buyButton.addEventListener(MouseEvent.CLICK, onBuyClick);
			addChild(_buyButton);
			
			renderBuyButton();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onThumbnailClick(e:MouseEvent):void
		{
			// Dispatch a store item view event.
			var event:StoreItemViewEvent = new StoreItemViewEvent(StoreItemViewEvent.THUMBNAIL_CLICK);
			dispatchEvent(event);
		}
		
		private function onThumbnailDoubleClick(e:MouseEvent):void
		{
			// Dispatch a store item view event.
			var event:StoreItemViewEvent = new StoreItemViewEvent(StoreItemViewEvent.MAGNIFY_CLICK);
			dispatchEvent(event);
		}
		
		private function onThumbnailRollOver(e:MouseEvent):void
		{
			// Dispatch a store item view event.
			var event:StoreItemViewEvent = new StoreItemViewEvent(StoreItemViewEvent.THUMBNAIL_OVER);
			dispatchEvent(event);
		}
		
		private function onThumbnailRollOut(e:MouseEvent):void
		{
			// Dispatch a store item view event.
			var event:StoreItemViewEvent = new StoreItemViewEvent(StoreItemViewEvent.THUMBNAIL_OUT);
			dispatchEvent(event);
		}
		
		private function onPreviewButtonClicked(e:MouseEvent):void
		{
			// Dispatch a store item view event.
			var event:StoreItemViewEvent = new StoreItemViewEvent(StoreItemViewEvent.MAGNIFY_CLICK);
			dispatchEvent(event);
		}
		
		private function onBuyClick(e:MouseEvent):void
		{
			// Dispatch a store item view event.
			var event:StoreItemViewEvent = new StoreItemViewEvent(StoreItemViewEvent.BUY_CLICK);
			dispatchEvent(event);
		}
		
	}
}
