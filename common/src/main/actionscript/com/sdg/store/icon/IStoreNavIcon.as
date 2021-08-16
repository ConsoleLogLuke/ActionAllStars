package com.sdg.store.icon
{
	import com.sdg.mvc.IView;
	import flash.display.DisplayObject;

	public interface IStoreNavIcon extends IView
	{
		function init(width:Number, height:Number):void;
		function get image():DisplayObject;
		function set image(value:DisplayObject):void;
	}
}