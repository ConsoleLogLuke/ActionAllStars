package com.sdg.net
{
	import mx.modules.IModuleInfo;
	
	public interface IModule extends IModuleInfo
	{
		function getModuleName():String;
		function remove():void;
		function initialize(...params:Array):void;
	}
}