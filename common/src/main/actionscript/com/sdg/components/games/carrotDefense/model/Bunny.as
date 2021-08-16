package com.sdg.components.games.carrotDefense.model
{
	import com.boostworthy.animation.management.AnimationManager;
	import com.sdg.display.render.RenderData;
	import com.sdg.display.render.RenderObject;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.utils.getTimer;
	
	/**
	 * @author molly.jameson
	 */
	public class Bunny extends BunnyDefenseModelBase
	{
		public static var MC_POOF:Class = null;
		public static var MC_SPLAT:Class = null
		public static var MC_LIFEBAR:Class = null;
		
		public static var SFX_LOCALKILL:Class = null;
		public static var SFX_SNOWBALLHIT:Class = null;
		
		private var m_DoneFunc:Function = null;
		private var m_BunnyNumber:int;
		private var m_HP:int;
		
		private var m_Path:Array;
		private var m_CurrPathIndex:int;
		private var m_StartTimeDelta:Number;
		private var m_HasSpawned:Boolean;
		
		private var m_HealthBar:MovieClip;
		private var m_MaxHP:int;
		private var m_IsStartOfWave:Boolean = false;
		private var m_IsDead:Boolean;
		private var m_BunnyMC:MovieClip;
		private var m_LastHitLocal:Boolean;
		
		private var m_LastFrameTime:int;
		
		public function Bunny(BunnyClass:Class,bunnyNumber:int,startTimeDelta:Number,hp:int = 3)
		{
			m_BunnyMC = new BunnyClass();
			m_Sprite = new Sprite();
			m_Sprite.addChild(m_BunnyMC);
			m_Sprite.mouseEnabled = false;
			m_Sprite.mouseChildren = false;
			m_AnimMan = new AnimationManager();
			
			var rd2:RenderData = new RenderData(m_Sprite);
			m_RO = new RenderObject(rd2);
			
			//var sim:SimRenderData = new SimRenderData(m_Sprite);
			
			/*var simEnt:SimEntity = new RoomEntity();
			//var sim4:SimData = new SimData();
			var simRO:SimRenderObject = new SimRenderObject(m_Sprite);
			simRO.entity = simEnt;
			
			m_RO = simRO;*/
			
			
			m_BunnyNumber = bunnyNumber;
			m_CurrPathIndex = 0;
			m_MaxHP = m_HP = hp;
			
			//trace("Bunny Num: " +bunnyNumber  + "MAX HP: " + m_MaxHP);
			m_StartTimeDelta = startTimeDelta;
			
			m_Sprite.visible = false;
			m_HasSpawned = false;
			m_IsDead = false;
			m_LastHitLocal = false;
			
			m_HealthBar = new MC_LIFEBAR();
			m_HealthBar.gotoAndStop(1);
			m_HealthBar.x  = -m_Sprite.width;
			m_HealthBar.y = -5;
			updateHealthBar();
			m_Sprite.addChild(m_HealthBar);
			
			m_BunnyMC.gotoAndPlay("down");
			
			// left path
			if(m_BunnyNumber % 2 == 0)
			{
				m_Path = [
						new Point(220,196),
						new Point(177,305),
						new Point(580,305),
						new Point(550,425),
						new Point(180,430),
						new Point(150,570),
						new Point(613,570),
						new Point(580,720),
						];
			}
			else
			{
				m_Path = [
						new Point(730,185),
						new Point(725,305),
						new Point(580,305),
						new Point(550,425),
						new Point(180,430),
						new Point(150,570),
						new Point(613,570),
						new Point(580,720),
						];
			}
		}
		
		public function get bunnyID():int
		{
			return m_BunnyNumber;
		}
		
		public function get spawnTime():Number
		{
			return m_StartTimeDelta;
		}
		public function getHasSpawned():Boolean
		{
			return m_HasSpawned;
		}
		
		public function set lastHitLocal(val:Boolean):void
		{
			m_LastHitLocal = val;
		}
		
		public function get HP():int
		{
			return m_HP;
		}
		public function set HP(health:int):void
		{
			if(health <= 0)
			{
				//DIE
				if(m_HP > 0)
				{
					playPainAnim(MC_POOF,true);
					
					m_BunnyMC.visible = false;
					m_AnimMan.removeAll();
					if(m_LastHitLocal)
					{
						var pt:Point = m_HealthBar.globalToLocal(new Point(500,10));
						m_AnimMan.move(m_HealthBar,pt.x,pt.y,750);
						m_AnimMan.scale(m_HealthBar,0.2,0.2,750);
					}
				}
				m_HP = health;
			}
			else
			{
				if(m_HP > health)
				{
					playPainAnim(MC_SPLAT);
					if(SFX_SNOWBALLHIT != null)
					{
						var snd:Sound = new SFX_SNOWBALLHIT();
						snd.play();
					}
				}
				m_HP = health;
				updateHealthBar();
			}
		}
		
		public function playLocalKillSound():void
		{
			if(SFX_LOCALKILL != null)
			{
				var snd:Sound = new SFX_LOCALKILL();
				snd.play();
			}
		}
		
		public function playPainAnim(AnimClass:Class,killOnEnd:Boolean = false):void
		{
			var poof:MovieClip = new AnimClass();
			poof.x = -poof.width/2;
			poof.y = -poof.height/2;
			m_Sprite.addChild(poof);
			poof.addEventListener(Event.ENTER_FRAME,onFrame);
			var that:Bunny = this;

			function onFrame(ev:Event):void
			{
				if(poof.currentFrame == poof.totalFrames)
				{
					m_Sprite.removeChild(poof);
					poof.removeEventListener(Event.ENTER_FRAME,onFrame);
					if(killOnEnd)
					{
						if(m_DoneFunc != null)
						{
							m_DoneFunc(that,false);
						}
					}
				}
			}
		}
		
		
		public function get startOfWave():Boolean
		{
			return m_IsStartOfWave;
		}
		public function set startOfWave(val:Boolean):void
		{
			m_IsStartOfWave = val;
		}
		
		public function get isDead():Boolean
		{
			return m_IsDead;
		}
		public function set isDead(val:Boolean):void
		{
			m_IsDead = val;
		}
		
		public function startPath(doneFunc:Function,currentTime:Number):void
		{
			
			m_DoneFunc = doneFunc;
			
			m_Sprite.visible = true;
			m_HasSpawned = true;
			initLerpInfo(currentTime,spawnTime);
			//trace("Spawned new bunny2: " + spawnTime + " currTime: " + currentTime);
		}
		
		private function getTimeBetweenPoints(index0:int,index1:int):Number
		{
			var oldPt:Point = m_Path[index0];
			var newPt:Point = m_Path[index1];
			var distance:Number = Point.distance(oldPt,newPt);
			var PIXELS_PER_SECOND:Number = 150;
			//var PIXELS_PER_SECOND:Number = 50;
			// 100 pps * Y s = X pixels; -> Y s = X /100
			var timeToTravel:Number = distance/PIXELS_PER_SECOND;
			//trace("TIME TO TRAVEL: " + timeToTravel + " over " + distance + " pixels");
			//trace(distance + " pixels"  + " over " + timeToTravel + " seconds");
			return timeToTravel * 1000;
		}
		
		private var m_Times:Array;
		private var m_CurrentTime:Number;
		private function initLerpInfo(currentTime:Number,spawnTime:Number):void
		{
			//Init the points in the path and the current time
			// All we
			m_Times = new Array();
			var prevTime:Number = spawnTime;
			m_CurrentTime = currentTime;
			for(var i:int = 0; i < m_Path.length-1;++i)
			{
				m_Times.push(prevTime);
				var timeToTravel:Number = getTimeBetweenPoints(i,i+1);
				prevTime += timeToTravel;
			}
			//Last time is just an end point.
			m_Times.push(prevTime);
			
			m_LastFrameTime = flash.utils.getTimer();
			m_BunnyMC.addEventListener(Event.ENTER_FRAME,onFrameUpdate);
		}
		
		public override function destroy():void
		{
			m_BunnyMC.removeEventListener(Event.ENTER_FRAME,onFrameUpdate);
			super.destroy();
		}
		private var DEBUGLastIndexStart:int = 0;
		private function onFrameUpdate(ev:Event):void
		{
			var now:int = flash.utils.getTimer();
			var frameDelta:int = now - m_LastFrameTime;
			m_LastFrameTime = now;
			
			m_CurrentTime += frameDelta;
			
			var currPathIndex:int = m_CurrPathIndex;
			
			//figure out what segement of the path we're on
			var startIndex:int = 0;
			for(var i:int = 0; i < m_Times.length;++i)
			{
				if(m_CurrentTime >= m_Times[i])
				{
					startIndex = i;
					currPathIndex = i;
				}
			}
			
			if(DEBUGLastIndexStart > startIndex)
			{
				trace("Um... somehow went backwards");
			}
			DEBUGLastIndexStart = startIndex;
			
			if(startIndex >= m_Times.length - 1)
			{
				//only if done with end
				if(m_DoneFunc != null)
				{
					m_DoneFunc(this,true);
				}
			}
			else
			{
				// keep going as normal
				var lastStartTime:int = 0;
				var lastEndTime:int = 0;
				
				
				//need to subtract out the server time.
				var tStart:Number = 0;
				var tEnd:Number = m_Times[startIndex + 1] - m_Times[startIndex];
				var tCurr:Number = m_CurrentTime - m_Times[startIndex];
				var t:Number = tCurr/tEnd;
				
				if(t < 0)
				{
					trace("T is : " + t);
					t = 0;
				}
				if(t > 1)
				{
					trace("T is : " + t);
					t = 1;
				}
				//calculate current position based on tTime.
				var nextPos:Point = new Point();
				nextPos.x = (1 - t) * m_Path[currPathIndex].x + t * m_Path[currPathIndex + 1].x;
				nextPos.y = (1 - t) * m_Path[currPathIndex].y + t * m_Path[currPathIndex + 1].y;
				
				var currPos:Point = new Point(m_Sprite.x,m_Sprite.y);				
				m_Sprite.x = nextPos.x;
				m_Sprite.y = nextPos.y;
				// we've changed direction
				if(m_CurrPathIndex < currPathIndex)
				{
					var dir:Point = new Point(m_Path[currPathIndex+1].x - m_Path[currPathIndex].x, 
												m_Path[currPathIndex+1].y - m_Path[currPathIndex].y);
					m_CurrPathIndex = currPathIndex;
					
					//down
					if(Math.abs(dir.y) > Math.abs(dir.x))
					{
						m_BunnyMC.gotoAndPlay("down");
					}
					else if(dir.x < 0)
					{
						m_BunnyMC.gotoAndPlay("left");
					}
					else
					{
						m_BunnyMC.gotoAndPlay("right");
					}
				}
			}
		}
		
		private function updateHealthBar():void
		{
			var tFill:Number = m_HP / m_MaxHP;
			if(tFill > 0.67)
			{
				m_HealthBar.gotoAndStop("lifeGreen");
			}
			else if(tFill > 0.34)
			{
				m_HealthBar.gotoAndStop("lifeYellow");
			}
			else
			{
				m_HealthBar.gotoAndStop("lifeRed");
			}
		}
		
		private function stopChildren(mc:MovieClip):void
		{
			for(var i:int = 0; i < mc.numChildren; ++i)
			{
				var mcChild:MovieClip = mc.getChildAt(i) as MovieClip;
				if(mcChild != null)
				{
					mcChild.stop();
					stopChildren(mcChild);
				}
			}
		}

	}
}