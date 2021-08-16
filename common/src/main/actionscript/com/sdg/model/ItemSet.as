package com.sdg.model
{
	public class ItemSet
	{
		private var _itemSetId:int;
		private var _name:String;
		private var _description:String;
		private var _itemTypes:Array;
		
		public function ItemSet(itemSetId:int, name:String, description:String, itemTpes:Array)
		{
			_itemSetId = itemSetId;
			_name = name;
			_description = description;
			_itemTypes = itemTpes;
		}
		
		public function get itemSetId():int
		{
			return _itemSetId;
		}
		
		public function get name():String
		{
			return _name;
		}

		public function get description():String
		{
			return _description;
		}

		public function get itemTpes():Array
		{
			return _itemTypes;
		}
	}
}