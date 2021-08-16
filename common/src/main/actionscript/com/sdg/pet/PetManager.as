package com.sdg.pet
{
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.control.room.RoomManager;
	import com.sdg.control.room.itemClasses.PetController;
	import com.sdg.events.DoodadActionEvent;
	import com.sdg.events.SocketPetEvent;
	import com.sdg.manager.SoundManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.GameAssetId;
	import com.sdg.model.ItemType;
	import com.sdg.model.PetItem;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.StringUtil;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class PetManager extends EventDispatcher
	{
		public function PetManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function leashPetToAvatar(avatar:Avatar, petInventoryId:int, petOwnerAvatarId:int):void
		{
			// Leash or unleash the pet.
			
			// Determine if the pet is owned by the local user.
			var isLocalPet:Boolean = (avatar.avatarId == petOwnerAvatarId);
			// Only the pet owner can leash/unleash.
			if (!isLocalPet) return;
			// Make sure the pet is not already leashed.
			var isPetLeashed:Boolean = (avatar.leashedPetInventoryId == petInventoryId);
			if (isPetLeashed) return;
			
			// Make sure we can get a reference to the pet controller.
			var petController:PetController = RoomManager.getInstance().roomContext.getItemControllerWithInventoryId(petInventoryId) as PetController;
			if (!petController)
			{
				// Can't get a reference to the pet controller. Tell the user that they must go to their home turf to leash a pet.
				SdgAlertChrome.show('Go to your home turf to leash your pet.', 'Wait!');
				return;
			}
			else
			{
				// Make sure the pet has sufficient energy/happiness.
				var petItem:PetItem = PetItem(petController.item);
				if (petItem.energy <= 0)
				{
					// Can't leash the pet because energy is too low.
					SdgAlertChrome.show('Food will provide energy.', StringUtil.GetStringWithinCharacterLimit(petItem.name, 19) + ' is tired');
					return;
				}
				else if (petItem.happiness <= 0)
				{
					// Can't leash pet because happiness is too low.
					SdgAlertChrome.show('Play will cheer them up.', StringUtil.GetStringWithinCharacterLimit(petItem.name, 19) + ' is sad');
					return;
				}
			}
			
			// Send leash action to server.
			SocketClient.getInstance().sendPluginMessage("avatar_handler", DoodadActionEvent.PET_LEASH, {petId:petInventoryId});
		}
		
		public static function unleashPet(petInventoryId:int):void
		{
			SocketClient.getInstance().sendPluginMessage("avatar_handler", DoodadActionEvent.PET_UNLEASH, {petId:petInventoryId});
		}
		
		public static function feedPetWithAvatarsFood(avatar:Avatar, petInventoryId:int, petOwnerAvatarId:int, onComplete:Function = null):void
		{
			// Feed the pet...
			// Make sure it is a pet owned by the avatar and that the avatar has pet food.
			var isLocalPet:Boolean = (avatar.avatarId == petOwnerAvatarId);
			if (!isLocalPet) return;
			var petFoodCount:int = avatar.petFoodCount;
			if (petFoodCount < 1)
			{
				// The local avatar does not have any food to feed the pet.
				// Load the avtars food inventory list to make sure we have the proper count.
				avatar.loadInventoryList(ItemType.PET_FOOD, onAvatarFoodListLoaded);
			}
			else
			{
				consumeFood();
			}
			
			function consumeFood():void
			{
				var petFoodInventoryId:int = avatar.petFoodInventoryId;
				if (petFoodInventoryId < 1) return;
				
				// Make sure pet energy isn't full already.
				var petController:PetController = RoomManager.getInstance().roomContext.getItemControllerWithInventoryId(petInventoryId) as PetController;
				if (petController && petController.petItem.energy > 0.95)
				{
					// Pet energy is already full.
					// No need to feed.
					SdgAlertChrome.show('Your pet does not need food right now.', StringUtil.GetStringWithinCharacterLimit(petController.item.name, 19) + ' is full');
					return;
				}
				
				// Send a socket message to the server.
				// Tell the server that we want to feed the pet.
				SocketClient.addPluginActionHandler(SocketPetEvent.PET_CONSUMED, onPetConsumedSocketEvent);
				SocketClient.getInstance().sendPluginMessage('avatar_handler', 'petConsume', {petId:petInventoryId, consumedInventoryId:petFoodInventoryId});
			}
			
			function onPetConsumedSocketEvent(e:SocketPetEvent):void
			{
				// Remove action listener.
				SocketClient.removePluginActionHandler(SocketPetEvent.PET_CONSUMED, onPetConsumedSocketEvent);
				
				// Decrement avatars pet food by one.
				avatar.decrementPetFoodCount();
				avatar = null;
				
				// Play pet eating sound.
				var soundUrl:String = AssetUtil.GetGameAssetUrl(GameAssetId.WORLD_SOUND, 'pet_eating.mp3');
				SoundManager.GetInstance().playSound(soundUrl);
				
				// Callback.
				if (onComplete != null) onComplete();
				onComplete = null;
			}
			
			function onAvatarFoodListLoaded():void
			{
				petFoodCount = avatar.petFoodCount;
				if (petFoodCount > 0)
				{
					consumeFood();
				}
				else
				{
					// The local avatar does not have any food to feed the pet.
					SdgAlertChrome.show('Go buy some at the pet store.', 'You\'re out of food!');
				}
			}
		}
		
		public static function playWithPet(petInventoryId:int, animationName:String = ''):PetController
		{
			// Trigger one of the pets animations and show the pet on the card.
			// Get a reference to the pet controller.
			var petController:PetController = RoomManager.getInstance().roomContext.getItemControllerWithInventoryId(petInventoryId) as PetController;
			if (!petController) return null;
			
			// Have the pet do an animation.
			if (animationName.length < 1)
			{
				petController.doRandomAnimation();
			}
			else
			{
				petController.doAnimation(animationName);
			}
			
			// Send a socket message to the server.
			// Tell the server that we want to play with the pet.
			SocketClient.getInstance().sendPluginMessage('avatar_handler', 'petPlay', {petId:petInventoryId});
			
			// Play pet sound.
			var soundUrl:String = AssetUtil.GetGameAssetUrl(GameAssetId.WORLD_SOUND, 'pet_play.mp3');
			SoundManager.GetInstance().playSound(soundUrl, 0.6);
			
			return petController;
		}
		
		public static function setPetFollowMode(petInventoryId:int, doFollow:int):void
		{
			// Send a socket message to the server.
			// Tell the server to make the pet stop following the avatar (0), or continue following (1).
			SocketClient.getInstance().sendPluginMessage('avatar_handler', SocketPetEvent.PET_FOLLOW_MODE, {petId:petInventoryId, followMode:doFollow});
			
			// Play whistle sound.
			var soundUrl:String = AssetUtil.GetGameAssetUrl(GameAssetId.WORLD_SOUND, 'whistle.mp3');
			SoundManager.GetInstance().playSound(soundUrl, 0.3);
		}
		
	}
}