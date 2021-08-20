package com.sdg.pickem
{
	import com.boostworthy.animation.management.AnimationManager;
	import com.sdg.control.room.RoomManager;
	import com.sdg.control.room.itemClasses.AvatarController;
	import com.sdg.control.room.itemClasses.RoomEntity;
	import com.sdg.display.AlignType;
	import com.sdg.events.AASEventManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.FallbackImageURL;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.PointCollection;
	import com.sdg.model.RoomLayerType;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.sim.map.IOccupancyTile;
	import com.sdg.sim.map.TileMap;
	import com.sdg.sim.map.TriggerTile;
	import com.sdg.trivia.Question;
	import com.sdg.trivia.TriviaAnswer;
	import com.sdg.trivia.TriviaQuestionCollection;
	import com.sdg.ui.UIPickemInGameScorecard;
	import com.sdg.view.IRoomView;

	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;

	public class PickemModel extends EventDispatcher implements IPickemDataProvider
	{
		private var _background:Object;
		private var _backgroundDisplaybject:Sprite;
		private var _backgroundScreen:Sprite;
		private var _defaultAnswerColor1:uint;
		private var _defaultAnswerColor2:uint;
		private var _screenView:IPickemScreenView;
		private var _floorTriangle1:FloorTriangle;
		private var _floorTriangle2:FloorTriangle;
		private var _animationManager:AnimationManager;
		private var _pickCard:UIPickemInGameScorecard;
		private var _emoteSize:Number;
		private var _currentQuestionIndex:int;
		private var _tilesEnabled:Boolean;
		private var _floorTilesEnabled:Boolean;
		private var _countdownSoundUrl:String;
		private var _voteRegisteredSoundUrl:String;
		private var _pollOverSoundUrl:String;
		private var _resultsInSoundUrl:String;
		private var _backgroundLoopSoundUrl:String;
		private var _countdownSound:Sound;
		private var _voteRegisteredSound:Sound;
		private var _pollOverSound:Sound;
		private var _resultsInSound:Sound;
		private var _backgroundLoopSound:Sound;
		private var _userPicks:UserPickCollection;
		private var _tutorialUrl:String;
		private var _firstTimePlayed:Boolean;
		private var _answerHasBeenProcessed:Boolean;
		private var _queScreenUrl:String;
		private var _queScreen:DisplayObject;
		private var _fifthPickResolution:FifthPickResolutionPanel;
		private var _questionsSinceLastStart:int;

		public function PickemModel()
		{
			super();
		}

		public function init(data:Object):Boolean
		{
			// Pull values from Object.
			try
			{
				_background = data.background;
				_backgroundDisplaybject = _background as Sprite;
				_backgroundScreen = data.screen as Sprite;
			}
			catch (e:Error)
			{
				// Could not get necesary values from data object.
				return false;
			}

			// Validate necesary values.
			if (_backgroundScreen == null) return false;

			// Setup default values.
			_defaultAnswerColor1 = 0xE9252D;
			_defaultAnswerColor2 = 0x1D51D7;
			_emoteSize = 80;
			_currentQuestionIndex = -1;
			_floorTilesEnabled = true;
			_countdownSoundUrl = 'audio/countdown_beep.mp3';
			_voteRegisteredSoundUrl = 'audio/camera_click.mp3';
			_pollOverSoundUrl = 'audio/organ_burst.mp3';
			_resultsInSoundUrl = 'audio/bring.mp3';
			_backgroundLoopSoundUrl = 'audio/sport_psychic_loop.mp3';
			_userPicks = new UserPickCollection();
			_tutorialUrl = 'swfs/sport_psychic_tutorial.swf';
			_firstTimePlayed = false;
			_answerHasBeenProcessed = false;
			_queScreenUrl = 'swfs/sport_psychic_que_screen.swf';
			_questionsSinceLastStart = 0;

			// Create an animation manager.
			_animationManager = new AnimationManager();

			// Create screen view.
			_screenView = new PickemScreenView(this);
			_screenView.width = _backgroundScreen.width;
			_screenView.height = _backgroundScreen.height;
			_backgroundScreen.addChild(DisplayObject(_screenView));

			// Create floor triangles.
			_floorTriangle1 = new FloorTriangle(422, 219, 0xff0000, AlignType.LEFT);
			_floorTriangle1.x = 13;
			_floorTriangle1.y = 388;
			_floorTriangle1.mouseEnabled = false;
			_floorTriangle1.blendMode = BlendMode.OVERLAY;
			_backgroundDisplaybject.addChild(_floorTriangle1);
			_floorTriangle2 = new FloorTriangle(424, 219, 0x0000ff, AlignType.RIGHT);
			_floorTriangle2.x = 490;
			_floorTriangle2.y = 388;
			_floorTriangle2.mouseEnabled = false;
			_floorTriangle2.blendMode = BlendMode.OVERLAY;
			_backgroundDisplaybject.addChild(_floorTriangle2);

			// Create the pickem scorecard.
			_pickCard = new UIPickemInGameScorecard(this);
			renderPickCard();

			return true;
		}

		////////////////////
		// INSTANCE METHODS
		////////////////////

		public function destroy():void
		{
			_screenView.destroy();
			_pickCard.destroy();
		}

		private function toggleTriviaTiles(value:Boolean):void
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

		private function getOpenTileCoordinates():Point
		{
			// Return coordinates for a non occupied / non pick tile.
			var floorTileMap:TileMap = RoomManager.getInstance().currentRoom.getMapLayer(RoomLayerType.FLOOR);
			var openTileCoordinates:PointCollection = floorTileMap.getAllOpenTileCoordinates();
			var i:int = 0;
			var len:int = openTileCoordinates.length;
			var tileCoordinate:Point;
			var tile:IOccupancyTile;
			var nonPickOpenCoordinates:PointCollection = new PointCollection();
			for (i; i < len; i++)
			{
				tileCoordinate = openTileCoordinates.getAt(i);

				// Get the tile at these coordinates.
				tile = floorTileMap.getTile(tileCoordinate.x, tileCoordinate.y);
				if (tile == null) continue;

				// Make sure it is not a pick tile.
				if (tile.tileSetID != 'blueTrivia' && tile.tileSetID != 'redTrivia')
				{
					// This is a non pick tile.
					nonPickOpenCoordinates.push(tileCoordinate);
				}
			}

			if (nonPickOpenCoordinates.length > 0)
			{
				return nonPickOpenCoordinates.getAt(0);
			}

			return null;
		}

		public function sendUserToOpenTile():Boolean
		{
			var openTileCoordinates:Point = getOpenTileCoordinates();
			if (openTileCoordinates == null)
			{
				// There is no open tile.
				return false;
			}
			var userAvatarController:AvatarController = RoomManager.getInstance().userController;
			userAvatarController.walk(openTileCoordinates.x, openTileCoordinates.y);

			return true;
		}

		public function getCurrentPickemInstance():PickemInstance
		{
			// Create local var for pickem data.
			var pData:PickemData = pickemData;
			if (pData == null) return null;

			// Determine pickem cycle length.
			var questionResultDuration:Number = PickemEvent.getQuestionDuration();
			var cycleDuration:Number = questionResultDuration * pData.questions.length;

			// Pickem runs continuously so determine where it should be right now based on the current time.
			var elapsedSinceStart:int = Math.floor(date.time - pData.startTime.time);
			var elapsedCurrentCycle:int = Math.floor(elapsedSinceStart % cycleDuration);
			var elapsedCurrentQuestion:int = Math.floor(elapsedCurrentCycle % questionResultDuration);
			var questionIndex:int = Math.floor(elapsedCurrentCycle / questionResultDuration);

			// Determine proper view state and countdown value.
			var state:String;
			var countdown:int;
			var endRoomResultDuration:int = PickemEvent.POLL_DURATION + PickemEvent.ROOM_RESULT_DURATION;
			var endResultAggregation:int = PickemEvent.POLL_DURATION + PickemEvent.RESULT_AGGREGATION_DURATION;
			if (elapsedCurrentQuestion < PickemEvent.POLL_DURATION)
			{
				state = PickemViewState.POLL_STATE;
				countdown = Math.floor((PickemEvent.POLL_DURATION - elapsedCurrentQuestion) / 1000);
			}
			else if (elapsedCurrentQuestion < endResultAggregation)
			{
				state = PickemViewState.RESULT_AGGREGATION_STATE;
				countdown = Math.floor((endResultAggregation - elapsedCurrentQuestion) / 1000);
			}
			else
			{
				state = PickemViewState.WORLD_RESULT_STATE;
				countdown = Math.floor((questionResultDuration - elapsedCurrentQuestion) / 1000);
			}

			// Return a PickemInstance object.
			return new PickemInstance(elapsedSinceStart, elapsedCurrentCycle, elapsedCurrentQuestion, questionIndex, state, countdown);
		}

		public function getUserAnswer():Number
		{
			// Returns -1 if the user has not given a valid answer.
			// 0 for answer 1.
			// 1 for answer 2.
			var answer:Number;
			var tileSetID:String = getUserCurrentTileID();

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

		private function getUserCurrentTileID():String
		{
			// Return the tile set ID for the tile that the user is on.

			// Get the user's current map corrdinates.
			var row:Number = userEntity.row;
			var col:Number = userEntity.col;

			// Get the map tile that the user occupies.
			var mapLayer:TileMap = RoomManager.getInstance().currentRoom.getMapLayer(RoomLayerType.FLOOR);
			var tile:IOccupancyTile = mapLayer.getTile(col, row);
			var tileSetID:String = tile.tileSetID;

			return tileSetID;
		}

		public function addPick(pick:UserPick):void
		{
			// Determine if there is another pick with the same event ID and question ID.
			var i:int = 0;
			var len:int = _userPicks.length;
			var eventId:int = pick.eventId;
			var questionId:int = pick.questionId;
			var pickEvent:PickemPickEvent = new PickemPickEvent(PickemPickEvent.NEW_PICK);
			for (i; i < len; i++)
			{
				var comparePick:UserPick = _userPicks.getAt(i);
				if (comparePick.eventId == eventId && comparePick.questionId == questionId)
				{
					if (comparePick.pickedAnswer == pick.pickedAnswer)
					{
						// The picks have the same values.
						// Do nothing.
					}
					else
					{
						// Replace the compare pick with the new pick.
						_userPicks.setAt(pick, i);

						// Dispatch new pick event.
						dispatchEvent(pickEvent)
					}
					return;
				}
			}

			// If we get to this line, simply append the new pick to the collection.
			_userPicks.push(pick);

			// Dispatch new pick event.
			dispatchEvent(pickEvent)
		}

		public function parseUserPicksXML(userPicksXML:XML, pickemEventId:int):void
		{
			trace('PickemModel: Parsing user picks XML.');
			// Parse out all picks with the proper pickem event id.
			var i:int = 0;
			var len:int = XML(userPicksXML.questions).children().length();
			var eventId:int;
			var collection:UserPickCollection = new UserPickCollection();
			var questionXML:XML;
			var questionId:int;
			var pickId:int;
			var userPick:UserPick;
			for (i; i < len; i++)
			{
				questionXML = userPicksXML.questions.question[i];
				if (questionXML == null) continue;

				// Validate data.
				if (questionXML.@eventId == null) continue;
				if (questionXML.@id == null) continue;
				if (questionXML.answer[0].@answerId == null) continue;
				if (questionXML.answer[1].@answerId == null) continue;
				if (questionXML.answer[0].@selected == null) continue;
				if (questionXML.answer[1].@selected == null) continue;

				eventId = questionXML.@eventId;
				if (eventId != pickemEventId) continue;

				questionId = questionXML.@id;
				pickId = -1; // Default to -1.
				if (questionXML.answer[0].@selected == 1) pickId = questionXML.answer[0].@answerId;
				if (questionXML.answer[1].@selected == 1) pickId = questionXML.answer[1].@answerId;

				trace('PickemModel: Creating UserPick for questionId: ' + questionId + ', pickId: ' + pickId + '.');

				// Create a UserPick object.
				var question:Question = pickemData.getQuestion(questionId);
				if (question == null)
				{
					trace('PickemModel: Could not get question id: ' + questionId + ' from PickemData.');
					continue;
				}
				var answer:TriviaAnswer = question.getAnswer(pickId);
				if (answer == null)
				{
					trace('PickemModel: Could not get answer id: ' + pickId + ' from question id: ' + questionId + ' from PickemData.');
					continue;
				}

				userPick = new UserPick(eventId, questionId, answer);
				addPick(userPick);
			}
		}

		public function processUserAnswer():void
		{
			// Create local for question index.
			var _currentQuestionIndex:int = _currentQuestionIndex;
			trace('PickemModel: Processing answer for question index ' + _currentQuestionIndex + '.');
			// If the user is correct or wrong, show a reaction accordingly.
			if (_answerHasBeenProcessed == true) return;
			_answerHasBeenProcessed = true;
			if (pickemData == null) return;
			var questions:TriviaQuestionCollection = pickemData.questions;
			var currentQuestion:Question = questions.get(_currentQuestionIndex);
			if (currentQuestion == null) return;
			var userAnswer:Number = getUserAnswer();
			var userAnswerId:int;
			var questionId:int = currentQuestion.id;
			var potentialPicksComplete:Boolean = false;

			if (userAnswer != -1)
			{
				// The user has given an answer.
				userAnswerId = TriviaAnswer(currentQuestion.answers[userAnswer]).id;
				trace('PickemModel: User answer: ' + userAnswerId);
				var userAvCntrl:AvatarController = RoomManager.getInstance().userController;
				var answer:TriviaAnswer = currentQuestion.answers[userAnswer];
				var answerImageUrl:String = answer.imageUrl;
				var emoteName:String = answer.imageUrl;
				var defaultEmoteName:String = 'http://' + Environment.getApplicationDomain();
				defaultEmoteName += (userAnswer == 0) ? FallbackImageURL.RED_AAS : FallbackImageURL.BLUE_AAS;

				// Show an emote for the answer.
				if (answerImageUrl.length > 0)
				{
					answerImageUrl = 'http://' + Environment.getApplicationDomain() + answerImageUrl;
					userAvCntrl.emote(answerImageUrl, defaultEmoteName, false, _emoteSize, _emoteSize);
				}
				else
				{
					userAvCntrl.emote(defaultEmoteName, null, false, _emoteSize, _emoteSize);
				}

				// Add user pick to collection.
				if (userPicks.length == 4) potentialPicksComplete = true;
				var newPick:UserPick = new UserPick(int(pickemData.id), questionId, pickemData.getQuestion(questionId).getAnswer(userAnswerId));
				addPick(newPick);
			}

			if (potentialPicksComplete == true && userPicks.length == 5)
			{
				// The user has just complteted their 5th pick.
				dispatchEvent(new PickemPickEvent(PickemPickEvent.FINAL_PICK));

				// If this is the first time that the user has played pickem,
				// Show a pop up for the turbin gifting.
				if (firstTimePlayed == true)
				{
					dispatchEvent(new PickemPickEvent(PickemPickEvent.FIRST_TIME_GAME_COMPLETE));
				}

				// Reset questions passed counter.
				_questionsSinceLastStart = 0;
			}
			else
			{
				// Increment a counter for questions passed.
				_questionsSinceLastStart++;

				if (_questionsSinceLastStart > 4 && userPicks.length > 4)
				{
					// Reset questions passed counter.
					_questionsSinceLastStart = 0;

					// The user has just complteted their 5th pick.
					dispatchEvent(new PickemPickEvent(PickemPickEvent.FINAL_PICK));
				}
			}

			trace('PICKS SINCE START: ' + _questionsSinceLastStart);

			// Pass the answer to the server.
			var answerParams:Object = new Object();
			answerParams.eventId = pickemData.id;
			answerParams.questionId = questionId;
			answerParams.answerId = userAnswerId;
			answerParams.avatarId = userAvatar.id;
			answerParams.isLastAnswer = ((_currentQuestionIndex + 1) < questions.length) ? 0 : 1;
			// Commit the answer.
			RoomManager.getInstance().sendItemAction(userAvatar, 'RwsUserAnswer', answerParams);

			// Dispatch a vote registred event.
			dispatchEvent(new PickemPickEvent(PickemPickEvent.VOTE_REGISTERED));
		}

		public function populateScoreCard():void
		{
			// Use user pick data to populate the pickem score card.
			trace('\n\nPickemModel: Populating pickem score card.');

			if (pickemData == null)
			{
				trace('PickemModel: We don\'t have Pickem data.');
				return;
			}

			// Load pick images.
			var i:int = 0;
			var len:int = userPicks.length;
			var loadOrder:Array = [];
			var triedFallback:Array = [];
			var pickedAnswer:TriviaAnswer;
			for (i; i < len; i++)
			{
				// Create local for user pick.
				var pick:UserPick = userPicks.getAt(i);
				// Validate pick.
				if (pick == null) continue;

				// Create local for picked answer.
				pickedAnswer = pick.pickedAnswer;
				// Validate picked answer.
				if (pickedAnswer == null)
				{
					// Could not determine picked answer.
					trace('PickemModel: Could not determine picked answer.');
					continue;
				}

				var pickId:int = pickedAnswer.id;
				if (pickId < 0)
				{
					// Invalid pickId.
					trace('PickemModel: Invalid pick id: ' + pickId + '.');
					continue;
				}



				// Validate answer image url.
				if (pickedAnswer.imageUrl == null || pickedAnswer.imageUrl == '')
				{
					// Could not determine answer url.
					trace('PickemModel: Answer does not have an image URL.');
					continue;
				}

				var url:String = 'http://' + Environment.getApplicationDomain() + pickedAnswer.imageUrl;
				var request:URLRequest = new URLRequest(url);
				triedFallback[i] = false;
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loadOrder.push(loader.contentLoaderInfo);
				loader.load(request);
			}

			function onComplete(e:Event):void
			{
				// Image load complete.
				// Determine index of the loader.
				var loaderInfo:LoaderInfo = LoaderInfo(e.currentTarget);
				var index:int = loadOrder.indexOf(loaderInfo);
				var pick:UserPick = userPicks.getAt(index);
				var questionIndex:int = pickemData.getQuestionIndex(pick.questionId);
				// Create local for picked answer.
				pickedAnswer = pick.pickedAnswer;
				// Validate picked answer.
				if (pickedAnswer == null)
				{
					// Could not determine picked answer.
					trace('PickemModel: Could not determine picked answer.');
					return;
				}
				var pickId:int = pickedAnswer.id;
				//trace('PickemBackgroundController: Image loaded for pick id: ' + pickId + '.');

				// Remove listeners.
				removeListeners(loaderInfo);

				// Create pick box.
				var pickBox:InGamePickBox = new InGamePickBox();
				//pickBox.pickName = pickedAnswer.text;
				var image:DisplayObject = loaderInfo.content;
				var imageSize:Number = 42;
				var scale:Number = Math.min(imageSize / image.width, imageSize / image.height);
				image.width *= scale;
				image.height *= scale;
				pickBox.image = image;

				// Add pick box to the pick card.
				_pickCard.addPickBoxAt(pickBox, questionIndex);

				// Render pick card.
				renderPickCard();
			}

			function onError(e:IOErrorEvent):void
			{
				// Error loading image.
				// Determine index of the loader.
				var loaderInfo:LoaderInfo = LoaderInfo(e.currentTarget);
				var index:int = loadOrder.indexOf(loaderInfo);
				var pick:UserPick = userPicks.getAt(index);
				trace('PickemModel: Error loading image for answer id: ' + pickId + '.');

				// Remove listeners.
				removeListeners(loaderInfo);

				if (triedFallback[index] != true)
				{
					triedFallback[index] = true;
					// Determine if the answer was likely displayed as answer 1 or answer 2.
					var question:Question = pickemData.getQuestion(pick.questionId);
					var answerIndex:int;
					if (question != null)
					{
						answerIndex = question.answers.indexOf(pick.pickedAnswer);
					}
					else
					{
						answerIndex = 0;
					}
					var url:String = 'http://' + Environment.getApplicationDomain();
					url += (answerIndex == 1) ? FallbackImageURL.BLUE_AAS : FallbackImageURL.RED_AAS;
					var request:URLRequest = new URLRequest(url);
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
					loadOrder[index] = loader.contentLoaderInfo;
					loader.load(request);
				}
				else
				{
					// Can't get an image.
					// Use some local default.
				}
			}

			function removeListeners(loaderInfo:LoaderInfo):void
			{
				loaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}

		private function renderPickCard():void
		{
			_pickCard.x = 925 - _pickCard.width;
			_pickCard.y = 665 - _pickCard.height - 80;
		}

		public function goToRoom(room:String):void
		{
			var userAvatarController:AvatarController = RoomManager.getInstance().userController;
			userAvatarController.goToRoom(room);
		}

		public function playSound(sound:Sound):void
		{
			var channel:SoundChannel;
			if (sound != null) channel = sound.play();
		}

		////////////////////
		// GET/SET METHODS
		////////////////////

		public function get backgroundScreen():Sprite
		{
			return _backgroundScreen;
		}

		public function get screenView():IPickemScreenView
		{
			return _screenView;
		}

		public function get answerImages():Array
		{
			return null;
		}

		public function get animationManager():AnimationManager
		{
			return _animationManager;
		}

		public function get floorTriangle1():FloorTriangle
		{
			return _floorTriangle1;
		}

		public function get floorTriangle2():FloorTriangle
		{
			return _floorTriangle2;
		}

		public function get pickCard():UIPickemInGameScorecard
		{
			return _pickCard;
		}

		public function get userPicks():UserPickCollection
		{
			return _userPicks;
		}

		public function get emoteSize():Number
		{
			return _emoteSize;
		}

		public function get defaultAnswerColor1():uint
		{
			return _defaultAnswerColor1;
		}

		public function get defaultAnswerColor2():uint
		{
			return _defaultAnswerColor2;
		}

		public function get countdownSound():Sound
		{
			return _countdownSound;
		}
		public function set countdownSound(value:Sound):void
		{
			if (value == _countdownSound) return;
			_countdownSound = value;
		}

		public function get pollOverSound():Sound
		{
			return _pollOverSound;
		}
		public function set pollOverSound(value:Sound):void
		{
			if (value == _pollOverSound) return;
			_pollOverSound = value;
		}

		public function get voteRegisteredSound():Sound
		{
			return _voteRegisteredSound;
		}
		public function set voteRegisteredSound(value:Sound):void
		{
			if (value == _voteRegisteredSound) return;
			_voteRegisteredSound = value;
		}

		public function get resultsInSound():Sound
		{
			return _resultsInSound;
		}
		public function set resultsInSound(value:Sound):void
		{
			if (value == _resultsInSound) return;
			_resultsInSound = value;
		}

		public function get backgroundLoopSound():Sound
		{
			return _backgroundLoopSound;
		}
		public function set backgroundLoopSound(value:Sound):void
		{
			if (value == _backgroundLoopSound) return;
			_backgroundLoopSound = value;
		}

		public function get roomContainer():IRoomView
		{
			return null;
		}

		public function get background():Object
		{
			return null;
		}

		public function get backgroundDisplayObject():Sprite
		{
			return null;
		}

		public function get currentQuestionIndex():int
		{
			return _currentQuestionIndex;
		}
		public function set currentQuestionIndex(value:int):void
		{
			if (value == _currentQuestionIndex) return;
			_currentQuestionIndex = value;
			_answerHasBeenProcessed = false;
			_pickCard.questionIndex = _currentQuestionIndex;
		}

		public function get userEntity():RoomEntity
		{
			return RoomManager.getInstance().userController.entity;
		}

		public function get userTileSetId():String
		{
			return null;
		}

		public function get floorTilesEnabled():Boolean
		{
			return _floorTilesEnabled;
		}
		public function set floorTilesEnabled(value:Boolean):void
		{
			if (value == _floorTilesEnabled) return;
			_floorTilesEnabled = value;
			toggleTriviaTiles(_floorTilesEnabled);
		}

		public function get socketClient():SocketClient
		{
			return SocketClient.getInstance();
		}

		public function get countdownSoundUrl():String
		{
			return _countdownSoundUrl;
		}

		public function get voteRegisteredSoundUrl():String
		{
			return _voteRegisteredSoundUrl;
		}

		public function get pollOverSoundUrl():String
		{
			return _pollOverSoundUrl;
		}

		public function get resultsInSoundUrl():String
		{
			return _resultsInSoundUrl;
		}

		public function get backgroundLoopSoundUrl():String
		{
			return _backgroundLoopSoundUrl;
		}

		public function get pickemData():PickemData
		{
			return AASEventManager.getInstance().pickemData;
		}

		public function get userAvatar():Avatar
		{
			return ModelLocator.getInstance().avatar;
		}

		public function get date():Date
		{
			return ModelLocator.getInstance().serverDate;
		}

		public function get tutorialUrl():String
		{
			return _tutorialUrl;
		}

		public function get firstTimePlayed():Boolean
		{
			return _firstTimePlayed;
		}
		public function set firstTimePlayed(value:Boolean):void
		{
			_firstTimePlayed = value;
		}

		public function get gameCompleteImageUrl():String
		{
			return 'swfs/sport_psychic_hat_giveaway.swf';
		}

		/*public function get consoleEventTarget():EventDispatcher
		{
			//return ModelLocator.getInstance().consoleEventTarget;
		}*/

		public function get questionDuration():int
		{
			return PickemEvent.getQuestionDuration();
		}

		public function get answerHasBeenProcessed():Boolean
		{
			return _answerHasBeenProcessed;
		}

		public function get queScreenUrl():String
		{
			return _queScreenUrl;
		}

		public function get queScreen():DisplayObject
		{
			return _queScreen;
		}
		public function set queScreen(value:DisplayObject):void
		{
			_queScreen = value;
		}

		public function get fifthPickResolution():FifthPickResolutionPanel
		{
			if (_fifthPickResolution == null) _fifthPickResolution = new FifthPickResolutionPanel(_backgroundScreen.width, _backgroundScreen.height);
			return _fifthPickResolution;
		}

	}
}
