package com.sdg.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.sdg.factory.IXMLObjectFactory;
	import com.sdg.model.Avatar;
	import com.sdg.model.StoreItem;
	import com.sdg.net.Environment;
	import com.sdg.utils.Constants;
	import com.sdg.utils.NetUtil;
	import com.sdg.utils.ObjectUtil;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	
	public class SdgServiceDelegate
	{
		private var responder:IResponder;
		
		public function SdgServiceDelegate(responder:IResponder):void
		{
			this.responder = responder;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Request methods
		//
		//--------------------------------------------------------------------------
		
		public function login(username:String, password:String, hasUnity:String):void
		{
			send("login", { userName:username, hash:NetUtil.generateHash([username, password], Environment.SALT), hasUnity:hasUnity });
		}
		
		public function mvpLogin(username:String, password:String, linkId:int, planId:int, paymentMethodId:int):void
		{
			send("mvpLogin", { userName:username, hash:NetUtil.generateHash([username, password], Environment.SALT), linkId:linkId, planId:planId, paymentMethodId:paymentMethodId });
		}
		
		public function getUnityNBATeams(avatarId:int):void
		{
			send("getUnityNBATeams", {avatarId:avatarId});
		}
		
		public function verifyFriend(friendName:String):void
		{
			send("verifyFriend", {friendName:friendName});
		}
		
		public function buttonClick(linkId:int, avatarId:int):void
		{
			sendPayload("buttonClick", {code:linkId, avatarId:avatarId});
		}
		
		public function getBuddyList(avatarId:int):void
		{
			send("getBuddyList", { avatarId:avatarId, hash:NetUtil.generateHash([avatarId], Environment.SALT) });
		}
		
		public function getPartyList(serverId:int):void
		{
			send("getPartyList", {serverId:serverId});
		}
		
		public function getPickem(avatarId:int, requestType:String = "lastResults"):void
		{
			send("pickem", {requestType:requestType, avatarId:avatarId});
		}
		
		public function saveFavTeams(avatarId:int, params:Object):void
		{
			params.avatarId = avatarId;
			sendPayload("saveFavTeams", params);
		}
		
		public function getFavTeams(avatarId:int):void
		{
			send("getFavTeams", {avatarId:avatarId});
		}
		
		public function checkRoom(avatarId:int, roomId:int):void
		{
			send("roomCheck", {avatarId:avatarId, roomId:roomId});
		}
		
		public function checkItemOwnership(avatarId:int, itemId:int):void
		{
			send("roomCheck", {avatarId:avatarId, itemId:itemId});
		}
		
		//public function savePickem(avatarId:int, roomId:int, eventId:int, questionId:int, answerString:String):void
		//{
		//	sendPayload("pickem", { avatarId:avatarId, roomId:roomId, eventId:eventId, questionId:questionId, answerString:answerString} );
		//}
		
		public function getAvatars(username:String):void
		{
			send("avatar", { userName:username });
		}
		
		public function getAvatar(avatarId:uint):void
		{
			send("avatar", { avatarId:avatarId });
		}
		
		public function getServers():void
		{
			send("serverList");
		}
		
		public function setPayPal(userId:uint, planId:uint):void
		{
			send("setPayPal", { userId:userId, planId:planId });
		}
		
		public function getAsn(avatarId:uint):void
		{
			send("getAsn", { avatarId:avatarId });
		}
		
		public function getInventory(avatarId:uint, itemTypeId:uint):void
		{
			send("inventoryList", { avatarId:avatarId, itemTypeId:itemTypeId });
		}
		
		public function getStoreCategories(parentCategoryId:uint):void
		{
			send("storeCategories", { parentCategoryId:parentCategoryId });
		}
		
		public function getStoreCategoriesByStoreId(storeId:uint):void
		{
			send("storeCategories", { storeId:storeId });
		}
		
		public function getAvatarStat(avatarId:int, statNameId:int):void
		{
			send("getAvatarStat", { avatarId:avatarId, statNameId:statNameId});
		}
		
		public function saveAvatarStat(avatarId:int, statNameId:int, statValue:int):void
		{
			//send("saveAvatarStat", { avatarId:avatarId, statNameId:statNameId, statValue:1 });
			var toEncode:Array = new Array(avatarId, statNameId, statValue);
	        var hash:String = NetUtil.signRequest(toEncode);
	        sendPayload("saveAvatarStat", { avatarId:avatarId, statNameId:statNameId, statValue:statValue, hash:hash } );
		}
		
		public function getStoreItems(parentCategoryId:uint, avatarId:uint):void
		{
			send("storeItems", { parentCategoryId:parentCategoryId, avatarId:avatarId });
		}
		
		public function getTickerFeed():void
		{
			send("getTickerFeed");
		}
		
		public function getAvatarApparel(avatarId:uint):void
		{
			send("avatarApparel", { avatarId:avatarId });
		}
		
		public function itemPurchase(item:StoreItem, avatarId:int, theStoreId:int):void
		{
			var _storeId:int=0;
			var _categoryId:int =0;
			if(item.parentCategory!=null){
				//_storeId=item.parentCategory.storeId;
				_categoryId=item.parentCategory.id;
			}
			_storeId=theStoreId;
			sendPayload("itemPurchase", { itemId:item.id, avatarId:avatarId, storeId:_storeId, categoryId:_categoryId, hash:NetUtil.generateHash([item.id, avatarId], Environment.SALT) });
		}
		
		public function saveAvatarApparel(avatar:Avatar):void
		{
			var collection:ArrayCollection = new ArrayCollection(avatar.apparel.toArray());
			if (avatar.background && avatar.background.itemId != 4167)
				collection.addItem(avatar.background);
			
			sendPayload("avatarApparelSave", 
						{ userId:avatar.userId, avatarId:avatar.avatarId, gender:avatar.gender },
						makeItemListXml(collection, "item", ["inventoryItemId", "itemId"]));
		}
		
		public function saveRegistration(obj:Object):void
		{
			sendPayload("saveRegistration", obj);
		}
		
		public function mvpLogProcess(pageId:int, linkId:int, planId:int, paymentMethodId:int):void
		{
			send("mvpLogProcess", { pageId:pageId, linkId:linkId, planId:planId, paymentMethodId:paymentMethodId });
		}
		
		public function makeGuestAccount(avatar:Avatar, affiliateid:int):void
		{
			sendPayload("makeGuestAccount", 
						{ gender:avatar.gender, affiliateid:affiliateid },
						makeItemListXml(avatar.apparel, "item", ["inventoryItemId", "itemId"]));
		}
		
		public function changePassword(userId:uint, oldPassword:String, newPassword:String):void
		{
			send("changePassword", { userId:userId, oldPassword:oldPassword, password:newPassword });
		}
		
		public function changeParentPassword(userId:uint, oldPassword:String, newPassword:String):void
		{
			send("changeParentPassword", { userId:userId, oldPassword:oldPassword, parentPassword:newPassword });
		}
		
		public function changeChatMode(avatarId:uint, chatMode:uint):void
		{
			send("changeChatMode", { avatarId:avatarId, chatMode:chatMode });
		}
		
		public function changeNewsletterOption(avatarId:uint, newsletterOption:uint):void
		{
			send("changeNewsletterOption", { avatarId:avatarId, newsletterOption:newsletterOption });
		}
		
		// Not Currently Supported - Check with Yves/Han before using again
		/*
		public function getBillDateByPlan(planId:uint, userId:int):void
		{
			send("getBillDate", { planId:planId, userId:userId });
		}
		*/
		
		public function getBillDateByUser(userId:uint):void
		{
			send("getBillDate", { userId:userId });
		}
		
		public function resendActivation(userName:String, parentEmail:String):void
		{
			send("resendActivation", { userName:userName, parentEmail:parentEmail });
		}
		
		public function saveTradingCard(avatarId:uint, backgroundId:uint, inventoryItems:Array):void
		{
			sendPayload("tradingCardSave", 
						{ avatarId:avatarId, backgroundId:backgroundId },
						makeItemListXml(inventoryItems, "item", ["inventoryItemId", "itemId"]));
		}
		
		public function savePrivateRoom(roomId:String, avatarId:uint, inventoryItems:Array):void
		{
			sendPayload("savePrivateRoom",
						{ roomId:roomId, avatarId:avatarId },
						makeItemListXml(inventoryItems, "inventoryItem", ["inventoryItemId", "x", "y", "orientation"]));
		}
		
		public function saveModeratorReport(params:Object):void
		{
			sendPayload("saveModeratorReport", params);
		}
		
		public function getAvatarLevels():void
		{
			send("levelList");
		}
		public function getItemTypeList(itemClassId:uint):void
		{
			send("itemTypeList", { itemClassId:itemClassId });
		}
		
		public function validateUsername(userName:String):void
		{
			send("validateUsername", { userName:userName });
		}
		
		public function getChallenges(gameId:uint, avatarId:uint):void
		{
			send("challenges", { gameId:gameId, avatarId:avatarId });
		}
		
		public function getGameStats(avatarId:int, gameId:int, timeCheck:Boolean):void
		{
			var params:Object = {avatarId:avatarId};
			if (timeCheck)
				params.timeCheck = 1;
			else
				params.gameId = gameId;
			
			send("getGameStats", params);
		}
		
		public function getGameTeams(avatarId:int, getOwned:Boolean):void
		{
			var params:Object = {avatarId:avatarId};
			if (getOwned)
				params.owned = 1;
				
			send("getGameTeams", params);
		}
		
		public function getTradingCardBackgrounds(avatarId:uint):void
		{
			send("tradingCardBackgroundList", { avatarId:avatarId });
		}
		
		public function getTradingCardFrame(avatarId:uint):void
		{
			send("tradingCardFrame", { avatarId:avatarId });
		}
		
		public function getGameAttributes(avatarId:uint, gameId:uint, achievementId:uint, team1Id:uint, team2Id:uint):void
		{
			send("gameAttributes", { avatarId:avatarId, gameId:gameId, achievementId:achievementId, team1Id:team1Id, team2Id:team2Id });
		}

		public function gameResult(result:String):void
		{
			send("gameResult", { payload:result });
		}
		
		public function getKioskCards(avatarId:uint):void
		{
			send("getKioskCards", { avatarId:avatarId });
		}
		
		public function purchaseTradingCardPack(avatarId:uint, tradingCardDefinitionId:uint):void
		{
			var toEncode:Array = new Array(avatarId, tradingCardDefinitionId);
	        var hash:String = NetUtil.signRequest(toEncode);
			send("purchaseTradingCardPack", { avatarId:avatarId, tradingCardDefinitionId:tradingCardDefinitionId, hashCode:hash});
		}
		
		public function deleteTradingCard(avatarId:uint, tradingCardId:uint):void
		{
			var toEncode:Array = new Array(avatarId, tradingCardId);
	        var hash:String = NetUtil.signRequest(toEncode);
			send("deleteTradingCard", { avatarId:avatarId, tradingCardId:tradingCardId, hashCode:hash});
		}
		
		public function getAlbumCards(avatarId:uint):void
		{
			send("getAlbumCards", { avatarId:avatarId});
		}


		public function sendTutorialReset(avatarId:uint, value:int):void
		{
			sendPayload("tutorialReset", { avatarId:avatarId , statNameId:Constants.MAIN_TUTORIAL, statValue:value } );
 		}
 		
 		public function getSeasonal(avatarId:uint):void
 		{
 			send("getSeasonal", { avatarId:avatarId });
 		}

		public function seasonGiftSelection(avatarId:uint, itemId:uint, answerId:String, additionalComments:String):void
		{
			sendPayload("seasonalGiftSelection", { avatarId:avatarId, itemId:itemId, answerId:answerId, additionalComments:additionalComments } );
 		}
 		
 		public function getJabs():void
 		{
 			send("getJabs", {});
 		}
		
 		public function getEmotes():void
 		{
 			send("getEmotes", {});
 		}
 		
 		public function getItemSets():void
 		{
 			send("getItemSets", {});
 		}
 		
 		public function messageBoardList(avatarId:int, ct:Number):void
 		{
 			var hash:String = NetUtil.generateHash([avatarId, ct], Environment.SALT);
 			send("messageBoardList", {avatarId:avatarId, messageTypeId:11, ct:ct, hash:hash});
 		}
 		
 		public function messageBoardAdd(avatarId:int, fromAvatarId:int, message:String, ct:Number, password:String):void
 		{
 			var hash:String = NetUtil.generateHash([fromAvatarId, password, message.replace(/\s+/g, ""), ct], Environment.SALT);
 			send("messageBoardAdd", {avatarId:avatarId, fromAvatarId:fromAvatarId, messageTypeId:11, message:message, ct:ct, hash:hash});
 		}
 		
 		public function messageBoardUpdate(avatarId:int, messageId:int, actionId:int, ct:Number, password:String, serverId:int):void
 		{
 			var hash:String = NetUtil.generateHash([avatarId, password, messageId, actionId, ct], Environment.SALT);
 			send("messageBoardUpdate", {avatarId:avatarId, messageId:messageId, ct:ct, serverId:serverId, actionId:actionId, hash:hash});
 		}
 		
 		public function getPetList(avatarId:uint):void
 		{
 			send("petList", {avatarId:avatarId});
 		}
 		
		public function saveInventoryAttribute(avatarId:int, userIventoryId:int, inventoryAttributeNameId:int, inventoryAttributeValue:String, cost:int = 0):void
		{
			var hash:String = NetUtil.generateHash([avatarId, userIventoryId, inventoryAttributeNameId, inventoryAttributeValue, cost], Environment.SALT)
			sendPayload("saveAttribute", 
				{ avatarId:avatarId,  
				  userInventoryId:userIventoryId, 
				  inventoryAttributeNameId:inventoryAttributeNameId, 
				  inventoryAttributeValue:inventoryAttributeValue,
				  cost:cost, 
				  hash:hash });
		}
		
		//--------------------------------------------------------------------------
		//
		//  Service calls
		//
		//--------------------------------------------------------------------------
		
		protected function send(serviceName:String, params:Object = null, factory:IXMLObjectFactory = null, key:Object = null):void
		{
	
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService(serviceName);
			trace("service url = " + service.url);
			var token:AsyncToken = service.send(params);
			token.addResponder(new SdgServiceResponder(handleResult, handleFault, factory, key));
		}
		
		protected function sendPayload(serviceName:String, requestParams:Object, requestXML:String = ""):void
		{
			trace("outgoing payload" + makePayloadXml(requestParams, requestXML));
			send(serviceName, { payload:makePayloadXml(requestParams, requestXML) });
		}
		
		//--------------------------------------------------------------------------
		//
		//  Response handlers
		//
		//--------------------------------------------------------------------------
		
		protected function handleResult(data:Object, key:Object):void
		{
			responder.result(data);
		}
		
		protected function handleFault(info:Object, key:Object):void
		{
			responder.fault(info);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Static utility methods.
		//
		//--------------------------------------------------------------------------
		
		public static function makePayloadXml(requestParams:Object, requestXML:String = ""):String
		{
			return	"<SDGRequest>" + 
						ObjectUtil.toXMLString(requestParams, "requestParameters") +
						requestXML +
					"</SDGRequest>";
		}
		
		public static function makeItemListXml(list:Object, itemNodeName:String, itemPropNames:Array = null):String
		{
			return	"<items>" + 
						ObjectUtil.toXMLListString(list, itemNodeName, itemPropNames) +
					"</items>";
		}
	}
}