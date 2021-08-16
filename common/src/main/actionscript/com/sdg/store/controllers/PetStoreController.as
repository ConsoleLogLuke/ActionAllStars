package com.sdg.store.controllers
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.commands.GetPetListCommand;
	import com.sdg.components.controls.CustomMVPAlert;
	import com.sdg.components.dialog.InteractiveDialog;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.control.SdgFrontController;
	import com.sdg.events.GetPetListEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.manager.LevelManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarLevelStatus;
	import com.sdg.model.ItemType;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.StoreItem;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.store.IStoreModel;
	import com.sdg.store.StoreConstants;
	import com.sdg.store.StoreController;
	import com.sdg.store.view.PetStoreHomeView;
	import com.sdg.utils.Constants;
	import com.sdg.utils.ItemUtil;
	import com.sdg.utils.MainUtil;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.events.CloseEvent;
	
	
	/*
	 * Pet all the last minute changes 
	 */

	public class PetStoreController extends StoreController
	{
		public function PetStoreController(target:IEventDispatcher=null)
		{
			super(target);
			
			//var sdg:SdgFrontController = SdgFrontController.getInstance();				
			//sdg.addCommand(GetPetListEvent.GET_PET_LIST, GetPetListCommand);
		}
		
		public override function init(model:IStoreModel):void
		{
			super.init(model);
			
			// Send some messages to the Pet view so
			// it knows what to gray out.
			// This will completely break when we switch to a more datadriven approach.
			// This doesn't seem to be a concern when explained.
			
			try
			{
				var homeView:PetStoreHomeView = this._model.homeView as PetStoreHomeView;
				homeView.addEventListener('viewLoaded',onHomeViewLoaded);
			}
			catch(e:Error)
			{
				trace(e.getStackTrace());
			}
		}
		
		private function onHomeViewLoaded(e:Event):void
		{
			var homeView:PetStoreHomeView = this._model.homeView as PetStoreHomeView;
			var mc:MovieClip = homeView.getContent() as MovieClip;
			
			// So you can make the buttons invisible if they already own pets.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			
			// Load owned pets
			//var temp:Array = userAvatar.getInventoryListById(ItemType.PETS).toArray();
			//mc.petItemsOwned(userAvatar.getInventoryListById(ItemType.PETS).toArray());
			
			// Load Avatar Rank
			var levelStatus:AvatarLevelStatus = LevelManager.GetAvatarLevelStatus(userAvatar);
			if (levelStatus)
			{
				mc.setAvatarRank(levelStatus.levelIndex);
			}
			// Load Avatar Tokens
			mc.setAvatarTokens(userAvatar.currency.toString());
			
			// Get Pet List
			CairngormEventDispatcher.getInstance().addEventListener(GetPetListEvent.GET_PET_LIST_COMPLETED, onPetListReceived);
			CairngormEventDispatcher.getInstance().dispatchEvent(new GetPetListEvent( GetPetListEvent.GET_PET_LIST, userAvatar.id ));
		}
		
		protected function onPetListReceived(e:GetPetListEvent):void
		{
			var homeView:PetStoreHomeView = this._model.homeView as PetStoreHomeView;
			var mc:MovieClip = homeView.getContent() as MovieClip;
			mc.petItemsOwned(e.petIdArray);
			
			// set new currency total
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			mc.setAvatarTokens(userAvatar.currency.toString());
		}
		
		protected function confirmBuyBox(itemId:int,petName:String):void
		{
			// Load up a custom dialog box.
			var dialog:InteractiveDialog  = MainUtil.showDialog(InteractiveDialog, 
			{url:Environment.getApplicationUrl() + "/test/gameSwf/gameId/70/gameFile/pets_yes_no_Buttons.swf",id:""},
			false,false) as InteractiveDialog;
			
			dialog.addEventListener(Event.COMPLETE,onSwfLoaded,false,0,true);
			
			var loader:QuickLoader = dialog.content as QuickLoader;
			loader.addEventListener('BtnYesHit',onConfirmYes,false,0,true);
			loader.addEventListener('BtnNoHit',onConfirmNo,false,0,true);
			
			function onSwfLoaded(ev:Event):void
			{
				var swfObj:Object = loader.content;
				swfObj.setWarningText("Are you sure you want the " + petName + "?");
				
				// Determine which other message to give
				var userAvatar:Avatar = ModelLocator.getInstance().avatar;
				var levelStatus:AvatarLevelStatus = LevelManager.GetAvatarLevelStatus(userAvatar);
				if (levelStatus)
				{
					switch (levelStatus.levelIndex)
					{
						case 1:
							swfObj.setLevelText("You can only buy 1 pet.");
							break;
						case 2:
							swfObj.setLevelText("You can only buy 2 pets.");
							break;
						case 3:
							swfObj.setLevelText("You can only buy 3 pets.");
							break;
						case 4:
							swfObj.setLevelText("You can only buy 4 pets.");
							break;
						case 5:
							swfObj.setLevelText("You can only buy 5 pets.");
							break;
						default:
							swfObj.setLevelText("You can only buy a few pets.");
							break;
					}
				}
				
			}
			
			function onConfirmYes(ev:Event):void
			{
				onConfirmPurchase(itemId);
				dialog.close();
				
				//var homeView:PetStoreHomeView = _model.homeView as PetStoreHomeView;
				//var mc:MovieClip = homeView.getContent() as MovieClip;
				
				// So you can make the buttons invisible if they already own pets.
				//var userAvatar:Avatar = ModelLocator.getInstance().avatar;

				// Get Pet List
				//CairngormEventDispatcher.getInstance().addEventListener(GetPetListEvent.GET_PET_LIST_COMPLETED, onPetListReceived);
				//CairngormEventDispatcher.getInstance().dispatchEvent(new GetPetListEvent( GetPetListEvent.GET_PET_LIST, userAvatar.id ));
			}
			function onConfirmNo(ev:Event):void
			{
				// just remove the popup
				dialog.close();
			}
		}
		
		protected function onConfirmPurchase(itemId:int):void
		{
			// Load attributes of the item.
			var url:String = ItemUtil.GetItemAttributesUrl(itemId);
			var request:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlLoader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Get store item from loaded data.
				var itemXML:XML = new XML(urlLoader.data);
				var item:StoreItem = StoreItem.StoreItemFromXML(itemXML);
				if (item == null) return;

				// Buy the item.
				buyItem(item, true);
			}
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		protected override function storeUpdateOnPurchase():void
		{
			// Get new Pet List
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			CairngormEventDispatcher.getInstance().addEventListener(GetPetListEvent.GET_PET_LIST_COMPLETED, onPetListReceived);
			CairngormEventDispatcher.getInstance().dispatchEvent(new GetPetListEvent( GetPetListEvent.GET_PET_LIST, userAvatar.id ));
		}
		
		protected override function onHomeViewBuy(e:Event):void
		{
			
			var avatar:Avatar = ModelLocator.getInstance().avatar;
			if (avatar.membershipStatus == Constants.MEMBER_STATUS_GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}
			else if (avatar.membershipStatus == Constants.MEMBER_STATUS_FREE)
			{
				LoggingUtil.sendClickLogging(StoreConstants.getLoggingViewIdForStore(StoreConstants.STORE_ID_PET));
				var closeIdentifierForLogging:int = StoreConstants.getLoggingClickIdForStore(StoreConstants.STORE_ID_PET)
					
				CustomMVPAlert.show(Environment.getApplicationUrl() + "/test/gameSwf/gameId/82/gameFile/mvp_upsell_13.swf",
											closeIdentifierForLogging, onClose);
				
				function onClose(event:CloseEvent):void
				{
					var identifier:int = event.detail;
					
					if (identifier == closeIdentifierForLogging)
						MainUtil.goToMVP(identifier);
				}
			
				return;
			}
			// Try to get an item id.
			var params:Object = e as Object;
			var itemId:int = (params.itemId != null) ? params.itemId : -1;
			if (itemId < 0) return;
			if (itemId != 6300)
			{
				var petName:String = (params.itemName != null) ? params.itemName : "this pet";
				confirmBuyBox(params.itemId,petName);
			}
			else
			{
				onConfirmPurchase(itemId);
			}
		}
	}
}