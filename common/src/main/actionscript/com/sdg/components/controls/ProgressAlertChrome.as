package com.sdg.components.controls
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarLabelPlacement;
	
	public class ProgressAlertChrome extends SdgAlertChrome
	{
		protected var progressBar:ProgressBar;
		private var expireTimer:Timer;
		
		public function set label(value:String):void
		{
			progressBar.label = value;
		}
		
		public function get label():String
		{
			return progressBar.label;
		}
		
		public function get indeterminate():Boolean
    	{
        	return progressBar.indeterminate;
    	}
		
		public function set indeterminate(value:Boolean):void
    	{
        	progressBar.indeterminate = value;
    	}
    	
		public function set source(value:Object):void
		{
			progressBar.source = value;
		}
		
		public function get source():Object
		{
			return progressBar.source;
		}
		
		/**
		 * Static show method.
		 */
		public static function show(message:String, title:String, label:String = null, source:Object = null, indeterminate:Boolean = false,
									closeHandler:Function = null, parent:Sprite = null,	modal:Boolean = true,
									cancelButton:Boolean = false, width:int = 430, height:int = 200, expireTime:int = 30000):ProgressAlertChrome
		{
			var alert:ProgressAlertChrome = new ProgressAlertChrome(message, title, cancelButton, width, height, expireTime);
			
			alert.source = source;
			alert.indeterminate = indeterminate;
			alert.label = label;
			
			alert.show(closeHandler, parent, modal);
			
			alert.startTimer();
			
			return alert;
		}
		
		/**
		 * Constructor.
		 */
		public function ProgressAlertChrome(message:String, title:String, cancelButton:Boolean, width:int, height:int, expireTime:int = 30000)
		{
			super(message, title, false, width, height, null, null);
			
			progressBar = new ProgressBar();
			this.addChild(progressBar);
			progressBar.width = width - 60;
			progressBar.height = 27;
			progressBar.setStyle("borderStyle", "solid");
			progressBar.setStyle("borderThickness", 10);
			progressBar.setStyle("borderColor", "#7ca4da");
			progressBar.x = width/2 - progressBar.width/2;
			progressBar.y = height - progressBar.height - 50;
			progressBar.labelPlacement = ProgressBarLabelPlacement.CENTER;
			progressBar.addEventListener(Event.COMPLETE, completeHandler);
			
			expireTimer = new Timer(expireTime,0);
		}
		
		protected function completeHandler(event:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
			addEventListener(Event.ENTER_FRAME, closeLaterHandler);
		}
		
		protected function closeLaterHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, closeLaterHandler);
			close();
			progressBar.removeEventListener(Event.COMPLETE, completeHandler);
		}
		
		// TIMER CODE
		
		protected function startTimer():void
		{
			expireTimer.addEventListener(TimerEvent.TIMER, timerClose);
			expireTimer.start();
		}
		
		protected function timerClose(e:TimerEvent):void
		{
			expireTimer.removeEventListener(TimerEvent.TIMER, timerClose);
			expireTimer.stop();
			close();
			progressBar.removeEventListener(Event.COMPLETE, completeHandler);
		}
	}
}