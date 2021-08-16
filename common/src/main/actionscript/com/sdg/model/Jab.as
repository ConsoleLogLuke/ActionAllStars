package com.sdg.model
{
	public class Jab
	{
		private var _jabId:int;
		private var _jabName:String;
		private var _jabIconUrl:String;
		private var _jabHudUrl:String;
		private var _jabEmoteUrl:String;
		private var _senderText:String;
		private var _receiverText:String;
		private var _emoteText:String;
		private var _requiredLevel:int;
		private var _showEmote:Boolean;
		private var _toolTip:String;
		private var _genderId:int;
		
		public function Jab(jabId:int, jabName:String, jabIconUrl:String, jabHudUrl:String, jabEmoteUrl:String, senderText:String, receiverText:String, emoteText:String, requiredLevel:int, showEmote:Boolean, toolTip:String, genderId:int = 1)
		{
			_jabId = jabId;
			_jabName = jabName;
			_jabIconUrl = jabIconUrl;
			_jabHudUrl = jabHudUrl;
			_jabEmoteUrl = jabEmoteUrl;
			_senderText = senderText;
			_receiverText = receiverText;
			_emoteText = emoteText;
			_requiredLevel = requiredLevel;
			_showEmote = showEmote;
			_toolTip = toolTip;
			_genderId = genderId;
		}
		
		public function get jabId():int
		{
			return _jabId;
		}
		
		public function get jabName():String
		{
			return _jabName;
		}

		public function get jabIconUrl():String
		{
			return _jabIconUrl;
		}
		
		public function get jabHudUrl():String
		{	
			return _jabHudUrl;
		}
		
		public function get jabEmoteUrl():String
		{	
			return _jabEmoteUrl;
		}
		
		public function get senderText():String
		{
			return _senderText;
		}
		
		public function get receiverText():String
		{
			return _receiverText;
		}
		
		public function get emoteText():String
		{
			return _emoteText;
		}
		
		public function get requiredLevel():int
		{
			return _requiredLevel;			
		}
		
		public function get showEmote():Boolean
		{
			return _showEmote;			
		}

		public function get toolTip():String
		{	
			return _toolTip;
		}
		
		public function get genderId():int
		{
			return _genderId;
		}
		
		/**
		 * Returns the given message text with [sender] and [reciever] replaced with the given sender and receiver names
		 */ 
		public static function getMessage(messageText:String, senderName:String, receiverName:String, gameName:String = null):String
		{
			var message:String = messageText.replace("\[sender\]", senderName);
			message = message.replace("\[receiver\]", receiverName);
			
			if (gameName)
				message = message.replace("\[game\]", gameName);
			
			return message;
		}
	}
}