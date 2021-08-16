package com.sdg.components.controls
{
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.control.AASModuleLoader;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.AvatarEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.leaderboard.Leaderboard;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.manager.LevelManager;
	import com.sdg.messageBoard.MessageBoardDialog;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarLevelStatus;
	import com.sdg.model.GameAssetId;
	import com.sdg.model.ISetAvatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Party;
	import com.sdg.model.Room;
	import com.sdg.model.RoomLayerType;
	import com.sdg.model.SdgItemAssetType;
	import com.sdg.model.Server;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.CurrencyUtil;
	import com.sdg.utils.MainUtil;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.core.Container;

	public class HomeTurfTopUI extends Container implements ISetAvatar
	{
		private const ELECTRO_BUFFER:Boolean = true;
		
		// Buffer Variables
		protected var _turfAccessBuffer:uint = 0;
		protected var _partyModeBuffer:uint = 0;
		protected var _accessTimer:Timer = new Timer(3000,0);
		protected var _partyTimer:Timer = new Timer(3000,0);
		
		// Primary Components
		protected var _turfUI:Sprite;
		protected var _turfUIAbstract:Object;
		protected var _socketClient:SocketClient;
		
		protected var _roomId:String;
		protected var _roomOwnerId:int;
		protected var _ownerAvatar:Avatar;
		protected var _roomAvatarLevel:uint = 0;
		protected var _avatarTurfFlag:Boolean = false;
		protected var _alreadyVoted:Boolean = false;
		
		protected var _playerAv:Avatar = ModelLocator.getInstance().avatar;
		protected var _turfOwner:Boolean = false;
		
		protected var _party:Party;
		protected var _effect:InventoryItem;
		
		public function HomeTurfTopUI()
		{
			super();
			
			// Set Location
			this.x = 0;
			this.y = 0;
			
			// Initialize Socket Client
			_socketClient = SocketClient.getInstance();
			
			// Listen to visible var
			//BindingUtils.bindSetter(visibleUpdate, this, "visible");
			
			// Listen for room data from socket event
			_socketClient.addEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);

			// Build Timers
			
			
			////////////////////////////////////
			// LOAD UI
			////////////////////////////////////
			
			var maxTry:uint = 4;
			var tries:uint = 0;
			
			var url:String = AssetUtil.GetGameAssetUrl(GameAssetId.WORLD, 'TurfControlUI.swf');
			
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onError(e:IOErrorEvent):void
			{
				if (tries++ < maxTry)
				{
					loader.load(request);
				}
				else
				{
					// Remove event listeners.
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				}
			}
				
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Add the console module to the display.
				_turfUI = loader.content as Sprite;
				_turfUIAbstract = _turfUI;
				rawChildren.addChildAt(_turfUI, 0);
					
				// Add console listeners.
				_turfUI.addEventListener('Turf Access',onAccessClick);
				_turfUI.addEventListener('Party Mode',onPartyModeClick);
				_turfUI.addEventListener('Turf Vote',onTurfVoteClick);
				_turfUI.addEventListener('Message',onMessageClick);
				_turfUI.addEventListener('Leaderboard',onLeaderboardClick);
				
				// Load Text Content
				_turfUIAbstract.setTurfLevelTexts("House","Amateur Shack","Rookie Pad","Pro House","Veteran Mansion","AllStar Estate");
				_turfUIAbstract.setRatingTexts("Rate this turf!","Needs Work!","Decent!","Pretty Good!","Nice!","Love It!")
			}
		}
		
		public function updateTurfUI():void
		{
			if (_turfUIAbstract)
			{
				_turfUIAbstract.setTurfLevel(_roomAvatarLevel);
			}
		}
		
		public function setTurfTitle(value:String):void
		{
			if (_turfUIAbstract)
			{
				_turfUIAbstract.setPlayerName(value);
			}
		}
		
		public function setAverage(value:Number):void
		{
			if (_turfUIAbstract)
			{
				_turfUIAbstract.setRatingAverage(value);
			}
		}
		
		public function setValue(value:String):void
		{
			if (_turfUIAbstract)
			{
				_turfUIAbstract.setTurfValue(value);
			}
		}
		
		public function setVotesAmount(value:String):void
		{
			if (_turfUIAbstract)
			{
				_turfUIAbstract.setVoteCount(value);
			}
		}
		
		public function setRating(value:String):void
		{
			if (_turfUIAbstract)
			{
				_turfUIAbstract.setUserRating(Number(value));
			}
		}
		
		public function setPartyStatus(value:int):void
		{
			if(_turfUIAbstract)
			{
				_turfUIAbstract.setPartyMode(value);
			}
		}
		
		//private function visibleUpdate(visible:Boolean):void
		//{}
		
		////////////////////
		// SET ROOM
		////////////////////
		public function setRoom(roomId:String,roomOwnerId:int):void
		{
			// Set RoomId
			_roomId = roomId;
			_roomOwnerId = roomOwnerId;
			
			// Set State
			_ownerAvatar = null;
			_alreadyVoted = false;
			_roomAvatarLevel = 0;
			if (_roomOwnerId == 0)
				_avatarTurfFlag = false;

			// Get the Avatar for the _roomAvatarLevel
			dispatchEvent(new AvatarEvent(_roomOwnerId, this));
			
			// Reset Data whenever we enter a new room
			if (_turfUIAbstract)
			{
				_turfUIAbstract.setAsTurfOwner(false);
				_turfUIAbstract.resetState();
				_turfOwner = false;
			}
			
			if (_party != null)
				_party.reset();
			
			_effect = null;
		}
		
		////////////////
		// SET AVATAR
		////////////////
		
		public function set avatar(value:Avatar):void
		{
			_ownerAvatar = value;
			
			setTurfTitle(_ownerAvatar.name+"\'"+"s");
			
			// Determine Level of Avatar
			var levelStatus:AvatarLevelStatus = LevelManager.GetAvatarLevelStatus(_ownerAvatar);
			if (levelStatus)
			{
				var levelChanged:Boolean = (_roomAvatarLevel != levelStatus.levelIndex);
				_roomAvatarLevel = levelStatus.levelIndex;
				
				updateTurfUI();
			}
			
			if (_playerAv.avatarId == _ownerAvatar.avatarId)
			{
				_turfOwner = true;
				_turfUIAbstract.setAsTurfOwner(true);
				
				if (_playerAv.turfAccess)
					_turfUIAbstract.initTurfAccess(_playerAv.turfAccess);
				
				if (_playerAv.partyMode)
					_turfUIAbstract.initPartyMode(_playerAv.partyMode);
			}

		}
		
		////////////////////////////////////////
		// Turf UI LISTENERS / ELECTRO CALLS
		////////////////////////////////////////
		
		private function onLeaderboardClick(e:Event):void
		{
			if (_playerAv.membershipStatus == MembershipStatus.GUEST)
			{
					MainUtil.showDialog(SaveYourGameDialog);
			}
			else
			{
				AASModuleLoader.openLeaderBoard(Leaderboard.COLLECTOR,1);
			}
		}
		
		private function onTurfVoteClick(e:Event):void
		{
			//Log Vote
			LoggingUtil.sendClickLogging(LoggingUtil.TURF_PANEL_RATE_TURF);
			
			// Send Vote to Server
			_socketClient.sendPluginMessage("avatar_handler", "setTurfRoomRating", { setTurfRoomRating:String(Object(e).value)});
		}
		
		private function onAccessClick(e:Event):void
		{
			if (_playerAv)
				_playerAv.turfAccess = uint(Object(e).value);
			
			// Send Access Level to Server
			submitBufferedTurfAccessCall(uint(Object(e).value));
		}
		
		private function onMessageClick(e:Event):void
		{
			// Log Click
			LoggingUtil.sendClickLogging(LoggingUtil.TURF_UI_TURF_MESSAGE_CLICK);
			
			var messageType:uint = uint(Object(e).value);
			if (messageType == 2)
			{
				//SdgAlertChrome.show("You will be able to send and receive colorful turf-messages shortly. Stay tuned!", "Coming Soon!");
				//alert.addButton("Close", 1);
				if (_playerAv.membershipStatus == MembershipStatus.GUEST)
					MainUtil.showDialog(SaveYourGameDialog);
				else if (Server.getCurrent().chatMode == Server.ULTRA_SAFE_CHAT)
					SdgAlertChrome.show("Turf Messages are not available on Safe Chat servers.", "Sorry");
				else
					MainUtil.showDialog(MessageBoardDialog);
			}
//			else if (messageType == 3)
//			{
//				SdgAlertChrome.show("Other players will now be able to see and join your party from their Friends lists.", "The party is ON!");
//			}
		}
		
		private function onPartyModeClick(e:Event):void
		{
//			var mode:uint = uint(Object(e).value);
//			
//			if (_playerAv)
//				_playerAv.partyMode = mode;
//			
//			// Send Party Mode to Server
//			submitBufferedPartyModeCall(uint(Object(e).value));
			
			var partyOptionsDialog:PartyOptionsDialog = new PartyOptionsDialog(_party);
		}
		
		/////////////////////////////
		// ELECTRO CALLS
		/////////////////////////////
		
		public function getTurfValueFromServer():void
		{
			_socketClient.sendPluginMessage("avatar_handler", "getTurfRoomValue",{ getTurfRoomValue:"0"});
		}
		
		private function submitBufferedTurfAccessCall(mode:uint):void
		{
			// Reset timer every time call is made and start
			_accessTimer.stop();
			_accessTimer.removeEventListener(TimerEvent.TIMER,onTimerCompleted);
			_accessTimer = null;
			_accessTimer = new Timer(3000,0);
			
			// Add Event Listener
			_accessTimer.addEventListener(TimerEvent.TIMER,onTimerCompleted);
			// Start it
			_accessTimer.start();
			
			// Reset Value to be submitted
			_turfAccessBuffer = mode;
			
			function onTimerCompleted():void
			{
				// Remove Event Listeners
				_accessTimer.removeEventListener(TimerEvent.TIMER,onTimerCompleted);
				
				// Log Info
				LoggingUtil.sendClickLogging(LoggingUtil.TURF_UI_TURF_ACCESS_CHANGE);
				
				// Make socket call
				_socketClient.sendPluginMessage("avatar_handler", "setLockMode", { lockMode:_turfAccessBuffer});
			}	
		}
	
		private function submitBufferedPartyModeCall(mode:uint):void
		{
			// Reset timer every time call is made and start
			_partyTimer.stop();
			_partyTimer.removeEventListener(TimerEvent.TIMER,onTimerCompleted);
			_partyTimer = null;
			_partyTimer = new Timer(3000,0);
			
			// Add Event Listener
			_partyTimer.addEventListener(TimerEvent.TIMER,onTimerCompleted);
			// Start it
			_partyTimer.start();
			
			// Reset Value to be submitted
			_partyModeBuffer = mode;
			
			function onTimerCompleted():void
			{
				// Remove Event Listeners
				_partyTimer.removeEventListener(TimerEvent.TIMER,onTimerCompleted);
				
				// Log Info
				LoggingUtil.sendClickLogging(LoggingUtil.TURF_UI_PARTY_MODE_CHANGE);
				
				// Make socket call
				if (_partyModeBuffer)
					_socketClient.sendPluginMessage("avatar_handler", "addParty", {});
				else
					_socketClient.sendPluginMessage("avatar_handler", "removeParty", {});
			}	
		}
		
		private function onPartyOnChanged(event:Event):void
		{
			if (_party.partyOn)
			{
				
				changeEffect();
				changeSound();
			}
			else
			{
				removeEffect();
				resetSound();
			}
			
			if (_turfUIAbstract)
				_turfUIAbstract.setPartyMode(_party.partyOn);
		}
		
		private function onThemeChanged(event:Event):void
		{
			
		}
		
		private function onEffectIdChanged(event:Event):void
		{
			changeEffect();
		}
		
		private function onSoundIdChanged(event:Event):void
		{
			changeSound();
		}
		
		private function changeSound():void
		{
			var room:Room = RoomManager.getInstance().currentRoom;
			room.clientBackgroundMusicSoundId = _party.soundId == 0 ? "" : _party.soundId.toString();
			RoomManager.getInstance().roomContext.roomView.getRoomController().setupRoomSound(room);
		}
		
		private function resetSound():void
		{
			var room:Room = RoomManager.getInstance().currentRoom;
			room.clientBackgroundMusicSoundId = null;
			RoomManager.getInstance().roomContext.roomView.getRoomController().setupRoomSound(room);
		}
		
		private function removeEffect():void
		{
			if (_effect == null) return;
			
			RoomManager.getInstance().currentRoom.removeClientItem(_effect);
			_effect = null;
		}
		
		private function changeEffect():void
		{
			removeEffect();
			
			if (_party.effectId == 0) return;
			
			_effect = new InventoryItem();
			_effect.itemId = _party.effectId;
			_effect.itemTypeId = 12;
			_effect.layerType = RoomLayerType.FOREGROUND;
			_effect.assetType = SdgItemAssetType.SWF;
			_effect.spriteTemplateId = 1;
			_effect.x = 0;
			_effect.y = 0;
			RoomManager.getInstance().currentRoom.addClientItem(_effect);
		}
		
		/////////////////////////////////
		// ELECTRO LISTENER
		/////////////////////////////////
		private function onPluginEvent(e:SocketEvent):void
		{
			var params:Object = e.params;
			var action:String = params.action as String;
			
			if (action == "partyState")
			{
				trace(params.partyState);
				var partyState:XML = new XML(params.partyState);
				
				if (_party == null)
				{
					_party = new Party();
					_party.addEventListener("partyOnChanged", onPartyOnChanged, false, 0, true);
					_party.addEventListener("themeChanged", onThemeChanged, false, 0, true);
					_party.addEventListener("effectIdChanged", onEffectIdChanged, false, 0, true);
					_party.addEventListener("soundIdChanged", onSoundIdChanged, false, 0, true);
				}
				
				_party.setPartyOptions(partyState.ps == 1, partyState.pn, partyState.efId, partyState.mId);
			}

			else if (action == 'turfRating')
			{
				trace("TURF RATING PLUGIN EVENT RECEIVED");

				// Parse Values
				var paramString:String = params.payload as String;
				var paramArray:Array = paramString.split(";",10);
				
				// Parse Data and then utilize setters
				var rawTurfValue:String = paramArray.pop() as String;
				var userVote:String = paramArray.pop() as String;
				var numVotes:String = paramArray.pop() as String;
				var roomRating:String = paramArray.pop() as String;
				
				if (userVote != "-1")
				{
					setRating(userVote);
				}
				
				setVotesAmount(numVotes);
				
				setAverage(Number(roomRating));
				
				if (rawTurfValue != "-1")
				{
					setValue(CurrencyUtil.intFormat(parseInt(rawTurfValue)));
				}
				else
				{
					setValue("0");
				}
				
			}
			//else if (action == 'turfValue')
			//{
				/*
				trace("TURF VALUE PLUGIN EVENT RECEIVED");
				var paramString:String = params.payload as String;
				
				// Parse Data and then utilize setters
				var rawTurfValue:String = paramString;

				if (this._turfValue)
				{
					if (rawTurfValue != "-1")
					{
						this._turfValue.text = CurrencyUtil.intFormat(parseInt(rawTurfValue));
					}
					else
					{
						this._turfValue.text = "N/A";
					}
				}
				*/
			//}
//			else if (action == SocketRoomEvent.CONFIG)
//			{
//				if (e.params.hasOwnProperty("p"))
//				{
//					setPartyStatus(1);
//				}
//				else
//				{
//					setPartyStatus(0);
//				}
//			}
		}
		
	}
}