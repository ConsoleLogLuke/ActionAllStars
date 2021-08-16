package com.sdg.utils
{
	import flash.net.LocalConnection;
	
	public class GCUtil extends Object
	{
		public function GCUtil()
		{
			super();
		}
		
		public static function forceCollection():void
		{
   			try
   			{
      			var x:LocalConnection = new LocalConnection();
	            var y:LocalConnection = new LocalConnection();

	            x.connect('dummy_string');
	            y.connect('dummy_string');
   			}
   			catch (e:Error)
   			{}
		}
	}
}