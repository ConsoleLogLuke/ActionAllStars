/**
* ...
* @author Lance Sanders
* @version 0.1
*/
package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ModeratorSaveReportEvent extends CairngormEvent
	{
		public static const MODERATOR_REPORT_SAVE:String = "moderatorReportSave";
		
		public var params:Object;

		
		public function ModeratorSaveReportEvent(params:Object)
		{
			super(MODERATOR_REPORT_SAVE);
			this.params = params;
		}
	}
}