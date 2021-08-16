package com.sdg.events
{
	import com.sdg.model.ActionAllStarsEvent;
	import com.sdg.model.ActionAllStarsEventCollection;
	import com.sdg.model.ActionAllStarsEventType;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.pickem.PickemData;
	import com.sdg.pickem.PickemEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class AASEventManager extends EventDispatcher
	{
		private static var _instance:AASEventManager;
		private var _eventSocket:SocketClient;
		private var _events:ActionAllStarsEventCollection;
		private var _eventsUpdated:Boolean;
		private var _pickemData:PickemData;
		
		public function AASEventManager()
		{
			if (_instance)
			{
				throw new Error("AASEventManager is a singleton class. Use 'getInstance()' to access the instance.");
			}
			else
			{
				_eventsUpdated = true;
				_events = new ActionAllStarsEventCollection();
			}
		}
		
		public static function getInstance():AASEventManager
		{
			if (_instance == null)
			{
				_instance = new AASEventManager();
			}
			
			return _instance;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function getCurrentEvent(eventType:String):ActionAllStarsEvent
		{
			// Filter events of specified type.
			var events:ActionAllStarsEventCollection = filterEventsByType(_events, eventType);
			
			// Check that there are any events of the specified type.
			if (events.length < 1) return null;
			
			// Find an in progress event.
			var i:int = 0;
			var len:int = events.length;
			var event:ActionAllStarsEvent;
			var currentEvent:ActionAllStarsEvent;
			var startTime:Date;
			var secondsUntilGame:Number;
			var gameElapsed:Number;
			var gameDuration:Number;
			for (i; i < len; i++)
			{
				event = events.getAt(i);
				
				// Get the event start time.
				startTime = event.startTime;
				
				// Calculate time until the trivia event starts in seconds.
				var mTimeUntilGame:int = Math.floor(startTime.time - ModelLocator.getInstance().serverDate.time);
				secondsUntilGame = mTimeUntilGame / 1000;
				
				gameElapsed = -mTimeUntilGame;
				gameDuration = event.duration;
				
				if (secondsUntilGame <= 0 && gameElapsed < gameDuration)
				{
					// The event is in progress.
					currentEvent = event;
					i = len;
				}
			}
			
			return currentEvent;
		}
		
		public function getNextEvent(eventType:String):ActionAllStarsEvent
		{
			// Filter events of specified type.
			var events:ActionAllStarsEventCollection = filterEventsByType(_events, eventType);
			
			// Check that there are any events of the specified type.
			if (events.length < 1) return null;
			
			// Find the next event.
			var i:int = 0;
			var len:int = events.length;
			var event:ActionAllStarsEvent;
			var nextEvent:ActionAllStarsEvent;
			var startTime:Date;
			var secondsUntilGame:Number;
			var gameElapsed:Number;
			var gameDuration:Number;
			var shortestWait:Number = -1;
			for (i; i < len; i++)
			{
				event = events.getAt(i);
				
				// Get the event start time.
				startTime = event.startTime;
				
				// Calculate time until the trivia event starts in seconds.
				var mTimeUntilGame:int = Math.floor(startTime.time - ModelLocator.getInstance().serverDate.time);
				
				if (mTimeUntilGame > 0)
				{
					// The event is comming up.
					if (shortestWait < 0 || shortestWait > mTimeUntilGame)
					{
						shortestWait = mTimeUntilGame;
						nextEvent = event;
					}
				}
			}
			
			return nextEvent;
		}
		
		public function filterEventsByType(events:ActionAllStarsEventCollection, type:String):ActionAllStarsEventCollection
		{
			// Filter events of specified type.
			var filteredEvents:ActionAllStarsEventCollection = new ActionAllStarsEventCollection();
			var i:int = 0;
			var len:int = events.length;
			var event:ActionAllStarsEvent;
			for (i; i < len; i++)
			{
				event = events.getAt(i);
				if (event.type == type) filteredEvents.push(event);
			}
			
			return filteredEvents;
		}
		
		private function printEvents():void
		{
			trace('AASEventManager: Tracing events.');
			var i:int = 0;
			var len:int = _events.length;
			for (i; i < len; i++)
			{
				trace(_events.getAt(i).toString());
			}
		}
		
		private function parsePickemData(events:ActionAllStarsEventCollection):void
		{
			var pickemEvents:ActionAllStarsEventCollection = filterEventsByType(events, ActionAllStarsEventType.PICKEM_EVENT);
			if (pickemEvents.length < 1) return;
			var pickemEvent:PickemEvent = PickemEvent(pickemEvents.getAt(0));
			var startTime:Date = pickemEvent.startTime;
			//var endTime:Date = (pickemEvent.endTime != null) ? pickemEvent.endTime : new Date(startTime.fullYear, startTime.month, startTime.date, 20, 0, 0, 0);
			var endTime:Date = new Date(startTime.fullYear, startTime.month, startTime.date, 16, 0, 0, 0);
			
			// Validate pickem data.
			if (pickemEvent.questions.length > 0)
			{
				_pickemData = new PickemData(pickemEvent.id, startTime, endTime, pickemEvent.questions);
			}
			
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set eventSocket(value:SocketClient):void
		{
			if (value == _eventSocket) return;
			if (_eventSocket != null) _eventSocket.removeEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
			_eventSocket = value;
			_eventSocket.addEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
		}
		
		public function get pickemData():PickemData
		{
			return (_pickemData == null) ? null : _pickemData;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onPluginEvent(e:SocketEvent):void
		{
			// Handle socket plugin event.
			// Only act on "rwsEvents" plugin event.
			var action:String = e.params.action;
			var eventsXML:XML;
			if (action == 'triviaEvents')
			{
				eventsXML = new XML(e.params.triviaEvents);
				trace(eventsXML);
				_events = ActionAllStarsEvent.ParseMultipleEventXML(eventsXML);
				parsePickemData(_events);
				_eventsUpdated = true;
			}
			else if (action == 'pickemEvents')
			{
				eventsXML = new XML(e.params.pickemEvents);
				trace(eventsXML);
				parsePickemData(ActionAllStarsEvent.ParseMultipleEventXML(eventsXML));
			}
		}
		
	}
}