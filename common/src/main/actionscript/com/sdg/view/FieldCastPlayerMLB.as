package com.sdg.view
{
	import com.sdg.view.fandamonium.PlayerNameTag;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class FieldCastPlayerMLB extends Sprite
	{
		private var _color1:uint;
		private var _color2:uint;
		private var _name:String;
		private var _number:uint;
		private var _isNameOnLeft:Boolean;
		private var _floorMarker:Sprite;
		private var _helmet:FandemoniumPlayerHelmet;
		private var _nameTag:PlayerNameTag;
		private var _glow:Sprite;
		private var _glowMatrix:Matrix;
		
		public function FieldCastPlayerMLB(color1:uint = 0xff0000, color2:uint = 0x0000ff, name:String = 'Player Name', number:uint = 0)
		{
			super();
			
			_color1 = color1;
			_color2 = color2;
			_name = name;
			_number = number;
			_isNameOnLeft = true;
			
			// Create floor marker.
			_floorMarker = new Sprite();
			_floorMarker.graphics.lineStyle(1, 0xFF9900);
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(28, 12, 0, -14, -6);
			_floorMarker.graphics.beginGradientFill(GradientType.RADIAL, [0xFFFC03, 0xFFAE15], [1, 1], [1, 255], gradMatrix);
			_floorMarker.graphics.drawEllipse(-14, -6, 28, 12);
			_floorMarker.filters = [new DropShadowFilter(2, 45, 0, 0.8)];
			addChild(_floorMarker);
			
			// Create glow.
			_glow = new Sprite();
			_glowMatrix = new Matrix();
			addChild(_glow);
			
			// Create helmet.
			_helmet = new FandemoniumPlayerHelmet();
			_helmet.color1 = _color1;
			_helmet.color2 = _color2;
			_helmet.x = -_helmet.width / 2;
			_helmet.y = -90;
			addChild(_helmet);
			
			_nameTag = new PlayerNameTag(_name, _number, _color1, _color2);
			addChild(_nameTag);
			
			render();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		private function render():void
		{
			var helmetBounds:Rectangle = _helmet.getBounds(this);
			
			// Position name.
			if (_isNameOnLeft == true)
			{
				_nameTag.x = helmetBounds.x - _nameTag.width - 10;
			}
			else
			{
				_nameTag.x = helmetBounds.right + 10;
			}
			_nameTag.y = helmetBounds.y + helmetBounds.height / 2 - _nameTag.height / 2;
			
			// Draw glow.
			var glowH:Number = -helmetBounds.y + helmetBounds.height / 2;
			_glowMatrix.createGradientBox(helmetBounds.width - 20, glowH, -Math.PI / 2, 0, -glowH);
			_glow.graphics.clear();
			_glow.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff], [1, 0], [1, 220], _glowMatrix);
			_glow.graphics.lineTo(helmetBounds.x + 10, helmetBounds.y + helmetBounds.height / 2);
			_glow.graphics.lineTo(helmetBounds.right - 10, helmetBounds.y + helmetBounds.height / 2);
			_glow.graphics.lineTo(0, 0);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get isNameOnLeft():Boolean
		{
			return _isNameOnLeft;
		}
		public function set isNameOnLeft(value:Boolean):void
		{
			if (value == _isNameOnLeft) return;
			_isNameOnLeft = value;
			render();
		}
		
	}
}