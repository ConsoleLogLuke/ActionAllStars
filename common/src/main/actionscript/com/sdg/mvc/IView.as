package com.sdg.mvc
{
	import com.sdg.display.IDisplayObject;
	
	import flash.display.DisplayObject;
	
	public interface IView extends IDisplayObject
	{
		function destroy():void;
		function render():void;
		
		function get display():DisplayObject;
	}
}