package com.sdg.view.fandamonium
{
	import com.sdg.buttonstyle.AASButtonStyles;
	import com.sdg.controls.BasicButton;
	import com.sdg.display.AASPanelBacking;
	import com.sdg.display.AlignType;
	import com.sdg.display.Stack;
	import com.sdg.model.LiveGame;
	import com.sdg.ui.UI3PartWindow;

	public class FandamoniumTeamSelectDialog extends UI3PartWindow
	{
		private var _teamButtonStack:Stack;
		private var _teamButton1:BasicButton;
		
		public function FandamoniumTeamSelectDialog()
		{
			super();
			
			// Use standard Action AllStars panel backing.
			backing = new AASPanelBacking();
			
			_teamButtonStack = new Stack(AlignType.VERTICAL, 10);
			_middle.content = _teamButtonStack;
			
			// Team button 1.
			_teamButton1 = new BasicButton('Hello World.', 140, 30, AASButtonStyles.ORANGE_BUTTON);
			_teamButtonStack.addContainer(_teamButton1);
			
			// Set padding.
			padding = 10;
		}
		
	}
}