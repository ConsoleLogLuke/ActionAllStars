package com.sdg.control.room.itemClasses.pet
{
	public interface IPetControllerDelegate
	{
		function onPetEnergyUpdate(value:Number):void;
		function onPetHappinessUpdate(value:Number):void;
	}
}