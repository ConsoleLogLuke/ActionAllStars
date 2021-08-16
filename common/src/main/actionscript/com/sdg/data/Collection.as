package com.sdg.data {
	
	public class Collection extends Object {
		
		protected var innerArray:Array;
		
		public function Collection() {
			innerArray = new Array();
		}
		
		/*
		 * CLASS METHODS
		*/
		public function getArrayAt(start:uint, length:uint):Array
		{
			var newArray:Array = new Array();
			var i:int;
			for (i = 0; i < length; i++)
			{
				if (innerArray[start + i] != null)
				{
					newArray.push(innerArray[start + i]);
				}
				else
				{
					i = length;
				}
			}
			return newArray;
		}
		public function getIndex(obj:Object):uint
		{
			return innerArray.indexOf(obj);
		}
		
		/*
		 * GET / SET METHODS
		*/
		public function get length():uint
		{
			return innerArray.length;
		}
		
	}
	
}