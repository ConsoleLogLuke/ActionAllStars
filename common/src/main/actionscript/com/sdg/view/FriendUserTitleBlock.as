package com.sdg.view
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.net.QuickLoader;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class FriendUserTitleBlock extends UserTitleBlock
	{
		protected var _presenceCircle:Sprite;
		protected var _presenceTextField:TextField;
		protected var _levelIndicator:DisplayObject;
		protected var _arrow:Sprite;
		protected var _roomId:String;

		public function FriendUserTitleBlock(id:uint, name:String, level:uint, teamId:uint, teamName:String, color1:uint, color2:uint, width:Number=287, height:Number=54, autoInit:Boolean=true)
		{
			_levelIndicator = new QuickLoader("swfs/buddy/rank_" + level + ".swf");

			_arrow = new Sprite();
			_arrow.visible = false;

			var request:URLRequest = new URLRequest('swfs/buddy/arrowJump.swf');
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.load(request);

			_presenceCircle = new Sprite();
			_presenceTextField = new TextField();
			_presenceTextField.defaultTextFormat = new TextFormat('EuroStyle', 11, 0xffffff, true);
			_presenceTextField.embedFonts = true;
			_presenceTextField.autoSize = TextFieldAutoSize.LEFT;
			_presenceTextField.selectable = false;
			_presenceTextField.mouseEnabled = false;

			super(id, name, level, teamId, teamName, color1, color2, width, height, autoInit);

			addChild(_presenceCircle);
			addChild(_presenceTextField);
			addChild(_levelIndicator);
			addChild(_arrow);

			function onLoadComplete(event:Event):void
			{
				loader.contentLoaderInfo.removeEventListener(Event.INIT, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

				var arrowContent:DisplayObject = loader.content;
				var scale:Number = Math.min(16/arrowContent.width, 16/arrowContent.height);
				arrowContent.scaleX = arrowContent.scaleY = scale;

				_arrow.addChild(arrowContent);
				_arrow.buttonMode = true;
				_arrow.addEventListener(MouseEvent.CLICK, onMouseClick);
			}

			function onLoadError(event:Event):void
			{
				loader.contentLoaderInfo.removeEventListener(Event.INIT, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			}

			function onMouseClick(event:MouseEvent):void
			{
				RoomManager.getInstance().teleportToRoom(_roomId);
			}
		}

		override protected function render():void
		{
			super.render();

			_nameField.y = 0;

			_levelIndicator.x = _nameField.x + 3;
			_levelIndicator.y = _nameField.y + _nameField.height - 1;

			_presenceCircle.x = _nameField.x;
			_presenceCircle.y = _nameField.y + _nameField.height + 17;

			_presenceTextField.x = _nameField.x + 10;
			_presenceTextField.y = _nameField.y + _nameField.height + 12;

			_arrow.y = _nameField.y + _nameField.height + 8;
		}

		public function setPresence(presence:int, roomId:String = null, locDesc:String = null):void
		{
			var presenceColor:uint;

			_presenceCircle.graphics.clear();

			if (presence == 1)
			{
				presenceColor = 0x00ff00;
				_presenceTextField.text = "Online" + (locDesc != null ? ":  " + locDesc : "");
				_arrow.visible = true;

				_arrow.x = _presenceTextField.x + _presenceTextField.width;
			}
			else
			{
				presenceColor = 0xaaaaaa;
				_presenceTextField.text = "Offline";
				_arrow.visible = false;
			}

			_roomId = roomId;

			_presenceCircle.graphics.beginFill(presenceColor);
			_presenceCircle.graphics.drawCircle(4, 4, 4);


		}
	}
}
