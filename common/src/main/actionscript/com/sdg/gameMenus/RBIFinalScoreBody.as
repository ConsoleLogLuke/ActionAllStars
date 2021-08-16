package com.sdg.gameMenus
{
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class RBIFinalScoreBody extends GradientGameBody
	{
		protected var _finishedButton:RBIMenuButton;
		
		public function RBIFinalScoreBody(resultXml:XML, width:Number = 925, height:Number = 515)
		{
			super("FINAL SCORE", width, height);
			
			var scoreboard:BaseballScoreboard = new BaseballScoreboard(resultXml.inning, resultXml.runs, resultXml.hits, resultXml.errors,
																	resultXml.homeAvatarName, resultXml.homeTeamName, resultXml.homeTeamId,
																	resultXml.awayAvatarName, resultXml.awayTeamName, resultXml.awayTeamId,
																	resultXml.homeAvatarName.toString() == resultXml.avatarName.toString(), width);
			addChild(scoreboard);
			scoreboard.y = 20;
			
			var awardsBG:DisplayObject = new QuickLoader("assets/swfs/rbi/awardsBG.swf", onComplete);
			
			function onComplete():void
			{
				var awardsContainer:Sprite = new Sprite();
				
				awardsBG.y = 30;
				awardsContainer.addChild(awardsBG);
				
				awardsContainer.graphics.beginFill(0xffffff);
				awardsContainer.graphics.drawRect(0, 0, awardsContainer.width, awardsContainer.height);
				awardsContainer.y = _height - awardsContainer.height;
				addChild(awardsContainer);
				
				var tokensField:TextField = new TextField();
				tokensField.defaultTextFormat = new TextFormat('EuroStyle', 44, 0x718799, true);
				tokensField.embedFonts = true;
				tokensField.autoSize = TextFieldAutoSize.LEFT;
				tokensField.selectable = false;
				tokensField.mouseEnabled = false;
				tokensField.text = resultXml.tokensEarned;
				tokensField.x = 90 - tokensField.width/2;
				tokensField.y = 55;
				awardsContainer.addChild(tokensField);
				
				var xpField:TextField = new TextField();
				xpField.defaultTextFormat = new TextFormat('EuroStyle', 44, 0x718799, true);
				xpField.embedFonts = true;
				xpField.autoSize = TextFieldAutoSize.LEFT;
				xpField.selectable = false;
				xpField.mouseEnabled = false;
				xpField.text = resultXml.experienceEarned;
				xpField.x = 235 - xpField.width/2;
				xpField.y = 55;
				awardsContainer.addChild(xpField);
				
				_finishedButton = new RBIMenuButton("BACK TO WORLD", 200, 55, 10, 20);
				_finishedButton.addEventListener(MouseEvent.CLICK, onFinishedClick)
				_finishedButton.x = 665;
				_finishedButton.y = 150;
				
				awardsContainer.addChild(_finishedButton);
			}
		}
		
		protected function onFinishedClick(event:MouseEvent):void
		{
			dispatchEvent(new Event("quit game"));
		}
		
		public function destroy():void
		{
			_finishedButton.removeEventListener(MouseEvent.CLICK, onFinishedClick);
		}
	}
}