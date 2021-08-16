package com.sdg.skate
{
	import flash.events.IEventDispatcher;
	
	public interface ISkateGameUI extends IEventDispatcher
	{
		function destroy():void;
		function showMessage(text:String, duration:int):void;
		function showStylizedMessage(text:String, color:uint = 0xff0000):void;
		function startNewKeyCombo(initialValue:String, intervalDuration:int = 1000, maxIntervals:int = 4, triggerDuration:int = 200, intervalWidth:Number = 100):void
		function attemptToSetNextValue(value:String):void;
		function stopCurrentKeyCombo(leaveUpDelay:int):void;
		function setPersistentMessage(text:String, showNow:Boolean = true):void;
		function removePersistentMessage():void;
		function addAvatar(avatarId:int, score:int, color:uint):void;
		function removeAvatar(avatarId:int):void;
		function setAvatarScore(avatarId:int, score:int):void;
		function highlightTrickSheet(highlight:Boolean):void;
		function showWinEffect():void;
		function getLeadingScoreAvatarId():int;
		
		function get points():int;
		function set points(value:int):void;
		function get timeProgressValue():Number;
		function set timeProgressValue(value:Number):void;
		function get scoreMultiplier():Number;
		function set scoreMultiplier(value:Number):void;
		function get localUserGamePlayCount():int;
		function set localUserGamePlayCount(value:int):void;
		function get numAvatars():int;
		function get timeDisplayVisible():Boolean;
		function set timeDisplayVisible(value:Boolean):void;
		function get trickButtonVisible():Boolean;
		function set trickButtonVisible(value:Boolean):void;
		
	}
}