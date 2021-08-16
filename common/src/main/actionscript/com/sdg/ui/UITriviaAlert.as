package com.sdg.ui
{
	import com.sdg.controls.AASDialogButton;
	import com.sdg.event.UIDialogueEvent;
	import com.sdg.trivia.TriviaResultPanelBacking;
	
	import flash.events.MouseEvent;
	
	public class UITriviaAlert extends UI3PartWindow
	{
		public function UITriviaAlert()
		{
			super();
			
			_middle.paddingLeft = _middle.paddingRight = 12;
			_bottom.paddingTop = 12;
			
			// Set content for the top container. It is a logo.
			_top.content = new AASTriviaLogo();
			
			// Create an 'OK' button for the bottom container.
			var okBtn:AASDialogButton = new AASDialogButton('OK');
			okBtn.label.embedFonts = true;
			okBtn.addEventListener(MouseEvent.CLICK, _okClick);
			_bottom.content = okBtn;
			
			// Use standard Action AllStars panel backing.
			backing = new TriviaResultPanelBacking();
			
			// Use 24 pixel padding.
			padding = 24;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		protected function _okClick(e:MouseEvent):void
		{
			dispatchEvent(new UIDialogueEvent(UIDialogueEvent.OK));
		}
		
	}
}