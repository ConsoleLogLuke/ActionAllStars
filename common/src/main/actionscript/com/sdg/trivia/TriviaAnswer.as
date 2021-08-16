package com.sdg.trivia
{
	public class TriviaAnswer extends Object
	{
		public var id:int;
		public var text:String;
		public var isCorrect:Boolean;
		public var imageUrl:String;
		private var _color1:uint;
		private var _color2:uint;
		private var _color3:uint;
		private var _color4:uint;
		
		public function TriviaAnswer(id:int, text:String, isCorrect:Boolean = false)
		{
			super();
			
			this.id = id;
			this.text = text;
			this.isCorrect = isCorrect;
			this.imageUrl = '';
		}
		
		public function get color1():uint
		{
			return _color1;
		}
		public function set color1(value:uint):void
		{
			_color1 = value;
		}
		
		public function get color2():uint
		{
			return _color2;
		}
		public function set color2(value:uint):void
		{
			_color2 = value;
		}
		
		public function get color3():uint
		{
			return _color3;
		}
		public function set color3(value:uint):void
		{
			_color3 = value;
		}
		
		public function get color4():uint
		{
			return _color4;
		}
		public function set color4(value:uint):void
		{
			_color4 = value;
		}
		
	}
}