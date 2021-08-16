package com.sdg.gameMenus
{
	import com.sdg.buttonstyle.ButtonSyle;
	import com.sdg.buttonstyle.IButtonStyle;
	import com.sdg.components.dialog.TransactionDialog;
	import com.sdg.controls.BasicButton;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.GradientFillStyle;
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.ItemListWindow;
	
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class RBIStoreListWindow extends GameTable
	{
		protected const TEAM_ICON_WIDTH:Number = 88;
		protected const TEAM_NAME_WIDTH:Number = 218;
		protected const RECORD_WIDTH:Number = 85;
		protected const OFFENSIVE_WIDTH:Number = 121;
		protected const PITCHING_WIDTH:Number = 121;
		protected const TOKENS_WIDTH:Number = 85;
		protected const BUY_WIDTH:Number = 121;
		
		protected var _listWindow:ItemListWindow;
//		protected var _addTokensButton:BasicButton;
		protected var _storeItemsCollection:DisplayObjectCollection;
		
		public function RBIStoreListWindow(width:Number = 867, height:Number = 308, borderHeight:Number = 37, borderThickness:Number = 4)
		{
			super(width, height, borderHeight, borderThickness);
			
			_listWindow = new ItemListWindow(_width - 2 * borderThickness, _height - 2 * borderThickness - borderHeight, 1, 100, 0);
			_listWindow.widthHeightRatio = 16;
			_listWindow.x = _width/2 - _listWindow.width/2;
			_listWindow.y = borderThickness + borderHeight;
			addChild(_listWindow);
			
			var totalListWidth:Number = TEAM_ICON_WIDTH + TEAM_NAME_WIDTH + RECORD_WIDTH + OFFENSIVE_WIDTH + PITCHING_WIDTH + TOKENS_WIDTH + BUY_WIDTH;
			var startX:Number = 0;
			
			var teamTitle:TextField = new TextField();
			teamTitle.defaultTextFormat = new TextFormat('EuroStyle', 10, 0x132B50, true);
			teamTitle.embedFonts = true;
			teamTitle.autoSize = TextFieldAutoSize.LEFT;
			teamTitle.selectable = false;
			teamTitle.mouseEnabled = false;
			teamTitle.text = "TEAM";
			var teamColumnWidth:Number = (TEAM_ICON_WIDTH/totalListWidth) * (_header.width - 20);
			teamTitle.x = teamColumnWidth/2 - teamTitle.width/2;
			teamTitle.y = _header.height/2 - teamTitle.height/2;
			_header.addChild(teamTitle);
			startX += teamColumnWidth;
			
			var teamNameColumnWidth:Number = (TEAM_NAME_WIDTH/totalListWidth) * (_header.width - 20);
			startX += teamNameColumnWidth;
			
			var recordTitle:TextField = new TextField();
			recordTitle.defaultTextFormat = new TextFormat('EuroStyle', 10, 0x132B50, true);
			recordTitle.embedFonts = true;
			recordTitle.autoSize = TextFieldAutoSize.LEFT;
			recordTitle.selectable = false;
			recordTitle.mouseEnabled = false;
			recordTitle.text = "RECORD";
			var recordColumnWidth:Number = (RECORD_WIDTH/totalListWidth) * (_header.width - 20);
			recordTitle.x = startX + recordColumnWidth/2 - recordTitle.width/2;
			recordTitle.y = _header.height/2 - recordTitle.height/2;
			_header.addChild(recordTitle);
			startX += recordColumnWidth;
			
			var offensiveTitle:TextField = new TextField();
			offensiveTitle.defaultTextFormat = new TextFormat('EuroStyle', 10, 0x132B50, true, null, null, null, null, TextFormatAlign.CENTER);
			offensiveTitle.embedFonts = true;
			offensiveTitle.autoSize = TextFieldAutoSize.LEFT;
			offensiveTitle.selectable = false;
			offensiveTitle.mouseEnabled = false;
			offensiveTitle.text = "OFFENSIVE\nRANK";
			var offensiveColumnWidth:Number = (OFFENSIVE_WIDTH/totalListWidth) * (_header.width - 20);
			offensiveTitle.x = startX + offensiveColumnWidth/2 - offensiveTitle.width/2;
			offensiveTitle.y = _header.height/2 - offensiveTitle.height/2;
			_header.addChild(offensiveTitle);
			startX += offensiveColumnWidth;
			
			var pitchingTitle:TextField = new TextField();
			pitchingTitle.defaultTextFormat = new TextFormat('EuroStyle', 10, 0x132B50, true, null, null, null, null, TextFormatAlign.CENTER);
			pitchingTitle.embedFonts = true;
			pitchingTitle.autoSize = TextFieldAutoSize.LEFT;
			pitchingTitle.selectable = false;
			pitchingTitle.mouseEnabled = false;
			pitchingTitle.text = "PITCHING\nRANK";
			var pitchingColumnWidth:Number = (PITCHING_WIDTH/totalListWidth) * (_header.width - 20);
			pitchingTitle.x = startX + pitchingColumnWidth/2 - pitchingTitle.width/2;
			pitchingTitle.y = _header.height/2 - pitchingTitle.height/2;
			_header.addChild(pitchingTitle);
			startX += pitchingColumnWidth;
			
			var tokensTitle:TextField = new TextField();
			tokensTitle.defaultTextFormat = new TextFormat('EuroStyle', 10, 0x132B50, true, null, null, null, null, TextFormatAlign.CENTER);
			tokensTitle.embedFonts = true;
			tokensTitle.autoSize = TextFieldAutoSize.LEFT;
			tokensTitle.selectable = false;
			tokensTitle.mouseEnabled = false;
			tokensTitle.text = "TOKENS";
			var tokensColumnWidth:Number = (TOKENS_WIDTH/totalListWidth) * (_header.width - 20);
			tokensTitle.x = startX + tokensColumnWidth/2 - tokensTitle.width/2;
			tokensTitle.y = _header.height/2 - tokensTitle.height/2;
			_header.addChild(tokensTitle);
			startX += tokensColumnWidth;
			
//			var offStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x0088C0, 0x0F548A], [1, 1], [1, 255], Math.PI / 2), 0xffffff, 0.3, 1, 6);
//			var overStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x22aae2, 0x2F74aA], [1, 1], [1, 255], Math.PI / 2), 0xffffff, 0.3, 1, 6);
//			var downStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x0078b0, 0x0F447A], [1, 1], [1, 255], Math.PI / 2), 0xffffff, 0.3, 1, 6);
//			var style:IButtonStyle = new ButtonSyle(offStyle, overStyle, downStyle);
//			_addTokensButton = new BasicButton('ADD TOKENS', 84, 12, style);
//			_addTokensButton.labelFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
//			_addTokensButton.embedFonts = true;
//			_addTokensButton.addEventListener(MouseEvent.CLICK, onAddClick);
//			var buyColumnWidth:Number = (BUY_WIDTH/totalListWidth) * (_header.width - 20);
//			_addTokensButton.x = startX + buyColumnWidth/2 - _addTokensButton.width/2;
//			_addTokensButton.y = _header.height/2 - _addTokensButton.height/2;
//			_header.addChild(_addTokensButton);
		}
		
		protected function onAddClick(e:MouseEvent):void
		{
			MainUtil.showDialog(TransactionDialog);
		}
		
		public function destroy():void
		{
//			_addTokensButton.removeEventListener(MouseEvent.CLICK, onAddClick);
			destroyCollection();
		}
		
		protected function destroyCollection():void
		{
			for each (var row:RBIStoreGridRow in _storeItemsCollection)
				row.destroy();
			
			_storeItemsCollection = null;
		}
		
		public function set storeItems(value:Array):void
		{
			if (_storeItemsCollection) destroyCollection();
				
			_storeItemsCollection = new DisplayObjectCollection();
			
			for each (var item:RBITeamItem in value)
			{
				var row:RBIStoreGridRow = new RBIStoreGridRow(item,
															TEAM_ICON_WIDTH,
															TEAM_NAME_WIDTH,
															RECORD_WIDTH,
															OFFENSIVE_WIDTH,
															PITCHING_WIDTH,
															TOKENS_WIDTH,
															BUY_WIDTH);
				_storeItemsCollection.push(row);
			}
			
			_listWindow.items = _storeItemsCollection;
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