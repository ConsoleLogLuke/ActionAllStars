package com.sdg.display
{
	import com.sdg.core.IProgressInfo;
	import com.sdg.display.render.RenderObject;
	import com.sdg.model.SdgItem;
	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	public interface IRoomItemDisplay extends IEventDispatcher
	{
		function get item():SdgItem;
		
		function get itemResolveStatus():uint;
		function set itemResolveStatus(value:uint):void;
		
		function get mouseEnabled():Boolean;
		function set mouseEnabled(value:Boolean):void;
		
		function get progressInfo():IProgressInfo;
		
		function get renderItem():RenderObject;
		
		function get visible():Boolean;
		function set visible(value:Boolean):void;
		
		function get x():Number;
		function set x(value:Number):void;

		function get y():Number;
		function set y(value:Number):void;
		
		function get width():Number;
		
		function get height():Number;
		
		function get orientation():uint;
		function set orientation(value:uint):void;
		
		function set floorMarker(value:DisplayObject):void;
		
		function get content():DisplayObject;
		
		function get filters():Array;
		function set filters(value:Array):void;
		
		function activate():void;
		
		function deactivate():void;
		
		// destroy all listeners, bitmaps and other associated resources
		function destroy():void;
		
		function getImageRect(update:Boolean = false):Rectangle
		
		function playAnimation(name:String):void;
		
		function showUIState(state:int):void;
		
		function addChild(child:DisplayObject):DisplayObject;
		
		function removeChild(child:DisplayObject):DisplayObject;
		
		function load():void;
	}
}