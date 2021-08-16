package com.sdg.view.pda.interfaces
{
	import com.sdg.display.IDisplayObject;
	
	import flash.media.Sound;
	
	public interface IPDAButtonBase extends IDisplayObject
	{
		function set mouseOverSound(value:Sound):void;
		function set clickSound(value:Sound):void;
		function set callBack(value:Function):void;
		function get callBack():Function;
	}
}