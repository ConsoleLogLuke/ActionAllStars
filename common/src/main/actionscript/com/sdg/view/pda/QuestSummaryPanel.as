package com.sdg.view.pda
{
	import com.sdg.buttonstyle.AASBlueButtonStyle;
	import com.sdg.controls.BasicButton;
	import com.sdg.events.QuestCardEvent;
	import com.sdg.events.QuestMovieEvent;
	import com.sdg.model.AvatarAchievement;
	import com.sdg.model.GameAssetId;
	import com.sdg.net.QuickLoader;
	import com.sdg.quest.QuestCutSceneFlag;
	import com.sdg.util.AssetUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class QuestSummaryPanel extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		private var _viewCardButton:BasicButton;
		private var _watchVideoButton:BasicButton;
		private var _deleteQuestButton:BasicButton;
		private var _descriptionField:TextField;
		private var _quest:AvatarAchievement;
		private var _isCompleteGraphic:DisplayObject;
		
		public function QuestSummaryPanel(quest:AvatarAchievement, width:Number, height:Number)
		{
			super();
			
			// Set default values.
			_width = 300;
			_height = 340;
			_quest = quest;
			
			// Build visual elements.
			var buttonStyle:AASBlueButtonStyle = new AASBlueButtonStyle();
			var labelFormat:TextFormat = new TextFormat('GillSans', 13, 0xffffff);
			_viewCardButton = new BasicButton('View Card', 100, 30, buttonStyle);
			_viewCardButton.label.setTextFormat(labelFormat);
			_viewCardButton.label.embedFonts = true;
			_viewCardButton.addEventListener(MouseEvent.CLICK, onViewCardClick);
			addChild(_viewCardButton);
			
			// Determine a label for the cut scene button.
			// Based on the type of cut scene associated with
			// the quest.
			var cutSceneLabel:String = (_quest.cutSceneFlag == QuestCutSceneFlag.PROGRESS) ? 'View Progress' : 'Watch Video';
			
			_watchVideoButton = new BasicButton(cutSceneLabel, 100, 30, buttonStyle);
			_watchVideoButton.label.setTextFormat(labelFormat);
			_watchVideoButton.label.embedFonts = true;
			_watchVideoButton.addEventListener(MouseEvent.CLICK, onWatchVideoClick);
			addChild(_watchVideoButton);
			
			_descriptionField = new TextField();
			_descriptionField.defaultTextFormat = new TextFormat('GillSans', 18, 0xffffff);
			_descriptionField.multiline = _descriptionField.wordWrap = true;
			_descriptionField.text = quest.description;
			_descriptionField.embedFonts = true;
			addChild(_descriptionField);
			
			// Determine graphic url.
			// Load the graphic and display it.
			var graphicUrl:String = (_quest.isComplete == true) ?  AssetUtil.GetGameAssetUrl(GameAssetId.WORLD, 'mission_completed.swf') : AssetUtil.GetGameAssetUrl(GameAssetId.WORLD, 'mission_not_completed.swf');
			// When the graphic loads, render will be called.
			_isCompleteGraphic = new QuickLoader(graphicUrl, render);
			addChild(_isCompleteGraphic);
			
			render();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		private function render():void
		{
			var spacing:Number = 10;
			
			// Render each element.
			_viewCardButton.x = spacing;
			_viewCardButton.y = spacing;
			
			_watchVideoButton.x = _viewCardButton.x + _viewCardButton.width + spacing;
			_watchVideoButton.y = spacing;
			
			// Determine if the cutscene button should be visible.
			if (_quest.cutSceneFlag == QuestCutSceneFlag.STANDARD_RESOLVE)
			{
				// If it's a standard resolve cut scene,
				// only show the button if the quest is
				// complete.
				_watchVideoButton.visible = (_quest.isComplete == true) ? true : false;
			}
			else if (_quest.cutSceneFlag == QuestCutSceneFlag.PROGRESS)
			{
				// If it's a progress cut scene,
				// show the button.
				_watchVideoButton.visible = true;
			}
			else
			{
				// If this quest does not have a
				// cut scene, do not show the button.
				_watchVideoButton.visible = false;
			}
		
			
			_descriptionField.x = spacing;
			_descriptionField.y = _viewCardButton.y + _viewCardButton.height + spacing;
			_descriptionField.width = _width - spacing * 2;
			_descriptionField.height = _height - _descriptionField.y - spacing;
			
			_isCompleteGraphic.x = _width / 2 - _isCompleteGraphic.width / 2;
			_isCompleteGraphic.y = _height - _isCompleteGraphic.height - spacing * 2;
		}
		
		public function destroy():void
		{
			// Handle cleanup.
			
			// Remove event listeners.
			_watchVideoButton.removeEventListener(MouseEvent.CLICK, onWatchVideoClick);
			_viewCardButton.removeEventListener(MouseEvent.CLICK, onViewCardClick);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onWatchVideoClick(e:MouseEvent):void
		{
			// Launch a cutscene for the quest.
			// Make sure there is a cutscene.
			if (_quest.hasCutscene == false) return;
			// The quest has a cutscene.
			
			// If the cut scene is a standard resolve,
			// make sure the quest has been completed 
			// before we can show the video.
			if (_quest.cutSceneFlag == QuestCutSceneFlag.STANDARD_RESOLVE && _quest.isComplete != true) return;
			
			// Show the cutscene.
			// Dispatch an event to show the cutscene.
			var event:QuestMovieEvent = new QuestMovieEvent(QuestMovieEvent.SHOW_MOVIE, _quest, true, false);
			dispatchEvent(event);
		}
		
		private function onViewCardClick(e:MouseEvent):void
		{
			// Dispatch a show quest card event.
			var questCardEvent:QuestCardEvent = new QuestCardEvent(QuestCardEvent.SHOW_CARD, _quest, true, false);
			dispatchEvent(questCardEvent);
		}
		
	}
}