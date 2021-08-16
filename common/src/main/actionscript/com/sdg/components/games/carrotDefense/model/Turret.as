package com.sdg.components.games.carrotDefense.model
{
	import com.sdg.components.games.carrotDefense.BunnyConsts;
	import com.sdg.display.render.RenderData;
	import com.sdg.display.render.RenderObject;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Turret extends BunnyDefenseModelBase
	{
		
		public static var MC_THROW_RANGE:Class;
		private var m_AvatarId:uint;
		
		private var m_Hits:int;
		private var m_Kills:int;
		private var m_Carrots:int;
		
		private var m_IsLocal:Boolean;
		private var m_Degrees:int;
		private var m_SnowmanAnim:MovieClip;
		// These need to update.
		public function Turret(ClassTurret:Class,avatarId:uint,xPos:int,yPos:int,isLocal:Boolean = true,labelName:String = "noLabel")
		{
			// Hardcoded offset to keep stuff consistent
			xPos -= 92;
			yPos -= 100;
			//numX:91.19999999999999
			//numY:99.6
			
			m_SnowmanAnim = new ClassTurret();
			m_IsLocal = isLocal;
			m_AvatarId = avatarId;

			m_Sprite = new Sprite();
			m_Sprite.mouseEnabled = false;
			m_Sprite.mouseChildren = false;
			m_Sprite.x = xPos + BunnyConsts.THROW_RANGE/2;
		 	m_Sprite.y = yPos + BunnyConsts.THROW_RANGE/2;
		 	
		 	
		 	var rangeCircleColor:uint = 0x0000FF;
			var alpha:Number = 0;
			if(!isLocal)
			{
				rangeCircleColor = 0xFF0000;
				alpha = 0;
			}
			var s:Sprite = new Sprite();
		 	s.graphics.beginFill(rangeCircleColor,alpha);
		 	s.graphics.drawCircle(0,0,BunnyConsts.THROW_RANGE);
		 	s.graphics.endFill();
		 	s.mouseEnabled = false;
		 	s.mouseChildren = false;
		 	m_Sprite.addChild(s);
		 	m_SnowmanAnim.x = -m_SnowmanAnim.width/2;
		 	m_SnowmanAnim.y = -m_SnowmanAnim.height/2;
			m_Sprite.addChild(m_SnowmanAnim);
			
			m_Sprite.mouseEnabled = false;
			
			if(!m_IsLocal)
			{
				var lbl:TextField = new TextField();
				
				lbl.y = 40;
				lbl.selectable = false;
				lbl.mouseEnabled = false;
				
				var fmt:TextFormat = new TextFormat('EuroStyle',16,0xFFFFFF,true);
				lbl.embedFonts = true;
				lbl.defaultTextFormat = fmt;
				lbl.text = labelName;
				lbl.filters = [new GlowFilter(0,1,6,6,8)];
				lbl.x = -m_SnowmanAnim.width/2;
				lbl.width = 500;
				lbl.setTextFormat(fmt);
				m_Sprite.addChild(lbl);
			}
			var rd2:RenderData = new RenderData(m_Sprite);
			m_RO = new RenderObject(rd2);
			
			/*var simEnt:SimEntity = new RoomEntity();
			//var sim4:SimData = new SimData();
			simEnt.x = m_Sprite.x;
			simEnt.y = m_Sprite.y;
			var simRO:SimRenderObject = new SimRenderObject(m_Sprite);
			simRO.entity = simEnt;
			
			m_RO = simRO;*/
			
			stopChildren(m_SnowmanAnim);
			
			m_Degrees = 0;
			

		 	m_Hits = 0;
		 	m_Kills = 0;
		 	m_Carrots = 0;

		 	if(MC_THROW_RANGE != null && isLocal)
		 	{
		 		var range:Sprite = new MC_THROW_RANGE();
		 		range.mouseEnabled = false;
		 		// the snowman has a weird offset...
		 		//range.x = -range.width/2 + 36;
		 		range.x = -range.width/2;
		 		range.y = -range.height/2;
		 		m_Sprite.addChild(range);
		 	}
		 	
		}
		
		public function get turretDisplay():Sprite
		{
			return m_SnowmanAnim;
		}
		
		private function stopChildren(mc:MovieClip):void
		{
			for(var i:int = 0; i < mc.numChildren; ++i)
			{
				var child:MovieClip = mc.getChildAt(i) as MovieClip;
				if(child != null)
				{
					child.stop();
					stopChildren(child);
				}
			}
		}
		
		public function get centerPt():Point
		{
			return new Point(display.x,display.y);
			//return new Point(display.x + 150,display.y + 150);
			//return new Point(display.x + display.width/4,display.y + display.height/4)
		}
		
		public function get hits():int
		{
			return m_Hits;
		}
		public function set hits(val:int):void
		{
			m_Hits = val;
		}
		public function get kills():int
		{
			return m_Kills;
		}
		public function set kills(val:int):void
		{
			m_Kills = val;
		}
		public function get carrots():int
		{
			return m_Carrots;
		}
		public function set carrots(val:int):void
		{
			m_Carrots = val;
		}
		
		public function get isLocal():Boolean
		{
			return m_IsLocal;
		}
		
		public function get avatarId():uint
		{
			return m_AvatarId;
		}
		
		public function startThrowAnimation():void
		{
			var frameNames:Array = ["east","southeast","south","southwest","west","northwest","north","northeast"];
			var currIndex:int = Math.floor(m_Degrees/45);
			m_SnowmanAnim.gotoAndPlay(frameNames[currIndex]);
			//trace("Playing Throw Anim: " + frameNames[currIndex]);
		}
		
		public function updateDirection(degrees:int):void
		{
			//trace("Update to: " + degrees);
			if(degrees < 0)
			{
				degrees += 360;
			}
			m_Degrees = degrees;
			// 0 is to right, 90 is down.
			var frameNames:Array = ["east","southeast","south","southwest","west","northwest","north","northeast"];
			
			var currIndex:int = Math.floor(degrees/45);
			var thisLbl:String = frameNames[currIndex] + "Stop";
			var currentLbl:String = m_SnowmanAnim.currentLabel;
			if(thisLbl != currentLbl &&
				frameNames[currIndex] != currentLbl)
			{
				m_SnowmanAnim.gotoAndStop(thisLbl);
			}
		}
	}
}