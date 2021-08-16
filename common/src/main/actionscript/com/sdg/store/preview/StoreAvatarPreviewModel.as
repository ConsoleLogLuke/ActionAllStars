package com.sdg.store.preview
{
	import com.boostworthy.animation.management.AnimationManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.IPreviewItem;
	import com.sdg.model.StoreItem;
	import com.sdg.net.Environment;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class StoreAvatarPreviewModel extends EventDispatcher implements IStoreAvatarPreviewModel
	{
		protected const DEFAULT_WIDTH:Number = 200;
		protected const DEFAULT_HEIGHT:Number = 200;
		
		protected var _view:IStoreAvatarPreviewView;
		protected var _controller:IStoreAvatarPreviewController;
		
		protected var _avatar:Avatar;
		protected var _avatarApparelUrls:Array;
		protected var _currentApparelUrls:Array;
		protected var _backgroundUrl:String;
		
		public function StoreAvatarPreviewModel(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function init(view:IStoreAvatarPreviewView, controller:IStoreAvatarPreviewController):void
		{
			// Set reference to view and controller.
			_view = view;
			_controller = controller;
			
			// Initialize the controller.
			_controller.init(this);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function resetClothing():void
		{
			// Reset the current apparel to the avatars actual apparel.
			_currentApparelUrls = _avatarApparelUrls.concat();
			dispatchEvent(new StoreAvatarPreviewEvent(StoreAvatarPreviewEvent.NEW_APPAREL_ITEM));
		}
		public function addItemSet(setItem:StoreItem):void{
			
			// Get the avatar's apparel url's including the new item.
			_currentApparelUrls = _avatar.getLayeredImageUrlArrayWithNewItems(setItem.childItems);
			
			// Dispatch event that indicates there is new apparel.
			dispatchEvent(new StoreAvatarPreviewEvent(StoreAvatarPreviewEvent.NEW_APPAREL_ITEM));
		}
		public function addItem(item:IPreviewItem):void
		{
			//reset first, to take into account sets
			_currentApparelUrls = _avatarApparelUrls.concat();
		
			
			// Get the avatar's apparel url's including the new item.
			_currentApparelUrls = _avatar.getLayeredImageUrlArrayWithNewItems([item]);
			
			// Dispatch event that indicates there is new apparel.
			dispatchEvent(new StoreAvatarPreviewEvent(StoreAvatarPreviewEvent.NEW_APPAREL_ITEM));
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get view():IStoreAvatarPreviewView
		{
			return _view;
		}
		
		public function get controller():IStoreAvatarPreviewController
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
		
		public function get avatar():Avatar
		{
			return _avatar;
		}
		public function set avatar(value:Avatar):void
		{
			_avatar = value;
			
			_avatarApparelUrls = _avatar.getLayeredImageUrlArray();
			_currentApparelUrls = _avatarApparelUrls.concat();
			
			dispatchEvent(new StoreAvatarPreviewEvent(StoreAvatarPreviewEvent.NEW_AVATAR));
		}
		
		public function get currentApparelUrls():Array
		{
			return _currentApparelUrls;
		}
		
		public function get backgroundUrl():String
		{
			return _backgroundUrl;
		}
		public function set backgroundUrl(value:String):void
		{
			if (value == _backgroundUrl) return;
			_backgroundUrl = value;
			dispatchEvent(new StoreAvatarPreviewEvent(StoreAvatarPreviewEvent.NEW_BACKGROUND_URL))
		}
		
		public function get addTokensButtonUrl():String
		{
			return Environment.getAssetUrl() + '/test/gameSwf/gameId/70/gameFile/btn_addTokens.swf';
		}
		
	}
}