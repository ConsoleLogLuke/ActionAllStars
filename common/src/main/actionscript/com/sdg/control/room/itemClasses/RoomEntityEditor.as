package com.sdg.control.room.itemClasses
{
	import com.sdg.components.controls.RoomEntityInspector;
	import com.sdg.control.room.RoomManager;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.display.RoomItemUIFlags;
	import com.sdg.display.render.RenderLayer;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.ItemType;
	import com.sdg.model.Room;
	import com.sdg.model.RoomLayerType;
	import com.sdg.model.SdgItem;
	import com.sdg.sim.map.TileMap;
	import com.sdg.view.IRoomView;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import mx.core.FlexGlobals; // Non-SDG - Application to FlexGlobals

	public class RoomEntityEditor implements IRoomItemEditor
	{
		protected var entity:RoomEntity;
		protected var inspector:RoomEntityInspector;
		protected var renderLayer:RenderLayer;
		protected var roomView:IRoomView;
		protected var uiState:int;

		// Reference points for rotation and dragging.
		protected var mapStartPoint:Point = new Point();
		protected var mouseStartPoint:Point = new Point();

		private var _owner:IRoomItemController;
		private var _inspectable:Boolean = true;

		public function get owner():IRoomItemController
		{
			return _owner;
		}

		public function get isDragging():Boolean
		{
			return (uiState & RoomItemUIFlags.DRAGGING) > 0;
		}

		public function get isValid():Boolean
		{
			return (uiState & RoomItemUIFlags.INVALID) == 0;
		}

		public function get inspectable():Boolean
		{
			return _inspectable;
		}

		public function set inspectable(value:Boolean):void
		{
			_inspectable = value;
			updateUIState();
		}

		public function get selected():Boolean
		{
			return (uiState & RoomItemUIFlags.SELECTED) != 0; // Non-SDG - manually convert the int to a boolean
		}

		public function set selected(value:Boolean):void
		{
			setUIState(RoomItemUIFlags.SELECTED, value)
		}

		/**
		 * Constructor.
		 */
		public function RoomEntityEditor(owner:IRoomItemController)
		{
			_owner = owner;
			entity = _owner.entity;
			roomView = _owner.context.roomView;

			renderLayer = roomView.getRenderLayer(_owner.item.layerType);

			inspector = new RoomEntityInspector();
			inspector.display = _owner.display;
			inspector.addEventListener("removeItem", inspectorRemoveHandler);
			inspector.addEventListener("rotateItem", inspectorRotateHandler);

			validatePosition();
		}

		public function startDrag(relative:Boolean = true):void
		{
			setUIState(RoomItemUIFlags.DRAGGING, true);

			mouseStartPoint = renderLayer.globalToLocal(roomView.mouseX, roomView.mouseY);

			mapStartPoint.x = (relative) ? entity.x : mouseStartPoint.x;
			mapStartPoint.y = (relative) ? entity.y : mouseStartPoint.y;

			FlexGlobals.topLevelApplication.systemManager.addEventListener(MouseEvent.MOUSE_MOVE, dragHandler);
			FlexGlobals.topLevelApplication.systemManager.addEventListener(MouseEvent.MOUSE_UP, dropHandler);
		}

		public function stopDrag():void
		{
			setUIState(RoomItemUIFlags.DRAGGING, false);

			entity.validateNow();
			if (!validatePosition())
			{
				entity.x = mapStartPoint.x;
				entity.y = mapStartPoint.y;
				validatePosition();
			}
			else
			{
				mapStartPoint.x = entity.x;
				mapStartPoint.y = entity.y;
			}

			FlexGlobals.topLevelApplication.systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, dragHandler);
			FlexGlobals.topLevelApplication.systemManager.removeEventListener(MouseEvent.MOUSE_UP, dropHandler);
		}

		protected function dragHandler(event:MouseEvent):void
		{
			var p:Point = renderLayer.globalToLocal(roomView.mouseX, roomView.mouseY);

			entity.x = mapStartPoint.x + p.x - mouseStartPoint.x;
			entity.y = mapStartPoint.y + p.y - mouseStartPoint.y;

			if (validatePosition())
			{
				entity.snapToGrid();
				entity.validateNow();
			}
			else
			{
				// Position is not valid.

				// If it's the wall layer,
				// Check if it is valid on the other wall.
				var item:SdgItem = _owner.item;
				if (item == null) return;
				var layerType:int = item.layerType;
				if (layerType == RoomLayerType.WALL || layerType == RoomLayerType.LEFT_WALL || layerType == RoomLayerType.RIGHT_WALL)
				{
					// Get a reference to the room.
					var room:Room = roomView.getRoomController().getRoom();

					var validMap:TileMap = room.getValidMapForEntity(entity, [RoomLayerType.LEFT_WALL, RoomLayerType.RIGHT_WALL]);
					if (validMap != null)
					{
						var mapLayerIndex:uint = room.getMapLayerIndex(validMap);
						if (_owner.item.layerType != mapLayerIndex)
						{
							// Move the entity to another map layer.
							_owner.context.changeEntityMap(_owner.entity, mapLayerIndex);
							_owner.item.layerType = mapLayerIndex;

							// Rotate the item if necesary.
							if (mapLayerIndex == RoomLayerType.LEFT_WALL && entity.orientation != 0 && entity.orientation != 180)
							{
								entity.nextOrientation();
							}
							else if (mapLayerIndex == RoomLayerType.RIGHT_WALL && entity.orientation != 90 && entity.orientation != 270)
							{
								entity.nextOrientation();
							}
						}
					}
				}
			}
		}

		protected function dropHandler(event:MouseEvent):void
		{
			stopDrag();
		}

		protected function validatePosition():Boolean
		{
			var valid:Boolean = entity.validateOccupancy();

			setUIState(RoomItemUIFlags.INVALID, !valid);

			if (valid != isValid)
			{
				_owner.context.room.flagItem(_owner.item, Room.ITEM_VALID_FLAG, valid);
			}

			return valid;
		}

		protected function setUIState(flags:int, value:Boolean):void
		{
			if (value != ((flags & uiState) > 0))
			{
				uiState = (value) ? uiState | flags : uiState & ~flags;
				updateUIState();
			}
		}

		protected function updateUIState():void
		{
			// Update display.
			var display:IRoomItemDisplay = _owner.display;
			if (display == null) return;
			display.showUIState(uiState);

			// Update inspector visibility.
			if (_inspectable && selected && !isDragging)
			{
				roomView.addPopUp(inspector);
				inspector.show();
			}
			else
			{
				roomView.removePopUp(inspector);
				inspector.hide();
			}
		}

		protected function inspectorRemoveHandler(event:Event):void
		{
			roomView.removePopUp(inspector);
			inspector.hide();
			_owner.context.room.removeItem(_owner.item);
			RoomManager.getInstance().itemCount--;
		}

		protected function inspectorRotateHandler(event:Event):void
		{
			entity.x = mapStartPoint.x;
			entity.y = mapStartPoint.y;
			entity.nextOrientation();

			validatePosition();
		}
	}
}
