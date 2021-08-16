package com.sdg.game.models
{
	public interface IUnityNBAModel extends IGameMenuModel
	{
		function set inputData(value:Object):void;
		function set gameResult(value:Object):void;
		function get tierArray():Array;
		function set myTeam(value:UnityNBATeam):void;
		function get myTeam():UnityNBATeam;
		function set opponentTeam(value:UnityNBATeam):void;
		function get opponentTeam():UnityNBATeam;
		function get tokensEarned():int;
		function get xpEarned():int;
		function get isGameComplete():Boolean;
		function get isWinner():Boolean;
		function get myScore():int;
		function get opponentScore():int;
	}
}
