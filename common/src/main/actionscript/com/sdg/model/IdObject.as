package com.sdg.model
{
	public class IdObject extends Object implements IIdObject
	{
		protected var _id:uint;
		protected var _name:String;
		
		public function IdObject(id:uint, name:String)
		{
			super();
			
			_id = id;
			_name = name;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get id():uint
		{
			return _id;
		}
		
		public function get name():String
		{
			return _name;
		}
		
	}
}