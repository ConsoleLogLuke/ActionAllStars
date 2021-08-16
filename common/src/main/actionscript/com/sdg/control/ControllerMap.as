package com.sdg.control
{
	import com.sdg.components.games.carrotDefense.controller.CarrotDefenseController;
	
	public class ControllerMap extends Object
	{
		protected static var _map:Object = {
			0: FlyBallGameController,
			1: TriviaBackgroundController,
			2: HiddenAthleteController,
			3: RWSLobbyController,
			4: PickemBackgroundController,
			5: CarrotDefenseController
		}
		
		public function ControllerMap()
		{
			super();
		}
		
		public static function getClass(id:int):Class
		{
			return _map[id];
		}
		
	}
}