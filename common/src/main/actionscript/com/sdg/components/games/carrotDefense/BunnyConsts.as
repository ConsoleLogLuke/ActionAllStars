package com.sdg.components.games.carrotDefense
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public final class BunnyConsts
	{
		public static const TEAM_LIFE:int = 20;
		public static const CARROT_DROP_RATE:Number = 0.6;
		public static const THROW_RANGE:Number = 150;
		public static const TIME_BETWEEN_ROUNDS:Number = 31;
		
		public static const BUNNY_HIT:int = 1;
		public static const BUNNY_KILL:int = 2;
		/**
		 * > Bunny Health: 3
>  Team Life: 20
> Waves before winning: 6 waves of 3 bunnies
> Bunny speed: 150 pixels per second
> Carrot chance of spawning: 75% on kill
> Number of milliseconds before you can shoot again: 250 ms
> Throw Range: 150 pixels.

		 */
		public static function getTempText(txt:String,bgColor:uint = 0,txtColor:uint=0xFFFFFF):TextField
		{
			var ret:TextField = new TextField();
			ret.background = true;
			ret.htmlText = txt;
			ret.backgroundColor = bgColor;
			ret.textColor = txtColor;
			ret.autoSize = flash.text.TextFieldAutoSize.LEFT;
			ret.selectable = false;
			return ret;
		}
		
		public static function getTempHitArea(label:String = "Temp",w:Number = 100, h:Number = 100,alpha:Number = 0.5,color:uint = 0):Sprite
		{
			var s:Sprite = new Sprite();
			s.graphics.beginFill(color,alpha);
			s.graphics.drawRect(0,0,w,h);
			s.graphics.endFill();
			
			var tf:TextField = getTempText(label);
			tf.mouseEnabled = false;
			s.addChild(tf);
			
			return s;
		}
		
		public static function getTempButton(txt:String):SimpleButton
		{
			return new SimpleButton(getTempText(txt),getTempText(txt,0xFFFFFF,0),getTempText(txt),getTempText(txt));
		}
		
		/* Math utils*/
		// The angle to the unit vector.
		public static  function vecToAngle(vec:Point):Number
		{
			return Math.atan2(vec.y,vec.x);
		}
		// angle from unitX vector
		public static  function angleToVec(radians:Number):Point
		{
			return new Point(Math.cos(radians),Math.sin(radians));
		}
	}
}