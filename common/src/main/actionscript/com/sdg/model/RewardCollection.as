package com.sdg.model
{
	public class RewardCollection extends ObjectCollection
	{
		public function RewardCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):Reward
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:Reward):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:Reward):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:Reward):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Searches Collection for Rewards of a Specific Type
		 * Assumes: Only One Reward of any given type in a reward collections
		 */
		public function getRewardByType(type:int):Reward
		{
			for each (var reward:Reward in _data)
			{
				if (reward.rewardTypeId == type)
					return reward;
			}
			
			return null;
		}
		
		/**
		 * Searches Collection for Rewards of a Specific avatarId
		 */
		public function getRewardByTypeAndAvatarId(typeId:int, avatarId:int):Reward
		{
			for each (var reward:Reward in _data)
			{
				if (reward.avatarId == avatarId && reward.rewardTypeId == typeId) return reward;
			}
			
			return null;
		}
		
	}
}