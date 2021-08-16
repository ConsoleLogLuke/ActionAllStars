package com.sdg.store.item
{
	import com.sdg.mvc.ViewBase;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class StoreItemDetailView extends ViewBase implements IStoreItemView
	{
		protected const MAX_CATEGORY_ICON_SIZE:Number = 100;
		protected const STAR_SIZE:Number = 20;
		
		protected var _thumbnail:DisplayObject;
		protected var _categoryIcon:DisplayObject;
		
		protected var _infoPanel:Sprite;
		
		protected var _itemNameTF:TextField;
		protected var _itemDescriptionTF:TextField;
		protected var _tokensTF:TextField;
		protected var _levelRequirementTF:TextField;
		protected var _turfValueTF:TextField;
		
		protected var _buyButton:Sprite;
		
		protected var _numTokens:int;
		protected var _levelRequirement:int;
		protected var _isLocked:Boolean;
		protected var _itemTypeId:uint;
		protected var _itemId:uint;
		protected var _purchasedAmount:uint;
		protected var _listOrderId:uint;
		protected var _homeTurfValue:uint;
		
		private var _isAffordable:Boolean;
		private var _starMeter:StarLevelMeter;
		private var _tokenIcon:DisplayObject;
		private var _turfIcon:DisplayObject;
		
		public function StoreItemDetailView()
		{
			super();
			
			// Defaults.
			_purchasedAmount = 0;
			_listOrderId = 0;
			_homeTurfValue = 0;
			_isAffordable = true;
			
			_infoPanel = new Sprite();
			addChild(_infoPanel);
			
			// Text format to be used.
			var format:TextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true);
			
			_itemNameTF = new TextField();
			_itemNameTF.embedFonts = true;
			_itemNameTF.defaultTextFormat = format;
			_itemNameTF.autoSize = TextFieldAutoSize.LEFT;
			_infoPanel.addChild(_itemNameTF);
			
			_itemDescriptionTF = new TextField();
			_itemDescriptionTF.embedFonts = true;
			_itemDescriptionTF.defaultTextFormat = format;
			_itemDescriptionTF.autoSize = TextFieldAutoSize.LEFT;
			_itemDescriptionTF.wordWrap = true;
			_itemDescriptionTF.multiline = true;
			_infoPanel.addChild(_itemDescriptionTF);
			
			_tokensTF = new TextField();
			_tokensTF.embedFonts = true;
			_tokensTF.defaultTextFormat = format;
			_tokensTF.autoSize = TextFieldAutoSize.LEFT;
			_tokensTF.text = "0";
			_infoPanel.addChild(_tokensTF);
			
			_turfValueTF = new TextField();
			_turfValueTF.embedFonts = true;
			_turfValueTF.defaultTextFormat = format;
			_turfValueTF.autoSize = TextFieldAutoSize.LEFT;
			_turfValueTF.text = "0";
			_turfValueTF.visible = false;
			_infoPanel.addChild(_turfValueTF);
			
			_levelRequirementTF = new TextField();
			_levelRequirementTF.embedFonts = true;
			_levelRequirementTF.autoSize = TextFieldAutoSize.LEFT;
			_infoPanel.addChild(_levelRequirementTF);
			
			_starMeter = new StarLevelMeter();
			_starMeter.setLevel(1);
			_infoPanel.addChild(_starMeter);
			
			_tokenIcon = new ShopToken();
			var tknSize:Number = 32;
			var tknScale:Number = Math.min(tknSize / _tokenIcon.width, tknSize / _tokenIcon.height);
			_tokenIcon.width *= tknScale;
			_tokenIcon.height *= tknScale;
			_infoPanel.addChild(_tokenIcon);
			
			_turfIcon = new HomeTurfIconGold();
			var icnSize:Number = 32;
			var icnScale:Number = Math.min(icnSize / _turfIcon.width, icnSize / _turfIcon.height);
			_turfIcon.width *= icnScale;
			_turfIcon.height *= icnScale;
			_turfIcon.visible = false;
			_infoPanel.addChild(_turfIcon);
			
			// Buy button.
			_buyButton = getNewBuyButton();
			_buyButton.buttonMode = true;
			_buyButton.addEventListener(MouseEvent.CLICK, onBuyClick);
			_infoPanel.addChild(_buyButton);
			
			_levelRequirement = 0;
			_isLocked = false;
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		override public function init(width:Number, height:Number):void
		{
			super.init(width, height);
			render();
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			// Remove event listeners.
			_buyButton.removeEventListener(MouseEvent.CLICK, onBuyClick);
			
			// Destroy object references to help with garbage collection.
			_thumbnail = null;
			_categoryIcon = null;
			_infoPanel = null;
			_itemNameTF = null;
			_itemDescriptionTF = null;
			_tokensTF = null;
			_levelRequirementTF = null;
			_buyButton = null;
		}
		
		
		override public function render():void
		{
			super.render();
			
			_itemNameTF.x = MAX_CATEGORY_ICON_SIZE + 10;
			
			_itemDescriptionTF.x = MAX_CATEGORY_ICON_SIZE + 10;
			_itemDescriptionTF.y = _itemNameTF.height;
			_itemDescriptionTF.width = _width - _itemDescriptionTF.x;
			
			_starMeter.x = _itemDescriptionTF.x;
			_starMeter.y = _itemDescriptionTF.y + _itemDescriptionTF.height + 10;
			
			_tokenIcon.x = _starMeter.x;
			_tokenIcon.y = _starMeter.y + _starMeter.height + 10;
			
			_turfIcon.x = _tokenIcon.x;
			_turfIcon.y = _tokenIcon.y + _tokenIcon.height + 10;
			
			_tokensTF.x = _tokenIcon.x + _tokenIcon.width + 10;
			_tokensTF.y = _tokenIcon.y + _tokenIcon.height / 2 - _tokensTF.height / 2;
			
			_turfValueTF.x = _tokensTF.x;
			_turfValueTF.y = _turfIcon.y + _turfIcon.height / 2 - _turfValueTF.height / 2;
			
			renderCategoryIcon();
			renderBuyButton();
			renderThumbnail();
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		protected function renderBuyButton():void
		{
			// Scale buy button.
			var buttonSize:Number = 46;
			var btnScale:Number = Math.max(buttonSize / _buyButton.width, buttonSize / _buyButton.height);
			_buyButton.width *= btnScale;
			_buyButton.height *= btnScale;
			
			_buyButton.x = _width / 2 - _buyButton.width / 2;
			_buyButton.y = detailsHeight - _buyButton.height;
		}
		
		protected function renderThumbnail():void
		{
			if (_thumbnail == null) return;
			
			var maxAvailableWidth:Number = _width;
			var maxAvailableHeight:Number = _height - detailsHeight - 5;
			
			var maxWidth:Number = 0.7 * maxAvailableWidth;
			var maxHeight:Number = 0.7 * maxAvailableHeight;
			
			// Scale the thumbnail within max width and height.
			var scale:Number = Math.min(maxWidth / _thumbnail.width, maxHeight / _thumbnail.height);
			_thumbnail.width *= scale;
			_thumbnail.height *= scale;
			
			_thumbnail.x = maxAvailableWidth/2 - _thumbnail.width/2;
			_thumbnail.y = maxAvailableHeight/2 - _thumbnail.height/2;
			
			_infoPanel.y = _height - detailsHeight;
			trace(detailsHeight);
		}
		
		protected function renderCategoryIcon():void
		{
			if (_categoryIcon == null) return;
			
			// Scale the thumbnail within max width and height.
			var scale:Number = Math.min(MAX_CATEGORY_ICON_SIZE/_categoryIcon.width, MAX_CATEGORY_ICON_SIZE/_categoryIcon.height);
			_categoryIcon.width *= scale;
			_categoryIcon.height *= scale;
			
			_categoryIcon.x = MAX_CATEGORY_ICON_SIZE/2  - _categoryIcon.width/2;
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function getNewBuyButton():Sprite
		{
			return new BuyButton();
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		protected function get detailsHeight():Number
		{
			return 233.45;
		}
		
		public function set categoryIcon(value:DisplayObject):void
		{
			if (_categoryIcon != null)
				removeChild(_categoryIcon);
			
			_categoryIcon = value;
			_infoPanel.addChild(_categoryIcon);
			
			render();
		}
		
		public function get thumbnail():DisplayObject
		{
			return _thumbnail;
		}
		
		public function set thumbnail(value:DisplayObject):void
		{
			if (_thumbnail != null)
				removeChild(_thumbnail);
			
			// Set the new one.
			_thumbnail = value;
			addChild(_thumbnail);
			
			renderThumbnail();
		}
		
		public function set itemName(value:String):void
		{
			_itemNameTF.text = value;
			
			render();
		}
		
		public function get itemName():String
		{
			return _itemNameTF.text;
		}
		
		public function set itemDescription(value:String):void
		{
			_itemDescriptionTF.text = value;
			
			render();
		}
		
		public function get itemDescription():String
		{
			return _itemDescriptionTF.text;
		}
		
		public function set numTokens(value:int):void
		{
			_numTokens = value;
			_tokensTF.text = _numTokens.toString();
			
			render();
		}
		
		public function get numTokens():int
		{
			return _numTokens;
		}
		
		public function set levelRequirement(value:int):void
		{
			if (value == _levelRequirement) return;
			_levelRequirement = value;
			_starMeter.setLevel(Math.ceil(_levelRequirement / 5));
			
			render();
		}
		
		public function get levelRequirement():int
		{
			return _levelRequirement;
		}
		
		public function set isLocked(value:Boolean):void
		{
			_isLocked = value;
			
			render();
		}
		
		public function get isLocked():Boolean
		{
			return _isLocked;
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
			_turfValueTF.text = _homeTurfValue.toString();
			_turfIcon.visible = _turfValueTF.visible = (_homeTurfValue > 0);
			render();
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
			// Dispatch a buy click event.
			dispatchEvent(new StoreItemViewEvent(StoreItemViewEvent.BUY_CLICK));
		}
		
	}
}
