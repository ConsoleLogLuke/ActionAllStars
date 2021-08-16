package com.sdg.components.controls
{
	import com.sdg.display.IDisplayObject;
	
	public interface IHudMessage extends IDisplayObject
	{
		function set removeCallback(value:Function):void;
		function set read(value:Boolean):void;
		function get isPersonal():Boolean;
		function set isPersonal(value:Boolean):void;
	}
}