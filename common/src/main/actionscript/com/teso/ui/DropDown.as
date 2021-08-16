package com.teso.ui
{
	import com.gskinner.motion.*;
	
	import fl.transitions.*;
	import fl.transitions.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;

	public class DropDown extends Sprite
	{
		private var _items:Array = new Array()
		protected var _overC:uint;
		protected var _backC:uint;
		protected var _w:Number;
		protected var _h:Number;
		protected var _timer:Timer;
		private var _open:Boolean = false;
		private var _defaultText:TextField;
		private var _title:String;
		private var _direction:String;
		private var _fmt:TextFormat;

		public function DropDown(w:Number, h:Number, title:String, fmt:TextFormat, colorBack:uint, itemArray:Array, direction:String, callback:Function, useEmbeddedFonts:Boolean = false)
		{
			// timer
			_timer = new Timer( 300 );
			_timer.addEventListener( TimerEvent.TIMER, closeDrop )

			// vars
			_w = w
			_h = h
			_backC = colorBack
			_items = itemArray
			_title = title
			_direction = direction
			_fmt = fmt

			// create a back for the holder
			var holder:MovieClip = new MovieClip();
			holder.name = "holder"
			holder.graphics.beginFill( _backC, 1 );
			holder.graphics.drawRoundRect( 0, 0, _w, _h, 2, 2 )
			holder.graphics.endFill()

			// add the drop
			addChild( holder )

			// set listeners
			holder.buttonMode = true;
			holder.addEventListener( MouseEvent.MOUSE_OVER, openDrop )
			holder.addEventListener( MouseEvent.MOUSE_OVER, cancelClose )
			holder.addEventListener( MouseEvent.MOUSE_OUT, startClose )

			// create a text field
			var t:TextField = new TextField()
			t.name = "holderText"
			t.selectable = false;
			t.mouseEnabled = false;
			t.autoSize = TextFieldAutoSize.LEFT;
			t.htmlText = title
			t.setTextFormat( fmt )
			t.embedFonts = useEmbeddedFonts;
			t.y = ( holder.height/2 ) - ( t.height/2 )

			_defaultText = t

			// add the text
			holder.addChild( t )

			// create children
			for( var i:uint=0; i<_items.length; i++ )
			{
				// create a back
				var back:MovieClip = new MovieClip()
				back.name = _items[i].name;
				back.graphics.beginFill( _backC, 1 )
				back.graphics.drawRoundRect( 0, 0, _w, _h, 10, 10 )
				back.graphics.endFill()

				// create a text field
				t = new TextField();
				t.name = "t"
				t.x = 5
				t.selectable = false;
				t.mouseEnabled = false;
				t.autoSize = TextFieldAutoSize.LEFT;
				t.htmlText = _items[i].title;
				t.setTextFormat( fmt )
				t.embedFonts = useEmbeddedFonts;
				t.y = ( back.height/2 ) - ( t.height/2 )

				if( _items[i].d )
				{
					_defaultText.htmlText = _title+" "+_items[i].title
					_defaultText.setTextFormat( _fmt )
				}

				// make them invisible for now
				back.visible = false;

				// set a listener
				back.buttonMode = true;
				back.addEventListener( MouseEvent.CLICK, closeDrop )
				back.addEventListener( MouseEvent.CLICK, setDefaultText )
				back.addEventListener( MouseEvent.CLICK, callback )
				back.addEventListener( MouseEvent.MOUSE_OUT, startClose )
				back.addEventListener( MouseEvent.MOUSE_OVER, cancelClose )

				// add the text
				back.addChild( t )

				// add it to the holder
				addChildAt( back, 0 )

				_items[i].mc = back
			}
		}

		private function openDrop( e:Event ):void
		{
			if( !_open )
			{

				for( var i:uint=0; i<_items.length; i++ )
				{
					// set a var
					var item:DisplayObject = _items[i].mc

					// set the items alpha to zero
					item.alpha = 0;

					// make the item visible
					item.visible = true

					// fade it in
					var tweenIn:GTween;

					if( _direction == "down" )
					{
						tweenIn = new GTween( item, .3, {y:_h + ( _h * i ),  alpha:1} )
					}
					else
					{
						tweenIn = new GTween( item, .3, {y:-_h - ( _h * i ),  alpha:1} )
					}
					tweenIn.ease = Regular.easeOut
				}
			}
			_open = true;

		}
		protected function cancelClose( e:Event ):void
		{
			if( e.currentTarget.name != "holder" )
			{
				e.currentTarget.alpha = .8
			}
			_timer.stop()
		}
		protected function startClose( e:Event ):void
		{
			e.currentTarget.alpha = 1
			_timer.start()
		}
		private function setDefaultText( e:Event ):void
		{
			_defaultText.htmlText = _title+" "+e.currentTarget.getChildByName( "t" ).text
			_defaultText.setTextFormat( _fmt )
		}
		private function closeDrop( e:Event ):void
		{
			closeIt()
		}
		private function closeIt():void
		{
			if( _open )
			{
				for( var i:uint=0; i<_items.length; i++ )
				{
					// set a var
					var item:DisplayObject = _items[i].mc

					// make the item visible
					item.visible = true

					// fade it in
					var tweenOut:GTween = new GTween( item, .3, {y:0, alpha:0}, {completeListener:done, data:item} )
					tweenOut.ease = Regular.easeOut
				}
			}

			_timer.stop()

			_open = false;
		}
		private function done( e:Event ):void
		{
			e.currentTarget.data.visible = false

		}
		
		public function selectOptionByIndex(index:uint):void
		{
			// Determine if an option at this index exists.
			var mc:DisplayObject = _items[index].mc as DisplayObject;
			if (mc == null) return;
			
			mc.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true));
		}
		
		public function selectOptionByName(name:String):void
		{
			// Determine if an option with this name exists.
			var mc:DisplayObject;
			var i:uint = 0;
			var len:uint = _items.length;
			for (i; i < len; i++)
			{
				var itemName:String = _items[i].name as String;
				if (itemName == name)
				{
					mc = _items[i].mc as DisplayObject;
					i = len;
				}
			}
			
			if (mc == null) return;
			
			mc.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true));
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get length():uint
		{
			return _items.length;
		}

	}
}