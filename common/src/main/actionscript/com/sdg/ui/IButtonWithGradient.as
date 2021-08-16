package com.sdg.ui
{
	import com.sdg.graphics.GradientStyle;
		
	public interface IButtonWithGradient extends IButtonCustom
	{
		function get gradient():GradientStyle;
		function set gradient(value:GradientStyle):void;
		
		function get backgroundStyle():String;
		function set backgroundStyle(value:String):void;
	}
}