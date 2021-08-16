package com.sdg.control.room
{
	import com.sdg.components.controls.MVPAlert;
	import com.sdg.components.controls.TurfItem;
	import com.sdg.control.room.itemClasses.*;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.events.TurfItemDragEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.ItemType;
	import com.sdg.utils.MainUtil;
	
	import flash.events.MouseEvent;
	
	import mx.core.IUIComponent;
	import mx.events.CloseEvent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	public class PrivateRoomEditor extends RoomUIController
	{
		private var _itemEditor:IRoomItemEditor;
		
		public function PrivateRoomEditor()
		{
			
		}
		
		override protected function cleanUp():void
		{
			super.cleanUp();
			
			_roomView.removeEventListener(DragEvent.DRAG_ENTER, menuItemDragEnterHandler);
			_roomView.removeEventListener(DragEvent.DRAG_DROP, menuItemDragDropHandler);
			_roomView.removeEventListener(DragEvent.DRAG_EXIT, menuItemDragExitHandler);
			_roomView.removeEventListener(RoomItemDisplayEvent.MOUSE_DOWN_ITEM, onMouseDownRoomItem);
			
			setEditTarget(null);
		}
		
		override protected function setUp():void
		{
			super.setUp();
			
			_room.removeAllAvatars();
			
			_roomView.addEventListener(DragEvent.DRAG_ENTER, menuItemDragEnterHandler);
			_roomView.addEventListener(DragEvent.DRAG_DROP, menuItemDragDropHandler);
			_roomView.addEventListener(DragEvent.DRAG_EXIT, menuItemDragExitHandler);
			_roomView.addEventListener(RoomItemDisplayEvent.MOUSE_DOWN_ITEM, onMouseDownRoomItem);
		}
		
		protected function setEditTarget(controller:IRoomItemController):void
		{
			if (_itemEditor)
			{
				_itemEditor.selected = false;
				_itemEditor.stopDrag();
			}
			
			if (controller)
			{
				_itemEditor = controller.getEditor();
				_itemEditor.selected = true;
			}
			else
			{
				_itemEditor = null;
			}
		}
		
		protected function menuItemDragEnterHandler(event:DragEvent):void
		{
			//var item:SdgItem = event.dragSource.dataForFormat('items')[0] as SdgItem;
			var turfItem:TurfItem = event.dragSource.dataForFormat('items')[0] as TurfItem;
			
			if (turfItem.isGreyedOut)
			{
				LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_TURF_BUILDER);
				
				var alert:MVPAlert = MVPAlert.show("Sorry, Athlete. You will need to renew your MVP membership to use this item.", "Rejoin the Team!", onClose);
				alert.addButton("Renew Membership", LoggingUtil.MVP_UPSELL_CLICK_TURF_BUILDER, 230);
				return;
			}
			
			_room.dispatchEvent(new TurfItemDragEvent(turfItem));
			var item:InventoryItem = turfItem.availableInventoryItem;
			
			if (item && !_room.containsItemKey(item))
   			{
				DragManager.acceptDragDrop(IUIComponent(event.target));
				
				_room.addItem(item);
				_roomManager.itemCount++;
					
				setEditTarget(getItemController(item));
				
				_itemEditor.owner.display.visible = true;
				_itemEditor.startDrag(false);
   			}
   			
   			function onClose(event:CloseEvent):void
			{
				var identifier:int = event.detail;
				
				if (identifier == LoggingUtil.MVP_UPSELL_CLICK_TURF_BUILDER)
					MainUtil.goToMVP(identifier);
			}
      	}
      	
      	protected function menuItemDragExitHandler(event:DragEvent):void
      	{
      		_room.removeItem(_itemEditor.owner.item);
			_roomManager.itemCount--;
			
			setEditTarget(null);
      	}

		protected function menuItemDragDropHandler(event:DragEvent):void 
		{
			if (_itemEditor == null) return;
			
			_itemEditor.stopDrag();
			
			if (!_itemEditor.isValid)
			{
				_room.removeItem(_itemEditor.owner.item);
				
				var invItem:InventoryItem = _itemEditor.owner.item as InventoryItem;
				
				_roomManager.itemCount--;
				
				setEditTarget(null);
			}
		}
		
		private function onMouseDownRoomItem(e:RoomItemDisplayEvent):void
		{
			// Determine item controller.
			_mouseItemController = getItemController(e.display.item);
			if (!_mouseItemController) return;
			
			setEditTarget(_mouseItemController);
			_itemEditor.startDrag();
		}
		
		override protected function onMouseDownRoom(e:MouseEvent):void
		{
			// Don't call super function because RoomUIController has different functionality that we don't want to invoke.
			if (_mouseItemController) return;
			
			if (_itemEditor && _itemEditor.owner.item != null && !_itemEditor.isValid)
			{
				_room.removeItem(_itemEditor.owner.item);
				_roomManager.itemCount--;
			}
			
			setEditTarget(null);
		}
		
	}
}