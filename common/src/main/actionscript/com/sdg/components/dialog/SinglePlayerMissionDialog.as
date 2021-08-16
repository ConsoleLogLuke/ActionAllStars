package com.sdg.components.dialog
{
	import com.sdg.control.room.RoomController;
	import com.sdg.control.room.RoomManager;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.quest.QuestManager;
	import com.sdg.utils.MainUtil;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;
		
	/**
		 * 
		 * This indicates the start menu for single player dialogs.
		 * Load in assets dynamically.
		 * 
		 * @author molly.jameson
		 * 
		 */
	public class SinglePlayerMissionDialog extends Canvas implements ISdgDialog
	{
		private var m_GameId:uint;
		private var m_Url:String = "";
		private var _display:DisplayObject;
		private var m_BGVolume:Number;
		
		public function SinglePlayerMissionDialog()
		{
			m_BGVolume = 1;
		}
		
		
		public function init(params:Object):void
		{
			if (params)
			{	
				m_GameId = params["gameID"];
			}
			else
			{
				this.close();
			}
			
			var swfPath:String = "";
			if (ModelLocator.getInstance().avatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				this.close();	
				// don't need to do anything else
				return;
			}
			else
			{
				// Single Plaeyr mission is now free
				swfPath = Environment.getApplicationUrl() + "/test/gameSwf/gameId/"+m_GameId+"/gameFile/MVPIntro.swf";	
			}
			if(swfPath != "")
			{
				_display = new QuickLoader(swfPath,loadCompleteHandler,null,3);
				_display.addEventListener("SPMSoundStarted",onSoundStarted);
				_display.addEventListener(Event.CLOSE,onMVPClose);
				_display.addEventListener("go mvp",onMVPClose);
			}
			// Turn off the BG Music
			//HACK HACK!!!
			//Since it's static we can access it.
			var roomController:RoomController = QuestManager.roomView.getRoomController();	
			m_BGVolume = roomController.roomSoundVolume;
			if (!roomController.isMuted)
			{
				roomController.roomSoundVolume = 0;
			}
			
			function onMVPClose(ev:Event):void
			{
				close();
				if (ev.type == "go mvp")
				{
					LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_CLICK_SINGLEPLAYERMISSION);
					MainUtil.goToMVP(LoggingUtil.MVP_UPSELL_CLICK_SINGLEPLAYERMISSION);
				}
			}
			function onSoundStarted(ev:Event):void
			{
				trace("Trace setting mute status of swf");
				var mc:MovieClip = _display["content"] as MovieClip;
				mc.onSetMuted(roomController.isMuted);
			}
		}
		
		protected function loadCompleteHandler():void
		{
			_display.addEventListener(Event.CLOSE,onClick,false,0,true);
			_display.addEventListener("GameLaunchEvent",onLaunchGame,false,0,true);
			this.rawChildren.addChild(_display);
			
			// For some reason this is changing in IE?
			try
			{
				_display.x = -this.root.width/2;
				
				var minHeight:Number = _display.height < root.height ? _display.height : root.height;
				_display.y = -minHeight/2;
			}
			catch(e:Error)
			{
				trace(e.getStackTrace());
			}
		}
		
		protected function onClick(e:Event):void
		{
			this.close();
		}
		
		public function close():void
		{
			// Remove Listener
			if(_display != null)
			{
				
				try
				{
					Object(_display).unloadSound();
				}
				catch(e:Error) {}
			}
			
			//Forward the close event to anything listening
			this.dispatchEvent(new Event(Event.CLOSE));
			
			PopUpManager.removePopUp(this);
			
			var roomController:RoomController = QuestManager.roomView.getRoomController();	
			if (!roomController.isMuted)
			{
				roomController.roomSoundVolume = m_BGVolume;
			}
		}
		
		/**
		 * 
		 * for now this only can launch the first mission.
		 * Next mission (if we do one) I'll define a game launch event in the world.
		 * Or cast the mission as an object. This event actually does have an ID attached to it though.
		 * 
		 * @author molly.jameson
		 * 
		 */
		private function onLaunchGame(event:Event):void
		{
			RoomManager.getInstance().loadGame(m_GameId);
			this.close();
		}

	}
}