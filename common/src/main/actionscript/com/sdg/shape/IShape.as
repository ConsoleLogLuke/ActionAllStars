package com.sdg.shape
{
	import flash.display.Graphics;
	
	public interface IShape
	{
		function draw(graphicsObject:Graphics):void;
		function set width(value:Number):void;
		function set height(value:Number):void;
		function set x(value:Number):void;
		function set y(value:Number):void;
	}
}