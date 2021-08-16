package com.sdg.control.room
{
	import com.sdg.control.CairngormEventController;
	import com.sdg.control.room.itemClasses.*;
	import com.sdg.events.RoomEnumEvent;
	import com.sdg.events.RoomItemEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Room;
	import com.sdg.model.SdgItem;
	import com.sdg.view.IRoomView;
	
	public class RoomControllerBase extends CairngormEventController
	{
		protected static var _roomManager:RoomManager;
		
		protected var _roomView:IRoomView;
		protected var _room:Room;
		protected var _context:IRoomContext;
		protected var _localAvatar:Avatar;
		
		public function RoomControllerBase()
		{
			_roomManager = RoomManager.getInstance();
			_localAvatar = ModelLocator.getInstance().avatar;
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function getRoom():Room
		{
			return _room;
		}
		
		public function getItemController(item:SdgItem, createIfNull:Boolean = true):IRoomItemController
		{
			return _context.getItemController(item, createIfNull);
		}
		
		public function removeItemController(item:SdgItem):void
		{
			_context.removeItemController(item);
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		protected function cleanUp():void
		{
			// Remove room listeners.
			_room.removeEventListener(RoomEnumEvent.ITEM_ADDED, onItemAdded);
			_room.removeEventListener(RoomEnumEvent.ITEM_REMOVED, onItemRemoved);
			_room.removeEventListener(RoomEnumEvent.ENUM_REFRESH, onEnumRefresh);
			
			// Remove context listeners.
			_context.removeEventListener(RoomItemEvent.ADDED, onRoomItemAddedToContext);
			_context.removeEventListener(RoomItemEvent.REMOVED, onRoomItemRemovedFromContext);
		}
		
		protected function setUp():void
		{
			// Add room listeners.
			_room.addEventListener(RoomEnumEvent.ITEM_ADDED, onItemAdded);
			_room.addEventListener(RoomEnumEvent.ITEM_REMOVED, onItemRemoved);
			_room.addEventListener(RoomEnumEvent.ENUM_REFRESH, onEnumRefresh);
			
			// Add room context listeners.
			_context.addEventListener(RoomItemEvent.ADDED, onRoomItemAddedToContext);
			_context.addEventListener(RoomItemEvent.REMOVED, onRoomItemRemovedFromContext);
		}
		
		protected function handleAddedItemController(itemController:IRoomItemController):void
		{
			
		}
		
		protected function handleRemovedItemController(itemController:IRoomItemController):void
		{
			
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
			if (value == _context) return;
			
			// If there was previously a context, do a cleanup before setting the new one.
			if (_context) cleanUp();
			
			// Set new context.
			_context = value;
			if (_context)
			{
				_room = _context.room;
				_roomView = _context.roomView;
				_roomManager.roomContext = _context;
				
				// Handle context change.
				setUp();
			}
			else
			{
				_room = null;
			}
		}
		
		public function get userController():AvatarController
		{
			return _roomManager.userController;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		protected function onItemAdded(e:RoomEnumEvent):void
		{
			// Get reference to item.
			var item:SdgItem = e.item;
			// Get reference to item controller.
			// Create the controller if it doesn't exist.
			var itemController:IRoomItemController = getItemController(item, true);
		}
		
		protected function onItemRemoved(e:RoomEnumEvent):void
		{
			// Get reference to item.
			var item:SdgItem = e.item;
			// Remove controller from room context.
			removeItemController(item);
		}
		
		protected function onEnumRefresh(e:RoomEnumEvent):void
		{
			
		}
		
		private function onRoomItemAddedToContext(e:RoomItemEvent):void
		{
			handleAddedItemController(e.roomItemController);
		}
		
		private function onRoomItemRemovedFromContext(e:RoomItemEvent):void
		{
			handleRemovedItemController(e.roomItemController);
		}
		
	}
}