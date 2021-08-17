package com.sdg.control
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.controls.TransitionBitmap;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.model.Avatar;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.LoadIndicatorOverlay;

	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName; // Non-SDG
	import flash.utils.Timer;

	import mx.core.Application;
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleLoader;
	import mx.modules.ModuleManager;

	public class AASModuleLoader
	{
		private static var RoomModule:Class = getDefinitionByName("RoomModule") as Class; // Non-SDG

		private static var _isStoreModuleOpenArray:Array = [];
		private static var _main:Object = Application.application;

		public function AASModuleLoader()
		{
		}

		public static function openLeaderBoard(gameType:uint = 0,index:uint = 0):void
		{
			// Load and show the leaderboard module.
			// Show a loading indicator so the user knows that something is happening.

			// Show loading indicator.
			var loadIndicator:LoadIndicatorOverlay = new LoadIndicatorOverlay();
			loadIndicator.name = 'Loading Leaderboard';
			_main.rawChildren.addChild(loadIndicator);

			// Steup and execute the load.
			var module:Object; // Non-SDG - remove the specific module type
			var info:IModuleInfo = ModuleManager.getModule('LeaderBoardModule.swf');
			info.addEventListener(ModuleEvent.READY, onModuleReady);
			info.addEventListener(ModuleEvent.ERROR, onModuleError);
			info.addEventListener(ModuleEvent.PROGRESS, onModuleProgress);
			info.load(ApplicationDomain.currentDomain);

			// Create a timeout timer.
			var timer:Timer = new Timer(3000);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();

			function onModuleError(e:ModuleEvent):void
			{
				handleLoadError();
			}

			function onTimer(e:TimerEvent):void
			{
				// If the timeout timer reaches it's interval,
				// we'll assume something has gone wrong with the load.

				handleLoadError();
			}

			function handleLoadError():void
			{
				// Remove listeners.
				info.removeEventListener(ModuleEvent.READY, onModuleReady);
				info.removeEventListener(ModuleEvent.ERROR, onModuleError);
				info.removeEventListener(ModuleEvent.PROGRESS, onModuleProgress);

				// Kill the timeout timer.
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;

				// Unload the module.
				info.unload();

				// Remove load indicator.
				_main.rawChildren.removeChild(loadIndicator);

				// Propagate the CloseModuleEvent
				_main.dispatchEvent(new Event('closeModule'));

				// Send an alert for the error.
				SdgAlertChrome.show('We couldn\'t load the Leaderboard.', 'Sorry');
			}

			function onModuleReady(e:ModuleEvent):void
			{
				// Remove listeners.
				info.removeEventListener(ModuleEvent.READY, onModuleReady);
				info.removeEventListener(ModuleEvent.ERROR, onModuleError);
				info.removeEventListener(ModuleEvent.PROGRESS, onModuleProgress);

				// Kill the timeout timer.
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;

				// Remove the load indicator.
				_main.rawChildren.removeChild(loadIndicator);

				module = info.factory.create(); // as LeaderBoardModule; // Non-SDG - don't cast to the specific module type
				if (gameType)
					module.init(ModelLocator.getInstance().avatar.id,gameType,index);
				else
					module.init(ModelLocator.getInstance().avatar.id);
				module.addEventListener('closeModule', onCloseModule);
				_main.rawChildren.addChild(module);
			}

			function onModuleProgress(e:ModuleEvent):void
			{
				// Restart the timeout timer.
				timer.reset();
				timer.start();
			}

			function onCloseModule(e:Event):void
			{
				// Remove event listener.
				module.removeEventListener('closeModule', onCloseModule);

				// Remove module from display.
				_main.rawChildren.removeChild(module);

				// Unload the module.
				info.unload();

				// Propagate the CloseModuleEvent
				_main.dispatchEvent(e);
			}
		}

		public static function openGameModule(gameId:int):void
		{
			var module:Object; // Non-SDG - remove the specific module type
			var info:IModuleInfo = ModuleManager.getModule('GameModule.swf');
			info.addEventListener(ModuleEvent.READY, onModuleReady);
			info.load(ApplicationDomain.currentDomain);

			function onModuleReady(e:ModuleEvent):void
			{
				info.removeEventListener(ModuleEvent.READY, onModuleReady);

				module = info.factory.create() // as GameModule; // Non-SDG - don't cast to the specific module type
				module.init(gameId);
				module.addEventListener('closeModule', onCloseModule);
				_main.rawChildren.addChild(module);
			}

			function onCloseModule(e:Event):void
			{
				// Remove event listener.
				module.removeEventListener('closeModule', onCloseModule);

				// Remove module from display.
				_main.rawChildren.removeChild(module);

				// Unload the module.
				info.unload();

				// Propagate the CloseModuleEvent
				_main.dispatchEvent(e);
			}
		}

		public static function openPrintShopModule(params:Object = null, moduleName:String = "PrintShopModule", displayName:String = 'Print Shop'):void
		{
			// Make sure the local user is registered.
			// If not, show the registration dialog.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			if (userAvatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}

//			if (getIsStoreModuleOpen(moduleName)) return;
//			setIsStoreModuleOpen(moduleName, true);

			// Load and show the print shop module.
			// Use a load indicator to let the user know
			// that something is happening.

			// Show load indicator.
			var loadIndicator:LoadIndicatorOverlay = new LoadIndicatorOverlay();
			loadIndicator.name = 'Loading Print Shop';
			_main.rawChildren.addChild(loadIndicator);

			var animationManager:AnimationManager = new AnimationManager();
			animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);

			var width:Number = _main.width;
			var height:Number = _main.height;

			var bitmapDataBuffer:BitmapData = new BitmapData(width, height, false);
			bitmapDataBuffer.draw(IBitmapDrawable(_main));
			var bitmap:TransitionBitmap = new TransitionBitmap(bitmapDataBuffer);
			bitmap.blurValue = 4;

			var whiteTint:Sprite = new Sprite();
			whiteTint.graphics.beginFill(0xffffff);
			whiteTint.graphics.drawRect(0, 0, width, height);
			whiteTint.alpha = 0;

			// Create a progress timer to keep track of how often progess occurs.
//			var progressTimeOut:uint = 3000;
//			var progressTimer:Timer = new Timer(progressTimeOut);
//			progressTimer.addEventListener(TimerEvent.TIMER, onProgressTimerInterval);

			var loader:ModuleLoader = new ModuleLoader();
			loader.url = moduleName + ".swf";
			loader.applicationDomain = ApplicationDomain.currentDomain;
			loader.addEventListener(ModuleEvent.READY, onModuleReady);
			loader.addEventListener(ModuleEvent.ERROR, onModuleError);
			loader.addEventListener(ModuleEvent.PROGRESS, onModuleProgress);
			loader.loadModule();

//			// Start the progress timer.
//			progressTimer.start();

			function onModuleReady(e:ModuleEvent):void
			{
				// Remove event listeners.
//				progressTimer.removeEventListener(TimerEvent.TIMER, onProgressTimerInterval);
//				progressTimer.reset();
				loader.removeEventListener(ModuleEvent.READY, onModuleReady);
				loader.removeEventListener(ModuleEvent.ERROR, onModuleError);
				loader.removeEventListener(ModuleEvent.PROGRESS, onModuleProgress);

				// Determine store id.
				// Default to 1.
				//var Id:uint = (params != null) ? params.Id as uint : 1;
				//if (storeId < 1) storeId = (RoomManager.getInstance().currentRoom.storeId > 0) ? RoomManager.getInstance().currentRoom.storeId : 1;

				// Get a reference to the store module.
				var printShopModule:Object = loader.child // as PrintShopModule; // Non-SDG - remove the specific module type and don't cast
				if (printShopModule != null) printShopModule.init();

				// Listen to module for a close event.
				loader.child.addEventListener('closeModule', onModuleClose);

				// Add the module to display.
				_main.rawChildren.addChild(bitmap);
				_main.rawChildren.addChild(whiteTint);
//				setIsStoreModuleOpen(moduleName, true);
				_main.mainLoader.visible = false;

				// Remove load indicator.
				_main.rawChildren.removeChild(loadIndicator);

				// calculate the zooming
				var scaleX:Number = 2;
				var scaleY:Number = 2;
				var zoomX:Number = width/2;
				var zoomY:Number = height/2;

				if (params)
				{
					if (params.hasOwnProperty("zoomX"))
						zoomX = params.zoomX;
					if (params.hasOwnProperty("zoomY"))
						zoomY = params.zoomY;
				}

				var moveX:Number = Math.min((scaleX * zoomX) - (width / 2), (scaleX * width) - width);
				var moveY:Number = Math.min((scaleY * zoomY) - (height / 2), (scaleY * height) - height);

				animationManager.property(whiteTint, 'alpha', 1, 200, Transitions.CUBIC_IN, RenderMethod.TIMER);
				animationManager.property(bitmap, 'scaleX', scaleX, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				animationManager.property(bitmap, 'x', -moveX, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				animationManager.property(bitmap, 'scaleY', scaleY, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				animationManager.property(bitmap, 'y', -moveY, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				animationManager.property(bitmap, 'blurValue', 50, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			}

			function onModuleError(e:ModuleEvent):void
			{
				// Remove event listeners.
//				progressTimer.removeEventListener(TimerEvent.TIMER, onProgressTimerInterval);
//				progressTimer.reset();
				loader.removeEventListener(ModuleEvent.READY, onModuleReady);
				loader.removeEventListener(ModuleEvent.ERROR, onModuleError);
				loader.removeEventListener(ModuleEvent.PROGRESS, onModuleProgress);

				handleModuleError();
			}

			function onModuleProgress(e:ModuleEvent):void
			{
				// Reset the progress timer.
//				progressTimer.reset();
//				progressTimer.start();
			}

			function onModuleClose(e:Event):void
			{
				// Remove event listener.
				loader.child.removeEventListener('closeModule', onModuleClose);

				// Remove module from display.
				_main.removeChild(loader);

				// Unload the module.
				loader.unloadModule();

//				setIsStoreModuleOpen(moduleName, false);
				_main.mainLoader.visible = true;

				// Clean up the animation manager.
				animationManager.removeAll();
				animationManager.dispose();
				animationManager = null;

				// Propagate the CloseModuleEvent
				_main.dispatchEvent(e);

//				setIsStoreModuleOpen(moduleName, false);
			}

			function handleModuleError():void
			{
//				setIsStoreModuleOpen(moduleName, false);
				_main.mainLoader.visible = true;

				// Remove load indicator.
				_main.rawChildren.removeChild(loadIndicator);

				// Dispatch a CloseModuleEvent
				_main.dispatchEvent(new Event('closeModule'));

				// Send an alert for the error.
				SdgAlertChrome.show('Sorry, there was an error loading the ' + displayName + '.', 'Error');

//				setIsStoreModuleOpen(moduleName, false);
			}

			/*
			function onProgressTimerInterval(e:TimerEvent):void
			{
				// Remove event listeners.
				progressTimer.removeEventListener(TimerEvent.TIMER, onProgressTimerInterval);
				progressTimer.reset();
				loader.removeEventListener(ModuleEvent.READY, onModuleReady);
				loader.removeEventListener(ModuleEvent.ERROR, onModuleError);
				loader.removeEventListener(ModuleEvent.PROGRESS, onModuleProgress);

				handleModuleError();
			}
			*/


			function onAnimationFinish(e:AnimationEvent):void
			{
				if (e.animTarget == bitmap && e.animProperty == "blurValue")
				{
					animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);

					_main.addChild(loader);
					_main.rawChildren.removeChild(bitmap);
					_main.rawChildren.removeChild(whiteTint);

					bitmap = null;
					whiteTint = null;
					bitmapDataBuffer.dispose();
					bitmapDataBuffer = null;
				}
			}

		}


		public static function openStoreModule(params:Object = null, moduleName:String = "StoreModule", displayName:String = 'Store', hideRoom:Boolean = false):void
		{
			// Make sure the local user is registered.
			// If not, show the registration dialog.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			if (userAvatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}

			if (getIsStoreModuleOpen(moduleName)) return;
			setIsStoreModuleOpen(moduleName, true);

			// Keep flag to determine if the room was hidden.
			var roomWasHidden:Boolean = false;

			// Load and show the store module.
			// Use a load indicator to let the user know
			// that something is happening.

			// Show load indicator.
			var loadIndicator:LoadIndicatorOverlay = new LoadIndicatorOverlay();
			loadIndicator.name = 'Loading Store';
			_main.rawChildren.addChild(loadIndicator);

			var animationManager:AnimationManager = new AnimationManager();
			animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);

			var width:Number = _main.width;
			var height:Number = _main.height;

			var bitmapDataBuffer:BitmapData = new BitmapData(width, height, false);
			bitmapDataBuffer.draw(IBitmapDrawable(_main));
			var bitmap:TransitionBitmap = new TransitionBitmap(bitmapDataBuffer);
			bitmap.blurValue = 4;

			var whiteTint:Sprite = new Sprite();
			whiteTint.graphics.beginFill(0xffffff);
			whiteTint.graphics.drawRect(0, 0, width, height);
			whiteTint.alpha = 0;

			// Create a progress timer to keep track of how often progess occurs.
			var progressTimeOut:uint = 3000;
			var progressTimer:Timer = new Timer(progressTimeOut);
			progressTimer.addEventListener(TimerEvent.TIMER, onProgressTimerInterval);

			var loader:ModuleLoader = new ModuleLoader();
			loader.url = moduleName + ".swf";
			loader.applicationDomain = ApplicationDomain.currentDomain;
			loader.addEventListener(ModuleEvent.READY, onModuleReady);
			loader.addEventListener(ModuleEvent.ERROR, onModuleError);
			loader.addEventListener(ModuleEvent.PROGRESS, onModuleProgress);
			loader.loadModule();

			// Start the progress timer.
			progressTimer.start();

			function onModuleReady(e:ModuleEvent):void
			{
				// Remove event listeners.
				progressTimer.removeEventListener(TimerEvent.TIMER, onProgressTimerInterval);
				progressTimer.reset();
				loader.removeEventListener(ModuleEvent.READY, onModuleReady);
				loader.removeEventListener(ModuleEvent.ERROR, onModuleError);
				loader.removeEventListener(ModuleEvent.PROGRESS, onModuleProgress);

				// Determine store id.
				// Default to 1.
				var storeId:uint = (params != null) ? params.storeId as uint : 1;
				//if (storeId < 1) storeId = (RoomManager.getInstance().currentRoom.storeId > 0) ? RoomManager.getInstance().currentRoom.storeId : 1;

				// Get a reference to the store module.
				var storeModule:Object = loader.child // as StoreModule; // Non-SDG - remove the specific module type and don't cast
				if (storeModule != null) storeModule.init(storeId);

				// Listen to module for a close event.
				loader.child.addEventListener('closeModule', onModuleClose);

				// Add the module to display.
				_main.rawChildren.addChild(bitmap);
				_main.rawChildren.addChild(whiteTint);
				setIsStoreModuleOpen(moduleName, true);
				_main.mainLoader.visible = false;

				// Remove load indicator.
				_main.rawChildren.removeChild(loadIndicator);

				// calculate the zooming
				var scaleX:Number = 2;
				var scaleY:Number = 2;
				var zoomX:Number = width/2;
				var zoomY:Number = height/2;

				if (params)
				{
					if (params.hasOwnProperty("zoomX"))
						zoomX = params.zoomX;
					if (params.hasOwnProperty("zoomY"))
						zoomY = params.zoomY;
				}

				var moveX:Number = Math.min((scaleX * zoomX) - (width / 2), (scaleX * width) - width);
				var moveY:Number = Math.min((scaleY * zoomY) - (height / 2), (scaleY * height) - height);

				animationManager.property(whiteTint, 'alpha', 1, 200, Transitions.CUBIC_IN, RenderMethod.TIMER);
				animationManager.property(bitmap, 'scaleX', scaleX, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				animationManager.property(bitmap, 'x', -moveX, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				animationManager.property(bitmap, 'scaleY', scaleY, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				animationManager.property(bitmap, 'y', -moveY, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				animationManager.property(bitmap, 'blurValue', 50, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			}

			function onModuleError(e:ModuleEvent):void
			{
				// Remove event listeners.
				progressTimer.removeEventListener(TimerEvent.TIMER, onProgressTimerInterval);
				progressTimer.reset();
				loader.removeEventListener(ModuleEvent.READY, onModuleReady);
				loader.removeEventListener(ModuleEvent.ERROR, onModuleError);
				loader.removeEventListener(ModuleEvent.PROGRESS, onModuleProgress);

				handleModuleError();
			}

			function onModuleProgress(e:ModuleEvent):void
			{
				// Reset the progress timer.
				progressTimer.reset();
				progressTimer.start();
			}

			function onModuleClose(e:Event):void
			{
				// Remove event listener.
				loader.child.removeEventListener('closeModule', onModuleClose);

				// Determine if we need to re-show the room.
				// while the store is open.
				if (roomWasHidden == true) RoomModule["SetRoomContainerVisible"](true); // Non-SDG - get the method with square brackets

				// Remove module from display.
				_main.removeChild(loader);

				// Unload the module.
				loader.unloadModule();

				setIsStoreModuleOpen(moduleName, false);
				_main.mainLoader.visible = true;

				// Clean up the animation manager.
				animationManager.removeAll();
				animationManager.dispose();
				animationManager = null;

				// Propagate the CloseModuleEvent
				_main.dispatchEvent(e);

				setIsStoreModuleOpen(moduleName, false);
			}

			function handleModuleError():void
			{
				setIsStoreModuleOpen(moduleName, false);
				_main.mainLoader.visible = true;

				// Remove load indicator.
				_main.rawChildren.removeChild(loadIndicator);

				// Dispatch a CloseModuleEvent
				_main.dispatchEvent(new Event('closeModule'));

				// Send an alert for the error.
				SdgAlertChrome.show('Sorry, there was an error loading the ' + displayName + '.', 'Error');

				setIsStoreModuleOpen(moduleName, false);
			}

			function onProgressTimerInterval(e:TimerEvent):void
			{
				// Remove event listeners.
				progressTimer.removeEventListener(TimerEvent.TIMER, onProgressTimerInterval);
				progressTimer.reset();
				loader.removeEventListener(ModuleEvent.READY, onModuleReady);
				loader.removeEventListener(ModuleEvent.ERROR, onModuleError);
				loader.removeEventListener(ModuleEvent.PROGRESS, onModuleProgress);

				handleModuleError();
			}

			function onAnimationFinish(e:AnimationEvent):void
			{
				if (e.animTarget == bitmap && e.animProperty == "blurValue")
				{
					animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);

					_main.addChild(loader);
					_main.rawChildren.removeChild(bitmap);
					_main.rawChildren.removeChild(whiteTint);

					// Determine if we should hide the room
					// while the store is open.
					if (hideRoom == true) roomWasHidden = RoomModule["SetRoomContainerVisible"](false); // Non-SDG - get the method with square brackets

					bitmap = null;
					whiteTint = null;
					bitmapDataBuffer.dispose();
					bitmapDataBuffer = null;
				}
			}
		}

		private static function getIsStoreModuleOpen(storeName:String):Boolean
		{
			return _isStoreModuleOpenArray[storeName] as Boolean;
		}
		private static function setIsStoreModuleOpen(storeName:String, isOpen:Boolean):void
		{
			_isStoreModuleOpenArray[storeName] = isOpen;
		}
	}
}
