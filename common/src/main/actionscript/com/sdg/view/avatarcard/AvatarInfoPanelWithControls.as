package com.sdg.view.avatarcard
{
	import com.sdg.audio.EmbeddedAudio;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	
	public class AvatarInfoPanelWithControls extends AvatarInfoPanel
	{
		private static const _ActionButtonStrokeFilter:GlowFilter = new GlowFilter(0xffffff, 1, 4, 4, 10);
		
		private var _actionButtons:Array;
		private var _clickEvents:Array;
		private var _clickLabels:Array;
		private var _actionButtonsContainer:Sprite;
		private var _overSound:Sound;
		private var _openSound:Sound;
		private var _isIgnored:Boolean;
		private var _isFriend:Boolean;
		private var _allowGoTo:Boolean;
		
		public function AvatarInfoPanelWithControls(isFriend:Boolean, isIgnored:Boolean, allowGoTo:Boolean, width:Number, height:Number)
		{
			_actionButtons = [];
			_clickEvents = [];
			_clickLabels = [];
			_actionButtonsContainer = new Sprite();
			_overSound = new EmbeddedAudio.OverSound();
			_openSound = new EmbeddedAudio.OpenSound();
			_isIgnored = isIgnored;
			_isFriend = isFriend;
			_allowGoTo = allowGoTo;
			
			// Action buttons.
			setupActionButtons();
			
			super(width, height);
			
			addChild(_actionButtonsContainer);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		override public function destroy():void
		{
			// Handle cleanup.
			
			// Remove children.
			removeChild(_actionButtonsContainer);
			
			// Remove event listeners.
			var i:int = 0;
			var len:int = _actionButtons.length;
			for (i; i < len; i++)
			{
				var btn:DisplayObject = _actionButtons[i];
				btn.removeEventListener(MouseEvent.ROLL_OVER, onActionButtonOver);
				btn.removeEventListener(MouseEvent.ROLL_OUT, onActionButtonRollOut);
				btn.removeEventListener(MouseEvent.MOUSE_DOWN, onActionButtonMouseDown);
			}
			
			// Remove references.
			_actionButtons = null;
			_clickEvents = null;
			_clickLabels = null;
			_actionButtonsContainer = null;
			_overSound = null;
			_openSound = null;
			
			super.destroy();
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			// Action buttons.
			renderActionButtons();
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function addActionButton(btn:Sprite, clickEvent:String, clickLabel:String):void
		{
			var btnRect:Rectangle = btn.getRect(btn);
			var btnContainer:Sprite = new Sprite();
			btn.x = -btnRect.x;
			btn.y = -btnRect.y;
			btnContainer.addChild(btn);
			btn = btnContainer;
			
			btn.addEventListener(MouseEvent.ROLL_OVER, onActionButtonOver);
			btn.addEventListener(MouseEvent.ROLL_OUT, onActionButtonRollOut);
			btn.addEventListener(MouseEvent.MOUSE_DOWN, onActionButtonMouseDown);
			
			btn.buttonMode = true;
			_actionButtonsContainer.addChild(btn);
			_actionButtons.push(btn);
			_clickEvents.push(clickEvent);
			_clickLabels.push(clickLabel);
		}
		
		private function renderActionButtons():void
		{
			var i:int = 0;
			var len:int = _actionButtons.length;
			var lastBtnRight:Number = 0;
			for (i; i < len; i++)
			{
				var btn:Sprite = _actionButtons[i];
				btn.x = lastBtnRight;
				lastBtnRight = btn.x + btn.width;
			}
			
			_actionButtonsContainer.x = _width / 2 - _actionButtonsContainer.width / 2;
			_actionButtonsContainer.y = _height - _actionButtonsContainer.height * 0.7;
		}
		
		private function setupActionButtons():void
		{
			removeActionButtons();
			
			if (_isIgnored)
			{
				var unIgnore:Sprite = new CircleIconUnignore();
				addActionButton(unIgnore, 'unignore', 'Unignore');
			}
			else
			{
				if (_allowGoTo)
				{
					var goToBtn:Sprite = new CircleIconJoin();
					addActionButton(goToBtn, 'go to', 'Go To');
				}
				
				var visitTurfBtn:Sprite = new CircleIconHome();
				addActionButton(visitTurfBtn, 'visit turf', 'Visit Turf');
				
				if (_isFriend)
				{
					var unFriendBtn:Sprite = new CircleIconUnfriend();
					addActionButton(unFriendBtn, 'unfriend', 'Unfriend');
				}
				else
				{
					var friendBtn:Sprite = new CircleIconFriend();
					addActionButton(friendBtn, 'friend', 'Add Friend');
				}
				
				var ignoreBtn:Sprite = new CircleIconIgnore();
				addActionButton(ignoreBtn, 'ignore', 'Ignore');
			}
			
			// Render action buttons.
			renderActionButtons();
		}
		
		private function removeActionButtons():void
		{
			// Remove all action buttons.
			var i:int = 0;
			var len:int = _actionButtons.length;
			if (!len) return;
			for (i; i < len; i++)
			{
				// Remove event listeners.
				var btn:DisplayObject = _actionButtons[i];
				btn.removeEventListener(MouseEvent.ROLL_OVER, onActionButtonOver);
				btn.removeEventListener(MouseEvent.ROLL_OUT, onActionButtonRollOut);
				btn.removeEventListener(MouseEvent.MOUSE_DOWN, onActionButtonMouseDown);
				
				// Remove from display.
				_actionButtonsContainer.removeChild(btn);
			}
			
			// Empty action buttons arrays.
			_actionButtons = [];
			_clickEvents = [];
			_clickLabels = [];
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set isIgnored(value:Boolean):void
		{
			if (value == _isIgnored) return;
			_isIgnored = value;
			setupActionButtons();
		}
		
		public function set allowGoTo(value:Boolean):void
		{
			if (value == _allowGoTo) return;
			_allowGoTo = value;
			setupActionButtons();
		}
		
		public function set isFriend(value:Boolean):void
		{
			if (value == _isFriend) return;
			_isFriend = value;
			setupActionButtons();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onActionButtonOver(e:MouseEvent):void
		{
			var btn:DisplayObject = e.currentTarget as DisplayObject;
			var index:int = _actionButtons.indexOf(btn);
			var clickLabel:String = _clickLabels[index];
			
			btn.filters = [_ActionButtonStrokeFilter];
			setActionLabel(clickLabel);
			
			// Play over sound.
			_overSound.play();
		}
		
		private function onActionButtonRollOut(e:MouseEvent):void
		{
			var btn:DisplayObject = e.currentTarget as DisplayObject;
			
			btn.filters = [];
			_actionBtnField.text = '';
		}
		
		private function onActionButtonMouseDown(e:MouseEvent):void
		{
			var btn:DisplayObject = e.currentTarget as DisplayObject;
			var index:int = _actionButtons.indexOf(btn);
			var clickEvent:String = _clickEvents[index];
			
			// PLay open sound.
			_openSound.play();
			
			dispatchEvent(new Event(clickEvent));
		}
		
	}
}