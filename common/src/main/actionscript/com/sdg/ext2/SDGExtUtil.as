package com.sdg.ext2
{
	import com.adobe.crypto.MD5;
	import com.adobe.utils.StringUtil;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	/**
	 * The SDGExtUtil class provides all necessary means
	 * for communicating with the host environment.
	 */
	public class SDGExtUtil extends EventDispatcher
	{
		private static const MD5_SALT:String = "ivGf7Do4ixkeE";
		
		private static var _instance:SDGExtUtil;
		private static var _singletonEnforcer:Object = {};
		
		private var _sdgApp:ISDGApp;
		private var _gameId:uint;
		private var _avatarId:uint;
		
		/**
		 * Returns the single SDGExtUtil instance.
		 * 
		 * @return The SDGExtUtil instance.
		 */
		public static function getInstance():SDGExtUtil
		{
			if (_instance == null) _instance = new SDGExtUtil(_singletonEnforcer);
			return _instance;
		}
		
		/**
		 * Constructor, must not be called directly.
		 *
		 * @param enforcer The singleton enforcer object used to ensure this class is only instantiated once.
		 * @throws Error If the constructor is called directly.
		 */
		public function SDGExtUtil(enforcer:Object)
		{
			if (enforcer !== _singletonEnforcer)
				throw new Error("SDGExtUtil is a singleton class. Use 'getInstance()' to access the instance.")
				
			if (ExternalInterface.available)
			{
				//ExternalInterface.addCallback("init", externalInitHandler);
				addExternalCallback("init", externalInitHandler);
				addExternalCallback("getState");
				addExternalCallback("pause");
				addExternalCallback("resume");
				addExternalCallback("destroy");
			}
		}
		
		/**
		 * Registers the object for external method invokations.
		 *
		 * @param sdgApp The ISDGApp instance that gives the host environment access
		 * to the game's exposed methods.
		 */
		public function registerSDGApp(sdgApp:ISDGApp):void
		{
			_sdgApp = sdgApp;
		}
		
		/**
		 * Invoke when the user indicates the desire to return to the host environment.
		 * 
		 * @param gameResults  a list of gameResult objects - one for each game played
		 */
		public function closeAndReturn(gameResults:Array):void
		{
			// convert the GameResult objects into generic AS3 Objects for ExternalInterface marshaling to javascript
			trace("SDGExtUtil.closeAndReturn called");
			var results:Array = new Array();
			for each (var gameResult:GameResult in gameResults)
				results.push(convertGameResultToString(gameResult)); 
			
			callExternal('closeAndReturn', results);
		}
		
		/**
		 * Should be invoked when the application has finished
		 * loading, and the game UI is ready for user input. 
		 */
		public function loadComplete():void
		{
			callExternal('loadComplete');
		}
		
		private function convertGameResultToString(result:GameResult):String
		{
			var data:XML = 
			<SdgRequest>
				<gameId>{_gameId}</gameId>
				<avatarId>{_avatarId}</avatarId>
			</SdgRequest>;
			 
			if (!isNaN(result.score)) data.appendChild(<score>{result.score}</score>);
			
			if (result.startDate)
			{
				data.appendChild(<startDate>{encodeUTCDate(result.startDate)}</startDate>);
				data.appendChild(<startTime>{encodeUTCTime(result.startDate)}</startTime>);
			}
			
			if (result.endDate)
			{
				data.appendChild(<endDate>{encodeUTCDate(result.endDate)}</endDate>);
				data.appendChild(<endTime>{encodeUTCTime(result.endDate)}</endTime>);
			}
			
			var date:Date = new Date();
			
			data.appendChild(<submissionDate>{encodeUTCDate(date)}</submissionDate>);
			data.appendChild(<submissionTime>{encodeUTCTime(date)}</submissionTime>);
			
			if (result.winCondition) data.appendChild(<winCondition>{result.winCondition}</winCondition>);
			if (result.attributes) data.appendChild(encodeGameAttributes(result.attributes));
			
			data.@hashCode = generateChecksum(data.children().toString());
			
			return data.toXMLString();
		}

		//--------------------------------------------------------------------------
		//
		//  Encode methods
		//
		//--------------------------------------------------------------------------
		
		private function encodeGameAttributes(atts:Object):XML
		{
			var data:XML = <attributes></attributes>;
			
			for (var name:String in atts)
			{
				var value:Object = atts[name];
				
				if (value != null)
				{
					if ((!(value is String) && !(value is Number)))
						throw new Error("Attribute '" + name + "' " + value + " must be a String or Number.");
						
					data.appendChild(<{name}>{atts[name]}</{name}>);
				}
			}
			
			return data;
		}
		
		private function encodeUTCDate(date:Date):String
		{
			if (date)
				return date.getUTCMonth() + '-' + date.getUTCDate() + '-' + date.getUTCFullYear();
			else
				return '';
		}
		
		private function encodeUTCTime(date:Date):String
		{
			if (date)
				return date.getUTCHours() + ':' + date.getUTCMinutes() + ':' + date.getUTCSeconds();
			else
				return '';
		}
		
		private function generateChecksum(str:String):String
		{
			var stripStr:String = StringUtil.remove(StringUtil.remove(str, ' '), '\n');
			return MD5.hash(stripStr + MD5_SALT);
		}
		
		//--------------------------------------------------------------------------
		//
		//  ExternalInterface methods
		//
		//--------------------------------------------------------------------------
		
		private function addExternalCallback(methodName:String, handler:Function = null):void
		{
			if (handler == null)
				handler = function(...args:Array):* { return handleExternal(methodName, args); }
			
			ExternalInterface.addCallback("SDG_" + methodName, handler);
		}
		
		private function handleExternal(methodName:String, args:Array):*
		{
			if (_sdgApp) return _sdgApp[methodName].apply(this, args);
		}
		
		private function externalInitHandler(params:Object):void
		{
			trace("externalInitHandler called: gameId is " + params.gameId);
			
			this._avatarId = params.avatarId;
			this._gameId = params.gameId;
			
			if (_sdgApp) _sdgApp.init(params);
		}
		
		private function callExternal(methodName:String, ...args:Array):void
		{
			if (ExternalInterface.available)
				ExternalInterface.call.apply(this, ["SDG_" + methodName].concat(args));
		}
	}
}