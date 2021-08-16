﻿package com.sdg.utils{	import flash.geom.*;		public class MathUtil	{		public static function wrap(value:Number, max:Number):Number		{			return (value < 0 ? max : 0) + value % max;		}				public static function clamp(value:Number, min:Number, max:Number):Number		{			return (value < min) ? min : (value > max) ? max : value;		}				public static function quantize(value:Number, resolution:Number):Number		{			return Math.round(value / resolution) * resolution;		}				public static function random(low:Number, high:Number):Number		{			return Math.floor(Math.random() * (1 + high - low)) + low;		}	}}