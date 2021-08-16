package com.sdg.game.models
{
	public class UnityNBAPlayer
	{
		private var _name:String;
		private var _attributes:Object;
		
		public function UnityNBAPlayer(name:String, attributes:Object = null)
		{
			_name = name;
			_attributes = attributes;
		}
		
		public function addAttribute(attributeName:String, value:Object):void
		{
			if (_attributes == null)
				_attributes = new Object();
			
			_attributes[attributeName] = value;
		} 
		
		public function get attributes():Object
		{
			return _attributes;
		}
		
		public function get name():String
		{
			return _name;
		}
	}
}