package com.sdg.gameMenus
{
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class BaseballScoreboard extends Sprite
	{
		protected const INNING_WIDTH:Number = 60;
		protected const INNING_HEIGHT:Number = 64;
		protected const RHE_WIDTH:Number = 84;
		protected const RHE_HEIGHT:Number = 56;

		protected const SCOREBOARD_HEIGHT:Number = 130;

		protected const BORDER_THICKNESS:Number = 1;

		protected var _width:Number;
		protected var _height:Number;
		protected var _innings:Sprite;
		protected var _rhe:Sprite;

		public function BaseballScoreboard(inningsString:String, runsString:String, hitsString:String, errorsString:String,
										homeAvatar:String, homeTeam:String, homeTeamId:int,
										awayAvatar:String, awayTeam:String, awayTeamId:int,
										isHome:Boolean, width:Number = 925, height:Number = 260)
		{
			super();
			_width = width;
			_height = height;

			var rheArray:Array;
			rheArray = runsString.split("-");
			var homeScore:int = rheArray[0];
			var awayScore:int = rheArray[1];
			rheArray = hitsString.split("-");
			var homeHits:int = rheArray[0];
			var awayHits:int = rheArray[1];
			rheArray = errorsString.split("-");
			var homeErrors:int = rheArray[0];
			var awayErrors:int = rheArray[1];

			var scoreboard:DisplayObject = createScoreboard(inningsString, homeScore, awayScore, homeHits, awayHits, homeErrors, awayErrors);

			var awayTeamBlock:Sprite = createTeamBlock(awayTeamId, awayTeam, awayAvatar, false);
			addChild(awayTeamBlock);
			var homeTeamBlock:Sprite = createTeamBlock(homeTeamId, homeTeam, homeAvatar, true);
			homeTeamBlock.y = _height - homeTeamBlock.height;
			addChild(homeTeamBlock);

			var homeWLDisplay:DisplayObject;
			var awayWLDisplay:DisplayObject;

			if (isHome)
			{
				if (homeScore > awayScore)
				{
					homeWLDisplay = createDisplay("swfs/rbi/results_YOUWIN.swf");
					awayWLDisplay = createDisplay("swfs/rbi/results_LOSER.swf");
				}
				else if (homeScore < awayScore)
				{
					homeWLDisplay = createDisplay("swfs/rbi/results_YOULOSE.swf");
					awayWLDisplay = createDisplay("swfs/rbi/results_WINNER.swf");
				}
			}
			else
			{
				if (homeScore > awayScore)
				{
					homeWLDisplay = createDisplay("swfs/rbi/results_WINNER.swf");
					awayWLDisplay = createDisplay("swfs/rbi/results_YOULOSE.swf");
				}
				else if (homeScore < awayScore)
				{
					homeWLDisplay = createDisplay("swfs/rbi/results_LOSER.swf");
					awayWLDisplay = createDisplay("swfs/rbi/results_YOUWIN.swf");
				}
			}

			function createDisplay(url:String):DisplayObject
			{
				var display:DisplayObject = new QuickLoader(url, onComplete);
				addChild(display);
				return display;
			}

			function onComplete():void
			{
				if (homeWLDisplay)
				{
					homeWLDisplay.x = 650;
					homeWLDisplay.y = scoreboard.y + scoreboard.height + 15;
				}

				if (awayWLDisplay)
				{
					awayWLDisplay.x = 650;
					awayWLDisplay.y = scoreboard.y - 15 - homeWLDisplay.height
				}
			}
		}

		protected function createScoreboard(inningsString:String, homeRuns:int, awayRuns:int, homeHits:int, awayHits:int, homeErrors:int, awayErrors:int):DisplayObject
		{
			var scoreboardBorder:Sprite = new Sprite();
			var scoreboard:Sprite = new Sprite();

			_innings = new Sprite();

			var inningsArray:Array = inningsString.split(",");
			for (var i:int = 0; i < 10; i++)
			{
				var homeScore:int = 0;
				var awayScore:int = 0;
				var isPlayed:Boolean = false;
				if (inningsArray[i] != null)
				{
					var scoresArray:Array = inningsArray[i].split("-");
					homeScore = scoresArray[0];
					awayScore = scoresArray[1];
					isPlayed = true;
				}
				var inningBlock:Sprite = createInningBlock(i+1, homeScore, awayScore, isPlayed);
				inningBlock.x = INNING_WIDTH * i;
				_innings.addChild(inningBlock);
			}
			scoreboard.addChild(_innings);

			_rhe = new Sprite();

			var rheBlock:Sprite;

			rheBlock = createRHEBlock(homeRuns, awayRuns);
			rheBlock.x = RHE_WIDTH * 0;
			_rhe.addChild(rheBlock);

			rheBlock = createRHEBlock(homeHits, awayHits);
			rheBlock.x = RHE_WIDTH * 1;
			_rhe.addChild(rheBlock);

			rheBlock = createRHEBlock(homeErrors, awayErrors);
			rheBlock.x = RHE_WIDTH * 2;
			_rhe.addChild(rheBlock);

			_rhe.x = _innings.x + _innings.width - BORDER_THICKNESS;
			scoreboard.addChild(_rhe);

			var labels:Sprite = new Sprite();
			labels.graphics.lineStyle(BORDER_THICKNESS, 0x718799);
			labels.graphics.beginFill(0xffffff);
			labels.graphics.drawRect(BORDER_THICKNESS/2, BORDER_THICKNESS/2, _rhe.width - BORDER_THICKNESS, SCOREBOARD_HEIGHT - 2*RHE_HEIGHT - BORDER_THICKNESS);
			labels.x = _rhe.width/2 - labels.width/2;
			labels.y = _rhe.height/2 - labels.height/2;
			_rhe.addChild(labels);

			var runsField:TextField = new TextField();
			runsField.defaultTextFormat = new TextFormat('EuroStyle', 12, 0x718799, true);
			runsField.embedFonts = true;
			runsField.autoSize = TextFieldAutoSize.LEFT;
			runsField.selectable = false;
			runsField.mouseEnabled = false;
			runsField.text = "RUNS";
			runsField.x = BORDER_THICKNESS + RHE_WIDTH/2 - runsField.width/2;
			runsField.y = labels.height/2 - runsField.height/2;
			labels.addChild(runsField);

			var hitsField:TextField = new TextField();
			hitsField.defaultTextFormat = new TextFormat('EuroStyle', 12, 0x718799, true);
			hitsField.embedFonts = true;
			hitsField.autoSize = TextFieldAutoSize.LEFT;
			hitsField.selectable = false;
			hitsField.mouseEnabled = false;
			hitsField.text = "HITS";
			hitsField.x = BORDER_THICKNESS + 3*RHE_WIDTH/2 - hitsField.width/2;
			hitsField.y = labels.height/2 - hitsField.height/2;
			labels.addChild(hitsField);

			var errorsField:TextField = new TextField();
			errorsField.defaultTextFormat = new TextFormat('EuroStyle', 12, 0x718799, true);
			errorsField.embedFonts = true;
			errorsField.autoSize = TextFieldAutoSize.LEFT;
			errorsField.selectable = false;
			errorsField.mouseEnabled = false;
			errorsField.text = "ERRORS";
			errorsField.x = BORDER_THICKNESS + 5*RHE_WIDTH/2 - errorsField.width/2;
			errorsField.y = labels.height/2 - errorsField.height/2;
			labels.addChild(errorsField);

			scoreboardBorder.graphics.beginFill(0x718799);
			scoreboardBorder.graphics.drawRect(0, 0, scoreboard.width + 4, scoreboard.height + 4);

			scoreboard.x = scoreboardBorder.width/2 - scoreboard.width/2;
			scoreboard.y = scoreboardBorder.height/2 - scoreboard.height/2;

			scoreboardBorder.addChild(scoreboard);
			scoreboardBorder.x = _width/2 - scoreboardBorder.width/2;
			scoreboardBorder.y = _height/2 - scoreboardBorder.height/2;
			scoreboardBorder.filters = [new DropShadowFilter(6)];
			addChild(scoreboardBorder);

			return scoreboardBorder;
		}

		protected function createTeamBlock(teamId:int, teamName:String, avatarName:String, isHome:Boolean):Sprite
		{
			var block:Sprite = new Sprite();

			var homeAwayContainer:Sprite = new Sprite();
			block.addChild(homeAwayContainer);

			var homeAwayField:TextField = new TextField();
			homeAwayField.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			homeAwayField.embedFonts = true;
			homeAwayField.autoSize = TextFieldAutoSize.LEFT
			homeAwayField.selectable = false;
			homeAwayField.mouseEnabled = false;
			homeAwayField.text = isHome ? "HOME" : "AWAY";
			homeAwayField.rotation = 270;
			homeAwayField.y = homeAwayField.height;
			homeAwayContainer.addChild(homeAwayField);

			var teamIcon:DisplayObject = new QuickLoader(AssetUtil.GetTeamLogoUrl(teamId), onComplete);
			var fieldsContainer:Sprite = new Sprite();

			var nameField:TextField = new TextField();
			nameField.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xffffff, true);
			nameField.embedFonts = true;
			nameField.autoSize = TextFieldAutoSize.LEFT;
			nameField.selectable = false;
			nameField.mouseEnabled = false;
			nameField.text = avatarName;
			fieldsContainer.addChild(nameField);

			var teamField:TextField = new TextField();
			teamField.defaultTextFormat = new TextFormat('EuroStyle', 15, 0x718799, true);
			teamField.embedFonts = true;
			teamField.autoSize = TextFieldAutoSize.LEFT;
			teamField.selectable = false;
			teamField.mouseEnabled = false;
			teamField.text = teamName;
			teamField.y = nameField.height - 5;
			fieldsContainer.addChild(teamField);

			block.addChild(fieldsContainer);

			function onComplete():void
			{
				teamIcon.scaleX = teamIcon.scaleY = .65;
				block.addChild(teamIcon);

				var blockHeight:Number = Math.max(fieldsContainer.height, teamIcon.height);
				homeAwayContainer.x = 20;
				homeAwayContainer.y = blockHeight/2 - homeAwayContainer.height/2;
				teamIcon.x = homeAwayContainer.x + homeAwayContainer.width + 10;
				teamIcon.y = blockHeight/2 - teamIcon.height/2;
				fieldsContainer.x = teamIcon.x + teamIcon.width + 10;
				fieldsContainer.y = blockHeight/2 - fieldsContainer.height/2;
			}

			return block;
		}

		protected function createInningBlock(inning:int, homeScore:int, awayScore:int, isPlayed:Boolean):Sprite
		{
			var block:Sprite = new Sprite();
			block.graphics.beginFill(0x718799);
			block.graphics.drawRect(0, 0, INNING_WIDTH + 2*BORDER_THICKNESS, SCOREBOARD_HEIGHT + 2*BORDER_THICKNESS);

			var topInning:Sprite = new Sprite();
			topInning.graphics.beginFill(0xB8C0C7);
			topInning.graphics.drawRect(0, 0, INNING_WIDTH, INNING_HEIGHT);
			topInning.x = block.width/2 - topInning.width/2;
			topInning.y = BORDER_THICKNESS;
			block.addChild(topInning);

			var bottomInning:Sprite = new Sprite();
			bottomInning.graphics.beginFill(0xB8C0C7);
			bottomInning.graphics.drawRect(0, 0, INNING_WIDTH, INNING_HEIGHT);
			bottomInning.x = block.width/2 - bottomInning.width/2;
			bottomInning.y = block.height - BORDER_THICKNESS - bottomInning.height;
			block.addChild(bottomInning);

			var awayScoreField:TextField = new TextField();
			awayScoreField.defaultTextFormat = new TextFormat('EuroStyle', 30, 0x335580, true);
			awayScoreField.embedFonts = true;
			awayScoreField.autoSize = TextFieldAutoSize.LEFT;
			awayScoreField.selectable = false;
			awayScoreField.mouseEnabled = false;
			awayScoreField.text = awayScore.toString();
			awayScoreField.x = topInning.width/2 - awayScoreField.width/2;
			awayScoreField.y = topInning.height/2 - awayScoreField.height/2;
			topInning.addChild(awayScoreField);

			var homeScoreField:TextField = new TextField();
			homeScoreField.defaultTextFormat = new TextFormat('EuroStyle', 30, 0x335580, true);
			homeScoreField.embedFonts = true;
			homeScoreField.autoSize = TextFieldAutoSize.LEFT;
			homeScoreField.selectable = false;
			homeScoreField.mouseEnabled = false;
			homeScoreField.text = homeScore.toString();
			homeScoreField.x = bottomInning.width/2 - homeScoreField.width/2;
			homeScoreField.y = bottomInning.height/2 - homeScoreField.height/2;
			bottomInning.addChild(homeScoreField);

			var inningNumBlock:Sprite = new Sprite();
			inningNumBlock.graphics.lineStyle(1, 0x718799);
			inningNumBlock.graphics.drawRect(0, 0, 18, 18);
			inningNumBlock.x = BORDER_THICKNESS;
			inningNumBlock.y = BORDER_THICKNESS;
			block.addChild(inningNumBlock);

			var inningField:TextField = new TextField();
			inningField.defaultTextFormat = new TextFormat('EuroStyle', 11, 0xffffff, true);
			inningField.embedFonts = true;
			inningField.autoSize = TextFieldAutoSize.LEFT;
			inningField.selectable = false;
			inningField.mouseEnabled = false;
			inningField.text = inning.toString();
			inningField.x = inningNumBlock.width/2 - inningField.width/2;
			inningField.y = inningNumBlock.height/2 - inningField.height/2;
			inningNumBlock.addChild(inningField);

			return block;
		}

		protected function createRHEBlock(homeRHE:int = 0, awayRHE:int = 0):Sprite
		{
			var block:Sprite = new Sprite();
			block.graphics.beginFill(0x718799);
			block.graphics.drawRect(0, 0, RHE_WIDTH + 2*BORDER_THICKNESS, SCOREBOARD_HEIGHT + 2*BORDER_THICKNESS);

			var topBox:Sprite = new Sprite();
			topBox.graphics.beginFill(0xffffff);
			topBox.graphics.drawRect(0, 0, RHE_WIDTH, RHE_HEIGHT);
			topBox.x = block.width/2 - topBox.width/2;
			topBox.y = BORDER_THICKNESS;
			block.addChild(topBox);

			var bottomBox:Sprite = new Sprite();
			bottomBox.graphics.beginFill(0xffffff);
			bottomBox.graphics.drawRect(0, 0, RHE_WIDTH, RHE_HEIGHT);
			bottomBox.x = block.width/2 - bottomBox.width/2;
			bottomBox.y = block.height - BORDER_THICKNESS - bottomBox.height;
			block.addChild(bottomBox);

			var awayRHEField:TextField = new TextField();
			awayRHEField.defaultTextFormat = new TextFormat('EuroStyle', 40, 0x335580, true);
			awayRHEField.embedFonts = true;
			awayRHEField.autoSize = TextFieldAutoSize.LEFT;
			awayRHEField.selectable = false;
			awayRHEField.mouseEnabled = false;
			awayRHEField.text = awayRHE.toString();
			awayRHEField.x = topBox.width/2 - awayRHEField.width/2;
			awayRHEField.y = topBox.height/2 - awayRHEField.height/2;
			topBox.addChild(awayRHEField);

			var homeRHEField:TextField = new TextField();
			homeRHEField.defaultTextFormat = new TextFormat('EuroStyle', 40, 0x335580, true);
			homeRHEField.embedFonts = true;
			homeRHEField.autoSize = TextFieldAutoSize.LEFT;
			homeRHEField.selectable = false;
			homeRHEField.mouseEnabled = false;
			homeRHEField.text = homeRHE.toString();
			homeRHEField.x = bottomBox.width/2 - homeRHEField.width/2;
			homeRHEField.y = bottomBox.height/2 - homeRHEField.height/2;
			bottomBox.addChild(homeRHEField);

			return block;
		}
	}
}
