package com.sdg.events
{
	import flash.display.Loader;
	import flash.events.Event;

	public class LoaderQueEvent extends Event
	{
		public static const COMPLETE:String = 'loader complete';
		public static const ERROR:String = 'loader error';
		public static const PROGRESS:String = 'loader progress';
		public static const EMPTY:String = 'loader que emptied';
		
		protected var _loader:Loader;
		protected var _bytesLoaded:uint;
		protected var _bytesTotal:uint;
		
		public function LoaderQueEvent(type:String, loader:Loader, bytesLoaded:uint, bytesTotal:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_loader = loader;
			_bytesLoaded = bytesLoaded;
			_bytesTotal = bytesTotal;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get loader():Loader
		{
			return _loader;
		}
		
		public function get bytesLoaded():uint
		{
			return _bytesLoaded;
		}
		
		public function get bytesTotal():uint
		{
			return _bytesTotal;
		}
		
	}
}