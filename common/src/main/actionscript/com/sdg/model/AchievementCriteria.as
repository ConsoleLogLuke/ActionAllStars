package com.sdg.model
{
	public class AchievementCriteria extends Object
	{
		private var _attributeId:int;
		private var _attributeValue:int;
		
		public function AchievementCriteria(attributeId:int, attributeValue:int)
		{
			super();
			
			_attributeId = attributeId;
			_attributeValue = attributeValue;
		}
		
		public function get attributeId():int
		{
			return _attributeId;
		}
		
		public function get attributeValue():int
		{
			return _attributeValue;
		}
		
	}
}