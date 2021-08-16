package com.sdg.pickem
{
	import com.boostworthy.animation.management.AnimationManager;
	import com.sdg.control.room.itemClasses.RoomEntity;
	import com.sdg.model.Avatar;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.ui.UIPickemInGameScorecard;
	import com.sdg.view.IRoomView;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.media.Sound;
	
	public interface IPickemModel extends IEventDispatcher
	{
		function init(data:Object):Boolean; // Returns true if initializations is successful.
		function destroy():void;
		function getCurrentPickemInstance():PickemInstance;
		function getUserAnswer():Number;
		function addPick(pick:UserPick):void;
		function parseUserPicksXML(userPicksXML:XML, pickemEventId:int):void;
		function sendUserToOpenTile():Boolean;
		function processUserAnswer():void;
		function populateScoreCard():void;
		
		function get backgroundScreen():Sprite;
		function get screenView():IPickemScreenView;
		function get answerImages():Array;
		function get animationManager():AnimationManager;
		function get floorTriangle1():FloorTriangle;
		function get floorTriangle2():FloorTriangle;
		function get pickCard():UIPickemInGameScorecard;
		function get userPicks():UserPickCollection;
		function get emoteSize():Number;
		function get defaultAnswerColor1():uint;
		function get defaultAnswerColor2():uint;
		function get countdownSound():Sound;
		function set countdownSound(value:Sound):void;
		function get pollOverSound():Sound;
		function set pollOverSound(value:Sound):void;
		function get voteRegisteredSound():Sound;
		function set voteRegisteredSound(value:Sound):void;
		function get resultsInSound():Sound;
		function set resultsInSound(value:Sound):void;
		function get backgroundLoopSound():Sound;
		function set backgroundLoopSound(value:Sound):void;
		function get roomContainer():IRoomView;
		function get background():Object;
		function get backgroundDisplayObject():Sprite;
		function get currentQuestionIndex():int;
		function set currentQuestionIndex(value:int):void;
		function get userEntity():RoomEntity;
		function get userTileSetId():String;
		function get floorTilesEnabled():Boolean;
		function set floorTilesEnabled(value:Boolean):void;
		function get socketClient():SocketClient;
		function get countdownSoundUrl():String;
		function get voteRegisteredSoundUrl():String;
		function get pollOverSoundUrl():String;
		function get resultsInSoundUrl():String;
		function get backgroundLoopSoundUrl():String;
		function get pickemData():PickemData;
		function get userAvatar():Avatar;
		function get date():Date;
		function get tutorialUrl():String;
		function get firstTimePlayed():Boolean;
		function set firstTimePlayed(value:Boolean):void;
		function get gameCompleteImageUrl():String;
		//function get consoleEventTarget():EventDispatcher;
		function get questionDuration():int;
		function get answerHasBeenProcessed():Boolean;
	}
}