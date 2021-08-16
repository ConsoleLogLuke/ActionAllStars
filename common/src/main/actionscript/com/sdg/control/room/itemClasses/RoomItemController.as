package com.sdg.control.room.itemClasses
{
	import com.sdg.business.resource.*;
	import com.sdg.control.CairngormEventController;
	import com.sdg.control.room.IRoomContext;
	import com.sdg.control.room.RoomManager;
	import com.sdg.core.IProgressInfo;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.display.render.RenderObject;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.events.RoomItemEvent;
	import com.sdg.events.SimEvent;
	import com.sdg.factory.RoomItemDisplayFactory;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.ItemResolveStatus;
	import com.sdg.model.ItemType;
	import com.sdg.model.RoomLayerType;
	import com.sdg.model.SdgItem;
	import com.sdg.model.SpriteTemplate;
	import com.sdg.sim.core.SimEntity;
	import com.sdg.sim.entity.TileMapEntity;
	import com.sdg.sim.render.SimRenderObject;
	import com.sdg.utils.BindingUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.binding.utils.ChangeWatcher;
	
	public class RoomItemController extends CairngormEventController implements IRoomItemController
	{
		private static const DEFAULT_DISPLAY_FACTORY:RoomItemDisplayFactory = new RoomItemDisplayFactory();
		
		protected var _itemResources:RemoteResourceMap;
		private var _actionListeners:Object;
		private var _context:IRoomContext;
		protected var _display:IRoomItemDisplay;
		protected var _entity:RoomEntity;
		protected var _item:SdgItem;
		protected var _itemResolveStatus:uint;
		private var _bindingitemUpdated:ChangeWatcher;
		private var _hasEntityListeners:Boolean;
		
		public function RoomItemController()
		{
			_hasEntityListeners = false;
			_itemResolveStatus = ItemResolveStatus.NONE;
			_actionListeners = {};
			_itemResources = new RemoteResourceMap();
			
			_itemResources.addEventListener(Event.COMPLETE, itemResourcesCompleteHandler);
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function initialize(item:SdgItem):void
		{
			// Allow initialization only once and assert that item is not null.
			if (_item)
				throw new Error("Already initialized.");
			else if (!item)
				throw new ArgumentError("Argument 'item' must not be null.");
			
			_item = item;
			
			initializeEntity();
			initializeDisplay();
			
			// Bind to item updateCount.
			_bindingitemUpdated = BindingUtil.bindSetter(itemUpdated, _item, "updateCount", false, false, false);
			
			// Get item resources.
			var rscLocator:SdgResourceLocator = SdgResourceLocator.getInstance();
			_itemResources.setResource("spriteTemplate", rscLocator.getSpriteTemplate(_item.spriteTemplateId));
			_itemResources.load();
		}
		
		public function destroy():void
		{
			// Clean up change watcher.
			if(_bindingitemUpdated != null) _bindingitemUpdated.unwatch(); //jma cleanup
			
			// Remove item resource listeners.
			_itemResources.removeEventListener(Event.COMPLETE, itemResourcesCompleteHandler);
			
			// Remove entity listeners.
			if (_hasEntityListeners == true)
			{
				_entity.removeEventListener(SimEvent.VALIDATED, entityValidatedHandler);
			}
			
			// Remove from context.
			if (_context != null)
			{
				_context.removeItemDisplay(_display);
				if (_entity) _context.removeMapEntity(_entity);
			}
			
			// Clean up display.
			_display.removeEventListener(MouseEvent.CLICK, mouseClickHandler);
			_display.removeEventListener(RoomItemDisplayEvent.MOVE, onDisplayMove);
			_display.destroy();
			
			// Set objects to null to prepare them for garbage collection.
			_itemResources = null;
			_actionListeners = null;
			_context = null;
			_display = null;
			_entity = null;
			_item = null;
			_bindingitemUpdated = null;
		}
		
		public function getEditor():IRoomItemEditor
		{
			return new RoomEntityEditor(this);
		}
		
		/**
		 * Invokes the listener for the specified action.
		 */
		public function processAction(action:String, params:Object):void
		{
			var listener:Function = _actionListeners[action];
			
			if (listener != null) listener(params);
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		protected function contextChanged(oldContext:IRoomContext, context:IRoomContext):void
		{
			if (oldContext)
			{
				// Remove display.
				oldContext.removeItemDisplay(_display);
				
				// Remove entity.
				if (_entity) oldContext.removeMapEntity(_entity);
			}
			
			if (context)
			{
				// Determine which map layer to use.
				var layerType:uint = _item.layerType;
				
				// See if it's an inventory item.
				var inventoryItem:InventoryItem = _item as InventoryItem;
				// If it's a wall item set layer type to WALL.
				if (layerType < 3 && inventoryItem != null && inventoryItem.itemTypeId == ItemType.WALL_ITEM) layerType = RoomLayerType.WALL;
				_item.layerType = layerType;
				
				// Add display.
				context.addItemDisplay(layerType, _display);
				// Add entity.
				if (_entity) context.addMapEntity(layerType, _entity);
			}
		}
		
		protected function itemUpdated():void
		{
			if (_entity)
			{
				_entity.orientation = _item.orientation;
				_entity.col = _item.x;
				_entity.row = _item.y;
			}
			else if (_display)
			{
				_display.x = _item.x;
				_display.y = _item.y;
			}
		}
		
		protected function itemResourcesCompleteHandler(event:Event):void
		{
			var st:SpriteTemplate = SpriteTemplate(_itemResources.getContent("spriteTemplate"));
			var renderItem:RenderObject = _display.renderItem;
			
			if (renderItem)
			{
				renderItem.originX = st.registrationX;
				renderItem.originY = st.registrationY;
			}
			
			if (_entity)
			{
				_entity.width = st.mapWidth;
				_entity.height = st.mapHeight;
			}
			
			itemUpdated();
		}
		
		protected function createDisplay():IRoomItemDisplay
		{
			// Use the default display factory to instantiate an instance of the display object.
			var displayFactory:RoomItemDisplayFactory = DEFAULT_DISPLAY_FACTORY;
			displayFactory.setItem(_item);
			return displayFactory.createInstance() as IRoomItemDisplay;
		}
		
		protected function initializeDisplay():void
		{
			// If display is null, instatiate the display object.
			if (!_display) _display = createDisplay();
			
			var renderItem:SimRenderObject = _display.renderItem as SimRenderObject;
			if (renderItem != null) renderItem.entity = _entity;
			
			addDisplayListeners();
			
			_item.display = _display;
		}
		
		protected function addDisplayListeners():void
		{
			_display.addEventListener(MouseEvent.CLICK, mouseClickHandler);
			_display.addEventListener(RoomItemDisplayEvent.MOVE, onDisplayMove);
		}
		
		protected function initializeEntity():void
		{
			// If the item layer type is a map type layer.
			if (RoomLayerType.isMapType(_item.layerType))
			{
				// Get a reference to the entity object.
				_entity = _item.entity;
				
				// Add event listeners to the entity.
				_entity.addEventListener(SimEvent.VALIDATED, entityValidatedHandler);
				
				// Set flag.
				_hasEntityListeners = true;
			}
		}
		
		protected function entityValidatedHandler(event:SimEvent):void
		{
			var flags:int = entity.stateFlags;
			
			if (flags & SimEntity.ROTATED_FLAG)
			{
				_item.orientation = _entity.orientation;
				_display.orientation = _entity.orientation;
			}
			
			if (flags & SimEntity.MOVED_FLAG)
			{
				_item.x = _entity.col;
				_item.y = _entity.row;
			}
		}
		
		/**
		 * Notifies the RoomManager of the action, so that it
		 * can be broadcast to other users in the room.
		 */
		protected function commitAction(action:String, params:Object, consequence:Object = null):void
		{
			RoomManager.getInstance().sendItemAction(_item, action, params, consequence);
		}
		
		/**
		 * Registers a listener method for the specified action.
		 * The method must accept a single argument of type Object 
		 * that contains the parameters of the action.
		 */
		protected function setActionListener(action:String, listener:Function):void
		{
			_actionListeners[action] = listener;
		}
		
		protected function removeActionListener(action:String):void
		{
			_actionListeners[action] = null;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get context():IRoomContext
		{
			return _context;
		}
		
		public function set context(value:IRoomContext):void
		{
			if (value != _context) 
			{
				var oldContext:IRoomContext = _context;
				_context = value;
				contextChanged(oldContext, _context);
			}
		}
		
		public function get display():IRoomItemDisplay
		{
			return _display;
		}
		
		public function get entity():RoomEntity
		{
			return _entity;
		}
		
		public function get item():SdgItem
		{
			return _item;
		}
		
		public function get progressInfo():IProgressInfo
		{
			return display.progressInfo;
		}
		
		public function get itemResolveStatus():uint
		{
			return _itemResolveStatus;
		}
		public function set itemResolveStatus(value:uint):void
		{
			if (value == _itemResolveStatus) return;
			
			_itemResolveStatus = value;
			
			_display.itemResolveStatus = _itemResolveStatus;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onDisplayMove(e:RoomItemDisplayEvent):void
		{
			dispatchEvent(new RoomItemEvent(RoomItemEvent.MOVE, this));
		}
		
		protected function mouseClickHandler(event:MouseEvent):void
		{
			// Determine inventory item click handlers.
			var inventoryItem:InventoryItem = item as InventoryItem;
			if (inventoryItem == null) return;
			// Call abstarct click handlers.
			var clickHandlerIds:Array = inventoryItem.abstractClickHandlerIds;
			var i:int = 0;
			var len:int = clickHandlerIds.length;
			for (i; i < len; i++)
			{
				var clickHandlerId:String = clickHandlerIds[i];
				AbstractItemInteractionHandlers.handleClick(this, clickHandlerId);
			}
		}
		
	}
}