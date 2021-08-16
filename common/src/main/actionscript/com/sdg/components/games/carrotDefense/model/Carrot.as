package com.sdg.components.games.carrotDefense.model
{
	
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.display.render.RenderData;
	import com.sdg.display.render.RenderObject;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.media.Sound;
	import flash.utils.Timer;
	
	public class Carrot extends BunnyDefenseModelBase
	{
		public static var SFX_SHOWCARROT:Class = null;
		
		private var m_DoneFunc:Function = null;
		
		private var m_Timer:Timer;
		private var m_WasClicked:Boolean;
		private var m_Snd:Sound;
		public function Carrot(CarrotClass:Class,doneFunc:Function)
		{
			m_Sprite = new CarrotClass();
			var rd2:RenderData = new RenderData(m_Sprite);
			m_RO = new RenderObject(rd2);
			
			m_DoneFunc = doneFunc;
			
			m_Sprite.addEventListener(MouseEvent.CLICK,onGetCarrotClick,false,0,true);
			m_Sprite.mouseChildren = false;
			m_Sprite.buttonMode = true;
			m_WasClicked = false;
			
			m_Timer = new Timer(3000,1);
		 	m_Timer.addEventListener(TimerEvent.TIMER,onCarrotFadeStart);
		 	m_Timer.start();
		 	
		 	m_Sprite.addEventListener(MouseEvent.MOUSE_OVER,onCarrotOver,false,0,true);
		 	m_Sprite.addEventListener(MouseEvent.MOUSE_OUT,onCarrotOut,false,0,true);
		 	
		 	if(SFX_SHOWCARROT != null)
			{
				m_Snd = new SFX_SHOWCARROT();
				m_Snd.play();
			}
		}
		
		
		public override function destroy():void
		{
			super.destroy();
			m_Timer.stop();
			m_Timer.removeEventListener(TimerEvent.TIMER,onCarrotFadeStart);
			m_Timer = null;
			m_Snd = null;
		}
		
		private function onCarrotFadeStart(ev:Event):void
		{
			if(!m_WasClicked)
			{
				m_AnimMan.alpha(m_Sprite,0,750);
				m_AnimMan.addEventListener(AnimationEvent.FINISH,onAnimDone);
			}
		}
		private function onAnimDone(ev:Event):void
		{
			if(m_DoneFunc != null)
			{
				m_AnimMan.removeEventListener(AnimationEvent.FINISH,onAnimDone);
				m_DoneFunc(this,m_WasClicked);
			}
		}
		private function onGetCarrotClick(ev:Event):void
		{
			if(m_DoneFunc != null)
			{
				m_Sprite.alpha = 1;
				// Do a lerp up!
				m_AnimMan.removeAll();
				m_AnimMan.move(m_Sprite,300,10,750);
				m_AnimMan.scale(m_Sprite,0.2,0.2,750);
				m_WasClicked = true;
				m_AnimMan.addEventListener(AnimationEvent.FINISH,onAnimDone);
				m_Snd.play();
			}
		}
		
		private function onCarrotOver(ev:Event):void
		{
			m_Sprite.filters = [new GlowFilter(0xFFCC00,1,12,12)];
		}
		private function onCarrotOut(ev:Event):void
		{
			m_Sprite.filters = [];
		}

	}
}