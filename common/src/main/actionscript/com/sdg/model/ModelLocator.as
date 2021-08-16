package com.sdg.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.sdg.collections.MruCache;
	
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class ModelLocator extends EventDispatcher implements IModelLocator, IEventDispatcher
	{
		public static const EVENTS_UPDATE:String = 'events update';
		private static var _instance:ModelLocator;
		
		public var audio:Audio = new Audio();
		public var user:User = new User();
		// WARNING: This avatar object is created on load but is removed if the user edits their turf amoung other things.
		// only use it for things that don't change like the avatarID or membership status.
		//If you need access to the local avatars display se RoomManager.userController instead.
		public var avatar:Avatar = new Avatar();
		public var avatarLevels:Object = new Object();
		public var servers:ArrayCollection = new ArrayCollection();
		public var inventoryItemTypes:Object = new Object();
		public var jabList:Array = new Array();
		public var jabMap:Object = new Object();
		public var emoteList:Array = new Array();
		public var emoteMap:Object = new Object();
		public var itemSetsMap:Object = new Object();
		public var ignoredAvatars:Object = new Object();
		public var currentGameSessionId:String = "";
		public var currentGameLevel:String = "";
		public var currentGameId:int = 0;
		public var application:MainApplication = new MainApplication();
		public var hasUnity:String;
		private var _tmr:Timer;
		private var _localTime:Number;
		private var _serverToLocalDateOffset:Number;
		public var affiliate:uint = 0;
		private var _actionAllStarEvents:ActionAllStarsEventCollection = new ActionAllStarsEventCollection();
		public var pickemSharedObject:SharedObject = SharedObject.getLocal("newPickemResults");
		public var referFriend:Buddy = null;
		public var incomingGameParams:Object;
				
		// avatar sprite sheet caching data
		public var urlSpriteSheetLoaders:Object = new Object();           // sprite sheets in the process of downloading
		public var expandingSpriteSheetLoaders:Object = new Object();     // sprite sheets in the process of expanding
	    public var spriteSheetCache:MruCache = new MruCache(1000);        // compressed bitmaps
	    public var expandedSpriteSheetBitmapsAlpha:Object = new Object(); // bitmaps with the alpha value in the green channel
	    public var expandedSpriteSheetBitmapsPerm:Object = new Object();  // expanded bitmaps - permanently cached
	    public var expandedSpriteSheetBitmaps:Object = new Object();      // expanded bitmaps (up to 20 or so)
	    public var expandedSpriteSheetsToCache:Object = new Object();     // item keys (20 or so) for bitmaps to be cached
	    public var expandedSpriteSheetsToCachePerm:Object = new Object(); // item keys for bitmaps to be permanently cached
	    public var mouthSpriteSheet:Bitmap;                               // the mouth for all avatars
	    public var eyesSpriteSheet:Bitmap;                                // the eyes for all avatars
	    
	    protected var _stores:Object = new Object();
		
		public function ModelLocator()
		{
			if (_instance)
				throw new Error("ModelLocator is a singleton class. Use 'getInstance()' to access the instance.");
		}
		
		public static function getInstance():ModelLocator
		{
			if (_instance == null) _instance = new ModelLocator();
			return _instance;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		private function accountForLocalTimeDifference():void
		{
			// get current local date/time
			var now:Date = new Date();
			// determine the offset of current local time to the last time the local time was stored
			// if that offset is more than 4 seconds
			// recalculate server time to local time offset
			var offset:Number = now.time - _localTime;
			if (Math.abs(offset) > 4000)
			{
				_serverToLocalDateOffset -= offset;
			}
			
			// update stored local time
			_localTime = now.time;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set serverTime(value:String):void
		{
			// parse date string into date object
			var day:Number = Number(value.substr(0, 2));
			var month:Number = Number(value.substr(2, 2)) - 1;
			var year:Number = Number(value.substr(4, 4));
			var hour:Number = Number(value.substr(9, 2));
			var minute:Number = Number(value.substr(12, 2));
			var second:Number = Number(value.substr(15, 2));
			var serverDate:Date = new Date(year, month, day, hour, minute, second);
			// compare server date/time to local date/time
			// compute an offset between the two
			var localDate:Date = new Date();
			_localTime = localDate.getTime();
			_serverToLocalDateOffset = serverDate.getTime() - _localTime;
			
			// make sure the timer exists
			// if not create it
			// this timer runs on an interval of 1 second
			if (_tmr == null)
			{
				_tmr = new Timer(1000);
				_tmr.addEventListener(TimerEvent.TIMER, _timerInterval);
			}
			
			trace('ModelLocator: Setting server time: value: ' + value + '; result: ' + serverTime);
			
			// restart the timer
			_tmr.reset();
			_tmr.start();
		}
		
		public function get serverTime():String
		{
			// return a string that rperesents the server date/time
			var date:Date = serverDate;
			return date.date + '-' + date.month + '-' + date.getFullYear() + ' ' + date.hours + ':' + zeroPad(date.minutes.toString()) + ':' + zeroPad(date.seconds.toString());
			
			function zeroPad(string:String):String
			{
				if (string.length < 2) string = '0' + string;
				return string;
			}
		}
		
		public function get serverDate():Date
		{
			// use current local date/time to calculate the server date/time
			accountForLocalTimeDifference();
			var now:Date = new Date();
			var nowTime:Number = now.getTime();
			var newServerDate:Date = new Date();
			newServerDate.setTime(nowTime + _serverToLocalDateOffset);
			return newServerDate;
		}
		
		public function get actionAllStarsEvents():ActionAllStarsEventCollection
		{
			return _actionAllStarEvents;
		}
		
		public function set actionAllStarsEvents(value:ActionAllStarsEventCollection):void
		{
			trace('ModelLocator: Setting action allstars events.');
			_actionAllStarEvents = value;
			dispatchEvent(new Event(EVENTS_UPDATE));
		}
		
		public function get stores():Object
		{
			return _stores;
		}
		public function set stores(value:Object):void
		{
			_stores = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function _timerInterval(e:TimerEvent):void
		{
			accountForLocalTimeDifference();
		}
	}
}