package com.sdg.view.avatarcard
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
		
	public class AvatarInfoSidePanel extends AvatarInfoPanel
	{
		public function AvatarInfoSidePanel(width:Number, height:Number)
		{
			super(width, height);
		}
		
		override protected function renderBacking():void
		{
			// Draw back.
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			_back.graphics.clear();
			_back.graphics.beginGradientFill(GradientType.LINEAR, [0x6890b8, 0x213377], [1, 1], [1, 255], gradMatrix);
			_back.graphics.lineTo(_width - _cornerSize, 0);
			_back.graphics.curveTo(_width, 0, _width, _cornerSize);
			_back.graphics.lineTo(_width, _height - _cornerSize);
			_back.graphics.curveTo(_width, _height, _width - _cornerSize, _height);
			_back.graphics.lineTo(0, _height);
		}
		
	}
}