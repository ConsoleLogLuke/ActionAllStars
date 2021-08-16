package com.sdg.view
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.sdg.events.GamePlaceChangeEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class GamePlaceView extends Sprite
	{
		protected var _iconSize:Number;
		
		private var _animMan:AnimationManager;
		private var _spacing:Number;
		private var _data:Array;
		private var _margin:Number;
		
		public function GamePlaceView(iconSize:Number = 20, spacing:Number = 10)
		{
			super();
			
			_iconSize = iconSize;
			_spacing = spacing;
			_data = [];
			_margin = 3;
			
			_animMan = new AnimationManager();
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function destroy():void
		{
			_animMan.dispose();
			_animMan = null;
			
			_data = null;
		}
		
		public function addItem(id:int, score:int, color:uint):void
		{
			// Make sure an item with this id hasnt already been added.
			if (getData(id)) return;
			
			var icon:DisplayObject = createIcon(color);
			icon.x = _margin;
			var data:Object = {id: id, score: score, color: color, icon: icon, placeIndex: _data.length};
			_data.push(data);
			
			addChild(icon);
			
			repositionIcons();
			
			renderBacking();
		}
		
		public function removeItem(id:int):void
		{
			var data:Object = getData(id);
			if (!data) return;
			
			removeChild(data.icon);
			
			_data.splice(_data.indexOf(data), 1);
			
			// Decrement place index.
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				Object(_data[i]).placeIndex = i;
			}
			
			repositionIcons();
			
			renderBacking();
		}
		
		public function setScore(id:int, score:int):void
		{
			var data:Object = getData(id);
			if (!data) return;
			
			data.score = score;
			repositionIcons();
		}
		
		public function getLeaderId():int
		{
			var leaderData:Object = _data[0] as Object;
			return (leaderData) ? leaderData.id : -1;
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		protected function createIcon(color:uint):DisplayObject
		{
			var size:Number = _iconSize / 2;
			var i:Sprite = new Sprite();
			i.graphics.beginFill(color);
			i.graphics.lineStyle(2, 0);
			i.graphics.drawCircle(size, size, size);
			
			return i;
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function getData(id:int):Object
		{
			for each (var data:Object in _data)
			{
				if (data.id == id) return data;
			}
			
			return null;
		}
		
		private function repositionIcons():void
		{
			// Sort data by score.
			_data.sort(scoreSort);
			
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var data:Object = _data[i];
				// Reposition icons.
				var icon:DisplayObject = data.icon;
				icon.x = _margin;
				var newY:Number = (_iconSize + _spacing) * i + _margin;
				if (icon.y != newY) _animMan.move(icon, icon.x, newY, 500, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				// Update places.
				if (i != data.placeIndex)
				{
					if (i > data.placeIndex)
					{
						dispatchEvent(new GamePlaceChangeEvent(GamePlaceChangeEvent.PLACE_DOWN, data.id, data.placeIndex, i, true));
					}
					else
					{
						dispatchEvent(new GamePlaceChangeEvent(GamePlaceChangeEvent.PLACE_UP, data.id, data.placeIndex, i, true));
					}
				}
				data.placeIndex = i;
				if (icon['value']) icon['value'] = i + 1;
			}
			
			function scoreSort(a:Object, b:Object):int
			{
				if (a.score < b.score)
				{
					return 1;
				}
				else if (a.score > b.score)
				{
					return -1;
				}
				else
				{
					return 0;
				}
			}
		}
		
		private function renderBacking():void
		{
			var w:Number = _iconSize + _margin * 2;
			var h:Number = (_iconSize + _spacing) * _data.length - _spacing + (_margin * 2);
			graphics.clear();
			graphics.beginFill(0xffffff, 0.8);
			graphics.drawRoundRect(0, 0, w, h, _margin * 2, _margin * 2);
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		override public function get width():Number
		{
			return _iconSize;
		}
		
		public function get length():int
		{
			return _data.length;
		}
		
	}
}