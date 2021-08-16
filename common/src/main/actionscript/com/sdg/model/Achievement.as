package com.sdg.model
{
	import com.sdg.utils.DateUtil;
	
	public class Achievement extends IdObject
	{
		public static const OPTIONAL:String = '0';
		public static const MANDATORY:String = '1';
		public static const HIDDEN:String = '2';
		
		private var _description:String;
		private var _startDate:Date;
		private var _endDate:Date;
		private var _questProviders:QuestProviderCollection;
		private var _hasCutscene:Boolean;
		private var _cutSceneFlag:uint;
		private var _deliveryMethod:String;
		protected var _priority:String;
		protected var _criteria:Array;
		protected var _metricAttributes:Array;
		
		public function Achievement(id:int, name:String, description:String = '', priority:String = '0', startDate:Date = null, endDate:Date = null, questProviders:QuestProviderCollection = null, hasCutscene:Boolean = false, cutSceneFlag:uint = 0, deliveryMethod:String = '0', criteria:Array = null, metricAttributes:Array = null)
		{
			super(id, name);
			
			_description = description;
			_priority = priority;
			_startDate = startDate;
			_endDate = endDate;
			_questProviders = (questProviders == null) ? new QuestProviderCollection() : questProviders;
			_hasCutscene = hasCutscene;
			_cutSceneFlag = cutSceneFlag;
			_deliveryMethod = deliveryMethod;
			_criteria = (criteria != null) ? criteria : [];
			_metricAttributes = (metricAttributes != null) ? metricAttributes : [];
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function ParseAchievementXML(xml:XML):Achievement
		{
			var id:int = xml.achievementId;
			var name:String = xml.name;
			var description:String = xml.description;
			var startDate:Date = DateUtil.ParseStandardDate(xml.startDate);
			var endDate:Date = DateUtil.ParseStandardDate(xml.endDate);
			var questProviders:QuestProviderCollection = QuestProviderCollection.ParseMultipleQuestProviderXML(xml.questProviders);
			var cutSceneFlag:uint = (xml.cutsceneFlag != null) ? xml.cutsceneFlag : 0;
			var hasCutscene:Boolean = (cutSceneFlag > 0) ? true : false;
			var priority:String = (xml.priority != null) ? xml.priority : '0';
			var deliveryMethod:String = (xml.deliveryMethod != null) ? xml.deliveryMethod : '0';
			
			// Parse avatar achievement criteria.
			var criteriaList:XMLList = xml.avatarAchievementCriteria as XMLList;
			var criteriaArray:Array = [];
			var i:int = 0;
			while (xml.avatarAchievementCriteria[i] != null)
			{
				var criteriaXml:XML = xml.avatarAchievementCriteria[i];
				i++;
				
				if (criteriaXml == null) continue;
				var criteria:AchievementCriteria = new AchievementCriteria(criteriaXml.attributeId, criteriaXml.attributeValue);
				criteriaArray.push(criteria);
			}
			
			// Parse achievement metric attributes.
			var metricAttributeArray:Array = [];
			var achievementMetricsXml:XMLList = xml.achms as XMLList;
			if (achievementMetricsXml != null)
			{
				i = 0;
				while (achievementMetricsXml.achm[i] != null)
				{
					var achievementMetricXml:XML = achievementMetricsXml.achm[i];
					var attributeId:int = achievementMetricXml.attrId;
					var attributeValue:int = achievementMetricXml.attrVal;
					metricAttributeArray[attributeId] = attributeValue;
					
					i++;
				}
			}
			
			var achievement:Achievement = new Achievement(id, name, description, priority, startDate, endDate, questProviders, hasCutscene, cutSceneFlag, deliveryMethod, criteriaArray, metricAttributeArray);
			return achievement;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function getCriteriaWithAttributeId(attributeId:int):Array
		{
			// Return an array of criteria that match
			// the input attribute id.
			var matchingCriteria:Array = [];
			for each (var achievementCriteria:AchievementCriteria in _criteria)
			{
				if (achievementCriteria.attributeId == attributeId) matchingCriteria.push(achievementCriteria);
			}
			
			return matchingCriteria;
		}
		
		public function getMetricAttributeWithAttributeId(metricAttributeId:int):int
		{
			var metricAttributeValue:int = _metricAttributes[metricAttributeId] as int;
			return metricAttributeValue;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get description():String
		{
			return _description;
		}
		
		public function get startDate():Date
		{
			return _startDate;
		}
		
		public function get endDate():Date
		{
			return _endDate;
		}
		
		public function get questProviders():QuestProviderCollection
		{
			return _questProviders;
		}
		
		public function get hasCutscene():Boolean
		{
			return _hasCutscene;
		}
		
		public function get priority():String
		{
			return _priority;
		}
		
		public function get deliveryMethod():String
		{
			return _deliveryMethod;
		}
		
		public function get cutSceneFlag():uint
		{
			return _cutSceneFlag;
		}
		
		public function get criteria():Array
		{
			return _criteria;
		}
		
		public function get metricAttributes():Array
		{
			return _metricAttributes;
		}
		
	}
}