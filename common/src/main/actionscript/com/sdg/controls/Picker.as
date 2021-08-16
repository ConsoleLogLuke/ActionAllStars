package com.sdg.controls
{
	import com.sdg.graphics.LineStyle;
	import com.sdg.view.Canvas;
	import com.sdg.view.CanvasCollection;
	import com.sdg.view.utils.LayoutUtils;
	
	import flash.events.MouseEvent;

	public class Picker extends Canvas
	{
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _length:int;
		protected var _margin:Number;
		protected var _spacing:Number;
		protected var _collection:CanvasCollection;
		protected var _selection:int;
		protected var _columns:int;
		protected var _rows:int;
		
		public function Picker(width:Number = 0, height:Number = 0, columns:int = 1, rows:int = 1)
		{
			super(width, height);
			
			_width = width;
			_height = height;
			_length = 0;
			_margin = 0;
			_spacing = 0;
			_selection = -1;
			_columns = columns;
			_rows = rows;
		}
		
		
		/*
		 * CLASS METHODS
		*/
		protected function _makePickables():void
		{
			// make a canvas for each pickable object
			var i:int;
			var canvas:Canvas;
			_collection = new CanvasCollection();
			for (i = 0; i < _length; i++)
			{
				canvas = _makeCanvas(i);
				canvas.addEventListener(MouseEvent.CLICK, _canvasClick);
				_collection.addItem(canvas);
				AddChild(canvas);
			}
			
			_draw();
		}
		
		public function setSelection(index:int):void
		{
			if (index < 0 || index >= _length) return;
			
			// designate some variables that will be used
			var canvas:Canvas;
			
			// if there is a current selection
			// remove selected styling from that canvas
			if (_selection > -1)
			{
				canvas = _collection.getItem(_selection);
				canvas.LineStyling = new LineStyle(0);
			}
			
			// style newly selected canvas
			canvas = _collection.getItem(index);
			canvas.LineStyling = new LineStyle(3, 0x000000);
			
			// set new selection
			_selection = index;
		}
		
		protected function _makeCanvas(index:int):Canvas
		{
			return new Canvas();
		}
		
		protected function _draw():void
		{
			LayoutUtils.MakeGrid(_collection.getArrayAt(0, _collection.length), _columns, _rows, _width, _height, 0, 0, _spacing);
		}
		
		
		/*
		 * GET /SET METHODS
		*/
		public function get columns():int
		{
			return _columns;
		}
		public function set columns(value:int):void
		{
			_columns = value;
			_draw();
		}
		public function get rows():int
		{
			return _rows;
		}
		public function set ySize(value:int):void
		{
			_rows = value;
			_draw();
		}
		public function get spacing():Number
		{
			return _spacing;
		}
		public function set spacing(value:Number):void
		{
			_spacing = value;
			_draw();
		}
		
		
		private function _canvasClick(e:MouseEvent):void
		{
			// get index of clicked canvas
			var canvas:Canvas = Canvas(e.currentTarget);
			var index:int = _collection.getIndex(canvas);
			setSelection(index);
		}
		
	}
}