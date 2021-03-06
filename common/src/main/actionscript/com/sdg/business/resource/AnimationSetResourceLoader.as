package com.sdg.business.resource
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.animation.AnimationSet;
	import com.sdg.animation.AnimationSetResource;
	import com.sdg.control.room.RoomManager;
	import com.sdg.display.AvatarSprite;
	import com.sdg.events.AvatarApparelEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.ItemType;
	import com.sdg.model.SdgItem;
	import com.sdg.model.SdgItemClassId;
	import com.sdg.utils.Constants;
	import com.sdg.utils.PreviewUtil;

	import flash.events.Event;

	import mx.core.FlexGlobals; // Non-SDG - Application to FlexGlobals

	public class AnimationSetResourceLoader extends CompositeRemoteResource
	{
		protected var item:SdgItem;
		protected var resourceList:RemoteResourceList;
		private var _content:Array;
		private var _layerLookup:Object = new Object();
		private const MAX_TRIES:int = 4;
		private var _numTries:int = 0;

		public function AnimationSetResourceLoader(item:SdgItem = null):void
		{
			resourceList = new RemoteResourceList();

			super(resourceList);

			this.item = item;

			addEventListener(Event.COMPLETE, completeHandler);
		}

		override public function destroy():void
		{
			// Handle cleanup.
			removeEventListener(Event.COMPLETE, completeHandler);

			resourceList.reset();

			// Set objects to null to prepare them for garbage collection.
			resourceList = null;
			_content = null;
			_layerLookup = null;
			item = null;

			super.destroy();
		}

		override public function get content():*
		{
			return _content;
		}

		override public function load():void
		{
			reset();
			resourceList.removeAll();

			// is this an avatar?
			if (item is Avatar)
			{
				loadAvatar(true);
				return;
			}

			var locator:SdgResourceLocator = SdgResourceLocator.getInstance();
			var numLayers:uint = item.numLayers;

			// Add animationSetResources for each animationSetId.
			for each (var animId:uint in item.animationSetIds)
			{
				// Create animationSetResources.
				var animResourceMap:RemoteResourceMap = new RemoteResourceMap();

				// Add animationSet.
				animResourceMap.setResource("animationSet", locator.getAnimationSet(animId));

				// Create spriteSheet list.
				var spriteSheets:RemoteResourceList = new RemoteResourceList();

				var id:uint = (item is InventoryItem) ? InventoryItem(item).itemId : item.id;

				// Add spriteSheet for each layer.
				for (var layer:int = 0; layer < numLayers; layer++)
				{
					spriteSheets.addResource(locator.getSpriteSheet(
						item.itemClassId, id, animId, item.spriteTemplateId, layer, item.version));
				}

				// Add spriteSheet list to animationSetResources.
				animResourceMap.setResource("spriteSheets", spriteSheets);

				// Add animationSetResources to list.
				resourceList.addResource(animResourceMap);
			}

			super.load();
		}

		public function loadAvatar(queue:Boolean = true):Boolean
		{
			// Returns true if load begins.

			var avatar:Avatar = this.item as Avatar;
			if (avatar == null)
			{
				trace("Error: AnimationSetResourceLoader - loadAvatar was called on a item that is not an avatar!");
				return false;
			}

			// if we don't have the apparel list for this avatar, get it first
	    	if (!avatar.hasApparel())
        	{
        		if (_numTries++ > MAX_TRIES) return false;
		   		CairngormEventDispatcher.getInstance().addEventListener(AvatarApparelEvent.AVATAR_APPAREL_COMPLETED, onApparelListCompleted);
				CairngormEventDispatcher.getInstance().dispatchEvent(new AvatarApparelEvent(avatar));
				return false;
        	}
        	else
        	{
        		_numTries = 0;
        	}

			if (queue)
			{
				AvatarLoadingQueue.getInstance().queueForLoading(this);
				return false;
			}

    		var locator:SdgResourceLocator = SdgResourceLocator.getInstance();
			var animResourceMap:RemoteResourceMap = new RemoteResourceMap();
			var spriteSheets:RemoteResourceList = new RemoteResourceList();

			// Hard code animation set.
			// This is the animation set used for "optimized sprite sheets",
			// implemented in October 2010.
			var animationSet:int = 201;
			var contextId:int = animationSet;

  			// Add animationSet.
			animResourceMap.setResource("animationSet", locator.getAnimationSet(animationSet));

			if (avatar.isWearingSuits)
			{
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SUITS), Constants.LAYER_SUIT, contextId);

				setWalkSpeed(false);
			}
			// are we wearing a skateboarding outfit?
			else if (avatar.isWearingSkateboardingOutfit)
			{
				// load the skateboarding spritesheets
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.BODY), Constants.LAYER_SKIN_SKATEBOARDING, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SHIRTS), Constants.LAYER_SHIRT_LOWER_SKATEBOARDING, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SHOES), Constants.LAYER_SHOES_LOWER_SKATEBOARDING, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SHOES), Constants.LAYER_SHOES_UPPER_SKATEBOARDING, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.PANTS), Constants.LAYER_PANTS_SKATEBOARDING, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SHIRTS), Constants.LAYER_SHIRT_TORSO_SKATEBOARDING, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.GLASSES), Constants.LAYER_GLASSES_SKATEBOARDING, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.HAIR), Constants.LAYER_HAIR_SKATEBOARDING, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.HAT), Constants.LAYER_HEADGEAR_SKATEBOARDING, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SHIRTS), Constants.LAYER_SHIRT_UPPER_SKATEBOARDING, contextId);

				setWalkSpeed(true);
			}
			else
			{
				// create resouces for the spritesheet layers
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.BODY), Constants.LAYER_SKIN, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SHIRTS), Constants.LAYER_SHIRT_LOWER, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SHIRTS), Constants.LAYER_SHIRT_TORSO, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.EYES), Constants.LAYER_EYES, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.MOUTH), Constants.LAYER_MOUTH, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SHOES), Constants.LAYER_SHOES_LOWER, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SHOES), Constants.LAYER_SHOES_UPPER, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.PANTS), Constants.LAYER_PANTS, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.GLASSES), Constants.LAYER_GLASSES, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.HAIR), PreviewUtil.getHairLayerId(avatar, true), contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.HAT), Constants.LAYER_HAT, contextId);
				addResourceForAvatarLayer(locator, spriteSheets, avatar, PreviewUtil.getLayerId(PreviewUtil.SHIRTS), Constants.LAYER_SHIRT_UPPER, contextId);

				setWalkSpeed(false);
			}

			// Add spriteSheet list to animationSetResources.
			animResourceMap.setResource("spriteSheets", spriteSheets);

			// Add animationSetResources to list.
			resourceList.addResource(animResourceMap);

			super.load();

			return true;

			function setWalkSpeed(isSkateboarding:Boolean):void
			{
				if (RoomManager.getInstance().userController && avatar.avatarId == RoomManager.getInstance().userController.avatar.avatarId)
				{
					if (isSkateboarding)
					{
						// increase the avatar speed by 75%
						RoomManager.getInstance().userController.walkSpeedMultiplier = 1.75;
					}
					else
					{
						// force the avatar to normal speed
						var speedShoesButton:Object = Object(FlexGlobals.topLevelApplication.mainLoader.child.speedShoesBtn.content);
						if (speedShoesButton.effectOn == false)
							RoomManager.getInstance().userController.walkSpeedMultiplier = 1;
					}
				}
			}
		}

		override public function reset():void
		{
			super.reset();
			_content = null;
		}

		protected function addResourceForAvatarLayer(locator:SdgResourceLocator, spriteSheets:RemoteResourceList, avatar:Avatar, avatarApparelIndex:int, layerId:int, contextId:int = 101):void
		{
			var apparelItem:InventoryItem = avatar.apparel.getItemAt(avatarApparelIndex) as InventoryItem;
			if (!apparelItem) return;
			contextId = (apparelItem.animationSetIds[0]) ? apparelItem.animationSetIds[0] : contextId;
			spriteSheets.addResource(locator.getAvatarSpriteSheetLayer(apparelItem.itemId, apparelItem.spriteTemplateId, layerId, contextId));
		}

        protected function onApparelListCompleted(ev:AvatarApparelEvent):void
		{
           	// remove our event listener
	   		CairngormEventDispatcher.getInstance().removeEventListener(AvatarApparelEvent.AVATAR_APPAREL_COMPLETED, onApparelListCompleted);

			ev.stopImmediatePropagation();

			// put those clothes on
			loadAvatar(true);
		}

		protected function completeHandler(event:Event):void
		{
			_content = [];

			var animResources:Array = resourceList.getAllResources();

			// Create AnimationSetResources.

			// Use composite filters for AVATARS, PETS, NPCs ONLY.
			var compositeFilters:Array = null;
			if (item.itemClassId == SdgItemClassId.AVATAR || item.itemTypeId == ItemType.PETS || item.itemTypeId == ItemType.NPC)
			{
				compositeFilters = AvatarSprite.DefaultAvatarCompositeFilters;
			}
			for each (var animResourceMap:RemoteResourceMap in animResources)
			{
				var animationSet:AnimationSet = animResourceMap.getContent("animationSet");
				var spriteSheets:Array = RemoteResourceList(animResourceMap.getResource("spriteSheets")).getAllContents();
				var animResource:AnimationSetResource = new AnimationSetResource(animationSet, spriteSheets, item, compositeFilters);

				RemoteResourceList(animResourceMap.getResource("spriteSheets")).removeAll();
				_content.push(animResource);
			}
		}
    }
}
