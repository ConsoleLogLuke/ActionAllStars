package com.sdg.game.keycombo
{
	public class KeyCombo extends Object
	{
		private var _keyCodes:Array;
		private var _params:Object;
		
		public function KeyCombo(keyCodes:Array, params:Object)
		{
			super();
			
			_keyCodes = keyCodes;
			_params = params;
		}
		
		public function get keyCodes():Array
		{
			return _keyCodes;
		}
		
		public function get params():Object
		{
			return _params;
		}
		
	}
}