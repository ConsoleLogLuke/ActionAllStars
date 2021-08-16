package com.sdg.components.controls
{
	import mx.collections.ArrayList;
	
	[Bindable]
	public class MessagesArrayList extends ArrayList
	{
		public var hasNewMessages:Boolean = false;
		
		public function MessagesArrayList()
		{
			super();
		}
	}
}