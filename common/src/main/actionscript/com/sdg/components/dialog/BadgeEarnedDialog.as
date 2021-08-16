package com.sdg.components.dialog
{
	import com.sdg.business.resource.RemoteResourceMap;
	import com.sdg.business.resource.SdgResourceLocator;
	import com.sdg.components.controls.BadgeShield;
	import com.sdg.components.controls.store.StoreNavBar;
	import com.sdg.control.BuddyManager;
	import com.sdg.display.LineStyle;
	import com.sdg.graphics.GradientStyle;
	import com.sdg.graphics.RoundRectStyle;
	import com.sdg.manager.BadgeManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.Badge;
	import com.sdg.model.BadgeLevel;
	import com.sdg.model.BadgeRewardMessage;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Reward;
	import com.sdg.model.RewardCollection;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.MainUtil;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;

	public class BadgeEarnedDialog extends Canvas implements ISdgDialog
	{
		protected var _manager:BadgeManager;
			
		// Imported Data
		private var _badgeId:int;
		private var _badgeLevelId:int;
				
		// Main Components
		private var _loader:Loader;
		private var _swf:DisplayObject;
		private var _itemReward:Reward;
		private var _giftLoader:Loader;
		private var _giftBox:DisplayObject;
		private var _background:Sprite;
		private var _border:Sprite;
		private var _headerText1:TextField;
		private var _headerText2:TextField;
		private var _badgeShield:BadgeShield;
		private var _initMovie:DisplayObject;
		private var loaderTest:Loader;
		private var _clickMsg:TextField;
		
		// Badge Data
		private var _currentBadgeLevel:BadgeLevel;
		private var _currentBadge:Badge;
		
		private var _useMovie:Boolean = false;

		private var _multiLevelBadge:Boolean       ;
		
		private var _badgeRewards:RewardCollection;

		//private var _interactive:;
		private var _tellButton:StoreNavBar;
		private var _closeButton:StoreNavBar;
		
		protected var _avatar:Avatar = ModelLocator.getInstance().avatar;

		public function BadgeEarnedDialog()
		{
			super();
			
			this.x = 50;
			this.y = 50;
			this.width = 620;
			this.height = 500;
			
		}
		
		public function init(params:Object):void
		{
			_useMovie = params.useMovie as Boolean;
			_currentBadge =  params.badge as Badge;
			_currentBadgeLevel = params.badgeLevel as BadgeLevel;
			
			if (_useMovie)
			{
				// Load Rank Movie
				_initMovie = new QuickLoader(Environment.getAssetUrl()+"/test/gameSwf/gameId/71/gameFile/badgeMovie_"+_currentBadgeLevel.id+".swf", onMovieComplete,onMovieError,3);
			}
			else
			{
				showBadgeDialog();
			}
		}
		
		private function onMovieComplete():void
		{
			var movieTimer:Timer = new Timer(7000,0);
			movieTimer.addEventListener(TimerEvent.TIMER, closeMovie);
			movieTimer.start()
			_initMovie.x = 0;
			_initMovie.y = 0;
			rawChildren.addChild(_initMovie);
		}
		
		private function onMovieError():void
		{
			showBadgeDialog();
		}
		
		private function closeMovie(te:TimerEvent):void
		{
			var timer:Timer = te.currentTarget as Timer;
			timer.removeEventListener(TimerEvent.TIMER, closeMovie);
			timer.stop();
			this.removeChild(_initMovie);
			showBadgeDialog();
		}
		
		private function showBadgeDialog():void
		{
			// Set Border
			_border = new Sprite();
			this.rawChildren.addChild(_border);
			
			var gradientBoxMatrix:Matrix = new Matrix();

			gradientBoxMatrix.createGradientBox(620, 500, Math.PI/2);
			_border.graphics.beginGradientFill(GradientType.LINEAR, [0x666666, 0xffffff, 0x666666], [1, 1, 1], [0, 128, 255], gradientBoxMatrix);
			_border.graphics.drawRect(0, 0, 620, 500);
			_border.graphics.endFill();
				
			// Set Background
			_background = new Sprite();
			this.rawChildren.addChild(_background);
			
			gradientBoxMatrix.createGradientBox(width-16, height-16, Math.PI/2);
			_background.graphics.beginGradientFill(GradientType.LINEAR, [0x063040, 0x0e526c], [1, 1], [0, 255], gradientBoxMatrix);
			
			_background.graphics.drawRect(0, 0, width-16, height-16);
			_background.graphics.endFill();
			_background.x = _border.width/2 - _background.width/2;
			_background.y = _border.height/2 - _background.height/2;
			_background.filters = [new GlowFilter(0x222222, 1, 11, 11, 2, 1, true)];
			
			// Place Buttons
			//_tellButton = buildButton(80,425,235,"TELL YOUR FRIENDS","TELL YOUR FRIENDS","onMessageButtonClick");
			_closeButton = buildButton(245,425,156,"CONTINUE","CLOSING...","onCloseButtonClick");
				
			//Header Text
			_headerText1 = new TextField();
			this.rawChildren.addChild(_headerText1);
			_headerText1.embedFonts = true;
			_headerText1.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xffffff, true);
			_headerText1.autoSize = TextFieldAutoSize.CENTER;
			_headerText1.selectable = false;
			//_headerText1.multiline = true;
			//_headerText1.wordWrap = true;
			_headerText1.text = "Congratulations!" 
			_headerText1.x = 100;
			_headerText1.y = 20;
			_headerText1.width = 450;
			
			_headerText2 = new TextField();
			this.rawChildren.addChild(_headerText2);
			_headerText2.embedFonts = true;
			_headerText2.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xffffff, true);
			_headerText2.autoSize = TextFieldAutoSize.CENTER;
			_headerText2.selectable = false;
			//_headerText2.multiline = true;
			//_headerText2.wordWrap = true;
			_headerText2.text = "You've earned a badge.";
			_headerText2.x = 100;
			_headerText2.y = 50;
			_headerText2.width = 450;
			
			// Click Here Msg
			_clickMsg = new TextField();
			_clickMsg.embedFonts = true;
			_clickMsg.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			_clickMsg.autoSize = TextFieldAutoSize.CENTER;
			_clickMsg.selectable = false;
			_clickMsg.text = "Click Here";
			_clickMsg.x = 480;
			_clickMsg.y = 355;
			//_clickMsg.width = 450;
			
			//(Data for SWF)
			_badgeShield = new BadgeShield();
			_badgeShield.badgeWidth = 147;
			_badgeShield.badgeHeight = 190;
			_badgeShield.level = _currentBadgeLevel.levelIndex - 1;
			_badgeShield.badgeId = _currentBadge.id;
			
			// Wait Until We Have The Shield Loaded Before We Continue
			_badgeShield.addEventListener("badge_completed",onShieldReady);
		}
		
		private function onShieldReady(e:Event):void
		{	
			// Remove Listener
			_badgeShield.removeEventListener("badge_completed",onShieldReady);
			
			// Badge Type
			_multiLevelBadge  = _currentBadge.hasMultipleLevels();
			
			// Get Item Reward if One
			_badgeRewards = _currentBadgeLevel.rewards;
			_itemReward = _badgeRewards.getRewardByType(3);
			
			if (_itemReward)
			{
				loadGiftIcon();
			}
			else
			{
				loadMainSwf();
			}
		}
		
		private function loadGiftIcon():void
		{
			_giftBox = new QuickLoader(Environment.getAssetUrl()+"/test/gameSwf/gameId/71/gameFile/gift_animation.swf",onGiftInit,null,3);

			function onGiftInit():void
			{
				try
				{
					_giftBox.addEventListener(MouseEvent.CLICK, onGiftClick);
					_giftBox.x = 474;
					_giftBox.y = 288;
				}
				catch(e:Error)
				{
					trace("Badge Earned Dialog error: " + e.message);
				}
				
				loadMainSwf();
				
				function onGiftClick(e:Event):void
				{
					showBadgeRewardDialog();
				}
			}
		}
			
		private function loadMainSwf():void
		{
			// Badge Title (Sub-Category)
			var badgeName:String = _currentBadge.name;

			// Badge Level (1-5)
			var level:int = _currentBadgeLevel.levelIndex;
			
			// Badge Description
			var description:String = _currentBadgeLevel.name;
			
			// Badge Trigger
			var trigger:String = _currentBadgeLevel.description
			
			// Load SWF and Execute Functions
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			var tokenReward:Reward = _badgeRewards.getRewardByType(1);
			var xpReward:Reward = _badgeRewards.getRewardByType(2);
			
			var xp:uint = 0;
			var token:uint = 0;
			if (xpReward)
			{
				xp = xpReward.rewardValue;
			}
				
			if (tokenReward)
			{
				token = tokenReward.rewardValue;
			}
			
			var hasReward:Boolean = false;
			if (_itemReward)
				hasReward = true;
			
			if (_multiLevelBadge)
			{
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {onSwfInit(event,true,hasReward,badgeName,description,level,trigger,_badgeShield,xp,token)});
				_loader.load(new URLRequest(Environment.getAssetUrl()+"/test/gameSwf/gameId/71/gameFile/BadgeAwardPanel.swf"));
			}
			else
			{
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {onSwfInit(event,false,hasReward,badgeName,description,level,trigger,_badgeShield,xp,token)});
				_loader.load(new URLRequest(Environment.getAssetUrl()+"/test/gameSwf/gameId/71/gameFile/BadgeAwardPanel_single.swf"));
			}
			
			function onIOError(event:Event):void
			{
				event.currentTarget.removeEventListener(Event.COMPLETE, arguments.callee);
				event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}

			function onSwfInit(event:Event,multiLevel:Boolean,hasReward:Boolean,x1:String,x2:String,x3:int,x4:String,x5:DisplayObject,x6:uint,x7:uint):void
			{
				event.currentTarget.removeEventListener(Event.COMPLETE, arguments.callee);
				event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
				try
				{
					_swf = DisplayObject(_loader.content);
					_swf.x = 70;
					_swf.y = 100;
					rawChildren.addChild(_swf);
					if (hasReward)
					{
						rawChildren.addChild(_giftBox);
						rawChildren.addChild(_clickMsg);
					}
					
					Object(_swf).start(x1,x2,x3,x4,x5,x6,x7);

				}
				catch(e:Error)
				{
					trace("Badge Earned Dialog error: " + e.message);
				}
			}
		}
		
		private function showBadgeRewardDialog():void
		{
			var imageLoader:Loader = new Loader();
			var gridLoader:Loader = new Loader();
			var image:DisplayObject = new Sprite() as DisplayObject;
			var grid:DisplayObject = new Sprite() as DisplayObject;
			var msgText:BadgeRewardMessage = null;
			
			var resourceLocator:SdgResourceLocator = SdgResourceLocator.getInstance();
			var resourceMap:RemoteResourceMap = new RemoteResourceMap();
			resourceMap.addEventListener(Event.COMPLETE, onXMLLoadComplete);
			resourceMap.setResource("badgeMessaging", resourceLocator.getBadgeRewardMessage(_currentBadgeLevel.id));
			resourceMap.load();
			
			function onXMLLoadComplete(e:Event):void
			{
				// Remove Listener
				resourceMap.removeEventListener(Event.COMPLETE, onXMLLoadComplete);
				
				msgText = BadgeRewardMessage(resourceMap.getContent("badgeMessaging"));
				
				loadImage();
			}
			
			function loadImage():void
			{
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onImageLoadComplete);
				imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
				imageLoader.load(new URLRequest(Environment.getAssetUrl()+"/test/gameSwf/gameId/71/gameFile/"+msgText.url));
			}
			
			function onImageLoadComplete(e:Event):void
			{
				e.currentTarget.removeEventListener(Event.COMPLETE, onImageLoadComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
			
				try
				{
					image = DisplayObject(e.currentTarget.content);
				}
				catch(e:Error)
				{
					trace("Error: " + e.message);
				}
				
				// Image has been loaded, so continue
				loadGrid();
			}
			
			function loadGrid():void
			{
				gridLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onGridLoadComplete);
				gridLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onGridIOError);
				gridLoader.load(new URLRequest(Environment.getAssetUrl()+"/test/gameSwf/gameId/71/gameFile/popUp_gridTexture.swf"));
			}
			
			function onGridLoadComplete(e:Event):void
			{
				e.currentTarget.removeEventListener(Event.COMPLETE, onGridLoadComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onGridIOError);
			
				try
				{
					grid = DisplayObject(e.currentTarget.content);
				}
				catch(e:Error)
				{
					trace("Error: " + e.message);
				}
				
				showAward();
			}
			
			function showAward():void
			{
				MainUtil.showDialog(BadgeRewardDialog, {level:_currentBadgeLevel.id, msg:msgText, image:image, grid:grid});
			}
			
			function onImageIOError(e:IOErrorEvent):void
			{
				e.currentTarget.removeEventListener(Event.COMPLETE, onImageLoadComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
				
				trace("BadgeEarnedDialog.onIOError: "+e.text);
			}
			
			function onGridIOError(e:IOErrorEvent):void
			{
				e.currentTarget.removeEventListener(Event.COMPLETE, onGridLoadComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onGridIOError);
				
				trace("BadgeEarnedDialog.onIOError: "+e.text);
			}
		}
		
		private function buildButton(x:int,y:int,width:uint,initialText:String,onClickText:String,callable:String):StoreNavBar
		{
			var button:StoreNavBar = new StoreNavBar(width, 30, initialText);
			button.roundRectStyle = new RoundRectStyle(15, 15);
			button.labelFormat = new TextFormat('EuroStyle', 20, 0x9D330B, true);
			button.buttonMode = true;
			if (callable == "onMessageButtonClick")
			{
				button.addEventListener(MouseEvent.CLICK, onMessageButtonClick);
			}
			else
			{
				button.addEventListener(MouseEvent.CLICK, onCloseButtonClick);
			}
			button.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			button.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			this.rawChildren.addChild(button);
			
			button.labelX = button.width/2 - button.labelWidth/2;

			setDefaultButton(button);
				
			button.x = x;
			button.y = y;
			
			return button;
		}
				
		private function onButtonMouseOver(event:MouseEvent):void
		{
			setMouseOverButton(event.currentTarget as StoreNavBar);
		}
			
		private function onButtonMouseOut(event:MouseEvent):void
		{
			setDefaultButton(event.currentTarget as StoreNavBar);
		}
				
		private function onCloseButtonClick(event:MouseEvent):void
		{
			this.close();
		}
				
		private function onMessageButtonClick(event:MouseEvent):void
		{
			var button:StoreNavBar = event.currentTarget as StoreNavBar;

			// Remove Listeners
			button.removeEventListener(MouseEvent.CLICK, onMessageButtonClick);
			button.removeEventListener(MouseEvent.MOUSE_OVER,onButtonMouseOver);
			button.removeEventListener(MouseEvent.MOUSE_OUT,onButtonMouseOut);
				
			// Call Function that sends messages to friends
			informFriends();
			
			// Set New Appearance
			setMouseOverButton(button);
		}
				
		private function setDefaultButton(button:StoreNavBar):void
		{
			button.labelColor = 0x9D330B;
			button.borderStyle = new LineStyle(0x913300, 1, 1);
			
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(button.width, button.height, Math.PI/2, 0, 0);
			button.gradient = new GradientStyle(GradientType.LINEAR, [0xF7D85B, 0xD88616], [1, 1], [0, 255], gradientBoxMatrix);
		}
				
		private function setMouseOverButton(button:StoreNavBar):void
		{
			button.labelColor = 0xffcc33;
			button.borderStyle = new LineStyle(0xff9900, 1, 1);
			
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(button.width, button.height, Math.PI/2, 0, 0);
			button.gradient = new GradientStyle(GradientType.LINEAR, [0xd18500, 0xa54c0a], [1, 1], [0, 255], gradientBoxMatrix);
		}
		
		public function generateRewardDialogText():void
		{
			return;	
		}
		
		public function informFriends():void
		{
			// Send Informing messagers to all buddies
			var valuesAmalgom:String = "7;"+_avatar.name+";"+_currentBadge.id+";"+_currentBadge.name+";"+_currentBadgeLevel.id+";"+_currentBadgeLevel.name+";"+_currentBadgeLevel.levelIndex;
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "shareWithFriends", { shareWithFriends:valuesAmalgom });
			
			// How Many Buddies did I tell?
			BuddyManager.start();
			var _buddyCount:int = BuddyManager.buddyCount;
			
			// Tell Player Buddies Are Informed
			if (_buddyCount > 1)
			{
				MainUtil.showDialog(BadgeNotifyBuddiesDialog, {title:"MESSAGES SENT:"}, false, false);
			}
			else if (_buddyCount == 1)
			{
				MainUtil.showDialog(BadgeNotifyBuddiesDialog, {title:"MESSAGE SENT:"}, false, false);
			}
		}
		
		
		public function close():void
		{
			// Remove Close Button Listeners
			_closeButton.removeEventListener(MouseEvent.CLICK, onCloseButtonClick);
			_closeButton.removeEventListener(MouseEvent.MOUSE_OVER,onButtonMouseOver);
			_closeButton.removeEventListener(MouseEvent.MOUSE_OUT,onButtonMouseOut);
			
			// Remove Tell Button Listener
			//_tellButton.removeEventListener(MouseEvent.CLICK, onMessageButtonClick);
			//_tellButton.removeEventListener(MouseEvent.MOUSE_OVER,onButtonMouseOver);
			//_tellButton.removeEventListener(MouseEvent.MOUSE_OUT,onButtonMouseOut);
			
			PopUpManager.removePopUp(this);
		}
		
	}
}