package com.sdg.game.views
{
	import com.sdg.game.events.UnityNBAEvent;
	import com.sdg.game.models.UnityNBATeam;
	import com.sdg.net.QuickLoader;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class OpponentTeamDisplay extends Sprite
	{
		private var _team:UnityNBATeam;
		private var _width:Number;
		private var _height:Number;

		private var _teamLogoDisplay:TeamLogoDisplay;
		private var _teamNameText:TextField;
		private var _textFormat:TextFormat;

		private var _selected:Boolean;
		private var _isLocked:Boolean;

		private var _isDefeatedLogo:DisplayObject;
		private var _lockedIcon:DisplayObject;

		public function OpponentTeamDisplay(team:UnityNBATeam)
		{
			super();

			_team = team;
			mouseChildren = false;
		}

		private function setSelectedHighlight():void
		{
			drawBox(1, .5);
		}

		private function setMouseOverHighlight():void
		{
			drawBox(.4, .2);
		}

		private function turnOffHighlight():void
		{
			drawBox(0, 0);
		}

		private function drawBox(lineAlpha:Number, boxAlpha:Number):void
		{
			graphics.clear();
			graphics.lineStyle(2, 0xffffff, lineAlpha);
			graphics.beginFill(0xffffff, boxAlpha);
			graphics.drawRect(0, 0, 170, 180);
			graphics.endFill();
		}

		public function get isDefeated():Boolean
		{
			return _team.isDefeated;
		}

		public function set isLocked(value:Boolean):void
		{
			_isLocked = value;

			if (_isLocked == true)
			{
				removeEventListeners();
			}
			else
			{
				addEventListeners();
			}
		}

		private function addEventListeners():void
		{
			addEventListener(MouseEvent.CLICK, onTeamClick, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OVER, onTeamMouseOver, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, onTeamMouseOut, false, 0, true);
		}

		private function removeEventListeners():void
		{
			removeEventListener(MouseEvent.CLICK, onTeamClick);
			removeEventListener(MouseEvent.MOUSE_OVER, onTeamMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onTeamMouseOut);
		}

		private function onTeamClick(event:MouseEvent):void
		{
			selected = true;
		}

		private function onTeamMouseOver(event:MouseEvent):void
		{
			mouseOver = true;
		}

		private function onTeamMouseOut(event:MouseEvent):void
		{
			mouseOver = false;
		}

		public function get team():UnityNBATeam
		{
			return _team;
		}

		private function set teamNameTextColor(value:uint):void
		{
			_textFormat.color = value
			_teamNameText.setTextFormat(_textFormat);
		}

		private function set mouseOver(value:Boolean):void
		{
			if (_selected) return;

			if (value == true)
			{
				setMouseOverHighlight();
			}
			else
			{
				turnOffHighlight();
			}
		}

		public function set selected(value:Boolean):void
		{
			if (value == _selected) return;

			_selected = value;

			if (_selected)
			{
				setSelectedHighlight();
				teamNameTextColor = 0xffffff;
				dispatchEvent(new UnityNBAEvent(UnityNBAEvent.OPPONENT_TEAM_SELECTED, true));
			}
			else
			{
				turnOffHighlight();
				teamNameTextColor = 0x000000;
			}
		}

		public function refresh():void
		{
			if (_teamLogoDisplay == null)
			{
				_teamLogoDisplay = new TeamLogoDisplay(_team, 170, 140);
				addChild(_teamLogoDisplay);
			}
			else
			{
				_teamLogoDisplay.refresh();
			}

			if (_teamNameText == null)
			{
				_textFormat = new TextFormat('EuroStyle', 14, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);

				_teamNameText = new TextField();
				_teamNameText.defaultTextFormat = _textFormat;
				_teamNameText.embedFonts = true;
				_teamNameText.autoSize = TextFieldAutoSize.CENTER;
				_teamNameText.selectable = false;
				_teamNameText.wordWrap = true;
				_teamNameText.multiline = true;
				_teamNameText.width = 166;
				addChild(_teamNameText);
				_teamNameText.text = _team.name;
				_teamNameText.x = 170/2 - _teamNameText.width/2;
				_teamNameText.y = 140;
			}

			var defeatedLogo:QuickLoader;
			var lockedIcon:QuickLoader;

			trace(_team.isDefeated);
			if (_team.isDefeated)
			{
				if (_isDefeatedLogo == null)
				{
					defeatedLogo = new QuickLoader("swfs/nbaAllStars/Defeated.swf", onDefeatedLoaded);
				}
			}

			if (_isLocked == true)
			{
				_teamLogoDisplay.alpha = .3;
				_teamNameText.alpha = .3;

				if (_lockedIcon == null)
				{
					lockedIcon = new QuickLoader("swfs/nbaAllStars/Icon_TeamLocked.swf", onLockedLoaded);
				}
			}
			else
			{
				_teamLogoDisplay.alpha = 1;
				_teamNameText.alpha = 1;
			}

			function onDefeatedLoaded():void
			{
				_isDefeatedLogo = defeatedLogo.content;
				addChild(_isDefeatedLogo);
				_isDefeatedLogo.x = 5;
				_isDefeatedLogo.y = 5;
			}

			function onLockedLoaded():void
			{
				_lockedIcon = lockedIcon.content;
				addChild(_lockedIcon);
				_lockedIcon.x = 170/2 - _lockedIcon.width/2;
				_lockedIcon.y = 180/2 - _lockedIcon.height/2;
			}
		}

		public function destroy():void
		{
			removeEventListeners();
			if (_teamLogoDisplay)
				_teamLogoDisplay.destroy();
		}
	}
}
