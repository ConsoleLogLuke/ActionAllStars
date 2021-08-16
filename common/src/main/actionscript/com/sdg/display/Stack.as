package com.sdg.display
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * The Stack class contains Container objects and lays them out in a stack.
	 */
	public class Stack extends Sprite
	{
		protected var _containers:Array;
		protected var _spacing:Number;
		protected var _alignType:String;
		protected var _width:Number;
		protected var _height:Number;
		protected var _sizeIsAccurate:Boolean;
		protected var _equalizeSize:Boolean;
		
		public function Stack(alignType:String = AlignType.HORIZONTAL, spacing:Number = 0)
		{
			super();
			
			// Set initial values.
			_containers = [];
			_spacing = spacing;
			_alignType = alignType;
			_sizeIsAccurate = false;
			_equalizeSize = false;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		protected function render():void
		{
			// Populate and layout containers.
			var i:int = 0;
			var len:int = _containers.length;
			var stackWidth:Number = 0;
			var stackHeight:Number = 0;
			var container:Container;
			var alignFunction:Function;
			var equalizeFunction:Function;
			var equalWidth:Number;
			var equalHeight:Number;
			if (_alignType == AlignType.VERTICAL)
			{
				equalWidth = width;
				alignFunction = verticalAlign;
				equalizeFunction = equalizeWidth;
			}
			else
			{
				equalHeight = height;
				alignFunction = horizontalAlign;
				equalizeFunction = equalizeHeight;
			}
			for (i; i < len; i++)
			{
				container = _containers[i] as Container;
				
				if (container == null) continue;
				
				// If '_equalizeSize' is true make all the containers
				// as wide as the widest (if vertical aligned)
				// or as high as the highest (if horizontal aligned).
				if (_equalizeSize == true) equalizeFunction();
				
				// Align the containers. Either horizontaly or vertically.
				alignFunction();
			}
			
			function horizontalAlign():void
			{
				container.x = stackWidth + (_spacing * i);
				stackWidth += container.width;
				container.y = 0;
			}
			function verticalAlign():void
			{
				container.x = 0;
				container.y = stackHeight + (_spacing * i);
				stackHeight += container.height;
			}
			function equalizeWidth():void
			{
				container.width = width;
			}
			function equalizeHeight():void
			{
				container.height = height;
			}
		}
		
		public function addContainer(container:Container):void
		{
			// Append the new container and redraw.
			_containers.push(container);
			addChild(container);
			container.addEventListener(Event.RESIZE, _containerResize);
			render();
			
			// Anytime a container is added or removed, '_sizeIsAccurate' is set to false.
			// '_width' and '_height' properties will be recalculated.
			_sizeIsAccurate = false;
			
			// Dispatch a resize event.
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		public function addContainerAt(container:Container, index:int):void
		{
			// Remove current container at that index, if any.
			var currentContainer:Container = _containers[index] as Container;
			if (currentContainer != null)
			{
				currentContainer.removeEventListener(Event.RESIZE, _containerResize);
				removeChild(currentContainer);
			}
			
			// Append the new container and redraw.
			_containers[index] = container;
			addChild(container);
			container.addEventListener(Event.RESIZE, _containerResize);
			render();
			
			// Anytime a container is added or removed, '_sizeIsAccurate' is set to false.
			// '_width' and '_height' properties will be recalculated.
			_sizeIsAccurate = false;
			
			// Dispatch a resize event.
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		public function removeContainer(container:Container):void
		{
			// If the container is part of the stack, remove it and redraw.
			// If it's not, trow an error.
			var index:int = _containers.indexOf(container);
			
			if (index > -1)
			{
				_containers.splice(index, 1);
				container.removeEventListener(Event.RESIZE, _containerResize);
				removeChild(container);
				
				// Anytime a container is added or removed, '_sizeIsAccurate' is set to false.
				// '_width' and '_height' properties will be recalculated.
				_sizeIsAccurate = false;
				
				// Dispatch a resize event.
				dispatchEvent(new Event(Event.RESIZE));
			}
			else
			{
				throw(new Error('This conatiner is not part of the stack.'));
			}
			
			render();
		}
		
		public function removeContainerAt(index:int):void
		{
			try
			{
				_containers.splice(index, 1);
			}
			catch (e:Error)
			{
				trace(e.message);
			}
			
			render();
		}
		
		public function addMultipleContainers(containers:Array):void
		{
			// Add multiple objects to the grid and redraw.
			var i:int = 0;
			var len:int = containers.length;
			for (i; i < len; i++)
			{
				var container:Container = containers[i] as Container;
				if (container != null)
				{
					addContainer(container);
				}
				else
				{
					throw(new Error(Object(containers[i]).toString() + ' is not a Container.'));
				}
			}
			
			render();
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get spacing():Number
		{
			return _spacing;
		}
		public function set spacing(value:Number):void
		{
			_spacing = value
			render();
		}
		
		public function get alignType():String
		{
			return _alignType;
		}
		public function set alignType(value:String):void
		{
			_alignType = value
			render();
		}
		
		
		private function _containerResize(e:Event):void
		{
			// If a container in the stack has resized, re-render.
			if (_containers.indexOf(e.currentTarget) > -1)
			{
				_sizeIsAccurate = false;
				render();
			}
		}
		
		override public function get height():Number
		{
			if (_sizeIsAccurate == true) return _height;
			
			var i:int = 0;
			var len:int = _containers.length;
			var h:Number = 0;
			var container:Container;
			
			if (alignType == AlignType.HORIZONTAL)
			{
				// Return the height of the tallest object in the stack.
				for (i; i < len; i++)
				{
					container = _containers[i] as Container;
					if (container == null) continue;
					h = Math.max(h, container.height);
				}
			}
			else
			{
				// Return the height of all the objects combinied plus spacing.
				for (i; i < len; i++)
				{
					container = _containers[i] as Container;
					if (container == null) continue;
					h += container.height;
				}
				
				// Account for spacing.
				h += _spacing * (len - 1);
			}
			
			_height = h;
			return _height;
		}
		
		override public function get width():Number
		{
			if (_sizeIsAccurate == true) return _width;
			
			var i:int = 0;
			var len:int = _containers.length;
			var w:Number = 0;
			var container:Container;
			
			if (alignType == AlignType.HORIZONTAL)
			{
				// Return the width of all the objects combinied plus spacing.
				for (i; i < len; i++)
				{
					container = _containers[i] as Container;
					if (container == null) continue;
					w += container.width;
				}
				
				// Account for spacing.
				w += _spacing * (len - 1);
			}
			else
			{
				// Return the width of the widest object in the stack.
				for (i; i < len; i++)
				{
					container = _containers[i] as Container;
					if (container == null) continue;
					w = Math.max(w, container.width);
				}
			}
			
			_width = w;
			return w;
		}
		
		/**
		 * If 'equalizeSize' is true make all the containers
		 * as wide as the widest (if vertical aligned)
		 * or as high as the highest (if horizontal aligned).
		 */
		public function get equalizeSize():Boolean
		{
			return _equalizeSize;
		}
		public function set equalizeSize(value:Boolean):void
		{
			_equalizeSize = value;
		}
		
	}
}