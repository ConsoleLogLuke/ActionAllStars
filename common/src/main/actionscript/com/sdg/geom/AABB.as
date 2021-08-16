﻿package com.sdg.geom{	public class AABB	{		public var xMin:Number;		public var yMin:Number;		public var xMax:Number;		public var yMax:Number;				public function AABB(xMin:Number = 0, yMin:Number = 0, xMax:Number = 0, yMax:Number = 0)		{			this.xMin = xMin, this.yMin = yMin, this.xMax = xMax, this.yMax = yMax;		}				public function intersects(aabb:AABB):Boolean		{			if (xMax < aabb.xMin) return false;			if (yMax < aabb.yMin) return false;			if (aabb.xMax < xMin) return false;			if (aabb.yMax < yMin) return false;						return true;		}				public function intersectsCoordinates(x:Number, y:Number):Boolean		{			if (xMax < x) return false;			if (yMax < y) return false;			if (x < xMin) return false;			if (y < yMin) return false;						return true;		}				public function offset(x:Number, y:Number):void		{			xMin += x, yMin += y, xMax += x, yMax += y; 		}				public function clone():AABB		{			return new AABB(xMin, yMin, xMax, yMax);		}				public function copy(aabb:AABB):void		{			xMin = aabb.xMin;			yMin = aabb.yMin;			xMax = aabb.xMax;			yMax = aabb.yMax;		}				public function toString():String		{			return "(xMin=" + xMin + ", yMin=" + yMin + ", xMax=" + xMax + ", yMax=" + yMax + ")";		}	}}