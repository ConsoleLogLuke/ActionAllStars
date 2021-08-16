package com.sdg.model
{
	import com.sdg.pickem.PickemEvent;
	import com.sdg.trivia.Question;
	import com.sdg.trivia.TriviaEvent;
	import com.sdg.utils.DateUtil;
	
	/* ////////////////////////////////////////////////////////////
	This class is a data stucture and is NOT an Event object in
	terms of an actionscript event that may dispatched and listened
	for. It contains data that pertains to every Action AllStars event.
	*/ ////////////////////////////////////////////////////////////
	
	public class ActionAllStarsEvent extends Object
	{
		protected var _type:String;
		protected var _id:String;
		protected var _startTime:Date;
		protected var _logoURL:String;
		private var _duration:Number;
		
		public function ActionAllStarsEvent(type:String, id:String, startTime:Date, logoURL:String = '')
		{
			super();
			
			_type = type;
			_id = id;
			_startTime = startTime;
			_logoURL = logoURL;
			_duration = 1000;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public static function ParseEventXML(eventXML:XML):ActionAllStarsEvent
		{
			// try to extract necessary data from the XML object
			try
			{
				var evType:String = eventXML.type;
				var evID:String = eventXML.id;
				var evStart:Date = DateUtil.DateFromString(eventXML.startTime);
				var event:ActionAllStarsEvent;
				var eventLogoURL:String = eventXML.@logoUrl;
			}
			catch (e:Error)
			{
				throw(new Error('Could not parse necessary information from eventXML: ' + e.message));
				return null;
			}
			
			// determine event type
			switch (evType)
			{
				case ActionAllStarsEventType.TRIVIA_EVENT :
					event = new TriviaEvent(evID, evStart, Question.ParseMultipleQuestionXML(eventXML.questions), eventLogoURL);
					break;
				case ActionAllStarsEventType.PICKEM_EVENT :
					var evEnd:Date = (eventXML.endTime != null) ? DateUtil.DateFromString(eventXML.endTime) : null;
					event = new PickemEvent(evID, evStart, evEnd, Question.ParseMultipleQuestionXML(eventXML.questions), eventLogoURL);
					break;
				default :
					event = null;
					break;
			}
			
			// return the event object
			return event;
		}
		
		public static function ParseMultipleEventXML(eventsXML:XML):ActionAllStarsEventCollection
		{
			var eventXML:XML;
			var event:ActionAllStarsEvent;
			var events:ActionAllStarsEventCollection = new ActionAllStarsEventCollection();
			var i:int = 0;
			while (eventsXML.actionAllStarsEvent[i] != null)
			{
				eventXML = eventsXML.actionAllStarsEvent[i];
				event = ParseEventXML(eventXML);
				events.push(event);
				
				i++;
			}
			
			return events;
		}
		
		public function toString():String
		{
			return 'ActionAllStarsEvent: [startTime: ' + startTime + ']';
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		public function get type():String
		{
			return _type;
		}
		public function set type(value:String):void
		{
			_type = value;
		}
		
		public function get id():String
		{
			return _id;
		}
		public function set id(value:String):void
		{
			_id = value;
		}
		
		public function get startTime():Date
		{
			return _startTime;
		}
		public function set startTime(value:Date):void
		{
			_startTime = value;
		}
		
		public function get logoURL():String
		{
			return _logoURL;
		}
		public function set logoURL(value:String):void
		{
			_logoURL = value;
		}
		
		public function get duration():Number
		{
			// milliseconds
			return _duration;
		}
		
	}
}