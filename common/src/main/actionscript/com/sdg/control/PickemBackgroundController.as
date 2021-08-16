package com.sdg.control
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.control.room.RoomManager;
	import com.sdg.control.room.itemClasses.AvatarController;
	import com.sdg.display.GameNotification;
	import com.sdg.events.SocketEvent;
	import com.sdg.events.TriggerTileEvent;
	import com.sdg.model.FallbackImageURL;
	import com.sdg.model.QuestionCategoryId;
	import com.sdg.model.Room;
	import com.sdg.net.Environment;
	import com.sdg.pickem.FifthPickResolutionPanel;
	import com.sdg.pickem.IPickemScreenView;
	import com.sdg.pickem.InQueScreen;
	import com.sdg.pickem.PickemData;
	import com.sdg.pickem.PickemInstance;
	import com.sdg.pickem.PickemModel;
	import com.sdg.pickem.PickemPickEvent;
	import com.sdg.pickem.PickemViewState;
	import com.sdg.trivia.Question;
	import com.sdg.trivia.TriviaAnswer;
	import com.sdg.trivia.TriviaQuestionCollection;
	import com.sdg.view.IRoomView;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class PickemBackgroundController extends EventDispatcher implements IDynamicController
	{
		public static const ANSWER_HIDE_FINISH:String = 'answer hide finish';
		public static const KILL_CURRENT_QUE:String = 'kill current que';
		
		private var _answerImages:Array;
		private var _hidingAnswers:Boolean;
		private var _roomPicksSent:Boolean;
		private var _resultsQueryed:Boolean;
		private var _listeningForQuestionStats:Boolean;
		private var _recievedResults:Boolean;
		private var _userPicksQueryed:Boolean;
		private var _defaultAnswerColor1:uint;
		private var _defaultAnswerColor2:uint;
		private var _tutorialSwf:DisplayObject;
		private var _roomContainer:IRoomView;
		private var _background:Object;
		private var _backgroundDisplaybject:Sprite;
		private var _tmr:Timer;
		private var _userTileSetID:String;
		private var _tutorialIsVisible:Boolean;
		private var _pickemModel:PickemModel;
		private var _inQueToStart:Boolean;
		private var _queScreenIsVisible:Boolean;
		private var _fifthPickPanelIsShown:Boolean;
		private var _finalPickMade:Boolean;
		
		public function PickemBackgroundController(roomContainer:IRoomView, data:Object)
		{
			super();
			
			// Create PickemModel.
			_pickemModel = new PickemModel();
			// Initialize model by passing in abstract data object.
			_pickemModel.init(data);
			
			// setup default values
			_roomContainer = roomContainer;
			_tmr = new Timer(250);
			_tmr.addEventListener(TimerEvent.TIMER, _timerInterval);
			_answerImages = new Array();
			_hidingAnswers = false;
			_roomPicksSent = false;
			_listeningForQuestionStats = false;
			_recievedResults = false;
			_userPicksQueryed = false;
			_defaultAnswerColor1 = 0xE9252D;
			_defaultAnswerColor2 = 0x1D51D7;
			_tutorialIsVisible = false;
			_inQueToStart = false;
			_queScreenIsVisible = false;
			_fifthPickPanelIsShown = false;
			_finalPickMade = false;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function init():void
		{
			// Get server time.
			_pickemModel.socketClient.sendPluginMessage('avatar_handler', 'serverTime', { });
			
			// Query to determine if user has played pickem before.
			var url:String = 'http://' + Environment.getApplicationDomain() + '/test/dyn/getStat?avatarId=' + _pickemModel.userAvatar.id + '&statNameId=10';
			var request:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onPlayerPickemQueryComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onPlayerPickemQueryError);
			urlLoader.load(request);
			
			// Load the tutorial.
			var tutorialUrl:String = _pickemModel.tutorialUrl;
			var tutorialRequest:URLRequest = new URLRequest(tutorialUrl);
			var tutorialLoader:Loader = new Loader();
			tutorialLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onTutorialLoadComplete);
			tutorialLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onTutorialLoadError);
			tutorialLoader.load(tutorialRequest);
			
			// Add pick card.
			_roomContainer.addPopUp(_pickemModel.pickCard);
			
			// Toggle trivia tiles off by default.
			_pickemModel.floorTilesEnabled = false;
			
			// Listen for events.
			_pickemModel.addEventListener(PickemPickEvent.NEW_PICK, onNewPick);
			_pickemModel.addEventListener(PickemPickEvent.FINAL_PICK, onFinalPick);
			_pickemModel.addEventListener(PickemPickEvent.FIRST_TIME_GAME_COMPLETE, onFirstTimeGameComplete);
			_pickemModel.addEventListener(PickemPickEvent.VOTE_REGISTERED, onVoteRegistered);
			_pickemModel.userEntity.addEventListener(TriggerTileEvent.TILE_TRIGGER, avatarTriggerTile);
						
			// Query for pickem events.
			requestPickemEvents();
			
			// load game sounds.
			loadSounds();
			
			function onPlayerPickemQueryComplete(e:Event):void
			{
				// Remove listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onPlayerPickemQueryComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onPlayerPickemQueryError);
				
				// Get XML from loaded data.
				var xml:XML = new XML(urlLoader.data);
				
				// Determine if this is the first time that the user has played pickem.
				if (xml.@status == '409')
				{
					// This is the first time that the user has played pickem.
					_pickemModel.firstTimePlayed = true;
				}
				else
				{
					// This is not the first time that the user has played pickem.
					_pickemModel.firstTimePlayed = false;
				}
			}
			
			function onPlayerPickemQueryError(e:IOErrorEvent):void
			{
				// Remove listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onPlayerPickemQueryComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onPlayerPickemQueryError);
			}
			
			function onTutorialLoadComplete(e:Event):void
			{
				// Remove listeners.
				tutorialLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onTutorialLoadComplete);
				tutorialLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onTutorialLoadError);
				
				trace('PickemBackgroundController: Loaded tutorial.');
				
				// Show the tutorial.
				_tutorialSwf = tutorialLoader.content;
				_tutorialSwf.addEventListener('skip', onTutorialSkip);
				showTutorial();
			}
			
			function onTutorialLoadError(e:IOErrorEvent):void
			{
				// Remove listeners.
				tutorialLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onTutorialLoadComplete);
				tutorialLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onTutorialLoadError);
				
				trace('PickemBackgroundController: Error loading tutorial.');
				
				// Que player to begin gameplay.
				quePlayerToStartGameplay();
			}
			
			function onTutorialSkip(e:Event):void
			{
				// Remove listeners.
				_tutorialSwf.removeEventListener('skip', onTutorialSkip);
				
				// Hide the tutorial.
				hideTutorial();
				
				// Que player to begin gameplay.
				quePlayerToStartGameplay();
			}
		}
		
		public function destroy():void
		{
			_tmr.removeEventListener(TimerEvent.TIMER, _timerInterval);
			_tmr.reset();
			
			// Remove scorecard.
			_roomContainer.removePopUp(_pickemModel.pickCard);
			
			// Remove event listeners.
			_pickemModel.userEntity.removeEventListener(TriggerTileEvent.TILE_TRIGGER, avatarTriggerTile);
			_pickemModel.removeEventListener(PickemPickEvent.NEW_PICK, onNewPick);
			_pickemModel.removeEventListener(PickemPickEvent.FINAL_PICK, onFinalPick);
			_pickemModel.removeEventListener(PickemPickEvent.FIRST_TIME_GAME_COMPLETE, onFirstTimeGameComplete);
			_pickemModel.removeEventListener(PickemPickEvent.VOTE_REGISTERED, onVoteRegistered);
			
			// Dispatch for an event to kill current que.
			killCurrentQue();
			
			// Destroy model.
			_pickemModel.destroy();
		}
		
		private function requestPickemEvents():void
		{
			// Query for pickem events.
			RoomManager.getInstance().socketMethods.getPickemEvents();
		}
		
		private function setCurrentQuestionIndex(value:int):void
		{
			if (value == _pickemModel.currentQuestionIndex) return;
			_pickemModel.currentQuestionIndex = value;
			trace('PickemBackgroundController: Setting current question index: ' + _pickemModel.currentQuestionIndex + '.');
			resetPicks();
			hideAnswers();
			hideCountdown();
			loadAnswerImages(_pickemModel.currentQuestionIndex);
		}
		
		private function resetPicks():void
		{
			trace('PickemBackgroundController: Resseting picks.');
			_roomPicksSent = false;
			_resultsQueryed = false;
			_listeningForQuestionStats = false;
			_recievedResults = false;
		}
		
		private function loadAnswerImages(questionIndex:int):void
		{
			// Get URLs.
			var pickemData:PickemData = _pickemModel.pickemData;
			if (pickemData == null) return;
			
			var question:Question = pickemData.questions.get(questionIndex);
			var domain:String = Environment.getApplicationDomain();
			
			// Make sure there are answers.
			if (question.answers[0] == null || question.answers[1] == null) return;
			
			var image1Url:String = 'http://' + domain + TriviaAnswer(question.answers[0]).imageUrl;
			//var image1Url:String = 'http://' + domain + '/test/static/clipart/playerLogoTemplate?playerId=5';
			var image2Url:String = 'http://' + domain + TriviaAnswer(question.answers[1]).imageUrl;
			//var image2Url:String = 'http://' + domain + '/test/static/clipart/playerLogoTemplate?playerId=10';
			if (image1Url.length < 1 || image2Url.length < 1) return;
			
			trace('PickemBackgroundController: Loading images for question index: ' + questionIndex + '; id: ' + question.id + '.');
			
			var triedFallbackImages:Boolean = false;
			var req1:URLRequest = new URLRequest(image1Url);
			var req2:URLRequest = new URLRequest(image2Url);
			var loader1:Loader = new Loader();
			var loader2:Loader = new Loader();
			loader1.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete1);
			loader1.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError1);
			loader1.load(req1);
			
			function onLoadComplete1(e:Event):void
			{
				// Remove listeners.
				loader1.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete1);
				loader1.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError1);
				
				// If content has a child, use it.
				var content:DisplayObject = DisplayObject(loader1.content);
				
				setAnswerImage(content, questionIndex, 0);
				
				// Load the second image.
				loader2.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete2);
				loader2.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError2);
				loader2.load(req2);
			}
			function onLoadComplete2(e:Event):void
			{
				// Remove listeners.
				loader2.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete2);
				loader2.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError2);
				
				// If content has a child, use it.
				var content:DisplayObject = DisplayObject(loader2.content);
				
				setAnswerImage(content, questionIndex, 1);
				bothImagesReady();
			}
			function onLoadError1(e:IOErrorEvent):void
			{
				if (triedFallbackImages == false)
				{
					// Try to use fallback images.
					triedFallbackImages = true;
					image1Url = 'http://' + Environment.getApplicationDomain() + FallbackImageURL.RED_AAS;
					image2Url = 'http://' + Environment.getApplicationDomain() + FallbackImageURL.BLUE_AAS;
					req1 = new URLRequest(image1Url);
					req2 = new URLRequest(image2Url);
					loader1.load(req1);
				}
				else
				{
					// Remove listeners.
					loader1.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete1);
					loader1.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError1);
				
					// If one of the images fails, don't use either.
					invalidateImages();
				}
			}
			function onLoadError2(e:IOErrorEvent):void
			{
				// Remove listeners.
				loader2.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete2);
				loader2.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError2);
				
				if (triedFallbackImages == false)
				{
					// Try to use fallback images.
					triedFallbackImages = true;
					image1Url = 'http://' + Environment.getApplicationDomain() + FallbackImageURL.RED_AAS;
					image2Url = 'http://' + Environment.getApplicationDomain() + FallbackImageURL.BLUE_AAS;
					req1 = new URLRequest(image1Url);
					req2 = new URLRequest(image2Url);
					loader1.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete1);
					loader1.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError1);
					loader1.load(req1);
				}
				else
				{
					// If one of the images fails, don't use either.
					invalidateImages();
				}
			}
			function invalidateImages():void
			{
				setAnswerImage(getDefaultRedAnswerImage(), questionIndex, 0);
				setAnswerImage(getDefaultBlueAnswerImage(), questionIndex, 1);
				bothImagesReady();
			}
			function bothImagesReady():void
			{
				// Show answers.
				// If the answers are currently being hidden, wait until they are hidden, then show them.
				
				if (_hidingAnswers == false)
				{
					applyAnswerColors();
					showAnswers();
					showCountdown();
				}
				else
				{
					addEventListener(ANSWER_HIDE_FINISH, onAnswerHide);
				}
				
				function onAnswerHide(e:Event):void
				{
					// Remove event listener.
					removeEventListener(ANSWER_HIDE_FINISH, onAnswerHide);
					
					applyAnswerColors();
					showAnswers();
					showCountdown();
				}
			}
		}
		
		private function applyAnswerColors():void
		{
			// Update answer colors on screen view.
			// Create locals.
			var pickemData:PickemData = _pickemModel.pickemData;
			if (pickemData == null) return;
			var questions:TriviaQuestionCollection = pickemData.questions;
			var currentQuestion:Question = questions.get(_pickemModel.currentQuestionIndex);
			var answer1:TriviaAnswer = TriviaAnswer(currentQuestion.answers[0]);
			var answer2:TriviaAnswer = TriviaAnswer(currentQuestion.answers[1]);
			var screenView:IPickemScreenView = _pickemModel.screenView;
			
			// Try to use primary color.
			if (answer1.color1 < 16581376 && answer2.color1 < 16581376)
			{
				// Pass in answer colors.
				screenView.answerColor1 = answer1.color1;
				screenView.answerColor2 = answer2.color1;
				
				_pickemModel.floorTriangle1.color = answer1.color1;
				_pickemModel.floorTriangle2.color = answer2.color1;
			}
			else
			{
				// Pass in default colors.
				screenView.answerColor1 = _defaultAnswerColor1;
				screenView.answerColor2 = _defaultAnswerColor2;
				
				_pickemModel.floorTriangle1.color = _defaultAnswerColor1;
				_pickemModel.floorTriangle2.color = _defaultAnswerColor2;
			}
			
		}
		
		private function setAnswerImage(image:DisplayObject, questionIndex:int, answerIndex:int):void
		{
			if (_answerImages[questionIndex] == null) _answerImages[questionIndex] = [];
			var array:Array = _answerImages[questionIndex];
			array[answerIndex] = image;
		}
		
		private function getAnswerImage(questionIndex:int, answerIndex:int):DisplayObject
		{
			var array:Array = _answerImages[questionIndex];
			if (array == null) return null;
			return DisplayObject(array[answerIndex]);
		}
		
		private function getDefaultRedAnswerImage():DisplayObject
		{
			var image:Sprite = new Sprite();
			image.graphics.beginFill(0xff0000);
			image.graphics.drawRect(0, 0, 100, 100);
			return image;
		}
		
		private function getDefaultBlueAnswerImage():DisplayObject
		{
			var image:Sprite = new Sprite();
			image.graphics.beginFill(0x0000ff);
			image.graphics.drawRect(0, 0, 100, 100);
			return image;
		}
		
		private function hideAnswers():void
		{
			// Hide answers by sending answer position to 0.
			// For answer 1 and 2.
			
			if (_hidingAnswers == true) return;
			_hidingAnswers = true;
			var a1Hidden:Boolean = false;
			var a2Hidden:Boolean = false;
			var animationManager:AnimationManager = _pickemModel.animationManager;
			animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);
			animationManager.property(_pickemModel.screenView, 'answer1Position', 0, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			animationManager.property(_pickemModel.screenView, 'answer2Position', 0, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onAnimationFinish(e:AnimationEvent):void
			{
				var obj:IPickemScreenView = e.animTarget as IPickemScreenView;
				var prop:String = e.animProperty;
				
				if (obj == null) return;
				if (obj != _pickemModel.screenView) return;
				
				if (prop == 'answer1Position' && obj.answer1Position == 0)
				{
					a1Hidden = true;
					if (a2Hidden == true) finish();
				}
				else if (prop == 'answer2Position' && obj.answer2Position == 0)
				{
					a2Hidden = true;
					if (a1Hidden == true) finish();
				}
			}
			
			function removeListeners():void
			{
				animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);
			}
			
			function finish():void
			{
				removeListeners();
				_hidingAnswers = false;
				dispatchEvent(new Event(ANSWER_HIDE_FINISH));
			}
		}
		
		private function showAnswers():void
		{
			_pickemModel.animationManager.property(_pickemModel.screenView, 'answer1Position', 1, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_pickemModel.animationManager.property(_pickemModel.screenView, 'answer2Position', 1, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		private function hideCountdown():void
		{
			_pickemModel.animationManager.property(_pickemModel.screenView, 'countdownAlpha', 0, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		private function showCountdown():void
		{
			_pickemModel.animationManager.property(_pickemModel.screenView, 'countdownAlpha', 1, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		private function getResultsForQuestion(question:Question):void
		{
			_resultsQueryed = true;
			var questionId:int = question.id;
			trace('PickemBackgroundController: Loading pickem results for question ' + questionId + '.');
			var url:String = 'http://' + Environment.getApplicationDomain() + '/test/pickem?requestType=answerCount&questionId=' + questionId;
			var request:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlLoader.load(request);
			
			function onComplete(e:Event):void
			{
				// When the result data is loaded, remove the listeners.
				removeListeners();
				
				_recievedResults = true;
				
				trace('PickemBackgroundController: Received pickem results for question ' + questionId + '.');
				
				var resultXML:XML = new XML(urlLoader.data);
				var count1:Number = resultXML.QuestionStats.answerCount[0];
				var count2:Number = resultXML.QuestionStats.answerCount[1];
				
				if (count1 > -1 && count2 > -1)
				{
					trace('Answer 1 Count: ' + count1);
					trace('Answer 2 Count: ' + count2);
					
					// Pass result data to the screen view.
					passWorldResults(count1, count2);
				}
				else
				{
					trace('PickemBackgroundController: Could not find 2 answers within pickem results XML.');
				}
			}
			function onError(e:IOErrorEvent):void
			{
				// There was an error while loading the result data.
				removeListeners();
				
				trace('Error: There was an error while loading pickem result data.');
				trace(e.text);
			}
			function removeListeners():void
			{
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		private function listenForQuestionStats(question:Question):void
		{
			_listeningForQuestionStats = true;
			
			trace('PickemBackgroundController: Listening for QuestionStats from socket server for question ' + question.id + '.');
			
			var timeout:Timer = new Timer(8000);
			timeout.addEventListener(TimerEvent.TIMER, onTimer);
			_pickemModel.socketClient.addEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
			timeout.start();
			
			function onPluginEvent(e:SocketEvent):void
			{
				// Handle socket plugin event.
				var action:String = e.params.action;
				
				// If it's not a QuestionStats event, ignore it.
				if (action != 'QuestionStats') return;
				
				// If we've already recieved question stats for the current question, we should ignore this one.
				if (_recievedResults == true) return;
				
				// Extract XML.
				if (e.params.QuestionStats != null)
				{
					var questionStats:XML = new XML(e.params.QuestionStats);
					
					// Make sure we recieved data for the correct question.
					var questionId:int = questionStats.@questionId;
					if (questionId != question.id) return;
					
					trace('PickemBackgroundController: Received QuestionStats from socket server for question ' + questionId + '.');
					
					// Kill the timeout timer.
					killTimeout();
					
					_recievedResults = true;
					
					var count1:Number = questionStats.answerCount[0];
					var count2:Number = questionStats.answerCount[1];
					
					if (count1 > -1 && count2 > -1)
					{
						trace('Answer 1 Count: ' + count1);
						trace('Answer 2 Count: ' + count2);
						
						// Pass result data to the screen view.
						passWorldResults(count1, count2);
					}
					else
					{
						trace('PickemBackgroundController: Could not find 2 answers within QuestionStats XML.');
						getResultsForQuestion(question);
					}
					
				}
				else
				{
					trace('PickemBackgroundController: Could not find question stats xml.');
					
					getResultsForQuestion(question);
				}
			}
			
			function onTimer(e:TimerEvent):void
			{
				// Kill the timeout timer.
				killTimeout();
				
				trace('PickemBackgroundController: Timeout reached for QuestionStats from socket server for question ' + question.id + '.');
				
				getResultsForQuestion(question);
			}
			
			function killTimeout():void
			{
				// Kill timer.
				timeout.removeEventListener(TimerEvent.TIMER, onTimer);
				timeout.reset();
				
				// Remove the socket event listener.
				_pickemModel.socketClient.removeEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
				
				// Set flag.
				_listeningForQuestionStats = false;
			}
		}
		
		private function updateUserPicks(pickemData:PickemData):void
		{
			// Request user pick data from the server.
			_userPicksQueryed = true;
			var avatarId:uint = _pickemModel.userAvatar.id;
			var pickemEventId:int = int(pickemData.id);
			var url:String = 'http://' + Environment.getApplicationDomain() + '/test/pickem?requestType=lastResults&avatarId=' + avatarId;
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader(request);
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			trace('\n\nPickemBackgroundController: Requesting user picks from server for avatar id: ' + avatarId + '.');
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				removeListeners();
				
				trace('PickemBackgroundController: Loaded user picks from server for avatar id: ' + avatarId + '.');
				
				// Parse user picks.
				var userPicksXML:XML = new XML(loader.data);
				trace(userPicksXML);
				_pickemModel.parseUserPicksXML(userPicksXML, pickemEventId);
			}
			function onIOError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				removeListeners();
				
				trace('PickemBackgroundController: Error retrieving user picks from server for avatar id: ' + _pickemModel.userAvatar.id + '.');
				trace(e.text);
			}
			function removeListeners():void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
		}
		
		private function getBitmapCopy(source:DisplayObject, width:Number, height:Number):Bitmap
		{
			var iW:Number = source.width;
			var iH:Number = source.height;
			var bitData:BitmapData = new BitmapData(width, height, true, 0x000000);
			source.width = width;
			source.height = height;
			bitData.draw(source);
			source.width = iW;
			source.height = iH;
			return new Bitmap(bitData, 'auto', true);
		}
		
		private function loadSounds():void
		{
			var loadQue:Array = [];
			var url:String;
			var request:URLRequest;
			
			// Countdown sound.
			url = _pickemModel.countdownSoundUrl;
			request = new URLRequest(url);
			var countdownSound:Sound = new Sound();
			countdownSound.addEventListener(Event.COMPLETE, onCountdownLoadComplete);
			countdownSound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			countdownSound.load(request);
			
			// Vote registered sound.
			url = _pickemModel.voteRegisteredSoundUrl;
			request = new URLRequest(url);
			var voteRegisteredSound:Sound = new Sound();
			voteRegisteredSound.addEventListener(Event.COMPLETE, onVoteLoadComplete);
			voteRegisteredSound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			voteRegisteredSound.load(request);
			
			// Poll over sound sound.
			url = _pickemModel.pollOverSoundUrl;
			request = new URLRequest(url);
			var pollOverSound:Sound = new Sound();
			pollOverSound.addEventListener(Event.COMPLETE, onPollOverLoadComplete);
			pollOverSound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			pollOverSound.load(request);
			
			// Results in sound.
			url = _pickemModel.resultsInSoundUrl;
			request = new URLRequest(url);
			var resultsInSound:Sound = new Sound();
			resultsInSound.addEventListener(Event.COMPLETE, onResultsInLoadComplete);
			resultsInSound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			resultsInSound.load(request);
			
			// Background loop sound.
			url = _pickemModel.backgroundLoopSoundUrl;
			request = new URLRequest(url);
			var backgroundLoopSound:Sound = new Sound();
			backgroundLoopSound.addEventListener(Event.COMPLETE, onBackgroundLoopLoadComplete);
			backgroundLoopSound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			backgroundLoopSound.load(request);
			
			function onCountdownLoadComplete(e:Event):void
			{
				// Remove listener.
				countdownSound.removeEventListener(Event.COMPLETE, onCountdownLoadComplete);
				countdownSound.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				_pickemModel.countdownSound = countdownSound;
			}
			
			function onVoteLoadComplete(e:Event):void
			{
				// Remove listener.
				voteRegisteredSound.removeEventListener(Event.COMPLETE, onVoteLoadComplete);
				voteRegisteredSound.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				_pickemModel.voteRegisteredSound = voteRegisteredSound;
			}
			
			function onPollOverLoadComplete(e:Event):void
			{
				// Remove listener.
				pollOverSound.removeEventListener(Event.COMPLETE, onPollOverLoadComplete);
				pollOverSound.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				_pickemModel.pollOverSound = pollOverSound;
			}
			
			function onResultsInLoadComplete(e:Event):void
			{
				// Remove listener.
				resultsInSound.removeEventListener(Event.COMPLETE, onResultsInLoadComplete);
				resultsInSound.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				_pickemModel.resultsInSound = resultsInSound;
			}
			
			function onBackgroundLoopLoadComplete(e:Event):void
			{
				// Remove listener.
				backgroundLoopSound.removeEventListener(Event.COMPLETE, onBackgroundLoopLoadComplete);
				backgroundLoopSound.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				_pickemModel.backgroundLoopSound = backgroundLoopSound;
				_pickemModel.screenView.backgroundLoopSound = backgroundLoopSound;
			}
			
			function onLoadError(e:IOErrorEvent):void
			{
				// Remove listener;
				var sound:Sound = e.currentTarget as Sound;
				trace('PickemBackgroundController: Error loading sound: ' + sound.url);
				sound.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			}
		}
		
		private function showGameNotification(text:String, duration:Number):void
		{
			// Create a GameNotification object.
			var notification:GameNotification = new GameNotification(400);
			notification.text = text;
			notification.x = 925 / 2 - notification.width / 2;
			notification.y = 665 - notification.height - 50;
			notification.addEventListener(GameNotification.CLOSE_CLICK, onCloseClick);
			notification.alpha = 0;
			
			// Create local var for animation manager.
			var animationManager:AnimationManager = _pickemModel.animationManager;
			
			// Use a timer to determine how long the notification will show for.
			var timer:Timer = new Timer(duration);
			var timerKilled:Boolean = false;
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			// Show the notification and start the timer.
			showNotification();
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				// When the timer hits it's interval.
				
				// Kill the timer.
				killTimer();
				
				// Hide the notificiation.
				hideNotification();
			}
			function onCloseClick(e:Event):void
			{
				// Kill the timer.
				killTimer();
				
				// Hide the notificiation.
				hideNotification();
			}
			function showNotification():void
			{
				_roomContainer.addPopUp(notification);
				animationManager.alpha(notification, 1, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			}
			function hideNotification():void
			{
				animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);
				animationManager.alpha(notification, 0, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			}
			function killTimer():void
			{
				if (timerKilled == true) return;
				timerKilled = true;
				// Remove the timer event listener.
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				// Stop timer.
				timer.reset();
			}
			function onAnimationFinish(e:AnimationEvent):void
			{
				if (e.animTarget == notification && notification.alpha == 0)
				{
					// Hide animation just finished.
					animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);
					_roomContainer.removePopUp(notification);
				}
			}
		}
		
		private function showTutorial():void
		{
			if (_tutorialIsVisible == true) return;
			_tutorialIsVisible = true;
			_pickemModel.backgroundScreen.addChild(_tutorialSwf);
			
			// Make the user avatar walk to an unoccupied / non pick tile, so they don't
			// make any unintentional picks while the pop up is up.
			_pickemModel.sendUserToOpenTile();
		}
		
		private function hideTutorial():void
		{
			if (_tutorialIsVisible == false) return;
			_tutorialIsVisible = false;
			_pickemModel.backgroundScreen.removeChild(_tutorialSwf);
		}
		
		private function showGameCompletePopUp():void
		{
			var url:String = _pickemModel.gameCompleteImageUrl;
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Create pop up.
				var popUp:DisplayObject = loader.content;
				popUp.addEventListener('close', onClose);
				_roomContainer.addPopUp(popUp);
				
				
				function onClose(e:Event):void
				{
					// Remove listener.
					popUp.removeEventListener('close', onClose);
					
					// Remove pop up.
					_roomContainer.removePopUp(popUp);
				}
			}
			function onError(e:IOErrorEvent):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		private function quePlayerToStartGameplay():void
		{
			// Stop gameplay timer.
			_tmr.reset();
			// Set a flag to true.
			_inQueToStart = true;
			// Listen for a kill que event.
			// This event means that the que timer should be reset.
			addEventListener(KILL_CURRENT_QUE, onKillQue);
			// Determine time until next question starts.
			// Countdown and begin gameplay on that question.
			var pickemInstance:PickemInstance = _pickemModel.getCurrentPickemInstance();
			if (pickemInstance == null)
			{
				// Could not establish a pickem instance.
				_tmr.start();
				return;
			}
			
			// Create local vars.
			var pickemData:PickemData = _pickemModel.pickemData;
			var elapsedCurrentQuestion:int = pickemInstance.elapsedCurrentQuestion;
			var questionResultDuration:Number = _pickemModel.questionDuration;
			var timeUntilNextQuestion:Number = questionResultDuration - elapsedCurrentQuestion;
			var screenView:IPickemScreenView = _pickemModel.screenView;
			var currentDate:Date = _pickemModel.date;
			
			// Check for error cases.
			if (pickemData == null)
			{
				// Could not establish pickem data.
				_tmr.start();
				return;
			}
			else if (currentDate.time < pickemData.startTime.time)
			{
				// Pickem data is not current.
				// Pickem should not start yet.
				_tmr.start();
				return;
			}
			else if (currentDate.time > pickemData.endTime.time)
			{
				// Pickem data is not current.
				// Pickem is over.
				_tmr.start();
				return;
			}
			
			// Hide answers.
			hideAnswers();
			// Hide countdown.
			hideCountdown();
			
			// Send view into poll state.
			screenView.viewState = PickemViewState.POLL_STATE;
			
			// Add the InQueScreen to the screen.
			// Fade it in.
			var animationManager:AnimationManager = _pickemModel.animationManager;
			var inQueScreen:InQueScreen = new InQueScreen(screenView.width, screenView.height, _pickemModel.animationManager);
			inQueScreen.alpha = 0;
			_pickemModel.backgroundScreen.addChild(inQueScreen);
			animationManager.alpha(inQueScreen, 1, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			// If there are less than 3 seconds until the next question,
			// Countdown until the question after that.
			if (timeUntilNextQuestion < 3000)
			{
				timeUntilNextQuestion += questionResultDuration;
			}
			
			// Create a timer that will hit it's interval when the next question should start.
			var timerCount:int = Math.round(timeUntilNextQuestion / 250);
			var timer:Timer = new Timer(250, timerCount);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				// Determine countodwn time until next question.
				// Pass it to the que screen.
				timeUntilNextQuestion -= timer.delay;
				inQueScreen.countdownTime = Math.round(timeUntilNextQuestion / 1000);
			}
			
			function onTimerComplete(e:TimerEvent):void
			{
				// Remove event listener and kill timer.
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				timer.reset();
				removeEventListener(KILL_CURRENT_QUE, onKillQue);
				
				// Remove InQueScreen.
				// Fade it out.
				animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);
				animationManager.alpha(inQueScreen, 0, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				
				// Start gameplay timer.
				_tmr.start();
				
				// Set flag to false.
				_inQueToStart = false;
			}
			
			function onKillQue(e:Event):void
			{
				// Remove event listener and kill timer.
				if (timer != null)
				{
					timer.removeEventListener(TimerEvent.TIMER, onTimer);
					timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
					timer.reset();
				}
				removeEventListener(KILL_CURRENT_QUE, onKillQue);
				
				// Set flag to false.
				_inQueToStart = false;
			}
			
			function onAnimationFinish(e:AnimationEvent):void
			{
				if (e.animTarget == inQueScreen && inQueScreen.alpha == 0)
				{
					// The InQueScreen is done fading out.
					animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);
					_pickemModel.backgroundScreen.removeChild(inQueScreen);
				}
			}
		}
		
		private function killCurrentQue():void
		{
			// Dispatch for an event to kill current que.
			dispatchEvent(new Event(KILL_CURRENT_QUE));
		}
		
		private function passWorldResults(count1:Number, count2:Number):void
		{
			// Pass result data to the screen view.
			var total:Number = count1 + count2;
			if (total < 1)
			{
				_pickemModel.screenView.worldResultBreakdown = 0.5;
			}
			else if (count1 < 1)
			{
				_pickemModel.screenView.worldResultBreakdown = 0;
			}
			else
			{
				_pickemModel.screenView.worldResultBreakdown = count1 / total;
			}
			
			// If the fifth pick panel is not sown,
			// play a results in sound.
			if (_fifthPickPanelIsShown != true)	_pickemModel.playSound(_pickemModel.resultsInSound);
		}
		
		private function setAnswerImages(questionIndex:int):void
		{
			var screenView:IPickemScreenView = _pickemModel.screenView;
			var answer1Image:DisplayObject = getAnswerImage(questionIndex, 0);
			var answer2Image:DisplayObject = getAnswerImage(questionIndex, 1);
			if (answer1Image != null && answer2Image != null && answer1Image != screenView.answer1Image && answer2Image != screenView.answer2Image)
			{
				// If the answers are currently being hidden, wait until they are hidden, then set the new images.
				if (_hidingAnswers == true)
				{
					addEventListener(ANSWER_HIDE_FINISH, onAnswersHide);
				}
				else
				{
					screenView.answer1Image = answer1Image;
					screenView.answer2Image = answer2Image;
				}
				
				function onAnswersHide(e:Event):void
				{
					// Remove event listener.
					removeEventListener(ANSWER_HIDE_FINISH, onAnswersHide);
					
					screenView.answer1Image = answer1Image;
					screenView.answer2Image = answer2Image;
				}
			}
		}
		
		private function finalPickComplete():void
		{
			// Pause gameplay.
			_tmr.reset();
			
			// Set flag to true.
			_fifthPickPanelIsShown = true;
			
			// Show 5th pick resolution panel.
			var panel:FifthPickResolutionPanel = _pickemModel.fifthPickResolution;
			panel.addEventListener('skip', onSkip);
			panel.addEventListener('exit', onExit);
			_pickemModel.backgroundScreen.addChild(panel);
			
			// Make the user avatar walk to an unoccupied / non pick tile, so they don't
			// make any unintentional picks while the pop up is up.
			_pickemModel.sendUserToOpenTile();
			
			function onSkip(e:Event):void
			{
				// Destroy panel.
				destroyPanel();
				
				// Que player to continue gameplay on the next question.
				quePlayerToStartGameplay();
			}
			
			function onExit(e:Event):void
			{
				// Destroy panel.
				destroyPanel();
				
				// Exit room to sports lobby.
				_pickemModel.goToRoom(Room.SPORTS_LOBBY);
			}
			
			function destroyPanel():void
			{
				// Remove listeners.
				panel.removeEventListener('skip', onSkip);
				panel.removeEventListener('exit', onExit);
				
				// Remove 5th pick panel.
				_pickemModel.backgroundScreen.removeChild(panel);
				
				// Set flag to false.
				_fifthPickPanelIsShown = false;
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function _timerInterval(e:TimerEvent):void
		{
			// Handle Pickem event countdown.
			// Get a current PickemInstance object.
			var pickemInstance:PickemInstance = _pickemModel.getCurrentPickemInstance();
			
			// Get pickem data.
			var pickemData:PickemData = _pickemModel.pickemData;
			
			// Create local vars.
			var screenView:IPickemScreenView = _pickemModel.screenView;
			var currentDate:Date = _pickemModel.date;
			var elapsedCurrentQuestion:int;
			var questionIndex:int;
			var currentQuestion:Question;
			var state:String;
			var countdown:int;
			var answer1:TriviaAnswer;
			var answer2:TriviaAnswer;
			if (pickemData == null)
			{
				// There is no pickem data.
				offHoursState();
				return;
			}
			else if (currentDate.time < pickemData.startTime.time || currentDate.time > pickemData.endTime.time)
			{
				// This pickem data is not current.
				offHoursState();
				return;
			}
			else if (pickemInstance != null)
			{
				elapsedCurrentQuestion = pickemInstance.elapsedCurrentQuestion;
				questionIndex = pickemInstance.questionIndex;
				state = pickemInstance.state;
				countdown = pickemInstance.countdown;
				currentQuestion = pickemData.questions.get(questionIndex);
				if (currentQuestion != null)
				{
					answer1 = TriviaAnswer(currentQuestion.answers[0]);
					answer2 = TriviaAnswer(currentQuestion.answers[1]);
				}
				else
				{
					// If we could not establish a current question.
					// Go into the error state.
					offHoursState();
					return;
				}
			}
			else
			{
				// If we could not establish a pickem instance.
				// Go into the error state.
				offHoursState();
				return;
			}
			
			if (_userPicksQueryed != true)
			{
				updateUserPicks(pickemData);
			}
			
			if (state != PickemViewState.OFF_HOURS && questionIndex > -1)
			{
				// Set current question index.
				setCurrentQuestionIndex(questionIndex);
				
				// If both answer images are loaded, set them on the view.
				setAnswerImages(questionIndex);
			}
			
			// Take action according to current game state.
			if (state == PickemViewState.POLL_STATE)
			{
				if (_finalPickMade == true)
				{
					// Stop gameplay to show a game resolution.
					_finalPickMade = false;
					finalPickComplete();
					return;
				}
				else
				{
					// Enable floor tiles.
					_pickemModel.floorTilesEnabled = true;
				}
			}
			else if (state == PickemViewState.RESULT_AGGREGATION_STATE)
			{
				if (_pickemModel.answerHasBeenProcessed == false) _pickemModel.processUserAnswer();
				
				// Make sure we are listeneing for question stats.
				if (_recievedResults == false && _listeningForQuestionStats == false) listenForQuestionStats(currentQuestion);
				
				// Disable floor tiles.
				_pickemModel.floorTilesEnabled = false;
				
				// If the current view state is the POLL STATE and it is about to be the result aggregation state,
				// Play a poll over sound.
				if (screenView.viewState == PickemViewState.POLL_STATE)
				{
					_pickemModel.playSound(_pickemModel.pollOverSound);
				}
			}
			else
			{
				// Assume that state is PickemViewState.WORLD_RESULT_STATE
				
				// Disable floor tiles.
				_pickemModel.floorTilesEnabled = false;
				
				// If we haven't gotten the results by now, make sure we get them.
				if (_recievedResults == false && _resultsQueryed == false) getResultsForQuestion(currentQuestion);
			}
			
			// Update view.
			screenView.viewState = state;
			screenView.questionText = currentQuestion.text;
			screenView.answer1Text = answer1.text;
			screenView.answer2Text = answer2.text;
			// If countdown is different then the screen's current countdown value.
			if (screenView.countdownTime != countdown)
			{
				// Apply new value to the screen.
				screenView.countdownTime = countdown;
				// If in the poll state and if the value is less than 5, play a countdown sound.
				if (state == PickemViewState.POLL_STATE && screenView.countdownTime < 5) _pickemModel.playSound(_pickemModel.countdownSound);
			}
			
			function offHoursState():void
			{
				// Update view.
				screenView.offHoursMessage = 'Sports Psychic will resume at 4am PST.';
				screenView.viewState = PickemViewState.OFF_HOURS;
			}
		}
		
		protected function avatarTriggerTile(event:TriggerTileEvent):void
		{
			var params:Object = event.params;
			var eventName:String = String(event.params.eventName);
			var userAvCntrl:AvatarController = RoomManager.getInstance().userController;
			var pickemData:PickemData = _pickemModel.pickemData;
			
			// If there is no pickem data, do nothing!
			if (pickemData == null) return;
			
			var questions:TriviaQuestionCollection = pickemData.questions;
			var currentQuestion:Question;
			var imageUrl:String;
			if (questions != null)
			{
				currentQuestion = questions.get(_pickemModel.currentQuestionIndex);
			}
			
			if (currentQuestion == null) return;
			
			if (eventName == 'tileSet')
			{
				var setID:String = String(event.params.setID);
				var fallbackURL:String;
				var emote:String;
				if (setID == 'redTrivia' && _userTileSetID != 'redTrivia')
				{
					_userTileSetID = 'redTrivia';
					// Show an emote.
					// Assign a failover emote.
					fallbackURL = 'http://' + Environment.getApplicationDomain() + FallbackImageURL.RED_AAS;
					// If it's a team question use the teams logo.
					if (currentQuestion.categoryId == QuestionCategoryId.TEAM)
					{
						imageUrl = TriviaAnswer(currentQuestion.answers[0]).imageUrl;
						emote = 'http://' + Environment.getApplicationDomain() + imageUrl;
						trace('PickemBackgroundController: Using dynamic emote: ' + imageUrl);
					}
					else
					{
						// If it's not a team question, use the default emotes.
						emote = fallbackURL;
					}
					
					// Show the emote.
					userAvCntrl.emote(emote, fallbackURL, false, _pickemModel.emoteSize, _pickemModel.emoteSize);
				}
				else if (setID == 'blueTrivia' && _userTileSetID != 'blueTrivia')
				{
					_userTileSetID = 'blueTrivia';
					// Show an emote.
					// Assign a failover emote.
					fallbackURL = 'http://' + Environment.getApplicationDomain() + FallbackImageURL.BLUE_AAS;
					// If it's a team question use the teams logo.
					if (currentQuestion.categoryId == QuestionCategoryId.TEAM)
					{
						imageUrl = TriviaAnswer(currentQuestion.answers[1]).imageUrl;
						emote = 'http://' + Environment.getApplicationDomain() + imageUrl;
						trace('PickemBackgroundController: Using dynamic emote: ' + imageUrl);
					}
					else
					{
						// If it's not a team question, use the default emotes.
						emote = fallbackURL;
					}
					
					// Show the emote.
					userAvCntrl.emote(emote, fallbackURL, false, _pickemModel.emoteSize, _pickemModel.emoteSize);
				}
			}
		}
		
		private function onHelpClick(e:Event):void
		{
			// Make sure we have a tutorial swf.
			if (_tutorialSwf == null) return;
			
			// Make sure the tutorial is not visible.
			if (_tutorialIsVisible == true) return;
			
			// Stop game timer.
			_tmr.reset();
			
			// Kill current que.
			killCurrentQue();
			
			// Show the Sport Psychic tutorial.
			_tutorialSwf.addEventListener('skip', onSkipClick);
			showTutorial();
			
			function onSkipClick(e:Event):void
			{
				// Remove skip click listener.
				_tutorialSwf.removeEventListener('skip', onSkipClick);
				
				// Remove tutorial.
				hideTutorial();
				
				// Que player to begin gameplay.
				quePlayerToStartGameplay();
			}
		}
		
		private function onNewPick(e:PickemPickEvent):void
		{
			_pickemModel.populateScoreCard();
		}
		
		private function onFinalPick(e:PickemPickEvent):void
		{
			_finalPickMade = true;
		}
		
		private function onFirstTimeGameComplete(e:PickemPickEvent):void
		{
			showGameCompletePopUp();
			// Make the user avatar walk to an unoccupied / non pick tile, so they don't
			// make any unintentional picks while the pop up is up.
			_pickemModel.sendUserToOpenTile();
		}
		
		private function onVoteRegistered(e:PickemPickEvent):void
		{
			// When a vote is registred.
			// Have the screen view display appropriate animations.
			_pickemModel.screenView.voteRegistered();
			// Play a vote registered sound.
			_pickemModel.playSound(_pickemModel.voteRegisteredSound);
		}
		
	}
}