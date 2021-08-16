package com.sdg.model
{
	public class AvatarLevelStatus extends Object
	{
		protected var _avatarId:uint;
		protected var _levelIndex:uint;
		protected var _levelName:String;
		protected var _subLevelIndex:uint;
		protected var _subLevelName:String;
		protected var _currentXp:uint;
		protected var _nextLevelXp:uint;
		protected var _levelColor:uint;
		protected var _currentSubLevelMinXp:uint;
		
		public function AvatarLevelStatus(avatarId:uint, levelIndex:uint, levelName:String, levelColor:uint, subLevelIndex:uint, subLevelName:String, currentXp:uint, currentSubLevelMinXp:uint, nextLevelXp:uint)
		{
			super();
			
			_avatarId = avatarId;
			_levelIndex = levelIndex;
			_levelName = levelName;
			_levelColor = levelColor;
			_subLevelIndex = subLevelIndex;
			_subLevelName = subLevelName;
			_currentXp = currentXp;
			_nextLevelXp = nextLevelXp;
			_currentSubLevelMinXp = currentSubLevelMinXp;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
		
		public function get levelIndex():uint
		{
			return _levelIndex;
		}
		
		public function get levelName():String
		{
			return _levelName;
		}
		
		public function get levelColor():uint
		{
			return _levelColor;
		}
		
		public function get subLevelIndex():uint
		{
			return _subLevelIndex;
		}
		
		public function get subLevelName():String
		{
			return _subLevelName;
		}
		
		public function get currentXp():uint
		{
			return _currentXp;
		}
		
		public function get nextLevelXp():uint
		{
			return _nextLevelXp;
		}
		
		public function get currentSubLevelMinXp():uint
		{
			return _currentSubLevelMinXp;
		}
		
	}
}