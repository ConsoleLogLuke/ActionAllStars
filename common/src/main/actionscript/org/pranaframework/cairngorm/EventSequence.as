/**
 * Copyright (c) 2007, the original author(s)
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the Prana Framework nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 package org.pranaframework.cairngorm {
	
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	import mx.utils.ArrayUtil;
	
	import org.pranaframework.utils.Assert;
	import org.pranaframework.utils.Property;
	
	/**
	 * Represents a sequence of events to be chained.
	 * 
	 * @author Christophe Herreman
	 * @author Tony Hillerson
	 */
	public class EventSequence {
		
		private var _sequenceEvents:Array;
		private var _currentSequenceEvent:SequenceEvent;
		
		/**
		 * Creates a new EventSequence
		 */
		public function EventSequence() {
			_sequenceEvents = new Array();
		}
		
		/**
		 * Starts dispatching this event sequence.
		 */
		public function dispatch():void {
			if (_sequenceEvents.length == 0) {
				throw new Error("Cannot start event sequence because sequence has no events");
			}
			var firstSequenceEvent:SequenceEvent = _sequenceEvents[0];
			dispatchSequenceEvent(firstSequenceEvent);
		}
		
		/**
		 * Adds an event to this sequence.
		 * 
		 * @param eventClass the class of the event (must be a subclass of CairngormEvent)
		 * @param parameters the arguments that will be passed to the event's constructor
		 * @param triggers the triggers that will cause the next event to be dispatched
		 */
		public function addSequenceEvent(eventClass:Class, parameters:Array = null, triggers:Array = null):void {
			Assert.notNull(eventClass, "The eventClass argument must not be null");
			Assert.subclassOf(eventClass, CairngormEvent);
			_sequenceEvents.push(new SequenceEvent(eventClass, parameters, triggers));
		}
		
		private function dispatchSequenceEvent(sequenceEvent:SequenceEvent):void {
			_currentSequenceEvent = sequenceEvent;
			var event:CairngormEvent = sequenceEvent.createEvent();
			var nextSequenceEvent:SequenceEvent = getNextSequenceEvent();
			
			if (nextSequenceEvent) {
				if (nextSequenceEvent.nextEventTriggers) {
					// setup bindings so that we know when to fire the next event
					for (var i:int = 0; i<nextSequenceEvent.nextEventTriggers.length; i++) {
						var p:Property = nextSequenceEvent.nextEventTriggers[i];
						ChangeWatcher.watch(p.host, p.chain[0], onTriggerChange);
					}
				}
			}
			
			event.dispatch();
		}
		
		private function getNextSequenceEvent():SequenceEvent {
			var currentIndex:int = ArrayUtil.getItemIndex(_currentSequenceEvent, _sequenceEvents);
			return _sequenceEvents[currentIndex + 1];
		}
		
		private function onTriggerChange(pce:PropertyChangeEvent):void {
			var nextSequenceEvent:SequenceEvent = getNextSequenceEvent();
			if (nextSequenceEvent) {
				dispatchSequenceEvent(nextSequenceEvent);
			}
		}
		
	}
}