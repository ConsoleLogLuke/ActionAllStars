package com.sdg.store.transaction
{
	import com.sdg.components.controls.store.StoreNavBar;
	import com.sdg.display.LineStyle;
	import com.sdg.graphics.GradientStyle;
	import com.sdg.graphics.RoundRectStyle;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class TokenDelivery extends Sprite
	{
		private var _tokenMessageStart:TextField;
		private var _tokenMessageEnd:TextField;
		private var _heading:TextField;
		private var _tokensField:StoreNavBar;
		private var _avatarName:String;
		private var _tokenIcon:TokenGraphic;
		private var _width:Number;
		private var _height:Number;
		
		public function TokenDelivery(width:Number, height:Number)
		{
			super();
			_width = width;
			_height = height;
			
			// Text format to be used.
			var headingFormat:TextFormat = new TextFormat('EuroStyle', 32, 0xffffff, true);
			var tf:TextFormat = new TextFormat('EuroStyle', 22, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
			
			_heading = new TextField();
			_heading.embedFonts = true;
			_heading.defaultTextFormat = headingFormat;
			_heading.autoSize = TextFieldAutoSize.LEFT;
			_heading.text = "Token Delivery";
			addChild(_heading);
			
			_tokenMessageStart = new TextField();
			_tokenMessageStart.embedFonts = true;
			_tokenMessageStart.defaultTextFormat = tf;
			_tokenMessageStart.autoSize = TextFieldAutoSize.CENTER;
			_tokenMessageStart.wordWrap = true;
			_tokenMessageStart.multiline = true;
			_tokenMessageStart.width = width - 100;
			addChild(_tokenMessageStart);
			
			_tokenMessageEnd = new TextField();
			_tokenMessageEnd.embedFonts = true;
			_tokenMessageEnd.defaultTextFormat = tf;
			_tokenMessageEnd.autoSize = TextFieldAutoSize.CENTER;
			_tokenMessageEnd.wordWrap = true;
			_tokenMessageEnd.multiline = true;
			_tokenMessageEnd.width = width - 100;
			addChild(_tokenMessageEnd);
			
			_tokensField = new StoreNavBar(260, 50);
			_tokensField.labelFormat = new TextFormat('EuroStyle', 22, 0xffffff, true);
			_tokensField.roundRectStyle = new RoundRectStyle(15, 15);
			_tokensField.borderStyle = new LineStyle(0xffffff, 1, 2);
			_tokensField.labelFilters = [new GlowFilter(0x055883, 1, 6, 6, 10, 1)];
			addChild(_tokensField);
			
			_tokenIcon = new TokenGraphic();
			var tkScale:Number = Math.min(70 / _tokenIcon.width, 70 / _tokenIcon.height);
			_tokenIcon.scaleX = _tokenIcon.scaleY = tkScale;
			_tokenIcon.filters = [new GlowFilter(0xffffff, 1, 6, 6, 10, 1)];
			addChild(_tokenIcon);
			
			this.mouseChildren = false;
		}
		
		private function render():void
		{
			_heading.x = _width/2 - _heading.width/2;
			_heading.y = 100;
			
			_tokenMessageStart.x = _width/2 - _tokenMessageStart.width/2;
			_tokenMessageStart.y = _heading.y + 80;
			
			_tokensField.x = _width/2 - _tokensField.width/2;
			_tokensField.y = _tokenMessageStart.y + _tokenMessageStart.height + 25;
			
			_tokensField.labelX = _tokensField.width/2 - _tokensField.labelWidth/2;
			
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(_tokensField.width, _tokensField.height, Math.PI/2, 0, 0);
			_tokensField.gradient = new GradientStyle(GradientType.LINEAR, [0x5fa9ce, 0x006699], [1, 1], [0, 255], gradientBoxMatrix);
			
			_tokenIcon.x = _tokensField.x - _tokenIcon.width/2 - 2;
			_tokenIcon.y = _tokensField.y + _tokensField.height/2 - _tokenIcon.height/2;
			
			_tokenMessageEnd.x = _width/2 - _tokenMessageEnd.width/2;
			_tokenMessageEnd.y = _tokensField.y + _tokensField.height + 25;
		}
		
		public function setMessages(message:String, tokenValue:int, closingMessage:String):void
		{
			_tokenMessageStart.text = message;
			_tokensField.label = tokenValue + " Tokens";
			_tokenMessageEnd.text = closingMessage;
			render();
		}
		
		public function set avatarName(value:String):void
		{
			_avatarName = value;
			render();
		}
		
//		public function set tokenValue(value:int):void
//		{
//			_tokensField.label = value + " Tokens";
//			render();
//		}
	}
}