package com.sdg.components.controls
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.events.*;
	import mx.preloaders.*;

    
    public class DownloadProgressBar extends Sprite 
        implements IPreloaderDisplay
    {
        // Define a Loader control to load the SWF file.
        protected var dpbImageControl:flash.display.Loader;
		
		private var mcBar:MovieClip;    	 

        public function DownloadProgressBar() {   
            super();        
        }
        
        // Specify the event listeners.
        public function set preloader(preloader:Sprite):void {
            // Listen for the relevant events
            preloader.addEventListener(
     	       ProgressEvent.PROGRESS, handleProgress); 
            preloader.addEventListener(
                Event.COMPLETE, handleComplete);
    
            preloader.addEventListener(
                FlexEvent.INIT_PROGRESS, handleInitProgress);
            preloader.addEventListener(
                FlexEvent.INIT_COMPLETE, handleInitComplete);
        }
        
        // Initialize the Loader control in the override 
        // of IPreloaderDisplay.initialize().
        public function initialize():void {
            dpbImageControl = new flash.display.Loader();       
            dpbImageControl.contentLoaderInfo.addEventListener(
            Event.COMPLETE, loader_completeHandler);
            dpbImageControl.load(new URLRequest('assets/swfs/preloader.swf'));
            
            // scaling
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_BORDER;
        } 

        // After the SWF file loads, set the size of the Loader control.
        protected function loader_completeHandler(event:Event):void
        {
            mcBar = (event.target.content as MovieClip );
            addChild(mcBar);
	        mcBar.x = 0; //(root.parent.stage.stageWidth / 2 ) - (mcBar.width / 2);
	        mcBar.y = 0; //(root.parent.stage.stageHeight / 2) - (mcBar.height / 2);
          }   

        // Define empty event listeners.
        private function handleProgress(event:ProgressEvent):void {

	       	var ticker:int;
	       	// the progressloader starts firing events right away
	       	// before the swf is loaded, we cannot post a gotoAndPlay until we have valid child
	       	// to do  - ideally we should turn off the ProgressEvent posting until we get the load
	       	// I tried that to no vail - ask Jessie or Lance after beta.
	       	
//	   		trace( "handleProgress - loaded " + event.bytesLoaded + " total " + event.bytesTotal  );
	       	
   			if( mcBar != null ) // do we have an instance?
			{		       	
	   		 	ticker = uint( (event.bytesLoaded * 100 / event.bytesTotal) );
//	   		 	trace( "ticker = " + ticker );
  	   		    mcBar.gotoAndStop(ticker);
  			}
        }
        
        private function handleComplete(event:Event):void {
        }
        
        private function handleInitProgress(event:Event):void {
        }
        
        private function handleInitComplete(event:Event):void {
            var timer:Timer = new Timer(2000,1);
            timer.addEventListener(TimerEvent.TIMER, dispatchComplete);
            timer.start();      
        }
    
        private function dispatchComplete(event:TimerEvent):void {
            dispatchEvent(new Event(Event.COMPLETE));
        }

        // Implement IPreloaderDisplay interface
    
        public function get backgroundColor():uint {
            return 0;
        }
        
        public function set backgroundColor(value:uint):void {
        }
        
        public function get backgroundAlpha():Number {
            return 0;
        }
        
        public function set backgroundAlpha(value:Number):void {
        }
        
        public function get backgroundImage():Object {
            return undefined;
        }
        
        public function set backgroundImage(value:Object):void {
        }
        
        public function get backgroundSize():String {
            return "";
        }
        
        public function set backgroundSize(value:String):void {
        }
    
        public function get stageWidth():Number {
         return 200;
   		}
        
        public function set stageWidth(value:Number):void {
       }
        
        public function get stageHeight():Number {
           return 200;
       }
        
        public function set stageHeight(value:Number):void {
        }
    }

}// ActionScript file
