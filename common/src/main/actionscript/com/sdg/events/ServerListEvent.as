package com.sdg.events{	import com.adobe.cairngorm.control.CairngormEvent;		public class ServerListEvent extends CairngormEvent	{		public static const LIST:String = 'findServers';		public static const LIST_COMPLETED:String = "serverListCompleted";				public var isAfterHours:Boolean;				public function ServerListEvent(type:String = LIST, isAfterHours:Boolean = false)		{			super(type);			this.isAfterHours = isAfterHours;		}	}}