package com.sdg.view.pda
{
	import com.sdg.control.PDAController;
	import com.sdg.view.pda.interfaces.IPDAMainPanel;
	import com.sdg.view.pda.interfaces.IPDAMainScreen;
	import com.sdg.view.pda.interfaces.IPDASidePanel;
	import com.sdg.view.pda.interfaces.IPDAView;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.effects.Move;
	import mx.effects.Rotate;
	import mx.events.EffectEvent;
	
	public class PDAView extends Canvas implements IPDAView
	{
		public static const OUTSIDE_CLICK:String = 'outside click';
		
		private var _pdaMainScreen:IPDAMainScreen;
		private var _pdaSidePanel:IPDASidePanel;
		private var _controller:PDAController;
		private var _lastSeenSidePanel:IPDASidePanel;
		private var _backing:Sprite;
		
		public function PDAView(controller:PDAController)
		{
			super();
			this.width = 925;
			this.height = 665;
			_controller = controller;
			
			// Create backing.
			// It will be invisible, used for recieving clicks.
			// If a user clicks outside of the PDA we will close the PDA.
			_backing = new Sprite();
			_backing.graphics.beginFill(0, 0.8);
			_backing.graphics.drawRect(0, 0, 925, 665);
			_backing.addEventListener(MouseEvent.CLICK, onBackingClick);
			rawChildren.addChild(_backing);
			
			_pdaMainScreen = new PDAMainScreen();
			rawChildren.addChild(_pdaMainScreen as DisplayObject);
			_pdaMainScreen.controller = _controller;
			_pdaMainScreen.x = this.width/2 - _pdaMainScreen.width/2;
			_pdaMainScreen.y = 25;
		}
		
		public function rotatePDA(rotateEndHandler:Function = null, angleFrom:Number = 0, angleTo:Number = 90, duration:Number = 100):void
		{
			//var bitmapDataBuffer:BitmapData = new BitmapData(_pdaMainScreen.width, _pdaMainScreen.height, false);
			//bitmapDataBuffer.draw(_pdaMainScreen);
			//var bitmap:Bitmap = new Bitmap(bitmapDataBuffer);
			//this.rawChildren.addChild(bitmap);
						
			var rotateEffect:Rotate = new Rotate(_pdaMainScreen);
			rotateEffect.angleTo = angleTo;
			rotateEffect.angleFrom = angleFrom;
			rotateEffect.duration = duration;
			rotateEffect.originX = _pdaMainScreen.width/2;
			rotateEffect.originY = _pdaMainScreen.height/2;
			
			if (rotateEndHandler != null)
				rotateEffect.addEventListener(EffectEvent.EFFECT_END, rotateEndHandler);
			
			rotateEffect.play();
		}
		
		private function animateScreen(screen:DisplayObject, xTo:Number, effectEndHandler:Function = null):void
		{
			var expandEffect:Move = new Move(screen);
			expandEffect.xTo = xTo;
			expandEffect.duration = 500;
			
			if (effectEndHandler != null)
				expandEffect.addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
			
			expandEffect.play();
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set mainPanel(panel:IPDAMainPanel):void
		{
			_pdaMainScreen.mainPanel = panel;
		}
		
		public function get mainPanel():IPDAMainPanel
		{
			return _pdaMainScreen.mainPanel;
		}
		
		public function set sidePanel(panel:IPDASidePanel):void
		{
			var mainScreenEndX:Number;
			
			// no side panels before
			if (_pdaSidePanel == null)
			{
				// yes side panels now - animate open panel
				if (panel != null)
				{
					setNewSidePanel(panel, _pdaMainScreen.x);
					mainScreenEndX = 925 / 2 - (_pdaMainScreen.width + _pdaSidePanel.width) / 2;
					//mainScreenEndX = 0;
					animateScreen(DisplayObject(_pdaMainScreen), mainScreenEndX);
					animateScreen(DisplayObject(_pdaSidePanel), mainScreenEndX + _pdaMainScreen.width);
				}
			}
			// yes side panels before
			else
			{
				// no side panels now - animate close panel
				if (panel == null)
				{
					mainScreenEndX = 925/2 - _pdaMainScreen.width/2;
					
					if (_lastSeenSidePanel == null)
					{
						animateScreen(DisplayObject(_pdaMainScreen), mainScreenEndX);
						animateScreen(DisplayObject(_pdaSidePanel), mainScreenEndX, onSidePanelClosed);
					}
					else
					{
						_pdaMainScreen.x = mainScreenEndX;
						removeSidePanel();
					}
				}
				// yes side panels now
				else
				{
					// if side panels same
					if (panel == _pdaSidePanel)
					{
						_pdaSidePanel.refresh();
					}
					// if side panels different - remove old side panel - add new side panel
					else
					{
						_pdaSidePanel.close();
						this.rawChildren.removeChild(DisplayObject(_pdaSidePanel));
						setNewSidePanel(panel, _pdaSidePanel.x);
					}
				}
			}
		}
		
		private function setNewSidePanel(panel:IPDASidePanel, startX:Number):void
		{
			_pdaSidePanel = panel;
			
			// pass controller to side panel
			_pdaSidePanel.controller = _controller;
			
			trace(_pdaSidePanel.y);
			this.rawChildren.addChildAt(DisplayObject(_pdaSidePanel), this.rawChildren.getChildIndex(DisplayObject(_pdaMainScreen)));
				
			_pdaSidePanel.x = startX;
			_pdaSidePanel.refresh();
		}
		
		private function removeSidePanel():void
		{
			if(_pdaSidePanel != null)
			{
				_pdaSidePanel.close();
				this.rawChildren.removeChild(DisplayObject(_pdaSidePanel));
				_pdaSidePanel = null;
				_lastSeenSidePanel = null;
			}
		}
		
		private function onSidePanelClosed(event:EffectEvent):void
		{
			event.currentTarget.removeEventListener(EffectEvent.EFFECT_END, onSidePanelClosed);
			removeSidePanel();
		}
		
		private function onPDAViewClosed(event:EffectEvent):void
		{
			event.currentTarget.removeEventListener(EffectEvent.EFFECT_END, onPDAViewClosed);
			super.visible = false;
			_lastSeenSidePanel = _pdaSidePanel;
		}
		
		public function get sidePanel():IPDASidePanel
		{
			return _pdaSidePanel;
		}
		
		public function get view():DisplayObject
		{
			return this;
		}
		
		public function get mainScreen():IPDAMainScreen
		{
			return _pdaMainScreen;
		}
		
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			
			_backing.alpha = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onBackingClick(e:MouseEvent):void
		{
			trace('\n\nCLICKED PDA VIEW BACKING\n\n');
			dispatchEvent(new Event(OUTSIDE_CLICK));
		}
		
	}
}