package com.sdg.display
{
	import com.adobe.utils.StringUtil;
	import com.sdg.net.Environment;
	import com.sdg.utils.Constants;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.*;

    public class ChatBubble extends Sprite
	{
		public static const EMOTE_FILTERS_NO_BUBBLE:Array = [new GlowFilter(0xffffff, 1, 3, 3, 8, 2), new DropShadowFilter(2, 45, 0, 0.4, 8, 8)];

		[Embed(source='images/chatBubble_bg.png')]
		private var chatBubble_bg:Class;

		[Embed(source='images/emote/emotBubble_bg.png')]
		private var emoteBubble_bg:Class;

		// 7/7/08 jma I did not have the GillSans font on my system
		// so the font defaulted to Times Roman  alpha

		[Embed(source="fonts/GIL.TTF", fontFamily="GillSans", embedAsCFF=false)] // Non-SDG - set embedAsCFF to false
		private var gillsans:Class;
		private var textField:TextField;
		private var icon:DisplayObject;
		private var bubble:Bitmap;
		private var m_failOverIcon:String;
		private var _positionEmote:Function;
		private var _isEmoteBubble:Boolean;
		private var _showBubbleTimer:Timer;
		private var _persistentEmote:DisplayObject;

		public function ChatBubble(isEmoteBubble:Boolean = false, positionEmote:Function = null, customBubble:Bitmap = null)
		{
			_positionEmote = positionEmote;
			_isEmoteBubble = isEmoteBubble;

			if (customBubble)
				bubble = customBubble;
			else
				bubble = isEmoteBubble ? new emoteBubble_bg() as Bitmap : new chatBubble_bg() as Bitmap;

			addChild(bubble);
			textField = new TextField();
			textField.embedFonts = true;
			textField.x = textField.y = 3;
			textField.wordWrap = true;
			textField.multiline = true;
			textField.selectable = false;
			textField.width = width - textField.x * 2;
			textField.height = height - textField.y * 2;
			addChild(textField);

			// hide bubble initially
			visible = false;

			// Create a timer used to hide the bubble after a specified amount of time.
			_showBubbleTimer = new Timer(Constants.CHATBUBBLE_TIMEOUT);
			_showBubbleTimer.addEventListener(TimerEvent.TIMER, onBubbleTimerInterval);
		}

		////////////////////
		// INSTANCE METHODS
		////////////////////

		public function destroy():void
		{
			// Kill bubble timer.
			_showBubbleTimer.reset();
			_showBubbleTimer.removeEventListener(TimerEvent.TIMER, onBubbleTimerInterval);
		}

		public function showText(text:String, offextY:int = 0):void
		{
			reset();

			textField.text = text;
			var format:TextFormat = new TextFormat()
			format.font = "GillSans";
			format.align = "center";
			textField.setTextFormat(format);

			// set the y position for vertical centering of the text
			switch (textField.numLines)
			{
				case 1:
					textField.y = 16;
					break;
				case 2:
					textField.y = 9;
					break;
				case 3:
					textField.y = 2;
					break;
				default:
					textField.y = 2;
					break;
			}

			textField.y += offextY;
		}

		/**
		 *  Shows an emote icon.
		 *
		 *  @param emotePath The path of the icon to show.
		 *
		 *  @param failOverIcon the path to a backup icon to show if emotePath fails to load.
		 */
		public function showIcon(emotePath:String, failOverIcon:String = null, useBubble:Boolean = true, iconWidth:Number = 35, iconHeight:Number = 36, applyFilters:Boolean = true, params:Object = null, makePersistent:Boolean = false):void
		{
			m_failOverIcon = failOverIcon;

			// Show or hide the bubble.
			bubble.visible = useBubble;

			// make sure we are using our own domain
			if (StringUtil.beginsWith(emotePath, "http"))
				emotePath = emotePath.replace(Environment.DOMAIN_REGEX, Environment.getApplicationUrl());

			// download the emote swf
			var request:URLRequest = new URLRequest(emotePath);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onIconDownloaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIconDownloadError);
   			loader.load(request);

			// Create a container for the emote.
			var emoteContainer:Sprite = new Sprite();
			emoteContainer.addChild(loader);

			// Should we make this emote persistent.
			// Always show it.
			if (makePersistent == true) _persistentEmote = emoteContainer;

			function onIconDownloaded(event:Event):void
			{
				// Remove event listeners.
				removeListeners();

				// get the original top and left margins
				var topMargin:Number = (loader.contentLoaderInfo.height - loader.height) / 2;
				var leftMargin:Number = (loader.contentLoaderInfo.width - loader.width) / 2;

				// save the orginal heights and width;
				var oldHeight:Number = loader.height;
				var oldWidth:Number = loader.width;

				// Scale the icon.
				var scale:Number = Math.min(iconWidth / loader.width, iconHeight / loader.height);
				loader.width *= scale;
				loader.height *= scale;

				// get the reduction ratios so we can get ajusted margin sizes
				var rRatioWidth:Number = loader.width / oldWidth;
				var rRatioHeight:Number = loader.height / oldHeight;

				// remove the left and top margins
				loader.x -= leftMargin * rRatioWidth;
				loader.y -= topMargin * rRatioHeight;

				// Stylize the icon.
				styleIcon();

				// set the emote location
				_positionEmote();

				// pass any params we have to the emote swf
				var swf:Object = Object(event.currentTarget.content);
				if (params)
					swf.params = params;

				// Show the emote.
				showImageInBubble(emoteContainer, useBubble);
			}

			function onIconDownloadError(event:Event):void
			{
				// Remove event listeners.
				removeListeners();

				if (m_failOverIcon != null && m_failOverIcon != '')
				{
					trace("onIconDownloadError: calling showIcon('" + m_failOverIcon + "')");
					showIcon(m_failOverIcon, null, useBubble, iconWidth, iconHeight);
				}
			}

			function removeListeners():void
			{
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onIconDownloaded);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIconDownloadError);
			}

			function styleIcon():void
			{
				if (!useBubble && applyFilters)
				{
					// Add some filters to the icon.
					// Give it a white stroke.
					loader.filters = EMOTE_FILTERS_NO_BUBBLE;
				}
			}
		}

		private function showImageInBubble(image:DisplayObject, useBubble:Boolean):void
		{
			reset();

			// Set new icon.
			icon = image;
			addChild(icon);

			// Position icon, based on whether or not we are using the bubble.
			if (useBubble == true)
			{
				// Center the icon.
				icon.x = (width / 2) - (icon.width / 2);
   				icon.y = (height / 2) - (icon.height / 2) - 6;
			}
			else
			{
				// Position the icon just above the avatar.
				icon.x = (width / 2) - (icon.width / 2);
				icon.y = height - icon.height - 2;
			}
		}

		public function show():void
		{
			visible = true;

			// Restart the bubble timer.
			_showBubbleTimer.reset();
			_showBubbleTimer.start();
		}

		public function hide():void
		{
			visible = false;

			// if we closed the chat bubble reposition the emote
			if (!_isEmoteBubble && _positionEmote != null)
				_positionEmote();

			// Reset the bubble timer.
			_showBubbleTimer.reset();

			// If a persistent emote exists, show it continuously.
			if (_persistentEmote != null) showImageInBubble(_persistentEmote, false);
		}

		protected function reset():void
		{
			if (icon && contains(icon)) removeChild(icon);
			textField.text = "";
			show();
		}

		public function removePersistentEmote():void
		{
			_persistentEmote = null;
			hide();
		}

		////////////////////
		// EVENT HANDLERS
		////////////////////

		private function onBubbleTimerInterval(e:TimerEvent):void
		{
			// When the bubble timer hits it's interval,
			// Hide the bubble.
			hide();
		}

    }
}
