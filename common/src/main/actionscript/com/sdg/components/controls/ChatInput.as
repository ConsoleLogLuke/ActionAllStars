package com.sdg.components.controls
{
    import com.electrotank.electroserver4.message.request.*;
    import com.sdg.components.dialog.SaveYourGameDialog;
    import com.sdg.control.room.RoomManager;
    import com.sdg.events.SocketEvent;
    import com.sdg.model.ModelLocator;
    import com.sdg.net.socket.SocketClient;
    import com.sdg.utils.MainUtil;
    
    import flash.events.KeyboardEvent;
    import flash.events.TextEvent;
    
    import mx.controls.TextInput;
    import mx.utils.StringUtil;
	
	/**
	 * ChatInput improves on TextInput for chat by validating message.  Chat messages
	 * are validated when the space bar is pressed and rejected words are rendered in red.
	 */
	public class ChatInput extends TextInput
	{
		private var m_socketClient:SocketClient = SocketClient.getInstance();
		private var m_textToValidate:String;
		private var _sendingChatMessage:Boolean;
		private var _chatMessageSender:Function = RoomManager.getInstance().sendChat;
		protected var _chatEnabled:Boolean = true;
		protected var _disabledTest:String = 'Chat disabled in full screen';
		private var _hasBadWords:Boolean = false;
		
		public function ChatInput()
		{
			// register our event listeners
			this.addEventListener(KeyboardEvent.KEY_UP, onChatInputKeyUp);
			this.addEventListener(TextEvent.TEXT_INPUT, onChatTextInput);
			listenForValidation = true;
			
			// limit the number of characters to 45
			this.maxChars = 45;
		}
		
		public function set listenForValidation(value:Boolean):void
		{
			if (value)
				m_socketClient.addEventListener(SocketEvent.PLUGIN_EVENT, onChatValidation);
			else	
				m_socketClient.removeEventListener(SocketEvent.PLUGIN_EVENT, onChatValidation);
		}
		
		/**
		 * Send the current message to the given room once the current chat message is validated
		 */
		public function sendChatMessage():void
		{
			if (!_chatEnabled) return;
			
			if (ModelLocator.getInstance().avatar.membershipStatus == 3)
			{
				//MainUtil.showDialog(MonthFreeUpsellDialog, {showPremiumHeader:false, messaging:"This feature is only available if you register."});
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}
			_sendingChatMessage = true;
			
			// once the text has been validated by the server, we'll send the message
			validateText(this.text);
		}
		
		public function set chatMessageSender(sender:Function):void
		{
			_chatMessageSender = sender;
		}
	
       /**
        * Sends a chat message to the server for validation.  Responses
        * from the server are handled in the onChatValidation handler.
        */		
		private function validateText(textToValidate:String):void
		{
			m_textToValidate = StringUtil.trim(textToValidate);
			
			if (textToValidate != null && textToValidate != "")
			{
				if (m_textToValidate.length > 200)
					m_textToValidate = m_textToValidate.substr(0, 200);
				
				m_socketClient.sendPluginMessage("chat_validation", "validate", { chat:m_textToValidate });
			}
		}
		
		// event handlers
		
		private function onChatInputKeyUp(event:KeyboardEvent):void
		{
			if (this.text == null)
				return;
			
			if (_hasBadWords)
			{
				this.htmlText = this.text;
				_hasBadWords = false;
			}	
			// validate chat the chat message when ever a space is pressed
//			var letter:String = String.fromCharCode(event.keyCode);
//			var isValidChar:Boolean = letter != null && letter.search("[a-zA-Z0-9'!?, ]") != -1 ||
//				(event.keyCode == Keyboard.DELETE || event.keyCode == Keyboard.BACKSPACE); 
//				
//			var isEditingExistingText:Boolean = 
//				(isValidChar && this.textField.caretIndex <= this.text.length - 1);
//			
//			if (event.keyCode == Keyboard.SPACE || isEditingExistingText)			
//			{
//				// validate up to the last space in the text message
//				// or the whole message if we are editing existing text
//				var textToValidate:String = isEditingExistingText ? this.text : this.text.substr(0, this.text.lastIndexOf(' '));
//				if (textToValidate == null || textToValidate.length == 0)
//					textToValidate = this.text;
//				
//				if (textToValidate != m_textToValidate)
//					validateText(textToValidate);
//			}
//			if (event.keyCode == Keyboard.BACKSPACE)
//			{
//				// if we are at the begining of the line, zero out htmlText 
//				// (makes sure chat input is not rendered in red at this point)
//				if (this.text.length == 0)
//					this.htmlText = "";
//			}
		}
		
		private function onChatTextInput(event:TextEvent):void
		{
			// if the letter is non-alphanumberic and is not ['!?, ], filter it out
			if (event.text.search("[a-zA-Z0-9'!?, ]") == -1)
				event.preventDefault();
			// if it is a space
			// caretIndex - 1 for normal double spaces
			// caretIndex for editing text
			else if (event.text.search(" ") != -1)
			{
				if (text == null || text.charAt(textField.caretIndex - 1) == " " || text.charAt(textField.caretIndex) == " ")
					event.preventDefault();
			}
			else if (event.text.search("'") != -1)
			{
				if (text == null || text.charAt(textField.caretIndex - 1) == "'" || text.charAt(textField.caretIndex) == "'")
					event.preventDefault();
			}
			else if (event.text.search("!") != -1)
			{
				if (text == null || text.charAt(textField.caretIndex - 1) == "!" || text.charAt(textField.caretIndex) == "!")
					event.preventDefault();
			}
			else if (event.text.search("?") != -1)
			{
				if (text == null || text.charAt(textField.caretIndex - 1) == "?" || text.charAt(textField.caretIndex) == "?")
					event.preventDefault();
			}
			else if (event.text.search(",") != -1)
			{
				if (text == null || text.charAt(textField.caretIndex - 1) == "," || text.charAt(textField.caretIndex) == ",")
					event.preventDefault();
			}
		}
		
		private function onChatValidation(event:SocketEvent):void
		{	
			if (event.params.pluginName == "chat_validation" && event.params.action == "chat_validation")
			{		
				var validationMessage:String = event.params.message as String;
				if (validationMessage == null || this.text == null)
					return
				else if (validationMessage == "1")
				{
					// if a '1' was sent then this is a valid message
					if (_sendingChatMessage)
					{
						this._chatMessageSender(m_textToValidate);
						
						this.textField.htmlText = "";
					}
					else
					{
						// just display our message without any red
						this.htmlText = this.text;
					}
				}
				else	
				{
					// this message is not validated - the server the message back with 
					// rejected words - format them in red
					var badWords:Array = validationMessage.split(",");
					var textToView:String = "";
					var startIndex:int = 0;
					for (var i:int = 0; i < badWords.length; i++)
					{
						var word:String = badWords[i];
						
						// get the index of "word" - it's the next item in the array
						// example: "shit,5,ass,17" means that 'shit' is at string index 5 and 'ass' is at 17 
						var index:int = badWords[++i];
						
						textToView += m_textToValidate.substring(startIndex, index) +
								"<FONT color='#ff0000'>" + m_textToValidate.substr(index, word.length) + "</FONT>";
						startIndex = index + word.length;
					}
					textToView += m_textToValidate.substring(startIndex, m_textToValidate.length);					
			        this.htmlText = this.text.replace(m_textToValidate, textToView);
			        
			        var alert:SdgAlertChrome = SdgAlertChrome.show("That's not allowed, keep it clean.", "Time Out");
			        alert.setFocus();
			        _hasBadWords = true;
			 	}
			 	
				_sendingChatMessage = false;
			}
		}
		
		public function get chatEnabled():Boolean
		{
			return _chatEnabled;
		}
		public function set chatEnabled(value:Boolean):void
		{
			_chatEnabled = value;
			
			if (_chatEnabled)
			{
				if (text == _disabledTest) text = '';
			}
			else
			{
				text = _disabledTest;
			}
		}
	}
}