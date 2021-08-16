package com.sdg.components.games.carrotDefense.view
{

	import com.sdg.components.controls.CustomMVPAlert;
	import com.sdg.components.dialog.ISdgDialog;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.SocketRoomEvent;
	import com.sdg.game.counter.GamePlayCounter;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.RoomInfo;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.methods.SocketRoomMethods;
	import com.sdg.utils.MainUtil;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	public class BunnyRoomJoinDialog extends Canvas implements ISdgDialog
	{
		private const BUNNY_ROOM_IDS:Array = ["public_157","public_158","public_159","public_160",
												"public_161","public_162","public_163","public_164"];
		
		private var m_Display:QuickLoader;
		private var m_RoomInfoArray:Array = [];
		public function BunnyRoomJoinDialog()
		{
			super();
		}
		
		public function init(params:Object):void
		{
			if (ModelLocator.getInstance().avatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				this.close();	
				// don't need to do anything else
				return;
			}
			
			//This will need upsell logic based on GamePlayCounter.getPlayCount(gameId)
			var loadURL:String = Environment.getApplicationUrl() + "/test/gameSwf/gameId/106/gameFile/towerDefense_startChoose_screens.swf";
			if (ModelLocator.getInstance().avatar.membershipStatus != MembershipStatus.PREMIUM)
			{
				if (GamePlayCounter.getPlayCount(106) >= GamePlayCounter.MAX_FREE_PLAYS_PER_DAY )
				{
					LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_BUNNY_GAME_LIMIT);
					var mvpAlert:CustomMVPAlert = CustomMVPAlert.show(Environment.getAssetUrl() + '/test/gameSwf/gameId/106/gameFile/mvp_upsell_popUp_BunniesAttack_GameLimit.swf',
																LoggingUtil.MVP_UPSELL_CLICK_BUNNY_GAME_LIMIT,onMVPClose);
					this.close();
					return;
				}
			}
			m_Display = new QuickLoader(loadURL,
							loadCompleteHandler,null,3);
			m_Display.addEventListener(Event.CLOSE,onClose);
			m_Display.addEventListener("Transport",onTransport);
			m_Display.addEventListener("BunnyDefenseEvent_PickRandomRoom",onQuickSelectSelected);
			
			getRoomInfo();
			function onMVPClose(event:Object):void
			{
				var identifier:int = event.detail;
				
				if (identifier == LoggingUtil.MVP_UPSELL_CLICK_BUNNY_GAME_LIMIT)
					MainUtil.goToMVP(identifier);
			}
		}
		
		private function getRoomInfo():void
		{
			var socketMethods:SocketRoomMethods = new SocketRoomMethods();
			socketMethods.addEventListener(SocketRoomEvent.NUM_AVATARS, onNumAvatar);
			
			var i:int = 0;
			 // [roomInfo, roomInfo, roomInfo]
			var roomInfo:RoomInfo;
			var roomId:String = BUNNY_ROOM_IDS[i];
			socketMethods.addEventListener(SocketRoomEvent.NUM_AVATARS, onNumAvatar);
			socketMethods.getAvatarCountInRoom(roomId);
			
			function onNumAvatar(ev:Object):void
			{
				var _avatarXML:XML = XML(ev.params.numAvatars);
				roomInfo = new RoomInfo(roomId, 'Bunny Attack', int(_avatarXML.numAvatars.*[0]), int(_avatarXML.maxAvatars.*[0]));
				m_RoomInfoArray.push(roomInfo);
				i++;
				if (i < BUNNY_ROOM_IDS.length)
				{
					// If we have more Broadcast Center rooms to check.
					roomId = BUNNY_ROOM_IDS[i];
					socketMethods.getAvatarCountInRoom(roomId);
				}
				else
				{
					// If we don't have any more Broadcast Center rooms to check.
					// Remove avatar count listener.
					socketMethods.removeEventListener(SocketRoomEvent.NUM_AVATARS, onNumAvatar);
					// Send to display
					trace("Done loading");
					setUpRoomSelect();
				}
			}

// These calls work, but ONLY if you have already been in that room. Otherwise the client doesn't have the zoneID.
/*
			SocketClient.getInstance().addEventListener(SocketEvent.PLUGIN_EVENT,onUsersInRoom);
			SocketClient.getInstance().sendPluginMessage("room_enumeration", "usersInRoom", { roomId:"public_156" });
			function onUsersInRoom(ev:SocketEvent):void
			{
				var action:String = ev.params.action;
				if(action == "usersInRoom")
				{
					trace(ev);
				}
			}
*/
		}
		
		public function close():void
		{
			if(m_Display != null)
			{
				var rawClip:MovieClip = m_Display.content as MovieClip;
				var howToPlayHit:DisplayObject = rawClip.getChildByName("btnHowTo");
				if(howToPlayHit != null)
				{
					howToPlayHit.removeEventListener(MouseEvent.CLICK,onHowToHit);
				}
				var btnChooseroom:DisplayObject = rawClip.getChildByName("btnChooseroom");
				if(btnChooseroom != null)
				{
					btnChooseroom.removeEventListener(MouseEvent.CLICK,onChooseRoomHit);
				}
			}
				
			//Forward the close event to anything listening
			this.dispatchEvent(new Event(Event.CLOSE));
			PopUpManager.removePopUp(this);
			
			//SocketClient.getInstance().removeEventListener(SocketRoomEvent.NUM_AVATARS, onNumAvatar);
		}

		
		protected function loadCompleteHandler():void
		{
			m_Display.addEventListener(Event.CLOSE,onClose);
			this.rawChildren.addChild(m_Display);

			try
			{
				var minWidth:Number = m_Display.width <= root.width ? m_Display.width : root.width;
				minWidth = root.width;
				m_Display.x = -minWidth/2;
				
				//var minHeight:Number = _display.height < root.height ? _display.height : root.height;
				var minHeight:Number = m_Display.height;
				minHeight = root.height;
				m_Display.y = -minHeight/2;
				
				var rawClip:MovieClip = m_Display.content as MovieClip;
				var howToPlayHit:DisplayObject = rawClip.getChildByName("btnHowTo");
				if(howToPlayHit != null)
				{
					howToPlayHit.addEventListener(MouseEvent.CLICK,onHowToHit);
				}
				var btnChooseroom:DisplayObject = rawClip.getChildByName("btnChooseroom");
				if(btnChooseroom != null)
				{
					btnChooseroom.addEventListener(MouseEvent.CLICK,onChooseRoomHit);
				}
				
			}
			catch(e:Error)
			{
				m_Display.x = -m_Display.width/2;
				m_Display.y = -m_Display.height/2;
			}
			setUpRoomSelect();
		}
		
		protected function onClose(ev:Event):void
		{
			close();
		}
		
		protected function onQuickSelectSelected(ev:Event):void
		{
			var roomEntered:Boolean = false;
			//Randomly pick a non-full room.
			for(var i:int = 0; i < m_RoomInfoArray.length; ++i)
			{
				var info:RoomInfo = m_RoomInfoArray[i];
				
				if(info.numAvatars < info.maxAvatars - 1)
				{
					roomEntered = true;
					dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, info.id));
				}
			}
			// attempt to enter the first one (probably failing)
			// thus the user is messaged.
			if(!roomEntered)
			{
				var firstRoom:RoomInfo = m_RoomInfoArray[0];
				dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, firstRoom.id));
			}
			LoggingUtil.sendClickLogging(4402);
		}
		
		private function setUpRoomSelect():void
		{
			try
			{
				//If the display loaded first
				if(m_Display.content != null)
				{
					if(m_RoomInfoArray.length > 0)
					{
						//trace("Num rooms: " + m_RoomInfoArray.length);
						var obj:Object = m_Display.content;
						obj.setRoomInfo(m_RoomInfoArray);
					}
				}
			}
			catch(e:Error)
			{
				trace(e.getStackTrace());
			}
		}
		
		protected function onTransport(e:Event):void
		{
			var roomId:String = "";
			if (e.hasOwnProperty("roomId"))
			{
				var obj:Object =  e as Object;
				roomId = obj.roomId as String;
			}
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
			
			this.close();
		}
		
		private function onHowToHit(ev:Event):void
		{
			LoggingUtil.sendClickLogging(4403);
		}
		private function onChooseRoomHit(ev:Event):void
		{
			LoggingUtil.sendClickLogging(4404);
		}
		
	}
}