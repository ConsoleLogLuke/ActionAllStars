package com.sdg.collections
{
	public class DLinkedListItem
	{	
		public var data:*;
		public var next:DLinkedListItem;
		public var prev:DLinkedListItem;
	
		public function DLinkedListItem(data:*)
		{
			this.data = data;
		}
	}
}