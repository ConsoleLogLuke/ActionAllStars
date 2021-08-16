﻿package com.sdg.collections{	import com.sdg.collections.DLinkedListItem;	import com.sdg.collections.ICollection;	import com.sdg.collections.IIterator;	import flash.errors.IllegalOperationError;	import flash.events.EventDispatcher;		public class DLinkedList extends EventDispatcher implements ICollection	{		private var _head:DLinkedListItem;		private var _tail:DLinkedListItem;				/**		 * Returns the number of items in the list.		 */		public function get size():uint		{			var count:int = 0;			var node:DLinkedListItem = _head;						while (node) count++;						return count;		}			/**		 * Returns whether the list contains any items.		 */		public function get isEmpty():Boolean		{			return _head == null;		}				public function DLinkedList(source:Array = null)		{			if (source)			{				for (var i:int = 0; i < source.length; i++)					addTail(source[i]);			}		}			/**		 * Adds the value to the end of the list and returns the added linked list item.		 */		public function addTail(value:*):DLinkedListItem		{			var item:DLinkedListItem = new DLinkedListItem(value);					if (_tail)			{				item.prev = _tail;				_tail.next = item;			}						_tail = item;					if (!_head) _head = _tail;			return item;		}			/**		 * Adds the value to the front of the list and returns the added linked list item.		 */		public function addHead(value:*):DLinkedListItem		{			var item:DLinkedListItem = new DLinkedListItem(value);						if (_head)			{				item.next = _head;				_head.prev = item;			}						if (!_tail) _tail = item;						_head = item;						return item;		}				/**		 * Adds the value after the specified item and returns the added linked list item.		 */		public function addAfter(item:DLinkedListItem, value:*):DLinkedListItem		{			var newItem:DLinkedListItem = new DLinkedListItem(value);					newItem.next = item.next;			item.next = newItem;					if (item == _tail) _tail = newItem;					return newItem;		}			/**		 * Adds the value before the specified item and returns the added linked list item.		 */		public function addBefore(item:DLinkedListItem, value:*):DLinkedListItem		{			var newItem:DLinkedListItem = new DLinkedListItem(value);			var prev:DLinkedListItem = item.prev;					prev.next = newItem;				newItem.next = item;					if (item == _head) _head = newItem;			return newItem;		}				/**		 * Returns whether the value exists.		 */		public function contains(value:*):Boolean		{			var item:DLinkedListItem = _head;					while (item)			{				if (item.data == value) return true;				item = item.next;			}					return false;		}				/**		 * Returns the value at the end of the list.		 */		public function getTail():*		{			return _tail ? _tail.data : null;		}			/**		 * Returns the value at the front of the list.		 */		public function getHead():*		{			return _head ? _head.data : null;		}			/**		 * Returns the item at the end of the list.		 */		public function getTailItem():DLinkedListItem		{			return _tail;		}			/**		 * Returns the item at the front of the list.		 */		public function getHeadItem():DLinkedListItem		{			return _head;		}			/**		 * Returns the item that wraps the specified value.		 */		public function getItemContaining(value:*):DLinkedListItem		{			var item:DLinkedListItem = _head;					while (item)			{				if (item.data == value) return item;				item = item.next;			}						throw new ArgumentError("No item exists for the specified 'value' [" + value + "]");		}				/**		 * Returns the value of the item after the target.		 */		public function getAfter(target:DLinkedListItem):*		{			if (!target.next) throw new ArgumentError("No item exists after the 'target' [" + target + "]");			return target.next.data;		}				/**		 * Returns the value of the item before the target.		 */		public function getBefore(target:DLinkedListItem):*		{			if (!target.prev) throw new ArgumentError("No item exists before the 'target' [" + target + "]");			return target.prev.data;		}				/**		 * Removes the item at the end of the list and returns the value.		 */		public function removeTail():*		{			if (_tail == null) throw new IllegalOperationError("No items exist in this list.");			return removeItem(_tail);		}			/**		 * Removes the item at the front of the list and returns the value.		 */		public function removeHead():*		{			if (_head == null) throw new IllegalOperationError("No items exist in this list.");			return removeItem(_head);		}			/**		 * Removes the item after the specified item from the list and returns the value.		 */		public function removeItemAfter(item:DLinkedListItem):*		{			if (!item.next) throw new ArgumentError("No item exists after the 'item' [" + item + "].");			return removeItem(item.next);		}				/**		 * Removes the item after the specified item from the list and returns the value.		 */		public function removeItemBefore(item:DLinkedListItem):*		{			if (!item.prev) throw new ArgumentError("No item exists before the 'item' [" + item + "].");					return removeItem(item.prev);		}				/**		 * Removes the specified item from the list and returns the value		 */		public function removeItem(item:DLinkedListItem):*		{			var next:DLinkedListItem = item.next;			var prev:DLinkedListItem = item.prev;					if (prev) prev.next = next;			item.next = item.prev = null;					if (item == _head) _head = next;			if (item == _tail) _tail = prev;						return item.data;		}				/**		 * Removes the specified value from the list.		 */		public function remove(value:*):void		{			removeItem(getItemContaining(value));		}			/**		 * Unlinks all items in the list.		 */		public function removeAll():void		{			var item:DLinkedListItem = _head;			var next:DLinkedListItem;					while(item)			{				next = item.next;				item.next = item.prev = null;				item = next;			}					_head = _tail = null;		}			/**		 * Returns an array of the items in the list.		 */		public function toArray():Array		{			var a:Array = [];			var item:DLinkedListItem = _head;					while(item) {				a.push(item.data);				item = item.next;			}					return a;		}			/**		 * Returns a DLinkedListIterator for the list.		 */		public function getIterator():IIterator		{			return new DLinkedListIterator(this);		}	}}import com.sdg.collections.DLinkedListItem;import com.sdg.collections.DLinkedList;import com.sdg.collections.IIterator;import flash.errors.IllegalOperationError;class DLinkedListIterator implements IIterator{		private var _currentItem:DLinkedListItem;	private var _list:DLinkedList;		public function get location():Object	{		return _currentItem.next == _list.getHeadItem() ? _currentItem : null;	}		public function DLinkedListIterator(list:DLinkedList)	{		_list = list;		reset();	}	/**	 * Resets the iteration index;	 */	public function reset():void	{		_currentItem = new DLinkedListItem(null);		_currentItem.next = _list.getHeadItem();	}	/**	 * Returns whether there remains an item to iterate over.	 */	public function hasNext():Boolean	{		return _currentItem.next != null;	}	/**	 * Returns the next item.	 */	public function next():*	{		if (!_currentItem.next) throw new IllegalOperationError("No item exists at the next location.");				_currentItem = _currentItem.next;		return _currentItem.data;	}	/**	 * Removes and returns the current item.	 */	public function remove():*	{		var data:*;				if (_currentItem == _list.getHeadItem())		{			data = _list.removeHead();			reset();		}		else		{			_currentItem = _currentItem.prev;						if (!_currentItem) throw new IllegalOperationError("The current location is invalid.");						data = _list.removeItemAfter(_currentItem);		}				return data;	}		/**	 * Removes and returns the next item.	 */	public function removeNext():*	{		if (!_currentItem.next) throw new IllegalOperationError("No item exists at the next location.");				return _list.removeItemAfter(_currentItem);	}}