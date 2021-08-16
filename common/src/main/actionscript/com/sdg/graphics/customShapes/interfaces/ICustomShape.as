package com.sdg.graphics.customShapes.interfaces
{
	import flash.display.Graphics;
	
	public interface ICustomShape
	{
		function get width():Number;
		function set width(value:Number):void;
		function get height():Number;
		function set height(value:Number):void;
		function draw(g:Graphics, x:Number = 0, y:Number = 0):void;
	}
}
