package com.sdg.display
{	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	public interface IDisplayObject extends IEventDispatcher
	{
		function get x():Number;
		function set x(value:Number):void;
		
		function get y():Number;
		function set y(value:Number):void;
		
		function get width():Number;
		function set width(value:Number):void;
		
		function get height():Number;
		function set height(value:Number):void;
		
		function get visible():Boolean;
		function set visible(value:Boolean):void;
		
		function get mouseX():Number;
		function get mouseY():Number;
		
		function getBounds(targetCoordinateSpace:DisplayObject):Rectangle;
	}
}