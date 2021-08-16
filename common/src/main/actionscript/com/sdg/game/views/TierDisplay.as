package com.sdg.game.views
{
	import com.sdg.game.models.UnityNBATeam;
	import com.sdg.game.models.UnityNBATier;
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TierDisplay extends Sprite
	{
		private var _teamDisplayArray:Array;
		private var _tierIndex:int;
		private var _tier:UnityNBATier;
		
		private var _teamsContainer:Sprite;
		private var _tierNumText:TextField;
		private var _lockedText:TextField;
		private var _textFormat:TextFormat;
		private var _lockIcon:DisplayObject;
		private var _colorTransform:ColorTransform;
		
		public function TierDisplay(tierIndex:int, tier:UnityNBATier)
		{
			super();
			
			_tierIndex = tierIndex;
			_tier = tier;
			
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(885, 40, Math.PI/2, 0, 0);
			
			graphics.beginGradientFill(GradientType.LINEAR, [0x094169, 0x3F72A2], [1, 1], [1, 255], gradientBoxMatrix);
			graphics.drawRect(0, 0, 885, 40);
			graphics.endFill();
			
			var background:QuickLoader = new QuickLoader("assets/swfs/nbaAllStars/Background_TeamTier.swf", onBackgroundLoaded);
			
			_textFormat = new TextFormat('EuroStyle', 15, 0x000000, true);
			
			_tierNumText = new TextField();
			_tierNumText.defaultTextFormat = _textFormat;
			_tierNumText.embedFonts = true;
			_tierNumText.autoSize = TextFieldAutoSize.LEFT;
			_tierNumText.selectable = false;
			addChild(_tierNumText);
			_tierNumText.text = "Tier " + _tierIndex;
			_tierNumText.x = 15
			_tierNumText.y = 40/2 - _tierNumText.height/2;
			
			_textFormat.size = 20;
			
			_lockedText = new TextField();
			_lockedText.defaultTextFormat = _textFormat;
			_lockedText.embedFonts = true;
			_lockedText.autoSize = TextFieldAutoSize.LEFT;
			_lockedText.selectable = false;
			addChild(_lockedText);
			
			_teamsContainer = new Sprite();
			addChild(_teamsContainer);
			
			populateTier();
			setLock();
			
			function onBackgroundLoaded():void
			{
				var displayContent:DisplayObject = background.content;
				addChildAt(displayContent, 0);
				displayContent.y = 40;
			}
		}
		
		private function populateTier():void
		{
			var index:int;
			var team:UnityNBATeam;
			var teamDisplay:OpponentTeamDisplay;
			
			_teamDisplayArray = new Array();
			
			var numTeams:int = _tier.teams.length;
			for (index = 0; index < numTeams; index++)
			{
				team = _tier.teams[index];
				teamDisplay = new OpponentTeamDisplay(team);
				teamDisplay.isLocked = _tier.locked;
				teamDisplay.x = index * 170;
				teamDisplay.y = 45;
				_teamsContainer.addChild(teamDisplay);
				_teamDisplayArray[index] = teamDisplay;
			}
			
			_teamsContainer.x = 885/2 - (numTeams * 170)/2;
		}
		
		private function setLock():void
		{
			var teamDisplay:OpponentTeamDisplay;
			
			var lockIconUrl:String = "assets/swfs/nbaAllStars/";
			
			if (_tier.locked)
			{
				_lockedText.text = "Locked";
				lockIconUrl += "Icon_Locked.swf";
			}
			else
			{
				_lockedText.text = "Unlocked";
				lockIconUrl += "Icon_UnLocked.swf";
			}
			
			var lockIcon:QuickLoader = new QuickLoader(lockIconUrl, onLockIconLoaded);
			
			_lockedText.x = 885 - 15 - _lockedText.width;
			_lockedText.y = 40/2 - _lockedText.height/2;
			
			if (_colorTransform == null)
			{
				_colorTransform = new ColorTransform();
				_colorTransform.color = 0x000000;
			}
			
			function onLockIconLoaded():void
			{
				_lockIcon = lockIcon.content;
				addChild(_lockIcon);
				setLockColor();
			}
		}
		
		public function destroy():void
		{
			for each (var teamDisplay:OpponentTeamDisplay in _teamDisplayArray)
			{
				teamDisplay.destroy();
			}
		}
		
		public function show():void
		{
			for each (var teamDisplay:OpponentTeamDisplay in _teamDisplayArray)
			{
				teamDisplay.refresh();
			}
			
			setText(_tierNumText, 0xffffff, 15);
			setText(_lockedText, 0xffffff, 20);
			_colorTransform.color = 0xffffff;
			setLockColor();
		}
		
		public function hide():void
		{
			setText(_tierNumText, 0x000000, 15);
			setText(_lockedText, 0x000000, 20);
			_colorTransform.color = 0x000000;
			setLockColor();
		}
		
		private function setLockColor():void
		{
			if (_lockIcon == null) return;
			
			_lockIcon.transform.colorTransform = _colorTransform;
			_lockIcon.x = 80;
			_lockIcon.y = 40/2 - _lockIcon.height/2;
		}
		
		private function setText(textField:TextField, fontColor:uint, fontSize:int):void
		{
			_textFormat.color = fontColor;
			_textFormat.size = fontSize;
			textField.setTextFormat(_textFormat);
		}
		
		public function get tierIndex():int
		{
			return _tierIndex;
		}
		
		public function get notDefeatedTeam():OpponentTeamDisplay
		{
			var teamDisplay:OpponentTeamDisplay;
			
			for each (teamDisplay in _teamDisplayArray)
			{
				if (teamDisplay.isDefeated == false)
				{
					break;
				}
			}
			
			return teamDisplay;
		}
	}
}