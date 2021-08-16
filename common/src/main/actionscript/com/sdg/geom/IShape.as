package com.sdg.geom
{
	import com.sdg.geom.IShapeCursor;
	import com.sdg.geom.IShape;
	import flash.geom.Rectangle;
	
	public interface IShape
	{
		function getRect():Rectangle;
		
		function getCursor():IShapeCursor;
		
		function clone():IShape;
	}
}