﻿package com.sdg.sim.core{	import com.sdg.events.SimEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;		public class SimData extends EventDispatcher	{		public var flags:int = SimEntity.STATIC_FLAG;		public var vx:Number = 0;		public var vy:Number = 0;		public var fx:Number = 0;		public var fy:Number = 0;		public var r:Number = 0;		public var r11:Number = 1;		public var r21:Number = 0;		public var av:Number = 0;		public var tq:Number = 0;		public var mass:Number = 0;		public var invMass:Number = 0;				protected var _x:Number;		protected var _y:Number;				private var _owner:SimEntity;				public function SimData(owner:SimEntity = null)		{			// Default values.			_owner = owner;			_x = 0;			_y = 0;		}				////////////////////		// GET/SET METHODS		////////////////////				public function get owner():SimEntity		{			return _owner;		}				public function get x():Number		{			return _x;		}		public function set x(value:Number):void		{			if (value == _x) return;			_x = value;						// Dispatch an event that signifies that the sim object has moved.			dispatchEvent(new SimEvent(SimEvent.MOVED));		}				public function get y():Number		{			return _y;		}		public function set y(value:Number):void		{			if (value == _y) return;			_y = value;						// Dispatch an event that signifies that the sim object has moved.			dispatchEvent(new SimEvent(SimEvent.MOVED));		}				public function get position():Point		{			return new Point(_x, _y);		}		public function set position(value:Point):void		{			if (value.x == _x && value.y == _y) return;			_x = value.x;			_y = value.y;						// Dispatch an event that signifies that the sim object has moved.			dispatchEvent(new SimEvent(SimEvent.MOVED));		}			}}