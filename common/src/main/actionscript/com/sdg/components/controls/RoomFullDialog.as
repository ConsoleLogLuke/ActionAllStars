package com.sdg.components.controls
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.net.QuickLoader;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class RoomFullDialog extends SdgAlertChrome
	{
		private static const BUTTON_WIDTH:Number = 395;
		private static const BUTTON_HEIGHT:Number = 26;

		private static const BROADCAST_CENTER:Object = {roomName:"Broadcast Center", roomId:"public_129"};
		private static const BLAKES_PLACE:Object = {roomName:"Blake's Place", roomId:"public_142"};
		private static const AAS_STORE:Object = {roomName:"Action AllStars Store", roomId:"public_105"};
		private static const JOE_BOSE_PARK:Object = {roomName:"Joe Bose Park", roomId:"public_103"};

		private static const NFL_PLAYERS_LOCKER:Object = {roomName:"NFL Player's Locker", roomId:"public_144"};

		private static const PET_ZONE:Object = {roomName:"Pet Zone", roomId:"public_154"};
		private static const MLB_STORE:Object = {roomName:"MLB Store", roomId:"public_113"};

		private static const BUNNY_HILL:Object = {roomName:"Bunny Hill", roomId:"public_156"};
		private static const VERT_VILLAGE:Object = {roomName:"Vert Village", roomId:"public_114"};
		private static const BALLERS_PLAZA:Object = {roomName:"Baller's Plaza", roomId:"public_109"};
		private static const NBA_STORE:Object = {roomName:"NBA Store", roomId:"public_108"};

		private static const VERT_VILLAGE_STORE:Object = {roomName:"Vert Village Store", roomId:"public_116"};
		private static const MAVERICKS:Object = {roomName:"Maverick's", roomId:"public_119"};
		private static const BEACHSIDE:Object = {roomName:"Beachside", roomId:"public_118"};

		private static const detourMap:Object = {	"public_101":[BROADCAST_CENTER, BLAKES_PLACE, AAS_STORE, JOE_BOSE_PARK],
													"public_121":[NFL_PLAYERS_LOCKER, JOE_BOSE_PARK],
													"public_103":[PET_ZONE],
													"public_110":[MLB_STORE],
													"public_117":[BUNNY_HILL, VERT_VILLAGE],
													"public_107":[BALLERS_PLAZA, NBA_STORE],
													"public_114":[VERT_VILLAGE_STORE, MAVERICKS, BEACHSIDE]
												};

		protected var _detourButtons:Array;
		protected var _closeButton:DisplayObject;

		public function RoomFullDialog(pendingRoomId:String):void
		{
			var detourRooms:Object = detourMap[pendingRoomId];

			var hasOkButton:Boolean;
			var message:String;
			var title:String;
			var dialogHeight:Number;
			var isMessageCentered:Boolean;

			if (detourRooms == null)
			{
				hasOkButton = true;
				message = "Oops! This room is full. You may want to try another server!";
				title = "Room Full";
				dialogHeight = 200;
				isMessageCentered = true;
			}
			else
			{
				var button:DisplayObject;
				var index:int;

				for each (var roomObject:Object in detourRooms)
				{
					button = createDetourButton(roomObject);
					button.x = 430/2 - BUTTON_WIDTH/2;
					button.y = 114 + ((BUTTON_HEIGHT + 6) * index);
					index++;
				}
				hasOkButton = false;
				message = "...but you can pick one right next door:";
				title = "This room is full!";
				dialogHeight = 153 + (index * 32);
				isMessageCentered = false;

				_closeButton = new QuickLoader("swfs/alert/closeButton.swf", onCloseButtonComplete);
			}

			super(message, title, hasOkButton, 430, dialogHeight, null, "swfs/alert/popup_detour.swf");

			if (isMessageCentered == false)
				_messageTF.y = 70;


			function onCloseButtonComplete():void
			{
				_closeButton = QuickLoader(_closeButton).content;
				_closeButton.scaleX = _closeButton.scaleY = .7;
				addChild(_closeButton);
				Sprite(_closeButton).buttonMode = true;
				_closeButton.addEventListener(MouseEvent.CLICK, onCloseClick, false, 0, true);
				_closeButton.x = 430 - _closeButton.width - 15;
				_closeButton.y = 15;
			}
		}

		private function onCloseClick(event:MouseEvent):void
		{
			close();
		}

		private function createDetourButton(roomObject:Object):DisplayObject
		{
			var button:Sprite = new Sprite();

			var tf:TextField = new TextField();
			tf.embedFonts = true;
			tf.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.selectable = false;
			tf.text = roomObject.roomName;
			tf.filters = [new GlowFilter(0x000000, 1, 5, 5, 10)];

			button.addChild(tf);
			addChild(button);
			button.buttonMode = true;
			button.mouseChildren = false;

			setHighlight(false);
			tf.x = BUTTON_WIDTH/2 - tf.width/2;
			tf.y = BUTTON_HEIGHT/2 - tf.height/2;

			if (_detourButtons == null) _detourButtons = new Array();
			_detourButtons.push(button);

			button.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			button.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			button.addEventListener(MouseEvent.CLICK, onClick);

			return button;

			function onMouseOver(event:MouseEvent):void
			{
				setHighlight(true);
			}

			function onMouseOut(event:MouseEvent):void
			{
				setHighlight(false);
			}

			function onClick(event:MouseEvent):void
			{
				CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomObject.roomId));
				close();
			}

			function setHighlight(value:Boolean):void
			{
				var textColor:uint = 0xffffff;
				var buttonAlpha:Number = 0;

				button.graphics.clear();
				button.graphics.lineStyle(2, 0xcfcfcf, .25);

				if (value == true)
				{
					textColor = 0xfdc000;
					buttonAlpha = .25;
				}

				button.graphics.beginFill(0xcfcfcf, buttonAlpha);
				button.graphics.drawRoundRect(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT, 30, 30);
				tf.textColor = textColor;
			}
		}

		/**
		 * Static show method.
		 */
		public static function show(pendingRoomId:String, closeHandler:Function = null):RoomFullDialog
		{
			var dialog:RoomFullDialog = new RoomFullDialog(pendingRoomId);

			dialog.show(closeHandler);
			return dialog;
		}

		override public function close(closeDetail:int = -1):void
		{
			var button:DisplayObject;
			if (_detourButtons != null)
			{
				for each (button in _detourButtons)
				{
					button.removeEventListener(MouseEvent.CLICK, arguments.callee);
					button.removeEventListener(MouseEvent.MOUSE_OVER, arguments.callee);
					button.removeEventListener(MouseEvent.MOUSE_OUT, arguments.callee);
				}
				_detourButtons = null;
			}

			if (_closeButton != null)
				_closeButton.removeEventListener(MouseEvent.CLICK, onCloseClick);

			super.close(closeDetail);
		}
	}
}
