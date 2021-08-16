package com.sdg.view.pda.interfaces
{
	import com.sdg.control.PDAController;
	import com.sdg.display.IDisplayObject;
	
	public interface IPDASidePanel extends IDisplayObject
	{
		function close():void;
		function refresh():void;
		function init(controller:PDAController = null):void;
		function set controller(value:PDAController):void;
		function get isInitialized():Boolean;
	}
}
