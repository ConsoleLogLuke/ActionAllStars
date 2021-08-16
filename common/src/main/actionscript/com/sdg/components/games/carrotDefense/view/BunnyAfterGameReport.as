package com.sdg.components.games.carrotDefense.view
{
	import com.sdg.components.controls.CustomMVPAlert;
	import com.sdg.components.dialog.InteractiveDialog;
	import com.sdg.components.games.carrotDefense.BunnyConsts;
	import com.sdg.components.games.carrotDefense.model.Turret;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.game.counter.GamePlayCounter;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.utils.MainUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Timer;

	public class BunnyAfterGameReport extends InteractiveDialog
	{
		private var m_TurretList:Array;
		private var m_Timer:Timer;
		 private var m_TimeLeft:int;
		 private var m_HasBeenShutDown:Boolean;
		 
		public function BunnyAfterGameReport()
		{
			super();
			
			m_TimeLeft = BunnyConsts.TIME_BETWEEN_ROUNDS * 1000;
			m_Timer = new Timer(1000,BunnyConsts.TIME_BETWEEN_ROUNDS);
		 	m_Timer.addEventListener(TimerEvent.TIMER,onTimeLeftUpdate,false,0,true);
		 	m_Timer.start();
		 	m_HasBeenShutDown = false;
		}
		
		public override function init(params:Object):void
		{
			var swfPath:String = Environment.getApplicationUrl() + "/test/gameSwf/gameId/106/gameFile/towerDefense_gameResults.swf"
			// just hardcode for now.
			params["url"] = swfPath;
			super.init(params);
			
			// Make a copy of the relevant information.
			var srcList:Array = params.turretList;
			m_TurretList = new Array();
			for(var i:int = 0; i < srcList.length; ++i)
			{
				var singleTurretInfo:Object = new Object();
				var turret:Turret = srcList[i];
				if(turret != null)
				{
					var av:Avatar = RoomManager.getInstance().currentRoom.getAvatarById(turret.avatarId);
					if(av != null)
					{
						singleTurretInfo.name = av.name;
						singleTurretInfo.kills = turret.kills.toString();
						singleTurretInfo.carrots = turret.carrots.toString();
						singleTurretInfo.isLocal = (turret.avatarId == ModelLocator.getInstance().avatar.avatarId);
						m_TurretList.push(singleTurretInfo);
					}
				}
			}
			//sort this list.
			m_TurretList = m_TurretList.sortOn("kills",Array.DESCENDING | Array.NUMERIC);	
		}
		
		protected override function loadCompleteHandler():void
		{
			super.loadCompleteHandler();
			
			// figure things out
			var s:Sprite = (_display as QuickLoader).content as Sprite;
			// Umm... for some reason the widht and the height are weird on this swf, can't figure out why
			//_display.x = -897/2;
			//_display.y = -547/2;
			try
			{
				var minWidth:Number = _display.width <= root.width ? _display.width : root.width;
				minWidth = root.width;
				_display.x = -minWidth/2;
				
				//var minHeight:Number = _display.height < root.height ? _display.height : root.height;
				var minHeight:Number = _display.height;
				minHeight = root.height;
				_display.y = -minHeight/2;
			}
			catch(e:Error)
			{
				_display.x = -_display.width/2;
				_display.y = -_display.height/2;
			}
			//_display.x = -_display.width/2;
			//_display.y = -_display.height/2;
			// attach a black background. Can't just be a modal since we attach this and then make it visible.
			
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0,0.7);
			sp.graphics.drawRect(-200,-200,1200,1200);
			sp.graphics.endFill();
			s.addChildAt(sp,0);
			
			
			var foundLocalTurret:Boolean = false;
			var teamBonus:int = m_TurretList.length;
			//there are 12 names on the board
			const MAX_PLAYERS:int = 12;
		 	for(var i:int = 0; i < 12; ++i)
		 	{
		 		var playerNameTF:TextField = s.getChildByName("player" + (i + 1)) as TextField;
		 		var rabbitCountTF:TextField = s.getChildByName("rabbitCount" + (i + 1)) as TextField;
		 		var carrotCountTF:TextField = s.getChildByName("carrotCount" + (i + 1)) as TextField;
		 		if(playerNameTF != null)
		 		{
		 			var allTFs:Array = [playerNameTF,rabbitCountTF,carrotCountTF];
		 			var j:int = 0;
		 			if(m_TurretList[i] != null)
		 			{
		 				var turret:Object = m_TurretList[i];
						
						playerNameTF.text = turret.name;
						rabbitCountTF.text = turret.kills;
						var totalCarrotsMinusBonus:int = (turret.carrots - teamBonus);
						carrotCountTF.text = totalCarrotsMinusBonus.toString();
						
		 				for(j = 0; j < 3; ++j)
		 					allTFs[j].visible = true;
		 				var filterArr:Array = [];
		 				var tfColor:uint = 0;
		 				if(turret.isLocal)
		 				{
		 					filterArr = [new GlowFilter(0xFFFFFF,1,6,6,4)];
		 					tfColor = 0xFF6600;
		 					foundLocalTurret = true;
		 				}
		 				for(j = 0; j < 3; ++j)
		 				{
		 					allTFs[j].filters = filterArr;
		 					allTFs[j].textColor = tfColor;
		 				}
		 			}
		 			else
		 			{
		 				for(j = 0; j < 3; ++j)
		 					allTFs[j].visible = false;
		 			}
		 		}
		 	}
		 	
		 	var tf:TextField = s.getChildByName("teamCarrots") as TextField;
			if(tf != null)
			{
				if(!foundLocalTurret)
				{
					tf.text = "0";
				}
				else
				{
					tf.text = m_TurretList.length.toString();
				}
			}
			
		 	initCurrentText();
		}
		
		public function closeWithoutGameCountCheck():void
		{
			super.close();
			m_Timer.removeEventListener(TimerEvent.TIMER,onTimeLeftUpdate);
		}
		
		public override function close():void
		{
			if(m_HasBeenShutDown == false)
			{
				m_HasBeenShutDown = true;
				closeWithoutGameCountCheck();
				if (ModelLocator.getInstance().avatar.membershipStatus != MembershipStatus.PREMIUM)
				{
					if (GamePlayCounter.getPlayCount(106) >= GamePlayCounter.MAX_FREE_PLAYS_PER_DAY )
					{
						dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, "public_156"));
						LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_BUNNY_GAME_LIMIT);
						var mvpAlert:CustomMVPAlert = CustomMVPAlert.show(Environment.getAssetUrl() + '/test/gameSwf/gameId/106/gameFile/mvp_upsell_popUp_BunniesAttack_GameLimit.swf',
																	LoggingUtil.MVP_UPSELL_CLICK_BUNNY_GAME_LIMIT,onMVPClose);
							
						return;
					}
				}
				function onMVPClose(event:Object):void
				{
					var identifier:int = event.detail;
					
					if (identifier == LoggingUtil.MVP_UPSELL_CLICK_BUNNY_GAME_LIMIT)
						MainUtil.goToMVP(identifier);
				}
			}
		}
		
		private function onTimeLeftUpdate(ev:TimerEvent):void
		 {
		 	try
			{
				m_TimeLeft -= 1000;
				var leftSeconds:int = m_TimeLeft/1000;
				var s:Sprite = (_display as QuickLoader).content as Sprite;
				var tf:TextField = s.getChildByName("countdownText") as TextField;
				if(tf != null)
				{
					tf.multiline = true;
					tf.wordWrap = true;
					tf.text = leftSeconds + " seconds until next invasion";
				}
			}
			catch(e:Error)
			{
				//trace(e.getStackTrace());
			}
		 }
		private function initCurrentText():void
		{
			var av:Avatar = ModelLocator.getInstance().avatar;
			var url:String = Environment.getApplicationUrl() + '/api/dyn/avatar/ac?avatarId='+av.avatarId+'&currencyId=1';
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);

			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Get feed xml.
				var xml:XML = new XML(loader.data);
				
				var s:Object = (_display as QuickLoader).content;
				try
				{
					var tf:TextField = s.getChildByName("totalCarrots") as TextField;
					if(tf != null)
					{
						tf.text = xml.balance;
					}
				}
				catch(err:Error)
				{
					trace("FUNCTION NOT FOUND");
				}
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
	}
}