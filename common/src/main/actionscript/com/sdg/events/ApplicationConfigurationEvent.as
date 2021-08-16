/**
* ...
* @author Lance Sanders
* @version 0.1
*/
package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ApplicationConfigurationEvent extends CairngormEvent
	{
		public static const LOAD:String = "configurationLoad";
		public static const READY:String = "configurationReady";
		
		public function ApplicationConfigurationEvent(type:String)
		{
			super(type);
		}
	}
}