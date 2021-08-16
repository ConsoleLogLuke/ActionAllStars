package com.sdg.components.games.carrotDefense.controller
{
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.games.carrotDefense.BunnyConsts;
	import com.sdg.components.games.carrotDefense.model.*;
	import com.sdg.components.games.carrotDefense.view.*;
	import com.sdg.control.CairngormEventController;
	import com.sdg.control.IDynamicController;
	import com.sdg.control.room.RoomManager;
	import com.sdg.display.AvatarSprite;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.display.RoomItemSprite;
	import com.sdg.display.render.RenderData;
	import com.sdg.display.render.RenderObject;
	import com.sdg.events.RoomItemEvent;
	import com.sdg.events.SocketRoomEvent;
	import com.sdg.game.counter.GamePlayCounter;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.RoomLayerType;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.sim.entity.TileMapEntity;
	import com.sdg.sim.map.IOccupancyTile;
	import com.sdg.sim.map.TileMap;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.IRoomView;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	/**
	 * 
	 * Proof of concept for in world games
	 * 
	 * @author molly.jameson
	 */
	public class CarrotDefenseController extends CairngormEventController implements IDynamicController
	{
		private var m_HasReceivedGameState:Boolean;
		private const STATE_NOT_STARTED:String = "NOT_YET_STARTED";
		private const STATE_IN_PROGRESS:String = "IN_PROGRESS";
		private const STATE_ENDED:String = "ENDED";
		
		private var _roomContainer:IRoomView;
		
		private var SnowmanClass:Class;
		private var BunnyClass:Class;
		private var CarrotClass:Class;
		
		// This is a server state for real and shouldn't be tracked by the client.
		private var m_LocalTurret:Turret;
		
		private var m_Snowballs:Array;
		private var m_CarrotList:Array;
		private var m_TurretList:Array;
		private var m_BunnyList:Array;
		
		private var m_GameStatus:String;

		 private var m_LastFrameTime:int;
		 private var m_ServerTime:Number;
		 private var m_RoomDestroyed:Boolean;
		 
		 private var m_LastClickTime:Number;
		 private var m_HUD:BunnyHUD;
		 private var m_Background:Sprite;
		
		public function CarrotDefenseController(roomContainer:IRoomView, data:Object)
		{
			super();
			_roomContainer = roomContainer;

			 SnowmanClass = data.SnowManClass;
			 BunnyClass = data.BunnyClass;
			 CarrotClass = data.CarrotClass;
			 Snowball.MC_SNOWBALL = data.snowballAnim;
			 Snowball.SFX_THROW = data.SfxSnowballWhoosh;
			 Bunny.MC_POOF = data.poofAnim;
			 Bunny.MC_SPLAT = data.splatAnim;
			 Bunny.MC_LIFEBAR = data.bunnyLife;
			 Turret.MC_THROW_RANGE = data.throwingRangeClass;
			 Carrot.SFX_SHOWCARROT = data.SfxCarrot;
			 Bunny.SFX_LOCALKILL = data.SfxBunnyPoof;
			 Bunny.SFX_SNOWBALLHIT = data.SfxSnowballHit;
			 
			 m_Snowballs = new Array();
			 m_BunnyList = new Array();
			 m_CarrotList = new Array();
			 m_TurretList = new Array();
			 m_LocalTurret = null;
			 
			 m_HasReceivedGameState = false;
			 m_GameStatus = STATE_NOT_STARTED;
			 
			 m_Background = _roomContainer.background;
			 m_HUD = new BunnyHUD(m_Background);
			 
			 RoomManager.getInstance().socketMethods.addEventListener("bunnyGameState",onGameStateMessage);
			 RoomManager.getInstance().socketMethods.addEventListener("bunnyGameStarted",onGameStartedMessage);
			 
			 //Request the 
			 var params:Object = new Object();
			params.roomId = RoomManager.getInstance().currentRoomId;
			SocketClient.getInstance().sendPluginMessage("room_enumeration", "bunnyGameState",params);

			// These are only here so the compiler knows to include these classes
			// without having to do an include all
			new BunnyRoomJoinDialog();
			new BunnyStore();

			m_LastClickTime = flash.utils.getTimer();	
			
			var snowmanBtn:SimpleButton = new data.placeSnowmanBtn();
			var avSprite:AvatarSprite = RoomManager.getInstance().userController.display as AvatarSprite;
			var rect:Rectangle = avSprite.getImageRect();
			var minHeight:int = rect.height + snowmanBtn.height;
			m_HUD.init(_roomContainer.uiLayer,snowmanBtn);
			m_HUD.placeSnowmanButton.addEventListener(MouseEvent.CLICK,onPlaceTurret,false,0,true);
			
			m_RoomDestroyed = false;
			
			m_HUD.starExitVisibility(true);
		}

		public function init():void
		{
			//Per Edvard unleash a pet associated with the avatar
			var myPetID:int = ModelLocator.getInstance().avatar.leashedPetInventoryId;
			if(myPetID != 0)
			{
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "unleash", { petId:(myPetID as int) });
				SdgAlertChrome.show("Your pet can't play with you and is waiting for you in your turf.","Time Out");
			}
		}
		
		public function destroy():void
		{
			var sp:Sprite = ModelLocator.getInstance().avatar.display as Sprite;
			for(var i:int = 0; i < sp.numChildren; ++i)
			{
				sp.getChildAt(i).visible = true;
			}
			var otherDisplay:IRoomItemDisplay = RoomManager.getInstance().userController.display;
			sp = otherDisplay as Sprite;
			for(i = 0; i < sp.numChildren; ++i)
			{
				sp.getChildAt(i).visible = true;
			}
			// in case your avatar has already left the room. Special case for that.
			var myAvDisplay:AvatarSprite = otherDisplay as AvatarSprite;
			myAvDisplay.mouseEnabled = true;
			myAvDisplay.mouseChildren = true;
			
			m_HUD.placeSnowmanButton.removeEventListener(MouseEvent.CLICK,onPlaceTurret);
			
			RoomManager.getInstance().socketMethods.removeEventListener("bunnyGameState",onGameStateMessage);
			RoomManager.getInstance().socketMethods.removeEventListener("bunnyGameStarted",onGameStartedMessage);
			RoomManager.getInstance().socketMethods.removeEventListener("bunnyGameBatch",onGameNewWaveMessage);
			RoomManager.getInstance().socketMethods.removeEventListener("bunnyGameEnded",onGameEndedMessage);
			
			RoomManager.getInstance().socketMethods.removeEventListener("towerAdded",onTowerAdded);
			RoomManager.getInstance().socketMethods.removeEventListener("towerRemoved",onTowerRemoved);
			RoomManager.getInstance().socketMethods.removeEventListener("bunnyShot",onBunnyShot);
			RoomManager.getInstance().socketMethods.removeEventListener("bunnyEscaped",onBunnyEscaped);
			RoomManager.getInstance().socketMethods.removeEventListener("userExit",onUserExit);
			RoomManager.getInstance().socketMethods.removeEventListener(SocketRoomEvent.JOIN,onUserJoined);

			RoomManager.getInstance().userController.removeEventListener(RoomItemEvent.MOVE,onAvatarMoved);
			
			m_Background.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			m_Background.removeEventListener(MouseEvent.CLICK,onClickBG);
			m_Background.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			
			RoomManager.getInstance().userController.entity.removeEventListener(TileMapEntity.PATH_FOLLOW_COMPLETE,onStopWalking);

			RoomManager.getInstance().socketMethods.removeEventListener(SocketRoomEvent.AVATAR_ACTION,onStartWalking);
			
			m_HUD.destroy();
			m_RoomDestroyed = true;
			
			
		}

		private function initFirstGame():void
		{
			m_HasReceivedGameState = true;
			m_HUD.placeSnowmanButton.visible = true;
			
			placeSnowmanBtn(RoomManager.getInstance().userController.display);

			//This is null by the time remove is called.
			//Just use weak references to clean this up.
			m_Background.addEventListener(Event.ENTER_FRAME,onEnterFrame,false,0,true);
			m_LastFrameTime = flash.utils.getTimer();
			
			m_Background.addEventListener(MouseEvent.CLICK,onClickBG,false,0,true);
			m_Background.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove,false,0,true);

			RoomManager.getInstance().socketMethods.addEventListener("bunnyGameBatch",onGameNewWaveMessage);
			RoomManager.getInstance().socketMethods.addEventListener("bunnyGameEnded",onGameEndedMessage);
			
			//Need to send a request first
			RoomManager.getInstance().socketMethods.addEventListener("towerAdded",onTowerAdded);
			RoomManager.getInstance().socketMethods.addEventListener("towerRemoved",onTowerRemoved);
			RoomManager.getInstance().socketMethods.addEventListener("bunnyShot",onBunnyShot);
			RoomManager.getInstance().socketMethods.addEventListener("bunnyEscaped",onBunnyEscaped);
			RoomManager.getInstance().socketMethods.addEventListener("userExit",onUserExit);
			RoomManager.getInstance().socketMethods.addEventListener(SocketRoomEvent.JOIN,onUserJoined);
			RoomManager.getInstance().userController.addEventListener(RoomItemEvent.MOVE,onAvatarMoved);
			
			RoomManager.getInstance().userController.entity.addEventListener(TileMapEntity.PATH_FOLLOW_COMPLETE,onStopWalking);

			RoomManager.getInstance().socketMethods.addEventListener(SocketRoomEvent.AVATAR_ACTION,onStartWalking);
		}
		
		private var m_IsWalking:Boolean = false;
		private function onStopWalking(ev:Event):void
		{
			m_IsWalking = false;
		}
		private function onStartWalking(ev:Event):void
		{
			var obj:Object = ev as Object;
			var actionXML:XML = new XML(obj.params.avatarAction);
			
			var avID:int = actionXML.id;
			var avAction:String = actionXML.action;
			if(avAction == "walk" && 
				avID == ModelLocator.getInstance().avatar.id)
			{
				m_IsWalking = true;
			}
		}
		
		private function onGameStartedMessage(ev:Event):void
		{
			// Reset all vars if they are there before.
			m_GameStatus = STATE_IN_PROGRESS;
			
			if(m_EndGameDialog != null)
			{
				m_EndGameDialog.close();
				m_EndGameDialog = null;	
			}
			m_HUD.stopSnowmanTimer();
			
			var obj:Object = ev as Object;
			var params:Object = obj.params;
			var xml:XML = new XML(params.bunnyGameStarted);
			
			m_ServerTime = params.bunnyGameStarted;
			var debugDate:Date = new Date();
			debugDate.setTime(m_ServerTime);
			
			m_HUD.resetTeamLife();
			
			if(!m_HasReceivedGameState)
			{
				initFirstGame();
			}	
			//trace(">>>>>>>>> GAME STARTED:" + xml.toXMLString() + " avID: " + ModelLocator.getInstance().avatar.avatarId + " in room: " + RoomManager.getInstance().currentRoomId);
		}
		//move this elsewhere
		private function syncGameState(stateXML:XML):void
		{
			const KILLS_INDEX:int = 5;
			const CARROTS_INDEX:int = 6;
			// the turret list for now with scores and such
			var allTowers:Array = stateXML.towers.split(";");
			//this should just blow away and reinit all data we have.
			//This is just a scores test until I write the join in progress.
			for(var i:int = 0; i < allTowers.length - 1; ++i)
			{
				var currTowerInfo:Array = allTowers[i].split(",");
				for(var j:int = 0; j < m_TurretList.length; ++j)
				{
					var turret:Turret = m_TurretList[j];
					if(turret != null && turret.avatarId == currTowerInfo[0])
					{
						//trace(j + "Set info for turret: " + turret.avatarId + " - " + currTowerInfo);
						turret.carrots = currTowerInfo[CARROTS_INDEX];
						turret.kills = currTowerInfo[KILLS_INDEX];
					}
				}
			}
		}
		
		private function onGameEndedMessage(ev:Event):void
		{
			var obj:Object = ev as Object;
			var xml:XML = new XML(obj.params.bunnyGameEnded);
			
			// Start Debug
			
			trace("Ended: " + xml.toXMLString());
			//END DEBUG
			syncGameState(xml);
			
			var gameState:String = xml.gameStatus;
			if(gameState.indexOf("WIN") >= 0)
			{
				m_HUD.playWinAnimation(makeEndScoreVisible);
			}
			else if(gameState.indexOf("LOSS") >= 0)
			{
				m_HUD.playLoseAnimation(makeEndScoreVisible);
			}
			showEndScoreScreen();
			
			m_GameStatus = gameState;
			
			// FORCE kill all the old bunnies, carrots, etc.
			// Not efficent I know.
			for(var j:int = 0; j < m_BunnyList.length; ++j)
			{
				var b:Bunny = m_BunnyList[j];
				b.destroy();
				removeToLayer(b);
			}
			m_BunnyList = new Array();
			for(j = 0; j < m_CarrotList.length; ++j)
			{
				var c:Carrot = m_CarrotList[j];
				c.destroy();
				removeToLayer(c,RoomLayerType.FOREGROUND);
			}
			m_CarrotList = new Array();
			
			var params:Object = new Object();
			params.roomId = RoomManager.getInstance().currentRoomId;
			SocketClient.getInstance().sendPluginMessage("room_enumeration", "removeTower",params);
		}
		private function onGameStateMessage(ev:Event):void
		{
			var firstTime:Boolean = false;
			if(!m_HasReceivedGameState)
			{
				initFirstGame();
				firstTime = true;
			}
			
			// Sync towers
			// Clear the towers and readd them.
			// Sync Bunnies
			
			m_HUD.resetGame();
			
			//trace("GOT BUNNY GAMESTATEEVENT: " + ev.type);
			var obj:Object = ev as Object;
			var params:Object = obj.params;
			
			var xml:XML = new XML(params.bunnyGameState);
			var realStartTime:Number = xml.startTime;
			var debugDate:Date = new Date();
			debugDate.setTime(realStartTime);
			//trace("Start Time with bunnyGameState msg :" +  realStartTime + " aka "  + debugDate.toTimeString());
			// Should be current time???
			m_ServerTime = params.currentTime;
			
			m_HUD.resetTeamLife(xml.gameHitPoint);
			
			var towers:Array = xml.towers.split(";");
			for(var i:int = 0; i < towers.length - 1; ++i)
			{
				var single:Array = towers[i].split(",");
				addTurret(single);
			}
			if(xml.gameStatus != STATE_IN_PROGRESS)
			{
				m_HUD.startSnowmanTimer(!firstTime);
			}
			else
			{
				m_HUD.stopSnowmanTimer();
				m_HUD.newGameStarted();
			}
			
			if(xml.gameStatus == STATE_IN_PROGRESS)
			{
				//trace(">>>>>>>>> Join In progress:" + xml.toXMLString()  + " avID: " + ModelLocator.getInstance().avatar.avatarId + " in room: " + RoomManager.getInstance().currentRoomId); 
				//IGNORE JOIN IN PROGRESS FOR NOW!
				var bunnyBatches:XMLList = xml.bunnyBatches.bb;
				for(var j:int = 0; j < bunnyBatches.length(); ++j)
				{
					var bb:XML = bunnyBatches[j];
					processBunnyWave(bb.valueOf());
				}
			}
			
			m_GameStatus = xml.gameStatus;
		}
		private function onGameNewWaveMessage(ev:Event):void
		{
			var obj:Object = ev as Object;
			var params:Object = obj.params;
			processBunnyWave(params["bunnyGameBatch"]);
		}
		private function processBunnyWave(batch:String):void
		{
			//trace(">>>>>>>>> Batch:" + batch + " avID: " + ModelLocator.getInstance().avatar.avatarId); 
			var arr:Array = batch.split(";");
			// Sample: 5;1292292796937;15,8068,3;16,1397,3;17,4022,3;
			// Wave Number; UnixTime; BunnyID, time after previous, HP; BunnyID, time after Prev, HP;
			//trace("Batch Num: " + arr[0]);
			//trace("Unix start time of batch: " + arr[1] + " flash time: " + flash.utils.getTimer());
			var date:Date = new Date();
			var startTime:Number = parseInt( arr[1] );
			date.setTime(startTime);
			
			var estimateServerDate:Date = new Date();
			estimateServerDate.setTime(m_ServerTime);
			//trace("estimateServerDate now: " + estimateServerDate.toTimeString());
			
			for(var i:int = 2; i < arr.length - 1; ++i)
			{
				//trace("BUNNY INFO:" + arr[i]);
				var singleBunny:Array = arr[i].split(",");
				//spawn next bunny
				var timeOffset:int = parseInt( singleBunny[1] );
				var spawnTime:Number = startTime;
				// First one spans immediately
				spawnTime += timeOffset;
				// next one needs to start after the previous one, not the first one.
				startTime += timeOffset;
				var debugDate:Date = new Date();
				date.setTime(spawnTime);
				//trace("Bunny Spawn Time In Theory: " + date.toTimeString());
				var bunnyNum:int = singleBunny[0];
				if(bunnyNum >= 0)
				{
				 	var b:Bunny = new Bunny(BunnyClass,singleBunny[0],spawnTime,singleBunny[2]);
				 	m_BunnyList.push(b);
				 	addToLayer(b);
				 	
				 	if(i == 2)
				 	{
				 		b.startOfWave = true;
				 	}
			 	}
			 	else
			 	{
			 		trace("ERROR: this shouldn't ever happen.");
			 	}
			}
		}
		
		public function addToLayer(model:BunnyDefenseModelBase,layerID:uint = RoomLayerType.FOREGROUND):void
		{
			_roomContainer.getRenderLayer(layerID).addItem(model.getRenderObject());
		}
		
		public function removeToLayer(model:BunnyDefenseModelBase,layerID:uint = RoomLayerType.FOREGROUND):void
		{
			_roomContainer.getRenderLayer(layerID).removeItem(model.getRenderObject());
		}
		
		private function onTowerAdded(ev:Event):void
		{
			//trace("TOWER ADDED EVENT");
			var obj:Object = ev as Object;
			var params:Object = obj.params;
			
			var str:String = params.towerAdded;
			var arr:Array = str.split(",");
			addTurret(arr);
		}
		
		private function addTurret(arr:Array):void
		{
			// Removing by avatarID from Room
			var av:Avatar = RoomManager.getInstance().currentRoom.getAvatarById(arr[0]);

			//So the chat bubble is not invisible, make the children invisible
			var sp:Sprite = av.display as Sprite;
			for(var i:int = 0; i < sp.numChildren; ++i)
			{
				sp.getChildAt(i).visible = false;
			}
			var avSprite:AvatarSprite = av.display as AvatarSprite;
			var rect:Rectangle = avSprite.getImageRect();
			avSprite.mouseChildren = false;
			avSprite.mouseEnabled = false;
			
			
			// Have a special case for the local avatar
			var otherDisplay:IRoomItemDisplay = RoomManager.getInstance().userController.display;
			if(av.avatarId ==  ModelLocator.getInstance().avatar.avatarId)
			{
				avSprite = otherDisplay as AvatarSprite;
				rect = avSprite.getImageRect();
				sp = otherDisplay as Sprite;
				for(i = 0; i < sp.numChildren; ++i)
				{
					sp.getChildAt(i).visible = false;
				}
				
				// Ignore clicks from other avatars in room.
				
				var allAvatars:Array = RoomManager.getInstance().currentRoom.getAllAvatars();
				for(i = 0; i < allAvatars.length; ++i)
				{
					var someAvatar:Avatar = allAvatars[i];
					var avDisplay:AvatarSprite = someAvatar.display as AvatarSprite;
					avDisplay.mouseEnabled = false;
					avDisplay.mouseChildren = false;
				}
			}
			
			for(var j:int = 0; j < m_TurretList.length; ++j)
			{
				var turret:Turret = m_TurretList[j];
				if(turret.avatarId == av.avatarId)
				{
					//trace("TURRET ALREADY ADDED");
					return;
				}
			}
			var xTile:int = arr[1];
			var yTile:int = arr[2];
			
			var displayPt:Point = _roomContainer.getRenderLayer(RoomLayerType.FLOOR).localToGlobal(xTile,yTile);
			// kinda fudge the numbers due to throw range changes
			//displayPt.x -= rect.width * 1.9;
			//displayPt.y -= rect.height * 1.2;
			
			var newTurret:Turret = new Turret(SnowmanClass,arr[0],displayPt.x,displayPt.y,
												av.avatarId == ModelLocator.getInstance().avatar.avatarId,av.name);
			
			addToLayer(newTurret);
			m_TurretList.push(newTurret);
			if(newTurret.isLocal)
			{
				m_HUD.placeSnowmanButton.visible = false;
				m_LocalTurret = newTurret;
				
				//This is also done server side
				GamePlayCounter.incrementGamePlay(106);
			}
		}
		
		private function onUserExit(ev:Event):void
		{
			var obj:Object = ev as Object;
			var params:Object = obj.params;
			var xml:XML = new XML(params.userRemoved);
			//<SDGResponse  status="1"><avatar><aId>4672</aId><uId>4672</uId><n>User4672</n><xp>3530</xp><t>6150</t><l>1</l><g>2</g><cm>1</cm><sId>1</sId><appr>0</appr><lp>50003640~6262</lp><v>5</v><pr>private_4672_1</pr><tv>82500</tv><stId>1</stId><lId>500</lId><x>14</x><cl>2649,1;5227,2;5263,3;3520,5;2719,6;2685,7;3507,8;</cl><y>19</y><ms>2</ms><asId>201</asId></avatar></SDGResponse>
			var aID:int = xml.avatar.aId;
			for(var i:int = 0; i < m_TurretList.length; ++i)
			{
				var turret:Turret = m_TurretList[i];
				if(turret.avatarId == aID)
				{
					removeTurret(turret,i);
					break;
				}
			}
		}
		private function onUserJoined(ev:Event):void
		{
			if(m_LocalTurret != null)
			{
				// hide the clicks on this latest avatar that joined if we're
				// a snowman now. Dont just get clicks off a layer on top because then tooltips stop working.
				var obj:Object = ev as Object;
				var params:Object = obj.params;
				var xml:XML = new XML(params.userAdded);
				var aID:int = xml.avatar.aId;
				var av:Avatar = RoomManager.getInstance().currentRoom.getAvatarById(aID);
				var avDisplay:AvatarSprite = av.display as AvatarSprite;
				avDisplay.mouseEnabled = false;
				avDisplay.mouseChildren = false;
			}
		}
		
		private function removeTurret(turret:Turret,removeIndex:int):void
		{
			var av:Avatar = RoomManager.getInstance().currentRoom.getAvatarById(turret.avatarId);
			if(av != null)
			{
				var sp:Sprite = av.display as Sprite;
				for(var j:int = 0; j < sp.numChildren; ++j)
				{
					sp.getChildAt(j).visible = true;
				}
				var otherDisplay:IRoomItemDisplay = RoomManager.getInstance().userController.display;
				if(av.avatarId ==  ModelLocator.getInstance().avatar.avatarId)
				{
					// in case your avatar has already left the room. Special case for that.
					var myAvDisplay:AvatarSprite = otherDisplay as AvatarSprite;
					for(var k:int = 0; k < sp.numChildren; ++k)
					{
						myAvDisplay.getChildAt(k).visible = true;
					}
					myAvDisplay.mouseEnabled = true;
					myAvDisplay.mouseChildren = true;
					
					var allAvatars:Array = RoomManager.getInstance().currentRoom.getAllAvatars();
					for(var i:int = 0; i < allAvatars.length; ++i)
					{
						var someAvatar:Avatar = allAvatars[i];
						var avDisplay:AvatarSprite = someAvatar.display as AvatarSprite;
						avDisplay.mouseEnabled = true;
						avDisplay.mouseChildren = true;
					}
				}
			}
			
			
			turret.destroy();
			removeToLayer(turret);
			m_TurretList.splice(removeIndex,1);
			if(turret.isLocal)
			{
				m_HUD.placeSnowmanButton.visible = true;
				m_LocalTurret = null;
				//Resets the room back to normal.
				 _roomContainer.getRoomController().useDefaultUIController();
				 
				 m_HUD.starExitVisibility(true);
				// _roomContainer.getRoomController().setCustomUIController(new CarrotDefenseUIController());
			}
		}
		
		private function onTowerRemoved(ev:Event):void
		{
			//trace("TOWER REMOVED EVENT");
			var obj:Object = ev as Object;
			var params:Object = obj.params;
			
			var str:String = params.towerRemoved;
			var arr:Array = str.split(",");
			
			//trace(str + "TOWER REMOVED");
			
			for(var i:int = 0; i < m_TurretList.length; ++i)
			{
				var turret:Turret = m_TurretList[i];
				if(turret.avatarId == arr[0])
				{
					removeTurret(turret,i);
					break;
				}
			}
		}
		
		private function onBunnyShot(ev:Event):void
		{
			//trace("BUNNY SHOT");
			var obj:Object = ev as Object;
			var params:Object = obj.params;
			var str:String = params.bunnyShot;
			var arr:Array = str.split(",");
			var disposition:int = parseInt(arr[3]);
			
			for(var i:int = 0; i < m_TurretList.length; ++i)
			{
				var turret:Turret = m_TurretList[i];
				if(turret.avatarId == arr[0])
				{
					if(turret.isLocal)
					{
						m_HUD.DEBUGShootGotBack();
					}
					var startPt:Point = turret.centerPt;
					var angleAsDeg:Number = parseInt(arr[1]);
					var angleAsRads:Number = angleAsDeg * Math.PI/180.0;
					var vec:Point = BunnyConsts.angleToVec(angleAsRads);
					var len:Number = vec.length;
					
					turret.updateDirection(angleAsDeg);
					turret.startThrowAnimation();
					
					vec.x = vec.x/len;
					vec.y = vec.y/len;
					//normalize than multipley by the range
					vec.x = vec.x * BunnyConsts.THROW_RANGE;
					vec.y = vec.y * BunnyConsts.THROW_RANGE;
					vec.x = vec.x + startPt.x;
					vec.y = vec.y + startPt.y;
					
					var s:Snowball = new Snowball();
					s.startThrow(startPt.x,startPt.y,vec.x,vec.y,Snowball.SNOWBALL_SPEED,snowballAnimDone);
					addToLayer(s,RoomLayerType.FOREGROUND);
					m_Snowballs.push(s);

					var bunnyIDIfHit:int = arr[2];
					if(bunnyIDIfHit != 0)
					{
						turret.hits = turret.hits + 1;
						for(var j:int = 0; j < m_BunnyList.length; ++j)
						{
							var b:Bunny = m_BunnyList[j];
							if(b.bunnyID == bunnyIDIfHit)
							{
								b.lastHitLocal = turret.isLocal;
								b.HP = b.HP - 1;
								//trace("BUNNY HIT!" + bunnyIDIfHit + " hp: " + b.HP);
								if(b.HP <= 0)
								{
									// Bunny is now removed later after animation
									//removeBunny(b,false);
									
									if(turret.isLocal && 
										!b.isDead &&
										disposition == BunnyConsts.BUNNY_KILL)
									{
										b.playLocalKillSound();
										
										//trace(" CARROT DROP!!!");
										m_HUD.incrementBunnyScore(1);
										if(Math.random() < BunnyConsts.CARROT_DROP_RATE)
										{
											spawnCarrot(b.display.x,b.display.y);
										}
									}
									b.isDead = true;
								}
								// Just so the list doens't get messed up
								return;
							}
						}
					}
				}
			}
		}

		//private var DEBUGSpriteBunny:Sprite;
		//private var DEBUGSpriteSnowman:Sprite;
		private function onEnterFrame(ev:Event):void
		{
			//SHOULDN"T BE DOING THIS EVERY FRAME
			onSpawnNextBunny();
			
			//SOLUTION?
			//why not do a fast collision bounding box check between the bunnies and the snowmen.
			// if they collide and snowman is on top and bunny is behind then swap their places.
			// Still faster than the every frame check that SimEngine does
			
			/*if(DEBUGSpriteBunny == null)
			{
				DEBUGSpriteBunny = new Sprite();
				DEBUGSpriteBunny.graphics.beginFill(0);
				DEBUGSpriteBunny.graphics.drawRect(0,0,20,20);
				DEBUGSpriteBunny.graphics.endFill();
			}
			if(DEBUGSpriteSnowman == null)
			{
				DEBUGSpriteSnowman = new Sprite();
				DEBUGSpriteSnowman.graphics.beginFill(0xFF0000);
				DEBUGSpriteSnowman.graphics.drawRect(0,0,20,20);
				DEBUGSpriteSnowman.graphics.endFill();
			}*/
			
			for(var j:int = 0; j < m_BunnyList.length; ++j)
			{
				var b:Bunny = m_BunnyList[j];
				if(b.getHasSpawned())
				{
					for(var i:int = 0; i < m_TurretList.length; ++i)
					{
						var turret:Turret = m_TurretList[i];
						if(turret.display.hitTestObject(b.display))
						{
							var turretDepth:int = turret.display.parent.getChildIndex(turret.display);
							var bunnyDepth:int = b.display.parent.getChildIndex(b.display);
							
							var turretY:int = turret.display.y// + turret.centerPt.y;
							var bunnyY:int = b.display.y - b.display.height/2;
							
							/*turret.display.parent.addChild(DEBUGSpriteSnowman);
							DEBUGSpriteSnowman.y = turretY;
							DEBUGSpriteSnowman.x = turret.centerPt.x;
							
							turret.display.parent.addChild(DEBUGSpriteBunny);
							DEBUGSpriteBunny.y = bunnyY;
							DEBUGSpriteBunny.x = b.display.x;*/
							// higher on the display list is more on top
							// lower on y means should be below
							
							// if turret is lower on screen than bunny.
							// and the turret sprite is on top of the bunny sprite
							// swap them
							if(turretY > bunnyY && 
								turretDepth < bunnyDepth)
							{
								turret.display.parent.setChildIndex(turret.display,bunnyDepth);
								b.display.parent.setChildIndex(b.display,turretDepth);
							}
							// if turret is higher on the screen y
							// and the turret sprite is beheath the bunny
							else if(turretY < bunnyY && 
								turretDepth > bunnyDepth)
							{
								turret.display.parent.setChildIndex(turret.display,bunnyDepth);
								b.display.parent.setChildIndex(b.display,turretDepth);			
							}
						}
					}
				}
			}
		}
		
		private function onAvatarMoved(ev:RoomItemEvent):void
		{
			placeSnowmanBtn(ev.roomItemController.display);		
		}
		
		private function onMouseMove(ev:MouseEvent):void
		{
			if(m_LocalTurret != null)
			{
				var myTurret:Turret = m_LocalTurret;
				var startPt:Point = myTurret.centerPt;
				var endPt:Point = new Point(ev.stageX,ev.stageY);
				
				var vec:Point = new Point(endPt.x - startPt.x, endPt.y - startPt.y);
				
				var angle:Number = BunnyConsts.vecToAngle(vec);
				
				var angleAsDegrees:Number = angle * 180/Math.PI;
				myTurret.updateDirection(angleAsDegrees);
			}
		}
		
		private function onClickBG(ev:MouseEvent):void
		{
			//Timer for spam clicks
			if(m_LocalTurret != null)
			{
				var TIME_BETWEEN_SHOTS:int = 250;
				var currTime:Number = flash.utils.getTimer();
				if(m_LastClickTime + TIME_BETWEEN_SHOTS < currTime)
				{
					m_LastClickTime = currTime;
					var turret:Turret = m_LocalTurret;
					var startPt:Point = turret.centerPt;
					var endPt:Point = new Point(ev.stageX,ev.stageY);
					
					var vec:Point = new Point(endPt.x - startPt.x, endPt.y - startPt.y);
					
					var angle:Number = BunnyConsts.vecToAngle(vec);
					
					var angleAsDegrees:Number = angle * 180/Math.PI;
					
					var bunnyHitID:int = projectIfAnyBunniesHit(turret,vec,startPt);
					var params:Object = new Object();
					params.roomId = RoomManager.getInstance().currentRoomId;
					params.bunnyId = bunnyHitID;
					params.angle = (int)(angleAsDegrees);
					SocketClient.getInstance().sendPluginMessage("room_enumeration", "bunnyShoot", params);
					
					m_HUD.DEBUGShootAccepted();
				}
			}
		}
		
		// Returns 0 if no bunnies are going to be hit. or ID if one is.
		private function projectIfAnyBunniesHit(turret:Turret,vec:Point,startPt:Point):int
		{
			var bunnyHitID:int = -1;
			var len:Number = vec.length;
			vec.x = vec.x/len;
			vec.y = vec.y/len;
			//normalize than multipley by the range
			vec.x = vec.x * BunnyConsts.THROW_RANGE;
			vec.y = vec.y * BunnyConsts.THROW_RANGE;
			vec.x = vec.x + startPt.x;
			vec.y = vec.y + startPt.y;
			
			var temp:Sprite = new Sprite();
			temp.graphics.beginFill((uint)(Math.random() * 0xFFFFFF),0.6);
			temp.graphics.drawRect(startPt.x,startPt.y,
									vec.x - startPt.x,vec.y - startPt.y);
			temp.graphics.endFill();
			temp.mouseEnabled = false;
			var ro2:RenderObject = new RenderObject(new RenderData(temp));
			_roomContainer.getRenderLayer(RoomLayerType.FOREGROUND).addItem(ro2);
			
			var shotHitRect:Rectangle = temp.getBounds(temp.stage);
			//trace("shot Rect:" + shotHitRect);
			for(var j:int = 0; j < m_BunnyList.length; ++j)
			{
				var b:Bunny = m_BunnyList[j];
				if(b.getHasSpawned())
				{
					var rect:Rectangle = b.display.getBounds(temp.stage);
					
					//trace("Bunny Rect:" + rect);
					if(rect.intersects(shotHitRect))
					{
						bunnyHitID = b.bunnyID;
						temp.graphics.beginFill(0);
						temp.graphics.drawCircle(0,0,100);
						temp.graphics.endFill();
						break;
					}
				}
			}
			// needs to be added for hit testobj to work
			_roomContainer.getRenderLayer(RoomLayerType.FOREGROUND).removeItem(ro2);
			
			if(bunnyHitID != -1)
			{
				trace("BUNNY HIT ID: " + bunnyHitID);
			}
			
			return bunnyHitID;
		}
		
				
		private function snowballAnimDone(s:Snowball):void
		{
			// Remove it from the list
			var i:int = m_Snowballs.indexOf(s);
			s.destroy();
			m_Snowballs.splice(i,1);
			removeToLayer(s,RoomLayerType.FOREGROUND);
		}
		/**
		 * Debug for the game
		 */
		
		 private function onPlaceTurret(ev:MouseEvent):void
		 {
		 	LoggingUtil.sendClickLogging(4405);
		 	if(m_LocalTurret == null)
		 	{
		 		// if not walking. AND final destination is not on a path tile.
				var floorTileMap:TileMap = RoomManager.getInstance().currentRoom.getMapLayer(RoomLayerType.FLOOR);
				var av:Avatar = RoomManager.getInstance().userController.avatar;
				var displayBase:RoomItemSprite = RoomManager.getInstance().userController.display as RoomItemSprite;
				var tile:IOccupancyTile = floorTileMap.getTile(av.x,av.y);
				
				if(tile != null)
				{
					if(tile.tileSetID == "1")
					{
						//the height changes when floaty text is above... so use stored values
						var ourPt:Point = new Point(av.display.x + BunnyConsts.THROW_RANGE/4,
													av.display.y + BunnyConsts.THROW_RANGE/4);
						var buffer:int = BunnyConsts.THROW_RANGE * 0.6;
						var toClose:Boolean = false;
						// are we to close to another turret?
						for(var j:int = 0; j < m_TurretList.length; ++j)
						{
							// Do we need to verify in right location here?
							var turret:Turret = m_TurretList[j];
							if( Point.distance(turret.centerPt,ourPt) < buffer)
							{
								toClose = true;
								break;
							}
						}
						
						if(m_IsWalking)
						{
							displayBase.showOverheadMessage("Can't place snowman when moving!",0x0000FF);
						}
						else if(toClose)
						{
							displayBase.showOverheadMessage("Too close to another snowman!",0x0000FF);
						}
						else
						{
							var params:Object = new Object();
							params.roomId = RoomManager.getInstance().currentRoomId;
							SocketClient.getInstance().sendPluginMessage("room_enumeration", "addTower",params);
							_roomContainer.getRoomController().setCustomUIController(new CarrotDefenseUIController());
							m_HUD.starExitVisibility(false);
						}
					}
					else
					{
						displayBase.showOverheadMessage("Can't place snowman on the path.",0x0000FF);
					}
				}
		 	}
		 }		 
		 		
		// Should really be doing this less
		private function onSpawnNextBunny():void
		{	 
			//serverDate
			var now:int = flash.utils.getTimer();
			var frameDelta:int = now - m_LastFrameTime;
			m_LastFrameTime = now;
			
			m_ServerTime += frameDelta;
			
		 	for(var i:int = 0; i < m_BunnyList.length; ++i)
			{	
				var b:Bunny = m_BunnyList[i];
				
				if(!b.getHasSpawned() && 
					b.spawnTime < m_ServerTime)
				{
					var svrDate:Date = new Date();
					svrDate.setTime(m_ServerTime);
					//trace("Server DATE NOW: " + svrDate.toTimeString());
					var d:Date = new Date();
					d.setTime(b.spawnTime);
			 		b.startPath(removeBunny,m_ServerTime);
			 		
			 		if(b.startOfWave)
			 		{
			 			m_HUD.nextWaveStarted();
			 		}
			 		
					break;
			 	}
			}
		 }
		 
		 private function removeBunny(b:Bunny,didGoOffscreen:Boolean):void
		 {
		 	var i:int = m_BunnyList.indexOf(b);
		 	if(i != -1)
		 	{
				if(didGoOffscreen)
				{
					//TODO: life should be on the bunnyEscaped message	
					var params:Object = new Object();
					params.roomId = RoomManager.getInstance().currentRoomId;
					params.bunnyId = b.bunnyID;
					SocketClient.getInstance().sendPluginMessage("room_enumeration", "bunnyEscape",params);
				}
				b.destroy();
				m_BunnyList.splice(i,1);
				removeToLayer(b);
		 	}
		 }
		 
		 private function onBunnyEscaped(ev:Event):void
		 {
		 	
		 	var obj:Object = ev as Object;
			var params:Object = obj.params;
			//trace("Bunny escaped params" + params.bunnyEscaped);
			//comma list of bunnyID,currentlife
			var arr:Array = params.bunnyEscaped.split(",");
			m_HUD.updateTeamLife(parseInt(arr[1]));
		 }
		 
		 private var m_EndGameDialog:BunnyAfterGameReport;
		 
		 private function showEndScoreScreen():void
		 {
		 	m_EndGameDialog = MainUtil.showDialog(BunnyAfterGameReport,{turretList:m_TurretList},false) as BunnyAfterGameReport;
		 	m_HUD.startSnowmanTimer();	
		 	m_EndGameDialog.visible = false; 
		 	
		 	m_HUD.DEBUGShow();	
		 }
		 private function makeEndScoreVisible():void
		 {
		 	if(m_RoomDestroyed)
		 	{
		 		m_EndGameDialog.closeWithoutGameCountCheck();
		 	}
		 	if(m_EndGameDialog != null)
		 	{
		 		m_EndGameDialog.visible = true;
		 	}
		 }
		 
		 private function spawnCarrot(startX:Number,startY:Number):void
		 {
		 	const MIN_CLICK_HEIGHT:int = 540;
		 	if(startY > MIN_CLICK_HEIGHT)
		 	{
		 		startY = MIN_CLICK_HEIGHT
		 	}
		 //	trace("CARROT SPAWNED");
		 	var c:Carrot = new Carrot(CarrotClass,carrotDestroyed);
		 	c.display.x = startX;
		 	c.display.y = startY;
		 	addToLayer(c,RoomLayerType.FOREGROUND);
		 	m_CarrotList.push(c);
		 }
		 private function carrotDestroyed(c:Carrot,userGotPoints:int):void
		 {
		 	var i:int = m_CarrotList.indexOf(c);
			c.destroy();
			m_CarrotList.splice(i,1);
			removeToLayer(c,RoomLayerType.FOREGROUND);
			if(userGotPoints != 0)
			{
				var params:Object = new Object();
				params.quantity = 1;
				params.roomId = RoomManager.getInstance().currentRoomId;
				SocketClient.getInstance().sendPluginMessage("room_enumeration", "carrotShoot",params);
				
				m_HUD.incrementCarrotScore(userGotPoints);
			}
		 }
		private function placeSnowmanBtn(onDisplay:IRoomItemDisplay):void
		{
			m_HUD.updateSnowmanButtonPos(onDisplay.x,onDisplay.y);
			m_HUD.updateRangePreview(onDisplay.x,onDisplay.y);
		}
	}
}