package com.sdg.view
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class MissionResolveMovieContainer extends FluidView
	{
		protected var _movie:DisplayObject;
		protected var _back:Sprite;
		protected var _txt:TextField;
		protected var _loadIndicator:SpinningLoadingIndicator;
		
		public function MissionResolveMovieContainer(width:Number = 925, height:Number = 665)
		{
			_back = new Sprite();
			
			_txt = new TextField();
			_txt.defaultTextFormat = new TextFormat('Arial', 12, 0xffffff, true);
			_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.selectable = false;
			
			_loadIndicator = new SpinningLoadingIndicator();
			var indScale:Number = (20 / _loadIndicator.width);
			_loadIndicator.width *= indScale;
			_loadIndicator.height *= indScale;
			
			super(width, height);
			
			render();
			
			addChild(_back);
			addChild(_txt);
			addChild(_loadIndicator);
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function show():void
		{
			trace('MissionResolveMovieContainer.show()');
			
			_movie.visible = true;
		}
		public function hide():void
		{
			_movie.visible = false;
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			_back.graphics.clear();
			_back.graphics.beginFill(0x000000, 0.8);
			_back.graphics.drawRect(0, 0, _width, _height);
			
			_txt.x = _width / 2 - _txt.width / 2;
			_txt.y = _height / 2 - _txt.height / 2;
			
			_loadIndicator.x = _txt.x + _txt.width + 10;
			_loadIndicator.y = _height / 2 - _loadIndicator.height / 2;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get movie():DisplayObject
		{
			return _movie;
		}
		public function set movie(value:DisplayObject):void
		{
			if (value == _movie) return;
			
			// Remove old.
			if (_movie != null) removeChild(_movie);
			
			// Add new.
			_movie = value;
			_movie.x = _width / 2 - _movie.width / 2;
			_movie.y = _height / 2 - _movie.height / 2;
			_movie.visible = false;
			addChild(_movie);
		}
		
		override public function get name():String
		{
			return _txt.text;
		}
		override public function set name(value:String):void
		{
			if (value == name) return;
			_txt.text = value;
			render();
		}
		
	}
}