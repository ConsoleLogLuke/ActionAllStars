package com.sdg.display
{	
	public interface IInteractiveObject extends IDisplayObject
	{
		function get mouseEnabled():Boolean;
		function set mouseEnabled(value:Boolean):void;
	}
}