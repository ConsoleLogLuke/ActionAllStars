package com.sdg.pickem
{
	import com.sdg.display.IDisplayObject;
	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.media.Sound;

	public interface IPickemScreenView extends IDisplayObject, IEventDispatcher
	{
		function voteRegistered():void;
		function destroy():void;
		
		function set questionText(value:String):void;
		function set answer1Text(value:String):void;
		function set answer2Text(value:String):void;
		function get answer1Image():DisplayObject;
		function get answer2Image():DisplayObject;
		function set answer1Image(value:DisplayObject):void;
		function set answer2Image(value:DisplayObject):void;
		function get countdownTime():int;
		function set countdownTime(value:int):void;
		function get viewState():String;
		function set viewState(value:String):void;
		function get answer1Position():Number;
		function get answer2Position():Number;
		function set answer1Position(value:Number):void;
		function set answer2Position(value:Number):void;
		function get roomResultBreakdown():Number;
		function set roomResultBreakdown(value:Number):void;
		function get worldResultBreakdown():Number;
		function set worldResultBreakdown(value:Number):void;
		function set answerColor1(value:uint):void;
		function set answerColor2(value:uint):void;
		function set backgroundLoopSound(value:Sound):void;
		function get countdownAlpha():Number;
		function set countdownAlpha(value:Number):void;
		function set offHoursMessage(value:String):void;
	}
}