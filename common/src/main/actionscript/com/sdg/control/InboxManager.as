package com.sdg.control
{
	import com.sdg.components.controls.ModeratorAlertChrome;
	import com.sdg.components.dialog.PopUpSplitScreen;
	import com.sdg.components.dialog.TokenDeliveryDialog;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.NotificationIcon;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.MainUtil;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.events.CloseEvent;
	
	public class InboxManager
	{
		public static function processUnreadMessages(unreadMessages:XML):void
		{
			trace(unreadMessages);
			for each (var inboxMessage:XML in unreadMessages.inboxMessage)
			{
				var messageTypeId:int = parseInt(inboxMessage.messageTypeId);
				switch (messageTypeId)
				{
					case 2:
						onModeratorMessage();
						// let the user know he is in warning mode
						//SdgAlert.show(inboxMessage.text, "Moderator Warning");
						//ModelLocator.getInstance().avatar.warned = true;
						break;
						
					case 4:
					case 5:
						onTokenDelivery(messageTypeId, inboxMessage.text);
						break;
					case 6:
						onChangesReport();
						break;
					case 7:
						onBadgeTellAFriend();
						break;
					case 8:
						onScoreTellAFriend();
						break;
					case 9:
						onLoginBadgeEarned();
						break;
					case 10:
						onNewGift();
						break;
					default:
						trace("Unknown message type: " + messageTypeId);
						trace("		message text: " + inboxMessage.text);
						break;
				}
				
				// mark the message as read
				SocketClient.sendMessage("avatar_handler", "setMessageAsRead", "inboxMessage", { inboxMessageId:inboxMessage.inboxMessageId });
			}
			
			function onModeratorMessage():void
			{
				var messageTextArray:Array = String(inboxMessage.text).split(";", 2);
				
				var modMessageType:int = messageTextArray[0];
				var message:String = messageTextArray[1];
				var avatar:Avatar = ModelLocator.getInstance().avatar;
				
				// unban/unwarn
				if (modMessageType == 0)
				{
					avatar.warned = false;
					avatar.banned = false;
				}
				// crisp silence
				if (modMessageType == 1)
				{
					avatar.warned = true;
					//SdgAlert.show(message, "WARNING NOTICE!");
					ModeratorAlertChrome.show(message, "SILENCING NOTICE!");
				}
				// suspend
				else if (modMessageType == 2)
				{
					avatar.banned = true;
					ModeratorAlertChrome.show(message, "SUSPENSION NOTICE!", onBanMessageClose);
				}
				// ban
				else if (modMessageType == 3)
				{
					avatar.banned = true;
					//SdgAlert.show(message, "BANNING NOTICE!", 0x04, 0x04, onBanMessageClose);
					ModeratorAlertChrome.show(message, "BANNING NOTICE!", onBanMessageClose);
				}
				// crisp warn
				else if (modMessageType == 10)
				{
					//SdgAlert.show(message, "WARNING NOTICE!");
					ModeratorAlertChrome.show(message, "WARNING NOTICE!");
				} 
			}
			
			function onBanMessageClose(event:CloseEvent):void
			{
				navigateToURL(new URLRequest('chatApp.jsp'), '_self');
			}
			
			function onBadgeTellAFriend():void
			{
				var messageTextArray:Array = String(inboxMessage.text).split(";", 7);
				var message:String = messageTextArray[1] + " has earned a badge! " + String(messageTextArray[3]).toUpperCase() + ": " + messageTextArray[5];
				HudController.getInstance().addNewBadgeMessage(messageTextArray[2], messageTextArray[6] - 1, message, false); 
			}
			
			function onScoreTellAFriend():void
			{
				var messageTextArray:Array = String(inboxMessage.text).split(";", 7);
				var message:String = messageTextArray[1] + " scored "+messageTextArray[2]+" in "+messageTextArray[3]+". Can you beat it?";
				HudController.getInstance().addNewNotification(message, NotificationIcon.GENERIC, false);
			}
			
			function onLoginBadgeEarned():void
			{
				var messageTextArray:Array = String(inboxMessage.text).split(";", 5);
				var badgeTitle:String = messageTextArray[2] as String;
				var message:String = "You've earned a badge!\n"+badgeTitle.toUpperCase()+":\n"+messageTextArray[3];
				HudController.getInstance().addNewBadgeMessage(messageTextArray[0], messageTextArray[1] - 1, message, false); 
			}
			
			function onNewGift():void
			{
				var message:String = "Way to go! A new prize has been placed in your Turf Builder!";
				HudController.getInstance().addNewNotification(message, NotificationIcon.BUDDY);
			}
			
			function onChangesReport():void
			{
				MainUtil.showDialog(PopUpSplitScreen);
			}
			
			function onTokenDelivery(messageTypeId:int, numTokens:int):void
			{
				var message:String;
				var closingMessage:String;
				if (messageTypeId == 4)
				{
					message = "Hey " + ModelLocator.getInstance().avatar.name + ",\n\nThe " + numTokens + " tokens you've purchased have been added to your account!";
					closingMessage = "Ready. Set. Shop!";
				}
				else if (messageTypeId == 5)
				{
					message = "Hey " + ModelLocator.getInstance().avatar.name + ",\n\nYour monthly token bonus has been added to your wallet.";
					closingMessage = "";
				}
				
				MainUtil.showDialog(TokenDeliveryDialog, {message:message, tokens:numTokens, closingMessage:closingMessage});
				HudController.getInstance().addNewNotification(numTokens + " tokens have been delivered to your account", NotificationIcon.GENERIC);
			}
		}
	}
}