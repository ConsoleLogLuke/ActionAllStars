package com.sdg.model
{
	public class LiveGameTeam extends Object
	{
		public static const HOME_TEAM:String = 'home team';
		public static const AWAY_TEAM:String = 'away team';
		
		private var _id:uint;
		private var _name:String;
		private var _cityName:String;
		private var _shortName:String;
		private var _advantage:String;
		private var _color1:uint;
		private var _color2:uint;
		
		public function LiveGameTeam(id:uint, name:String, cityName:String, shortName:String)
		{
			super();
			
			_id = id;
			_name = name;
			_cityName = cityName;
			_shortName = shortName;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get id():uint
		{
			return _id;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get cityName():String
		{
			return _cityName;
		}
		
		public function get shortName():String
		{
			return _shortName;
		}
		
		public function get advantage():String
		{
			return _advantage
		}
		public function set advantage(value:String):void
		{
			if (value == _advantage) return;
			
			// The value must either be HOME or AWAY.
			if (value != HOME_TEAM && value != AWAY_TEAM) return;
			
			_advantage = value;
		}
		
		public function get color1():uint
		{
			return _color1;
		}
		public function set color1(value:uint):void
		{
			_color1 = value;
		}
		
		public function get color2():uint
		{
			return _color2;
		}
		public function set color2(value:uint):void
		{
			_color2 = value;
		}
		
	}
}