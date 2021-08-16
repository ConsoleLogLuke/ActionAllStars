package com.sdg.view
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.events.SaveFavTeamsEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Team;
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.core.UIComponent;
	
	[Event(name="topTeamChanged", type="flash.events.Event")]
	
	public class ChangeTopTeam extends UIComponent
	{
		private var _background:DisplayObject;
		private var _basketballLogo:TeamIconUncropped;
		private var _baseballLogo:TeamIconUncropped;
		private var _footballLogo:TeamIconUncropped;
		private var _selectionIndicator:Sprite;
		private var _basketballTeam:Team;
		private var _baseballTeam:Team;
		private var _footballTeam:Team;
		private var _topTeam:Team;
		private var _closeButton:Sprite;
		private var _teamsInitialized:Boolean;
		private var _message:TextField;
		private var _topTeamChanged:Boolean;
		
		public function ChangeTopTeam()
		{
			super();
			_teamsInitialized = false;
			_topTeamChanged = false;
		}
		
		public function setTeams(basketball:Team, baseball:Team, football:Team):void
		{
			_basketballTeam = basketball;
			_baseballTeam = baseball;
			_footballTeam = football;
			
			if (_background == null)
				init();
			
			if (_basketballTeam == null && _baseballTeam == null && _footballTeam == null)
			{
				showChooseTeamMessage()
			}
			else
			{
				if (!_teamsInitialized)
					initTeams();
				else
					update();
			}
		}
		
		private function showChooseTeamMessage():void
		{
			if (_message == null)
			{
				_message = new TextField();
				_message.embedFonts = true;
				_message.defaultTextFormat = new TextFormat('EuroStyle', 11, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
				
				_message.autoSize = TextFieldAutoSize.CENTER;
				_message.selectable = false;
				_message.mouseEnabled = false;
				_message.wordWrap = true;
				_message.text = "Head over to Blake's Place to select your favorite teams.";
				addChild(_message);
			}
		}
		
		private function initTeams():void
		{
			_teamsInitialized = true;
			if (_message)
			{
				removeChild(_message);
				_message = null;
			}
			
			_selectionIndicator = new Sprite();
			_selectionIndicator.graphics.beginFill(0xbbbbbb);
			_selectionIndicator.graphics.drawRect(0, 0, 42, 42);
			_selectionIndicator.visible = false;
			
			if (_basketballTeam == null)
				_basketballLogo = new TeamIconUncropped(34, 34, 0x999999, 0x333333, 0, "assets/swfs/teamAffinity/iconBasketball.swf");
			else
				_basketballLogo = new TeamIconUncropped(34, 34, _basketballTeam.teamColor1, _basketballTeam.teamColor2, _basketballTeam.teamId);
			
			
			if (_baseballTeam == null)
				_baseballLogo = new TeamIconUncropped(34, 34, 0x999999, 0x333333, 0, "assets/swfs/teamAffinity/iconBaseball.swf");
			else
				_baseballLogo = new TeamIconUncropped(34, 34, _baseballTeam.teamColor1, _baseballTeam.teamColor2, _baseballTeam.teamId);
			
			
			if (_footballTeam == null)
				_footballLogo = new TeamIconUncropped(34, 34, 0x999999, 0x333333, 0, "assets/swfs/teamAffinity/iconFootball.swf");
			else
				_footballLogo = new TeamIconUncropped(34, 34, _footballTeam.teamColor1, _footballTeam.teamColor2, _footballTeam.teamId);
			
			addChild(_selectionIndicator);
			addChild(_basketballLogo);
			addChild(_baseballLogo);
			addChild(_footballLogo);
				
			_basketballLogo.buttonMode = true;
			_basketballLogo.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {onClick(event, _basketballTeam)});
				
			_baseballLogo.buttonMode = true;
			_baseballLogo.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {onClick(event, _baseballTeam)});
				
			_footballLogo.buttonMode = true;
			_footballLogo.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {onClick(event, _footballTeam)});
				
			render();
		}
		
		private function init():void
		{
			_background = new QuickLoader("assets/swfs/teamAffinity/changeTopTeamBG.swf", onComplete);
			addChild(_background);
			
			_closeButton = new Sprite();
			var closeX:TextField = new TextField();
			closeX.defaultTextFormat = new TextFormat('Arial', 14, 0xffffff, true);
			closeX.autoSize = TextFieldAutoSize.LEFT;
			closeX.selectable = false;
			closeX.mouseEnabled = false;
			closeX.text = "X";
			_closeButton.addChild(closeX);
			
			function onComplete():void
			{
				addChild(_closeButton);
				
				_closeButton.buttonMode = true;
				_closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
				
				render();
			}
		}
		
		private function onCloseClick(event:MouseEvent):void
		{
			if (_topTeamChanged)
			{
				var params:Object = new Object();
				var avatar:Avatar = ModelLocator.getInstance().avatar;
				
				var teamArray:Array = avatar.favoriteTeams;
				var favTeam:Team = avatar.favoriteTeam;
				var index:int = 1;
				
				for each(var team:Team in teamArray)
				{
					params["team" + index] = team.teamId;
					if (team == favTeam)
						params.teamFlag = index;
					
					index++;
				}
				
				CairngormEventDispatcher.getInstance().dispatchEvent(new SaveFavTeamsEvent(params));
				_topTeamChanged = false;
			}
			this.visible = false;
		}
		
		private function onClick(event:MouseEvent, team:Team):void
		{
			selectTopTeam(team, event.currentTarget as TeamIconUncropped);
		}
				
		private function render():void
		{
			if (_basketballLogo)
			{
				_basketballLogo.x = _background.width/4 - 3*_basketballLogo.width/4;
				_basketballLogo.y = 28;
			}
			
			if (_baseballLogo)
			{
				_baseballLogo.x = _background.width/2 - _baseballLogo.width/2;
				_baseballLogo.y = 28;
			}
			
			if (_footballLogo)
			{
				_footballLogo.x = 3*_background.width/4 - _footballLogo.width/4;
				_footballLogo.y = 28;
			}
			
			if (_message)
			{
				_message.width = _background.width - 10;
				_message.x = _background.width/2 - _message.width/2;
				_message.y = 23;
			}
			
			_closeButton.x = _background.width - _closeButton.width - 8;
			_closeButton.y = 1;
			
			topTeam = _topTeam;
		}
		
		private function update():void
		{
			if (_basketballTeam)
				_basketballLogo.setParams(_basketballTeam.teamId, _basketballTeam.teamColor1, _basketballTeam.teamColor2);
			if (_baseballTeam)
				_baseballLogo.setParams(_baseballTeam.teamId, _baseballTeam.teamColor1, _baseballTeam.teamColor2);
			if (_footballTeam)
				_footballLogo.setParams(_footballTeam.teamId, _footballTeam.teamColor1, _footballTeam.teamColor2);
		}
		
		private function selectTopTeam(team:Team, icon:TeamIconUncropped):void
		{
			if (team == null) return;
			if (icon == null) return;
			
			_topTeam = team;

			_selectionIndicator.x = icon.x + icon.width/2 - _selectionIndicator.width/2;
			_selectionIndicator.y = icon.y + icon.height/2 - _selectionIndicator.height/2;
			_selectionIndicator.visible = true;
			
			ModelLocator.getInstance().avatar.favoriteLeagueId = team.leagueId;
			
			_topTeamChanged = true;
			dispatchEvent(new Event("topTeamChanged"));
		}
		
		public function set topTeam(team:Team):void
		{
			var topTeamIcon:TeamIconUncropped;
			switch (team)
			{
				case _basketballTeam:
					topTeamIcon = _basketballLogo;
					break;
				case _baseballTeam:
					topTeamIcon = _baseballLogo;
					break;
				case _footballTeam:
					topTeamIcon = _footballLogo;
					break;
			}
			
			selectTopTeam(team, topTeamIcon);
		}
		
		public function get topTeam():Team
		{
			return _topTeam
		}
	}
}