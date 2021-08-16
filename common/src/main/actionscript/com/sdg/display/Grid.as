package com.sdg.display
{
	import com.sdg.events.GridItemEvent;
	import com.sdg.model.DisplayObjectCollection;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	public class Grid extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _rows:int;
		protected var _cols:int;
		protected var _spacingX:Number;
		protected var _spacingY:Number;
		protected var _unitWidth:Number;
		protected var _unitHeight:Number;
		protected var _displayObjects:Array;
		protected var _containers:Array;
		protected var _containerFitType:String;
		protected var _containerAlignX:String;
		protected var _containerAlignY:String;
		protected var _useDeviderLines:Boolean;
		protected var _deviderLineStyle:LineStyle;
		protected var _deviderLineLayer:Sprite;
		protected var _visibleArea:Rectangle;
		protected var _visibleAreaBuffer:Number;
		protected var _containersLayer:Sprite;
		
		/**
		 * The Grid class automatically lays out display objects in a grid.
		 */
		public function Grid(columns:Number = 1, rows:int = 1, unitWidth:Number = 100, unitHeight:Number = 100)
		{
			super();
			
			// Set initial values.
			_width = 0;
			_height = 0;
			_rows = rows;
			_cols = columns;
			_spacingX = 0;
			_spacingY = 0;
			_unitWidth = unitWidth;
			_unitHeight = unitHeight;
			_visibleAreaBuffer = 100;
			_displayObjects = [];
			_containers = [];
			_containerFitType = FitType.FIT_WITHIN;
			_containerAlignX = AlignType.MIDDLE;
			_containerAlignY = AlignType.MIDDLE;
			_useDeviderLines = false;
			_deviderLineStyle = new LineStyle(0, 1, 1);
			_deviderLineLayer = new Sprite();
			addChild(_deviderLineLayer);
			
			_containersLayer = new Sprite();
			addChild(_containersLayer);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function destroy():void
		{
			removeAll();
		}
		
		protected function render():void
		{
			var unitCount:int = _rows * _cols;
			var container:Container;
			
			// Add or remove containers as necesary.
			while(_containers.length > unitCount)
			{
				container = Container(_containers.pop());
				container.clearContent();
				_containersLayer.removeChild(container);
			}
			while(_containers.length < unitCount)
			{
				container = new Container(_unitWidth, _unitHeight);
				container.fitType = _containerFitType;
				container.alignX = _containerAlignX;
				container.alignY = _containerAlignY;
				_containers.push(container);
				_containersLayer.addChild(container);
			}
			
			// Populate and layout containers.
			var i:int = 0;
			var len:int = _containers.length;
			for (i; i < len; i++)
			{
				container = Container(_containers[i]);
				container.width = _unitWidth;
				container.height = _unitHeight;
				if (_displayObjects[i] as DisplayObject != null) container.content = _displayObjects[i];
				container.x = (container.width + _spacingX) * (i - (Math.floor(i / _cols) * _cols)) + _spacingX;
				container.y = Math.floor(i / _cols) * (container.height + _spacingY) + _spacingY;
			}
			
			// If '_useDeviderLines' is true.
			// Draw deviding lines.
			_deviderLineLayer.graphics.clear();
			if (_useDeviderLines == true)
			{
				// Draw vertical lines first.
				_deviderLineLayer.graphics.lineStyle(_deviderLineStyle.thickness, _deviderLineStyle.color, _deviderLineStyle.alpha);
				var vertLength:Number = height;
				var horzLength:Number = width;
				var halfSpacing:Number = _spacingX / 2;
				var unitWidthWithSpace:Number = _unitWidth + _spacingX;
				var unitHeightWithSpace:Number = _unitHeight + _spacingY;
				i = 1;
				len = _cols;
				for (i; i < len; i++)
				{
					var lineX:Number = unitWidthWithSpace * i - halfSpacing;
					_deviderLineLayer.graphics.moveTo(lineX, 0);
					_deviderLineLayer.graphics.lineTo(lineX, vertLength);
				}
				
				// Now draw horizontal lines.
				i = 1;
				len = _rows;
				halfSpacing = _spacingY / 2;
				for (i; i < len; i++)
				{
					var lineY:Number = unitHeightWithSpace * i - halfSpacing;
					_deviderLineLayer.graphics.moveTo(0, lineY);
					_deviderLineLayer.graphics.lineTo(horzLength, lineY);
				}
			}
			
			// update width and height properties.
			updateSize();
			
			updateVisibility();
		}
		
		public function addObject(object:DisplayObject):void
		{
			// Append the new object and redraw.
			_displayObjects.push(object);
			object.visible = false;
			render();
		}
		
		public function removeObject(object:DisplayObject):void
		{
			// If the object is part of the grid, remove it and redraw.
			// If it's not, trow an error.
			var index:int = _displayObjects.indexOf(object);
			
			if (index > -1)
			{
				_displayObjects.splice(index, 1);
			}
			else
			{
				throw(new Error(object.toString() + ' could not be found in this grid.'));
			}
			
			render();
		}
		
		public function removeObjectAt(index:int):void
		{
			try
			{
				_displayObjects.splice(index, 1);
			}
			catch (e:Error)
			{
				trace(e.message);
			}
			
			render();
		}
		
		public function removeAll():void
		{
			_displayObjects = [];
			
			// Clear containers.
			var i:uint = 0;
			var len:uint = _containers.length;
			for (i; i < len; i++)
			{
				var container:Container = _containers[i] as Container;
				if (container != null) container.clearContent();
			}
			_containers = [];
			
			// Create new container layer.
			removeChild(_containersLayer);
			_containersLayer = new Sprite();
			addChild(_containersLayer);
			
			render();
		}
		
		public function addMultipleObjects(displayObjects:DisplayObjectCollection, autoSize:Boolean = false):void
		{
			// Add multiple objects to the grid and redraw.
			var i:int = 0;
			var len:int = displayObjects.length;
			for (i; i < len; i++)
			{
				var object:DisplayObject = displayObjects.getAt(i);
				
				if (autoSize == true)
				{
					object.width = _unitWidth;
					object.height = _unitHeight;
				}
				
				addObject(object);
			}
			
			render();
		}
		
		public function setUnitSize(width:Number, height:Number):void
		{
			_unitWidth = width;
			_unitHeight = height;
			render();
		}
		
		public function updateSize():void
		{
			var oldWidth:Number = _width;
			var oldHeight:Number = _height;
			
			_width = (_unitWidth * _cols) + (_spacingX * (_cols - 1)) + _spacingX;
			_height = Math.ceil(_displayObjects.length / _cols) * (_unitHeight + _spacingY) + _spacingY;
			
			if (_width != oldWidth || _height != oldHeight)
			{
				dispatchEvent(new Event(Event.RESIZE));
			}
		}
		
		public function updateVisibility():void
		{
			// If an object in the grid does not intersect with the visible area property, hide it.
			if (_visibleArea != null)
			{
				var i:uint = 0;
				var len:uint = _displayObjects.length;
				var bufferedVisibleArea:Rectangle = new Rectangle(_visibleArea.x - _visibleAreaBuffer, _visibleArea.y - _visibleAreaBuffer, _visibleArea.width + _visibleAreaBuffer * 2, _visibleArea.height + _visibleAreaBuffer * 2);
				for (i; i < len; i++)
				{
					var dis:DisplayObject = _displayObjects[i] as DisplayObject;
					var disRect:Rectangle = dis.getBounds(this);
					var currentVisibility:Boolean = dis.visible;
					dis.visible = (bufferedVisibleArea.intersects(disRect)) ? true : false;
					
					// Check if we should dispatch grid item events.
					if (currentVisibility == false && dis.visible == true)
					{
						dispatchEvent(new GridItemEvent(GridItemEvent.INTO_VISIBILITY, dis, true));
					}
					else if (currentVisibility == true && dis.visible == false)
					{
						dispatchEvent(new GridItemEvent(GridItemEvent.OUT_OF_VISIBILITY, dis, true));
					}
				}
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get rows():int
		{
			return _rows;
		}
		public function set rows(value:int):void
		{
			_rows = value;
		}
		
		public function get columns():int
		{
			return _cols;
		}
		public function set columns(value:int):void
		{
			_cols = value;
		}
		
		public function get unitWidth():Number
		{
			return _unitWidth;
		}
		public function set unitWidth(value:Number):void
		{
			_unitWidth = value;
			render();
		}
		
		public function get unitHeight():Number
		{
			return _unitHeight;
		}
		public function set unitHeight(value:Number):void
		{
			_unitHeight = value;
			render();
		}
		
		public function get spacingX():Number
		{
			return _spacingX;
		}
		public function set spacingX(value:Number):void
		{
			_spacingX = value;
		}
		
		public function get spacingY():Number
		{
			return _spacingY;
		}
		public function set spacingY(value:Number):void
		{
			_spacingY = value;
		}
		
		public function get containerFitType():String
		{
			return _containerFitType;
		}
		public function set containerFitType(value:String):void
		{
			_containerFitType = value;
			render();
		}
		
		public function get containerAlignX():String
		{
			return _containerAlignX;
		}
		public function set containerAlignX(value:String):void
		{
			_containerAlignX = value;
			render();
		}
		
		public function get containerAlignY():String
		{
			return _containerAlignY;
		}
		public function set containerAlignY(value:String):void
		{
			_containerAlignY = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
			//return (_unitHeight * _rows) + (_spacingY * (_rows - 1));
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		public function get useDeviderLines():Boolean
		{
			return _useDeviderLines;
		}
		public function set useDeviderLines(value:Boolean):void
		{
			_useDeviderLines = value;
			render();
		}
		
		public function get deviderLineStyle():LineStyle
		{
			return _deviderLineStyle;
		}
		public function set deviderLineStyle(value:LineStyle):void
		{
			_deviderLineStyle = value;
			render();
		}
		
		public function get length():int
		{
			return _cols * _rows;
		}
		
		public function get displayObjects():Array
		{
			return _displayObjects;
		}
		
		public function get visibleArea():Rectangle
		{
			return _visibleArea;
		}
		public function set visibleArea(value:Rectangle):void
		{
			if (_visibleArea == null ||
				Math.abs(value.x - _visibleArea.x) > _visibleAreaBuffer ||
				Math.abs(value.y - _visibleArea.y) > _visibleAreaBuffer ||
				Math.abs(value.width - _visibleArea.width) > _visibleAreaBuffer ||
				Math.abs(value.height - _visibleArea.height) > _visibleAreaBuffer)
			{
				_visibleArea = value;
				updateVisibility();
			}
		}
		
	}
}