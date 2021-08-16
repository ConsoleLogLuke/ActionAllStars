package com.sdg.utils
{
	public class CurrencyUtil extends Object
	{
		public function CurrencyUtil()
		{
			super();
		}
		
		public static function IntToDollars(value:int):String
		{
//			var abValue:uint = Math.abs(value);
//			var dollarString:String = String(value);
//			var output:String = "";
//			var i:int = 0;
//			
//			for (i; i < dollarString.length; i++)
//			{
//				if (i > 0 && (i % 3 == 0 ))
//				{
//					output = "," + output;
//				}
//			
//				output = dollarString.substr( -i - 1, 1) + output;
//			}
			
			return "$"+intFormat(value);
		}
		
		public static function intFormat(value:int):String
		{
			var abValue:uint = Math.abs(value);
			var dollarString:String = String(abValue);
			var output:String = "";
			var i:int = 0;
			
			for (i; i < dollarString.length; i++)
			{
				if (i > 0 && (i % 3 == 0 ))
				{
					output = "," + output;
				}
			
				output = dollarString.substr( -i - 1, 1) + output;
			}
			
			if (Math.abs(value) == value)
				return output;
			else
				return "-"+output;
		}
		
//		public static function intFormat(value:String):String
//		{
//			//var abValue:uint = Math.abs(value);
//			var dollarString:String = value;
//			var output:String = "";
//			var i:int = 0;
//			
//			for (i; i < dollarString.length; i++)
//			{
//				if (i > 0 && (i % 3 == 0 ))
//				{
//					output = "," + output;
//				}
//			
//				output = dollarString.substr( -i - 1, 1) + output;
//			}
//			
//			return output;
//		}
		
	}
}