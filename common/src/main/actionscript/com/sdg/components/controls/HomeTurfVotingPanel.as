package com.sdg.components.controls
{
	import com.sdg.components.events.TurfVoteEvent;
	import com.sdg.events.AvatarEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.manager.LevelManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarLevelStatus;
	import com.sdg.model.ISetAvatar;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.CurrencyUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.Container;

	//public class HomeTurfVotingPanel extends TitleWindow implements ISetAvatar
	public class HomeTurfVotingPanel extends Container implements ISetAvatar
	{
		// Constants
		private static var WIDTH:uint = 165;		
		private static var STARS_WIDTH:uint = 85;
		private static var HEIGHT:uint = 180;
		private static var TOP_HEIGHT:uint = 60;
		private static var BOTTOM_HEIGHT:uint = 120;
		
		// Primary Components
		protected var _backing:Sprite;
		protected var _translucentBacking:Sprite;
		protected var _name:TextField;
		protected var _comment:TextField;
		protected var _totalRatingsText:TextField;
		protected var _ratingsCount:TextField;
		protected var _stars:VoteStars;
		protected var _turfValueText:TextField;
		protected var _turfValue:TextField;
		protected var _houseOutline:DisplayObject;
		protected var _outlineLoader:Loader;
		protected var _badgeIconLoader:Loader;
		protected var _badgeLinkIcon:DisplayObject;
		
		// Only Set Once
		protected var _initialized:Boolean = false;
		
		// State Data
		protected var _alreadyVoted:Boolean;
		protected var _roomAvatarLevel:uint = 0;
		protected var _avatarTurfFlag:Boolean = false;
		protected var _roomId:String;
		protected var _roomOwnerId:int;
		protected var _ownerAvatar:Avatar;
		
		// Socket Client
		private var _socketClient:SocketClient = SocketClient.getInstance();
		
		public function HomeTurfVotingPanel()
		{
			super();
			
			// Set Location
			this.x = 755;
			this.y = 5;
			
			// Listen to visible var
			BindingUtils.bindSetter(visibleUpdate, this, "visible");
						
			// Listen for room data from socket event
			_socketClient.addEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
		}
		
		// Render Is Only Ever Executed Once
		protected function render():void
		{
			// Only execute once
			if (_initialized)
				return;
				
			// Set Height and Width
			this.height = HomeTurfVotingPanel.TOP_HEIGHT;
			this.width = HomeTurfVotingPanel.WIDTH;
			
			_backing = new Sprite();
			this.rawChildren.addChild(_backing);
			
			_translucentBacking = new Sprite();
			this.rawChildren.addChild(_translucentBacking);
				
			// Render Backgrounds
			var cornerSize:Number = 8;
			_backing.graphics.clear();
			_backing.graphics.beginFill(0x1f1f1f, 1.0);
			_backing.graphics.drawRoundRectComplex(0,0,this.width,this.height,cornerSize,cornerSize,0,0);
			_translucentBacking.graphics.clear();
			_translucentBacking.graphics.beginFill(0x222222, 0.9);
			_translucentBacking.graphics.drawRoundRectComplex(0,HomeTurfVotingPanel.TOP_HEIGHT,
				HomeTurfVotingPanel.WIDTH,HomeTurfVotingPanel.BOTTOM_HEIGHT,0,0,cornerSize,cornerSize);
			
			// Render Name
			_name = new TextField();
			_name.defaultTextFormat = new TextFormat('EuroStyle', 13, 0xffcc00, true,true);
			_name.text = this.determineTurfTitle();
			_name.autoSize = TextFieldAutoSize.LEFT;
			_name.embedFonts = true;
			_name.selectable = false;
			//_name.width = 50;
			//_name.height = 12;
			_name.x = 3;
			_name.y = 3;
			this.rawChildren.addChild(_name);
			
			// Render Text of Ratings Count
			_totalRatingsText = new TextField();
			_totalRatingsText.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			_totalRatingsText.text = 'Total Ratings:';
			_totalRatingsText.autoSize = TextFieldAutoSize.LEFT;
			_totalRatingsText.embedFonts = true;
			_totalRatingsText.selectable = false;
			_totalRatingsText.x = 3;
			_totalRatingsText.y = 42;
			this.rawChildren.addChild(_totalRatingsText);
			
			// Render Ratings Count
			_ratingsCount = new TextField();
			_ratingsCount.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			_ratingsCount.text = '0';
			_ratingsCount.autoSize = TextFieldAutoSize.LEFT;
			_ratingsCount.embedFonts = true;
			_ratingsCount.selectable = false;
			_ratingsCount.x = 80;
			_ratingsCount.y = 42;
			this.rawChildren.addChild(_ratingsCount);
			
			// Render Turf Value Text
			_turfValueText = new TextField();
			_turfValueText.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			_turfValueText.text = "Turf Value: ";
			_turfValueText.autoSize = TextFieldAutoSize.LEFT;
			_turfValueText.embedFonts = true;
			_turfValueText.selectable = false;
			_turfValueText.x = 3;
			_turfValueText.y = 160;
			this.rawChildren.addChild(_turfValueText);
			
			// Render Turf Value
			_turfValue = new TextField();
			_turfValue.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffcc00, true);
			_turfValue.text = "0";
			_turfValue.autoSize = TextFieldAutoSize.LEFT;
			_turfValue.embedFonts = true;
			_turfValue.selectable = false;
			_turfValue.x = 65;
			_turfValue.y = 160;
			this.rawChildren.addChild(_turfValue);
			
			// Stars Display
			_stars = new VoteStars();
			_stars.x = 3;
			_stars.y = 25;
			this.rawChildren.addChild(_stars);
			_stars.addEventListener(TurfVoteEvent.VOTE,onVote);

			// Record that panel is rendered
			_initialized = true;
		}
		
		// PUBLIC DATA SETTERS
		// setRoom is called whenever a person enters a room
		public function setRoom(roomId:String,roomOwnerId:int):void
		{
			// Build Panel if this is the first usuage of the panel
			render();
			
			// Set RoomId
			_roomId = roomId;
			_roomOwnerId = roomOwnerId;
			
			// Reset State
			_ownerAvatar = null;
			_alreadyVoted = false;
			_roomAvatarLevel = 0;
			if (_roomOwnerId == 0)
				_avatarTurfFlag = false;

			// Get the Avatar for the _roomAvatarLevel
			dispatchEvent(new AvatarEvent(_roomOwnerId, this));
			
			// Voting Panel Data Should Be Reset
			//this.updateTurfTitle();
			_ratingsCount.text = '0';
			_stars.reset();
		}
		
		public function setVoteCount(count:String):void
		{
			_ratingsCount.text = count;
		}
		
		public function setTurfValue(value:String):void
		{
			_turfValue.text = value;
		}
		
		public function set avatar(value:Avatar):void
		{
			_ownerAvatar = value;
			
			// Determine Level of Avatar
			var levelStatus:AvatarLevelStatus = LevelManager.GetAvatarLevelStatus(_ownerAvatar);
			if (levelStatus)
			{
				var levelChanged:Boolean = (_roomAvatarLevel != levelStatus.levelIndex);
				_roomAvatarLevel = levelStatus.levelIndex;
				this.updateTurfTitle();
				if (levelChanged)
				{
					if (_houseOutline)
						this.rawChildren.removeChild(_houseOutline);
					this.loadHouseOutline();
				}
			}
		}
		
		public function loadHouseOutline():void
		{
			// Load House Display
			_houseOutline = new QuickLoader(this.getHouseOutlineURL(),onOutlineReady,onOutlineIOError,3);
			
			// OLD LOADER
			//_outlineLoader = new Loader();
			//_outlineLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onOutlineReady);
			//_outlineLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onOutlineIOError);
			//_outlineLoader.load(new URLRequest(this.getHouseOutlineURL()));
		}
		
//		public function loadBadgeIcon():void
//		{
//			// Load Badge Icon
//			_badgeIconLoader = new Loader();
//			_badgeIconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onIconReady);
//			_badgeIconLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIconIOError);
//			_badgeIconLoader.load(new URLRequest(Environment.getAssetUrl()+"/test/gameSwf/gameId/73/gameFile/house1.swf"));
//		}
		
		public function getTurfValueFromServer():void
		{
			trace("Getting Turf Value");
			_socketClient.sendPluginMessage("avatar_handler", "getTurfRoomValue",{ getTurfRoomValue:"0"});
		}
		
		public function updateTurfTitle():void
		{
			_name.text = this.determineTurfTitle();
		}
		
		// LISTENERS
		private function onPluginEvent(e:SocketEvent):void
		{
			var params:Object = e.params;
			var action:String = params.action as String;

			if (action == 'turfRating')
			{
				trace("TURF RATING PLUGIN EVENT RECEIVED");

				// Parse Values
				var paramString:String = params.payload as String;
				var paramArray:Array = paramString.split(";",10);
				
				// Parse Data and then utilize setters
				var rawTurfValue:String = paramArray.pop() as String;
				var userVote:String = paramArray.pop() as String;
				var numVotes:String = paramArray.pop() as String;
				var roomRating:String = paramArray.pop() as String;
				
				
				this._stars.setAverage(Number(roomRating));
				this.setVoteCount(numVotes);
				if (userVote != "-1")
				{
					_stars.setVote(Number(userVote));
					_stars.updateStarsDescription();
				}
				if (rawTurfValue != "-1")
				{
					this._turfValue.text = CurrencyUtil.intFormat(parseInt(rawTurfValue));
				}
				else
				{
					this._turfValue.text = "0";
				}
				
			}
			else if (action == 'turfValue')
			{
				trace("TURF VALUE PLUGIN EVENT RECEIVED");
				var paramString:String = params.payload as String;
				
				// Parse Data and then utilize setters
				var rawTurfValue:String = paramString;

				if (this._turfValue)
				{
					if (rawTurfValue != "-1")
					{
						this._turfValue.text = CurrencyUtil.intFormat(parseInt(rawTurfValue));
					}
					else
					{
						this._turfValue.text = "N/A";
					}
				}
			}
		}
		
		private function onVote(e:TurfVoteEvent):void
		{
			//Log Vote
			LoggingUtil.sendClickLogging(LoggingUtil.TURF_PANEL_RATE_TURF);
			
			// Send Vote to Server
			//trace("voting on turf = " + e.vote);
			_socketClient.sendPluginMessage("avatar_handler", "setTurfRoomRating", { setTurfRoomRating:String(e.vote)});
		}
		
		private function onOutlineReady():void
		{
			//_outlineLoader.removeEventListener(Event.COMPLETE, onOutlineReady);
			//_outlineLoader.removeEventListener(IOErrorEvent.IO_ERROR, onOutlineIOError);
			try
			{
				//_houseOutline = DisplayObject(_outlineLoader.content);
				//_outlineLoader.visible= true;
				_houseOutline.x = 3;
				_houseOutline.y = 70;
				this.rawChildren.addChild(_houseOutline);
			}
			catch(e:Error)
			{
				trace("Home Turf House Outline Image Error: " + e.message);
			}
		}
		
		private function onOutlineIOError():void
		{
			//_outlineLoader.removeEventListener(Event.COMPLETE, onOutlineReady);
			//_outlineLoader.removeEventListener(IOErrorEvent.IO_ERROR, onOutlineIOError);
		}
		
//		private function onIconReady(event:Event):void
//		{
//			_badgeIconLoader.removeEventListener(Event.COMPLETE, onIconReady);
//			_badgeIconLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIconIOError);
//			try
//			{
//				_badgeLinkIcon = DisplayObject(_badgeIconLoader.content);
//				_badgeIconLoader.visible= true;
//				_badgeLinkIcon.x = 0;
//				_badgeLinkIcon.y = 0;
//				this.rawChildren.addChild(_badgeLinkIcon);
//				
//				// TBD - Add Listener to Clicks on the Icon to launch Badge Conparison Screen
//			}
//			catch(e:Error)
//			{
//				trace("Badge Icon Error: " + e.message);
//			}
//		}
		
//		private function onIconIOError(event:Event):void
//		{
//			_badgeIconLoader.removeEventListener(Event.COMPLETE, onIconReady);
//			_badgeIconLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIconIOError);
//			
//		}
		
		private function visibleUpdate(visible:Boolean):void
		{
			//if (visible == true)
				//this.getTurfValueFromServer();
			var x:int = 0;
		}
		
		// PRIVATE FUNCTIONS
		private function getHouseOutlineURL():String
		{
			switch (_roomAvatarLevel)
			{
				case 1:
					return Environment.getAssetUrl()+"/test/gameSwf/gameId/73/gameFile/house1.swf";
				case 2:
					return Environment.getAssetUrl()+"/test/gameSwf/gameId/73/gameFile/house2.swf";
				case 3:
					return Environment.getAssetUrl()+"/test/gameSwf/gameId/73/gameFile/house3.swf";
				case 4:
					return Environment.getAssetUrl()+"/test/gameSwf/gameId/73/gameFile/house4.swf";
				case 5:
					return Environment.getAssetUrl()+"/test/gameSwf/gameId/73/gameFile/house5.swf";
				default:
					return Environment.getAssetUrl()+"/test/gameSwf/gameId/73/gameFile/house3.swf";
			}
		}
		
		private function determineTurfTitle():String
		{
			// Default to Empty String
			var themeName:String = "";
			
			var titleSuffix:String = "";
			trace("Turf Title Room_Avatar_Level :"+_roomAvatarLevel);
			switch (_roomAvatarLevel)
			{
				case 1:
					titleSuffix = "Amateur Shack";
					break;
				case 2:
					titleSuffix = "Rookie Pad";
					break;
				case 3:
					titleSuffix = "Pro House";
					break; 
				case 4:
					titleSuffix = "Veteran Mansion";
					break;
				case 5:
					titleSuffix = "AllStar Estate";
					break;
				default:
					titleSuffix = "Pro House";
			}
			
			return titleSuffix;
			//return themeName+" "+titleSuffix;	
		}
		
	}
}