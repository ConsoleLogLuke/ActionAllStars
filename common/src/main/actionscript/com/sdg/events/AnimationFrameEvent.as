﻿package com.sdg.events{	import flash.events.Event;	public class AnimationFrameEvent extends Event	{		public static const SPRITE:String = 'sprite';		public static const SOUND:String = 'sound';		public static const ACTION:String = 'action';				public var data:Object;				public function AnimationFrameEvent(type:String, data:Object = null)		{			super(type);			this.data = data;		}				override public function clone():Event		{			return new AnimationFrameEvent(type, data);		}	}}