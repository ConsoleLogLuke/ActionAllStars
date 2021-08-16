package com.sdg.model
{
	public class Emote
	{
		private var _emoteId:int;
		private var _emoteName:String;
		private var _emoteIconUrl:String;
		private var _emoteText:String;
		private var _requiredLevel:int;
		private var _vendorId:int;
		
		public function Emote(emoteId:int, emoteName:String, emoteIconUrl:String, emoteText:String, requiredLevel:int, vendorId:int)
		{
			_emoteId = emoteId;
			_emoteName = emoteName;
			_emoteIconUrl = emoteIconUrl;
			_emoteText = emoteText;
			_requiredLevel = requiredLevel;
			_vendorId = vendorId;
		}
		
		public function get emoteId():int
		{
			return _emoteId;
		}
		
		public function get emoteName():String
		{
			return _emoteName;
		}

		public function get emoteIconUrl():String
		{
			return _emoteIconUrl;
		}
		
		public function get emoteText():String
		{
			return _emoteText;
		}
		
		public function get requiredLevel():int
		{
			return _requiredLevel;			
		}
		
		public function get vendorId():int
		{
			return _vendorId;			
		}
		
		/**
		 * Returns the given message text with [sender] and [reciever] replaced with the given sender and receiver names
		 */ 
		public static function getMessage(messageText:String, senderName:String, receiverName:String):String
		{
			var message:String = messageText.replace("\[sender\]", senderName);
			return message.replace("\[receiver\]", receiverName); 
		}
	}
}