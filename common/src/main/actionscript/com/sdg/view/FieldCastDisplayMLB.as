package com.sdg.view
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.model.LiveGamePlayMLB;
	import com.sdg.model.LiveGamePlayer;
	import com.sdg.model.LiveGameTeam;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	public class FieldCastDisplayMLB extends Sprite
	{
		public static const BASE_1:String = 'base 1';
		public static const BASE_2:String = 'base 2';
		public static const BASE_3:String = 'base 3';
		public static const HOME_PLATE:String = 'home plate';
		public static const HOME:String = 'home plate then dugout';
		public static const MOUND:String = 'pitcher mound';
		public static const DUGOUT_1:String = 'dugout 1';
		public static const DUGOUT_2:String = 'dugout 2';
		
		private var _animManager:AnimationManager;
		private var _basePos1:Point;
		private var _basePos2:Point;
		private var _basePos3:Point;
		private var _basePos4:Point;
		private var _moundPos:Point;
		private var _dugoutPos1:Point;
		private var _dugoutPos2:Point;
		private var _playerArray:Array;
		private var _playerDisplayArray:Array;
		private var _playerPositionArray:Array;
		private var _team1:LiveGameTeam;
		private var _team2:LiveGameTeam;
		private var _lastGamePlay:LiveGamePlayMLB;
		
		public function FieldCastDisplayMLB()
		{
			super();
			
			// Default.
			_basePos1 = new Point(891, 423);
			_basePos2 = new Point(473, 310);
			_basePos3 = new Point(42, 422);
			_basePos4 = new Point(473, 546);
			_moundPos = new Point(473, 401);
			_dugoutPos1 = new Point(50, 550);
			_dugoutPos2 = new Point(875, 550);
			_playerArray = [];
			_playerDisplayArray = [];
			_playerPositionArray = [];
			_animManager = new AnimationManager();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function setGamePlay(gamePlay:LiveGamePlayMLB):void
		{
			// Keep track of who is on the field.
			var onFieldArray:Array = [];
			
			// Determine how many runs were scored if any.
			var runsIn:uint = 0;
			if (_lastGamePlay != null)
			{
				// Determine run count.
				runsIn = (gamePlay.isInningTop == true) ? gamePlay.awayTeamScore - _lastGamePlay.awayTeamScore : gamePlay.homeTeamScore - _lastGamePlay.homeTeamScore;
			}
			
			// If the innning is over, send everyone to their dugout.
			if (gamePlay.inningEnded == true)
			{
				allPlayersToDugout();
				return;
			}
			
			// If it was a home run, send everyone home.
			if (gamePlay.playType == LiveGamePlayMLB.HOME_RUN)
			{
				homeRun(gamePlay);
				return;
			}
			
			// Who should be at bat?
			var atBatPlayer:LiveGamePlayer = gamePlay.batterPlayer;
			if (atBatPlayer != null) movePlayer(atBatPlayer, HOME_PLATE);
			
			// Who should be pitching?
			var pitcherPlayer:LiveGamePlayer = gamePlay.pitcher;
			if (pitcherPlayer != null) movePlayer(pitcherPlayer, MOUND);
			
			// Who should be on first?
			var basePlayer1:LiveGamePlayer = gamePlay.base1Player;
			if (basePlayer1 != null) movePlayer(basePlayer1, BASE_1);
			
			// Who should be on second?
			var basePlayer2:LiveGamePlayer = gamePlay.base2Player;
			if (basePlayer2 != null) movePlayer(basePlayer2, BASE_2);
			
			// Who should be on third?
			var basePlayer3:LiveGamePlayer = gamePlay.base3Player;
			if (basePlayer3 != null) movePlayer(basePlayer3, BASE_3);
			
			// Clean up players who should not be on the field.
			cleanUpField();
			
			// Keep track of the latest game play event.
			_lastGamePlay = gamePlay;
			
			function cleanUpField():void
			{
				// Who is on the field but shouldn't be?
				var i:int = 0;
				var len:int = _playerArray.length;
				var sentHome:uint = 0;
				playerLoop: for (i; i < len; i++)
				{
					// Get player reference.
					var player:LiveGamePlayer = _playerArray[i] as LiveGamePlayer;
					if (player == null) continue playerLoop;
					
					// If this player is NOT in the local onFieldArray, them he shouldn't be on the field anymore.
					var idString:String = player.id.toString();
					if (onFieldArray[idString] == null)
					{
						if (sentHome < runsIn)
						{
							// There are more runs than people we have sent home.
							// If this player is on base,
							// Send them home.
							
							// Determine player's position on the field.
							var currentPos:String = _playerPositionArray[idString];
							switch (currentPos)
							{
								case BASE_3 :
									movePlayerDisplay(player, HOME);
									sentHome++;
									continue playerLoop;
									break;
								case BASE_2 :
									movePlayerDisplay(player, HOME);
									sentHome++;
									continue playerLoop;
									break;
								case BASE_1 :
									movePlayerDisplay(player, HOME);
									sentHome++;
									continue playerLoop;
									break;
							}
						}
						
						// This player is on the field but should NOT be.
						// Send the player to their dugout.
						var team:LiveGameTeam = getTeam(player.teamId);
						var dugout:String = (player.teamId == _team1.id) ? DUGOUT_1 : DUGOUT_2;
						movePlayer(player, dugout);
					}
				}
			}
			
			function movePlayer(player:LiveGamePlayer, moveTo:String):void
			{
				// Is this player already on the field?
				var idString:String = player.id.toString();
				var currentPlayerDisplay:DisplayObject = _playerDisplayArray[idString];
				if (currentPlayerDisplay != null)
				{
					// This player is already on the field.
					// Move the player.
					movePlayerDisplay(player, moveTo);
				}
				else
				{
					// This player is not yet on the field.
					// Add the player and create a player display.
					currentPlayerDisplay = addPlayer(player);
					// Move the player.
					movePlayerDisplay(player, moveTo);
				}
				
				// Keep a reference of the player id in a local array.
				onFieldArray[idString] = idString;
			}
		}
		
		private function movePlayerDisplay(player:LiveGamePlayer, moveTo:String):void
		{
			// Determine a set of destinations,
			// Based on where the player is coming from and where the player is going.
			var destinationArray:Array = [moveTo];
			var destinationIndex:uint = 0;
			var idString:String = player.id.toString();
			var currentPos:String = _playerPositionArray[idString];
			var display:FieldCastPlayerMLB = _playerDisplayArray[idString] as FieldCastPlayerMLB;
			
			if (moveTo == HOME)
			{
				switch (currentPos)
				{
					case HOME_PLATE :
						destinationArray.unshift(BASE_1, BASE_2, BASE_3);
						break;
					case BASE_1 :
						destinationArray.unshift(BASE_2, BASE_3);
						break;
					case BASE_2 :
						destinationArray.unshift(BASE_3);
						break;
				}
				
				// Add dugout as their last destination.
				var dugout:String = (player.teamId == _team1.id) ? DUGOUT_1 : DUGOUT_2;
				destinationArray.push(dugout);
			}
			else if (moveTo == BASE_2 && currentPos == HOME_PLATE)
			{
				// Move to first, then second.
				destinationArray.unshift(BASE_1);
			}
			else if (moveTo == BASE_3 && currentPos == HOME_PLATE)
			{
				// Move to first, then second, then third.
				destinationArray.unshift(BASE_2);
				destinationArray.unshift(BASE_3);
			}
			else if (moveTo == BASE_3 && currentPos == BASE_1)
			{
				// Move to second, then third.
				destinationArray.unshift(BASE_2);
			}
			
			// Listen for animation finish.
			_animManager.addEventListener(AnimationEvent.FINISH, onFinish);
			move(destinationArray[destinationIndex]);
			
			function move(newPosString:String):void
			{
				var newPos:Point = getPosition(newPosString);
				var speed:uint = 200; // Pixels per second.
				var distanceX:Number = Math.abs(newPos.x - display.x);
				var distanceY:Number = Math.abs(newPos.y - display.y);
				var disatnce:Number = Math.sqrt(Math.pow(distanceX, 2) + Math.pow(distanceY, 2));
				var duration:uint = Math.floor((disatnce / speed) * 1000);
				_animManager.move(display, newPos.x, newPos.y, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				
				// If moving the player to third base, change name position.
				if (newPosString == BASE_3)
				{
					display.isNameOnLeft = false;
				}
			}
			
			function onFinish(e:AnimationEvent):void
			{
				// Make sure the finish event is for this player.
				var animTarget:DisplayObject = e.animTarget as DisplayObject;
				if (animTarget != display) return;
				
				// Keep a reference to the player position.
				currentPos = destinationArray[destinationIndex];
				_playerPositionArray[idString] = currentPos;
				
				// Increment destination index.
				destinationIndex++;
				
				if (destinationIndex < destinationArray.length)
				{
					// Move to the next destination.
					move(destinationArray[destinationIndex]);
				}
				else
				{
					// Remove event listener.
					_animManager.removeEventListener(AnimationEvent.FINISH, onFinish);
					
					// If we just moved the player to a dugout, remove the player.
					if (currentPos == DUGOUT_1 || currentPos == DUGOUT_2)
					{
						removePlayer(player);
					}
				}
			}
		}
		
		private function allPlayersToDugout():void
		{
			// Move all players to their dugout.
			var i:int = 0;
			var len:int = _playerArray.length;
			for (i; i < len; i++)
			{
				// Get reference to player at index i.
				var player:LiveGamePlayer = _playerArray[i] as LiveGamePlayer;
				if (player == null) continue;
				
				// Determine which dugout this player should go to.
				var dugout:String = (player.teamId == _team1.id) ? DUGOUT_1 : DUGOUT_2;
				
				// Move the player display to the dugout.
				movePlayerDisplay(player, dugout);
			}
		}
		
		private function homeRun(gamePlay:LiveGamePlayMLB):void
		{
			// Send all players on base to home.
			
			var atBatPlayer:LiveGamePlayer = gamePlay.batterPlayer;
			if (atBatPlayer != null) movePlayerDisplay(atBatPlayer, HOME);
			
			var basePlayer1:LiveGamePlayer = gamePlay.base1Player;
			if (basePlayer1 != null) movePlayerDisplay(basePlayer1, HOME);
			
			var basePlayer2:LiveGamePlayer = gamePlay.base2Player;
			if (basePlayer2 != null) movePlayerDisplay(basePlayer2, HOME);
			
			var basePlayer3:LiveGamePlayer = gamePlay.base3Player;
			if (basePlayer3 != null) movePlayerDisplay(basePlayer3, HOME);
		}
		
		private function addPlayer(player:LiveGamePlayer):DisplayObject
		{
			// Get reference to player id as a string.
			var idString:String = player.id.toString();
			
			// Make sure this player has not already been added.
			if (_playerArray[idString] != null) return null;
			
			// get reference to team and team color.
			var team:LiveGameTeam = getTeam(player.teamId);
			var teamColor1:uint = 0xff0000;
			var teamColor2:uint = 0x0000ff;
			if (team != null)
			{
				teamColor1 = team.color1;
				teamColor2 = team.color2;
			}
			var dugout:String = (player.teamId == _team1.id) ? DUGOUT_1 : DUGOUT_2;
			
			// Create display object.
			var display:FieldCastPlayerMLB = new FieldCastPlayerMLB(teamColor1, teamColor2, player.name, player.number);
			display.cacheAsBitmap = true;
			var position:Point = getPosition(dugout);
			display.x = position.x;
			display.y = position.y;
			
			// Create references in arrays.
			_playerArray[idString] = player;
			_playerDisplayArray[idString] = display;
			_playerPositionArray[idString] = dugout;
			
			// Add to display.
			addChild(display);
			
			return display;
		}
		
		private function removePlayer(player:LiveGamePlayer):void
		{
			var idString:String = player.id.toString();
			if (_playerArray[idString] == null) return;
			
			var display:DisplayObject = _playerDisplayArray[idString];
			removeChild(display);
			
			_playerArray[idString] = null;
			_playerDisplayArray[idString] = null;
			_playerPositionArray[idString] = null;
		}
		
		private function removeAllPlayers():void
		{
			var i:int = 0;
			var len:int = _playerArray.length;
			for (i; i < len; i++)
			{
				var player:LiveGamePlayer = _playerArray[i] as LiveGamePlayer;
				if (player == null) continue;
				var idString:String = player.id.toString();
				var display:DisplayObject = _playerDisplayArray[idString];
				removeChild(display);
			}
			
			// Empty the arrays.
			_playerArray = [];
			_playerDisplayArray = [];
			_playerPositionArray = [];
		}
		
		private function getTeam(teamId:uint):LiveGameTeam
		{
			// Determine if the team id matches that of team1 or team2 and return the match.
			// If there is no match, return null.
			if (_team1 != null && _team1.id == teamId)
			{
				return _team1;
			}
			else if (_team2 != null && _team2.id == teamId)
			{
				return _team2;
			}
			
			return null;
		}
		
		private function getPosition(locationString:String):Point
		{
			switch (locationString)
			{
				case BASE_1 :
					return _basePos1;
				case BASE_2 :
					return _basePos2;
				case BASE_3 :
					return _basePos3;
				case HOME_PLATE :
					return _basePos4;
				case HOME :
					return _basePos4;
				case MOUND :
					return _moundPos;
				case DUGOUT_1 :
					return _dugoutPos1;
				case DUGOUT_2 :
					return _dugoutPos2;
				default :
					return new Point(0, 0);
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get basePos1():Point
		{
			return _basePos1;
		}
		public function set basePos1(value:Point):void
		{
			if (value == _basePos1) return;
			_basePos1 = value;
		}
		
		public function get basePos2():Point
		{
			return _basePos2;
		}
		public function set basePos2(value:Point):void
		{
			if (value == _basePos2) return;
			_basePos2 = value;
		}
		
		public function get basePos3():Point
		{
			return _basePos3;
		}
		public function set basePos3(value:Point):void
		{
			if (value == _basePos3) return;
			_basePos3 = value;
		}
		
		public function get moundPos():Point
		{
			return _moundPos;
		}
		public function set moundPos(value:Point):void
		{
			if (value == _moundPos) return;
			_moundPos = value;
		}
		
		public function get team1():LiveGameTeam
		{
			return _team1;
		}
		public function set team1(value:LiveGameTeam):void
		{
			_team1 = value;
		}
		
		public function get team2():LiveGameTeam
		{
			return _team2;
		}
		public function set team2(value:LiveGameTeam):void
		{
			_team2 = value;
		}
		
	}
}