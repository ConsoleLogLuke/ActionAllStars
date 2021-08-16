package com.sdg.display.leaderboard
{
	import com.sdg.core.IProgressInfo;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.display.RoomItemDisplayBase;
	import com.sdg.leaderboard.model.TopUser;
	import com.sdg.leaderboard.model.TopUserCollection;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.SdgItem;
	import com.sdg.utils.StringUtil;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class InWorldLeaderboardDisplay extends RoomItemDisplayBase implements IRoomItemDisplay
	{
		protected var _names:TextField;
		protected var _scores:TextField;
		protected var _width:Number;
		protected var _height:Number;
		protected var _titleField:TextField;
		protected var _localUserColor:uint;
		
		private var _topUsers:TopUserCollection;
		private var _margin:Number;
		private var _title:String;
		private var _titleColor:uint;
		
		public function InWorldLeaderboardDisplay(item:SdgItem)
		{
			super(item);
			
			_margin = 5;
			_width = 176; // Make this DB driven if we use more of these.
			_height = 110;
			_title = 'Top Scores Today';
			_titleColor = 0xffffff;
			_localUserColor = 0x46a0c3;
			
			_names = new TextField();
			_names.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff, true, null, null, null, null, TextFormatAlign.LEFT);
			_names.autoSize = TextFieldAutoSize.LEFT;
			_names.selectable = false;
			_names.multiline = true;
			_names.embedFonts = true;
			_names.text = _title;
			
			_scores = new TextField();
			_scores.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff, true, null, null, null, null, TextFormatAlign.RIGHT);
			_scores.autoSize = TextFieldAutoSize.RIGHT;
			_scores.selectable = false;
			_scores.multiline = true;
			_scores.embedFonts = true;
			
			_titleField = new TextField();
			_titleField.defaultTextFormat = new TextFormat('EuroStyle', 14, _titleColor, true);
			_titleField.autoSize = TextFieldAutoSize.LEFT;
			_titleField.selectable = false;
			_titleField.embedFonts = true;
			_titleField.text = _title;
			
			render();
			
			addChild(_scores);
			addChild(_names);
			addChild(_titleField);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		override public function destroy():void
		{
			// Cleanup.
			
			_names = null;
			_scores = null;
			
			super.destroy();
		}
		
		public function getImageRect(update:Boolean = false):Rectangle
		{
			return getRect(this);
		}
		
		public function playAnimation(name:String):void
		{
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function render():void
		{
			renderTitle();
			
			_names.x = _margin;
			_names.y = _titleField.y + _titleField.height + _margin / 2;
			
			_scores.x = _width - _scores.width - _margin;
			_scores.y = _names.y;
		}
		
		private function renderTopUsers():void
		{
			var nameText:String = '';
			var scoreText:String = '';
			var i:int = 0;
			var len:int = _topUsers.length;
			var userNameDimensions:Array;
			var userScoreDimensions:Array;
			var localAvatar:Avatar = ModelLocator.getInstance().avatar;
			for (i; i < len; i++)
			{
				var topUser:TopUser = _topUsers.getAt(i);
				
				// If it's the local user, set up variables to format the text differently.
				if (topUser.name == localAvatar.name)
				{
					userNameDimensions = [];
					userNameDimensions.push(nameText.length);
					userScoreDimensions = [];
					userScoreDimensions.push(scoreText.length);
				}
				
				nameText += StringUtil.GetStringWithinCharacterLimit(topUser.name, 12) + '\n';
				scoreText += topUser.points + '\n';
				
				if (topUser.name == localAvatar.name)
				{
					userNameDimensions.push(nameText.length);
					userScoreDimensions.push(scoreText.length);
				}
			}
			
			_names.text = nameText;
			_scores.text = scoreText;
			
			// Determine if the local user's name is on the list and if we need to format it differently.
			if (userNameDimensions)
			{
				var format:TextFormat = _names.getTextFormat();
				format.color = _localUserColor;
				_names.setTextFormat(format, userNameDimensions[0], userNameDimensions[1] - 1);
				_scores.setTextFormat(format, userScoreDimensions[0], userScoreDimensions[1] - 1);
			}
		}
		
		private function renderTitle():void
		{
			_titleField.x = _width / 2 - _titleField.width / 2;
			_titleField.y = _margin / 2;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get topUsers():TopUserCollection
		{
			return _topUsers;
		}
		public function set topUsers(value:TopUserCollection):void
		{
			_topUsers = value;
			renderTopUsers();
		}
		
		public function get orientation():uint
		{
			return 0;
		}
		public function set orientation(value:uint):void
		{
			
		}
		
		public function get progressInfo():IProgressInfo
		{
			return null;
		}
		
		public function get content():DisplayObject
		{
			return this;
		}
		
		public function set floorMarker(value:DisplayObject):void
		{
			
		}
		
		public function get titleColor():uint
		{
			return _titleColor;
		}
		public function set titleColor(value:uint):void
		{
			if (value == _titleColor) return;
			_titleColor = value;
			// Give special formatting to beggining of name field.
			var currentFormat:TextFormat = _titleField.getTextFormat();
			currentFormat.color = _titleColor;
			_titleField.setTextFormat(currentFormat);
			_titleField.defaultTextFormat = currentFormat;
		}
		
		public function get nameColor():uint
		{
			return uint(_names.getTextFormat().color);
		}
		public function set nameColor(value:uint):void
		{
			var currentFormat:TextFormat = _names.defaultTextFormat;
			currentFormat.color = value;
			_names.defaultTextFormat = currentFormat;
			_names.setTextFormat(currentFormat);
		}
		
		public function get scoreColor():uint
		{
			return uint(_scores.getTextFormat().color);
		}
		public function set scoreColor(value:uint):void
		{
			var currentFormat:TextFormat = _scores.defaultTextFormat;
			currentFormat.color = value;
			_scores.defaultTextFormat = currentFormat;
			_scores.setTextFormat(currentFormat);
		}
		
		public function get localUserColor():uint
		{
			return _localUserColor;
		}
		public function set localUserColor(value:uint):void
		{
			if (value == _localUserColor) return;
			_localUserColor = value;
			renderTopUsers();
		}
		
		public function get title():String
		{
			return _title;
		}
		public function set title(value:String):void
		{
			if (value == _title) return;
			_title = value;
			_titleField.text = _title;
			renderTitle();
		}
		
	}
}