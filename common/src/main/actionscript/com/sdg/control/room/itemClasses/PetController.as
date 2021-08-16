package com.sdg.control.room.itemClasses
{
	import com.sdg.control.room.RoomManager;
	import com.sdg.control.room.itemClasses.pet.IPetControllerDelegate;
	import com.sdg.model.PetItem;
	import com.sdg.model.SdgItem;
	import com.sdg.pet.events.PetUpdateEvent;
	
	/**
	 * 
	 * Controls the custom actions of a pet
	 * 
	 * @author molly.jameson
	*/
	public class PetController extends Character
	{
		private var _delegates:Array;
		private var _petItem:PetItem;
		
		public function PetController()
		{
			super();
			
			_delegates = [];
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public override function initialize(item:SdgItem):void
		{
			super.initialize(item);
			
			_petItem = item as PetItem;
			
			// also listen for leash, unleash
			setActionListener("orientation", orientationActionHandler);
			
			// Add item listeners.
			item.addEventListener(PetUpdateEvent.ENERGY, onPetEnergyUpdate);
			item.addEventListener(PetUpdateEvent.HAPPINESS, onPetHappinessUpdate);
		}
		public override function destroy():void
		{
			removeActionListener("orientation");
			
			// Remove all delegates.
			_delegates = [];
			
			// Remove item listeners.
			item.removeEventListener(PetUpdateEvent.ENERGY, onPetEnergyUpdate);
			item.removeEventListener(PetUpdateEvent.HAPPINESS, onPetHappinessUpdate);
			
			super.destroy();
		}
		
		//Makes sure when in the turf editor pets can't be deleted.
		public override function getEditor():IRoomItemEditor
		{
			var editer:RoomEntityEditor = new RoomEntityEditor(this);
			editer.inspectable = false;
			return editer;
		}
		
		public function doAnimation(animationName:String):void
		{
			var actionName:String = 'animate';
			var actionParams:Object = {action:actionName, animationName:animationName};
			// Trigger the action/animation.
			RoomManager.getInstance().sendItemAction(item,actionName,actionParams);
		}
		
		public function doRandomAnimation():void
		{
			// Hard code list of available animations.
			var animationNames:Array = ['idle', 'flex', 'wave'];
			var randomAnimationName:String = animationNames[Math.round(Math.random() * (animationNames.length - 1))];
			// Do random animation.
			doAnimation(randomAnimationName);
		}
		
		public function addPetControllerDelegate(delegate:IPetControllerDelegate):void
		{
			// Add it to the array but make sure it doesnt already exist.
			var index:int = _delegates.indexOf(delegate);
			if (index < 0) _delegates.push(delegate);
		}
		
		public function removePetControllerDelegate(delegate:IPetControllerDelegate):void
		{
			var index:int = _delegates.indexOf(delegate);
			if (index > -1) _delegates.splice(index, 1);
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		protected function orientationActionHandler(params:Object):void
		{
			// testing setting the orientation
			var orient:uint = params.orientation;
			trace("Setting pet orientation at: " + orient);
			entity.orientation = orient;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get petItem():PetItem
		{
			return _petItem;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onPetEnergyUpdate(e:PetUpdateEvent):void
		{
			// Call function on all delegates.
			var petEnergy:Number = e.petItem.energy;
			for each (var delegate:IPetControllerDelegate in _delegates)
			{
				delegate.onPetEnergyUpdate(petEnergy);
			}
		}
		
		private function onPetHappinessUpdate(e:PetUpdateEvent):void
		{
			// Call function on all delegates.
			var petHappiness:Number = e.petItem.happiness;
			for each (var delegate:IPetControllerDelegate in _delegates)
			{
				delegate.onPetHappinessUpdate(petHappiness);
			}
		}
		
	}
}