package com.sdg.business.resource
{
	public interface IResourceLoader extends IRemoteResource
	{
		function get info():ResourceInfo
		function set info(value:ResourceInfo):void;
	}
}