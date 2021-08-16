package com.sdg.events {

	import com.sdg.model.Reward;
	import com.sdg.model.RewardCollection;
	
	import flash.events.Event;

	public class SocketEvent extends Event {

		public static const CONNECTION:String = "connection";
		public static const CONNECTION_CLOSED:String = "connectionClosed";
		public static const LOGIN:String = "login";
		public static const LOGOUT:String = "logout";
		public static const PUBLIC_MESSAGE:String = "publicMessage";
		public static const PRIVATE_MESSAGE:String = "privateMessage";
		public static const ROOM_JOIN:String = "roomEnter";
		public static const ROOM_EXIT:String = "roomExit";
		public static const PLUGIN_EVENT:String = "plugin";
		public static const JOIN_GAME_QUEUE_SUCCESS:String = "mpJoinGameQueueSuccess";
		public static const LEAVE_GAME_QUEUE_SUCCESS:String = "mpLeaveGameQueueSuccess";
		public static const JOIN_GAME_QUEUE_FAIL:String = "mpJoinGameQueueFail";
		public static const LAUNCH_GAME_QUEUE:String = "mpLaunchGameQueue";
		public static const LAUNCH_MULTIPLAYER_GAME:String = "mpLaunchGame";
		
		private var _params:Object;
		private var _rewards:RewardCollection;

		public function SocketEvent(type:String, params:Object = null)
		{
			super(type);
			_params = params;
			_rewards = new RewardCollection();
			
			// Parse out rewards.
			if (_params.reward)
			{
				var	rewardsXml:XML = new XML(_params.reward);
				var rewards:RewardCollection = new RewardCollection();
				
				var i:int = 0;
				while (rewardsXml.reward[i])
				{
					var rewardXml:XML = rewardsXml.reward[i];
					var r:Reward = new Reward();
					r.rewardTypeId = rewardXml.rewardTypeId;
					r.rewardValue = rewardXml.rewardValue;
					r.rewardValueTotal = rewardXml.rewardValueTotal;
					r.avatarId = rewardXml.avatarId;
					
					// Check if there is already a reward in the collection with the same avatar id and type id.
					var currentReward:Reward = rewards.getRewardByTypeAndAvatarId(r.rewardTypeId, r.avatarId);
					if (currentReward)
					{
						// A reward with the same avatar id and type already exists.
						// Merge the values.
						currentReward.rewardValue += r.rewardValue;
						currentReward.rewardValueTotal = Math.max(currentReward.rewardValueTotal, r.rewardValueTotal);
					}
					else
					{
						rewards.push(r);
					}
					
					i++;
				}
				
				_rewards = rewards;
			}
		}
		
		override public function clone():Event
		{
			return new SocketEvent(type, params);
		}
		
		public function createParamsXml():XML
		{
			return (_params.action) ? new XML(_params[_params.action]) : null;
		}
		
		public function get params():Object
		{
			return _params;
		}
		
		public function get rewards():RewardCollection
		{
			return _rewards;
		}
	}
}
