package com.sdg.components.controls
{
	import com.sdg.components.events.InteractiveGridEvent;
	import com.sdg.components.skins.GridBackgroundSkin;
	import com.sdg.components.skins.InteractiveGridIndicator;
	import com.sdg.utils.ComponentUtil;
	import com.sdg.utils.DrawUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	
	import mx.core.FlexShape;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	use namespace mx_internal;
	
	
	[Event(name="tileClick", type="com.sdg.components.events.InteractiveGridEvent")]
	
	[Event(name="tileDown", type="com.sdg.components.events.InteractiveGridEvent")]
	
	[Event(name="tileUp", type="com.sdg.components.events.InteractiveGridEvent")]
	
	[Event(name="tileHover", type="com.sdg.components.events.InteractiveGridEvent")]
	
	
	[Style(name="backgroundSkin", type="Class", inherit="no")]
	
	[Style(name="gridFillAlpha", type="Number", inherit="yes")]
	
	[Style(name="gridFillColors", type="Array", arrayType="uint", format="Color", inherit="yes")]

	[Style(name="gridLineAlpha", type="Number", inherit="yes")]
	
	[Style(name="gridLineColor", type="uint", format="Color", inherit="yes")]
	
	[Style(name="highlightColor", type="uint", format="Color", inherit="yes")]
	
	[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
	
	[Style(name="rollOverIndicatorSkin", type="Class", inherit="yes")]
	
	[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]
	
	[Bindable]
	public class InteractiveGrid extends UIComponent
	{
		protected var background:IFlexDisplayObject;
		protected var gridLineLayer:FlexShape;
		protected var gridSizeChanged:Boolean = true;
		protected var rollOverIndicator:IFlexDisplayObject;
		protected var indicatorChanged:Boolean = true;
		
		private var _backgroundVisible:Boolean = true;
		private var _buttonDownFlag:Boolean = false;
		private var _columns:uint = 10;
		private var _rows:uint = 10;
		private var _columnWidth:Number = 1;
		private var _rowHeight:Number = 1;
		private var _mouseColumn:int = -1;
		private var _mouseRow:int = -1;
		private var _indicatorVisible:Boolean = true;
		private var _indicatorColumns:uint = 1;
		private var _indicatorRows:uint = 1;
		
		public function get backgroundVisible():Boolean
		{
			return _backgroundVisible;
		}
		
		public function set backgroundVisible(value:Boolean):void
		{
			if (value != _backgroundVisible)
			{
				_backgroundVisible = value;
				
				if (background)
				{
					if (!_backgroundVisible)
						removeChild(DisplayObject(background));
					else
						addChildAt(DisplayObject(background), 0);
				}
			}
		}
		
		public function get columns():uint
		{
			return _columns;
		}
		
		public function set columns(value:uint):void
		{
			if (value == 0) _columns = 1;
			else _columns = value;
			invalidateGridSize();
		}
		
		public function get rows():uint
		{
			return _rows;
		}
		
		public function set rows(value:uint):void
		{
			if (value == 0) _rows = 1;
			else _rows = value;
			invalidateGridSize();
		}
		
		public function get columnWidth():Number
		{
			return _columnWidth;
		}
		
		public function set columnWidth(value:Number):void
		{
			_columnWidth = value;
			invalidateGridSize();
		}
		
		public function get rowHeight():Number
		{
			return _rowHeight;
		}
		
		public function set rowHeight(value:Number):void
		{
			_rowHeight = value;
			invalidateGridSize();
		}
		
		public function get mouseColumn():Number
		{
			return _mouseColumn;
		}
		
		public function get mouseRow():Number
		{
			return _mouseRow;
		}
		
		public function get indicatorVisible():Boolean
		{
			return _indicatorVisible;
		}
		
		public function set indicatorVisible(value:Boolean):void
		{
			if (value != _indicatorVisible)
			{
				_indicatorVisible = value;
				indicatorChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get indicatorColumns():uint
		{
			return _indicatorColumns;
		}
		
		public function set indicatorColumns(value:uint):void
		{
			if (value != _indicatorColumns)
			{
				_indicatorColumns = value;
				indicatorChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get indicatorRows():uint
		{
			return _indicatorRows;
		}
		
		public function set indicatorRows(value:uint):void
		{
			if (value != _indicatorRows)
			{
				_indicatorRows = value;
				indicatorChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function InteractiveGrid()
		{
			invalidateSizeFlag = true;
			addEventListener(FlexEvent.ADD, addHandler);
			addEventListener(FlexEvent.REMOVE, removeHandler);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (!background)
			{
				background = ComponentUtil.createSkin(this, "backgroundSkin", GridBackgroundSkin);
				if (_backgroundVisible) addChild(background as DisplayObject);
			}
			
			if (!gridLineLayer)
			{
				gridLineLayer = new FlexShape();
				addChild(gridLineLayer);
			}
			
			if (!rollOverIndicator)
			{
				rollOverIndicator = ComponentUtil.createSkin(this, "rollOverIndicatorSkin", InteractiveGridIndicator);
				rollOverIndicator.visible = false;
				addChild(rollOverIndicator as DisplayObject);
			}
		}
		
		protected function invalidateGridSize():void
		{
			gridSizeChanged = true;
			invalidateSize();
		}
		
		override public function validateSize(recursive:Boolean = false):void
		{
			explicitWidth = _columnWidth * _columns;
			explicitHeight = _rowHeight * _rows;
			
			super.validateSize(recursive);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			if (gridSizeChanged)
			{
				background.setActualSize(explicitWidth, explicitHeight);
				drawGridLines();
				gridSizeChanged = false;
			}
			
			if (indicatorChanged)
			{
				rollOverIndicator.visible = _indicatorVisible;
				indicatorChanged = false;
			}
			
			updateMouseGridPosition();
		}
		
		protected function drawGridLines():void
		{
			var g:Graphics = gridLineLayer.graphics;
			g.clear();
			
			var gridLineAlpha:Number = getStyle("gridLineAlpha");
			
			if (gridLineAlpha > 0)
			{
				g.lineStyle(1, getStyle("gridLineColor"), gridLineAlpha, false, "none");
				DrawUtil.drawGrid(g, _columns, _rows, _columnWidth, _rowHeight);
			}
		}
		
		protected function addMouseListeners():void
		{
			addEventListener(MouseEvent.CLICK, mouseClickHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        	systemManager.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        	systemManager.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		protected function removeMouseListeners():void
		{
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		protected function mouseClickHandler(event:MouseEvent):void
		{
			if (validateMousePosition())
				dispatchMouseEvent(InteractiveGridEvent.TILE_CLICK);
		}
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			_buttonDownFlag = true;
			if (validateMousePosition())
				dispatchMouseEvent(InteractiveGridEvent.TILE_DOWN);
		}
		
		protected function mouseUpHandler(event:MouseEvent):void
		{
			_buttonDownFlag = false;
			if (validateMousePosition())
				dispatchMouseEvent(InteractiveGridEvent.TILE_UP);
		}
		
		protected function mouseOutHandler(event:MouseEvent):void
		{
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			setMouseGridPosition(-1, -1);
		}
		
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			updateMouseGridPosition();
		}
		
		protected function updateMouseGridPosition():void
		{
			setMouseGridPosition( Math.floor(mouseX / _columnWidth),
								  Math.floor(mouseY / _rowHeight))
		}
		
		protected function setMouseGridPosition(column:int, row:int):void
		{
			if (column < 0 || column >= _columns || row < 0 || row >= _rows)
				column = -1, row = -1;
			
			if (column != _mouseColumn || row != _mouseRow)
			{
				_mouseColumn = column;
				_mouseRow = row;
				
				updateIndicator();
				
				dispatchMouseEvent(InteractiveGridEvent.TILE_HOVER);
			}
		}
		
		protected function updateIndicator():void
		{
			if (!rollOverIndicator) return;
			
			if (validateMousePosition())
			{
				rollOverIndicator.x = _mouseColumn * _columnWidth;
				rollOverIndicator.y = _mouseRow * _rowHeight;
				rollOverIndicator.setActualSize(_columnWidth * Math.min(_indicatorColumns, _columns - _mouseColumn), 
												_rowHeight * Math.min(_indicatorRows, _rows - _mouseRow));
			}
		}
		
		private function validateMousePosition():Boolean
		{
			return _mouseColumn > -1 && _mouseRow > -1;
		}
		
		private function dispatchMouseEvent(eventType:String):void
		{
			dispatchEvent(new InteractiveGridEvent(eventType, true, true, 
												   _mouseColumn, _mouseRow,
												   _buttonDownFlag));
		}
		
		private function addHandler(event:FlexEvent):void
		{
			addMouseListeners();
		}
		
		private function removeHandler(event:FlexEvent):void
		{
			removeMouseListeners();
		}
	}
}