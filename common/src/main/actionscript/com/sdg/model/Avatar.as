package com.sdg.model
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.events.AvatarApparelEvent;
	import com.sdg.events.AvatarUpdateEvent;
	import com.sdg.events.InventoryListEvent;
	import com.sdg.manager.LevelManager;
	import com.sdg.utils.Constants;
	import com.sdg.utils.HairUtil;
	import com.sdg.utils.ItemUtil;
	import com.sdg.utils.PreviewUtil;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class Avatar extends SdgItem implements ILayeredImageItem
	{
		public static const POINTS_UPDATE:String = 'avatar points update';
		public static const POINTS_TO_SHOW_UPDATE:String = 'avatar to show update';
		public static const FAVORITE_TEAMS_CHANGED:String = 'favorite teams changed';
		public static const LEASHED_PET_UPDATE:String = 'leashed pet update';
		public static const EVENT_LOCAL_AVATAR_XML_DONE_LOADING:String = 'event local avatar login xml done';
		
		public static const AVAILABLE_STATUS:uint = 0;
		public static const IDLE_STATUS:uint = 1;
		public static const AWAY_STATUS:uint = 2;
		
		public static const ULTRA_SAFE_CHAT:uint = 0;
		public static const SAFE_CHAT:uint = 1;
		
		public static const NEWSLETTER_OPT_OUT:uint = 0;
		public static const NEWSLETTER_OPT_IN:uint = 1;
		
		public static const APPAREL_LENGTH:int = 13;
		
		public static const MALE:uint = 1;
		public static const FEMALE:uint = 2;
		
		public var userId:int;
		protected var _points:uint;
		protected var _pointsToShow:uint;
		public var gender:int;
		public var purchaseStatus:int;
		public var privateRoom:String;
		public var apparel:ArrayCollection = new ArrayCollection(new Array(APPAREL_LENGTH));
		public var apparelList:Object = new Object();
		public var statusId:uint;
		public var warned:Boolean;
		public var banned:Boolean;
		public var membershipStatus:uint;
		public var chatModeStatus:uint;
		public var newsletterOptionStatus:uint;
		public var background:InventoryItem;
		public var isPlaying:Boolean;
		public var isLegacy:Boolean;
		public var approved:uint;
		
		private var _currentRewards:Array;
		private var _level:uint;
		private var _levelName:String;
		private var _subLevel:uint;
		private var _subLevelName:String;
		protected var _currency:uint;
		protected var _currencyToShow:uint;
		protected var _isRewardsSynced:Boolean = true;
		private var _equippedBadge:String;
		private var _roomId:String;
		private var _badgeCount:int;
		protected var _xpGamer:int;
		protected var _xpGuru:int;
		protected var _xpCollector:int;
		protected var _joinDate:Date;
		protected var _homeTurfValue:int;
		protected var _favoriteTeams:Array;
		protected var _favoriteLeagueId:uint;
		protected var _equippedBadgeId:uint;
		protected var _equippedBadgeLevelId:uint;
		protected var _equippedBadgeLevelIndex:uint;
		protected var _updateTokens:Array;
		
		protected var _leashedPetInventoryId:uint;
		protected var _leashedPetItemId:uint;
		
		// Client-Side Vars for Turf UI
		protected var _turfAccess:uint;
		protected var _partyMode:uint;
		
		private static var _globalUpdateTokens:Array = [];
		
		// Han wants all the rest calls to only be in one XML.
		// since this is unpredictable keep it in one place.
		// an event is dispatched off the local avatar when this is done loading.
		private var _localAvatarLogInXML:XML = null;;
		
		public function Avatar()
		{
			_favoriteTeams = [];
			_favoriteLeagueId = League.MLB_ID;
			_updateTokens = [];
			
			_turfAccess = 0;
			_partyMode = 0;
			_badgeCount = 0;
			
			super();
			
			// default to 1 instead of 0
			updateLevelStatus();
		}

		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public static function GetUniqueUpdateToken(requestingObject:Object):uint
		{
			// Determine if an update token already exists
			// for this requesting object.
			var globalTokens:Array = _globalUpdateTokens;
			var index:int = globalTokens.indexOf(requestingObject);
			if (index > -1) return index;
			
			// Create a new update token for this requesting object.
			return _globalUpdateTokens.push(requestingObject) - 1;
		}
		
		public static function RemoveUniqueUpdateToken(requestingObject:Object):void
		{
			// Remove an update token for the given
			// requesting object.
			//
			// IMPORTANT
			//
			// If you get a unique update token
			// always remove it when you are done.
			var index:int = _globalUpdateTokens.indexOf(requestingObject);
			if (index > -1) _globalUpdateTokens.splice(index, 1);
		}
		
		public function getInventoryListById(id:uint):ArrayCollection
		{
			if (apparelList[id] != null) return apparelList[id];
			
			apparelList[id] = new ArrayCollection();
			return apparelList[id];
		}
		
		public function setApparel(item:InventoryItem):void
		{
			if (item.itemTypeId == PreviewUtil.BACKGROUNDS)
				background = item;
			else
			{
				var itemLayerId:int = item.getLayerId();
				if (itemLayerId < 0) return;
				
				var oldItem:InventoryItem = apparel.getItemAt(itemLayerId) as InventoryItem;
				
				apparel.setItemAt(item,itemLayerId);
			}
			
			// Set flag.
			needsUpdate()
			
			// Dispatch apparel change event.
			dispatchEvent(new AvatarApparelEvent(this, AvatarApparelEvent.AVATAR_APPAREL_CHANGED, oldItem, item));
		}
		
		public function removeApparel(layerId:int):void
		{
			// Get refrence to item being removed.
			var oldItem:InventoryItem = apparel[layerId] as InventoryItem;
			
			// Remove item.
			apparel[layerId] = null;
			
			// Set flag.
			needsUpdate()
			
			// Dispatch apparel change event.
			dispatchEvent(new AvatarApparelEvent(this, AvatarApparelEvent.AVATAR_APPAREL_CHANGED, oldItem, null));
		}
		
		public function hasApparel():Boolean
		{
			for each (var item:Object in this.apparel)
			{
				if (item is InventoryItem)
					return true;
			}
			
			return false;
		}
		
		public function getLayeredImageUrlArray():Array
		{
			var items:Array = apparel.toArray();
			return getItemsImageUrlArray(items);
		}
		
		public function getLayeredImageUrlArrayWithNewItems(newItems:Array):Array
		{
			// Takes an array of preview items.
			// Returns image url array of preview images for the items as if the avatar was wearing those new items.
			var items:Array = apparel.toArray();
			var i:uint = 0;
			var len:uint = newItems.length;
			for (i; i < len; i++)
			{
				var newItem:IPreviewItem = newItems[i] as IPreviewItem;
				if (newItem == null) continue;
				
				items[PreviewUtil.getLayerId(newItem.itemTypeId)] = newItem;
			}
			
			return getItemsImageUrlArray(items);
		}
		
		/**
		 * Gets the type of headwear currently on this avatar (hat, helmlet, headband, visor, beanie)
		 * 
		 * @return itemTypeId of item or zero if there is none
		 */
		public function getHeadwearType():int
		{
			var item:InventoryItem = apparel.getItemAt(PreviewUtil.getLayerId(PreviewUtil.HAT)) as InventoryItem;
			
			return item == null ? 0 : item.itemTypeId;
		}
		
		public function getHairItemId():int
		{
			var item:InventoryItem = apparel.getItemAt(PreviewUtil.getLayerId(PreviewUtil.HAIR)) as InventoryItem;
			
			return item != null ? item.itemId : 0;
		}
		
		public function getSkinItemId():int
		{
			var item:InventoryItem = apparel.getItemAt(PreviewUtil.getLayerId(PreviewUtil.BODY)) as InventoryItem;
			
			return (item) ? item.itemId : 0;
		}
		
		public function removeAllApparel():void
		{
			apparel = new ArrayCollection(new Array(APPAREL_LENGTH));
		}
		
		public function setFavoriteTeam(team:Team, leagueId:uint):void
		{
			_favoriteTeams[leagueId] = team;
			
			needsUpdate();
			
			dispatchEvent(new Event(FAVORITE_TEAMS_CHANGED));
		}
		
		public function getFavoriteTeamId(leagueId:uint):uint
		{
			return _favoriteTeams[leagueId] ? _favoriteTeams[leagueId].teamId : 0;
		}
		
		public function getFavoriteTeam(leagueId:uint):Team
		{
			return _favoriteTeams[leagueId];
		}
		
		public function getDoesNeedUpdate(requestingObject:Object):Boolean
		{
			var updateToken:uint = Avatar.GetUniqueUpdateToken(requestingObject);
			return (_updateTokens[updateToken] != true);
		}
		
		public function setDoesNotNeedUpdate(requestingObject:Object):void
		{
			var updateToken:uint = Avatar.GetUniqueUpdateToken(requestingObject);
			_updateTokens[updateToken] = true;
		}
		
		// Get pet information immediately.
		public function isPetLeashed():Boolean
		{
			return _leashedPetInventoryId != 0;
		}
		
		public function loadInventoryList(itemTypeId:int, onComplete:Function = null, onFail:Function = null):void
		{
			var cairngorm:CairngormEventDispatcher = CairngormEventDispatcher.getInstance();
			cairngorm.addEventListener(InventoryListEvent.LIST_FAILED, onListFailed);
			cairngorm.addEventListener(InventoryListEvent.LIST_COMPLETED, onListComplete);
			cairngorm.dispatchEvent(new InventoryListEvent(avatarId, itemTypeId));
			
			function onListFailed(e:InventoryListEvent):void
			{
				// Make sure it is for the correct call.
				if (e.avatarId != avatarId || e.itemTypeId != itemTypeId) return;
				// Remove listeners.
				cairngorm.removeEventListener(InventoryListEvent.LIST_FAILED, onListFailed);
				cairngorm.removeEventListener(InventoryListEvent.LIST_COMPLETED, onListComplete);
				
				// Fail callback.
				if (onFail != null) onFail();
				onFail = null;
				cairngorm = null;
			}
			
			function onListComplete(e:InventoryListEvent):void
			{
				// Make sure it is for the correct call.
				if (e.avatarId != avatarId || e.itemTypeId != itemTypeId) return;
				// Remove listeners.
				cairngorm.removeEventListener(InventoryListEvent.LIST_FAILED, onListFailed);
				cairngorm.removeEventListener(InventoryListEvent.LIST_COMPLETED, onListComplete);
				
				// Complete callback.
				if (onComplete != null) onComplete();
				onComplete = null;
				cairngorm = null;
			}
		}
		
		public function decrementPetFoodCount(amount:int = 1):void
		{
			var petFoodList:ArrayCollection = getInventoryListById(ItemType.PET_FOOD);
			InventoryItem(petFoodList.getItemAt(0)).charges -= amount;
		}
		
		public function setPetFoodInventoryItem(petFood:InventoryItem):void
		{
			var petFoodList:ArrayCollection = getInventoryListById(ItemType.PET_FOOD);
			if  (petFoodList.length == 0)
			{
				petFoodList.addItem(petFood);
			}
			else
			{
				petFoodList.setItemAt(petFood, 0);
			}
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		protected function getItemsImageUrlArray(items:Array):Array
		{
			// Takes an array of InventoryItems.
			// Returns an array of image urls for those item previews.

			var urls:Array = [];
			
			var suit:IPreviewItem = items[PreviewUtil.getLayerId(PreviewUtil.SUITS)] as IPreviewItem;
			if (suit != null)
			{
				urls[PreviewUtil.getLayerId(suit.itemTypeId)] = ItemUtil.GetPreviewUrl(suit.itemId);
			}
			else
			{
				var i:int = 0;
				var len:int = items.length;
				var isSkateOutfit:Boolean = (getItemSetId(items) == Constants.APPAREL_SET_ID_SKATEBOARDING);
				var isMale:Boolean = (gender == 1) ? true : false;
				
				for (i; i < len; i++)
				{
					var item:IPreviewItem = items[i] as IPreviewItem;
					if (item == null) continue;
					
					// Get reference to item type id.
					var itemTypeId:int = item.itemTypeId;
					
					// Determine preview URL.
					var url:String;
					if (isSkateOutfit == true && isOutfitItemType(itemTypeId) == true)
					{
						// If the avatar is wearing the complete skateboard outfit and this item is one of the skate outfit items,
						// Use the skateboard outfit layer id.
						url = ItemUtil.GetPreviewUrl(item.itemId, isMale, 9100);
					}
					else
					{
						url = ItemUtil.GetPreviewUrl(item.itemId, isMale);
					}
					
					// Make sure there is a URL.
					if (url.length < 1) continue;
					
					// If this item is head wear, we need to determine the proper hat hair.
					if (itemTypeId == HeadWear.HAT || itemTypeId == HeadWear.VISOR || itemTypeId == HeadWear.HEADBAND || itemTypeId == HeadWear.HELMET || itemTypeId == HeadWear.BEANIE)
					{
						// Determine hat hair layer id.
						var layerId:int = HairUtil.GetHairLayerId(getHairItemId(), itemTypeId);
						
						// Modify the url for the hair layer.
						var currentHairUrl:String = urls[PreviewUtil.getLayerId(PreviewUtil.HAIR)] as String;
						if (currentHairUrl != null)
						{
							// Replace layerId.
							var a:int = currentHairUrl.indexOf('layerId=');
							var b:int = currentHairUrl.indexOf('&', a);
							var firstPart:String = currentHairUrl.substring(0, a);
							var secondPart:String = currentHairUrl.substr(b);
							var newHairUrl:String = firstPart + 'layerId=' + layerId.toString() + secondPart;
							urls[PreviewUtil.getLayerId(PreviewUtil.HAIR)] = newHairUrl;
						}
					}
					urls[PreviewUtil.getLayerId(itemTypeId)] = url;
				}
			}
			
			if(isPetLeashed())
			{
				urls[PreviewUtil.getLayerId(PreviewUtil.PETS)] = ItemUtil.GetPreviewUrl(_leashedPetItemId);
			}
			
			return urls;
			
			function isOutfitItemType(itemTypeId:uint):Boolean
			{
				if (itemTypeId == PreviewUtil.BODY || itemTypeId == PreviewUtil.SHOES || itemTypeId == PreviewUtil.PANTS || itemTypeId == PreviewUtil.SHIRTS)
				{
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		protected function commitRewardValues(rewards:Array):void
		{	
			for each (var reward:Reward in rewards)
			{
				switch (reward.rewardTypeId)
				{
					case Reward.CURRENCY:
						_isRewardsSynced = false;
						currency = reward.rewardValueTotal;
						break;
				
					case Reward.EXPERIENCE:
						_isRewardsSynced = false;
						points = reward.rewardValueTotal;
						break;
				
					case Reward.INVENTORY_ITEM:
						break;
				
					case Reward.LEVEL_UP:
						level = reward.rewardValueTotal;
						break;
					
					case Reward.ACHIEVEMENT:
						break;
						
					case Reward.SUBLEVEL_UP:
						break;
				}
			}
		}
		
		protected function getItemSetId(items:Array):int
		{
			// a 'set' currently consists of hat, shirt, pants and shoes
			var hat:InventoryItem = items[PreviewUtil.getLayerId(PreviewUtil.HAT)] as InventoryItem;
			var shirt:InventoryItem = items[PreviewUtil.getLayerId(PreviewUtil.SHIRTS)] as InventoryItem;
			var pants:InventoryItem = items[PreviewUtil.getLayerId(PreviewUtil.PANTS)] as InventoryItem;
			var shoes:InventoryItem = items[PreviewUtil.getLayerId(PreviewUtil.SHOES)] as InventoryItem;
			
			// make sure we are wearing all these items
			if (!hat || !shirt || !pants || !shoes)
				return 0;
			
			// if all items have the hat's itemSetId, then that is our itemSetId 
			var itemSetId:int = 0;
			if (hat.itemSetId == shirt.itemSetId &&
				hat.itemSetId == pants.itemSetId &&
				hat.itemSetId == shoes.itemSetId)
			{
				itemSetId = hat.itemSetId;
			}	
							
			return itemSetId;
		}
		
		protected function updateLevelStatus():void
		{
			var levelStatus:AvatarLevelStatus = LevelManager.GetAvatarLevelStatus(this);
			if (levelStatus == null) return;
			level = levelStatus.levelIndex;
			levelName = levelStatus.levelName;
			subLevel = levelStatus.subLevelIndex;
			subLevelName = levelStatus.subLevelName;
		}
		
		protected function needsUpdate():void
		{
			_updateTokens = [];
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function announceNewSubLevel(newLevel:uint):void
		{
			dispatchEvent(new AvatarUpdateEvent(AvatarUpdateEvent.SUBLEVEL_UPDATE,newLevel));
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function set localAvatarLogInXML(val:XML):void
		{
			_localAvatarLogInXML = val;
		}
		public function get localAvatarLogInXML():XML
		{
			return _localAvatarLogInXML;
		}

		//Gets the actual object based on this inventoryId this is so we can get previews and info.
		public function set leashedPetInventoryId(inventoryId:int):void
		{
			if (inventoryId == _leashedPetInventoryId) return;
			_leashedPetInventoryId = inventoryId;
			
			dispatchEvent(new Event(LEASHED_PET_UPDATE));
		}
		public function get leashedPetInventoryId():int
		{
			return _leashedPetInventoryId;
		}
		
		public function set leashedPetItemId(itemId:int):void
		{
			_leashedPetItemId = itemId;
		}
		public function get leashedPetItemId():int
		{
			return _leashedPetItemId;
		}
		
		public function set turfAccess(value:uint):void
		{
			_turfAccess = value;
		}
		
		public function get turfAccess():uint
		{
			return _turfAccess;
		}
		
		public function set partyMode(value:uint):void
		{
			_partyMode = value;
		}
		
		public function get partyMode():uint
		{
			return _partyMode;
		}
		
		override public function get id():uint
		{
			return avatarId;
		}
		
		public function get isFullyClothed():Boolean
		{
			var count:int = 0;
			for each (var item:Object in this.apparel)
			{
				if (item is InventoryItem)
					count++;
			}
			
			return count >= 7;
		}
		
		public function get currentRewards():Array
		{
			return _currentRewards;
		}
		
		public function set currentRewards(value:Array):void
		{
			if (value) commitRewardValues(value);
			_currentRewards = value;
		}
		
		public function set equippedBadge(value:String):void
		{
			// Parse values.
			var values:Array = value.split('|', 5);
			var id:uint = values[0];
			var name:String = values[1];
			var badgeLevelId:uint = values[2];
			var badgeLevelName:String = values[3];
			var badgeLevelIndex:uint = values[4];
			
			if (id == _equippedBadgeId && badgeLevelId == _equippedBadgeLevelId && badgeLevelIndex == _equippedBadgeLevelIndex) return;
			_equippedBadgeId = id;
			_equippedBadgeLevelId = badgeLevelId;
			_equippedBadgeLevelIndex = badgeLevelIndex;
			
			_equippedBadge = value;
			
			needsUpdate()
		}
		
		public function get equippedBadge():String
		{
			return _equippedBadge;
		}
		
		public function get equippedBadgeId():uint
		{
			return _equippedBadgeId;
		}
		
		public function get equippedBadgeLevelId():uint
		{
			return _equippedBadgeLevelId;
		}
		
		public function get equippedBadgeLevelIndex():uint
		{
			return _equippedBadgeLevelIndex;
		}
		
		public function get level():uint
		{
			return _level;
		}
		public function set level(value:uint):void
		{
			if (value == _level) return;
			_level = value;
			needsUpdate()
		}
		
		public function get levelName():String
		{
			var avatarLevel:AvatarLevel = ModelLocator.getInstance().avatarLevels[_level];
			_levelName = (avatarLevel) ? avatarLevel.levelName : "";
			return _levelName;
		}
		public function set levelName(value:String):void
		{
			_levelName = value;
		}
		
		public function get subLevelName():String
		{
			return _subLevelName;
		}
		public function set subLevelName(value:String):void
		{
			if (value == _subLevelName) return;
			_subLevelName = value;
			needsUpdate();
		}
		
		public function get isPremiumMember():Boolean
		{
			return (membershipStatus == MembershipStatus.PREMIUM);
		}
		
		override public function get propListString():String
		{
			var superPropString:String = super.propListString;
			var propString:String = 	'userId: ' + userId + '\n' +
										'points: ' + points + '\n' +
										'currency: ' + currency + '\n' +
										'gender: ' + gender + '\n' +
										'statusId: ' + statusId + '\n' +
										'membershipStatus: ' + membershipStatus + '\n';
			
			propString = superPropString + propString;
										
			return propString;
		}
		
		override public function get className():String
		{
			return 'Avatar';
		}
		
		public function get currentItemSetId():int
		{
			return getItemSetId(apparel.toArray());
		}
		
		public function get isWearingSkateboardingOutfit():Boolean
		{
			return currentItemSetId == Constants.APPAREL_SET_ID_SKATEBOARDING;
		}
		
		public function get isWearingHeadwear():Boolean
		{
			return getHeadwearType() != 0;
		}
		
		public function get isWearingGlasses():Boolean
		{
			return apparel[PreviewUtil.getLayerId(PreviewUtil.GLASSES)] is InventoryItem;
		}
		
		public function get isWearingSuits():Boolean
		{
			return apparel[PreviewUtil.getLayerId(PreviewUtil.SUITS)] is InventoryItem;
		}
		
		public function resetRewardSync():void
		{
			_isRewardsSynced = true;
			currencyToShow = _currency;
			pointsToShow = _points;
		}
		
		public function get currencyToShow():uint
		{
			return _currencyToShow;
		}
		
		private function set currencyToShow(value:uint):void
		{
			_currencyToShow = value;
			
			dispatchEvent(new AvatarUpdateEvent(AvatarUpdateEvent.TOKENS_TO_SHOW_UPDATE));
		}
		
		public function set currency(value:uint):void
		{
			_currency = value;
			needsUpdate();
			dispatchEvent(new AvatarUpdateEvent(AvatarUpdateEvent.TOKENS_UPDATE));
			
			if (_isRewardsSynced == true)
			{
				currencyToShow = _currency;
			}
		}
		
		public function get currency():uint
		{
			return _currency;
		}
		
		public function get pointsToShow():uint
		{
			return _pointsToShow;
		}
		
		private function set pointsToShow(value:uint):void
		{
			_pointsToShow = value;
			
			dispatchEvent(new Event(POINTS_TO_SHOW_UPDATE));
		}
		
		public function get points():uint
		{
			return _points;
		}
		
		public function set points(value:uint):void
		{
			// Added value versus points check due to update race condition - never lower XP points
			var pointsSet:Boolean = false;
			if (value > _points)
			{
				_points = value;
				needsUpdate();
				pointsSet = true;
			}
			// needs to be set before updateLevelStatus!
			if (_isRewardsSynced == true)
			{
				pointsToShow = _points;
			}
			if (pointsSet)
			{
				updateLevelStatus();
				dispatchEvent(new Event(POINTS_UPDATE));
			}
			
		}
		
		public function get subLevel():int
		{
			return _subLevel;
		}
		public function set subLevel(value:int):void
		{
			if (value == _subLevel) return;
			_subLevel = value;
			needsUpdate()
			announceNewSubLevel(_subLevel);
		}
		
		public function get xpGamer():int
		{
			return _xpGamer;
		}
		public function set xpGamer(value:int):void
		{
			if (value == _xpGamer) return;
			_xpGamer = value;
			needsUpdate()
		}
		
		public function get xpGuru():int
		{
			return _xpGuru;
		}
		public function set xpGuru(value:int):void
		{
			if (value == _xpGuru) return;
			_xpGuru = value;
			needsUpdate()
		}
		
		public function get xpCollector():int
		{
			return _xpCollector;
		}
		public function set xpCollector(value:int):void
		{
			if (value == _xpCollector) return;
			_xpCollector = value;
			needsUpdate()
		}
		
		public function get homeTurfValue():int
		{
			return _homeTurfValue;
		}
		public function set homeTurfValue(value:int):void
		{
			_homeTurfValue = value;
		}
		
		public function get joinDate():Date
		{
			return _joinDate;
		}
		public function set joinDate(value:Date):void
		{
			_joinDate = value;
		}
		
		public function get favoriteLeagueId():uint
		{
			return _favoriteLeagueId;
		}
		public function set favoriteLeagueId(value:uint):void
		{
			_favoriteLeagueId = value;
			
			dispatchEvent(new Event("favorite teams changed"));
		}
		
		public function get favoriteTeamId():int
		{
			return _favoriteTeams[_favoriteLeagueId] ? _favoriteTeams[_favoriteLeagueId].teamId : 0;
		}
		
		public function get favoriteTeam():Team
		{
			return _favoriteTeams[_favoriteLeagueId];
		}
		
		public function get favoriteTeams():Array
		{
			return _favoriteTeams;
		}
		
		public function get roomId():String
		{
			return _roomId;
		}
		public function set roomId(value:String):void
		{
			_roomId = value;
		}
		
		public function get badgeCount():int
		{
			return _badgeCount;
		}
		public function set badgeCount(value:int):void
		{
			_badgeCount = value;
		}
		
		public function get petFoodCount():int
		{
			var petFoodList:ArrayCollection = getInventoryListById(ItemType.PET_FOOD);
			return (petFoodList.length < 1) ? 0 : InventoryItem(petFoodList.getItemAt(0)).charges;
		}
		
		public function get petFoodInventoryId():int
		{
			var petFoodList:ArrayCollection = getInventoryListById(ItemType.PET_FOOD);
			return (petFoodList.length < 1) ? -1 : InventoryItem(petFoodList.getItemAt(0)).id;
		}
		
	}
}
