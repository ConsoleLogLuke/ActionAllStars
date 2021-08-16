package com.sdg.business
{
	public class SdgServiceResponse
	{
		private var _data:XML;
		
		/**
		 * The raw xml data.
		 */
		public function get data():XML
		{
			return _data;
		}
		
		/**
		 * The status code. If the status is 0, an error occurred.
		 */
		public function get status():int
		{
			var code:int = int(_data.@status);
			return isNaN(code) ? 0 : code;
		}
		
		/**
		 * The last message in the errors list.
		 */
		public function get errorMessage():String
		{
			// If errors exist, return the last message.
			if (_data.errors is XML)
			{
				var messages:XMLList = _data.errors.children();
				
				if (messages.length() > 0)
					return messages[messages.length() - 1].text();
			}
			
			return null;
		}
		
		/**
		 * Constructor.
		 */
		public function SdgServiceResponse(data:Object):void
		{
			_data = XML(data);
		}
	}
}