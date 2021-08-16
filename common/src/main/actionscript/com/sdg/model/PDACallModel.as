package com.sdg.model
{
	public class PDACallModel extends Object
	{
		public var callerId:int;
		public var callerName:String;
		public var callerImageUrl:String;
		
		public function PDACallModel()
		{
			super();
			
			callerId = 0;
			callerName = 'Some Caller';
			callerImageUrl = '';
		}
		
	}
}