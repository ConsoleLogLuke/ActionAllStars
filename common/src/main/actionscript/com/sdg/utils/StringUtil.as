package com.sdg.utils
{
	import flash.utils.*;
		
	public class StringUtil
	{
		// takes a date like 2008-08-12T23:54:16.015Z and returns human readable
		public static function formatDate(dateString:String):String
		{
			var str:String = dateString.substr(0, dateString.indexOf("T"));
			while (str.indexOf("-") != -1)
			{
				str = str.replace("-", "/");
			}
			var date:Date = new Date(str);
			var monthStrings:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
			var output:String = monthStrings[date.getMonth()];
			output += " " + date.getDate();
			output += ", " + date.getFullYear();
			return output;
		}
		
		public static function lcFirst(str:String):String
		{
			var substr:String = str.substring(1);
			var first:String = str.charAt(0);
			return first.toLowerCase() + substr;
		}
		
		public static function AlphabeticCompare(a:String, b:String):int
		{
			var pos:uint = 0;
			while (a.charCodeAt(pos) && b.charCodeAt(pos))
			{
				var aCode:Number = a.charCodeAt(pos);
				var bCode:Number = b.charCodeAt(pos);
				
				if (aCode < bCode)
				{
					return -1;
				}
				else if (aCode > bCode)
				{
					return 1;
				}
				
				pos ++;
			}
			
			return 0;
		}
		
		public static function GetStringWithinCharacterLimit(string:String, limit:uint):String
		{
			if (string.length > limit)
			{
				return string.substring(0, limit - 4) + '...';
			}
			
			return string;
		}
		
	}
}