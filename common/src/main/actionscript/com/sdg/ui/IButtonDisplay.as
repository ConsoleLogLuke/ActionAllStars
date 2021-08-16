package com.sdg.ui
{
	import com.sdg.mvc.IView;
	
	import flash.text.TextFormat;

	public interface IButtonDisplay extends IView
	{
		function get label():String;
		function set label(value:String):void;
		
		function get labelFormat():TextFormat;
		function set labelFormat(value:TextFormat):void;
		
	}
}