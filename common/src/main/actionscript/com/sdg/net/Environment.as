package com.sdg.net
{
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	
	public class Environment
	{
		private static var browser:String;
		private static var swfDomain:String;
		private static var htmlUrl:String;
		public static const SALT:String = 'ivGf7Do4ixkeE';

		public static const DOMAIN_REGEX:RegExp = /^(http:\/\/|https:\/\/)?([^\/]+)/i;

		// modify these to match a known user in your target world
		public static const USER_NAME:String  = "bud1";
		public static const USER_ID:String = "4";
		public static const PASSWORD:String = "asdasd";
		public static const CHAT_MODE:String = "1";
		
		
		// DEV
		//private static const env:String = 'mdr-dev01';
		
		// QA
		private static const env:String = 'mdr-qa01';
		
		// QA 2
		//private static const env:String = 'mdr-qa02';
		
		// QA 3
		//private static const env:String = 'mdr-qa03';
		
		// DEMO
		//private static const env:String = 'mdr-demo01';
		
		// STAGE
		//private static const env:String = 'mdr-stage01';
		
		// LIVE
		//private static const env:String = 'www.actionallstars.com';
		
		private static var APPLICATION_DOMAIN:String = env;
		private static var ASSET_DOMAIN:String = env;
		public static const DOMAIN:String = env;		// your default electroserver location
		
		
		public static const SERVER_ID:String = "101";
		public static const NAME:String =  "Chat Central";
		public static const PORT:String = "8080";					// your default es port

		public static const PARTNER_ID:String = "0";
		public static const VERSION:String = "1234";
		
        public static const FAILOVER_DOMAIN:String = "192.168.0.222";        // FAILOVER ES
        public static const FAILOVER_PORT:String = "8989"                    // FAILOVER PORT

        public static const FAILOVER_TEST_ON:String = "true";
        public static const FAILOVER_TEST_OFF:String = "false";
		 public static const USE_FAILOVER:String = FAILOVER_TEST_OFF;
		public static var serverVersion:String = "5";
		public static var returnUrl:String = "192.168.0.222"; 
		
		public static function setApplicationDomain(value:String):void
		{
			APPLICATION_DOMAIN = value;
		}
		
		public static function setAssetDomain(value:String):void
		{
			ASSET_DOMAIN = value;
		}
		
		public static function getApplicationUrl():String
		{
			return getUriScheme() + "://" + getApplicationDomain();
		}

		public static function getAssetUrl():String
		{
			return getUriScheme() + "://" + getAssetDomain();
		}
		
		public static function getSecureUrl():String
		{
			return "https" + "://" + getApplicationDomain();
		}

		public static function getApplicationDomain():String
		{
			return APPLICATION_DOMAIN;
		}

		public static function getAssetDomain():String
		{
			return ASSET_DOMAIN;
		}

		public static function isStandalone():Boolean
		{
			var host:String = getHtmlDomain();
			return (host == "" || host.indexOf('file') > -1);
		}
		
		public static function getHtmlUrl():String
		{
			if (htmlUrl == null)
			{
				try
				{
					htmlUrl = ExternalInterface.call('function(){return location.href}');
					if (htmlUrl == null) htmlUrl = "";
				}
				catch (error:Error)
				{
					htmlUrl = "";
				}
			}
			
			return htmlUrl;
		}

		public static function getHtmlDomain():String
		{
			var html:String = getHtmlUrl();
			return (html != "") ? html.match(DOMAIN_REGEX)[2] : "";
		}

		public static function getSwfDomain():String
		{
			if (swfDomain == null) {
				var lc:LocalConnection = new LocalConnection();
				swfDomain = lc.domain;
			}
			return swfDomain;
		}

		public static function getUriScheme():String
		{
			return (getHtmlUrl().indexOf('https://') > -1) ? 'https' : 'http';
		}

		public static function getBrowser():String
		{
			if (browser == null)
			{
				try
				{
					browser = ExternalInterface.call('getBrowser');
				}
				catch (error:Error)
				{

				}
			}
			
			return browser;
		}
/*
		public static function getAllDomains():Array
		{	
			var domains:Array = new Array();
			for each (var context:Object in HOST_MAP) {
				for each (var host:Object in context) {
					domains.push(host);
				}
			}
			return domains;
		}

		public static function getDomainsForContext():Array
		{
			var domains:Array = new Array();

			for each (var host:String in HOST_MAP[getContext()]) {
					domains.push(host);
			}
			return domains;
		}
		*/
	}
}