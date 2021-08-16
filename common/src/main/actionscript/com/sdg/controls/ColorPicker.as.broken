package com.sdg.controls
{
	import com.sdg.controls.events.ColorPickerEvent;
	import com.sdg.view.Canvas;

	public class ColorPicker extends Picker
	{
		
		private var _colors:Array;
		
		public function ColorPicker(width:Number = 0, height:Number = 0, columns:int = 1, rows:int = 1, colors:Array = null)
		{
			super(width, height, columns, rows);
			
			_colors = (colors == null) ? [0xffffff, 0x000000, 0xff0000, 0x00ff00, 0x0000ff] : colors;
			_length = _colors.length;
			
			_makePickables();
		}
		
		/*
		 * CLASS METHODS
		*/
		override public function setSelection(index:int):void
		{
			super.setSelection(index);
			
			// dispatch select event
			var e:ColorPickerEvent = new ColorPickerEvent(ColorPickerEvent.SELECT);
			e.color = _colors[_selection];
			dispatchEvent(e);
		}
		
		override protected function _makeCanvas(index:int):Canvas
		{
			var color:uint = _colors[index];
			var canvas:Canvas = new Canvas(10, 10, 0);
			canvas.Fill.Color = color;
			return canvas;
		}
		
		
		/*
		 * GET / SET METHODS
		*/
		public function get colors():Array
		{
			return _colors;
		}
		
	}
}