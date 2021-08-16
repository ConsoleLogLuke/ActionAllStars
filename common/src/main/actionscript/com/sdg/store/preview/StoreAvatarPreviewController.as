package com.sdg.store.preview
{
	import com.sdg.display.AvatarSprite;
	import com.sdg.events.AvatarUpdateEvent;
	import com.sdg.model.Avatar;
	import com.sdg.view.LayeredImage;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class StoreAvatarPreviewController extends EventDispatcher implements IStoreAvatarPreviewController
	{
		public static const LOAD_NEW_AVATAR:String = 'load new avatar';
		
		protected var _model:IStoreAvatarPreviewModel;
		
		protected var _layeredAvatarImage:LayeredImage;
		protected var _avatar:Avatar;
		
		// Token & Point update delay.
		// If we recieve an update from the avatar
		// that points or tokens have been updated,
		// wait a defined period of time before reacting.
		// This way if we are supposed to react to both
		// in a short period of time, we can handle it
		// in a specific way.
		protected var _tokenPointUpdateDelay:Number = 1000; // 1 Second
		protected var _recTokenCount:uint = 0;
		protected var _recPointCount:uint = 0;
		protected var _currentAvatarPoints:uint;
		
		public function StoreAvatarPreviewController(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function init(model:IStoreAvatarPreviewModel):void
		{
			// Set reference to model.
			_model = model;
			
			// Initialize the view.
			_model.view.init(_model.defaultWidth, _model.defaultHeight);
			
			// Add listeners to model.
			_model.addEventListener(StoreAvatarPreviewEvent.NEW_AVATAR, onNewAvatar);
			_model.addEventListener(StoreAvatarPreviewEvent.NEW_APPAREL_ITEM, onNewApparelItem);
			_model.addEventListener(StoreAvatarPreviewEvent.NEW_BACKGROUND_URL, onNewBackgroundUrl);
			
			// Listen to the view.
			_model.view.addEventListener(StoreAvatarPreviewEvent.ADD_TOKENS_CLICK, onAddTokensClick);
		}
		
		public function destroy():void
		{
			// Remove event listeners.
			_model.removeEventListener(StoreAvatarPreviewEvent.NEW_AVATAR, onNewAvatar);
			_model.removeEventListener(StoreAvatarPreviewEvent.NEW_APPAREL_ITEM, onNewApparelItem);
			_model.removeEventListener(StoreAvatarPreviewEvent.NEW_BACKGROUND_URL, onNewBackgroundUrl);
			_model.view.removeEventListener(StoreAvatarPreviewEvent.ADD_TOKENS_CLICK, onAddTokensClick);
			_avatar.removeEventListener(AvatarUpdateEvent.SUBLEVEL_UPDATE, onSubLevelUpdated);
			_avatar.removeEventListener(AvatarUpdateEvent.TOKENS_UPDATE, onTokensUpdated);
			_avatar.removeEventListener(Avatar.POINTS_UPDATE, onPointsUpdated);
			
			// Destroy view.
			_model.view.destroy();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onNewAvatar(e:StoreAvatarPreviewEvent):void
		{
			// When a new avatar is set, update the view.
			var previewView:IStoreAvatarPreviewView = _model.view;
			
			// Check if this is a new avatar.
			if (_model.avatar != _avatar)
			{
				if (_avatar != null)
				{
					// Remove listeners.
					_avatar.removeEventListener(AvatarUpdateEvent.SUBLEVEL_UPDATE, onSubLevelUpdated);
					_avatar.removeEventListener(AvatarUpdateEvent.TOKENS_UPDATE, onTokensUpdated);
					_avatar.removeEventListener(Avatar.POINTS_UPDATE, onPointsUpdated);
				}
				
				// Pass new avatar data to the view.
				previewView.avatarName = _model.avatar.name;
				previewView.tokens = _model.avatar.currency;
				previewView.turfValue = _model.avatar.homeTurfValue;
				previewView.level = _model.avatar.level;
				previewView.levelName = _model.avatar.levelName;
				previewView.subLevel = _model.avatar.subLevel;
				
				_avatar = _model.avatar;
				_currentAvatarPoints = _avatar.points;
				_model.avatar.addEventListener(AvatarUpdateEvent.SUBLEVEL_UPDATE, onSubLevelUpdated);
				_model.avatar.addEventListener(AvatarUpdateEvent.TOKENS_UPDATE, onTokensUpdated);
				_model.avatar.addEventListener(Avatar.POINTS_UPDATE, onPointsUpdated);
			}
			
			// Dispatch an event that signifies a new avatar will be loaded.
			dispatchEvent(new Event(LOAD_NEW_AVATAR));
			var loadComplete:Boolean = false;
			addEventListener(LOAD_NEW_AVATAR, onLoadNewAvatar);
			
			// Set the avatar image as a loading indicator.
			var loadIndicator:Sprite = new Sprite();
			loadIndicator.graphics.beginFill(0xffffff, 0);
			loadIndicator.graphics.drawRect(0, 0, 255, 340);
			var star:DisplayObject = new StarLoadingIndicator();
			star.x = loadIndicator.width / 2 - star.width / 2;
			star.y = loadIndicator.height / 2 - star.height / 2;
			loadIndicator.addChild(star);
			previewView.avatarImage = loadIndicator;
			
			// Load avatar image for the avatar.
			_layeredAvatarImage = new LayeredImage();
			_layeredAvatarImage.addEventListener(Event.COMPLETE, onComplete);
			_layeredAvatarImage.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_layeredAvatarImage.loadItemImage(_model.avatar);
			
			function onProgress(e:ProgressEvent):void
			{
				// Set load progress.
				previewView.avatarImageLoadProgress = e.bytesLoaded / e.bytesTotal;
			}
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				_layeredAvatarImage.removeEventListener(Event.COMPLETE, onComplete);
				_layeredAvatarImage.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				removeEventListener(LOAD_NEW_AVATAR, onLoadNewAvatar);
				
				// Apply filters to the avatar image.
				_layeredAvatarImage.filters = AvatarSprite.DefaultAvatarPreviewFilters;
				
				// Set avatar image.
				previewView.avatarImage = _layeredAvatarImage;
			}
			function onLoadNewAvatar(e:Event):void
			{
				// If a new avatar is gonna be loaded before this one has finished loading,
				// cancel this load in favor of the new one.
				if (loadComplete == false)
				{
					// Remove event listeners.
					_layeredAvatarImage.removeEventListener(Event.COMPLETE, onComplete);
					_layeredAvatarImage.removeEventListener(ProgressEvent.PROGRESS, onProgress);
					removeEventListener(LOAD_NEW_AVATAR, onLoadNewAvatar);
					// Cancel load.
					_layeredAvatarImage.close();
				}
			}
		}
		
		private function onNewApparelItem(e:StoreAvatarPreviewEvent):void
		{
			_layeredAvatarImage.mergeUrlArray(_model.currentApparelUrls);
		}
		
		private function onNewBackgroundUrl(e:StoreAvatarPreviewEvent):void
		{
			// Load the new background.
			var url:String = _model.backgroundUrl;
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.load(request);
			
			function onLoadComplete(e:Event):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				
				// Pass the loaded background to the view.
				_model.view.background = loader.content;
			}
			
			function onLoadError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			}
		}
		
		private function onAddTokensClick(e:StoreAvatarPreviewEvent):void
		{
			// Propegate the event.
			dispatchEvent(new StoreAvatarPreviewEvent(e.type));
		}
		
		private function onTokensUpdated(e:AvatarUpdateEvent):void
		{
			// Get reference to the avtar preview.
			var previewView:IStoreAvatarPreviewView = _model.view;
			
			_recTokenCount = _avatar.currency;
			
			// Create a timer for the token/point delay.
			var timer:Timer = new Timer(_tokenPointUpdateDelay);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;
				
				if (_recPointCount > 0)
				{
					previewView.animateTokensAndXp(_recTokenCount, 4000, _recPointCount, 4000);
				}
				else if (_recTokenCount > 0)
				{
					previewView.animateTokens(_recTokenCount);
				}
				
				// Reset values.
				_recTokenCount = 0;
				_recPointCount = 0;
			}
		}
		
		private function onPointsUpdated(e:Event):void
		{
			var increase:uint = _avatar.points - _currentAvatarPoints;
			_recPointCount = increase;
			_currentAvatarPoints = _avatar.points;
			
			// Get reference to the avtar preview.
			var previewView:IStoreAvatarPreviewView = _model.view;
			
			// Create a timer for the token/point delay.
			var timer:Timer = new Timer(_tokenPointUpdateDelay);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;
				
				if (_recTokenCount > 0)
				{
					previewView.animateTokensAndXp(_recTokenCount, 4000, _recPointCount, 5000);
				}
				else if (_recPointCount > 0)
				{
					previewView.animateXp(_recPointCount);
				}
				
				// Reset values.
				_recTokenCount = 0;
				_recPointCount = 0;
			}
		}
		
		private function onSubLevelUpdated(e:AvatarUpdateEvent):void
		{
			// Update level info on view.
			_model.view.level = _model.avatar.level;
			_model.view.levelName = _model.avatar.levelName;
			_model.view.subLevel = _model.avatar.subLevel;
		}
		
	}
}