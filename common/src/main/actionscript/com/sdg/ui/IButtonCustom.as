package com.sdg.ui
{
	import com.sdg.display.LineStyle;
	import com.sdg.graphics.RoundRectStyle;
	
	public interface IButtonCustom extends IButtonDisplay
	{
		function get backgroundColor():uint;
		function set backgroundColor(value:uint):void;
		
		function get backgroundAlpha():Number;
		function set backgroundAlpha(value:Number):void;
		
		function get backgroundShape():String;
		function set backgroundShape(value:String): void;
		
		function get labelX():Number;
		function set labelX(value:Number):void;
		
		function get roundRectStyle():RoundRectStyle;
		function set roundRectStyle(value:RoundRectStyle):void
		
		function get borderStyle():LineStyle;
		function set borderStyle(value:LineStyle):void;
	}
}