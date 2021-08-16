package com.sdg.components.controls
{
	import com.teso.ui.DropDown;
	
	import flash.events.Event;
	import flash.text.TextFormat;

	public class TurfDropDown extends DropDown
	{
		public function TurfDropDown(w:Number, h:Number, title:String, fmt:TextFormat, colorBack:uint, colorOver:uint, itemArray:Array, direction:String, callback:Function, useEmbeddedFonts:Boolean=false)
		{
			super(w, h, title, fmt, colorBack, itemArray, direction, callback, useEmbeddedFonts);
			_overC = colorOver;
		}
		
		override protected function cancelClose( e:Event ):void
		{
			if( e.currentTarget.name != "holder" )
			{
				e.currentTarget.graphics.clear();
				e.currentTarget.graphics.beginFill( _overC, 1 );
				e.currentTarget.graphics.drawRoundRect( 0, 0, _w, _h, 2, 2 )
				e.currentTarget.graphics.endFill()
			}
			_timer.stop()
		}
		
		override protected function startClose( e:Event ):void
		{
			e.currentTarget.graphics.clear();
			e.currentTarget.graphics.beginFill( _backC, 1 );
			e.currentTarget.graphics.drawRoundRect( 0, 0, _w, _h, 2, 2 )
			e.currentTarget.graphics.endFill()
			_timer.start()
		}
		
	}
}