package com.sdg.control.room.itemClasses
{
	import com.sdg.display.leaderboard.InWorldLeaderboardDisplay;
	import com.sdg.leaderboard.LeaderboardUtil;
	import com.sdg.leaderboard.model.LeaderboardTimeFrame;
	import com.sdg.leaderboard.model.LeaderboardUserSet;
	import com.sdg.leaderboard.model.TopUserCollection;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.SdgItem;
	import com.sdg.util.ServerFeedUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class InWorldLeaderboardController extends RoomItemController implements IRoomItemController
	{
		private var _timeFrame:int; // The timeframe from which we grab high scores. (Daily, Weekly, Monthly, All-Time)
		
		public function InWorldLeaderboardController()
		{
			super();
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		override public function initialize(item:SdgItem):void
		{
			super.initialize(item);
			
			// Load top 5 scores for today.
			var localAvatar:Avatar = ModelLocator.getInstance().avatar;
			var gameId:int = _item.attributes.gameId;
			// Determine which time frame we will use to grab high scores from.
			// Daily, Weekly, Monthly, All-Time.
			// We hijacked the "mintDate" InventoryAttribute to set this value.
			_timeFrame = (_item.attributes.mintDate) ? _item.attributes.mintDate : LeaderboardTimeFrame.DAY;
			var url:String = ServerFeedUtil.TopUserListUrl(localAvatar.avatarId, gameId, 5, _timeFrame, LeaderboardUserSet.WORLD);
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onUserListComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onUserListError);
			loader.load(request);
			
			// Use the timeFrame value to determine a proper title.
			switch (_timeFrame)
			{
				case LeaderboardTimeFrame.DAY:
					leaderboardDisplay.title = 'Top Scores Today';
					break;
				case LeaderboardTimeFrame.WEEK:
					leaderboardDisplay.title = 'Top Scores This Week';
					break;
				case LeaderboardTimeFrame.MONTH:
					leaderboardDisplay.title = 'Top Scores This Month';
					break;
				case LeaderboardTimeFrame.ALL_TIME:
					leaderboardDisplay.title = 'Top Scores All-Time';
					break;
				default:
					leaderboardDisplay.title = 'Top Scores Today';
			}
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get leaderboardDisplay():InWorldLeaderboardDisplay
		{
			return InWorldLeaderboardDisplay(_display);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onUserListComplete(e:Event):void
		{
			// Remove listeners.
			var loader:URLLoader = URLLoader(e.currentTarget);
			loader.removeEventListener(Event.COMPLETE, onUserListComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onUserListError);
			
			// Parse top users.
			var topUsers:TopUserCollection = LeaderboardUtil.ParseTopUsers(new XML(loader.data));
			// Pass to display.
			leaderboardDisplay.topUsers = topUsers;
		}
		
		private function onUserListError(e:IOErrorEvent):void
		{
			// Remove listeners.
			var loader:URLLoader = URLLoader(e.currentTarget);
			loader.removeEventListener(Event.COMPLETE, onUserListComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onUserListError);
		}
		
	}
}