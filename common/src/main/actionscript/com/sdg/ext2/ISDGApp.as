﻿package com.sdg.ext2{	import flash.display.LoaderInfo;		/**	 * The ISDGApp interface defines the methods exposed 	 * to the game host environment.	 */	public interface ISDGApp	{		/**		 * Initialize the game at start up. Note that this is fired just after		 * the games fires loadComplete() from SDGExtUtil		 * 		 * @param params  the attributes for the game		 */		function init(params:Object):void;				/**		 * Returns the current state of the game, enumerated by SDGAppState.		 * The possible return values are:		 *		 * 1: Game is currently initializing.		 * 2: Game has initialized and is running.		 * 3: Game is currently paused.		 * 4: Game is completed and awaiting deactivation.		 *		 * @return Current state.		 */		function getState():int;				/**		 * Disables all animations, sounds and other processes		 * in the game. If it is invoked during initialization,		 * the game should suspend any upcoming intro animations, etc.		 */		function pause():void;				/**		 * Returns the game to its previously unpaused state.		 */		function resume():void;				/**		 * Immediately closes all active processes, releases		 * dynamically allocated resources, and prepares 		 * the app for removal from the host environment.		 */		function destroy():void;	}}