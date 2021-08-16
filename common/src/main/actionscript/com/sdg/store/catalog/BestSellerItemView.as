package com.sdg.store.catalog
{
	import com.sdg.buttonstyle.ButtonSyle;
	import com.sdg.buttonstyle.IButtonStyle;
	import com.sdg.controls.BasicButton;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.GradientFillStyle;
	import com.sdg.mvc.ViewBase;
	import com.sdg.store.item.IStoreItemView;
	import com.sdg.store.item.StoreItemViewEvent;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class BestSellerItemView extends ViewBase implements IStoreItemView
	{
		protected var _nameField:TextField;
		protected var _tokenField:TextField;
		protected var _numTokens:uint;
		protected var _itemThumbnail:DisplayObject;
		protected var _margin:Number;
		protected var _itemTypeId:uint;
		protected var _itemId:uint;
		protected var _buyButton:BasicButton;
		protected var _mask:Sprite;
		protected var _purchasedAmount:uint;
		protected var _listOrderId:uint;
		protected var _isLocked:Boolean;
		protected var _levelRequirement:int;
		protected var _homeTurfValue:uint;
		
		private var _isAffordable:Boolean;
		
		public function BestSellerItemView(margin:Number = 10)
		{
			super();
			
			// Defaults.
			_margin = margin;
			_purchasedAmount = 0;
			_listOrderId = 0;
			
			// Create mask.
			_mask = new Sprite();
			addChild(_mask);
			
			// Create name field.
			_nameField = new TextField();
			_nameField.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff, true);
			_nameField.autoSize = TextFieldAutoSize.LEFT;
			_nameField.selectable = false;
			_nameField.mouseEnabled = false;
			_nameField.embedFonts = true;
			_nameField.mask = _mask;
			addChild(_nameField);
			
			// Create token field.
			_tokenField = new TextField();
			_tokenField.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff, true);
			_tokenField.autoSize = TextFieldAutoSize.LEFT;
			_tokenField.selectable = false;
			_tokenField.mouseEnabled = false;
			_tokenField.embedFonts = true;
			addChild(_tokenField);
			
			// Buy button.
			var offStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xf8db5c, 0xd28602], [1, 1], [1, 255], Math.PI / 2), 0x913300, 1, 1, 8);
			var overStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xd18500, 0xa54c0a], [1, 1], [1, 255], Math.PI / 2), 0x913300, 1, 1, 8);
			var bStyle:IButtonStyle = new ButtonSyle(offStyle, overStyle, overStyle);
			_buyButton = new BasicButton('BUY', 40, 18, bStyle);
			_buyButton.labelFormat = new TextFormat('EuroStyle', 10, 0x913300, true);
			_buyButton.embedFonts = true;
			_buyButton.addEventListener(MouseEvent.CLICK, onBuyClick);
			addChild(_buyButton);
			
			// Create thumbnail.
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0xffffff);
			s.graphics.drawRect(0, 0, 10, 10);
			_itemThumbnail = s;
			addChild(_itemThumbnail);
			
			render();
		}
		
		override public function destroy():void
		{
		}
		
		override public function render():void
		{
			// Scale item thumbnail.
			var maxScale:Number = (_height - _margin * 2) / _itemThumbnail.height;
			_itemThumbnail.width *= maxScale;
			_itemThumbnail.height *= maxScale;
			_itemThumbnail.x = _margin;
			_itemThumbnail.y = _margin;
			
			_nameField.x = _itemThumbnail.x + _itemThumbnail.width + _margin;
			_nameField.y = _itemThumbnail.y;
			
			_tokenField.x = _nameField.x;
			_tokenField.y = _nameField.y + _nameField.height;
			
			_buyButton.x = _nameField.x;
			_buyButton.y = _tokenField.y + _tokenField.height;
			
			// Draw mask.
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00ff00);
			_mask.graphics.drawRect(0, 0, _width, _height);
		}
		
		public function get levelRequirement():int
		{
			return _levelRequirement;
		}
		public function set levelRequirement(value:int):void
		{
			_levelRequirement=value;
		}
		
		public function get isLocked():Boolean
		{
		
			return _isLocked;
		}
		public function set isLocked(value:Boolean):void
		{
			_isLocked=value;
		}
		
		public function get thumbnail():DisplayObject
		{
			return _itemThumbnail;
		}
		public function set thumbnail(value:DisplayObject):void
		{
			// Remove previous.
			if (_itemThumbnail != null)
			{
				removeChild(_itemThumbnail);
			}
			
			// Set new one.
			_itemThumbnail = value;
			addChild(_itemThumbnail);
			
			render();
		}
		
		public function get itemName():String
		{
			return _nameField.text;
		}
		public function set itemName(value:String):void
		{
			_nameField.text = value;
			render();
		}
		
		public function get numTokens():int
		{
			return _numTokens;
		}
		public function set numTokens(value:int):void
		{
			_numTokens = value;
			_tokenField.text = _numTokens.toString() + ' Tokens';
			render();
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
			return _purchasedAmount;
		}
		public function set purchasedAmount(value:int):void
		{
			_purchasedAmount = value;
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
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onBuyClick(e:MouseEvent):void
		{
			// Dispatch a store item view event.
			var event:StoreItemViewEvent = new StoreItemViewEvent(StoreItemViewEvent.BUY_CLICK, true);
			dispatchEvent(event);
		}
		
	}
}