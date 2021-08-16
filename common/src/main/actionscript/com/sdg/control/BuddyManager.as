package com.sdg.control
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.controls.SdgAlert;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.BuddyListEvent;
	import com.sdg.events.PartyListEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.factory.BuddyFactory;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.Buddy;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.NotificationIcon;
	import com.sdg.model.PartyBuddy;
	import com.sdg.model.Server;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.Constants;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class BuddyManager extends EventDispatcher
	{
		public static const MAX_BUDDIES:uint = 100;	
		
		public static const BUDDY_REQUESTED:int = 1;
		public static const BUDDY_REJECTED:int = 2;
		public static const BUDDY_CONFIRMED:int = 3;
		public static const BUDDY_REQUEST_RECEIVED:int = 4;
		public static const BUDDY_REQUEST_REJECTED:int = 5;
		public static const BUDDY_REQUEST_RECEIVED_REFER_FRIEND:int = 6;

		// private member fields
		private static var _instance:BuddyManager;
		private static var _createdFromStart:Boolean = false;
		private var _avatar:Avatar = ModelLocator.getInstance().avatar;
		private var _buddies:Object;
		private var _buddyCollection:ArrayCollection;
		private var _needsRemoval:Object = new Object();
		private var _partyCollection:ArrayCollection;
		
		/**
		 * Constructor.
		 */
		public function BuddyManager()
		{
			if (_instance || !_createdFromStart)
				throw new Error("BuddyManager is a singleton class. Use 'BuddyManager.start()' to begin buddy managament");
				
			SocketClient.getInstance().addEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
			getBuddyListFromServer();
		}
		
		/**
		 * Starts the BuddyMananger - creates the manager and starts listening for buddy events
		 */
		public static function start():void
		{
			if (_instance == null)
			{
				_createdFromStart = true;
				_instance = new BuddyManager();
			}
		}
		
		/**
		 * The number of confirmed buddies in the buddy list
		 */
		public static function get buddyCount():uint
		{
			return _instance._buddyCollection.length;
		}
		
		public static function set buddyXML(value:XML):void
		{
			_instance._buddies = BuddyFactory.buildBuddyList(value);
			_instance._buddyCollection = new ArrayCollection();
			
			for each (var buddy:Buddy in _instance._buddies)
			{
				if (buddy.status == BUDDY_CONFIRMED)
					_instance._buddyCollection.addItem(buddy);
				else if (buddy.status == BUDDY_REQUEST_RECEIVED || buddy.status == BUDDY_REQUEST_RECEIVED_REFER_FRIEND)
					_instance.processBuddyRequest(buddy, true);
			}
			
			SocketClient.sendMessage("avatar_handler", "buddyList", "buddy", { avatarId:_instance._avatar.avatarId, friendTypeId:1 });
		}
		
		public static function getBuddyCollection():ArrayCollection
		{
			return _instance._buddyCollection;
		}
		
		public static function getBuddy(avatarId:int):Buddy
		{
			for each (var buddy:Buddy in _instance._buddyCollection)
			{
				if (buddy.avatarId == avatarId) return buddy;
			}
			
			return null;
		}
		
		private function updateBuddyPresence(buddyAvatarId:int, presenceStatus:int, roomId:String, locDesc:String, partyMode:int, sendNotification:Boolean = true):void
        {
        	// find the buddy
        	var buddy:Buddy = findBuddy(buddyAvatarId);
        	
        	if (buddy)
        	{
        		// send a notification to the user
				if (sendNotification == true && buddy.presence != 1 && presenceStatus == 1 && buddy.status == BUDDY_CONFIRMED)
				{
					var message:String = "Your buddy, " + buddy.name + ", just came online!";
					HudController.getInstance().addNewNotification(message, NotificationIcon.BUDDY, false);
				}
        		
        		// now update the buddy
        		buddy.presence = presenceStatus;
				buddy.roomId = roomId;
				buddy.roomName = locDesc;
				buddy.partyMode = partyMode;
        	}
		}
		
		private function updateBuddyInfo(buddyXml:XML):Buddy
		{
			trace(buddyXml);
			var buddy:Buddy = findBuddy(buddyXml.buddyAvatarId);
			
			if (buddy)
				BuddyFactory.updateBuddy(buddyXml, buddy);
			else
			{
				buddy = BuddyFactory.buildBuddy(buddyXml);
				_buddies[buddyXml.buddyAvatarId] = buddy;
				if (buddy.status == BUDDY_CONFIRMED)
					processNewBuddy(buddy.avatarId);
			}
			
			if (_needsRemoval[buddy.avatarId] == true)
			{
				delete _needsRemoval[buddy.avatarId];
				removeBuddy(buddy.avatarId);
			}
			
			return buddy;
		}
		
		private static function removeBuddy(buddyAvatarId:int):void
		{
			var buddy:Buddy = _instance.findBuddy(buddyAvatarId);
			
			if (buddy == null)
			{
				_instance._needsRemoval[buddyAvatarId] = true;
				return;
			}
			
			var indexOfBuddy:int = _instance._buddyCollection.getItemIndex(buddy);
			
			if (indexOfBuddy != -1)
				_instance._buddyCollection.removeItemAt(indexOfBuddy);
			
			delete _instance._buddies[buddyAvatarId];
		}
		
		public static function makeRemoveBuddyRequest(buddyAvatarId:int):void
		{
			SocketClient.sendMessage("avatar_handler", "buddyRemove", "buddy", { avatarId:_instance._avatar.avatarId, buddyAvatarId:buddyAvatarId, friendTypeId:1, statusId:2 });
		}
		
		private function onPluginEvent(event:SocketEvent):void
		{
			var buddy:Buddy;
			var buddyXml:XML;
			
			switch (event.params.action)
			{
				case "buddyList":
					var buddyListXml:XML = XML(event.params.buddyList);
					for each (buddyXml in buddyListXml.buddies.buddy)
						updateBuddyPresence(buddyXml.buddyAvatarId, buddyXml.pr, buddyXml.rm, buddyXml.ld, buddyXml.p, false);
					break;
				case "buddyRequest":
					buddy = BuddyFactory.buildBuddy(XML(event.params.buddy));
					_buddies[buddy.avatarId] = buddy;
					processBuddyRequest(buddy);
					break;
				case "buddyReject":
					trace("buddyReject");
					removeBuddy(XML(event.params.buddy).buddyAvatarId);
					break;
				case "buddyRemove":
					removeBuddy(XML(event.params.buddy).buddyAvatarId);
					break;					
				case "buddyConfirm":
					buddy = updateBuddyInfo(XML(event.params.buddy));
					//var buddy:Buddy = BuddyFactory.buildBuddy(XML(event.params.buddy));
					processNewBuddy(buddy.avatarId);
					break;
				case "buddyInfo":
					trace("buddyInfo");
					//var updatedBuddy:Buddy = BuddyFactory.buildBuddy(XML(event.params.buddy)); 
					updateBuddyInfo(XML(event.params.buddy));
					break;
				case "presenceUpdate":
					var params:Object = event.params;
					updateBuddyPresence(params.avatarId, params.pr, params.rm, params.ld, params.p);
					break;
				default:
					break;
			}
		}
		
		/**
		 * Gets buddy info for the given buddy with presence and confirmation info
		 */ 
		public static function getBuddyInfo(buddyAvatarId:int):void
		{
			trace("get buddyInfo");
			SocketClient.sendMessage("avatar_handler", "buddyInfo", "buddy", {serverId:Server.getCurrentId(), avatarId:ModelLocator.getInstance().avatar.avatarId, buddyAvatarId:buddyAvatarId, friendTypeId:1});
		}
		
		public static function makeBuddyRequest(buddyId:int, buddyName:String, isReferFriend:Boolean = false):void
		{
			// handle the max buddy count
			if (buddyCount >= MAX_BUDDIES)
			{
				SdgAlert.show("You are more popular than your friends list can handle!  If you remove some of your friends, you can add more.", "Buddy List Full");
				return;
			}
			
			var buddyStatus:int = _instance.getBuddyStatus(buddyId);
			
			// the avatar is a new buddy
			if (buddyStatus == 0)
			{
				if (buddyCount == MAX_BUDDIES - 1)
				{
					SdgAlert.show("Your friends list is one friend away from being full.", "Buddy List Almost Full");
				}
				
				var params:Object = {serverId:Server.getCurrentId(), avatarId:ModelLocator.getInstance().avatar.avatarId, buddyAvatarId:buddyId, friendTypeId:1};
				if (isReferFriend)
					params.statusId = BUDDY_REQUEST_RECEIVED_REFER_FRIEND;
				
				SocketClient.sendMessage("avatar_handler", "buddyRequest", "buddy", params);
				SdgAlertChrome.show("Your buddy invitation has been sent to " + buddyName, "Buddy Request Sent");
				getBuddyInfo(buddyId);
			}
			// buddy is awaiting your reply, should already be in hud
			else if (buddyStatus == BUDDY_REQUEST_RECEIVED)
			{
				// should make them buddies and delete the buddy request
				if (replyBuddyRequest(true, buddyId, buddyName))
				{
					HudController.getInstance().findRemoveBuddyRequest(buddyId);
				}
			}
			// already sent buddy request
			else if (buddyStatus == BUDDY_REQUESTED)
			{
				SdgAlertChrome.show("A buddy invitation has already been sent to " + buddyName, "Request Already Sent");
			}
		}
		
		public static function replyBuddyRequest(acceptBuddy:Boolean, buddyAvatarId:int, buddyAvatarName:String = null):Boolean
		{
			var params:Object = {avatarId:_instance._avatar.avatarId, buddyAvatarId:buddyAvatarId, friendTypeId:1};
			if (acceptBuddy)
			{
				// handle the max buddy count - set it at 100 for now
				if (buddyCount >= MAX_BUDDIES)
				{
					SdgAlert.show("You are more popular than your friends list can handle!  If you remove some of your friends, you can add more.", "Buddy List Full");
					return false;
				}
				else
				{
					if (_instance.getBuddyStatus(buddyAvatarId) == BUDDY_REQUEST_RECEIVED_REFER_FRIEND)
						LoggingUtil.sendClickLogging(LoggingUtil.RAF_FRIEND_REQUEST_ACCEPTED);
					
					SocketClient.sendMessage("avatar_handler", "buddyConfirm", "buddy", params);
					_instance.processNewBuddy(buddyAvatarId);
					getBuddyInfo(buddyAvatarId);
				}
			}
			else
			{
				SocketClient.sendMessage("avatar_handler", "buddyReject", "buddy", params);
				removeBuddy(buddyAvatarId);
			}
			
			return true;
		}
		
		/**
		 *  Returns true if the given avatar is a buddy of ours
		 */
		public static function isBuddy(avatarId:int):Boolean
		{
			var buddy:Buddy = _instance.findBuddy(avatarId);
			return buddy != null && buddy.status == BUDDY_CONFIRMED;
		}
		
		/**
		 *  Returns true if the given avatar is a buddy of ours and is online
		 */
		public static function isBuddyOnline(avatarId:int):Boolean
		{
			var buddy:Buddy = _instance.findBuddy(avatarId);
			return buddy != null && buddy.status == BUDDY_CONFIRMED && buddy.presence == 1;
		}
		
		private function processNewBuddy(buddyAvatarId:int):void
		{
			var buddy:Buddy = findBuddy(buddyAvatarId);
			
			_buddyCollection.addItem(buddy);
			HudController.getInstance().addNewNotification(buddy.name + " is now your buddy.", NotificationIcon.BUDDY);
		}
		
		private function getBuddyStatus(buddyId:int):int
		{
			var buddy:Buddy = findBuddy(buddyId);
			if (buddy)
				return buddy.status;
				
			return 0;	
		}
		
		private function getBuddyListFromServer():void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new BuddyListEvent());
			//SocketClient.sendMessage("avatar_handler", "buddyList", "buddy", { avatarId:_avatar.avatarId, friendTypeId:1 });
		}
		
		private function processBuddyRequest(buddy:Buddy, isPendingRequest:Boolean = false):void
		{
			// until we have server side support for max buddy requesting - we'll have to reject buddies
			// here if we are at our limit
			
			// handle the max buddy count - set it at 100 for now
			if (buddyCount >= MAX_BUDDIES)
			{
				replyBuddyRequest(false, buddy.avatarId);
				RoomManager.getInstance().sendChat("Sorry, my buddy list is maxed out");
				return;
			}
			
			// handle ignore buddy
			var isIgnored:Boolean = ModelLocator.getInstance().ignoredAvatars[buddy.avatarId];
			if (isIgnored)
			{
				trace("reject");
				replyBuddyRequest(false, buddy.avatarId);
				return;
			}
			
			var message:String;
			
			if (buddy.status == BuddyManager.BUDDY_REQUEST_RECEIVED_REFER_FRIEND)
				message = "Your buddy " + buddy.name + " just joined the team and wants to be friends! Accept friend request?";
			else
				message = buddy.name + " wants to be your buddy. Do you accept?";
			
			// release with PDA
			HudController.getInstance().addNewBuddyRequest(message, buddy.avatarId, buddy.name, isPendingRequest);
		}
		
		private function findBuddy(buddyAvatarId:int):Buddy
		{
			// It's possible to get a presense update before getting your list of buddies.
			if(_buddies != null)
			{
				return _buddies[buddyAvatarId];
			}
			return null;
		}
		
		
		// party stuff
		
		public static function getPartyCollection():ArrayCollection
		{
			return _instance.partyCollection;
		}
		
		private function get partyCollection():ArrayCollection
		{
			_partyCollection = new ArrayCollection();
			
			CairngormEventDispatcher.getInstance().dispatchEvent(new PartyListEvent());
			
			return _partyCollection;
		}
		
		public static function set partyBuddyXML(value:XML):void
		{
			var buddies:Object = BuddyFactory.buildPartyList(value);
			for each (var buddy:PartyBuddy in buddies)
			{
				if (buddy.avatarId == _instance._avatar.avatarId)
					continue;
				
				if (buddy.partyMode == Constants.TURF_ACCESS_FRIENDS) // if party is friend only, then check whether avatar is a buddy
				{
					if (isBuddy(buddy.avatarId) == false)
						continue;
					
					if (buddy.presence != Constants.PRESENCE_ONLINE)
						continue;
				}
				
				_instance._partyCollection.addItem(buddy);
			}
		}
	}
}
