package com.sdg.gameMenus
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TeamSelectBox extends Sprite
	{
		protected const BORDER_THICKNESS:Number = 3;
		protected const LINE_WIDTH:Number = 1;
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _itemScroll:ItemScroll;
		protected var _selectedTeam:TextField;
		
		public function TeamSelectBox(width:Number = 415, height:Number = 250, topEdgeHeight:Number = 15, bottomEdgeHeight:Number = 25)
		{
			super();
			_width = width;
			_height = height;
			
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(_width, _height, Math.PI/2, 0, 0);
			
			graphics.lineStyle(BORDER_THICKNESS, 0x718799);
			graphics.beginGradientFill(GradientType.LINEAR, [0xA3B0C4, 0xD3DAE1], [1, 1], [1, 255], gradientBoxMatrix);
			graphics.drawRect(BORDER_THICKNESS/2, BORDER_THICKNESS/2, _width-BORDER_THICKNESS, _height-BORDER_THICKNESS);
			graphics.endFill();
			
			graphics.lineStyle();
			graphics.beginFill(0x172D54);
			graphics.drawRect(BORDER_THICKNESS, BORDER_THICKNESS, _width - 2*BORDER_THICKNESS, topEdgeHeight);
			graphics.endFill();
			
			graphics.lineStyle(LINE_WIDTH, 0x718799);
			graphics.beginFill(0xB8C0C7);
			graphics.drawRect(BORDER_THICKNESS - LINE_WIDTH/2,
							_height - BORDER_THICKNESS + LINE_WIDTH/2 - bottomEdgeHeight,
							_width - 2*BORDER_THICKNESS + LINE_WIDTH, bottomEdgeHeight);
			graphics.endFill();
			
			var selectionBox:Sprite = new Sprite();
			selectionBox.graphics.lineStyle(LINE_WIDTH, 0x718799);
			selectionBox.graphics.beginFill(0xB8C0C7);
			selectionBox.graphics.drawRect(0, 0, 140, 140);
			addChild(selectionBox);
						
			_itemScroll = new ItemScroll(_width, _height - topEdgeHeight - bottomEdgeHeight - 2*BORDER_THICKNESS);
			_itemScroll.addEventListener("selectedIndexChanged", onSelectedChanged);
			_itemScroll.y = topEdgeHeight + BORDER_THICKNESS;
			addChild(_itemScroll);
			
			selectionBox.x = _width/2 - selectionBox.width/2;
			selectionBox.y = _itemScroll.y + _itemScroll.height/2 - selectionBox.height/2;
			
			var playAs:TextField = new TextField();
			playAs.defaultTextFormat = new TextFormat('EuroStyle', 20, 0x69758D, true);
			playAs.embedFonts = true;
			playAs.autoSize = TextFieldAutoSize.LEFT;
			playAs.selectable = false;
			playAs.mouseEnabled = false;
			playAs.text = "Play as:";
			playAs.x = _width/2 - playAs.width/2;
			playAs.y = _itemScroll.y + 3;
			addChild(playAs);
			
			_selectedTeam = new TextField();
			_selectedTeam.defaultTextFormat = new TextFormat('EuroStyle', 20, 0x69758D, true);
			_selectedTeam.embedFonts = true;
			_selectedTeam.autoSize = TextFieldAutoSize.LEFT;
			_selectedTeam.selectable = false;
			_selectedTeam.mouseEnabled = false;
			addChild(_selectedTeam);
		}
		
		protected function onSelectedChanged(event:Event):void
		{
			var scrollItem:TeamSelectScrollItem = _itemScroll.selectedItem as TeamSelectScrollItem;
			var team:GameTeamItem = scrollItem.team;
			_selectedTeam.text = team.name;
			_selectedTeam.x = _width/2 - _selectedTeam.width/2;
			_selectedTeam.y = _itemScroll.y + _itemScroll.height - _selectedTeam.height -  3;
		}
		
		public function destroy():void
		{
			_itemScroll.removeEventListener("selectedIndexChanged", onSelectedChanged);
			_itemScroll.destroy();
		}
		
		public function set teams(value:Array):void
		{
			_itemScroll.removeAllItems();
			var itemSize:Number = _itemScroll.windowSize/3;
			for each (var team:GameTeamItem in value)
			{
				_itemScroll.addScrollItem(new TeamSelectScrollItem(team, itemSize, itemSize));
			}
			
			_itemScroll.selectedIndex = 0;
		}
		
		public function get selectedTeam():GameTeamItem
		{
			var gameTeamItem:GameTeamItem;
			
			var selection:TeamSelectScrollItem = _itemScroll.selectedItem as TeamSelectScrollItem;
			if (selection != null)
				gameTeamItem = selection.team;
			
			return gameTeamItem;
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