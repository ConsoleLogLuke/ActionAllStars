package com.sdg.model
{
	[Bindable]
	public class Reward
	{
		public static const CURRENCY:uint = 1;
		public static const EXPERIENCE:uint = 2;
		public static const INVENTORY_ITEM:uint = 3;
		public static const LEVEL_UP:uint = 4;
		public static const ACHIEVEMENT:uint = 5;
		public static const SUBLEVEL_UP:uint = 6;
		public static const BADGE:uint = 7;
		
		public var avatarId:uint;
		public var causeId:uint;
		public var rewardTypeId:uint;
		public var rewardValue:uint;
		public var rewardValueTotal:uint;
		
		private static const PRIORITY_MAP:Object = { 1:2, 2:3, 3:0, 4:5, 5:1 };
		
		public function get priority():Number
		{
			return PRIORITY_MAP[rewardTypeId];
		}
		
		public static function RewardCollectionFromXML(rewardList:XMLList):RewardCollection
		{
			var i:uint = 0;
			var rewards:RewardCollection = new RewardCollection();
			while (rewardList.reward[i] != null)
			{
				var reward:Reward = RewardFromXML(rewardList.reward[i]);
				rewards.push(reward);
				
				i++;
			}
			
			return rewards;
		}
		
		public static function RewardFromXML(rewardXML:XML):Reward
		{
			var typeId:uint = (rewardXML.@typeId) ? rewardXML.@typeId : 0;
			var value:uint = (rewardXML.@value) ? rewardXML.@value : 0;
			
			var reward:Reward = new Reward();
			reward.rewardTypeId = typeId;
			reward.rewardValue = value;
			
			return reward;
		}
	}
}