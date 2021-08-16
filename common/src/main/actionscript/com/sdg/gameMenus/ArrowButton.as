package com.sdg.gameMenus
{
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	public class ArrowButton extends Sprite
	{
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		
		protected var _width:Number;
		protected var _height:Number;
		
		public function ArrowButton(direction:String, width:Number, height:Number, arrowWidth:Number, arrowHeight:Number)
		{
			super();
			_width = width;
			_height = height;
			
			graphics.lineStyle(1, 0xffffff);
			graphics.beginFill(0x172D54);
			graphics.drawRect(.5, .5, _width-1, _height-1);
			
			var arrow:Sprite = new Sprite();
			arrow.graphics.beginFill(0xffffff);
			if (direction == LEFT)
			{
				arrow.graphics.moveTo(arrowWidth, 0);
				arrow.graphics.lineTo(0, arrowHeight/2);
				arrow.graphics.lineTo(arrowWidth, arrowHeight);
			}
			else if (direction == RIGHT)
			{
				arrow.graphics.moveTo(0, 0);
				arrow.graphics.lineTo(arrowWidth, arrowHeight/2);
				arrow.graphics.lineTo(0, arrowHeight);
			}
			
			arrow.filters = [new DropShadowFilter(2, 45)];
			arrow.x = _width/2 - arrow.width/2;
			arrow.y = _height/2 - arrow.height/2;
			addChild(arrow);
			
			this.filters = [new DropShadowFilter(2, 45)];
		}
		
		public function set enabled(value:Boolean):void
		{
			this.mouseEnabled = value;
			if (value)
				this.alpha = 1;
			else
				this.alpha = .5;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;
		}
	}
}