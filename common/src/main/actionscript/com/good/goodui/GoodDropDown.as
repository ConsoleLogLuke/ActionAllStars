package com.good.goodui
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.good.goodgraphics.GoodArrow;
	import com.good.goodgraphics.GoodRect;
	import com.sdg.model.IIdObject;
	import com.sdg.model.IdObjectCollection;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class GoodDropDown extends FluidView
	{
		public static const ITEM_SELECT:String = 'item select';
		
		protected var _margin:Number;
		protected var _shadow:DropShadowFilter;
		protected var _format:TextFormat;
		protected var _itemFormat:TextFormat;
		protected var _itemOverFormat:TextFormat;
		protected var _animMangr:AnimationManager;
		protected var _name:String;
		
		protected var _backing:GoodRect;
		protected var _mainField:TextField;
		protected var _arrow:GoodArrow;
		protected var _itemFields:Array;
		protected var _topParent:Stage;
		
		protected var _items:IdObjectCollection;
		protected var _currentItem:IIdObject;
		protected var _currentItemIndex:int;
		
		public function GoodDropDown(id:uint, name:String, items:IdObjectCollection = null, animMangr:AnimationManager = null)
		{
			super(1, 1);
			
			_name = name;
			_margin = 4;
			_currentItemIndex = -1;
			_shadow = new DropShadowFilter(1, 45, 0, 1, 2, 2);
			_items = (items) ? items : new IdObjectCollection();
			_format = new TextFormat('Arial', 14, 0xffffff, true);
			_itemFormat = new TextFormat('Arial', 14, 0);
			_itemOverFormat = new TextFormat('Arial', 14, 0xffffff);
			_animMangr = (animMangr) ? animMangr : new AnimationManager();
			
			_mainField = new TextField();
			_mainField.defaultTextFormat = _format;
			_mainField.autoSize = TextFieldAutoSize.LEFT;
			_mainField.text = name;
			_mainField.filters = [_shadow];
			_mainField.selectable = false;
			_mainField.mouseEnabled = false;
			addChild(_mainField);
			
			var h:Number = _mainField.height + _margin;
			
			_backing = new GoodRect(_mainField.width + h, h, h);
			addChildAt(_backing, 0);
			
			_arrow = new GoodArrow(_mainField.height / 2.8, _mainField.height / 1.8);
			_arrow.rotation = 90;
			_arrow.filters = [_shadow];
			addChild(_arrow);
			
			_width = _mainField.width + h + _arrow.height + h / 2;
			_height = _mainField.height + _margin;
			
			render();
			
			buttonMode = true;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(Event.ADDED, onAdded);
		}
		
		override protected function render():void
		{
			super.render();
			
			var h:Number = _mainField.height + _margin;
			var w:Number = _width;
			
			_mainField.x = h / 2;
			_mainField.y = _margin / 2;
			
			_arrow.x = w - _arrow.width / 2 - h / 2;
			_arrow.y = h / 2;
			
			_backing.width = w;
			_backing.height = h;
		}
		
		public function destroy():void
		{
			// Remove all event listeners.
			removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			removeEventListener(Event.ADDED, onAdded);
		}
		
		protected function createItemField(item:IIdObject):TextField
		{
			var field:TextField = new TextField();
			field.defaultTextFormat = _itemFormat;
			field.autoSize = TextFieldAutoSize.LEFT;
			field.text = item.name;
			field.selectable = false;
			field.mouseEnabled = false;
			
			return field;
		}
		
		protected function getTopParent():Stage
		{
			return (_topParent != null) ?  _topParent : stage;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set items(value:IdObjectCollection):void
		{
			_items = value;
			
			// Make sure there is still a value for the current index.
			if (_currentItemIndex > -1 && !_items.getAt(_currentItemIndex))
			{
				// If there is not an item at this index anymore,
				// Try to select the first item, or deselect.
				currentItemIndex = (_items.getAt(0)) ? 0 : -1;
			}
		}
		
		public function get currentItemIndex():int
		{
			return _currentItemIndex;
		}
		public function set currentItemIndex(value:int):void
		{
			_currentItemIndex = value;
			
			// Set current item.
			var currentItem:IIdObject = _items.getAt(_currentItemIndex);
			if (!currentItem)
			{
				// Update main field.
				_mainField.text = _name;
				
				return;
			}
			
			// Set current item.
			_currentItem = currentItem;
			
			// Update main field.
			_mainField.text = _currentItem.name;
			
			// Dispatch item select event.
			dispatchEvent(new Event(ITEM_SELECT));
		}
		
		public function get color():uint
		{
			return _backing.color;
		}
		public function set color(value:uint):void
		{
			_backing.color = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onMouseOver(e:MouseEvent):void
		{
			// Remove mouse over listener.
			removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			
			// Listen for other mouse interactions.
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			// Make backing and arrow glow to indicate roll over.
			var glow:GlowFilter = new GlowFilter(0xffffff, 1, 6, 6, 2);
			_backing.filters = [glow];
			_arrow.filters = [_shadow, glow];
			
			function onRollOut(e:MouseEvent):void
			{
				// Remove event listeners.
				removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
				// Finish.
				finish();
			}
			
			function onMouseDown(e:MouseEvent):void
			{
				// Expand the drop down.
				
				// Remove event listeners.
				removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
				var h:Number = _mainField.height + _margin;
				var w:Number = _width;
				
				var scrollSpeed:Number = 6;
				var scrollButtonSize:Number = 20;
				var isScroll:Boolean = false;
				
				// Determine what dimensions we will use for the drop down.
				var dropW:Number = w - h;
				var maxDropH:Number = int.MAX_VALUE;
				
				// Create text fields for all items.
				var i:uint = 0;
				var len:uint = _items.length;
				var fields:Array = [];
				var mouseCatchers:Array = [];
				var maxW:Number = 0; // Max width of all fields.
				var minW:Number = w - h;
				var allFieldHeight:Number = 0;
				var fieldTop:Number = h;
				var fieldLeft:Number = h / 2;
				var margin:Number = h / 4;
				var topParent:Stage = getTopParent();
				if (topParent != null) maxDropH = topParent.stageHeight - getRect(topParent).y - margin;
				var fieldContainer:Sprite = new Sprite();
				for (i; i < len; i++)
				{
					// Create text field for this item.
					var field:TextField = createItemField(_items.getAt(i));
					field.x = fieldLeft + margin;
					field.y = allFieldHeight + margin;
					allFieldHeight += field.height;
					var newMaxW:Number = field.width + margin * 2;
					if (newMaxW > maxW) maxW = newMaxW;
					
					fields.push(field);
					
					// Create mouse catcher for this item.
					var mouseCatch:GoodRect = new GoodRect(field.width + margin * 2, field.height, 0, _backing.color);
					mouseCatch.x = fieldLeft;
					mouseCatch.y = field.y;
					mouseCatch.width = dropW;
					mouseCatch.alpha = 0;
					mouseCatch.addEventListener(MouseEvent.ROLL_OVER, onItemRollOver);
					
					fieldContainer.addChild(mouseCatch);
					fieldContainer.addChild(field);
					
					mouseCatchers.push(mouseCatch);
				}
				
				// Add the field container to display.
				fieldContainer.y = fieldTop;
				addChild(fieldContainer);
				
				// Save reference to item fields.
				_itemFields = fields;
				
				// Determine the height of the drop.
				var dropH:Number = h + allFieldHeight + margin * 2;
				
				// Determine if we need to allow scrolling within the drop-down because of space restrictions.
				var fieldMask:Sprite;
				var scrollUpButton:Sprite;
				var scrollDownButton:Sprite;
				var upArrow:GoodArrow;
				var downArrow:GoodArrow;
				if (dropH > maxDropH)
				{
					// We need to adjust the size of the drop,
					// Mask fields,
					// Allow scrolling control of fields.
					
					dropH = maxDropH;
					isScroll = true;
					
					// Create scroll controls.
					scrollUpButton = new Sprite();
					scrollUpButton.graphics.beginFill(0x00ff00, 0);
					scrollUpButton.graphics.drawRect(0, 0, dropW, scrollButtonSize);
					scrollUpButton.x = fieldLeft;
					scrollUpButton.y = fieldTop;
					scrollUpButton.addEventListener(MouseEvent.ROLL_OVER, onScrollUpOver);
					upArrow = new GoodArrow(7, 10, 0x000000);
					upArrow.rotation = -90;
					upArrow.x = dropW / 2;
					upArrow.y = scrollButtonSize / 2;
					scrollUpButton.addChild(upArrow);
					addChild(scrollUpButton);
					scrollDownButton = new Sprite();
					scrollDownButton.graphics.beginFill(0x00ff00, 0);
					scrollDownButton.graphics.drawRect(0, 0, dropW, scrollButtonSize);
					scrollDownButton.x = fieldLeft;
					scrollDownButton.y = dropH - scrollButtonSize;
					scrollDownButton.addEventListener(MouseEvent.ROLL_OVER, onScrollDownOver);
					downArrow = new GoodArrow(7, 10, 0x000000);
					downArrow.rotation = 90;
					downArrow.x = dropW / 2;
					downArrow.y = scrollButtonSize / 2;
					scrollDownButton.addChild(downArrow);
					addChild(scrollDownButton);
					
					// Create mask.
					fieldMask = new Sprite();
					fieldMask.graphics.beginFill(0x00ff00);
					fieldMask.graphics.drawRect(0, 0, dropW, dropH - fieldTop - scrollUpButton.height * 2);
					fieldMask.x = fieldLeft;
					fieldMask.y = fieldTop + scrollUpButton.height;
					fieldContainer.mask = fieldMask;
					addChild(fieldMask);
					
					// Adjust position of field container.
					fieldContainer.y = fieldTop + scrollUpButton.height;
					
					// Listen for scroll wheel.
					addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
				}
				
				// Create drop backing.
				var dropBacking:GoodRect = new GoodRect(1, h, 0, 0xffffff);
				dropBacking.x = fieldLeft;
				addChildAt(dropBacking, getChildIndex(_arrow) + 1);
				_animMangr.size(dropBacking, dropW, dropH, 200, Transitions.LINEAR, RenderMethod.ENTER_FRAME);
				
				// Create name field.
				var nameField:TextField = new TextField();
				nameField.defaultTextFormat = _itemFormat;
				var nameFormat:TextFormat = nameField.defaultTextFormat;
				nameFormat.bold = true;
				nameField.defaultTextFormat = nameFormat;
				nameField.autoSize = TextFieldAutoSize.LEFT;
				nameField.selectable = false;
				nameField.text = _name;
				nameField.x = fieldLeft + margin;
				nameField.y = _margin / 2;
				addChild(nameField);
				
				// Listen for roll out.
				addEventListener(MouseEvent.ROLL_OUT, onDropRollOut);
				
				function onDropRollOut(e:MouseEvent):void
				{
					removeDropDown();
				}
				
				function onItemRollOver(e:MouseEvent):void
				{
					// Determine index of item.
					var index:uint = mouseCatchers.indexOf(e.currentTarget);
					
					// Get reference to mouse catcher.
					var mouseCatch:GoodRect = e.currentTarget as GoodRect;
					
					// Listen for roll out.
					mouseCatch.addEventListener(MouseEvent.ROLL_OUT, onItemRollOut);
					
					// Show mouse catcher.
					mouseCatch.alpha = 1;
					
					// Get reference to item field.
					var field:TextField = fields[index] as TextField;
					
					// Make item field white.
					field.setTextFormat(_itemOverFormat);
					
					// Listen for clicks.
					mouseCatch.addEventListener(MouseEvent.CLICK, onItemClick);
					
					function onItemRollOut(e:MouseEvent):void
					{
						// Remove event listeners.
						mouseCatch.removeEventListener(MouseEvent.ROLL_OUT, onItemRollOut);
						mouseCatch.removeEventListener(MouseEvent.CLICK, onItemClick);
						
						// Hide mouse catcher.
						mouseCatch.alpha = 0;
						
						// Reset item field format.
						field.setTextFormat(_itemFormat);
					}
					
					function onItemClick(e:MouseEvent):void
					{
						// Remove event listeners.
						mouseCatch.removeEventListener(MouseEvent.ROLL_OUT, onItemRollOut);
						mouseCatch.removeEventListener(MouseEvent.CLICK, onItemClick);
						
						// Set current item index.
						currentItemIndex = index;
						
						// Remove drop down.
						removeDropDown();
					}
				}
				
				function removeDropDown():void
				{
					// Remove event listener.
					removeEventListener(MouseEvent.ROLL_OUT, onDropRollOut);
					
					// Remove drop down.
					removeChild(dropBacking);
					
					// Remove name field.
					removeChild(nameField);
					
					// Remove scroll controls.
					if (scrollUpButton != null)
					{
						removeChild(scrollUpButton);
						scrollUpButton.removeEventListener(MouseEvent.ROLL_OVER, onScrollUpOver);
						removeChild(scrollDownButton);
						scrollDownButton.removeEventListener(MouseEvent.ROLL_OVER, onScrollDownOver);
						
						removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
					}
					
					// Remove item fields and corresponding mouse catchers.
					var i:uint = 0;
					var len:uint = _itemFields.length;
					for (i; i < len; i++)
					{
						// Remove event listeners.
						var mouseCatcher:DisplayObject = mouseCatchers[i] as DisplayObject;
						mouseCatcher.removeEventListener(MouseEvent.ROLL_OVER, onItemRollOver);
					}
					
					// Remove field container from display.
					removeChild(fieldContainer);
					
					_itemFields = [];
					
					// Finish.
					finish();
				}
				
				function onScrollUpOver(e:MouseEvent):void
				{
					// Listen for enter frame.
					addEventListener(Event.ENTER_FRAME, onEnterFrame);
					
					// Change colors.
					scrollUpButton.graphics.beginFill(_backing.color);
					scrollUpButton.graphics.drawRect(0, 0, dropW, scrollButtonSize);
					upArrow.color = 0xffffff;
					
					// Listen for roll out.
					scrollUpButton.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
					
					function onRollOut(e:MouseEvent):void
					{
						// Stop scrolling.
						removeEventListener(Event.ENTER_FRAME, onEnterFrame);
						scrollUpButton.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
						
						// Change colors.
						scrollUpButton.graphics.clear();
						scrollUpButton.graphics.beginFill(0, 0);
						scrollUpButton.graphics.drawRect(0, 0, dropW, scrollButtonSize);
						upArrow.color = 0;
					}
					
					function onEnterFrame(e:Event):void
					{
						scroll(scrollSpeed);
					}
				}
				
				function onScrollDownOver(e:MouseEvent):void
				{
					// Listen for enter frame.
					addEventListener(Event.ENTER_FRAME, onEnterFrame);
					
					// Change colors.
					scrollDownButton.graphics.beginFill(_backing.color);
					scrollDownButton.graphics.drawRect(0, 0, dropW, scrollButtonSize);
					downArrow.color = 0xffffff;
					
					// Listen for roll out.
					scrollDownButton.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
					
					function onRollOut(e:MouseEvent):void
					{
						// Stop scrolling.
						removeEventListener(Event.ENTER_FRAME, onEnterFrame);
						scrollDownButton.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
						
						// Change colors.
						scrollDownButton.graphics.clear();
						scrollDownButton.graphics.beginFill(0, 0);
						scrollDownButton.graphics.drawRect(0, 0, dropW, scrollButtonSize);
						downArrow.color = 0;
					}
					
					function onEnterFrame(e:Event):void
					{
						scroll(-scrollSpeed);
					}
				}
				
				function onMouseWheel(e:MouseEvent):void
				{
					// When the user uses the mouse wheel,
					// scroll the field.
					scroll(e.delta * scrollSpeed);
				}
				
				function scroll(amount:Number):void
				{
					var minY:Number = scrollDownButton.y - fieldContainer.height - margin;
					var maxY:Number = fieldTop + scrollUpButton.height;
					
					trace('amount = ' + amount);
					
					if ((fieldContainer.y > minY && amount < 0) ||(fieldContainer.y < maxY && amount > 0)) fieldContainer.y += amount;
					if (fieldContainer.y < minY) fieldContainer.y = minY;
					if (fieldContainer.y > maxY) fieldContainer.y = maxY;
				}
			}
			
			function finish():void
			{
				// Remove glow.
				_backing.filters = [];
				_arrow.filters = [_shadow];
				
				// Add roll over listener.
				addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			}
		}
		
		private function onAdded(e:Event):void
		{
			// Get reference to stage.
			_topParent = stage;
		}
		
	}
}