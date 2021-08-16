package com.sdg.geom
{
	public interface IShapeCursor
	{
		function get currentIndex():int;
		
		function currentSegment(coords:Array):int;
		
		function hasNext():Boolean;
		
		function hasPrev():Boolean;
		
		function next():void;
		
		function prev():void;
		
		function reset():void;
		
		function seek(index:uint):void;
	}
}