package com.sdg.view.fandamonium
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.sdg.view.StarAnimation;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	public class FandamoniumMeter extends FandamoniumMeterTemplate
	{
		private var _animManager:AnimationManager;
		private var _barContainer:Sprite;
		private var _barMask:Sprite;
		private var _bar1:Sprite;
		private var _bar2:Sprite;
		private var _fanScore1:int;
		private var _fanScore2:int;
		private var _meterPosition:Number;
		private var _meterSpike:Sprite;
		private var _team1Color1:uint;
		private var _team1Color2:uint;
		private var _team2Color1:uint;
		private var _team2Color2:uint;
		private var _starAnim1:StarAnimation;
		private var _starAnim2:StarAnimation;
		
		public function FandamoniumMeter()
		{
			super();
			
			// Default.
			_barContainer = new Sprite();
			_bar1 = new Sprite();
			_bar2 = new Sprite();
			_fanScore1 = 0;
			_fanScore2 = 0;
			_meterSpike = new Sprite();
			_meterPosition = 0.5;
			_team1Color1 = 0xff0000;
			_team1Color2 = 0xffffff;
			_team2Color1 = 0x0000ff;
			_team2Color2 = 0xffffff;
			_barMask = new Sprite();
			_animManager = new AnimationManager();
			_starAnim1 = new StarAnimation(10, 10);
			_starAnim2 = new StarAnimation(10, 10);
			
			// Add bars.
			addChild(_barContainer);
			addChild(_barMask);
			_barContainer.addChild(_bar1);
			_barContainer.addChild(_bar2);
			_barContainer.addChild(_starAnim1);
			_barContainer.addChild(_starAnim2);
			_barContainer.addChild(_meterSpike);
			_barContainer.mask = _barMask;
			
			// Give some filters to the bar.
			_barContainer.filters = [new GlowFilter(0x000000, 0.7, 12, 12, 2, 1, true)];
			
			// Draw meter spike.
			_meterSpike.graphics.beginFill(0xffffff);
			_meterSpike.graphics.lineTo(-5, meterArea.height);
			_meterSpike.graphics.lineTo(5, meterArea.height);
			_meterSpike.graphics.lineTo(0, 0);
			_meterSpike.filters = [new DropShadowFilter(1, 45, 0, 1, 5, 5)];
			
			// Initial render.
			render();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		private function render():void
		{
			// Set some reference points.
			var barHeight:Number = meterArea.height;
			var halfBarHeight:Number = barHeight / 2;
			var mX:Number = meterArea.x;
			var mY:Number = meterArea.y;
			var mBottom:Number = mY + barHeight;
			var mRight:Number = mX + meterArea.width;
			var spikeX:Number = mX + halfBarHeight + ((meterArea.width - barHeight) * _meterPosition);
			var color2Height:Number = 4;
			var color2HalfHeight:Number = color2Height / 2;
			
			// Bar mask.
			_barMask.graphics.clear();
			_barMask.graphics.beginFill(0xffffff);
			_barMask.graphics.moveTo(mX, mY + halfBarHeight);
			_barMask.graphics.curveTo(mX, mBottom, mX + halfBarHeight, mBottom);
			_barMask.graphics.lineTo(mRight - halfBarHeight, mBottom);
			_barMask.graphics.curveTo(mRight, mBottom, mRight, mY + halfBarHeight);
			_barMask.graphics.curveTo(mRight, mY, mRight - halfBarHeight, mY);
			_barMask.graphics.lineTo(mX + halfBarHeight, mY);
			_barMask.graphics.curveTo(mX, mY, mX, mY + halfBarHeight);
			
			_bar1.graphics.clear();
			_bar1.graphics.beginFill(_team1Color1);
			_bar1.graphics.drawRect(mX, mY, spikeX - mX, barHeight);
			//_bar1.graphics.beginFill(_team1Color2);
			//_bar1.graphics.drawRect(mX, mY + halfBarHeight - color2HalfHeight, spikeX - mX, color2Height);
			
			// Draw bar 2.
			_bar2.graphics.clear();
			_bar2.graphics.beginFill(_team2Color1);
			_bar2.graphics.drawRect(spikeX, mY, mRight - spikeX, barHeight);
			//_bar2.graphics.beginFill(_team2Color2);
			//_bar2.graphics.drawRect(spikeX, mY + halfBarHeight - color2HalfHeight, mRight - spikeX, color2Height);
			
			// Position meter spike.
			_meterSpike.x = spikeX;
			_meterSpike.y = mY;
			
			// Position star animation.
			_starAnim1.width = _starAnim2.width = meterArea.width;
			_starAnim1.height = _starAnim2.height = meterArea.height;
			_starAnim1.x = meterArea.x;
			_starAnim2.x = meterArea.x + meterArea.width;
			_starAnim1.y = _starAnim2.y = mY + halfBarHeight;
		}
		
		private function destroy():void
		{
			// Handle clean up.
			_animManager.dispose();
		}
		
		private function animateMeterSpike(meterPosition:Number):void
		{
			_animManager.property(this, 'meterPosition', meterPosition, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
		}
		
		public function setScore(team1:int, team2:int):void
		{
			// Animate numerical score.
			_animManager.property(this, 'fanScore1', team1, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			_animManager.property(this, 'fanScore2', team2, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			
			// Determine the increae from the previous scores for both teams.
			var increase1:Number = team1 - _fanScore1;
			var increase2:Number = team2 - _fanScore2;
			_fanScore1 = team1;
			_fanScore2 = team2;
			
			var total:Number = _fanScore1 + _fanScore2;
			var ratio:Number = (total != 0) ? _fanScore1 / total : 0.5;
			
			animateMeterSpike(ratio);
			
			var starCount:uint = 20;
			var starCountMax:uint = 50;
			if (increase1 > increase2)
			{
				starCount = Math.floor(Math.min(increase1 / 10, starCountMax));
				_starAnim1.animate(new Point(1, 0), starCount, 20, 8, meterArea.width * ratio);
			}
			else if (increase1 < increase2)
			{
				starCount = Math.floor(Math.min(increase2 / 10, starCountMax));
				_starAnim2.animate(new Point(-1, 0), starCount, 20, 8, meterArea.width * (1 - ratio));
			}
		}
		
		public function setTeamColors1(color1:uint, color2:uint):void
		{
			_team1Color1 = color1;
			_team1Color2 = color2;
			render();
		}
		
		public function setTeamColors2(color1:uint, color2:uint):void
		{
			_team2Color1 = color1;
			_team2Color2 = color2;
			render();
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get meterPosition():Number
		{
			return _meterPosition;
		}
		public function set meterPosition(value:Number):void
		{
			value = Math.min(value, 1);
			value = Math.max(value, 0);
			if (value == _meterPosition) return;
			_meterPosition = value;
			render();
		}
		
	}
}