package com.sdg.utils
{
	import flash.system.Capabilities;
	
	public class VersionUtil
	{
		// Returns: Whole Number Version of Flash; if error, 0
		public static function getVersion():uint
		{
			var firstSpace:int = Capabilities.version.indexOf(" ");
			var fullVersionNum:String = "";
			if (firstSpace > 0)
				fullVersionNum = Capabilities.version.substring(firstSpace+1);
			else
				return 0;
			
			var firstComma:int = fullVersionNum.indexOf(",");
			var flashVersion:String = "";
			if (firstComma > 0)
				flashVersion = fullVersionNum.substring(0,firstComma);
			else
				return 0;
				
			//trace(Capabilities.version+" / "+flashVersion);
			//flashVersion = "fgu";
			if (parseInt(flashVersion))
				return parseInt(flashVersion);
			else
				return 0;
		}

	}
}