package com.sdg.view
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	public class FramerateDebugView extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		private var _backing:Sprite;
		private var _frameRateField:TextField;
		private var _frameRate:Number;
		
		public function FramerateDebugView()
		{
			super();
			
			// Default.
			_width = 200;
			_height = 60;
			_frameRate = 0;
			
			_backing = new Sprite();
			addChild(_backing);
			
			_frameRateField = new TextField();
			_frameRateField.defaultTextFormat = new TextFormat('Arial', 12, 0xffffff);
			_frameRateField.autoSize = TextFieldAutoSize.LEFT;
			addChild(_frameRateField);
			
			render();
			
			var timer:Timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		private function render():void
		{
			_backing.graphics.clear();
			_backing.graphics.beginFill(0, 0.5);
			_backing.graphics.drawRect(0, 0, _width, _height);
			
			_frameRateField.x = 10;
			_frameRateField.y = 10;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set frameRate(value:Number):void
		{
			_frameRate = value;
			_frameRateField.text = 'FPS: ' + _frameRate;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onTimer(e:TimerEvent):void
		{
			if (stage != null)
			{
				frameRate = stage.frameRate;
			}
		}
		
	}
}