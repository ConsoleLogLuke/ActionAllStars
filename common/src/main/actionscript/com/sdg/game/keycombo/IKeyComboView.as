package com.sdg.game.keycombo
{
	import com.sdg.display.IDisplayObject;
	
	public interface IKeyComboView extends IDisplayObject
	{
		function addKeyPoint(slackFactor:Number = 1):void;
		function setIntervalProgress(value:Number):void;
		function setNextKeyPointValue(value:String):void;
		function destroy():void;
		
		function get intervalWidth():Number;
		function get keyPointSize():Number;
		function get fillVisible():Boolean;
		function set fillVisible(value:Boolean):void;
	}
}