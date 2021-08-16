﻿package com.sdg.ext2{	/**	 * The GameResult class consists of public properties	 * that describe the end-game stats. To submit the result	 * to the SDG game server, invoke the SDGExtUtil.sendGameResult() 	 * method and pass in an instance of GameResult.	 */	public class GameResult	{		/* The game start date. */		public var startDate:Date;				/* The game end date. */		public var endDate:Date;				/* The user's score. */		public var score:uint;				/* (optional) Denotes whether the user has won or lost the game. */		public var winCondition:String;				/* (optional) An object containing custom key/value pairs. */		public var attributes:Object;	}}