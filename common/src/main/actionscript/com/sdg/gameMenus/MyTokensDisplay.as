package com.sdg.gameMenus
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class MyTokensDisplay extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _tokensText:TextField;
		
		public function MyTokensDisplay(tokens:int, width:Number = 260, height:Number = 50)
		{
			super();
			
			_width = width;
			_height = height;
			
			var tokensBunch:Sprite = createTokenBunch();
			tokensBunch.x = _width - tokensBunch.width;
			tokensBunch.y = _height/2 - tokensBunch.height/2;
			
			var tokensContainer:Sprite = new Sprite();
			tokensContainer.graphics.beginFill(0xffffff);
			tokensContainer.graphics.drawRoundRect(0, 0, _width - tokensBunch.width/2, _height - 4, 10, 10);
			tokensContainer.y = _height/2 - tokensContainer.height/2;
			
			var textContainer:Sprite = new Sprite();
			
			var myTokensText:TextField = new TextField();
			myTokensText.defaultTextFormat = new TextFormat('EuroStyle', 14, 0x848A8C, true);
			myTokensText.embedFonts = true;
			myTokensText.autoSize = TextFieldAutoSize.LEFT;
			myTokensText.selectable = false;
			myTokensText.mouseEnabled = false;
			myTokensText.text = "My Tokens:";
			textContainer.addChild(myTokensText);
			
			_tokensText = new TextField();
			_tokensText.defaultTextFormat = new TextFormat('EuroStyle', 22, 0x335580, true);
			_tokensText.embedFonts = true;
			_tokensText.autoSize = TextFieldAutoSize.LEFT;
			_tokensText.selectable = false;
			_tokensText.mouseEnabled = false;
			_tokensText.text = tokens.toString();
			_tokensText.y = myTokensText.y + myTokensText.height - 6;
			textContainer.addChild(_tokensText);
			
			textContainer.x = 15;
			textContainer.y = tokensContainer.height/2 - textContainer.height/2 + 2;
			tokensContainer.addChild(textContainer);
			
			addChild(tokensContainer);
			addChild(tokensBunch);
		}
		
		private function createTokenBunch():Sprite
		{
			var container:Sprite = new Sprite();
			var tkSize:Number = 30;
			var overlap:Number = 10;
			
			var tk:TokenGraphic = new TokenGraphic();
			var tkScale:Number = Math.min(tkSize / tk.width, tkSize / tk.height);
			tk.scaleX = tk.scaleY = tkScale;
			tk.x = tk.width/2 - overlap/2;
			container.addChild(tk);
			
			tk = new TokenGraphic();
			tk.scaleX = tk.scaleY = tkScale;
			tk.y = tk.height - overlap;
			container.addChild(tk);
			
			tk = new TokenGraphic();
			tk.scaleX = tk.scaleY = tkScale;
			tk.x = tk.width - overlap;
			tk.y = tk.height - overlap;
			container.addChild(tk);
			
			return container;
		}
		
		public function set tokens(value:int):void
		{
			_tokensText.text = value.toString();
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;
		}
	}
}