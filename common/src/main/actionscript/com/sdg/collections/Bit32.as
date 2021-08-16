﻿package com.sdg.collections{	import flash.geom.*;		public class Bit32	{		private var _bits:int;				public function Bit32(bits:int = 0):void		{			_bits = bits;		}				public function getBit(index:int):int		{			return (_bits & (1 << index)) >> index;		}				public function getBits(bits:int):int		{			return (bits & _bits);		}				public function setBit(index:int, value:Boolean):void		{			if (index > -1 && index < 31)				_bits = (value) ? _bits | (1 << index) : _bits & ~(1 << index);		}				public function setBits(bits:int, value:Boolean):void		{			_bits = (value) ? _bits | bits : _bits & ~bits;		}				public function toString():String		{			return String(_bits);		}				public function valueOf():Object		{			return _bits;		}	}}