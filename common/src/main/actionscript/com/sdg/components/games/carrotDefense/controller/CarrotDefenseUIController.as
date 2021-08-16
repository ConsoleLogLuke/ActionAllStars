package com.sdg.components.games.carrotDefense.controller
{
	import com.sdg.control.room.RoomUIController;

	public class CarrotDefenseUIController extends RoomUIController
	{
		public function CarrotDefenseUIController()
		{
		}
		override protected function setUp():void
		{
			// DO NOT LISTEN FOR ANYTHING
		}
		
		override protected function cleanUp():void
		{
			//Nothing to clean up since nothing changed
		}
	}
}