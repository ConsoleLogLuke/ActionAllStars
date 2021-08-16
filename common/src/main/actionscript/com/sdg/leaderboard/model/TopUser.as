package com.sdg.leaderboard.model
{
	import com.sdg.model.IIdObject;
	import com.sdg.model.IdObject;

	public class TopUser extends IdObject implements IIdObject
	{
		protected var _place:uint;
		protected var _level:uint
		protected var _points:int;
		protected var _teamId:uint;
		protected var _teamName:String;
		protected var _color1:uint;
		protected var _color2:uint;
		
		public function TopUser(id:uint, name:String, place:uint, level:uint, points:int, teamId:uint, teamName:String, color1:uint, color2:uint)
		{
			_place = place;
			_level = level;
			_points = points;
			_teamId = teamId;
			_teamName = teamName;
			_color1 = color1;
			_color2 = color2;
			
			super(id, name);
		}
		
		public function get place():int
		{
			return _place;
		}
		public function set place(value:int):void
		{
			_place = value;
		} 
		
		public function get level():int
		{
			return _level;
		}
		public function set level(value:int):void
		{
			_level = value;
		}
		
		public function get points():int
		{
			return _points;
		}
		public function set points(value:int):void
		{
			_points = value;
		}
		
		public function get teamId():uint
		{
			return _teamId;
		}
		public function set teamId(value:uint):void
		{
			_teamId = value;
		}
		
		public function get teamName():String
		{
			return _teamName;
		}
		public function set teamName(value:String):void
		{
			_teamName = value;
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