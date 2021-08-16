package com.sdg.utils
{
	public class DateUtil extends Object
	{
		public function DateUtil()
		{
			super();
		}
		
		public static function DateFromString(dateString:String):Date
		{
			// convert a date string into a Date object
			// return the date object
			
			// date string must be in a specific format
			// MM-DD-YYYY hh:mm:ss
			var day:Number = Number(dateString.substr(8, 2));
			var month:Number = Number(dateString.substr(5, 2)) - 1;
			var year:Number = Number(dateString.substr(0, 4));
			var hour:Number = Number(dateString.substr(11, 2));
			var minute:Number = Number(dateString.substr(14, 2));
			var second:Number = Number(dateString.substr(17, 2));
			
			return new Date(year, month, day, hour, minute, second);
		}
		
		public static function ParseStandardDate(string:String):Date
		{
			// Convert a string to a Date object.
			
			// Date must be in a specific format.
			// YYYY-MM-DDThh:mm:ssZ
			var year:int = int(string.substr(0, 4));
			var month:int = int(string.substr(5, 2)) - 1;
			var day:int = int(string.substr(8, 2));
			var hour:int = int(string.substr(11, 2));
			var minute:int = int(string.substr(14, 2));
			var second:int = int(string.substr(17, 2));
			var timezone:String = string.substr(19, 1);
			var date:Date = new Date(year, month, day, hour, minute, second);
			if (timezone == 'Z') 
			{
				// Convert to Pacific by subtracting 7 hours.
				date.setTime(date.time - 25200000);
			}
			
			return date;
		}
		
		public static function DateToStandardString(date:Date):String
		{
			// returns YYYY-MM-DDThh:mm:ssZ
			// Zero pad month, day, hours, minutes and seconds
			return date.fullYear + '-' + zeroPad(date.month) + '-' + zeroPad(date.date) + 'T' + zeroPad(date.hours) + ':' + zeroPad(date.minutes) + ':' + zeroPad(date.seconds) + 'Z';
			
			function zeroPad(number:Number):String
			{
				var string:String = number.toString();
				if (string.length < 2) string = '0' + string;
				return string;
			}
		}
		
		public static function DateToCommonString(date:Date):String
		{
			// Returns MM-DD-YYYY
			return zeroPad(date.month + 1) + '-' + zeroPad(date.date) + '-' + date.fullYear;
			
			function zeroPad(number:Number):String
			{
				var string:String = number.toString();
				if (string.length < 2) string = '0' + string;
				return string;
			}
		}
		
	}
}