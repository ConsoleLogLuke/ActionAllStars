package com.sdg.view
{
	import com.sdg.graphics.RayBurst;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;

	public class RayBurstBackground extends Sprite
	{
		protected var _rayBurst:RayBurst;
		protected var _back:Sprite;
		protected var _width:Number;
		protected var _height:Number;
		protected var _backColor1:uint;
		protected var _backColor2:uint;
		protected var _rayMask:Sprite;
		protected var _raySpeed:Number;
		
		public function RayBurstBackground(width:Number, height:Number, rayColor:uint = 0xffffff, rayAlpha:Number = 1, backColor1:uint = 0xaaaaff, backColor2:uint = 0xffffff, raySpeed:Number = 0.5)
		{
			super();
			
			_width = width;
			_height = height;
			_backColor1 = backColor1;
			_backColor2 = backColor2;
			_raySpeed = raySpeed;
			
			_back = new Sprite();
			addChild(_back);
			
			var rayDis:Number = Math.sqrt(Math.pow(_width, 2) + Math.pow(_height, 2)) / 2;
			_rayBurst = new RayBurst(rayDis, 20, rayColor, rayAlpha);
			_rayBurst.cacheAsBitmap = true;
			addChild(_rayBurst);
			
			_rayMask = new Sprite();
			_rayBurst.mask = _rayMask;
			addChild(_rayMask);
			
			render();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		protected function render():void
		{
			var rayDis:Number = Math.sqrt(Math.pow(_width, 2) + Math.pow(_height, 2)) / 2;
			_rayBurst.distance = rayDis;
			_rayBurst.x = _width / 2;
			_rayBurst.y = _height / 2;
			
			// Draw gradient backing.
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			_back.graphics.clear();
			_back.graphics.beginGradientFill(GradientType.LINEAR, [_backColor1, _backColor2], [1, 1], [1, 255], gradMatrix);
			_back.graphics.drawRect(0, 0, _width, _height);
			_back.graphics.endFill();
			
			// Draw ray mask.
			_rayMask.graphics.clear();
			_rayMask.graphics.beginFill(0x00ff00);
			_rayMask.graphics.drawRect(0, 0, _width, _height);
		}
		
		public function destroy():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onEnterFrame(e:Event):void
		{
			// Rotate the burst.
			_rayBurst.rotation += _raySpeed;
		}
		
	}
}