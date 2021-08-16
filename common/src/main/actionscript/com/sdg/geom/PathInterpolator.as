package com.sdg.geom
{
	import com.sdg.geom.IShapeCursor;
	import com.sdg.geom.IShape;
	import com.sdg.geom.Path;
	import flash.geom.Point;
	
	public class PathInterpolator
	{
		private static const SEG_MOVETO:int = Path.SEG_MOVETO;
		private static const SEG_LINETO:int = Path.SEG_LINETO;
		
		private var _angle:Number = 0;
		private var _cursor:IShapeCursor;
		private var _lineL:Number = 0;
		private var _stepL:Number = 0;
		private var _p1:Point = new Point();
		private var _p2:Point = new Point();
		
		public function PathInterpolator(path:IShape = null)
		{
			setPath(path);
		}
		
		public function get currentAngle():Number
		{
			return _angle;
		}
		
		public function get currentIndex():int
		{
			return _cursor.currentIndex;
		}
		
		public function getPosition(p:Point):void
		{
			if (_lineL > 0)
			{
				var f:Number = _stepL / _lineL;
				p.x = _p1.x + (_p2.x - _p1.x) * f;
				p.y = _p1.y + (_p2.y - _p1.y) * f;
			}
			else
			{
				p.x = _p1.x,
				p.y = _p1.y;
			}
		}

		public function reset():void
		{
			_cursor.reset();
			_stepL = 0;
			updateLine();
		}
		
		public function setPath(path:IShape):void
		{
			_cursor = (path == null) ? GeomUtil.NULL_SHAPE_CURSOR : path.getCursor();
			_stepL = 0;
			updateLine();
		}

		public function step(dL:Number):Boolean
		{
			_stepL += dL;
			
			if (_stepL >= 0)
			{
				while (_stepL >= _lineL)
				{
					if (_cursor.hasNext())
					{
						_stepL -= _lineL;
					
						_cursor.next();
						updateLine();
					}
					else
					{
						_stepL = _lineL;
						return true;
					}
				}
			}
			else
			{
				while (_stepL < 0)
				{
					if (_cursor.hasPrev())
					{
						_stepL += _lineL;
					
						_cursor.prev();
						updateLine();
					}
					else
					{
						_stepL = 0;
						return true;
					}
				}
			}
			
			return false;
		}

		private function updateLine():void
		{
			var coords:Array = [];
			
			switch (_cursor.currentSegment(coords))
			{
				case SEG_MOVETO:
					_p1.x = _p2.x = coords[0];
					_p1.y = _p2.y = coords[1];
					break;
				
				case SEG_LINETO:
					_p1.x = _p2.x, _p1.y = _p2.y;
					_p2.x = coords[0], _p2.y = coords[1];
					break;
			}
			
			_lineL = Math.sqrt( (_p2.x - _p1.x) * (_p2.x - _p1.x) + (_p2.y - _p1.y) * (_p2.y - _p1.y) );
			_angle = Math.atan2(_p2.y - _p1.y, _p2.x - _p1.x);
		}
	}
}