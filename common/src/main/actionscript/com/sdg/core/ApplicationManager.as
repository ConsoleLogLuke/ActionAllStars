package com.sdg.core
{
	import com.sdg.collections.QuickList;

	import flash.events.TimerEvent;
	import flash.utils.getDefinitionByName; // Non-SDG
	import flash.utils.Timer;

	import mx.core.Application;
	import mx.managers.ISystemManager;

	public class ApplicationManager
	{
		private static var RoomModule:Class = getDefinitionByName("RoomModule") as Class; // Non-SDG

		private var _popUpsHiddenListeners:QuickList = new QuickList();
		private var _popUpsHiddenTimer:Timer;

		private static var _instance:ApplicationManager;

		public static function getInstance():ApplicationManager
		{
			if (_instance == null) _instance = new ApplicationManager();
			return _instance;
		}

		/**
		 * Singleton constructor.
		 */
		public function ApplicationManager()
		{
			if (_instance)
				throw new Error("ApplicationManager is a singleton class. Use 'getInstance()' to access the instance.");
		}

		public function get numVisiblePopUps():uint
		{
			var systemManager:ISystemManager = Application.application.systemManager;
			var systemChildren:int = systemManager.numChildren;

			var numPopUps:int;

			if (systemChildren < 2)
			{
				numPopUps = 0;
				//return 0;
			}
			else
			{
				var num:int = 0;

				for (var i:int = 1; i < systemChildren; i++)
				{
					if (systemManager.getChildAt(i).visible) num++;
				}

				numPopUps = num;
				//return num;
			}

			//count the number in RoomModule
			numPopUps += RoomModule["getInstance"].popupCounter; // Non-SDG - get the method with square brackets

			return numPopUps;
		}

		/**
		 * Adds a one-time listener that will trigger when no popUps
		 * exist in the application.
		 */
		public function addPopUpsHiddenListener(listener:Function):void
		{
			// Initialize polling timer if it doesn't exist.
			if (!_popUpsHiddenTimer)
			{
				_popUpsHiddenTimer = new Timer(500);
				_popUpsHiddenTimer.addEventListener(TimerEvent.TIMER, checkNumPopUps);
			}

			_popUpsHiddenTimer.reset();
			_popUpsHiddenTimer.start();

			// Add listener to the list.
			if (!_popUpsHiddenListeners.contains(listener))
				_popUpsHiddenListeners.push(listener);
		}

		public function removePopUpsHiddenListener(listener:Function):void
		{
			_popUpsHiddenListeners.removeValue(listener);

			if (_popUpsHiddenListeners.length == 0)
				_popUpsHiddenTimer.stop();
		}

		private function checkNumPopUps(event:TimerEvent):void
		{
			if (numVisiblePopUps == 0)
			{
				for each (var listener:Function in _popUpsHiddenListeners)
					listener();

				_popUpsHiddenListeners.length = 0;
				_popUpsHiddenTimer.stop();
			}
		}
	}
}
