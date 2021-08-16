package com.sdg.game.keycombo
{
	public class KeyComboMap extends Object
	{
		private var _keys:Array;
		private var _allKeyCombos:Array;
		
		public function KeyComboMap()
		{
			super();
			
			_keys = [];
			_allKeyCombos = [];
		}
		
		public function removeAll():void
		{
			_keys = null;
			_allKeyCombos = null;
		}
		
		public function addKeyCombo(keyCombo:Array, params:Object):void
		{
			var i:int = 0;
			var len:int = keyCombo.length;
			var keys:Array = _keys;
			for (i; i < len; i++)
			{
				var keyValue:String = keyCombo[i];
				var keyMap:Array = keys[keyValue] as Array;
				if (!keyMap)
				{
					keyMap = [];
					keys[keyValue] = keyMap;
				}
				keys = keyMap;
			}
			
			var kC:KeyCombo = new KeyCombo(keyCombo, params);
			keys.push(kC);
			_allKeyCombos.push(kC);
		}
		
		public function getKeyCombo(keyCombo:Array):KeyCombo
		{
			var i:int = 0;
			var len:int = keyCombo.length;
			var keys:Array = _keys;
			for (i; i < len; i++)
			{
				var keyValue:String = keyCombo[i];
				var keyMap:Array = keys[keyValue] as Array;
				if (!keyMap) return null;
				keys = keyMap;
			}
			
			for each (var combo:Object in keys)
			{
				var kc:KeyCombo = combo as KeyCombo;
				if (kc) return kc;
			}
			
			return null;
		}
		
		/*
		Return combo where paramName = value.
		*/
		public function getByParam(paramName:String, value:Object):KeyCombo
		{
			var i:int = 0;
			var len:int = _allKeyCombos.length;
			for (i; i < len; i++)
			{
				var combo:KeyCombo = _allKeyCombos[i];
				if (combo.params[paramName] && combo.params[paramName] == value) return KeyCombo(combo);
			}
			
			return null;
		}
		
	}
}