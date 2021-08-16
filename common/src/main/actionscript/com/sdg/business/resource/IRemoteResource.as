package com.sdg.business.resource
{
	import com.sdg.core.IProgressInfo;
	
	public interface IRemoteResource extends IProgressInfo
	{
		function get content():*;
		
		function get useCache():Boolean;
		
		function load():void;
		
		function reset():void;
	}
}