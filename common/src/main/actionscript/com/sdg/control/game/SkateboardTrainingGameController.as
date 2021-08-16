package com.sdg.control.game
{
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.SocketEvent;
	import com.sdg.model.GameAssetId;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.skate.SkateTrickEvent;
	import com.sdg.util.AssetUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class SkateboardTrainingGameController extends SkateboardGameController
	{
		public function SkateboardTrainingGameController(gameId:int)
		{
			super(gameId);
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function setUp():void
		{
			super.setUp();
			
			_postTrickDelay = 3000;
			_scoreTricks = true;
			_allowKeyCombo = false;
			
			// Add listeners.
			addEventListener('enablekeycombo', onEnableKeyCombo);
			addEventListener('highlighttricksheet', onHighlightTrickSheet);
			addEventListener('unhighlighttricksheet', onUnHighlightTrickSheet);
			addEventListener('closetricksheet', onCloseTrickSheet);
			
			// Hide time display.
			_uiView.timeDisplayVisible = false;
			// Hide trick sheet button.
			_uiView.trickButtonVisible = false;
			
			// Load up event xml to handle training flow.
			var url:String = AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'skate_training_event_flow.xml');
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Start event flow.
				startEventFlow(new XML(loader.data));
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		override protected function cleanUp():void
		{
			// Add listeners.
			removeEventListener('enablekeycombo', onEnableKeyCombo);
			removeEventListener('highlighttricksheet', onHighlightTrickSheet);
			removeEventListener('unhighlighttricksheet', onUnHighlightTrickSheet);
			removeEventListener('closetricksheet', onCloseTrickSheet);
			
			super.cleanUp();
		}
		
		override protected function handleCurrentInputDirection():Point
		{
			var distance:Point = super.handleCurrentInputDirection();
			// Dispatch move event.
			if (Math.abs(distance.x) > 0 || Math.abs(distance.y) > 0)
			{
				dispatchEvent(new Event('move'));
			}
			
			return distance;
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function startEventFlow(eventsXml:XML):void
		{
			var currentEventIndex:int = 0;
			var timer:Timer;
			processCurrentEvent();
			
			function processCurrentEvent():void
			{
				// Get current event.
				var event:XML = eventsXml.events.e[currentEventIndex];
				if (!event) return;
				var type:String = event.@type;
				
				// Make sure the UI has not been destroyed.
				if (!_uiView) return;
				
				// Handle event.
				switch (type)
				{
					case 'msg':
						_uiView.setPersistentMessage(event.@value, true);
						break;
					case 'finish':
						finish();
						break;
				}
				
				// Handle condition for event to complete.
				var completeCondition:XML = (event.cnd[0]) ? new XML(event.cnd) : null;
				var cndType:String = (completeCondition) ? completeCondition.@type : null;
				switch (cndType)
				{
					case 'time':
						// Wait a period of time before completing this event.
						timer = new Timer(completeCondition.@value);
						timer.addEventListener(TimerEvent.TIMER, onTimer);
						timer.start();
						break;
					case 'key':
						_keyboardInputController.addKeyDownHandler(completeCondition.@value, onKeyDown);
						break;
					case 'action':
						addEventListener(String(completeCondition.@value), onAction);
						break
					default:
						finishCurrentEvent();
						break;
				}
				
				// Handle actions.
				var action:XML = (event.act[0]) ? new XML(event.act) : null;
				var actionType:String = (action) ? action.@type : null;
				switch (actionType)
				{
					case 'event':
						dispatchEvent(new Event(String(action.@value)));
						break;
				}
			}
			
			function finishCurrentEvent():void
			{
				// Get current event.
				var event:XML = eventsXml.events.e[currentEventIndex];
				if (!event) return;
				var type:String = event.@type;
				
				// Make sure the UI has not been destroyed.
				if (!_uiView) return;
				
				// Clean up event.
				switch (type)
				{
					case 'msg':
						// Maybe remove the message.
						break;
				}
				
				// Handle condition for event.
				var completeCondition:XML = (event.cnd[0]) ? new XML(event.cnd) : null;
				var cndType:String = (completeCondition) ? completeCondition.@type : null;
				switch (cndType)
				{
					case 'key':
					case 'action':
						// Play success sound.
						_soundBank.playSound(AssetUtil.GetGameAssetUrl(GameAssetId.SKATEBOARD_GAME, 'success.mp3'), 0.3);
						break;
				}
				
				// Process next event.
				currentEventIndex++;
				processCurrentEvent();
			}
			
			function onTimer(e:TimerEvent):void
			{
				// Kill timer.
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;
				// Finish event.
				finishCurrentEvent();
			}
			
			function onKeyDown(e:KeyboardEvent):void
			{
				// Remove listener.
				_keyboardInputController.removeKeyDownHandler(e.keyCode, onKeyDown);
				// Finish event.
				finishCurrentEvent();
			}
			
			function onAction(e:Event):void
			{
				// Get current event.
				var event:XML = eventsXml.events.e[currentEventIndex];
				var completeCondition:XML = new XML(event.cnd);
				
				// Handle based on action value.
				var actionValue:String = completeCondition.@value;
				var params:XML = (completeCondition.p[0]) ? new XML(completeCondition.p) : null;
				switch (actionValue)
				{
					case SkateTrickEvent.TRICK:
						// Make sure the correct trick was executed.
						var trickEvent:SkateTrickEvent = SkateTrickEvent(e);
						var trickName:String = (params.@name[0] && params.@name[0] != '*') ? params.@name : trickEvent.trickName;
						var maxAccuracyDeviation:Number = (params.@maxAccuracyDeviation[0]) ? params.@maxAccuracyDeviation : 1;
						var mustBeMoving:Boolean = (params.@mustBeMoving == '1') ? true : trickEvent.skaterIsMoving;
						var minLength:int = (params.@minLength) ? params.@minLength : 0;
						// Make sure the trick satisfies all requirements.
						if (trickEvent.trickName != trickName)
						{
							_uiView.showMessage('Wrong trick.', 3000);
							return;
						}
						if (trickEvent.averageAccuracyDeviation > maxAccuracyDeviation)
						{
							_uiView.showMessage('Time it better.', 3000);
							return;
						}
						if (trickEvent.comboLength < minLength)
						{
							_uiView.showMessage('Try a longer trick.', 3000);
							return;
						}
						if (trickEvent.skaterIsMoving != mustBeMoving)
						{
							_uiView.showMessage('Try that while moving.', 3000);
							return;
						}
						
						complete();
						
						break;
					default:
						if (e.type == actionValue) complete();
						break;
				}
				
				function complete():void
				{
					// Remove listener.
					removeEventListener(e.type, onAction);
					// Finish event.
					finishCurrentEvent();
				}
			}
		}
		
		private function finish():void
		{
			// Send finish message to server and exit the room.
			SocketClient.getInstance().sendPluginMessage('room_enumeration', 'mpFinishPracticeGame', {avatarId: _localAvatar.avatarId, gameId: _gameId, roomId: _room.id});
			RoomManager.getInstance().enterRoom('public_202', false);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		override protected function onLaunchGame(e:SocketEvent):void
		{
			// In training mode, we only need to listen for score messages.
			SocketClient.addPluginActionHandler('mpAddToScore', onAddToScore);
		}
		
		private function onEnableKeyCombo(e:Event):void
		{
			// Enable key combo and trick scoring.
			_scoreTricks = true;
			_allowKeyCombo = true;
		}
		
		private function onHighlightTrickSheet(e:Event):void
		{
			// Draw attention to the trick sheet button.
			// Make sure it is visible.
			_uiView.trickButtonVisible = true;
			_uiView.highlightTrickSheet(true);
		}
		
		private function onUnHighlightTrickSheet(e:Event):void
		{
			// Remove highlight from trick sheet button.
			_uiView.highlightTrickSheet(false);
		}
		
		private function onCloseTrickSheet(e:Event):void
		{
			// Remove highlight from trick sheet button.
			_uiView.highlightTrickSheet(false);
		}
		
	}
}