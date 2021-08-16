package com.sdg.components.games.carrotDefense.view
{
	import com.sdg.components.games.carrotDefense.BunnyConsts;
	import com.sdg.components.games.carrotDefense.model.Turret;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public class BunnyHUD
	{
		 private var m_CarrotScore:int;
		 private var m_BunnyScore:int;
		 private var m_CarrotScoreTF:TextField;
		 private var m_BunnyScoreTF:TextField;
		 private var m_LifeMeter:MovieClip;
		 private var m_TeamLife:int = 20;
		 private var m_StartLife:int = 20;
		 private var m_LastLifeState:int = 20;
		 
		 private var m_Timer:Timer;
		 private var m_TimeLeft:int;
		 
		 private const MAX_LIFE_GRAPHICALLY:int = 5;
		 private var m_SnowManRef:MovieClip;
		 
		 private var m_EndAnimation:MovieClip;
		 
		 private var m_RangePreview:Sprite;
		 private var m_BG:Sprite;
		 
		 private var m_UILayer:Sprite;
		 private var m_PlaceSnowmanBtn:SimpleButton;
		 private var m_MinAvatarHeight:int;		 
		 
		public function BunnyHUD(background:Sprite)
		{
			// grabs the HUD Names off it
			
			var carrotCount:DisplayObject = background.getChildByName("carrotCount");
			if(carrotCount != null)
			{
				m_CarrotScoreTF = (carrotCount as Sprite).getChildByName("txtRabbitKills") as TextField;
			}
			var rabbitCount:DisplayObject = background.getChildByName("rabbitCount");
			if(rabbitCount != null)
			{
				m_BunnyScoreTF = (rabbitCount as Sprite).getChildByName("txtRabbitKills") as TextField;
			}
			m_LifeMeter = background["inst_LifeMeter"];
			m_LifeMeter = m_LifeMeter["inst_LifeMeter"];
			m_LifeMeter = m_LifeMeter["lifeMeterNew"];
			
			m_SnowManRef = background.getChildByName("inst_SnowmanRef") as MovieClip;
			//m_SnowManRef.gotoAndPlay(2);
			
			m_EndAnimation = background.getChildByName("inst_EndAnim") as MovieClip;
			m_EndAnimation.visible = false;
			m_EndAnimation.stop();
			//m_EndAnimation.gotoAndPlay("goodJob");
			
			m_RangePreview = new Turret.MC_THROW_RANGE();
			m_RangePreview.mouseChildren = m_RangePreview.mouseEnabled = false;
			background.addChild(m_RangePreview);
			showRangePreview(false);
			
			m_BG = background;
		}
		
		public function init(uiLayer:Sprite,placeSnowmanButton:SimpleButton,minAvatarHeight:int=120):void
		{
			m_UILayer = uiLayer;
			
			m_PlaceSnowmanBtn = placeSnowmanButton;

			 m_PlaceSnowmanBtn.addEventListener(MouseEvent.MOUSE_OVER,onTurretBtnOver,false,0,true);
			 m_PlaceSnowmanBtn.addEventListener(MouseEvent.MOUSE_OUT,onTurretBtnOut,false,0,true);
			 
			 m_PlaceSnowmanBtn.visible = false;
			m_UILayer.addChild(m_PlaceSnowmanBtn);
			
			m_EndAnimation.mouseChildren = m_EndAnimation.mouseEnabled = false;
			m_UILayer.addChild(m_EndAnimation);
			var parentOfLifeMeter:Sprite = m_BG["inst_LifeMeter"];
			//parentOfLifeMeter.mouseChildren = parentOfLifeMeter.mouseEnabled = false;
			m_UILayer.addChild(parentOfLifeMeter);
			
			m_MinAvatarHeight = minAvatarHeight;
			
			DEBUGInit();
			 
		}
		public function destroy():void
		{
			m_UILayer.removeChild(m_EndAnimation);
			var parentOfLifeMeter:DisplayObject = m_BG["inst_LifeMeter"];
			m_UILayer.removeChild(parentOfLifeMeter);
			
			m_UILayer.removeChild(m_PlaceSnowmanBtn);
			
			m_PlaceSnowmanBtn.removeEventListener(MouseEvent.MOUSE_OVER,onTurretBtnOver);
			 m_PlaceSnowmanBtn.removeEventListener(MouseEvent.MOUSE_OUT,onTurretBtnOut);
		}
		
		public function get placeSnowmanButton():SimpleButton
		{
			return m_PlaceSnowmanBtn;
		}
		public function updateSnowmanButtonPos(xPos:int,yPos:int):void
		{
			m_PlaceSnowmanBtn.x = xPos + 40;
			m_PlaceSnowmanBtn.y = yPos + m_MinAvatarHeight;
		}
		
		public function showRangePreview(isShowing:Boolean = true):void
		{
			m_RangePreview.visible = isShowing;
		}
		public function updateRangePreview(xPos:int,yPos:int):void
		{
			// pffset based on snowman height difference
			m_RangePreview.x = xPos - m_RangePreview.width/2 + 75;
			m_RangePreview.y = yPos - m_RangePreview.height/2 + 75;
		}
		
		private function onTurretBtnOver(ev:Event):void
		 {
		 	showRangePreview(true);
		 }
		 private function onTurretBtnOut(ev:Event):void
		 {
		 	showRangePreview(false);
		 }
		
		public function nextWaveStarted():void
		{
			playRandomSnowmanPhrase();
		}
		public function newGameStarted():void
		{
			playRandomSnowmanPhrase();
			
			DEBUGInit();
		}
		
		private function playRandomSnowmanPhrase():void
		{
			var expressionTypes:Array = ["refSmile","refOhNo","refGrimace"];
			var randIndex:int = (int)(Math.random() * expressionTypes.length);
			
			var randPhrase:String = allStrings(randIndex);
			//Should be in a config file but whatever.
			var obj:Object = m_BG;
			obj.setSnowManDialogDuringAnimation(randPhrase,expressionTypes[randIndex]);
			//m_SnowManRef.gotoAndPlay("refOhNo");
		}
		private function allStrings(index:int):String
		{
			var dialog:Array = ["These bunnies are relentless!","Don't let them get through!",
					"Hold your ground!","AAAAAAAAAAA!"];
			if(index == 0)
			{
				dialog = ["The next wave is approaching...","The bunnies are close, I can feel it.",
						"Are you ready for this?","Prepare your snowmen.","There is movement in the trees!"];
			}
			else if(index == 1)
			{
				dialog = ["I can hear them coming!","Oh no, they are here!",
						"Have those snowballs ready!","The nose, watch the nose!"];
			}
			var randIndex:int = (int)(Math.random() * dialog.length);
			return dialog[randIndex];
		}
		
		public function updateCarrotScore(toPoints:int = 0):void
		 {
		 	m_CarrotScore = toPoints;
		 	m_CarrotScoreTF.text = m_CarrotScore.toString();
		 }
		 public function incrementCarrotScore(byPoints:int = 1):void
		 {
		 	m_CarrotScore = m_CarrotScore + byPoints;
		 	m_CarrotScoreTF.text = m_CarrotScore.toString();
		 }
		 public function updateBunnyScore(toPoints:int=0):void
		 {
		 	m_BunnyScore = toPoints;
		 	m_BunnyScoreTF.text = m_BunnyScore.toString();
		 }
		 public function incrementBunnyScore(byPoints:int=1):void
		 {
		 	m_BunnyScore = m_BunnyScore + byPoints;
		 	m_BunnyScoreTF.text = m_BunnyScore.toString();
		 }
		 public function resetTeamLife(startLife:int = 20):void
		 {
		 	m_TeamLife = startLife;
		 	m_StartLife = BunnyConsts.TEAM_LIFE;
		 	m_LifeMeter.gotoAndStop(1);
		 	m_LastLifeState = m_StartLife;
		 }
		 public function updateTeamLife(newLife:int = 1):void
		 {
		 	m_TeamLife = newLife;
		 	
		 	if(m_LastLifeState != m_TeamLife)
		 	{
		 		var inverse:int = m_StartLife - m_TeamLife;
		 		var labelName:String = "life" + inverse.toString();
		 		m_LifeMeter.gotoAndPlay(labelName);
		 	}
		 }
		 
		 public function resetGame():void
		 {
		 	m_SnowManRef.gotoAndPlay(2);
		 	resetTeamLife();
		 	updateBunnyScore();
		 	updateCarrotScore();
		 }
		 
		 //dispatches a win animation when done.
		 public function playWinAnimation(endFuncCallBack:Function):void
		 {
		 	//probably should frame label these too.
		 	m_EndAnimation.visible = true;
		 	m_EndAnimation.gotoAndPlay("goodJob");
		 	m_EndAnimation.addEventListener(Event.ENTER_FRAME,onEnterFrame);
		 	function onEnterFrame(ev:Event):void
		 	{
		 		if(m_EndAnimation.currentFrame == 145)
		 		{
		 			m_EndAnimation.visible = false;
		 			m_EndAnimation.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
		 			endFuncCallBack();
		 		}
		 	}
		 }
		 public function playLoseAnimation(endFuncCallBack:Function):void
		 {
		 	m_EndAnimation.visible = true;
		 	m_EndAnimation.gotoAndPlay("gameOver");
		 	m_EndAnimation.addEventListener(Event.ENTER_FRAME,onEnterFrame);
		 	function onEnterFrame(ev:Event):void
		 	{
		 		if(m_EndAnimation.currentFrame == 73)
		 		{
		 			m_EndAnimation.visible = false;
		 			m_EndAnimation.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
		 			endFuncCallBack();
		 		}
		 	}
		 }
		 
		
		 public function startSnowmanTimer(useRealTime:Boolean = true):void
		 {
		 	if(useRealTime)
		 	{
			 	stopSnowmanTimer();
			 	//For some reason this is coming up out of sync with the after
			 	//game report... by exactly one second?
			 	m_TimeLeft = (BunnyConsts.TIME_BETWEEN_ROUNDS-1) * 1000;
			 	m_Timer = new Timer(1000,BunnyConsts.TIME_BETWEEN_ROUNDS);
			 	m_Timer.addEventListener(TimerEvent.TIMER,onTimeLeftUpdate,false,0,true);
				m_Timer.start();
		 	}
		 	else
		 	{
		 		try
				{
					var obj:Object = m_BG;
					// one frame try and wait
					m_BG.addEventListener(Event.ENTER_FRAME, onTryTwiceFrame);
					var frameCount:int = 0;
					// Flash is being really stupid.
					function onTryTwiceFrame(ev:Event):void
					{
						frameCount++;
						if(frameCount > 5)
						{
							m_BG.removeEventListener(Event.ENTER_FRAME, onTryTwiceFrame);
						}
						obj.setSnowManDialog("Next invasion starts soon!");
					}	
				}
				catch(e:Error)
				{
				}
		 	}
		 }
		 public function stopSnowmanTimer():void
		 {
		 	if(m_Timer != null)
			{
				m_Timer.removeEventListener(TimerEvent.TIMER,onTimeLeftUpdate);
				m_Timer.stop();
				m_Timer = null;
			}
		 }
		 public function onTimeLeftUpdate(ev:TimerEvent):void
		 {
		 	try
			{
				
				m_TimeLeft -= 1000;
				var leftSeconds:int = m_TimeLeft/1000;
				var obj:Object = m_BG;
				
				if(leftSeconds <= 0)
				{
					obj.setSnowManDialog("Next invasion starts soon!");
				}
				else
				{
					obj.setSnowManDialog(leftSeconds + " seconds until next invasion");
				}
			}
			catch(e:Error)
			{
				//trace(e.getStackTrace());
				if(m_Timer != null)
				{
					m_Timer.removeEventListener(TimerEvent.TIMER,onTimeLeftUpdate);
				}
			}
		 }
		 
		 public function get minAvatarHeight():int
		 {
		 	return m_MinAvatarHeight;
		 }
		 
		 public function starExitVisibility(isVisible:Boolean):void
		 {
		 	var mc:Sprite = m_BG.getChildByName("starArrow2") as Sprite;
			 if(mc != null)
			 {
			 	mc.visible = mc.mouseChildren = mc.mouseEnabled = isVisible; 
			 }
			 mc = m_BG.getChildByName("balloon2") as Sprite;
			 if(mc != null)
			 {
			 	mc.visible = mc.mouseChildren = mc.mouseEnabled = isVisible; 
			 }
			 mc = m_BG.getChildByName("inst_RoomSelect") as Sprite;
			 if(mc != null)
			 {
			 	mc.visible = mc.mouseChildren = mc.mouseEnabled = isVisible; 
			 }
		 }
		 
		 private var m_DebugClickShow:Sprite;
		 private var m_StartClicks:int;
		 private var m_EndClicks:int;
		 private var m_DebugText:TextField;
		 
		 public function DEBUGInit():void
		 {
		 	/*if(m_DebugClickShow == null)
		 	{
		 		m_DebugClickShow = new Sprite();
		 		m_BG.addChild(m_DebugClickShow);
		 		m_DebugClickShow.x = 200;
		 		// clicking on it causes debug to come up
		 		m_DebugClickShow.addEventListener(MouseEvent.CLICK,onDebugClick);
		 		
		 		m_DebugText = new TextField();
		 		m_DebugText.autoSize = "left";
		 		m_DebugText.x = 300;
		 		m_DebugText.background = true;
		 		m_DebugText.backgroundColor = 0xFF0000;
		 		m_DebugText.width = 500;
		 		m_BG.addChild(m_DebugText);
		 		
		 		m_DebugText.multiline = true;
		 		m_DebugText.wordWrap = true;
		 		m_DebugText.text = "sfadsdfafsdafseads sdfsaf";
		 		m_DebugText.visible = false;
		 	}
		 	m_StartClicks = 0;
		 	m_EndClicks = 0;
		 	
		 	function onDebugClick(ev:Event):void
		 	{
		 		DEBUGShow();
		 	}*/
		 }
		 //change color and add to start time
		 public function DEBUGShootAccepted():void
		 {
		 	/*m_DebugClickShow.graphics.clear();
		 	m_DebugClickShow.graphics.beginFill((uint)(0xFFFFFF * Math.random()));
		 	m_DebugClickShow.graphics.drawRect(0,0,40,40);
		 	m_DebugClickShow.graphics.endFill();
		 	
		 	m_StartClicks++;*/
		 }
		 public function DEBUGShootGotBack():void
		 {
		 	/*m_EndClicks++;*/
		 }
		 public function DEBUGShow():void
		 {
		 	// Print out. Determine averages.
		 	// actually toggles

		 	/*var str:String = "";
		 	str = "Total Sent: " + m_StartClicks.toString() + "\n";
		 	str = str + "Total Received: " + m_EndClicks.toString() + "\n";
		 	
		 	m_DebugText.visible = !m_DebugText.visible;
		 	
		 	m_DebugText.text = str;*/
		 	
		 }

	}
}