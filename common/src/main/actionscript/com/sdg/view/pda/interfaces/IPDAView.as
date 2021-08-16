package com.sdg.view.pda.interfaces
{
	import com.sdg.display.IDisplayObject;
	
	import flash.display.DisplayObject;
	
	public interface IPDAView extends IDisplayObject
	{
		function get view():DisplayObject;
		function get mainScreen():IPDAMainScreen;
		function set mainPanel(panel:IPDAMainPanel):void;
		function get mainPanel():IPDAMainPanel;
		function set sidePanel(panel:IPDASidePanel):void;
		function get sidePanel():IPDASidePanel;
		function rotatePDA(rotateEndHandler:Function = null, angleFrom:Number = 90, angleTo:Number = 90, duration:Number = 100):void;
	}
}
