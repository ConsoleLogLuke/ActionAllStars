package com.sdg.model
{
	import flash.text.TextFormat;
	
	public class QuestListItemFormat extends Object
	{
		private var _backingColor:uint;
		private var _titleFormat:TextFormat;
		
		public function QuestListItemFormat(backingColor:uint, titleFormat:TextFormat)
		{
			super();
			
			_backingColor = backingColor;
			_titleFormat = titleFormat;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get backingColor():uint
		{
			return _backingColor;
		}
		public function set backingColor(value:uint):void
		{
			if (value == _backingColor) return;
			
			_backingColor = value;
		}
		
		public function get titleFormat():TextFormat
		{
			return _titleFormat;
		}
		public function set titleFormat(value:TextFormat):void
		{
			if (value == _titleFormat) return;
			
			_titleFormat = value;
		}
		
	}
}