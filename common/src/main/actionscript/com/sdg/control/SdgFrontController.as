package com.sdg.control
{	
	
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.FrontController;
	import com.sdg.commands.*;
	import com.sdg.events.*;
	import flash.events.Event;
	import mx.core.mx_internal;
	import mx.core.UIComponent;
	
	public class SdgFrontController extends FrontController
	{
		private static var _instance:SdgFrontController;
		
		public static function getInstance():SdgFrontController
		{
			if (!_instance) _instance = new SdgFrontController();
			return _instance;
		}
		
		public function SdgFrontController()
		{
			if (_instance)
				throw new Error("SdgFrontController is a singleton. Use 'getInstance()' to access the instance.");
		}
		
		//--------------------------------------------------------------------------
		//
		//  Hack to enable standard dispatchEvent() for CairngormEvent
		//
		//--------------------------------------------------------------------------
		
		/** Create the dispatch event hook when the Application is created. */
		private static var dispatchEventHooked:Boolean = hookDispatchEvent();
		
		/**
		 * Add a hook into dispatchEvent high up in the inheritance chain.  Any
		 * subclass of UIComponent is now "CairngormEvent-aware" and no longer
		 * needs separate event dispatching code for Cairngorm events.
		 */
		private static function hookDispatchEvent():Boolean
		{
		 	UIComponent.mx_internal::dispatchEventHook = cairngormDispatchEventHook;

		 	return true;
		}

		/**
		 * The event hook itself.  Any time we encounter a CairngormEvent, we
		 * dispatch it through the centralized CairngormEventDispatcher.  This
		 * abstraction prevents subclasses from having to know how to deal with
		 * Cairngorm events.
		 */
		private static function cairngormDispatchEventHook(event:Event, uic:UIComponent):void
		{
		 	if ( event is CairngormEvent )
		 	{
		  		CairngormEventDispatcher.getInstance().dispatchEvent(event as CairngormEvent);
		  	}
		}
	}

}