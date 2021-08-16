package com.sdg.control.room
{
	import com.sdg.business.resource.LoaderResource;
	import com.sdg.business.resource.ResourceInfo;
	import com.sdg.collections.QuickMap;
	import com.sdg.components.controls.ProgressAlertChrome;
	import com.sdg.components.games.InvitePanel;
	import com.sdg.control.room.itemClasses.*;
	import com.sdg.core.IProgressInfo;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.display.render.RenderLayer;
	import com.sdg.events.RoomItemEvent;
	import com.sdg.factory.RoomItemControllerFactory;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Room;
	import com.sdg.model.RoomLayerType;
	import com.sdg.model.SdgItem;
	import com.sdg.model.SdgItemClassId;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.sim.SimEngine;
	import com.sdg.sim.core.ISimulation;
	import com.sdg.sim.map.*;
	import com.sdg.sim.render.IsoRenderLayer;
	import com.sdg.util.AssetUtil;
	import com.sdg.view.IRoomView;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	
	import mx.core.Application;
	
	public class RoomContext extends EventDispatcher implements IRoomContext
	{
		protected var backgroundImageRsc:LoaderResource;
		protected var itemControllerMap:QuickMap = new QuickMap(true);
		
		private var _simEngine:SimEngine;
		private var _room:Room;
		private var _roomView:IRoomView;
		private var _itemControllerFactory:RoomItemControllerFactory;
		private var _bgProgressAlert:ProgressAlertChrome;
		private var _localAvatarController:AvatarController;
		
		public function RoomContext(simEngine:SimEngine, room:Room, roomView:IRoomView, itemControllerFactory:RoomItemControllerFactory)
		{
			_simEngine = simEngine;
			_room = room;
			_roomView = roomView;
			_itemControllerFactory = new RoomItemControllerFactory();
			
			setUpRoom();
			
			_roomView.enabled = true;
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function setUpRoom():void
		{
			// Add tilemap layers to engine.
			for (var i:int = 0; i < room.numLayers; i++)
			{
				var mapLayer:TileMap = room.getMapLayer(i);
				if (mapLayer) _simEngine.addSimulation(mapLayer);
			}
			
			// Floor matrix.
			// Hard Coded = VERY BAD!
			var floorMatrix:Matrix = new Matrix();
			var tileSize:Number = TileMap.TILE_SIZE;
			var isoAngle:Number = TileMap.ISO_ANGLE;
			floorMatrix.scale(tileSize, tileSize); // tile size.
			floorMatrix.rotate(Math.PI / 4);
			floorMatrix.scale(1, isoAngle / 90);
			floorMatrix.tx = 462.5;
			floorMatrix.ty = 100;
			
			// Add render layers.
			addPixelRenderLayer(RoomLayerType.BACKGROUND, _roomView.width, _roomView.height);
			//addPixelRenderLayer(RoomLayerType.WALL, 0, 0);
			addMapRenderLayer(RoomLayerType.WALL, floorMatrix);
			addMapRenderLayer(RoomLayerType.LEFT_WALL, floorMatrix);
			addMapRenderLayer(RoomLayerType.RIGHT_WALL, floorMatrix);
			addMapRenderLayer(RoomLayerType.FLOOR, floorMatrix);
			addPixelRenderLayer(RoomLayerType.FOREGROUND, roomView.width, roomView.height);
			
			// Load background image.
			roomView.visible = false;
			_bgProgressAlert = ProgressAlertChrome.show("Loading Room...", room.name, null, null, true);
			backgroundImageRsc = new LoaderResource(new ResourceInfo(room.backgroundUrl, null, 150000));
			backgroundImageRsc.addEventListener(Event.COMPLETE, backgroundImageCompleteHandler);
			backgroundImageRsc.load();
		}
		
		public function clear():void
		{
			// Remove all tilemaps from the simEngine.
			_simEngine.removeAllSimulations();
			
			// Remove all render layers and background from the view.
			roomView.clear();
			
			// Prevent background image from loading.
			backgroundImageRsc.reset();
			
			// Remove all item controllers.
			removeAllItemControllers();
			itemControllerMap = new QuickMap(true);
			
			_roomView.enabled = false;
		}
		
		public function addItemController(item:SdgItem, controller:IRoomItemController):void
		{
			itemControllerMap[item] = controller;
			controller.context = this;
			
			dispatchEvent(new RoomItemEvent(RoomItemEvent.ADDED, controller));
		}
		
		public function getItemController(item:SdgItem, createIfNull:Boolean = true):IRoomItemController
		{
			// Get a reference to the item controller.
			var controller:IRoomItemController = itemControllerMap[item];
			
			// Possibly create an item controller if we couldn't find one.
			if (controller == null)
			{
				if (createIfNull == true)
				{
					if (item.itemClassId == SdgItemClassId.AVATAR && item.avatarId == ModelLocator.getInstance().user.avatarId)
					{
						controller = RoomManager.getInstance().userController;
					}
					else
					{
						_itemControllerFactory.setItem(item);
						controller = _itemControllerFactory.createInstance() as IRoomItemController;
					}
					
					addItemController(item, controller);
				}
				else
				{
					return null;
				}
			}
			
			return controller;
		}
		
		public function getItemControllerWithInventoryId(inventoryItemId:int):IRoomItemController
		{
			for each (var roomItemController:IRoomItemController in itemControllerMap)
			{
				if (roomItemController.item && roomItemController.item.id == inventoryItemId) return roomItemController;
			}
			
			return null;
		}
		
		public function removeItemController(item:SdgItem):void
		{
			// Get a reference to the item controller.
			var itemController:IRoomItemController = itemControllerMap[item];
			
			// Make sure we have an item controller.
			if (itemController == null) return;
			
			// Dispatch removed event.
			dispatchEvent(new RoomItemEvent(RoomItemEvent.REMOVED, itemController));
			
			// Check if the item begin removed is an Avatar.
			if (item.itemClassId == SdgItemClassId.AVATAR)
			{
				// Get avatar controller.
				var avatarController:AvatarController = itemController as AvatarController;
				
				// Make sure it's not the local user avatar.
				if (item.avatarId != ModelLocator.getInstance().user.avatarId)
				{
					// first let any board games know that we've left
					if (ModelLocator.getInstance().currentGameSessionId.length > 0)
						avatarController.boardGameAction(ModelLocator.getInstance().currentGameId, ModelLocator.getInstance().currentGameSessionId, ModelLocator.getInstance().currentGameLevel, [avatarController.avatar.avatarId], avatarController.avatar.avatarId, "leaveGame", avatarController.avatar.avatarId.toString());
						
					if (RoomManager.getInstance().userController.invitePanelOn)
					{
					    var invitePanel:InvitePanel = InvitePanel(Application.application.mainLoader.child.invitePanel);
		                invitePanel.removePlayerLocal(item.avatarId);
					}		
						 
					avatarController.destroy();		// jma destroy called if avatar is not system avatar
				 }
			}
			else
			{
				itemController.destroy();
			}
			
			// These things will be done for all item controllers.
			itemController.context = null; // system avatar needs this since he is changing rooms not just exiting
			itemControllerMap.remove(item);
		}
		
		public function removeAllItemControllers():void
		{
			for each (var controller:IRoomItemController in itemControllerMap)
			{
				controller.context = null;
			}
		}
		
		public function addItemDisplay(layer:uint, display:IRoomItemDisplay):void
		{
			roomView.addItemDisplay(layer, display);
		}
		
		public function removeItemDisplay(display:IRoomItemDisplay):void
		{
			if( display != null )
			{
				// remove the object from the room
				roomView.removeItemDisplay(display);

				// destroy RoomItemDesplay objects ie AvatarSprite, CharacterSprite etc
				// RoomItemDisplayBase - interface is in IRoomItemDisplay.as

				display.destroy();	// null out for our local server test	
			}
			else 
			{
				trace( "Error attempting to remove null display object" );
			}
		}
		
		public function addMapEntity(layer:uint, entity:RoomEntity):void
		{
			// Default WALL layer to left wall.
			if (layer == RoomLayerType.WALL) layer = RoomLayerType.LEFT_WALL;
			
			var mapLayer:TileMap = room.getMapLayer(layer);
			if (mapLayer) mapLayer.addMember(entity);
		}
		
		public function removeMapEntity(entity:RoomEntity):void
		{
			var mapLayer:ISimulation = _simEngine.getSimulationContaining(entity);
			if (mapLayer) mapLayer.removeMember(entity);
		}
		
		public function changeEntityMap(entity:RoomEntity, newMapLayer:uint):void
		{
			// Remove the entity from it's current map.
			removeMapEntity(entity);
			
			var mapLayer:TileMap = room.getMapLayer(newMapLayer);
			if (mapLayer) mapLayer.addMember(entity);
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		protected function addPixelRenderLayer(index:uint, width:uint, height:uint):void
		{
			var layer:RenderLayer = new RenderLayer(width, height);
			layer.id = index;
			roomView.addRenderLayer(index, layer);
		}
		
		protected function addMapRenderLayer(index:uint, matrix:Matrix):void
		{
			var map:TileMap = room.getMapLayer(index);
			var w:int = (map) ? map.columns : 0;
			var h:int = (map) ? map.rows : 0;
			var layer:RenderLayer = new IsoRenderLayer(w, h, matrix, true);
			layer.id = index;
			roomView.addRenderLayer(index, layer);
		}
		
		////////////////////
		// GET?SET METHODS
		////////////////////
		
		public function get room():Room
		{
			return _room;
		}
		
		public function get roomView():IRoomView
		{
			return _roomView;
		}
		
		public function get progressInfo():IProgressInfo
		{
			return backgroundImageRsc;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		protected function backgroundImageCompleteHandler(event:Event):void
		{
			var bgSWF:Sprite = backgroundImageRsc.content;
			var bgObject:Object = bgSWF;
			
			roomView.background = bgSWF;
			bgSWF.addEventListener(Event.ENTER_FRAME, onBackgroundEnterFrame);
			var serverDateTime:Date = ModelLocator.getInstance().serverDate;
			var minutes:String = serverDateTime.getMinutes().toString();
			if (minutes.length == 1) minutes = '0' + minutes;
			
			if (bgObject.hasOwnProperty('time'))
				bgObject.time = serverDateTime.getHours() + ':' + minutes + ':' + serverDateTime.getSeconds();
		
			if (bgObject.hasOwnProperty('applicationUrl'))
				bgObject.applicationUrl = Environment.getApplicationUrl();
			
			
			// If it's a private room, load a new asset that contains the floor star
			// and place it on top of the background.
			// This was a workaround so that "Angry" would not have to modify 100+ assets with the new star look.
			if (_room.id.indexOf('private') == 0)
			{
				var layoutId:int = _room.layoutId;
				// Check for the legacy layout id (106). Use the veteran layout (140).
				if (layoutId == 106) layoutId = 140;
				var floorStarLayerUrl:String = AssetUtil.GetGameAssetUrl(99, 'floor_star_' + layoutId + '.swf');
				var floorStarLoader:QuickLoader = new QuickLoader(floorStarLayerUrl, onFloorStarComplete);
			}
			
			function onFloorStarComplete():void
			{
				// Add the new star to the background.
				bgSWF.addChild(floorStarLoader.content);
				// Also attempt to hide the old star by using the instance name.
				var oldStar:DisplayObject = bgObject['starArrow2'] as DisplayObject;
				if (oldStar) oldStar.visible = false;
			}
		}
		
		protected function onBackgroundEnterFrame(event:Event):void
		{
			DisplayObject(event.currentTarget).removeEventListener(Event.ENTER_FRAME, onBackgroundEnterFrame);
			trace("onBackgroundEnterFrame");
			if (_bgProgressAlert)
				_bgProgressAlert.close();
			roomView.visible = true;
		}
		
	}
}