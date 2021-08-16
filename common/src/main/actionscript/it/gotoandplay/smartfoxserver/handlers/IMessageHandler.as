package it.gotoandplay.smartfoxserver.handlers
{
	public interface IMessageHandler
	{
		function handleMessage(msgObj:Object, type:String):void
	}
}