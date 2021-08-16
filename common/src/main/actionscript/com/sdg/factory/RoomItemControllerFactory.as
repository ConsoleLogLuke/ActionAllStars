package com.sdg.factory
{
	import com.sdg.control.room.itemClasses.*;
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.SdgItem;
	import com.sdg.npc.NPCController;
	
	public class RoomItemControllerFactory
	{
		private static const INVENTORY_CONTROLLER_CLASS_MAP:Object =
		{
			1018:GameLauncher,
			1020:ExitPoint,
			1021:InteractiveDoodad,
			1022:BackgroundItemController,
			1024:NPCController,
			1025:FoodVender,
			1029:InteractiveSign,
			1030:GiftGivingSign,
			1033:InteractiveMissionController,
			20:PetController,
			22:InWorldLeaderboardController
		}
		
		protected var item:SdgItem;
		
		public function setItem(item:SdgItem):void
		{
			this.item = item;
		}
		
		public function createInstance():Object
		{
			var controllerClass:Class
			var controller:RoomItemController;
			
			// Determine controller class.
			if (item is Avatar)
			{
				// If item is an Avatar, use an AvatarController controller class.
				controllerClass = AvatarController;
			}
			else if (item is InventoryItem)
			{
				// If item is an inventory item, determine the controller class.
				controllerClass = getInventoryControllerClass(InventoryItem(item).itemTypeId);
			}
			
			// If NO controller class was established, default to RoomItemController.
			if (controllerClass == null) controllerClass = RoomItemController;
			
			// Instantiate the controller class.
			try
			{
				controller = new controllerClass();
			}
			catch (e:Error)
			{
				// Could not instantiate the controller class.
				trace('RoomItemControllerFactory: Could not instantiate controller class for item: ' + item.toString());
			}
			
			// Call initialize on the room item controller.
			if (controller != null)
			{
				controller.initialize(item);
				return controller;
			}
			else
			{
				return null;
			}
		}
		
		protected function getInventoryControllerClass(itemTypeId:uint):Class
		{
			return INVENTORY_CONTROLLER_CLASS_MAP[itemTypeId];
		}
	}
}