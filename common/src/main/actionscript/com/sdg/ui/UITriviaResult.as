package com.sdg.ui {
	import com.sdg.display.AdBlock;
	import com.sdg.display.AlignType;
	import com.sdg.display.Box;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.Container;
	import com.sdg.display.GradientFillStyle;
	import com.sdg.display.Stack;
	import com.sdg.display.YouWinNTokensBlock;
	import com.sdg.font.FontStyles;
	import com.sdg.model.GameAssetId;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class UITriviaResult extends UITriviaAlert
	{
		private var _awardedTokens:int;
		
		public function UITriviaResult(awardedTokens:int = 0)
		{
			super();
			
			// Set initial values.
			_awardedTokens = awardedTokens;
			
			// Main content.
			var mainContent:Container = new Container();
			mainContent.padding = 12;
			
			// Create the "You win: N Tockens" block.
			var youWinBlockContainer:Container = new Container();
			youWinBlockContainer.alignX = AlignType.MIDDLE;
			var youWinNTokensBlock:YouWinNTokensBlock = new YouWinNTokensBlock(_awardedTokens);
			youWinNTokensBlock.filters = [new DropShadowFilter(2, 45, 0, 0.2, 12, 12)];
			youWinBlockContainer.content = youWinNTokensBlock;
			
			// Middle left container.
			var middleLeftContainer:Container = new Container();
			middleLeftContainer.paddingLeft = middleLeftContainer.paddingRight = 24;
			
			// Midle left stack.
			var middleLeftStack:Stack = new Stack(AlignType.VERTICAL, 12);
			
			// Ad block.
			var adBlock:AdBlock = new AdBlock(248, 234);
			adBlock.cornerSize = 24;
			// Load ad content.
			var adImage:DisplayObject = new QuickLoader(AssetUtil.GetGameAssetUrl(GameAssetId.TRIVIA, 'trivia_ad.swf'), adImageComplete);
			function adImageComplete():void
			{
				adBlock.content = adImage;
			}
			
			// Create content for middle container.
			var genericContainer:Container;
			var middleStack:Stack = new Stack(AlignType.HORIZONTAL, 12);
			var congratsText:TextField = new TextField();
			congratsText.defaultTextFormat = new TextFormat('GillSans', 32, 0xffffff, true);
			congratsText.styleSheet = FontStyles.GILL_SANS;
			congratsText.autoSize = TextFieldAutoSize.CENTER;
			congratsText.selectable = false;
			congratsText.embedFonts = true;
			congratsText.text = 'Congratulations!';
			congratsText.filters = [new GlowFilter(0xa92135, 1, 3, 3, 10, 2)];
			genericContainer = new Container();
			genericContainer.alignY = AlignType.MIDDLE;
			genericContainer.paddingTop = genericContainer.paddingBottom = 12;
			genericContainer.content = congratsText;
			middleLeftStack.addContainer(genericContainer);
			middleLeftStack.addContainer(youWinBlockContainer);
			middleLeftContainer.content = middleLeftStack;
			middleStack.addContainer(middleLeftContainer);
			middleStack.addContainer(adBlock);
			mainContent.content = middleStack;
			_middle.content = mainContent;
			
			// Size some elements.
			youWinBlockContainer.width = middleLeftContainer.width - middleLeftContainer.paddingLeft - middleLeftContainer.paddingRight;
			
			// Create backing for main content.
			var mainContentBacking:Box = new Box();
			mainContentBacking.style = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xa1d6ff, 0xffffff], [1, 1], [1, 120], Math.PI/2), 0x0772c4, 1, 6, 18);
			mainContent.backing = mainContentBacking;
			
			_render();
			
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		
		////////////////////
		// EVENT HANDLERS
		////////////////////

		
	}
}
