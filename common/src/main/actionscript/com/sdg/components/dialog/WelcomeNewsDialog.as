package com.sdg.components.dialog
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.boostworthy.animation.management.AnimationManager;
	import com.sdg.components.controls.ProgressAlertChrome;
	import com.sdg.components.dialog.helpers.MainDialogHelper;
	import com.sdg.control.PDAController;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.AvatarApparelEvent;
	import com.sdg.events.RoomManagerEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.manager.BadgeManager;
	import com.sdg.manager.LevelManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarLevelStatus;
	import com.sdg.model.Badge;
	import com.sdg.model.BadgeLevel;
	import com.sdg.model.BadgeLevelCollection;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.User;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.ItemUtil;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.LayeredImage;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.formatters.NumberFormatter;
	/*
	This screen shows up for returning users when they first log in. It's main components are:
	1. Promo area swf
	2. Ticker
	3. ASN button
	4. A place for text to appear for how long they have to go before the next rank
	Later:
	5. Show number of notifications
	6. Show number of turf messages
	7. Recommend some badges.
	8. Possibly allowance of day to day prizes also surfaced here?
	9. Possibly sports psycic
	@author molly.jameson
	*/
	public class WelcomeNewsDialog extends InteractiveDialog
	{
		private var m_ShowWorldMapOnClose:Boolean;
		private var m_Info:XML;
		// tracking the splash screen changes
		private var m_SplashPages:Array;
		private var m_SplashAnimator:AnimationManager;
		private var m_CurrSplashIndex:int = 0;
		private var m_NextTimer:Timer;
		
		// to show during loading
		private var m_ProgressAlert:ProgressAlertChrome;
		private var m_WS:welcomeScreen;
		
		private const LOG_WELCOME_LOAD:int = 4700;
		private const LOG_WELCOME_CLOSE:int = 4701;
		//private const LOG_BADGE_CLICK:int = 4702;
		private const LOG_ASN_CLICK:int = 4703;
		private const LOG_PROMO_CLICK_0:int = 4704;
		private const LOG_PROMO_CLICK_3:int = 4707;
		
		public function WelcomeNewsDialog()
		{
			super();
			m_ShowWorldMapOnClose = false;
			m_Info = null;
		}
		public override function init(params:Object):void
		{
			m_ShowWorldMapOnClose = params["showWorldMapOnEnd"];
			
			if (ModelLocator.getInstance().avatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				this.close();	
				// don't need to do anything else
				return;
			}
			// instead of loading in a URL just use the embeded asset since everyone sees it.
			m_WS = new welcomeScreen();
			// close on welcome button
			var closeBtn:DisplayObject = m_WS.btn_xClose;
			closeBtn.addEventListener(MouseEvent.CLICK,onCloseClick,false,0,true);
			_display = m_WS;
			
			var clickBlocker:Sprite = new Sprite();
			clickBlocker.graphics.beginFill(0,0.75);
			clickBlocker.graphics.drawRect(0,0,925,665);
			clickBlocker.graphics.endFill();
			clickBlocker.x = -clickBlocker.width/2;
			clickBlocker.y = -clickBlocker.height/2;
			m_WS.addChildAt(clickBlocker,0);
				
			super.loadCompleteHandler();
			
			loadCurrentData();
			setUpBadges();
			splashLoad();
			
			setUpLevelInfo();
			// independent calls
			setUpASN();
			loadFavTeamLogo();
			
			// Wait until all clothes are loaded
			CairngormEventDispatcher.getInstance().addEventListener(AvatarApparelEvent.AVATAR_APPAREL_COMPLETED, onApparelListCompleted);
			CairngormEventDispatcher.getInstance().dispatchEvent(new AvatarApparelEvent(ModelLocator.getInstance().avatar));			
			// is a girl
			if(ModelLocator.getInstance().avatar.gender != 1)
			{
				m_WS.frame.npcKyle.visible = false;
				m_WS.frame.npcMolly.visible = true;
			}
			else
			{
				m_WS.frame.npcKyle.visible = true;
				m_WS.frame.npcMolly.visible = false;
			}		
			
			// some slow machines are skipping the stop animation on the timeline.
			// these are special animations that NEED to be stopped correctly.
			for(var i:int = 1; i <= 6; ++i)
			{
				var mc2:MovieClip = m_WS["coinAnim"+(i)];
				mc2.gotoAndStop(1);
			}
			m_WS.bonusPopUp.gotoAndStop(1);

			m_WS.dailyBonus.inst_DailyBonusHeader.text =  getMonthName() + "'s Daily Bonus ";
			// Don't show the welcome screen until we have at least the welcome screen xml
			m_ProgressAlert  = ProgressAlertChrome.show('Loading section... please wait.', 'Just A Moment');
			m_WS.visible = false;
		}
		//clean up and logging
		public override function close():void
		{
			super.close();
			
			if(m_ShowWorldMapOnClose)
			{
				RoomManager.getInstance().dispatchEvent(new RoomManagerEvent(RoomManagerEvent.REQUEST_FOR_WORLD_MAP));
			}
			if(m_NextTimer != null)
			{
				m_NextTimer.removeEventListener(TimerEvent.TIMER, onNextTimer);
				m_NextTimer.stop();
			}
			if(m_ProgressAlert != null)
			{
				m_ProgressAlert.close(0);
				m_ProgressAlert = null;
			}
			LoggingUtil.sendClickLogging(LOG_WELCOME_CLOSE);
		}
		
		private function onCloseClick(ev:Event):void
		{
			close();
		}
		// Welcome screen XML (contains the sayings and prizes
		private function loadCurrentData():void
		{
			var av:Avatar = ModelLocator.getInstance().avatar;
			if(av.localAvatarLogInXML != null)
			{
				onComplete();
			}
			else
			{
				av.addEventListener(Avatar.EVENT_LOCAL_AVATAR_XML_DONE_LOADING,onComplete);
			}
			
			function onComplete(e:Event = null):void
			{
				av.removeEventListener(Avatar.EVENT_LOCAL_AVATAR_XML_DONE_LOADING,onComplete);
				
				LoggingUtil.sendClickLogging(LOG_WELCOME_LOAD);
				m_WS.visible = true;
				m_ProgressAlert.close(0);
				m_ProgressAlert = null;
				
				m_Info = av.localAvatarLogInXML;
				// check if we have the info we need, if not close and move on.
				if(m_Info.descendants("count").length() == 0)
				{
					close();
				}
				else
				{
					startSayingIfReady();	
					showBadgesIfReady();	
					checkForPrizes(m_Info.descendants("count")[0]);		
				}
			}
		}
		// Welcome screen XML (contains the sayings and prizes
		/*private function loadCurrentData():void
		{
			var av:Avatar = ModelLocator.getInstance().avatar;
			//http://mdr-qa02/test/dyn/avatar/acctLoginInfo?avatarId=123
			var url:String = Environment.getApplicationUrl() + '/test/dyn/avatar/acctLoginInfo?avatarId='+av.avatarId;
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);

			function onComplete(e:Event):void
			{
				// Show the welcome screen remove loading
				m_WS.visible = true;
				m_ProgressAlert.close(0);
				m_ProgressAlert = null;
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				var xml:XML = new XML(loader.data);
				m_Info = xml[0];
				startSayingIfReady();	
				showBadgesIfReady();	
				checkForPrizes(m_Info.descendants("count")[0]);				
			}
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				close();
			}
		}*/
		
		private function checkForPrizes(timesLoggedIn:int = 0):void
		{
			var todayPrize:XMLList = m_Info.descendants("prize");
			var awardPrizeThisTime:XMLList = m_Info.descendants("prizeAwarded");
			//only show the animation if this is the first time they've logged in today
			var showAnimation:Boolean = true;
			if(awardPrizeThisTime.length() == 0 ||
			  awardPrizeThisTime[0] == "0")
			  {
			  	showAnimation = false;
			  }
			
			var maxCoins:int = (timesLoggedIn >= 6) ? 6 : timesLoggedIn;
			
			// make sure all the others are stopped by default
			for(i = 1; i <= 6; ++i)
			{
				var mc2:MovieClip = m_WS["coinAnim"+(i)];
				mc2.gotoAndStop(1);
			}
			m_WS.bonusPopUp.gotoAndStop(1);
			
			for(var i:int = 1; i <= maxCoins; ++i)
			{
				var mc:MovieClip = m_WS["coinAnim"+(i)];
				if(i == timesLoggedIn && showAnimation)
				{
					var tokens:int = 0;
					var xml:XML = todayPrize[i - 1];
					if(xml != null)
					{
						if(xml.prizeRequirementValue == i)
						{
							tokens = xml.currencyValue;
						}
						// sets a static var inside the welcome screen that is read by a later frame
						welcomeScreen.s_TokenText = "+" + tokens.toString();
						mc.gotoAndPlay("start");
					}
				}
				else
				{
					mc.gotoAndStop("previousDay");	
				}
			}
			
			// just for the prize
			if(timesLoggedIn == 7 && showAnimation)
			{
				var todayPrizeXml:XML = todayPrize[6];
				if(todayPrizeXml != null)
				{
					m_WS.bonusPopUp.gotoAndPlay("startPrize");
					m_WS.bonusPopUp.addEventListener(Event.ENTER_FRAME,onPrizeWait);
					var bigURL:String = ItemUtil.GetLargeThumbnailUrl(todayPrizeXml.itemId);
					var itemNameSt:String = "You've earned this "+ todayPrizeXml.name + " for stopping by 7 times in "+getMonthName()+"!";
					m_WS.setPrizeInfo(bigURL,itemNameSt);
					// On last frame they can close the nested window
					function onPrizeWait(ev:Event):void
					{
						if(m_WS.bonusPopUp.currentFrame == m_WS.bonusPopUp.totalFrames)
						{
							m_WS.bonusPopUp.removeEventListener(Event.ENTER_FRAME,onPrizeWait);
							m_WS.bonusPopUp.day7Bonus.btnClosePrize.addEventListener(MouseEvent.CLICK,onPrizeClose);
							function onPrizeClose(ev:Event):void
							{
								m_WS.bonusPopUp.gotoAndPlay("stopPrize");
							}
						}
					}
				}
			}
			// grayscale the whole thing if no animation needed.
			if(timesLoggedIn > 7 || 
			  (timesLoggedIn >= 7 && !showAnimation))
			{
				var grayScaleMat:Array = [ .33,.33,.33,0,0,.33,.33,.33,0,0,.33,.33,.33,0,0,.33,.33,.33,1,0 ];
				m_WS.dailyBonus.filters = [new ColorMatrixFilter(grayScaleMat)];
			}
		}
		private function onApparelListCompleted(event:AvatarApparelEvent):void
		{	
			CairngormEventDispatcher.getInstance().removeEventListener(AvatarApparelEvent.AVATAR_APPAREL_COMPLETED, onApparelListCompleted);
			var av:Avatar = ModelLocator.getInstance().avatar;
			// Load avatar image.
			var avatarImage:LayeredImage = new LayeredImage();
			avatarImage.addEventListener(Event.COMPLETE, onAvatarImageComplete);
			avatarImage.loadItemImage(av);
			function onAvatarImageComplete():void
			{
				// Remove event listener.
				avatarImage.removeEventListener(Event.COMPLETE, onAvatarImageComplete);
				avatarImage.filters = [new GlowFilter(0, 1, 5, 5, 10)];
				// according to mock up 88 pixels height
				avatarImage.scaleX = avatarImage.scaleY = 88/avatarImage.height;
				m_WS.yourAvatar.addChild(avatarImage);
			}
		}
		private function loadFavTeamLogo():void
		{
			var av:Avatar = ModelLocator.getInstance().avatar;
			var holderMC:Sprite = m_WS.teamSelect_icon;
			if (av.favoriteTeamId)
			{
				
				holderMC.addChild(new QuickLoader(AssetUtil.GetTeamLogoUrl(av.favoriteTeamId),null,null,3));
			}
			else
			{
				holderMC.visible = false;
			}
		}
		
		/**
		 * Level loading info
		 */
		private function setUpLevelInfo():void
		{
			if (LevelManager.LevelDataAvailable)
			{	
				updateLevelData();
			}
			else
			{
				LevelManager.Instance.addEventListener(LevelManager.LEVEL_DATA_AVAILABLE, onLevelDataAvailable);
				function onLevelDataAvailable(ev:Event):void
				{
					LevelManager.Instance.removeEventListener(LevelManager.LEVEL_DATA_AVAILABLE, onLevelDataAvailable);
					updateLevelData();
				}
			}
		}
		
		private function updateLevelData():void
		{
			var levelStatus:AvatarLevelStatus = LevelManager.GetAvatarLevelStatus(ModelLocator.getInstance().avatar);
			m_WS.star_allstar.visible = false;
				
			for(var i:int = 1; i <= 4; ++i)
			{
				var mcName:String = "starLevel" + i;
				var starSprite:MovieClip = m_WS[mcName] as MovieClip;
				if(starSprite && levelStatus.levelIndex >= i)
				{
					starSprite.visible = true;
					// stops the swelling
					if(levelStatus.levelIndex == i)
					{
						starSprite.starFill.gotoAndPlay("starSwell");
						//Am 1 - 5,Rookie 6 -> 10,Pro 11 -> 15,Vet 16 - 20,21
						var frameLabel:int = (levelStatus.subLevelIndex % 5);
						if(frameLabel <= 0 || frameLabel > 5)
						{
							frameLabel = 5;
						}
						
						starSprite.starFill.starFillAnim.gotoAndStop("level" + frameLabel);
					}
					else
					{
						starSprite.starFill.stop();
						starSprite.starFill.starFillAnim.gotoAndStop("level5");
					}
				}
			}
			if(levelStatus.levelIndex >= 5)
			{
				m_WS.star_allstar.visible = true;
				m_WS.star_allstar.starFill.starFillAnim.gotoAndStop("level5");
				m_WS.star_allstar.starFill.gotoAndPlay("starSwell");
			}
			
			startSayingIfReady();
		}		
		// start saying if we have the level and saying loaded.
		private function startSayingIfReady():void
		{
			if(m_Info != null && LevelManager.LevelDataAvailable)
			{
				var saying:XMLList = m_Info.descendants("saying");
				var sayingString:String = saying[0];
				var av:Avatar = ModelLocator.getInstance().avatar;
				if(sayingString == null)
				{
					sayingString == "";
				}
				m_WS.setText(sayingString, "Welcome back, " + av.name + "!");
				showLevelText();
			}
		}
		private function showLevelText():void
		{
			var av:Avatar = ModelLocator.getInstance().avatar;
			var levelStatus:AvatarLevelStatus = LevelManager.GetAvatarLevelStatus(av);
			var nf:NumberFormatter = new NumberFormatter();
			
			m_WS.mc_tf.rankLevel.text = levelStatus.levelName + " : Level " + levelStatus.subLevelIndex;
			m_WS.mc_tf.nextLevel.text = nf.format(levelStatus.nextLevelXp - levelStatus.currentXp)+ " XP to next level!";
			if(levelStatus.subLevelIndex >= 21)
			{
				m_WS.mc_tf.nextLevel.visible = false;
			}
		}
		
		/**
		 * BADGE code here.
		 */
		private function setUpBadges():void
		{
			// Badges section
			var isBadgesLoaded:Boolean = false;
			if (BadgeManager.BadgesAvailable == false)
			{
				BadgeManager.Instance.addEventListener(BadgeManager.BADGE_LOAD_COMPLETE, onComplete);
				BadgeManager.LoadBadges();
			}
			else
			{
				showBadgesIfReady();
			}
			// This is actually called twice. Once for when the badges are loaded.
			// and for when the avatar badges are loaded.
			function onComplete(event:Event):void
			{
				if (isBadgesLoaded == false)
				{
					isBadgesLoaded = true;
					BadgeManager.LoadAvatarBadges(ModelLocator.getInstance().avatar.avatarId);
				}
				else
				{
					BadgeManager.Instance.removeEventListener(BadgeManager.BADGE_LOAD_COMPLETE, onComplete);
					showBadgesIfReady();
				}
			}
		}
		// just verifies if a badge level is on our list of badge levels.
		// basically just a very specific "contains"
		private function isLevelOnList(checkBadges:XMLList, levelId:int):int
		{
			for(var i:int = 0; i < checkBadges.length(); ++i)
			{
				var obj:Object = checkBadges[i];
				var objTest:Object = obj.badgeLevel.id;
				var objTest2:Object = obj.id[0];
				var badgeId:int = parseInt(obj.id[0]);
				if(badgeId == levelId)
				{
					return i;
				}
			}
			return -1;
		}
		private function showBadgesIfReady():void
		{
			if (BadgeManager.BadgesAvailable == true && m_Info != null)
			{
				var checkBadges:XMLList = m_Info.descendants("badgeLevel");
				
				var unearnedBadges:Array = new Array();
				var len:int = BadgeManager.AllBadges.length;
				for(var i:int = 0; i < len; ++i)
				{
					var b:Badge = BadgeManager.AllBadges.getAt(i);
					var levels:BadgeLevelCollection = b.levels;
					// going through backwards to make sure we just get the highest level.
					for (var j:int = 0; j < levels.length; j++)
					{
						var level:BadgeLevel = levels.getAt(j);
						if (!BadgeManager.DoesAvatarOwnBadgeLevel(ModelLocator.getInstance().avatar.avatarId, b.id, level.id))
						{
							var listIndex:int = isLevelOnList(checkBadges,level.id)
							if(listIndex >= 0)
							{
								var badgeData:Object = new Object();
								badgeData.xmlData = checkBadges[listIndex];
								badgeData.badgeID = b.id;
								// if it's on our list and they haven't earned it yet. add to unearned
								unearnedBadges.push(badgeData);
								break;
							}
						}
					}
				}
				// go through unearned badges
				if(unearnedBadges.length > 0)
				{
					var unearnedBadge:Object = unearnedBadges[(int)(unearnedBadges.length * Math.random())];
					
					m_WS.badgePromo.inst_BadgeText.text = unearnedBadge.xmlData.name;
					
					// load the correct image
					var badgeImageLocation:String = Environment.getAssetUrl() + "/api/static/images/badgeSuggest?badgeId="+unearnedBadge.badgeID;
					m_WS.badgePromo.inst_BadgeImage.addChild(new QuickLoader(badgeImageLocation,null,null,3));
				}
				else
				{
					m_WS.badgePromo.inst_BadgeText.text = "Have you earned all your badges?";
				}
			}
		}
		/**
		 * ASN showing code
		 */
		private function setUpASN():void
		{
			var asnBtn:DisplayObject = m_WS.btnASN;
			asnBtn.addEventListener(MouseEvent.CLICK,onASNClick,false,0,true);
			var user:User = ModelLocator.getInstance().user;
			// Determine whether to set "New" on button
			if (user.lastEditionId <= user.userEditionId)
			{
				m_WS.asnNew.visible = false;
			}
		}
		private function onASNClick(ev:Event):void
		{
			// stop showing new on other animations
			m_WS.asnNew.visible = false;
			MainDialogHelper.showDialog({news:true});
			ModelLocator.getInstance().avatar.dispatchEvent(new Event('Event_ASN_Shown'));
			LoggingUtil.sendClickLogging(LOG_ASN_CLICK);
		}
		
		private function splashLoad():void
		{
			var url:String = Environment.getApplicationUrl() + "/api/static/metadata/upsell/slideSetXML?slideSetId=2";
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			m_SplashAnimator = new AnimationManager();
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Get feed xml.
				var xml:XML = new XML(loader.data);				
				var ws:welcomeScreen = _display as welcomeScreen;
				var allURLs:XMLList = xml.descendants("url");
				m_SplashPages = new Array();
				m_CurrSplashIndex = 0;
				
				m_WS.btnBack.addEventListener(MouseEvent.CLICK,onScrollLeft,false,0,true);
				m_WS.btnForward.addEventListener(MouseEvent.CLICK,onScrollRight,false,0,true);
				for(var i:int = 0; i < allURLs.length(); ++i)
				{
					var splashURL:String = Environment.getApplicationUrl()+"/"+allURLs[i];
					var splashLoader:QuickLoader = new QuickLoader(splashURL,null,null,3);
					splashLoader.addEventListener("Transport",onTransport,false,0,true);
					splashLoader.addEventListener('buy item', onBuyItem,false,0,true);
					m_SplashPages.push(splashLoader);
					splashLoader.x = splashLoader.y = 3;
					if(i == 0)
					{
						m_WS.largePromo.promoContainer.addChild(m_SplashPages[0]);
					}
				}
				// Don't fade if only one is on there.
				if( allURLs.length() > 1)
				{
					m_NextTimer = new Timer(4000,int.MAX_VALUE);
					m_NextTimer.addEventListener(TimerEvent.TIMER, onNextTimer);
					m_NextTimer.start();
				}
			}
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		// can only be called from splash screens so just log here.
		protected override function onTransport(e:Event):void
		{
			super.onTransport(e);
			logSplashClick();
		}
		protected override function onBuyItem(event:Event):void
		{
			super.onBuyItem(event);
			logSplashClick();
		}
		private function logSplashClick():void
		{
			// does a range check since Anne gave me a set number of IDs
			if(LOG_PROMO_CLICK_0 + m_CurrSplashIndex <= LOG_PROMO_CLICK_3)
			{
				LoggingUtil.sendClickLogging(LOG_PROMO_CLICK_0 + m_CurrSplashIndex);
			}
		}
		private function onNextTimer(ev:Event):void
		{
			onScrollRight();
		}
		private function onScrollLeft(ev:Event = null):void
		{
			var prev:Sprite = m_SplashPages[m_CurrSplashIndex];
			m_CurrSplashIndex = (m_CurrSplashIndex - 1) >= 0 ? (m_CurrSplashIndex - 1) : m_SplashPages.length - 1;
			var next:Sprite = m_SplashPages[m_CurrSplashIndex];
			
			ForceScroll(prev,next,ev != null);
		}
		private function onScrollRight(ev:Event = null):void
		{
			// if event is null then do a fade
			var prev:Sprite = m_SplashPages[m_CurrSplashIndex];
			m_CurrSplashIndex = (m_CurrSplashIndex + 1) % m_SplashPages.length;
			var next:Sprite = m_SplashPages[m_CurrSplashIndex];

			// fade out previous and fade on the next one
			ForceScroll(prev,next,ev != null);
		}
		
		private function ForceScroll(prev:Sprite,next:Sprite,wasForced:Boolean):void
		{
			var ws:welcomeScreen = _display as welcomeScreen;
			ws.largePromo.promoContainer.addChild(next);
			prev.alpha = 1;
			next.alpha = 0;
			m_SplashAnimator.alpha(prev,0,1000);
			m_SplashAnimator.alpha(next,1,1000);
			
			// they've done a force scroll
			if(wasForced)
			{
				m_NextTimer.stop();
				m_NextTimer.start();
			}
		}
		private function getMonthName():String
		{
			var currDate:Date = new Date();
			var allMonths:Array = new Array('January', 'February', 'March', 'April', 'May','June', 
											'July', 'August', 'September', 'October', 'November', 'December');
			return allMonths[currDate.month];								
		}
		
	}
}