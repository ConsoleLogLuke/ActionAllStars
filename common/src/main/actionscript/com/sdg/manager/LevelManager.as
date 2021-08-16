package com.sdg.manager
{
	import com.sdg.business.resource.RemoteResourceMap;
	import com.sdg.business.resource.SdgResourceLocator;
	import com.sdg.components.dialog.LevelEarnedDialog;
	import com.sdg.events.SocketEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarLevelStatus;
	import com.sdg.model.Level;
	import com.sdg.model.LevelCollection;
	import com.sdg.model.LevelMessage;
	import com.sdg.model.SubLevel;
	import com.sdg.model.SubLevelCollection;
	import com.sdg.net.Environment;
	import com.sdg.utils.MainUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class LevelManager extends EventDispatcher
	{
		public static const LEVEL_DATA_AVAILABLE:String = 'level data available';
		
		protected static var _instance:LevelManager;
		
		protected static var _levelDataAvailable:Boolean;
		protected static var _levels:LevelCollection;
		protected static var _subLevels:SubLevelCollection;
		
		public function LevelManager(target:IEventDispatcher=null)
		{
			if (_instance == null)
			{
				super();
			}
			else
			{
				throw new Error("LevelManager is a singleton class. Use 'getInstance()' to access the instance.");
			}
		}
		
		public static function GetInstance():LevelManager
		{
			if (_instance == null) _instance = new LevelManager();
			return _instance;
		}
		
		protected static function init():void
		{
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function LoadLevelData():void
		{
			var url:String = Environment.getApplicationUrl() + '/test/level/list';
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Parse the loaded data into xml.
				var xml:XML = new XML(loader.data);
				
				// Parse levels out of the XML.
				_levels = Level.LevelCollectionFromXML(xml.child('levels'));
				
				// Index sub levels.
				indexSubLevels();
				
				// Set flag.
				_levelDataAvailable = true;
				
				// Dispatch complete event.
				Instance.dispatchEvent(new Event(LEVEL_DATA_AVAILABLE));
			}
		}
		
		public static function GetAvatarLevelStatus(avatar:Avatar):AvatarLevelStatus
		{
			// Make sure level data is available.
			if (!_levelDataAvailable) return null;
			if (!_subLevels) return null;
			
			var currentXp:uint = (avatar.pointsToShow) ? avatar.pointsToShow : 0;
			
			var currentLevel:Level;
			var currentSubLevel:SubLevel;
			var nextLevelPoints:uint = 0;
			
			// Determine sub level.
			var i:int = _subLevels.length - 1;
			for (i; i > -1; i--)
			{
				var subLevel:SubLevel = _subLevels.getAt(i);
				if (!subLevel) continue;
				
				if (subLevel.pointsToLevel <= currentXp)
				{
					currentSubLevel = subLevel;
					var nextSubLevel:SubLevel = _subLevels.getAt(i + 1);
					nextLevelPoints = (nextSubLevel != null) ? nextSubLevel.pointsToLevel : (currentXp - currentSubLevel.pointsToLevel / 2);
					break;
				}
			}
			
			// Make sure we have a current sub level.
			if (!currentSubLevel) return null;
			
			// Determine level.
			currentLevel = getLevelFromSubLevelId(currentSubLevel.id);
			if (!currentLevel) return null;
			
			return new AvatarLevelStatus(avatar.id, currentLevel.id, currentLevel.name, currentLevel.levelColor, currentSubLevel.number, currentSubLevel.name, currentXp, currentSubLevel.pointsToLevel, nextLevelPoints);
		}
		
		public static function GetAvatarLevelStatusFromPoints(avatar:Avatar, points:uint):AvatarLevelStatus
		{
			// Make sure level data is available.
			if (!_levelDataAvailable) return null;
			if (!_subLevels) return null;
			
			var currentXp:uint = points ? points : 0;
			
			var currentLevel:Level;
			var currentSubLevel:SubLevel;
			var nextLevelPoints:uint = 0;
			
			// Determine sub level.
			var i:int = _subLevels.length - 1;
			for (i; i > -1; i--)
			{
				var subLevel:SubLevel = _subLevels.getAt(i);
				if (!subLevel) continue;
				
				if (subLevel.pointsToLevel <= currentXp)
				{
					currentSubLevel = subLevel;
					var nextSubLevel:SubLevel = _subLevels.getAt(i + 1);
					nextLevelPoints = (nextSubLevel != null) ? nextSubLevel.pointsToLevel : (currentXp - currentSubLevel.pointsToLevel / 2);
					break;
				}
			}
			
			// Make sure we have a current sub level.
			if (!currentSubLevel) return null;
			
			// Determine level.
			currentLevel = getLevelFromSubLevelId(currentSubLevel.id);
			if (!currentLevel) return null;
			
			return new AvatarLevelStatus(avatar.id, currentLevel.id, currentLevel.name, currentLevel.levelColor, currentSubLevel.number, currentSubLevel.name, currentXp, currentSubLevel.pointsToLevel, nextLevelPoints);
		}
		
		public static function isSubLevelNewRank(subLevel:int):Boolean
		{
			var rank:int = getLevelFromSubLevelId(subLevel).id;
			var prevRank:int = getLevelFromSubLevelId(subLevel - 1).id;
			
			if (rank > prevRank)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		protected static function indexSubLevels():void
		{
			//Store sub levels in a collection in order of points to level.
			var i:uint = 0;
			var len:uint = _levels.length;
			var subLevels:SubLevelCollection = new SubLevelCollection();
			for (i; i < len; i++)
			{
				var level:Level = _levels.getAt(i);
				var i2:uint = 0;
				var len2:uint = level.subLevels.length;
				for (i2; i2 < len2; i2++)
				{
					var subLevel:SubLevel = level.subLevels.getAt(i2);
					subLevels.push(subLevel);
				}
			}
			
			// Sort sub levels by points to level.
			subLevels.sortByPointsToLevel();
			
			_subLevels = subLevels;
		}
		
		protected static function getLevelFromSubLevelId(subLevelId:uint):Level
		{
			var i:uint = 0;
			var len:uint = _levels.length;
			for (i; i < len; i++)
			{
				var subLevel:SubLevel = _levels.getAt(i).subLevels.getFromId(subLevelId);
				if (subLevel) return _levels.getAt(i);
			}
			
			return null;
		}
		
		protected static function traceSubLevels():void
		{
			trace('SUB LEVELS:\n====================');
			var i:uint = 0;
			var len:uint = _subLevels.length;
			for (i ; i < len; i++)
			{
				var subLevel:SubLevel = _subLevels.getAt(i);
				trace('\t(' + subLevel.number + ') ' + subLevel.pointsToLevel);
			}
			
			trace('====================');
		}
		
		public static function awardLevel(levelId:uint):void
		{
			var imageLoader:Loader = new Loader();
			var gridLoader:Loader = new Loader();
			var image:DisplayObject = new Sprite() as DisplayObject;
			var grid:DisplayObject = new Sprite() as DisplayObject;
			var msgText:LevelMessage = null;
			
			var resourceLocator:SdgResourceLocator = SdgResourceLocator.getInstance();
			var resourceMap:RemoteResourceMap = new RemoteResourceMap();
			resourceMap.addEventListener(Event.COMPLETE, onXMLLoadComplete);
			//resourceMap.addEventListener(Event., onXMLLoadComplete);
			resourceMap.setResource("levelMessaging", resourceLocator.getLevelMessage(levelId));
			resourceMap.load();
			
			function onXMLLoadComplete(e:Event):void
			{
				// Remove Listener
				resourceMap.removeEventListener(Event.COMPLETE, onXMLLoadComplete);
				
				msgText = LevelMessage(resourceMap.getContent("levelMessaging"));
				
				loadImage();
			}
			
			function loadImage():void
			{
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onImageLoadComplete);
				imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
				imageLoader.load(new URLRequest(Environment.getAssetUrl()+"/test/gameSwf/gameId/71/gameFile/"+msgText.url));
			}
			
			function onImageLoadComplete(e:Event):void
			{
				e.currentTarget.removeEventListener(Event.COMPLETE, onImageLoadComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
			
				try
				{
					image = DisplayObject(e.currentTarget.content);
				}
				catch(e:Error)
				{
					trace("Error: " + e.message);
				}
				
				// Image has been loaded, so continue
				loadGrid();
			}
			
			function loadGrid():void
			{
				gridLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onGridLoadComplete);
				gridLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onGridIOError);
				gridLoader.load(new URLRequest(Environment.getAssetUrl()+"/test/gameSwf/gameId/71/gameFile/popUp_gridTexture.swf"));
			}
			
			function onGridLoadComplete(e:Event):void
			{
				e.currentTarget.removeEventListener(Event.COMPLETE, onGridLoadComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onGridIOError);
			
				try
				{
					grid = DisplayObject(e.currentTarget.content);
				}
				catch(e:Error)
				{
					trace("Error: " + e.message);
				}
				
				showAward();
			}
			
			function showAward():void
			{
				MainUtil.showDialog(LevelEarnedDialog, {level:levelId, msg:msgText, image:image, grid:grid});

				// Display Local Message
//				var msg:String = "You've earned a badge!\n"+badge.name.toUpperCase()+":\n"+badgeLevel.name;
//				HudController.getInstance().addNewBadgeMessage(parentBadge.id, badgeLevel.levelIndex-1, msg);
			}
			
			function onImageIOError(e:IOErrorEvent):void
			{
				e.currentTarget.removeEventListener(Event.COMPLETE, onImageLoadComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
				
				trace("LevelManager.onIOError: "+e.text);
			}
			
			function onGridIOError(e:IOErrorEvent):void
			{
				e.currentTarget.removeEventListener(Event.COMPLETE, onGridLoadComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onGridIOError);
				
				trace("LevelManager.onIOError: "+e.text);
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public static function get Instance():LevelManager
		{
			return GetInstance();
		}
		
		public static function get LevelDataAvailable():Boolean
		{
			return _levelDataAvailable;
		}
		
	}
}