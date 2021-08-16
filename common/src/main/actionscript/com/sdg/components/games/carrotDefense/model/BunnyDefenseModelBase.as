package com.sdg.components.games.carrotDefense.model
{
	import com.boostworthy.animation.management.AnimationManager;
	import com.sdg.display.render.RenderObject;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	
	public class BunnyDefenseModelBase
	{
		protected var m_AnimMan:AnimationManager;
		protected var m_RO:RenderObject;
		protected var m_Sprite:Sprite;
		private var m_Depth:int;
		
		public function BunnyDefenseModelBase()
		{
			m_AnimMan = new AnimationManager();
		}
		
		public function getRenderObject():RenderObject
		{
			return m_RO;
		}
		public function get display():DisplayObject
		{
			return m_Sprite;
		}
		
		public function destroy():void
		{
			if(m_AnimMan != null)
			{
				m_AnimMan.removeAll();
				m_AnimMan = null;
			}
		}
		
		public function get depth():int
		{
			return m_Depth;
		}
		public function set depth(val:int):void
		{
			m_Depth = val;
		}
	}
}