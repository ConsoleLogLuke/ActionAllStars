package com.sdg.model
{
	public class LiveGamePlayMLB extends Object
	{
		public static const STRIKE:String = 'mlb strike';
		public static const BALL:String = 'mlb ball';
		public static const OUT:String = 'mlb out';
		public static const FOUL:String = 'mlb foul';
		public static const STRIKE_OUT:String = 'mlb strike out';
		public static const DOUBLE_PLAY:String = 'mlb double play';
		public static const TRIPLE_PLAY:String = 'mlb triple play';
		public static const WALK:String = 'mlb walk';
		public static const IN_PLAY_OUT:String = 'mlb in play out';
		public static const SINGLE:String = 'mlb single';
		public static const DOUBLE:String = 'mlb double';
		public static const TRIPLE:String = 'mlb triple';
		public static const HOME_RUN:String = 'mlb home run';
		public static const ERROR:String = 'mlb error';
		public static const RUN:String = 'mlb run';
		public static const RUN_TWO:String = 'mlb two runs';
		public static const RUN_THREE:String = 'mlb three runs';
		public static const GRAND_SLAM:String = 'mlb grand slam';
		
		public static const HOME_TEAM:String = 'home team';
		public static const AWAY_TEAM:String = 'away team';
		
		private var _gameEventId:String;
		private var _playId:uint;
		private var _homeTeamScore:uint;
		private var _awayTeamScore:uint;
		private var _pitcherId:uint;
		private var _batterPlayerId:uint
		private var _onDeckId:uint;
		private var _base1PlayerId:uint;
		private var _base2PlayerId:uint;
		private var _base3PlayerId:uint;
		private var _inning:uint;
		private var _isInningTop:Boolean;
		private var _inningEnded:Boolean;
		private var _strikes:uint;
		private var _balls:uint;
		private var _outs:uint;
		private var _gameProgress:String;
		private var _lastGameStatus:String;
		private var _lastPitch:String;
		private var _lastBatterStatus:String;
		private var _base1Player:LiveGamePlayer;
		private var _base2Player:LiveGamePlayer;
		private var _base3Player:LiveGamePlayer;
		private var _batterPlayer:LiveGamePlayer;
		private var _pitcher:LiveGamePlayer;
		private var _lastAction:String;
		private var _comment:String;
		
		private var _playType:String;
		private var _isScoringPlay:Boolean;
		
		public function LiveGamePlayMLB(gameEventId:String, playId:uint, homeTeamScore:uint, awayTeamScore:uint, 
										pitcherId:uint, batterPlayerId:uint, onDeckId:uint, base1PlayerId:uint, 
										base2PlayerId:uint, base3PlayerId:uint, inning:uint, isInningTop:Boolean, 
										inningEnded:Boolean, strikes:uint, balls:uint, outs:uint, gameProgress:String, 
										lastGameStatus:String, lastPitch:String, lastBatterStatus:String, 
										base1Player:LiveGamePlayer = null, base2Player:LiveGamePlayer = null, base3Player:LiveGamePlayer = null,
										batterPlayer:LiveGamePlayer = null, pitcher:LiveGamePlayer = null, lastAction:String = '', comment:String = '')
		{
			super();
			
			_gameEventId = gameEventId;
			_playId = playId;
			_homeTeamScore = homeTeamScore;
			_awayTeamScore = awayTeamScore;
			_pitcherId = pitcherId;
			_batterPlayerId = batterPlayerId;
			_onDeckId = onDeckId;
			_base1PlayerId = base1PlayerId;
			_base2PlayerId = base2PlayerId;
			_base3PlayerId = base3PlayerId;
			_inning = inning;
			_isInningTop = isInningTop;
			_inningEnded = inningEnded;
			_strikes = strikes;
			_balls = balls;
			_outs = outs;
			_gameProgress = gameProgress;
			_lastGameStatus = lastGameStatus;
			_lastPitch = lastPitch;
			_lastBatterStatus = lastBatterStatus;
			_base1Player = base1Player;
			_base2Player = base2Player;
			_base3Player = base3Player;
			_batterPlayer = batterPlayer;
			_pitcher = pitcher;
			_lastAction = lastAction;
			_comment = comment;
			_isScoringPlay = false;
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function LiveGamePlayFromXML(gamePlayXML:XML):LiveGamePlayMLB
		{
			// Create a live game play object from XML.
			
			// Validate data in xml.
			var gameEventId:String = (gamePlayXML.gameEventId != null) ? gamePlayXML.gameEventId : '';
			var playId:uint = (gamePlayXML.playId != null) ? gamePlayXML.playId : 0;
			var homeTeamScore:uint = (gamePlayXML.homeTeamScore != null) ? gamePlayXML.homeTeamScore : 0;
			var awayTeamScore:uint = (gamePlayXML.awayTeamScore != null) ? gamePlayXML.awayTeamScore : 0;
			var pitcherId:uint = (gamePlayXML.pitcherId != null) ? gamePlayXML.pitcherId : 0;
			var batterPlayerId:uint = (gamePlayXML.batterPlayerId != null) ? gamePlayXML.batterPlayerId : 0;
			var onDeckId:uint = (gamePlayXML.onDeckId != null) ? gamePlayXML.onDeckId : 0;
			var base1PlayerId:uint = (gamePlayXML.base1PlayerId != null) ? gamePlayXML.base1PlayerId : 0;
			var base2PlayerId:uint = (gamePlayXML.base2PlayerId != null) ? gamePlayXML.base2PlayerId : 0;
			var base3PlayerId:uint = (gamePlayXML.base3PlayerId != null) ? gamePlayXML.base3PlayerId : 0;
			var inning:uint = (gamePlayXML.inning != null) ? gamePlayXML.inning : 0;
			var isInningTop:Boolean = (gamePlayXML.isInningTop != null && gamePlayXML.isInningTop == 'true') ? true : false;
			var inningEnded:Boolean = (gamePlayXML.inningEnded != null && gamePlayXML.inningEnded == 'true') ? true : false;
			var strikes:uint = (gamePlayXML.s != null) ? gamePlayXML.s : 0;
			var balls:uint = (gamePlayXML.b != null) ? gamePlayXML.b : 0;
			var outs:uint = (gamePlayXML.o != null) ? gamePlayXML.o : 0;
			var gameProgress:String = (gamePlayXML.gameProgress != null) ? gamePlayXML.gameProgress : '';
			var lastGameStatus:String = (gamePlayXML.lastGameStatus != null) ? gamePlayXML.lastGameStatus : '';
			var lastPitch:String = (gamePlayXML.lastPitch != null) ? gamePlayXML.lastPitch : '';
			var lastBatterStatus:String = (gamePlayXML.lastBatterStatus != null) ? gamePlayXML.lastBatterStatus : '';
			var lastAction:String = (gamePlayXML.lastAction != null) ? gamePlayXML.lastAction : '';
			var comment:String = (gamePlayXML.comment != null) ? gamePlayXML.comment : '';
			
			var base1Node:XMLList = gamePlayXML.child('base1Player');
			var base2Node:XMLList = gamePlayXML.child('base2Player');
			var base3Node:XMLList = gamePlayXML.child('base3Player');
			var base1Player:LiveGamePlayer = (base1Node.length() > 0) ? LiveGamePlayer.PlayerFromXML(new XML(base1Node)) : null;
			var base2Player:LiveGamePlayer = (base2Node.length() > 0) ? LiveGamePlayer.PlayerFromXML(new XML(base2Node)) : null;
			var base3Player:LiveGamePlayer = (base3Node.length() > 0) ? LiveGamePlayer.PlayerFromXML(new XML(base3Node)) : null;
			
			var batterNode:XMLList = gamePlayXML.child('batterPlayer');
			var pitcherNode:XMLList = gamePlayXML.child('pitcher');
			var batterPlayer:LiveGamePlayer = (batterNode.length() > 0) ? LiveGamePlayer.PlayerFromXML(new XML(batterNode)) : null;
			var pitcher:LiveGamePlayer = (pitcherNode.length() > 0) ? LiveGamePlayer.PlayerFromXML(new XML(pitcherNode)) : null;
			
			// Create the live game play object.
			var gamePlay:LiveGamePlayMLB = new LiveGamePlayMLB(gameEventId, playId, homeTeamScore, awayTeamScore, pitcherId, batterPlayerId, onDeckId, base1PlayerId, base2PlayerId, base3PlayerId, inning, isInningTop, inningEnded, strikes, balls, outs, gameProgress, lastGameStatus, lastPitch, lastBatterStatus, base1Player, base2Player, base3Player, batterPlayer, pitcher, lastAction, comment);
			
			return gamePlay;
		}
		
		public static function GetGamePlayXML(gamePlay:LiveGamePlayMLB):XML
		{
			var root:XML = new XML(<baseballGamePlay></baseballGamePlay>);
			
			root.appendChild('<gameEventId>' + gamePlay.gameEventId + '</gameEventId>');
			root.appendChild('<playId>' + gamePlay.playId + '</playId>');
			root.appendChild('<homeTeamScore>' + gamePlay.homeTeamScore + '</homeTeamScore>');
			root.appendChild('<awayTeamScore>' + gamePlay.awayTeamScore + '</awayTeamScore>');
			root.appendChild('<pitcherId>' + gamePlay.pitcherId + '</pitcherId>');
			root.appendChild('<batterPlayerId>' + gamePlay.batterPlayerId + '</batterPlayerId>');
			root.appendChild('<onDeckId>' + gamePlay.onDeckId + '</onDeckId>');
			root.appendChild('<base1PlayerId>' + gamePlay.base1PlayerId + '</base1PlayerId>');
			root.appendChild('<base2PlayerId>' + gamePlay.base2PlayerId + '</base2PlayerId>');
			root.appendChild('<base3PlayerId>' + gamePlay.base3PlayerId + '</base3PlayerId>');
			//root.appendChild('<base1Note>' + gamePlay.base1Note + '</base1Note>');
			root.appendChild('<inning>' + gamePlay.inning + '</inning>');
			root.appendChild('<isInningTop>' + gamePlay.isInningTop + '</isInningTop>');
			root.appendChild('<inningEnded>' + gamePlay.inningEnded + '</inningEnded>');
			root.appendChild('<s>' + gamePlay.strikes + '</s>');
			root.appendChild('<b>' + gamePlay.balls + '</b>');
			root.appendChild('<o>' + gamePlay.outs + '</o>');
			root.appendChild('<gameProgress>' + gamePlay.gameProgress + '</gameProgress>');
			root.appendChild('<lastGameStatus>' + gamePlay.lastGameStatus + '</lastGameStatus>');
			root.appendChild('<lastPitch>' + gamePlay.lastPitch + '</lastPitch>');
			root.appendChild('<lastBatterStatus>' + gamePlay.lastBatterStatus + '</lastBatterStatus>');
			root.appendChild('<lastAction>' + gamePlay.lastAction + '</lastAction>');
			root.appendChild('<comment>' + gamePlay.comment + '</comment>');
			if (gamePlay.base1Player != null) root.appendChild(LiveGamePlayer.GetPlayerXML(gamePlay.base1Player, 'base1Player'));
			if (gamePlay.base2Player != null) root.appendChild(LiveGamePlayer.GetPlayerXML(gamePlay.base2Player, 'base2Player'));
			if (gamePlay.base3Player != null) root.appendChild(LiveGamePlayer.GetPlayerXML(gamePlay.base3Player, 'base3Player'));
			
			return root;
		}
		
		public static function GetPlayTypeFromConsecutivePlays(previousPlay:LiveGamePlayMLB, currentPlay:LiveGamePlayMLB):String
		{
			// Determine runs.
			var runCount:uint;
			if (currentPlay.lastPitch.indexOf('In play') > -1 && currentPlay.lastGameStatus == 'home_run') return HOME_RUN;
			if (currentPlay.awayTeamScore > previousPlay.awayTeamScore)
			{
				runCount = currentPlay.awayTeamScore - previousPlay.awayTeamScore;
			}
			else if (currentPlay.homeTeamScore > currentPlay.homeTeamScore)
			{
				runCount = currentPlay.homeTeamScore - previousPlay.homeTeamScore;	
			}
			switch (runCount)
			{
				case 1:
					return RUN;
					break;
				case 2:
					return RUN_TWO;
					break;
				case 3:
					return RUN_THREE;
					break;
				case 4:
					return GRAND_SLAM;
					break;
			}
			
			// Determine outs.
			if (currentPlay.outs > previousPlay.outs)
			{
				if (currentPlay.outs == previousPlay.outs + 3)
				{
					return TRIPLE_PLAY;
				}
				else if (currentPlay.outs == previousPlay.outs + 2)
				{
					return DOUBLE_PLAY;
				}
				
				if (currentPlay.strikes == 3)
				{
					return STRIKE_OUT;
				}
				
				return OUT;
			}
			
			// Determine strikes.
			if (currentPlay.strikes == previousPlay.strikes + 1)
			{
				// A strike occured.
				if (currentPlay.strikes > 2 && currentPlay.outs > previousPlay.outs)
				{
					// A strike out occured.
					return STRIKE_OUT;
				}
				
				if (currentPlay.lastPitch.indexOf('Foul') > -1)
				{
					// A strike from fould occured.
					return FOUL;
				}
				
				return STRIKE;
			}
			
			// Determine balls.
			if (currentPlay.balls == previousPlay.balls + 1)
			{
				// A ball occured.
				if (currentPlay.balls > 3)
				{
					// A walk just occured.
					return WALK;
				}
				return BALL;
			}
			
			// Determine fouls without strikes.
			if (currentPlay.lastPitch.indexOf('Foul') > -1)
			{
				// A foul without a strike occured.
				return FOUL;
			}
			
			// Determine in-play events.
			if (currentPlay.lastPitch.indexOf('In play') > -1)
			{
				// An in play event occured.
				
				// Determine home run.
				if (currentPlay.lastGameStatus == 'home_run')
				{
					// Batter hit a home run.
					return HOME_RUN;
				}
				
				// Determine error.
				if (currentPlay.lastGameStatus == 'error')
				{
					return ERROR;
				}
				
				// Determine if the batter is now on base.
				if (currentPlay.batterPlayerId == currentPlay.base1PlayerId)
				{
					// The batter is now on first.
					// It was a single.
					return SINGLE;
				}
				else if (currentPlay.batterPlayerId == currentPlay.base2PlayerId)
				{
					// The batter is now on second.
					// It was a double.
					return DOUBLE;
				}
				else if (currentPlay.batterPlayerId == currentPlay.base2PlayerId)
				{
					// The batter is now on third.
					// It was a tripple.
					return TRIPLE;
				}
			}
			
			return '';
		}
		
		public static function SetPlayParamsFromConsecutivePlays(previousPlay:LiveGamePlayMLB, currentPlay:LiveGamePlayMLB):void
		{
			// Compare two consecutive plays to determine parameters for the current play.
			var playType:String = GetPlayTypeFromConsecutivePlays(previousPlay, currentPlay);
			currentPlay.playType = playType;
			
			// Determine if it is a scoring play.
			if (currentPlay.homeTeamScore > previousPlay.homeTeamScore || currentPlay.awayTeamScore > previousPlay.awayTeamScore)
			{
				// It is a scoring play.
				currentPlay.isScoringPlay = true;
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get gameEventId():String
		{
			return _gameEventId;
		}
		
		public function get playId():uint
		{
			return _playId;
		}
		
		public function get homeTeamScore():uint
		{
			return _homeTeamScore;
		}
		
		public function get awayTeamScore():uint
		{
			return _awayTeamScore;
		}
		
		public function get pitcherId():uint
		{
			return _pitcherId;
		}
		
		public function get batterPlayerId():uint
		{
			return _batterPlayerId;
		}
		
		public function get onDeckId():uint
		{
			return _onDeckId;
		}
		
		public function get base1PlayerId():uint
		{
			return _base1PlayerId;
		}
		
		public function get base2PlayerId():uint
		{
			return _base2PlayerId;
		}
		
		public function get base3PlayerId():uint
		{
			return _base3PlayerId;
		}
		
		public function get inning():uint
		{
			return _inning;
		}
		
		public function get isInningTop():Boolean
		{
			return _isInningTop;
		}
		
		
		public function get inningEnded():Boolean
		{
			return _inningEnded;
		}
		
		public function get strikes():uint
		{
			return _strikes;
		}
		
		public function get balls():uint
		{
			return _balls;
		}
		
		public function get outs():uint
		{
			return _outs;
		}
		
		public function get gameProgress():String
		{
			return _gameProgress;
		}
		
		public function get lastGameStatus():String
		{
			return _lastGameStatus;
		}
		
		public function get lastPitch():String
		{
			return _lastPitch;
		}
		
		public function get lastBatterStatus():String
		{
			return _lastBatterStatus;
		}
		
		public function get lastAction():String
		{
			return _lastAction;
		}
		
		public function get base1Player():LiveGamePlayer
		{
			return _base1Player;
		}
		
		public function get base2Player():LiveGamePlayer
		{
			return _base2Player;
		}
		
		public function get base3Player():LiveGamePlayer
		{
			return _base3Player;
		}
		
		public function get batterPlayer():LiveGamePlayer
		{
			return _batterPlayer;
		}
		
		public function get pitcher():LiveGamePlayer
		{
			return _pitcher;
		}
		
		public function get playType():String
		{
			return _playType;
		}
		public function set playType(value:String):void
		{
			_playType = value;
		}
		
		public function get isScoringPlay():Boolean
		{
			return _isScoringPlay;
		}
		public function set isScoringPlay(value:Boolean):void
		{
			_isScoringPlay = value;
		}
		
		public function get comment():String
		{
			return _comment;
		}
		public function set comment(value:String):void
		{
			_comment = value;
		}
		
	}
}