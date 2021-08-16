package com.sdg.components.games.carrotDefense.model
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.display.render.RenderData;
	import com.sdg.display.render.RenderObject;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	
	public class Snowball extends BunnyDefenseModelBase
	{
		public static var MC_SNOWBALL:Class = null;
		public static var SFX_THROW:Class = null;
		public static const SNOWBALL_SPEED:int = 250;
		public function Snowball()
		{
			m_Sprite = getSnowball();
			m_Sprite.mouseEnabled = false;
			var rd2:RenderData = new RenderData(m_Sprite);
			m_RO = new RenderObject(rd2);	
		}
		
		private var m_DoneFunc:Function = null;
		public function startThrow(startX:Number,startY:Number,endX:Number,endY:Number,totalTime:Number = 1000,doneFunc:Function = null):void
		{
			m_Sprite.x = startX;
			m_Sprite.y = startY;
			m_AnimMan.move(m_Sprite,endX,endY,totalTime);
			m_AnimMan.addEventListener(AnimationEvent.FINISH,onLerpDone);
			m_DoneFunc = doneFunc;
			
			if(SFX_THROW != null)
			{
				var snd:Sound = new SFX_THROW();
				snd.play();
			}
		}
		
		private function onLerpDone(ev:Event):void
		{
			if(m_DoneFunc != null)
			{
				m_AnimMan.removeEventListener(AnimationEvent.FINISH,onLerpDone);
				m_AnimMan.alpha(m_Sprite,0,200,Transitions.CUBIC_OUT);
				m_AnimMan.addEventListener(AnimationEvent.FINISH,onFadeDone);
				
			}
		}
		private function onFadeDone(ev:Event):void
		{
			if(m_DoneFunc != null)
			{
				m_AnimMan.removeEventListener(AnimationEvent.FINISH,onFadeDone);
				m_DoneFunc(this);
			}
		}
		
		//This is really the view, I know.
		// This should just be here for the prototype.
		// And really real MVC is kinda overkill for this.
		private function getSnowball():Sprite
		{
			if(MC_SNOWBALL != null)
			{
				return new Snowball.MC_SNOWBALL();
			}
		 	var s:Sprite = new Sprite();
		 	
		 	s.graphics.beginFill(0);
		 	s.graphics.drawCircle(0,0,14);
		 	s.graphics.endFill();
		 	s.graphics.beginFill(0xFFFFFF);
		 	s.graphics.drawCircle(1,1,10);
		 	s.graphics.endFill();
		 	
		 	return s;
		}

	}
}