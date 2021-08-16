package com.sdg.view.fandamonium
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class OutfieldWalls extends Sprite
	{
		private var _homeTeamWall:TeamWall;
		private var _awayTeamWall:TeamWall;
		
		public function OutfieldWalls()
		{
			super();
			
			_homeTeamWall = new TeamWall(new Point(675, 80), new Point(925, 123), new Point(675, 159), new Point(925, 210), Math.PI/1.7);
			_homeTeamWall.logoSize = 85;
			_homeTeamWall.logoPosition = new Point(800, 143);
			_homeTeamWall.logoSkewFactor = -2.94;
			addChild(_homeTeamWall);
			
			_awayTeamWall = new TeamWall(new Point(0, 118), new Point(243, 80), new Point(0, 206), new Point(243, 157), Math.PI/2.4);
			_awayTeamWall.logoSize = 85;
			_awayTeamWall.logoPosition = new Point(121, 155);
			_awayTeamWall.logoSkewFactor = 2.95;
			addChild(_awayTeamWall);
		}
		
		public function setHomeTeamWallPoints(topLeft:Point = null, topRight:Point = null, bottomLeft:Point = null, bottomRight:Point = null):void
		{
			_homeTeamWall.setWallPoints(topLeft, topRight, bottomLeft, bottomRight);
		}
		
		public function setAwayTeamWallPoints(topLeft:Point = null, topRight:Point = null, bottomLeft:Point = null, bottomRight:Point = null):void
		{
			_awayTeamWall.setWallPoints(topLeft, topRight, bottomLeft, bottomRight);
		}
		
		public function set homeTeamColor(color:uint):void
		{
			_homeTeamWall.color = color;
		}
		
		public function set awayTeamColor(color:uint):void
		{
			_awayTeamWall.color = color;
		}
		
		public function set homeTeamLogo(logo:DisplayObject):void
		{
			_homeTeamWall.logo = logo;
		}
		
		public function set awayTeamLogo(logo:DisplayObject):void
		{
			_awayTeamWall.logo = logo;
		}
		
		public function set homeTeamLogoSize(size:int):void
		{
			_homeTeamWall.logoSize = size;
		}
		
		public function set awayTeamLogoSize(size:int):void
		{
			_awayTeamWall.logoSize = size;
		}
		
		public function set homeTeamLogoPosition(point:Point):void
		{
			_homeTeamWall.logoPosition = point;
		}
		
		public function set awayTeamLogoPosition(point:Point):void
		{
			_awayTeamWall.logoPosition = point;
		}
	}
}