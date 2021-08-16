package com.sdg.util
{
	import com.sdg.display.Grid;
	
	import flash.geom.Point;
	
	public class GridUtil extends Object
	{
		/**
		 * Returns the center position of a grid unit.
		 */
		public static function GetCenter(grid:Grid, unitIndex:int):Point
		{
			var len:int = grid.length;
			var cols:int = grid.columns;
			var unitWidth:Number = grid.unitWidth;
			var unitHeight:Number = grid.unitHeight;
			var unitWidthPlusSpace:Number = unitWidth + grid.spacingX;
			var unitHeightPlusSpace:Number = unitHeight + grid.spacingY;
			if (unitIndex >= len) throw(new Error('This unitIndex ' + unitIndex + ' is out of range.'));
			var row:int = Math.floor(unitIndex / cols);
			var col:int = unitIndex - (row * cols);
			return new Point(unitWidthPlusSpace * col + (unitWidth / 2), unitHeightPlusSpace * row + (unitHeight / 2));
		}
		
	}
}