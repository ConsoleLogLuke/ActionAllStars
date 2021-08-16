package com.sdg.events
{
	import flash.events.Event;

	public class MapCollectionEvent extends Event
	{
		public static const COLLECTION_CHANGE:String = 'collectionChange';
		
		public var kind:String;
		public var location:Object;
		public var oldLocation:Object;
		public var items:Array;
		
		public function MapCollectionEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, kind:String = null, location:Object = null, oldLocation:Object = null, items:Array = null)
		{
			super(type, bubbles, cancelable);
			this.kind = kind;
			this.location = location;
			this.oldLocation = oldLocation;
			this.items = items;
			
			if (!items) this.items = [];
		}
		
		override public function toString():String
		{
			return "[MapCollectionEvent type=" + type + "]";
		}
	}
}