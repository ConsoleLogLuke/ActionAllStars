package com.sdg.display
{
	import com.sdg.font.FontStyles;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class YouWinNTokensBlock extends Container
	{
		private var _youWinTextContainer:Container;
		private var _textContainer:Container;
		private var _tokenAnimationContainer:Container;
		
		public function YouWinNTokensBlock(nTokens:int = 0)
		{
			super();
			
			// Create the "You win: N Tockens" block.
			
			// Token animation container.
			_tokenAnimationContainer = new Container();
			_tokenAnimationContainer.alignY = AlignType.MIDDLE;
			_tokenAnimationContainer.content = new TokensImage();
			
			// You win container.
			_youWinTextContainer = new Container();
			_youWinTextContainer.alignX = AlignType.MIDDLE;
			
			// Text container.
			_textContainer = new Container();
			var youWinText:TextField = new TextField();
			youWinText.autoSize = TextFieldAutoSize.CENTER;
			youWinText.defaultTextFormat = new TextFormat('GillSans', 28, 0, true);
			youWinText.styleSheet = FontStyles.GILL_SANS;
			youWinText.selectable = false;
			youWinText.embedFonts = true;
			youWinText.text = 'You win:';
			_youWinTextContainer.content = youWinText;
			var nTokensText:TextField = new TextField();
			nTokensText.defaultTextFormat = new TextFormat('GillSans', 28, 0x194b88, true);
			nTokensText.styleSheet = FontStyles.GILL_SANS;
			nTokensText.autoSize = TextFieldAutoSize.CENTER;
			nTokensText.selectable = false;
			nTokensText.embedFonts = true;
			nTokensText.text = nTokens + ' Tokens';
			var nTokensContainer:Container = new Container();
			nTokensContainer.content = nTokensText;
			var textStack:Stack = new Stack(AlignType.VERTICAL);
			textStack.addContainer(_youWinTextContainer);
			textStack.addContainer(nTokensContainer);
			_textContainer.content = textStack;
			
			var horizontalStack:Stack = new Stack(AlignType.HORIZONTAL, 12);
			horizontalStack.addContainer(_tokenAnimationContainer);
			horizontalStack.addContainer(_textContainer);
			
			// Create backing.
			var panelBacking:Box = new Box();
			panelBacking.style = new BoxStyle(new FillStyle(0xffffff, 1), 0xb9e0ff, 1, 4, 12);
			backing = panelBacking;
			
			// Set a 12 pixel padding.
			padding = 24;
			
			content = horizontalStack;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override protected function _render():void
		{
			super._render();
			
			_youWinTextContainer.width = _textContainer.width - _textContainer.paddingLeft - _textContainer.paddingRight;
			_tokenAnimationContainer.height = _height - _paddingTop - _paddingBottom;
		}
		
	}
}