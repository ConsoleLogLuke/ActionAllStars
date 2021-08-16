package com.sdg.shape
{
	import flash.display.Graphics;

	public class Shape extends Object implements IShape
	{
		protected var _x:Number;
		protected var _y:Number;
		protected var _width:Number;
		protected var _height:Number;
		
		/**
		 * The Shape class is a base class for all shapes that implement IShape.
		 * You should only extend from Shape and never use as is.
		 */
		public function Shape(x:Number, y:Number, width:Number, height:Number)
		{
			super();
			
			_x = x;
			_y = y;
			_width = width;
			_height = height;
		}
		
		public function draw(graphicsObject:Graphics):void
		{
			throw(new Error('You must not call draw() directly on the Shape class. Make sure any classes that inerit from Shape override the draw() method'));
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get width():Number
		{
			return _width;
		}
		public function set width(value:Number):void
		{
			_width = value;
		}
		
		public function get height():Number
		{
			return _height;
		}
		public function set height(value:Number):void
		{
			_height = value;
		}
		
		public function get x():Number
		{
			return _x;
		}
		public function set x(value:Number):void
		{
			_x = value;
		}
		
		public function get y():Number
		{
			return _y;
		}
		public function set y(value:Number):void
		{
			_y = value;
		}
		
	}
}