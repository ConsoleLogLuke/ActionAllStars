package com.sdg.control
{
	import ch.capi.data.QueueList;
	
	import com.sdg.components.controls.BadgeMessage;
	import com.sdg.components.controls.BuddyRequestMessage;
	import com.sdg.components.controls.HudMessageDisplay;
	import com.sdg.components.controls.IHudMessage;
	import com.sdg.components.controls.JabMessage;
	import com.sdg.components.controls.MessagesArrayList;
	import com.sdg.components.controls.NotificationMessage;
	import com.sdg.components.controls.RequestMessage;
	import com.sdg.model.NotificationIcon;
	
	[Bindable]
	public class HudController
	{
		private static var _instance:HudController;
		
		public var personalMessagesList:MessagesArrayList = new MessagesArrayList();
		public var buddiesMessagesList:MessagesArrayList = new MessagesArrayList();
		public var requestsList:MessagesArrayList = new MessagesArrayList();
		
		public var messageQueue:QueueList = new QueueList();
		private var _display:HudMessageDisplay;
		public var hasNewMessages:Boolean = false;
		private var _currentList:MessagesArrayList;
		
		/**
		 * Constructor.
		 */
		public function HudController()
		{
			if (_instance)
				throw new Error("HudController is a singleton class. Use 'getInstance()' to access the instance.");
		}
		
		public static function getInstance():HudController
		{
			if (_instance == null)
			{
				_instance = new HudController();
				_instance._display = new HudMessageDisplay();
			}
			
			return _instance;
		}
		
		public function addNewJab(swfUrl:String = null, jabId:int = 0,
								receiverName:String = null, senderName:String = null,
								senderAvatarId:int = 0, jabText:String = null, isPersonal:Boolean = true,
								priority:Boolean = false, gameSessionId:String = '0', gameId:int = 0):void
		{
			var jabMessage:JabMessage = new JabMessage();
			addNewMessage(jabMessage, priority);
			jabMessage.iconSource = swfUrl;
			jabMessage.jabId = jabId;
			jabMessage.senderName = senderName;
			jabMessage.senderAvatarId = senderAvatarId;
			jabMessage.jabText = jabText;
			jabMessage.isPersonal = isPersonal;
			jabMessage.gameSessionId = gameSessionId;
			jabMessage.gameId = gameId;
		}
		
		public function addNewNotification(message:String = null, iconId:int = 0, isPersonal:Boolean = true, priority:Boolean = false, clickHandler:Function= null):void
		{
			var notificationMessage:NotificationMessage = new NotificationMessage();
			addNewMessage(notificationMessage, priority);
			notificationMessage.message = message;
			notificationMessage.iconId = iconId;
			notificationMessage.isPersonal = isPersonal;
			notificationMessage.clickHandler = clickHandler;
		}
		
		public function addNewBadgeMessage(badgeId:int, level:int, message:String = null, isPersonal:Boolean = true,
											priority:Boolean = false, clickHandler:Function= null):void
		{
			var badgeMessage:BadgeMessage = new BadgeMessage();
			addNewMessage(badgeMessage, priority);
			badgeMessage.setBadgeIcon(badgeId, level);
			badgeMessage.message = message;
			badgeMessage.isPersonal = isPersonal;
			badgeMessage.clickHandler = clickHandler;
		}
		
		public function addNewBuddyRequest(message:String = null, buddyAvatarId:int = 0, buddyName:String = null, priority:Boolean = false, isPendingBuddy:Boolean = false):void
		{
			var requestMessage:BuddyRequestMessage = new BuddyRequestMessage();
			addNewMessage(requestMessage, priority, isPendingBuddy);
			requestMessage.message = message;
			requestMessage.buddyAvatarId = buddyAvatarId;
			requestMessage.buddyAvatarName = buddyName;
		}
		
		public function addNewRequest(message:String = null, priority:Boolean = false):void
		{
			var requestMessage:RequestMessage = new RequestMessage();
			addNewMessage(requestMessage, priority);
			requestMessage.message = message;
		}
		
		public function processBuddyRequestReply(bool:Boolean, buddyAvatarId:int, buddyAvatarName:String):Boolean
		{
			return BuddyManager.replyBuddyRequest(bool, buddyAvatarId, buddyAvatarName);
		}
		
		public function findRemoveBuddyRequest(buddyId:int):void
		{
			var item:IHudMessage;
			var request:BuddyRequestMessage;
			
			for each (item in messageQueue)
			{
				request = item as BuddyRequestMessage;
				if (request != null && request.buddyAvatarId == buddyId)
					removeFromQueue(request);
			}
			
			if (_display.numChildren > 0)
			{
				request = _display.getChildAt(0) as BuddyRequestMessage;
				if (request != null && request.buddyAvatarId == buddyId)
					_display.changeMessage(false);
			}
			
			for each (item in requestsList)
			{
				request = item as BuddyRequestMessage;
				if (request != null && request.buddyAvatarId == buddyId)
					removeMessageFromList(request, requestsList);
			}
		}
		
		public function addNewMessage(message:IHudMessage, priority:Boolean = false, isPendingRequest:Boolean = false):void
		{
			if (isPendingRequest)
				addMessageToList(message);
			else
			{
				if (priority)
					messageQueue.addElementAt(message, 0);
				else
					messageQueue.add(message);
				
				message.removeCallback = removeFromQueue;
				
				_display.setMessageDisplay();
			}
		}
		
		private function removeFromQueue(message:IHudMessage):void
		{
			messageQueue.removeElement(message);
		}
		
		private function determineList(message:IHudMessage):MessagesArrayList
		{
			var list:MessagesArrayList;
			if (message is RequestMessage)
				list = requestsList;
			else
			{
				if (message.isPersonal)
					list = personalMessagesList;
				else
					list = buddiesMessagesList;
			}
			return list;
		}
		
		private function getRWSNotification():NotificationMessage
		{
			for each (var message:NotificationMessage in personalMessagesList)
			{
				if (message.iconId == NotificationIcon.RWS)
					return message;
			}
			return null;
		}
		
		public function addMessageToList(message:IHudMessage, list:MessagesArrayList = null):void
		{
			// if no list is specified, find out what it should be
			if (!list)
				list = determineList(message);
			
			var notification:NotificationMessage = message as NotificationMessage;
			if (notification && notification.iconId == NotificationIcon.RWS)
			{
				var rwsMessage:NotificationMessage = getRWSNotification();				
				if (rwsMessage)
					removeMessageFromList(rwsMessage, personalMessagesList);
			}
			
			list.addItemAt(message, 0);
			message.removeCallback = removeMessageFromList;
			
			if (_currentList != list)
			{
				list.hasNewMessages = true;
				hasNewMessages = true;
			}
		}
		
		public function removeMessageFromList(message:IHudMessage, list:MessagesArrayList = null):void
		{
			// if no list is specified, find out what it should be
			if (!list)
				list = determineList(message);
			
			list.removeItem(message);
		}
		
		public function set currentList(value:MessagesArrayList):void
		{
			if (_currentList)
			{	
				for each (var message:IHudMessage in _currentList)
					message.read = true;
			}
			
			_currentList = value;
			
			if (value)
				value.hasNewMessages = false;
			if (!personalMessagesList.hasNewMessages && !buddiesMessagesList.hasNewMessages && !requestsList.hasNewMessages)
				hasNewMessages = false;
		}
		
		public function get display():HudMessageDisplay
		{
			return _display;
		}
	}
}
