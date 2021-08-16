package com.sdg.store.nav
{
	import com.sdg.model.Store;
	import com.sdg.net.RemoteSoundBank;
	import com.sdg.store.util.StoreUtil;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;

	public class StoreNavModel extends EventDispatcher implements IStoreNavModel
	{
		public const NAV_START:Point = new Point(5,50);
		
		protected const DEFAULT_WIDTH:Number = 200;
		protected const DEFAULT_HEIGHT:Number = 200;
		
		// MVC
		protected var _view:IStoreNavView;
		protected var _controller:IStoreNavController;
		
		// Store Data
		protected var _storeId:uint;
		protected var _store:Store;
		protected var _storeName:String;
		protected var _buttons:Object;
		protected var _remoteSoundBank:RemoteSoundBank;

		//State
		protected var _currentCategory:Number;
		protected var _categorySelectHistory:Number; // Shadow of the currentCategory value
		protected var _navBorderTopUrl:String;
		protected var _navBorderMiddleUrl:String;
		protected var _navBorderBottomUrl:String;
		//protected var _subCatBypass:Number;
		//protected var _rolloverSoundUrl:String;
		//protected var _selectSoundUrl:String;

		public function StoreNavModel(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function init(view:IStoreNavView, controller:IStoreNavController):void
		{
			// Set reference to view and controller.
			_view = view;
			_controller = controller;
			
			// Initialize Variables
			_currentCategory = -1;
			
			// Create remote sound bank.
			_remoteSoundBank = new RemoteSoundBank();
			
			// Initialize the controller.
			_controller.init(this);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get remoteSoundBank():RemoteSoundBank
		{
			return _remoteSoundBank;
		}
		
		public function get store():Store
		{
			return _store;
		}
		public function set store(value:Store):void
		{
			_store = value;
			
			trace("+++++++++CHECKING FOR MATCHING CATEGORIES");
			
			//Has the Category Changed?
			if (_categorySelectHistory != _currentCategory)
			{
				trace("++++++++Categories Didn't Match 1: "+_categorySelectHistory);
				trace("++++++++Categories Didn't Match 2: "+_currentCategory);
				var event:StoreNavEvent = new StoreNavEvent(StoreNavEvent.NAV_UPDATE);
				dispatchEvent(event);	
			}
		}
		
		public function get storeId():uint
		{
			return _storeId;	
		}
		
		public function set storeId(value:uint):void
		{
			_storeId = value;
			_view.setBorderStoreId(_storeId);
		}
		
		public function get view():IStoreNavView
		{
			return _view;
		}
		
		public function get controller():IStoreNavController
		{
			return _controller;
		}
		
		public function get defaultWidth():Number
		{
			return DEFAULT_WIDTH;
		}
		
		public function get defaultHeight():Number
		{
			return DEFAULT_HEIGHT;
		}
		
		public function get storeName():String
		{
			return _storeName;
		}
		
		public function set storeName(value:String):void
		{
			_storeName = value;
		}
		
		public function get currentCategory():Number
		{
			return _currentCategory;
		}
		
		public function set currentCategory(value:Number):void
		{
			_categorySelectHistory = _currentCategory;
			_currentCategory = value;
		}
		
		// Special Additional Function
		public function resetCurrentCategory():void
		{
			_categorySelectHistory = -1;
			_currentCategory = -1;
		}
		
		//public function get categorySelectHistory():int
		//{
		//	return _categorySelectHistory;
		//}
		
		//public function set categorySelectHistory(value:int):void
		//{
		//	_categorySelectHistory = value;
		//}
		
		public function get buttons():Object
		{
			return buttons;
		}
		
		public function set buttons(value:Object):void
		{
			//redraw left nav when this changes
		}
		
		public function get navBorderTopUrl():String
		{
			return _navBorderTopUrl;
		}
		
		public function get navBorderMiddleUrl():String
		{
			return _navBorderMiddleUrl;
		}
		
		public function get navBorderBottomUrl():String
		{
			return _navBorderBottomUrl;
		}
		
		public function get rolloverSoundUrl():String
		{
			return StoreUtil.GetAssetPath() + 'Click075.mp3';
		}
		
		public function get selectSoundUrl():String
		{
			return StoreUtil.GetAssetPath() + 'Click076.mp3';
		}
		
		public function setNavBorderUrls(valueTop:String,valueMiddle:String,valueBottom:String):void
		{
			_navBorderTopUrl = valueTop;
			_navBorderMiddleUrl = valueMiddle;
			_view.setBorderMiddleUrl(valueMiddle);
			_navBorderBottomUrl = valueBottom;
			var event:StoreNavEvent = new StoreNavEvent(StoreNavEvent.NEW_BORDER_URL);
			dispatchEvent(event);
		}
		
	}
}