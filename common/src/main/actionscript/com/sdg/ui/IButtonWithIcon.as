package com.sdg.ui
{
	import flash.display.DisplayObject;
	
	public interface IButtonWithIcon extends IButtonDisplay
	{
		function get icon():DisplayObject;
		function set icon(value:DisplayObject):void;
	}
}