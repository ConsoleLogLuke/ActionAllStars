package com.sdg.components.controls
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarLabelPlacement;
	
	[Style(name="progressBarStyleName", type="String", inherit="no")]
	
	[Bindable]
	public class ProgressAlert extends SdgAlert
	{
		public static const CANCEL:int = SdgAlert.CANCEL;
		public static const COMPLETE:int = 0x80;
		
		protected var progressBar:ProgressBar;
		
		override public function set label(value:String):void
		{
			progressBar.label = value;
		}
		
		override public function get label():String
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
		public static function show(message:String = "", title:String = "", label:String = null,
									source:Object = null, indeterminate:Boolean = false, 
									showCancelButton:Boolean = false, closeHandler:Function = null, 
									parent:Sprite = null, modal:Boolean = true):ProgressAlert
		{
			var alert:ProgressAlert = new ProgressAlert();
			
			alert.message = message;
			alert.title = title;
			alert.source = source;
			alert.indeterminate = indeterminate;
			alert.label = label;
			alert.buttonFlags = showCancelButton ? SdgAlert.CANCEL : 0;
			alert.show(closeHandler, parent, modal);
			
			return alert;
		}
		
		/**
		 * Constructor.
		 */
		public function ProgressAlert()
		{
			progressBar = new ProgressBar();
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			if (styleProp == null || styleProp == "styleName" || styleProp == "progressBarStyleName")
			{
				progressBar.styleName = getStyle("progressBarStyleName");
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (!progressBar.parent)
			{
				progressBar.percentWidth = 100;
				progressBar.labelPlacement = ProgressBarLabelPlacement.CENTER;
				progressBar.addEventListener(Event.COMPLETE, completeHandler);
				addChild(progressBar);
			}
		}
		
		protected function completeHandler(event:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
			addEventListener(Event.ENTER_FRAME, closeLaterHandler);
		}
		
		protected function closeLaterHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, closeLaterHandler);
			close(ProgressAlert.COMPLETE);
			progressBar.removeEventListener(Event.COMPLETE, completeHandler);
		}
	}
}