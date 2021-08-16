package com.sdg.control
{
	import com.sdg.control.room.RoomManager;
	import com.sdg.control.room.itemClasses.AvatarController;
	import com.sdg.control.room.itemClasses.RoomEntity;
	import com.sdg.event.UIDialogueEvent;
	import com.sdg.events.AASEventManager;
	import com.sdg.events.SocketEvent;
	import com.sdg.events.TriggerTileEvent;
	import com.sdg.model.ActionAllStarsEventType;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.RoomLayerType;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.sim.map.IOccupancyTile;
	import com.sdg.sim.map.TileMap;
	import com.sdg.sim.map.TriggerTile;
	import com.sdg.trivia.Question;
	import com.sdg.trivia.TokenCountHUD;
	import com.sdg.trivia.TriviaAnswer;
	import com.sdg.trivia.TriviaEvent;
	import com.sdg.trivia.TriviaQuestionCollection;
	import com.sdg.ui.UITriviaResult;
	import com.sdg.ui.UITriviaStamps;
	import com.sdg.util.LayoutUtil;
	import com.sdg.utils.Constants;
	import com.sdg.view.IRoomView;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class TriviaBackgroundController extends CairngormEventController implements IDynamicController
	{
		public static const USE_DEBUG_TEXT:Boolean = false;
		public static const RESULT:String = 'trivia result';
		public static const DEFAULT_BLUE_EMOTE:String = 'assets/images/blueGrid.png';
		public static const DEFAULT_RED_EMOTE:String = 'assets/images/redGrid.png';
		public static const RAIN_CLOUD_EMOTE:String = 'assets/swfs/rainCloud.swf';
		public static const SUN_EMOTE:String = 'assets/swfs/sun.swf';
		public static const FIREWORKS_EMOTE:String = 'assets/swfs/fireworks.swf';
		private var _roomContainer:IRoomView;
		private var _background:Object;
		private var _tmr:Timer;
		private var _inGameMode:Boolean;
		private var _currentQuestionIndex:int;
		private var _currentEvent:TriviaEvent;
		private var _userEntity:RoomEntity;
		private var _passSound:Sound;
		private var _failSound:Sound;
		private var _soundChannel:SoundChannel;
		private var _userTileSetID:String;
		private var _userCorrectCount:int;
		private var _trivResultPopUp:UITriviaResult;
		private var _trivStampsPopUp:UITriviaStamps;
		private var _correctAnswersArray:Array = [0, 0, 0, 0, 0];
		private var _timeToAnswerDuration:int = 20000;
		private var _showAnswerDuration:int = 15000;
		private var _resultXML:XML;
		private var _userStamps:int = 0;
		private var _newStamp:Boolean = false;
		private var _prizeOfTheWeekThumbnailURL:String;
		private var _answerHasBeenProcessed:Boolean = false;
		private var _timeStep:int = 0;
		private var _timeStepMax:int;
		private var _tokenCountHUD:TokenCountHUD;
		private var _tokensPerQuestion:int = 2;
		private var _checkedServerEvents:Boolean = false;
		private var _debugTimeField:TextField;
		
		private var _debugField:TextField;
		
		public function TriviaBackgroundController(roomContainer:IRoomView, data:Object)
		{
			super();
			
			// Get server time.
			SocketClient.getInstance().sendPluginMessage('avatar_handler', 'serverTime', { });
			
			// setup default values
			_roomContainer = roomContainer;
			_background = data.background;
			_passSound = data.passSound;
			_failSound = data.failSound;
			_inGameMode = false;
			_tmr = new Timer(250);
			_timeStepMax = Math.floor(1000 / _tmr.delay);
			_tmr.addEventListener(TimerEvent.TIMER, _timerInterval);
			_userEntity = RoomManager.getInstance().userController.entity;
			_userCorrectCount = 0;
			
			// Create a debug field.
			// Use a timer to continuously write the server time into it.
			_debugTimeField = new TextField();
			_debugTimeField.defaultTextFormat = new TextFormat('Arial', 12, 0xffffff);
			_debugTimeField.autoSize = TextFieldAutoSize.LEFT;
			_debugField = new TextField();
			_debugField.defaultTextFormat = new TextFormat('Arial', 12, 0xffffff);
			_debugField.width = 300;
			//_debugField.autoSize = TextFieldAutoSize.LEFT;
			_debugField.y = 20;
			_appendDebugText('DEBUG');
			if (USE_DEBUG_TEXT == true)
			{
				_background.addChild(_debugTimeField);
				_background.addChild(_debugField);
			}
			
			var srvTmr:Timer = new Timer(1000);
			srvTmr.addEventListener(TimerEvent.TIMER, onSrvTmr);
			srvTmr.start();
			
			function onSrvTmr(e:TimerEvent):void
			{
				_debugTimeField.text = ModelLocator.getInstance().serverDate.toString();
			}
			
			// Create token count hud.
			// Add as a pop up.
			// Position.
			_tokenCountHUD = new TokenCountHUD();
			_tokenCountHUD.visible = false;
			_roomContainer.addPopUp(_tokenCountHUD);
			LayoutUtil.CenterObject(_tokenCountHUD, 462, 590);
			
			// set the current question index
			// means we are currently on the first question
			_currentQuestionIndex = 0;
			
			// disable trivia tiles
			toggleTriviaTiles(false);
			
			// Listen for trigger tile events on the user room entity.
			_userEntity.addEventListener(TriggerTileEvent.TILE_TRIGGER, _avatarTriggerTile);
			
			// Listen for socket plugin events.
			SocketClient.getInstance().addEventListener(SocketEvent.PLUGIN_EVENT, _onPluginEvent);
			
			// Determine current event.
			_checkNextEvent();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function init():void
		{
			
		}
		
		public function destroy():void
		{
			// handle clean up
			_tmr.removeEventListener(TimerEvent.TIMER, _timerInterval);
			_tmr.reset();
			
			// Tell the background to do it's clean up work.
			try
			{
				trace('\nTriviaBackgroundController: Calling destroy on the background.\n');
				_background.destroy();
			}
			catch(e:Error)
			{
				trace('Failed to call destroy() on trivia background.');
				trace(e.message);
			}
			
			// Make sure token count hud is hidden.
			_hideTokenCount();
			_roomContainer.removePopUp(_tokenCountHUD);
			
			// Remove event listeners.
			_userEntity.removeEventListener(TriggerTileEvent.TILE_TRIGGER, _avatarTriggerTile);
			SocketClient.getInstance().removeEventListener(SocketEvent.PLUGIN_EVENT, _onPluginEvent);
			
			_inGameMode = false;
		}
		
		protected function toggleTriviaTiles(value:Boolean):void
		{
			// enable/disable trivia tile sets according to boolean value
			//
			// get the floor tile map for the room
			var floorTileMap:TileMap = RoomManager.getInstance().currentRoom.getMapLayer(RoomLayerType.FLOOR);
			// get all tiles of the "blueTrivia" set
			var triviaTiles:Array = floorTileMap.getTileSet('blueTrivia');
			toggleEventTiles(triviaTiles);
			// get all tiles of the "redTrivia" set
			triviaTiles = floorTileMap.getTileSet('redTrivia');
			toggleEventTiles(triviaTiles);
			
			function toggleEventTiles(tiles:Array):void
			{
				// takes an array of tiles and disables events for all of them
				var len:int = tiles.length;
				var i:int = 0;
				var tile:*;
				for (i; i < len; i++)
				{
					tile = tiles[i];
					if (tile as TriggerTile)
					{
						tile.eventEnabled = value;
					}
				}
			}
		}
		
		private function _getUserAnswer():Number
		{
			// Returns -1 if the user has not given a valid answer.
			// 0 if the answer is red.
			// 1 if the answer is blue.
			var answer:Number;
			var tileSetID:String = _getUserCurrentTileID();
			
			switch (tileSetID)
			{
				case 'redTrivia':
					answer = 0;
					break;
				case 'blueTrivia':
					answer = 1;
					break;
				default:
					answer = -1;
					break;
			}
			
			return answer;
		}
		
		private function _getUserCurrentTileID():String
		{
			// Return the tile set ID for the tile that the user is on.
			
			// Get the user's current map corrdinates.
			var row:Number = _userEntity.row;
			var col:Number = _userEntity.col;
			
			// Get the map tile that the user occupies.
			var mapLayer:TileMap = RoomManager.getInstance().currentRoom.getMapLayer(RoomLayerType.FLOOR);
			var tile:IOccupancyTile = mapLayer.getTile(col, row);
			var tileSetID:String = tile.tileSetID;
			
			return tileSetID;
		}
		
		private function _sendScoreToBackground(questionIndex:int = 1):void
		{
			// Pass some data to the background.
			try
			{
				_background.updateScore(_correctAnswersArray[0], _correctAnswersArray[1], _correctAnswersArray[2], _correctAnswersArray[3], _correctAnswersArray[4], questionIndex);
			}
			catch (e:Error)
			{
				trace('Unable to send score to the background: ' + e.message)
			}
		}
		
		private function _checkNextEvent():void
		{
			trace('TriviaBackgroundController: Checking next event.');
			var eventManager:AASEventManager = AASEventManager.getInstance();
			var currentEvent:TriviaEvent = eventManager.getCurrentEvent(ActionAllStarsEventType.TRIVIA_EVENT) as TriviaEvent;
			var nextEvent:TriviaEvent;
			_currentEvent = null;
			if (currentEvent != null)
			{
				// There is an event in progress.
				trace('TriviaBackgroundController: There is an event in progress.');
				_currentEvent = currentEvent;
			}
			else
			{
				nextEvent = eventManager.getNextEvent(ActionAllStarsEventType.TRIVIA_EVENT) as TriviaEvent;
			}
			
			if (nextEvent != null)
			{
				// There is an event coming up.
				trace('TriviaBackgroundController: There is an event coming up.');
				_currentEvent = nextEvent;
			}
			
			if (_currentEvent != null)
			{
				// Pass question data to the background.
				_passQuestionsToBackground();
				
				// Start the game timer.	
				_tmr.start();
			}
			else
			{
				trace('TriviaBackgroundController: There are NO events coming up.');
				// If there are no events.
				// Send a large number to the background.
				Object(_background).timeUntilGame = 99999999999;
				// Tell the server to send us info about any events it might know about.
				if (_checkedServerEvents != true)
				{
					var timeout:Timer = new Timer(30000);
					timeout.addEventListener(TimerEvent.TIMER, onTimeout);
					timeout.start();
					trace('TriviaBackgroundController: Querying server for RWS events.');
					RoomManager.getInstance().socketMethods.getRwsEvents();
					_checkedServerEvents = true;
					
					function onTimeout(e:TimerEvent):void
					{
						timeout.removeEventListener(TimerEvent.TIMER, onTimeout);
						timeout.reset();
						_checkedServerEvents = false;
					}
				}
			}
		}
		
		private function _loadEventImages():void
		{
			if (_currentEvent == null) return;
			
			trace('TriviaBackgroundController: Loading event images.');
			
			var questions:TriviaQuestionCollection = _currentEvent.questions;
			var question:Question;
			var answer1:TriviaAnswer;
			var answer2:TriviaAnswer;
			var i:int = 0;
			var len:int = questions.length;
			for (i; i < len; i++)
			{
				question = questions.get(i);
				
				answer1 = TriviaAnswer(question.answers[0]);
				loadAnswerImage(answer1.imageUrl, i, 0);
				answer2 = TriviaAnswer(question.answers[1]);
				loadAnswerImage(answer2.imageUrl, i, 1);
			}
			
			function loadAnswerImage(url:String, questionIndex:int, answerIndex:int):void
			{
				trace('TriviaBackgroundController: Loading image for questionIndex: ' + questionIndex + '; answerIndex: ' + answerIndex + '; ' + url);
				
				if (url.length < 1) return;
				var request:URLRequest = new URLRequest('http://' + Environment.getApplicationDomain() + url);
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader.load(request);
				
				function onLoadComplete(e:Event):void
				{
					// Remove listeners.
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
					
					trace('TriviaBackgroundController: Passing image to background for questionIndex: ' + questionIndex + '; answerIndex: ' + answerIndex + '.');
					
					// Pass the image to the background.
					try
					{
						_background.setAnswerImage(loader.content, questionIndex, answerIndex);
					}
					catch (e:Error)
					{
						trace('TriviaBackgroundController: Unable to set answer image on background.');
					}
				}
				
				function onIOError(e:IOErrorEvent):void
				{
					// Remove listeners.
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
					trace(e.text);
				}
			}
			
		}
		
		protected function commitAction(action:String, params:Object, consequence:Object = null):void
		{
			RoomManager.getInstance().sendItemAction(ModelLocator.getInstance().avatar, action, params, consequence);
		}
		
		private function _passQuestionsToBackground():void
		{
			trace('TriviaBackgroundController: Passing question data to the background.');
			try
			{
				var questions:TriviaQuestionCollection = _currentEvent.questions;
				var question:Question;
				var answer1:TriviaAnswer;
				var answer2:TriviaAnswer;
				var correctAnswerIndex:int;
				var url1:String;
				var url2:String;
				var i:int = 0;
				var len:int = questions.length;
				for (i; i < len; i++)
				{
					question = questions.get(i);
					answer1 = TriviaAnswer(question.answers[0]);
					answer2 = TriviaAnswer(question.answers[1]);
					correctAnswerIndex = (question.correctAnswerId == answer1.id) ? 0 : 1;
					url1 = 'http://' + Environment.getApplicationDomain() + answer1.imageUrl;
					url2 = 'http://' + Environment.getApplicationDomain() + answer2.imageUrl;
					_background.setQuestionData(i, question.text, answer1.text, answer2.text, correctAnswerIndex, url1, url2);
					trace(question.toString());
				}
				
			}
			catch (e:Error)
			{
				trace(e.message);
			}
		}
		
		private function _toggleGameMode(value:Boolean):void
		{
			trace('TriviaBackgroundController: Toggling game mode to ' + value + '.');
			_inGameMode = value;
			var opposite:Boolean = (value == true) ? false : true;
			
			// Enable trivia tiles.
			toggleTriviaTiles(value);
		}
		
		private function _processAnswer():void
		{
			trace('TriviaBackgroundController: Processing answer for question index ' + _currentQuestionIndex + '.');
			_appendDebugText('Processing answer for question index ' + _currentQuestionIndex + '.');
			// If the user is correct or wrong, show a reaction accordingly.
			_answerHasBeenProcessed = true;
			var questions:TriviaQuestionCollection = _currentEvent.questions;
			var currentQuestion:Question = questions.get(_currentQuestionIndex);
			var userAnswer:Number = _getUserAnswer();
			var userAnswerId:int;
			var correctAnswerId:int = currentQuestion.correctAnswerId;
			var userIsCorrect:Boolean = false;
			var questionId:int = currentQuestion.id;
			
			if (userAnswer != -1)
			{
				userAnswerId = TriviaAnswer(currentQuestion.answers[userAnswer]).id;
				trace('TriviaBackgroundController: User sanswer: ' + userAnswerId + ', Correct answer: ' + correctAnswerId);
				var userAvCntrl:AvatarController = RoomManager.getInstance().userController;
				var emoteName:String;
				
				if (userAnswerId == correctAnswerId)
				{
					trace('TriviaBackgroundController: User answer is correct.');
					// The user is correct.
					userCorrectCount++;
					_correctAnswersArray[_currentQuestionIndex] = 1;
					// Show a positive emote.
					userIsCorrect = true;
					emoteName = (Math.random() > 0.5) ? SUN_EMOTE : FIREWORKS_EMOTE;
					
					// Play the pass sound.
					if (_passSound != null) _soundChannel = _passSound.play();
				}
				else
				{
					trace('TriviaBackgroundController: User answer is incorrect.');
					// The user is wrong.
					// Show a negative emote.
					userIsCorrect = false;
					emoteName = RAIN_CLOUD_EMOTE;
					
					// Play the fail sound.
					if (_failSound != null) _soundChannel = _failSound.play();
				}
				
				userAvCntrl.emote(emoteName);
			}
			
			// Pass the answer to the server.
			var answerParams:Object = new Object();
			answerParams.eventId = _currentEvent.id;
			answerParams.questionId = questionId;
			answerParams.answerId = userAnswerId;
			answerParams.avatarId = ModelLocator.getInstance().user.avatarId;
			answerParams.correctFlag = (userIsCorrect == true) ? 1 : 0;
			answerParams.isLastAnswer = ((_currentQuestionIndex + 1) < questions.length) ? 0 : 1;
			commitAction('RwsUserAnswer', answerParams);
			
			// Get server time.
			//SocketClient.getInstance().sendPluginMessage('avatar_handler', 'serverTime', { });
		}
		
		private function _showGameResults():void
		{
			trace('TriviaBackgroundController: Showing game results.');
			var correctCount:int = userCorrectCount;
			// If we have result XML show the result UI.
			// If not than listen for a RESULT event.
			if (_resultXML != null)
			{
				showTriviaResult();
			}
			else
			{
				addEventListener(RESULT, onResult);
				
				// Create a result timeout.
				// If we don't get a result then we'll just fake it.
				var resultTimeOut:Timer = new Timer(1000);
				resultTimeOut.addEventListener(TimerEvent.TIMER, onResultTimeOut);
				resultTimeOut.start();
			}
			
			function showTriviaResult():void
			{
				// Show trivia game results.
				if (_trivResultPopUp != null) removeTriviaResults();
				_trivResultPopUp = new UITriviaResult(correctCount * _tokensPerQuestion);
				_trivResultPopUp.addEventListener(UIDialogueEvent.OK, trivResultOk);
				_roomContainer.addPopUp(_trivResultPopUp);
				centerPopUp(_trivResultPopUp);
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "quizGameComplete", { numCorrect:correctCount, gameTypeId:1 });
				
			}
			function onResult(e:Event):void
			{
				// Remove listener.
				removeEventListener(RESULT, onResult);
				
				// Show trivia game results.
				showTriviaResult();
			}
			function onResultTimeOut(e:TimerEvent):void
			{
				// Remove listener.
				removeEventListener(RESULT, onResult);
				resultTimeOut.removeEventListener(TimerEvent.TIMER, onResultTimeOut);
				
				resultTimeOut.reset();
				
				// Fake the trivia results.
				_userStamps = 1;
				_newStamp = true;
				
				// Show trivia game results.
				showTriviaResult();
			}
			function trivResultOk(e:UIDialogueEvent):void
			{
				removeTriviaResults();
				
				// Show trivia stamps popup.
				var membershipStatus:int = ModelLocator.getInstance().avatar.membershipStatus;
				trace('Membership status: ' + membershipStatus);
				if (_trivStampsPopUp != null) removeTriviaStamps();
				//_trivStampsPopUp = new UITriviaStamps(_userStamps, _newStamp, (membershipStatus == Constants.MEMBER_STATUS_PREMIUM || membershipStatus == Constants.MEMBER_STATUS_PREMIUM_CANCELLED) ? true : false, (_prizeOfTheWeekThumbnailURL != null) ? Environment.getApplicationUrl() + _prizeOfTheWeekThumbnailURL : '');
				_trivStampsPopUp = new UITriviaStamps(_userStamps, _newStamp, (_prizeOfTheWeekThumbnailURL != null) ? Environment.getApplicationUrl() + _prizeOfTheWeekThumbnailURL : '');
				_trivStampsPopUp.addEventListener(UIDialogueEvent.OK, trivStampOk);
				_roomContainer.addPopUp(_trivStampsPopUp);
				centerPopUp(_trivStampsPopUp);
				_trivStampsPopUp.animate();
			}
			function trivStampOk(e:UIDialogueEvent):void
			{
				removeTriviaStamps();
			}
			function centerPopUp(popUp:DisplayObject):void
			{
				popUp.x = 462 - popUp.width / 2;
				popUp.y = 332 - popUp.height / 2;
			}
			
			function removeTriviaResults():void
			{
				// Remove event listener.
				_trivResultPopUp.removeEventListener(UIDialogueEvent.OK, trivResultOk);
					
				// Remove trivia results popup.
				_roomContainer.removePopUp(_trivResultPopUp);
				
				_trivResultPopUp = null;
			}
			
			function removeTriviaStamps():void
			{
				// Remove event listener.
				_trivStampsPopUp.removeEventListener(UIDialogueEvent.OK, trivResultOk);
				
				// Remove trivia results popup.
				_roomContainer.removePopUp(_trivStampsPopUp);
				
				_trivStampsPopUp = null;
			}
		}
		
		private function _destroyCurrentEvent():void
		{
			// Destroy the current event.
			trace('TriviaBackgroundController: Destroying current event.');
			_currentEvent = null;
			userCorrectCount = 0;
			_correctAnswersArray = [0, 0, 0, 0, 0];
		}
		
		private function _appendDebugText(text:String):void
		{
			_debugField.text = text + '\n' + _debugField.text;
			trace(text);
		}
		
		private function _showTokenCount():void
		{
			if (_tokenCountHUD.visible == true) return;
			_tokenCountHUD.visible = true;
		}
		
		private function _hideTokenCount():void
		{
			if (_tokenCountHUD.visible == false) return;
			_tokenCountHUD.visible = false;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get userCorrectCount():int
		{
			return _userCorrectCount;
		}
		public function set userCorrectCount(value:int):void
		{
			_userCorrectCount = value;
			_tokenCountHUD.tokens = _userCorrectCount * _tokensPerQuestion;
			LayoutUtil.CenterObject(_tokenCountHUD, 462, 590);
			if (_userCorrectCount < 1)
			{
				_hideTokenCount();
			}
			else
			{
				_showTokenCount();
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		private function _timerInterval(e:TimerEvent):void
		{
			_timeStep++;
			
			// Create local vars.
			var eventStartTime:Date = _currentEvent.startTime;
			var mTimeUntilGame:int = Math.ceil(eventStartTime.time - ModelLocator.getInstance().serverDate.time);
			var sTimeUntilGame:int = Math.ceil(mTimeUntilGame / 1000);
			if (_inGameMode == false) Object(_background).timeUntilGame = sTimeUntilGame;
			
			var gameElapsed:Number = -mTimeUntilGame;
			var questionAnswerDuration:Number = _timeToAnswerDuration + _showAnswerDuration;
			var gameDuration:Number = questionAnswerDuration * _currentEvent.questions.length;
			var questionIndex:int = Math.floor(gameElapsed / questionAnswerDuration);
			var currentQuestionElapsed:Number = gameElapsed - (questionIndex * questionAnswerDuration);
			var timeUntilShowQuestion:Number = questionAnswerDuration - currentQuestionElapsed;
			var timeUntilShowAnswer:Number = questionAnswerDuration - _showAnswerDuration - currentQuestionElapsed;
			
			// If we are on a new question index,
			// reset some boolean values.
			if (_currentQuestionIndex != questionIndex)
			{
				_currentQuestionIndex = questionIndex;
				_answerHasBeenProcessed = false;
				_appendDebugText('Current question index: ' + _currentQuestionIndex + '; Time until game: ' + sTimeUntilGame);
				_appendDebugText('Event start time: ' + eventStartTime.toString());
				_appendDebugText('Server time: ' + ModelLocator.getInstance().serverDate.toString());
			}
			
			if (gameElapsed > 0)
			{
				// If not yet in game mode and the game is not over.
				if (_inGameMode == false && gameElapsed < gameDuration)
				{
					_toggleGameMode(true);
					_resultXML = null
					_sendScoreToBackground(_currentQuestionIndex + 1);
				}
				
				// If in game mode.
				if (_inGameMode == true)
				{
					// If it's time to process the answer and it hasn't been processed.
					if (timeUntilShowAnswer < 1 && _answerHasBeenProcessed == false)
					{
						// Process user answer and pass to the serrver.
						_processAnswer();
						_sendScoreToBackground(_currentQuestionIndex + 2);
					}
					
					// If the game should be over.
					if (gameElapsed > gameDuration)
					{
						// Show game results.
						_showGameResults();
						
						// Hide scoring hud.
						_sendScoreToBackground(0);
						
						// End the current game/event and check for the next.
						_toggleGameMode(false);
						_tmr.reset();
						_destroyCurrentEvent();
						_checkNextEvent();
					}
					
					try
					{
						_background.timeUntilShowAnswer = timeUntilShowAnswer;
					}
					catch(e:Error)
					{
						trace('Could not send "timeUntilShowAnswer" to the background: ' + e.message);
						trace('timeUntilShowAnswer: ' + timeUntilShowAnswer);
					}
				}
				
			}
//			else if (sTimeUntilGame < 60)
//			{
//				// Hide messaging hud.
//				RoomManager.getInstance().hudVisible = false;
//			}
			
			// Try to pass the data to the background.
			try
			{
				_background.currentQuestionIndex = questionIndex;
			}
			catch(e:Error)
			{
				trace('Could not pass "currentQuestionIndex" to background: ' + e.message);
			}
			
			if (questionIndex > -2) _background.timeUntilShowQuestion = timeUntilShowQuestion;
			
			if (_timeStep >= _timeStepMax) _timeStep = 0;
		}
		
		protected function _avatarTriggerTile(event:TriggerTileEvent):void
		{
			var params:Object = event.params;
			var eventName:String = String(event.params.eventName);
			var userAvCntrl:AvatarController = RoomManager.getInstance().userController;
			
			// Make sure there is a current event.
			if (_currentEvent == null) return;
			
			var questions:TriviaQuestionCollection = _currentEvent.questions;
			var currentQuestion:Question;
			var imageUrl:String;
			if (questions != null)
			{
				currentQuestion = questions.get(_currentQuestionIndex);
			}
			
			if (eventName == 'tileSet')
			{
				var setID:String = String(event.params.setID);
				if (currentQuestion == null) return;
				if (setID == 'redTrivia' && _userTileSetID != 'redTrivia')
				{
					_userTileSetID = 'redTrivia';
					// Show an emote.
					imageUrl = TriviaAnswer(currentQuestion.answers[0]).imageUrl;
					if (imageUrl.length < 1)
					{
						// Use default red trivia emote.
						userAvCntrl.emote(DEFAULT_RED_EMOTE);
					}
					else
					{
						// Use the answer image as an emote.
						// Pass in an emebeded emote to use as a failover.
						imageUrl = 'http://' + Environment.getApplicationDomain() + imageUrl;
						trace('TriviaBackgroundController: Using dynamic emote: ' + imageUrl);
						userAvCntrl.emote(imageUrl, DEFAULT_RED_EMOTE);
					}
					
				}
				else if (setID == 'blueTrivia' && _userTileSetID != 'blueTrivia')
				{
					_userTileSetID = 'blueTrivia';
					// Show an emote.
					imageUrl = TriviaAnswer(currentQuestion.answers[1]).imageUrl;
					if (imageUrl.length < 1)
					{
						// Use default blue trivia emote.
						userAvCntrl.emote(DEFAULT_BLUE_EMOTE);
					}
					else
					{
						// Use the answer image as an emote.
						// Pass in an emebeded emote to use as a failover.
						imageUrl = 'http://' + Environment.getApplicationDomain() + imageUrl;
						trace('TriviaBackgroundController: Using dynamic emote: ' + imageUrl);
						userAvCntrl.emote(imageUrl, DEFAULT_BLUE_EMOTE);
					}
				}
			}
		}
		
		protected function _onPluginEvent(e:SocketEvent):void
		{
			// Handle socket event according to action parameter.
			var action:String = e.params.action;
			switch (action)
			{
				case 'rwsResult' :
					_resultXML = new XML(e.params.rwsResult);
					trace('Trivia Result XML:\n' + _resultXML);
					_userStamps = (_resultXML.stamps != null) ? _resultXML.stamps : 1;
					_newStamp = (_resultXML.stamps.@isNew != null && _resultXML.stamps.@isNew == 'true') ? true : false;
					_prizeOfTheWeekThumbnailURL = (_resultXML.prize.thumbnailUrl != null) ? _resultXML.prize.thumbnailUrl : null;
					dispatchEvent(new Event(RESULT));
					break;
				default :
					break;
			}
		}
		
	}
}