package com.sdg.events
{
	import flash.events.Event;

	public class SDGAnimationEvent extends Event
	{
		public static const ANIMATION_COMPLETE:String = 'animationComplete';
		public static const ANIMATION_START:String = 'animationStart';
		public static const ANIMATION_STOP:String = 'animationStop';
		
		public function SDGAnimationEvent(type:String)
		{
			super(type);
		}
	}
}