package com.sdg.model
{
	public class AvatarAchievement extends Achievement
	{
		public static const IN_PROGRESS:String = '1';
		public static const COMPLETED:String = '2';
		public static const FAILED:String = '3';
		public static const MANDATORY:String = '1';
		public static const OPTIONAL:String = '0';
		
		protected var _status:String;
		
		public function AvatarAchievement(id:int, name:String, description:String='', status:String = '0', priority:String = '0', startDate:Date=null, endDate:Date=null, questProviders:QuestProviderCollection=null, hasCutscene:Boolean=false, cutSceneFlag:uint = 0, deliveryMethod:String = '0', criteria:Array = null, metricAttributes:Array = null)
		{
			super(id, name, description, priority, startDate, endDate, questProviders, hasCutscene, cutSceneFlag, deliveryMethod, criteria, metricAttributes);
			
			_status = status;
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function ParseAvatarAchievementXML(xml:XML):AvatarAchievement
		{
			var achievement:Achievement = Achievement.ParseAchievementXML(xml);
			
			// Extract status.
			var status:String = (xml.achievementStatusId != null) ? xml.achievementStatusId : '0';
			// Extract priority.
			var priority:String = (xml.priority != null) ? xml.priority : '0';
			// Extract start date.
			var startDate:Date = (xml.achievementStartDateAsLong != null) ? new Date(xml.achievementStartDateAsLong) : null;
			
			return new AvatarAchievement(achievement.id, achievement.name, achievement.description, status, priority, startDate, achievement.endDate, achievement.questProviders, achievement.hasCutscene, achievement.cutSceneFlag, achievement.deliveryMethod, achievement.criteria, achievement.metricAttributes);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get status():String
		{
			return _status;
		}
		
		public function get isComplete():Boolean
		{
			return (_status == AchievementStatus.COMPLETE);
		}
		
	}
}