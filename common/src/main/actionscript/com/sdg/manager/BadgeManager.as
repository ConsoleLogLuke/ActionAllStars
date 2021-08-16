package com.sdg.manager
{
	import com.sdg.components.dialog.BadgeEarnedDialog;
	import com.sdg.control.HudController;
	import com.sdg.events.SocketEvent;
	import com.sdg.model.Badge;
	import com.sdg.model.BadgeCategory;
	import com.sdg.model.BadgeCategoryCollection;
	import com.sdg.model.BadgeCollection;
	import com.sdg.model.BadgeLevel;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Reward;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.MainUtil;
	import com.sdg.utils.ObjectUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class BadgeManager extends EventDispatcher
	{
		public static const BADGE_LOAD_ERROR:String = 'badge load error';
		public static const BADGE_LOAD_COMPLETE:String = 'badge load complete';
		public static const BADGE_LOAD_PROGRESS:String = 'badge load progress';
		
		protected static var _instance:BadgeManager;
		
		protected static var _badgesAvailable:Boolean;
		protected static var _badgeDataLoading:Boolean;
		protected static var _badgeDataBytesLoaded:uint;
		protected static var _badgeDataBytesTotal:uint;
		protected static var _allBadges:BadgeCollection;
		protected static var _badgeCategories:BadgeCategoryCollection;
		protected static var _avatarBadgeData:Array = [];
		
		public function BadgeManager()
		{
			if (_instance == null)
			{
				super();
			}
			else
			{
				throw new Error("BadgeManager is a singleton class. Use 'getInstance()' to access the instance.");
			}
		}
		
		public static function GetInstance():BadgeManager
		{
			if (_instance == null)
			{
				_instance = new BadgeManager();
				init();
			}
			return _instance;
		}
		
		public static function badgeAwardTester(testBadgeLevelId:uint):void
		{
			awardBadge(testBadgeLevelId);
		}
		
		protected static function init():void
		{
			// Listen for badge awarded socket events.
			SocketClient.getInstance().addEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function LoadBadges():void
		{
			trace("LoadBadges() Called");
			
			// Load badge list XML.
			
			var url:String = Environment.getApplicationUrl() + '/test/badge/list';
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			// Reset integers.
			_badgeDataBytesLoaded = 0;
			_badgeDataBytesTotal = 1;
			
			// Set flag.
			_badgeDataLoading = true;
			
			// Begin loading.
			loader.load(request);
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				
				// Set flag.
				_badgeDataLoading = false;
				
				// Dispatch event.
				Instance.dispatchEvent(new IOErrorEvent(BADGE_LOAD_ERROR, e.bubbles, e.cancelable, e.text));
			}
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				
				// Parse data into an XML object.
				var xml:XML = new XML(loader.data);
				
				// Parse XML into badge categories.
				var badgeCategoryList:XMLList = xml.child('badgeCategories');
				_badgeCategories = BadgeCategory.BadgeCategoryCollectionFromXML(badgeCategoryList);
				
				// Parse XML into a badge collection.
				var badgeList:XMLList = xml.child('allBadges');
				_allBadges = Badge.BadgeCollectionFromXML(badgeList);
				_allBadges.sortAlphabetically();
				
				// Set flag.
				_badgeDataLoading = false;
				_badgesAvailable = true;
				
				// Dispatch complete event.
				Instance.dispatchEvent(new Event(BADGE_LOAD_COMPLETE, e.bubbles, e.cancelable));
			}
			
			function onProgress(e:ProgressEvent):void
			{
				// Set integers.
				_badgeDataBytesTotal = e.bytesTotal;
				_badgeDataBytesLoaded = e.bytesLoaded;
				
				// Dispatch progress event.
				Instance.dispatchEvent(new ProgressEvent(BADGE_LOAD_PROGRESS, e.bubbles, e.cancelable, e.bytesLoaded, e.bytesTotal));
			}
		}
		
		public static function GetBadgesByCategory(categoryId:uint):BadgeCollection
		{
			// Return a collection of badges with the specified category id.
			
			var i:uint = 0;
			var len:uint = _allBadges.length;
			var badges:BadgeCollection = new BadgeCollection();
			for (i; i < len; i++)
			{
				var badge:Badge = _allBadges.getAt(i);
				if (badge.badgeCategoryId == categoryId) badges.push(badge);
			}
			
			return badges;
		}
		
		public static function AvatarBadgesAvailable(avatarId:uint):Boolean
		{
			// Check if avatar badge data is available for the specified avatar.
			return (_avatarBadgeData[avatarId] != null);
		}
		
		public static function LoadAvatarBadges(avatarId:uint):void
		{
			// Load badge data for specified avatar.
			var url:String = Environment.getApplicationUrl() + '/test/badge/avatar?avatarId=' + avatarId.toString();
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
				
				// Parse loaded data into XML.
				var xml:XML = new XML(loader.data);
				
				// Parse out badge id's.
				var i:uint = 0;
				var badgeIds:Array = [];
				while (xml.avatarBadges.badge[i] != null)
				{
					var badgeXML:XML = xml.avatarBadges.badge[i];
					var badgeId:uint = badgeXML.@id;
					
					// Parse out badge levels.
					var i2:uint = 0;
					var levelIds:Array = [];
					while (badgeXML.level[i2] != null)
					{
						var levelXML:XML = badgeXML.level[i2];
						var levelId:uint = levelXML.@id;
						var dateAcquired:Date = new Date(levelXML.@dateAcquired);
						
						levelIds[levelId] = dateAcquired;
						
						i2++;
					}
					
					badgeIds[badgeId] = levelIds;
					
					i++;
				}
				
				// Store the badge data.
				_avatarBadgeData[avatarId] = badgeIds;
				
				// Dispatch complete event.
				Instance.dispatchEvent(new Event(BADGE_LOAD_COMPLETE));
			}
		}
		
		public static function DoesAvatarOwnBadgeLevel(avatarId:uint, badgeId:uint, badgeLevelId:uint):Boolean
		{
			var badgeIds:Array = _avatarBadgeData[avatarId] as Array;
			if (badgeIds == null) return false;
			
			var levelIds:Array = badgeIds[badgeId] as Array;
			if (levelIds == null) return false;
			
			var avatarOwnsBadge:Boolean = (levelIds[badgeLevelId] != null);
			
			return avatarOwnsBadge;
		}
		
		public static function DoesAvatarOwnBadge(avatarId:uint, badgeId:uint):Boolean
		{
			var badgeIds:Array = _avatarBadgeData[avatarId] as Array;
			if (badgeIds == null) return false;
			
			var levelIds:Array = badgeIds[badgeId] as Array;
			if (levelIds == null) return false;
			
			return true;
		}
		
		public static function GetAvatarBadgeLevelDateAcquired(avatarId:uint, badgeId:uint, badgeLevelId:uint):Date
		{
			var badges:Array = _avatarBadgeData[avatarId] as Array;
			if (!badges) return null;
			
			var badgeLevels:Array = badges[badgeId] as Array;
			if (!badgeLevels) return null;
			
			var dateAcquired:Date = badgeLevels[badgeLevelId] as Date;
			
			return dateAcquired;
		}
		
		protected static function awardBadge(badgeLevelId:uint):void
		{
			// Make sure badge data is loaded.
			if (_badgesAvailable)
			{
				// Badge data is available.
				continueAward();
			}
			else
			{
				// Badge data is NOT avaialable.
				// Make sure we are loading it.
				Instance.addEventListener(BADGE_LOAD_COMPLETE, onLoadComplete);
				if (_badgeDataLoading != true) LoadBadges();
			}
			
			function onLoadComplete(e:Event):void
			{
				// Remove Listener
				Instance.removeEventListener(BADGE_LOAD_COMPLETE, onLoadComplete);
				
				// Badge data is available.
				continueAward();
			}
			
			function continueAward():void
			{
				
				// Get badge level instance.
				var i:uint = 0;
				var len:uint = _allBadges.length;
				var badgeLevel:BadgeLevel;
				var parentBadge:Badge;
				for (i; i < len; i++)
				{
					var badge:Badge = _allBadges.getAt(i);
					var level:BadgeLevel = badge.levels.getFromId(badgeLevelId);
					if (level != null)
					{
						badgeLevel = level;
						parentBadge = badge;
						i = len;
						continue;
					}
				}
				
				if (badgeLevel != null)
				{	
					// Store the level id and badge id for the user avatar.
					// This denotes that the user has this badge and badge level.
					storeUserBadge(parentBadge.id, badgeLevel.id);
					
					// With the badge and the badge level, throw up the dialog
					var useMovie:Boolean = dialogHasMovie(badgeLevel.id);
					MainUtil.showDialog(BadgeEarnedDialog, {badgeLevel:badgeLevel, badge:parentBadge,useMovie:useMovie});
					
					// Display Local Message
					var msg:String = "You've earned a badge!\n"+badge.name.toUpperCase()+":\n"+badgeLevel.name;
					HudController.getInstance().addNewBadgeMessage(parentBadge.id, badgeLevel.levelIndex-1, msg);
					
				}
			}
		}
		
		protected static function storeUserBadge(badgeId:uint, badgeLevelId:uint):void
		{
			// Store the level id and badge id for the user avatar.
			// This denotes that the user has this badge and badge level.
			var avatarId:uint = ModelLocator.getInstance().avatar.id;
			
			// Make sure badges for the user avatar have been loaded.
			if (AvatarBadgesAvailable(avatarId) == false)
			{
				// Load avatar badges.
				trace('Trying to store badge for user avatar but avatar badge list is not available.\nLoading avatar badge list...');
				Instance.addEventListener(BADGE_LOAD_COMPLETE, onBadgeLoadComplete);
				LoadAvatarBadges(avatarId);
				
				function onBadgeLoadComplete(e:Event):void
				{
					if (AvatarBadgesAvailable(avatarId))
					{
						trace('Avatar badge list loaded');
						Instance.removeEventListener(BADGE_LOAD_COMPLETE, onBadgeLoadComplete);
						continueStore();
					}
				}
			}
			else
			{
				continueStore();
			}
			
			function continueStore():void
			{
				trace('Storing badge for user avatar...');
				trace('\tavatarId: ' + avatarId + '\n\tbadgeId: ' + badgeId + '\n\tbadgeLevelId: ' + badgeLevelId);
				var dateAcquired:Date = new Date();
				var badgeIds:Array = (_avatarBadgeData[avatarId]) ? _avatarBadgeData[avatarId] : [];
				var badgeLevelIds:Array = (badgeIds[badgeId]) ? badgeIds[badgeId] : [];
				badgeLevelIds[badgeLevelId] = dateAcquired;
				badgeIds[badgeId] = badgeLevelIds;
				_avatarBadgeData[avatarId] = badgeIds;
				trace('Stored badge successfuly');
			}
		}
		
		private static function dialogHasMovie(badgeLevelId:uint):Boolean
		{
			var movieBadgeLevels:Array = new Array(89,90,91,92);
			if (movieBadgeLevels.indexOf(badgeLevelId) == -1)
			{
				return false;
			}
			
			return true;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public static function get Instance():BadgeManager
		{
			return GetInstance();
		}
		
		public static function get BadgesAvailable():Boolean
		{
			return _badgesAvailable;
		}
		
		public static function get AllBadges():BadgeCollection
		{
			return _allBadges;
		}
		
		public static function get BadgeCategories():BadgeCategoryCollection
		{
			return _badgeCategories;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private static function onPluginEvent(e:SocketEvent):void
		{
			var params:Object = e.params;
			var action:String = params.action;
			
			// Check for Badge Reward
			if (e.params.reward)
			{
				var	rewardXMLList:XMLList = XML(e.params.reward).children();
					
				for each (var rewardXML:XML in rewardXMLList)
				{
					var r:Reward = ObjectUtil.mapXMLNodeValues(new Reward(),rewardXML);
					if (r.rewardTypeId == Reward.BADGE)
					{
						awardBadge(r.rewardValue);
					}
				}
			}
			
		}
		
	}
}