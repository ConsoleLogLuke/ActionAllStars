package com.sdg.leaderboard
{
	import com.sdg.mvc.IModel;

	public interface ILeaderboardModel extends IModel
	{
		function get view():ILeaderboardView;
		function get controller():ILeaderboardController;

		function get selectorModel():ILeaderboardSelectModel;
		function get cardModel():ILeaderboardCardModel;
	}
}