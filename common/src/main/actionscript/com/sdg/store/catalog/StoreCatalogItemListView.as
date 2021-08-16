package com.sdg.store.catalog
{
	import com.sdg.buttonstyle.ButtonSyle;
	import com.sdg.buttonstyle.IButtonStyle;
	import com.sdg.controls.BasicButton;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.FillStyle;
	import com.sdg.events.LoaderQueEvent;
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.model.StoreItem;
	import com.sdg.model.StoreItemCollection;
	import com.sdg.mvc.ViewBase;
	import com.sdg.net.Environment;
	import com.sdg.net.LoaderQue;
	import com.sdg.store.item.IStoreItemView;
	import com.sdg.store.skin.ScrollBarBacking;
	import com.sdg.store.skin.ScrollButtonDown;
	import com.sdg.store.skin.ScrollButtonUp;
	import com.sdg.view.ItemListWindow;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextFormat;

	public class StoreCatalogItemListView extends ViewBase implements IStoreCatalogItemListView
	{
		protected var _background:DisplayObject;
		protected var _itemListWindow:ItemListWindow;
		protected var _items:StoreItemCollection;
		protected var _margins:Array;
		protected var _filterHeader:Sprite;
		protected var _weekButton:BasicButton;
		protected var _monthButton:BasicButton;
		protected var _filterButtonOffStyle:BoxStyle;
		protected var _filterOverOffStyle:BoxStyle;
		protected var _filterButtonStyle:IButtonStyle;
		protected var _selectedFilterStyle:IButtonStyle;
		
		public function StoreCatalogItemListView()
		{
			super();
			
			_width = 200;
			_height = 300;
			_margins = [0, 0, 0, 0];
			
			// Create filter header.
			_filterHeader = new Sprite();
			addChild(_filterHeader);
			
			// Create all time button.
			_filterButtonOffStyle = new BoxStyle(new FillStyle(0x000000, 1), 0x444444, 1, 1, 6);
			_filterOverOffStyle = new BoxStyle(new FillStyle(0x222222, 1), 0x444444, 1, 1, 6);
			_filterButtonStyle = new ButtonSyle(_filterButtonOffStyle, _filterOverOffStyle, _filterButtonOffStyle);
			_selectedFilterStyle = new ButtonSyle(_filterOverOffStyle, _filterOverOffStyle, _filterOverOffStyle);
			_weekButton = new BasicButton('WEEK', 70, 20, _selectedFilterStyle);
			_weekButton.labelFormat = new TextFormat('EuroStyle', 12, 0xffffff, true);
			_weekButton.embedFonts = true;
			_weekButton.addEventListener(MouseEvent.CLICK, onWeekClick);
			_filterHeader.addChild(_weekButton);
			
			// Create monthly filter button.
			_monthButton = new BasicButton('30 DAYS', 70, 20, _filterButtonStyle);
			_monthButton.labelFormat = new TextFormat('EuroStyle', 12, 0xffffff, true);
			_monthButton.embedFonts = true;
			_monthButton.addEventListener(MouseEvent.CLICK, onMonthClick);
			_filterHeader.addChild(_monthButton);
			
			// Create item list window.
			_itemListWindow = new ItemListWindow(_width, _height, 1, 100, 5);
			_itemListWindow.widthHeightRatio = 3;
			addChild(_itemListWindow);
			
			// Create scroll bar elements.
			_itemListWindow.vScrollBar.scrollButton1 = new ScrollButtonUp(0xffffff);
			_itemListWindow.vScrollBar.scrollButton2 = new ScrollButtonDown(0xffffff);
			_itemListWindow.vScrollBar.scrollBarBacking = new ScrollBarBacking();
			var grabber:Sprite = new Sprite();
			grabber.graphics.beginFill(0, 0);
			grabber.graphics.drawRect(0, 0, 20, 20);
			grabber.graphics.endFill();
			grabber.graphics.beginFill(0x888888);
			grabber.graphics.drawRect(4, 0, 12, 20);
			_itemListWindow.vScrollBar.scrollBarGrabber = grabber;
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			// Remove event listeners.
			_weekButton.removeEventListener(MouseEvent.CLICK, onWeekClick);
			_filterHeader.removeEventListener(MouseEvent.CLICK, onMonthClick);
		}
		
		override public function render():void
		{
			// Get reference to margins;
			var topM:Number = _margins[0];
			var rightM:Number = _margins[1];
			var bottomM:Number = _margins[2];
			var leftM:Number = _margins[3];
			var xM:Number = leftM + rightM;
			var yM:Number = topM + bottomM;
			
			// Draw filter header.
			_filterHeader.graphics.clear();
			_filterHeader.graphics.beginFill(0x00ff00, 0);
			_filterHeader.graphics.drawRect(0, 0, _width - xM, 24);
			_filterHeader.x = leftM;
			_filterHeader.y = topM;
			
			// Position filter buttons.
			_weekButton.x = 10;
			_weekButton.y = _filterHeader.height / 2 - _weekButton.height / 2;
			_monthButton.x = _weekButton.x + _weekButton.width + 5;
			_monthButton.y = _filterHeader.height / 2 - _monthButton.height / 2;
			
			// Scale item list window.
			_itemListWindow.width = _width - xM;
			_itemListWindow.height = _height - yM - _filterHeader.height;
			_itemListWindow.x = leftM;
			_itemListWindow.y = _filterHeader.y + _filterHeader.height;
			
			// Scale background.
			if (_background != null)
			{
				_background.width = _width;
				_background.height = _height;
			}
		}
		
		public function setMargin(top:Number, right:Number, bottom:Number, left:Number):void
		{
			_margins = [top, right, bottom, left];
			render();
		}
		
		public function set items(value:StoreItemCollection):void
		{
			// Set new value.
			_items = value;
			
			// Create loader que for the thumbnails.
			var loaderQue:LoaderQue = new LoaderQue(1, 3000, 2, true);
			loaderQue.addEventListener(LoaderQueEvent.COMPLETE, loadComplete);
			loaderQue.addEventListener(LoaderQueEvent.EMPTY, onEmpty);
			
			// Create item views and pass them to the item list window.
			var i:uint = 0;
			var len:uint = _items.length;
			var itemViews:DisplayObjectCollection = new DisplayObjectCollection();
			var itemViewUrls:Array = [];
			for (i; i < len; i++)
			{
				// Get reference to item.
				var item:StoreItem = _items.getAt(i);
				if (item == null) continue;
				
				// Create item view.
				var itemView:IStoreItemView = new BestSellerItemView(5);
				itemView.init(_width, 30);
				itemView.itemName = item.name;
				itemView.numTokens = item.price;
				itemView.itemId = item.id;
				
				// Get reference to thumbnail url.
				var url:String = Environment.getAssetUrl() + item.thumbnailUrl + '&i=' + i;
				
				// Keep track of thumbnail urls.
				itemViewUrls.push(url);
				
				// Load item thumbnail.
				loaderQue.addRequest(new URLRequest(url));
				
				// Add item view to collection.
				itemViews.push(itemView.display);
			}
			
			// Pass the item views to the item list window.
			_itemListWindow.items = itemViews;
			
			// Reset scroll position.
			_itemListWindow.scrollValueY = 0;
			
			function loadComplete(e:LoaderQueEvent):void
			{
				// Determine index of url.
				var index:int = itemViewUrls.indexOf(e.loader.contentLoaderInfo.url);
				if (index < 0) return;
				
				// Get reference to item view.
				var itemView:IStoreItemView = itemViews.getAt(index) as IStoreItemView;
				if (itemView == null) return;
				
				// Create a bitmap copy of the loaded thumbnail.
				var content:DisplayObject = e.loader.content;
				var bitData:BitmapData = new BitmapData(content.width, content.height, true, 0);
				bitData.draw(content);
				var thumbnail:Bitmap = new Bitmap(bitData, 'auto', true);
				
				// Pass the thumbnail to the item view.
				itemView.thumbnail = thumbnail;
			}
			
			function onEmpty(e:LoaderQueEvent):void
			{
				// Remove event listeners.
				loaderQue.addEventListener(LoaderQueEvent.COMPLETE, loadComplete);
				loaderQue.addEventListener(LoaderQueEvent.EMPTY, onEmpty);
			}
		}
		
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
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onWeekClick(e:MouseEvent):void
		{
			// Set filter button styles.
			_weekButton.offStyle = _selectedFilterStyle.offStyle;
			_monthButton.offStyle = _filterButtonOffStyle;
			
			dispatchEvent(new StoreCatalogItemListEvent(StoreCatalogItemListEvent.FILTER_WEEK_CLICK));
		}
		
		private function onMonthClick(e:MouseEvent):void
		{
			// Set filter button styles.
			_monthButton.offStyle = _selectedFilterStyle.offStyle;
			_weekButton.offStyle = _filterButtonOffStyle;
			
			dispatchEvent(new StoreCatalogItemListEvent(StoreCatalogItemListEvent.FILTER_MONTH_CLICK));
		}
		
	}
}