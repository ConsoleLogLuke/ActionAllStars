package com.sdg.store.item
{
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.model.ObjectCollection;
	
	import flash.display.DisplayObject;

	public class StoreItemViewCollection extends ObjectCollection
	{
		public function StoreItemViewCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):IStoreItemView
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:IStoreItemView):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:IStoreItemView):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:IStoreItemView):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromItemId(id:int):IStoreItemView
		{	
			var i:int = 0;
			var len:int = _data.length;
			var item:IStoreItemView;
			for (i; i < len; i++)
			{
				item = _data[i] as IStoreItemView;
				if (item.itemId == id) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
		/**
		 * Creates new display object collection, returns it.
		 */
		public function toDisplayObjectCollection():DisplayObjectCollection
		{
			var i:uint = 0;
			var len:uint = _data.length;
			var collection:DisplayObjectCollection = new DisplayObjectCollection();
			for (i; i < len; i++)
			{
				var display:DisplayObject = _data[i] as DisplayObject;
				if (display != null) collection.push(display);
			}
			return collection;
		}
		
	}
}