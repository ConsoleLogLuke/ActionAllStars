package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GameAttributesEvent;
	import com.sdg.utils.Constants;
	
	import flash.external.ExternalInterface;
	
	import mx.rpc.IResponder;

	public class GameAttributesCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		protected var _event:GameAttributesEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as GameAttributesEvent;
			new SdgServiceDelegate(this).getGameAttributes(_event.avatarId, _event.gameId, _event.achievementId, _event.team1ItemId, _event.team2ItemId);
		}
		
		public function result(data:Object):void
		{
			var unityAttributeString:String = XML(data).children().toXMLString().replace(/\n/g, "");
			
			var xmlData:XML = data as XML;
			
			var width:uint = xmlData.width;
			var height:uint = xmlData.height;
			var src:String = xmlData.src;
			
			// put everthing but the width, height, and src in an "attributes" object
			var attributes:Object = new Object();
			for each (var item:XML in xmlData.children())
			{
				if (item.name().toString() == "width" || item.name().toString() == "height" || item.name().toString() == "src")
					continue
				
				// HACK to fix avatar skin color in game
				//    Color passed is actually colorId - this is a manual conversion back to color
				//if (false)
				if (item.name().toString() == "skinColor")
				{
					if (item.toString() == 1)
					{
						attributes[item.name().toString()] = "e5ab8b";
					}
					else if (item.toString() == 2)
					{
						attributes[item.name().toString()] = "d88e52";
					}
					else if (item.toString() == 3)
					{
						attributes[item.name().toString()] = "7e502b";
					}
					else if (item.toString() == 4)
					{
						attributes[item.name().toString()] = "613323";
					}
					else
					{
						// do the usual
						attributes[item.name().toString()] = "d88e52";
					}
					
				}	
				else
				{
					attributes[item.name().toString()] = item.toString();
				}
				
			}
			
			// Display all of the data
			// Debug vars
			//var skinColor:String= attributes["skinColor"];
			//var skinColorId:String= attributes["skinColorId"];
			//var genderId:String= attributes["genderId"];
			//SdgAlertChrome.show("Skin Color, SkinColorId: "+skinColor.toUpperCase()+", "+skinColorId,"DEBUG!");
			
			// call javascript here to launch the game
			if (ExternalInterface.available)
			{
				if (_event.gameId == Constants.RBI_GAME_ID || _event.gameId == Constants.NBA_ALLSTARS_GAME_ID)
					ExternalInterface.call("loadExternalUnityGame", src, width, height, unityAttributeString);
				else
					ExternalInterface.call("loadExternalGame", src, width, height, attributes);
			}
		}
	}
}