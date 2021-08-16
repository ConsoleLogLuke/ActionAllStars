package com.sdg.core
{
	import flash.events.IEventDispatcher;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	public interface IProgressInfo extends IEventDispatcher
	{
		function get bytesLoaded():uint;
		
		function get bytesTotal():uint;
		
		function get complete():Boolean;
		
		function get pending():Boolean;
	}
}