package com.sdg.utils
{
	import com.adobe.crypto.MD5;
	
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import com.sdg.net.Environment;
	
	public class NetUtil
	{

		public static function signRequest(params:Array):String
		{
			var str:String = "";
			for each(var value:String in params)
			{
				str += value;
			}
			return MD5.hash(str + Environment.SALT); 
		}
		
		public static function generateHash(values:Array, salt:String):String
		{
			var str:String = "";
			for(var i:uint = 0; i < values.length; i++)
			{
				str += values[i];
			}
			return MD5.hash(str + salt); 
		}
		
		/**
		 * Applies the specified params to a URLVariables object
		 * and returns a URLRequest;
		 */
		public static function createURLRequest(url:String, params:Object = null):URLRequest
		{
			var request:URLRequest = new URLRequest(url);
			
			if (params)
			{
				var data:URLVariables = new URLVariables();
				
				for (var s:String in params)
					data[s] = params[s];
					
				request.data = data;
			}
			
			return request;
		}
		
		/**
		 * Encodes a URLRequest to the application/x-www-form-urlencoded format.
		 */
		public static function encodeURLRequest(request:URLRequest):String
		{
			var str:String = request.url;
			
			if (request.data)
			{
				if (str.indexOf('?') > -1) 
					str += '&';
				else
					str += '?';
				
				str += encodeURLVariables(request.data);
			}
			
			return str;
		}
		
		/**
		 * Encodes a shallow object to the application/x-www-form-urlencoded format.
		 */
		public static function encodeURLVariables(data:Object):String
		{
			var str:String = '';
			
			for (var name:String in data)
				str += name + '=' + String(data[name]) + '&';
			
			// If params exist, trim the last '&' separator from the string.
			if (str.length) 
				return str.slice(0, str.length - 1);
			else
				return str;
		}
		
		/**
		 * Returns the lowercase filetype in the url.
		 */
		public static function getFileType(url:String):String
		{
			var qIndex:int = url.indexOf("?");
			if (qIndex > -1) url = url.substring(0, qIndex);
            return url.substring(url.lastIndexOf(".") + 1).toLowerCase();
		}
		
		public static function createPayloadXml(topNode:String, params:Object):String
		{
			var xmlString:String = "<" + topNode + ">";

			for (var str:String in params)
			{
				xmlString += "<" + str + ">" + params[str] + "</" + str + ">";
			}
			xmlString += "</" + topNode + ">";
			
			return xmlString;
		}
	}
}