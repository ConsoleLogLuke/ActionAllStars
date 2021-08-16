package com.sdg.pet.card
{
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.control.room.RoomManager;
	import com.sdg.control.room.itemClasses.PetController;
	import com.sdg.control.room.itemClasses.pet.IPetControllerDelegate;
	import com.sdg.events.room.item.RoomItemCircleMenuEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.ItemType;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.PetItem;
	import com.sdg.model.User;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.pet.PetManager;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.NetUtil;
	import com.sdg.view.FluidView;
	import com.sdg.view.room.RoomItemViewCopy;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.events.CloseEvent;

	public class IntegratedPetInfoPanel extends FluidView implements IPetControllerDelegate
	{
		public static const DAYS_TO_OWN_BEFORE_YOU_CAN_NAME:int = 7;
		
		private static const _PET_IMAGE_STROKE:GlowFilter = new GlowFilter(0, 1, 5, 5, 10);
		
		private var _localAvatar:Avatar;
		private var _infoPanel:PetInfoPanel;
		private var _petInventoryId:int;
		private var _petItemId:int;
		private var _petOwnerAvatarId:int;
		private var _petName:String;
		private var _currentPetViewWindow:RoomItemViewCopy;
		private var _currentPetViewWindowTimer:Timer;
		private var _petCreatedTime:Number;
		
		public function IntegratedPetInfoPanel(petController:PetController, width:Number = 230, height:Number = 320)
		{
			_localAvatar = ModelLocator.getInstance().avatar;
			
			var petItem:PetItem = PetItem(petController.item);
			_petInventoryId = petItem.id;
			_petItemId = petItem.itemId;
			_petOwnerAvatarId = petController.item.avatarId;
			_petName = petItem.name;
			_petCreatedTime = petItem.createdTime;
			
			// Determine if the pet is owned by the local user.
			var isLocalPet:Boolean = (_localAvatar.avatarId == _petOwnerAvatarId);
			// Determine if the pet is leashed.
			var isPetLeashed:Boolean = (_localAvatar.leashedPetInventoryId == _petInventoryId);
			// Determine first and second pet name.
			var names:Array = petItem.name.split(' ');
			var firstName:String = names[0];
			var secondName:String = names[1];
			// Determine pet food count.
			var petFoodCount:int = _localAvatar.petFoodCount;
			// Determine if user should be able to name pet.
			var canNamePet:Boolean = (!PetItem.isCustomPetName(_petName) && getDaysUntilCanName() <= 0);
			
			_infoPanel = new PetInfoPanel(firstName, secondName, isLocalPet, isPetLeashed, petFoodCount, canNamePet, width, height);
			if (!isLocalPet) _infoPanel.foodVisible = false;
			_infoPanel.setHappinessLevel(petItem.happiness);
			// If it's a pet owned by GOD avatar, set full energy.
			_infoPanel.setEnergyLevel(petItem.energy);
			
			// If this is a pet owned by the local avatar and the food count is 0, try to load the food invetory list.
			if (isLocalPet && petFoodCount < 1)
			{
				_infoPanel.foodVisible = false;
				_localAvatar.loadInventoryList(ItemType.PET_FOOD, onPetFoodListComplete);
			}
			
			// Load the pet portrait.
			var petImageLoader:QuickLoader = new QuickLoader(AssetUtil.GetItemImageUrlWithLayerAndContext(petItem.itemId, 9600, 101), onPetImageComplete);
			
			super(width, height);
			
			render();
			
			// Add avatar listeners.
			_localAvatar.addEventListener(Avatar.LEASHED_PET_UPDATE, onLeashedPetUpdate);
			
			// Add interaction listeners.
			_infoPanel.addEventListener(RoomItemCircleMenuEvent.CLICK_FEED_PET, onFeedClick);
			_infoPanel.addEventListener(RoomItemCircleMenuEvent.CLICK_PLAY_PET, onPlayClick);
			_infoPanel.addEventListener(RoomItemCircleMenuEvent.CLICK_LEASH_PET, onLeashClick);
			_infoPanel.addEventListener(PetInfoPanel.SELECTED_PET_NAME, onSelectedPetName);
			_infoPanel.addEventListener(PetInfoPanel.ATTEMPT_NAME_PET, onAttemptedToNamePet);
			
			// Add this as a delegate to the pet controller.
			petController.addPetControllerDelegate(this);
			
			// Add displays.
			addChild(_infoPanel);
			
			function onPetImageComplete():void
			{
				// Set the pet image on the info panel.
				// Give it a storke.
				var petImage:DisplayObject = petImageLoader.content;
				petImage.filters = [_PET_IMAGE_STROKE];
				if (_infoPanel) _infoPanel.doImageSwap(petImage);
				petImageLoader = null;
			}
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function destroy():void
		{
			// Remove listeners.
			_infoPanel.removeEventListener(RoomItemCircleMenuEvent.CLICK_FEED_PET, onFeedClick);
			_infoPanel.removeEventListener(RoomItemCircleMenuEvent.CLICK_PLAY_PET, onPlayClick);
			_infoPanel.removeEventListener(RoomItemCircleMenuEvent.CLICK_LEASH_PET, onLeashClick);
			_localAvatar.removeEventListener(Avatar.LEASHED_PET_UPDATE, onLeashedPetUpdate);
			_infoPanel.removeEventListener(PetInfoPanel.SELECTED_PET_NAME, onSelectedPetName);
			_infoPanel.removeEventListener(PetInfoPanel.ATTEMPT_NAME_PET, onAttemptedToNamePet);
			
			// Remove this as a delegate from the pet controller.
			var petController:PetController = RoomManager.getInstance().roomContext.getItemControllerWithInventoryId(_petInventoryId) as PetController;
			if (petController) petController.removePetControllerDelegate(this);
			
			// Remove displays.
			removeChild(_infoPanel);
			
			// Clean up functions.
			_infoPanel.destroy();
			
			// Remove references.
			_infoPanel = null;
			_localAvatar = null;
		}
		
		public function onPetEnergyUpdate(value:Number):void
		{
			_infoPanel.setEnergyLevel(value);
		}
		
		public function onPetHappinessUpdate(value:Number):void
		{
			_infoPanel.setHappinessLevel(value);
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			_infoPanel.width = _width;
			_infoPanel.height = _height;
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function savePetName():void
		{
			// Save the pet name to the server.
			// Make sure the pet is owned by the local user.
			if (_localAvatar.avatarId != _petOwnerAvatarId) return;
			
			// Get user name and pass word.
			var localUser:User = ModelLocator.getInstance().user;
			var userName:String = localUser.username.toLowerCase(); // User name must be lower case for hash to work correctly.
			var userPassword:String = localUser.password;
			var hash:String = NetUtil.generateHash([userName, userPassword], Environment.SALT);
			var petName:String = _infoPanel.firstName + ' ' + _infoPanel.secondName;
			var qualifiedPetName:String = _infoPanel.firstName + '+' + _infoPanel.secondName;
			
			// Make sure the new pet name is actually different.
			if (getFirstAndSecondPetName() == petName) return;
			
			// Make sure the user should be able to name the pet.
			// Make sure the pet hasn't been named already.
			if (PetItem.isCustomPetName(_petName))
			{
				// This pet has already been named.
				SdgAlertChrome.show('You can only name your pet once.', 'Sorry!');
				resetPetName();
				return;
			}
			// Make sure they have owned the pet for long enough.
			var daysUntilCanName:Number = getDaysUntilCanName();
			if (daysUntilCanName > 0)
			{
				// User has not owned pet long enough to name the pet.
				SdgAlertChrome.show('You can name your pet after ' + Math.ceil(daysUntilCanName) + ' days.', 'Wait!');
				resetPetName();
				return;
			}
			
			
			// We are about to save the pet's newly selected name.
			// The user can only do this once.
			// Let's give them an opportunity to change their mind with a dialog screen.
			var areYouSureDialog:SdgAlertChrome = new SdgAlertChrome('You can only name your pet once.', 'Are you sure?', true, 430, 200);
			areYouSureDialog.addButton('Cancel', 2);
			areYouSureDialog.addEventListener(CloseEvent.CLOSE, onCloseAreYouSureDialog);
			areYouSureDialog.show();
			
			function onCloseAreYouSureDialog(e:CloseEvent):void
			{
				// Remove listener.
				areYouSureDialog.removeEventListener(CloseEvent.CLOSE, onCloseAreYouSureDialog);
				
				// Determine if the user clicked ok or cancel.
				var buttonIdentifier:int = e.detail;
				if (buttonIdentifier == 1)
				{
					// Continue saving name.
					continuePetNameSave();
				}
				else
				{
					// Cancel name save.
					resetPetName();
					return;
				}
			}
			
			function continuePetNameSave():void
			{
				var url:String = Environment.getApplicationUrl() + '/test/petName?inventoryId=' + _petInventoryId + '&petName=' + qualifiedPetName + '&hash=' + hash;
				var request:URLRequest = new URLRequest(url);
				var loader:URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onSaveNameComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onSaveNameError);
				loader.load(request);
				
				function onSaveNameComplete(e:Event):void
				{
					// Remove listeners.
					loader.removeEventListener(Event.COMPLETE, onSaveNameComplete);
					loader.removeEventListener(IOErrorEvent.IO_ERROR, onSaveNameError);
					
					// Determine if attempt to save pet name was successful.
					var response:XML = new XML(loader.data);
					var status:String = response.@status;
					if (status == '1')
					{
						// Pet name was saved.
						
						// Update the local pet name.
						// Get a reference to the pet controller.
						_petName = petName
						var petController:PetController = RoomManager.getInstance().roomContext.getItemControllerWithInventoryId(_petInventoryId) as PetController;
						if (petController) petController.item.name = petName;
						
						// Send a message to the socket server to notify that the pet name has changed.
						SocketClient.getInstance().sendPluginMessage('avatar_handler', 'petUpdated', {petId:_petInventoryId});
						
						// Message this to the user.
						SdgAlertChrome.show('Your pet has been named.', petName);
					}
					else
					{
						// Unable to save pet name for some reason.
						// Message this to the user.
						SdgAlertChrome.show('Unable to name your pet at the moment. Please try again later.', 'Time Out');
					}
				}
				
				function onSaveNameError(e:IOErrorEvent):void
				{
					// Remove listeners.
					loader.removeEventListener(Event.COMPLETE, onSaveNameComplete);
					loader.removeEventListener(IOErrorEvent.IO_ERROR, onSaveNameError);
					
					// Unable to save pet name for some reason.
					// Message this to the user.
					SdgAlertChrome.show('Unable to name your pet at the moment. Please try again later.', 'Time Out');
				}
			}
		}
		
		private function showPetViewWindow(petController:PetController, duration:int = 5000):void
		{
			// Show a pet view window temporaily.
			// If one is already being show, just reset the timer that is used to hide it.
			if (_currentPetViewWindowTimer)
			{
				_currentPetViewWindowTimer.reset();
				_currentPetViewWindowTimer.delay = duration;
			}
			else
			{
				var originalPetImage:DisplayObject = _infoPanel.image;
				var petViewWindow:RoomItemViewCopy = new RoomItemViewCopy(100, 100, petController, false, 1, 60);
				_currentPetViewWindow = petViewWindow;
				var fadeDuration:int = 500;
				_infoPanel.doImageSwap(petViewWindow, fadeDuration);
				
				// Create a timer to swap the image back after a given time.
				_currentPetViewWindowTimer = new Timer(duration);
				_currentPetViewWindowTimer.addEventListener(TimerEvent.TIMER, onTimer);
			}
			
			// Start the timer.
			_currentPetViewWindowTimer.start();
			
			function onTimer(e:TimerEvent):void
			{
				// Remove timer listener.
				_currentPetViewWindowTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				_currentPetViewWindowTimer.reset();
				_currentPetViewWindowTimer = null;
				
				// Swap the original pet image back in.
				if (_infoPanel)
				{
					_infoPanel.doImageSwap(originalPetImage, fadeDuration, clean);
				}
				else
				{
					clean();
				}
			}
			
			function clean():void
			{
				// Clean up the pet view window.
				petViewWindow.destroy();
				petViewWindow = null;
				_currentPetViewWindow = null;
			}
		}
		
		private function getDaysUntilCanName():Number
		{
			// If pet created time is 0, assume it is not accurate.
			if (_petCreatedTime < 1) return DAYS_TO_OWN_BEFORE_YOU_CAN_NAME;
			
			var daysOwned:Number = (Number(new Date().time) - _petCreatedTime) / 1000 / 60 / 60 / 24; // Convert miliseconds to days.
			daysOwned = Math.max(daysOwned, 0);
			return DAYS_TO_OWN_BEFORE_YOU_CAN_NAME - daysOwned;
		}
		
		private function resetPetName():void
		{
			// Determine first and second pet name.
			var names:Array = _petName.split(' ');
			var firstName:String = names[0];
			var secondName:String = names[1];
			
			// Reset names on info panel.
			_infoPanel.firstName = firstName;
			_infoPanel.secondName = secondName;
		}
		
		private function getFirstAndSecondPetName():String
		{
			var names:Array = _petName.split(' ');
			var firstName:String = names[0];
			var secondName:String = names[1];
			return firstName + ' ' + secondName;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onFeedClick(e:Event):void
		{
			PetManager.feedPetWithAvatarsFood(_localAvatar, _petInventoryId, _petOwnerAvatarId, onFeedComplete);
			
			function onFeedComplete():void
			{
				_infoPanel.petFoodCount--;
			}
		}
		
		private function onPlayClick(e:Event):void
		{
			// Trigger one of the pets animations and show the pet on the card.
			var petController:PetController = PetManager.playWithPet(_petInventoryId);
			// Show the pet view window so the user can see the pet's play animation.
			if (petController) showPetViewWindow(petController, 5000);
		}
		
		private function onLeashClick(e:Event):void
		{
			// Leash or unleash the pet.
			
			// Determine if the pet is owned by the local user.
			var isLocalPet:Boolean = (_localAvatar.avatarId == _petOwnerAvatarId);
			// Only the pet owner can leash/unleash.
			if (!isLocalPet) return;
			// Determine if the pet is leashed.
			var isPetLeashed:Boolean = (_localAvatar.leashedPetInventoryId == _petInventoryId);
			
			// Either leash or unleash the pet.
			if (isPetLeashed)
			{
				// Unleash pet.
				PetManager.unleashPet(_petInventoryId);
			}
			else
			{
				// Leash pet.
				PetManager.leashPetToAvatar(_localAvatar, _petInventoryId, _localAvatar.avatarId);
			}
		}
		
		private function onLeashedPetUpdate(e:Event):void
		{
			// Check if the local avatar still has this pet leashed.
			_infoPanel.isLeashed = (_localAvatar.leashedPetInventoryId == _petInventoryId);
		}
		
		private function onSelectedPetName(e:Event):void
		{
			// Save the pet name to the server.
			savePetName();
		}
		
		private function onPetFoodListComplete():void
		{
			var petFoodCount:int = _localAvatar.petFoodCount;
			_infoPanel.petFoodCount = petFoodCount;
			_infoPanel.foodVisible = true;
		}
		
		private function onAttemptedToNamePet(e:Event):void
		{
			// This gets called when user attempts to name pet when they shouldn't be able to.
			// Make sure the pet hasn't been named already.
			if (PetItem.isCustomPetName(_petName))
			{
				// This pet has already been named.
				SdgAlertChrome.show('You can only name your pet once.', 'Sorry!');
				return;
			}
			// Make sure they have owned the pet for long enough.
			var daysUntilCanName:Number = getDaysUntilCanName();
			if (daysUntilCanName > 0)
			{
				// User has not owned pet long enough to name the pet.
				SdgAlertChrome.show('You can name your pet after ' + Math.ceil(daysUntilCanName) + ' days.', 'Wait!');
				return;
			}
		}
		
	}
}