package com.sdg.leaderboard
{
	import flash.events.IEventDispatcher;

	public interface ILeaderboardController extends IEventDispatcher
	{
		function init(model:ILeaderboardModel):void;
	}
}