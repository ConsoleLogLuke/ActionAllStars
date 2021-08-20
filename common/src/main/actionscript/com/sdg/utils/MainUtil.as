package com.sdg.utils
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.dialog.*;
	import com.sdg.events.ShowOverlayEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Server;
	import com.sdg.model.User;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.Socket;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.Timer;

	import mx.core.FlexGlobals; // Non-SDG - Application to FlexGlobals
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;

	public class MainUtil
	{
		private static var _navigateToMainCalled:Boolean = false;
		private static var _connectTestCount:int = 0;
		private static var _waitDialogLaunched:Boolean = false;
		private static var _testConnectSocket:Socket;

		public static function showDialog(dialogClass:Class, params:Object = null, modal:Boolean = true, center:Boolean = true):ISdgDialog
        {
        	var dialog:IFlexDisplayObject;

        	// debug testing per Molly
        	modal = false;
        	// END DEBUG

            if (modal)
            {
            	// we handle modal dialogs here to fix a bug in PopUpManager when scaling.  The bug is where the modal background
            	// is not sized correctly when the window is small the first time a modal dialog is called.
            	dialog = MainUtil.showModalDialog(dialogClass, params);
            }
            else
            {
	            dialog = PopUpManager.createPopUp(DisplayObject(FlexGlobals.topLevelApplication), dialogClass, modal);
	            //swf fit seems to be resizing the root and not the application
	            //dialog = PopUpManager.createPopUp(DisplayObject(FlexGlobals.topLevelApplication.root), dialogClass, modal);
	            if (center)
	            {
	            	MainUtil.centerPopUp(dialog);
	            	//PopUpManager.centerPopUp(dialog);
	            }
	            else
	            {
	                PopUpManager.bringToFront(dialog);
	            }

	            ISdgDialog(dialog).init(params);
            }

            return ISdgDialog(dialog);
        }

        public static function centerPopUp(popUp:IFlexDisplayObject):void
	    {
	    	PopUpManager.centerPopUp(popUp);
	    	return;
	    	//http://stackoverflow.com/questions/2065299/upgraded-to-flex-3-4-and-tried-3-5-popupmanager-centerpopup-broken
	        // If we don't find the pop owner or if the owner's parent is not specified or is not on the
	        // stage, then center based on the popUp's current parent.

	        var test:Object = popUp;


	        var popUpParent:DisplayObject = popUp.parent;

	        if(test.hasOwnProperty("owner"))
	        {
	        	popUpParent = test.owner.parent as DisplayObject;
	        }
	        if (popUpParent)
	        {
	        	 var pt:Point = new Point(0, 0);
			     pt = popUpParent.localToGlobal(pt); // Convert local 0,0 into global coordinate
			     pt = popUp.globalToLocal(pt); // Convert the result into local coordinate of myPop
			     popUp.move(Math.round((popUpParent.width - popup.width) / 2) + pt.x,
			      Math.round((popUpParent.height - popup.height) / 2) + pt.y);

	        }
	    }

        public static function reShowDialog(dialog:IFlexDisplayObject, modal:Boolean = true, center:Boolean = true):void
        {
        	if (modal)
        	{
        		showModalDialog(null, null, dialog);
        		return;
        	}

        	PopUpManager.addPopUp(dialog, DisplayObject(FlexGlobals.topLevelApplication), modal);

            if (center)
            	PopUpManager.centerPopUp(dialog);
            else
                PopUpManager.bringToFront(dialog);
        }

        public static function showModalDialog(dialogClass:Class, childParams:Object = null, createdDialog:IFlexDisplayObject = null):IFlexDisplayObject
        {
        	CairngormEventDispatcher.getInstance().dispatchEvent(new ShowOverlayEvent());

        	// create the modal base
            var modalDialog:ModalDialog = ModalDialog(PopUpManager.createPopUp(DisplayObject(FlexGlobals.topLevelApplication), ModalDialog));

            // have the modal dialog show the child dialog
            var childDialog:IFlexDisplayObject = modalDialog.init({dialogClass:dialogClass, childParams:childParams, createdDialog:createdDialog});

             // show the dialog
           	//PopUpManager.centerPopUp(IFlexDisplayObject(modalDialog));
           MainUtil.centerPopUp(modalDialog);

           // return the child dialog
           	return childDialog;

        	/*if(dialogClass == null)
        	{

	         }
	         else
	         {


	           	var dialog:IFlexDisplayObject = PopUpManager.createPopUp(DisplayObject(FlexGlobals.topLevelApplication), dialogClass);
	            //swf fit seems to be resizing the root and not the application
	            PopUpManager.centerPopUp(dialog);

	            ISdgDialog(dialog).init(childParams);
	           	return dialog;
	          }*/


        }

		/**
		 * failover test
		 * call failTester with server and user ( mirror args of old navigate to main )
		 * failover sets server.useFailover to "true" if the normal connect fails
		 * this is passed on to chatapp via the POST vars
		 * to disable
		 */
		public static function navigateToMain(server:Server, user:User = null, forceFailerOver:Boolean = false):void
		{
			trace("navigateToMain: forceFailerOver = " + forceFailerOver);

			if (forceFailerOver)
			{
				onTestConnectFail(null, server, user);
				return;
			}

			if (!_waitDialogLaunched)
			{
				var waitDialogTimer:Timer = new Timer(2000, 1);
				waitDialogTimer.addEventListener(TimerEvent.TIMER_COMPLETE, startWaitingDialog);
				waitDialogTimer.start();
			}

			var connectTimer:Timer = new Timer(3000, 1);
			connectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void {onTestConnectTimeout(event, server, user)});
			connectTimer.start();

			// create a socket for a test connection
			trace("testing socket connection on " + server.domain.toString() + ":" + server.port);

			_testConnectSocket = new Socket();
			_testConnectSocket.addEventListener(Event.CONNECT, function(event:Event):void {onTestConnectSuccess(event, server, user)});
			_testConnectSocket.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void {onTestConnectFail(event, server, user)});
			_testConnectSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:Event):void {onTestConnectFail(event, server, user)});
			_testConnectSocket.connect(server.domain, server.port);
		}

		private static function onTestConnectSuccess(event:Event, server:Server, user:User):void
		{
			trace("FailOver test succeeded");

			var socket:Socket = Socket(event.currentTarget);
			socket.removeEventListener(Event.CONNECT, arguments.callee);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, arguments.callee);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, arguments.callee);
			socket.close();

			server.useFailover = false;
			_navigateToMain(server, user);
		}

		private static function onTestConnectFail(event:Event, server:Server,  user:User):void
		{
			trace("FailOver test failed");
			if (event)
			{
				var socket:Socket = Socket(event.currentTarget);
				socket.removeEventListener(Event.CONNECT, arguments.callee);
				socket.removeEventListener(IOErrorEvent.IO_ERROR, arguments.callee);
				socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, arguments.callee);
			}

			server.useFailover = true;
			_navigateToMain(server, user);
		}

		private static function onTestConnectTimeout(event:TimerEvent, server:Server,  user:User):void
		{
			var timer:Timer = event.currentTarget as Timer;
			if (timer)
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, arguments.callee);

			_connectTestCount++;
			trace("TestConnectTimeout! - test count: " + _connectTestCount);

			if (_connectTestCount >= 3)
			{
				// fail the test - use failover
				onTestConnectFail(null, server, user);
			}
			else
			{
				// try the test connection again
				_testConnectSocket.removeEventListener(Event.CONNECT, arguments.callee);
				_testConnectSocket.removeEventListener(IOErrorEvent.IO_ERROR, arguments.callee);
				_testConnectSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, arguments.callee);

				navigateToMain(server, user);
			}
		}

		private static function startWaitingDialog(event:TimerEvent):void
		{
			_waitDialogLaunched = true;

			var timer:Timer = event.currentTarget as Timer;
			if (timer)
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, arguments.callee);

			// show the stars
        	var data:Object = new Object();
        	var _postStarsWaitingDialog:ISdgDialog;
        	data.swfPath = "swfs/preloader.swf";
        	trace( "posting stars");
        	_postStarsWaitingDialog = MainUtil.showDialog(OverlayDialog2, data, false, false);
        }

    	private static function _navigateToMain( server:Server, user:User = null):void
        {
        	// only call this once
        	if (_navigateToMainCalled)
        		return;

        	_navigateToMainCalled = true;

        	trace( "name             " + server.name);
			trace( "serverID         " + server.serverId);
			trace( "domain           " + server.domain);
			trace( "port     		 " + server.port);
			trace( "failover domain  " + server.failoverDomain);
			trace( "failover port    " + server.failoverPort);
			trace( "use Failover     " + server.useFailover);

			// goto ChatApp.jsp
			var request:URLRequest = new URLRequest('chatApp.jsp');
			request.method = URLRequestMethod.POST;

			// get all the user variables from login
			var variables:URLVariables = new URLVariables();


			if (user == null)
				user = ModelLocator.getInstance().user;

			variables.userId = user.userId;
			variables.userName = user.username;
			variables.password = user.password;
			variables.mainTutorialCount = user.mainTutorialCount;

			// server specifics
			variables.serverId = server.serverId;
			variables.name = server.name;
			variables.chatMode = server.chatMode;

			variables.domain = server.domain;					// as from physical server
			variables.port = server.port;						// as from physical server
			variables.failoverDomain = server.failoverDomain;	// as from physical server
			variables.failoverPort = server.failoverPort;		// as from physical server
			variables.useFailover = server.useFailover;			// "true" use failover domain:port
			variables.partnerId = ModelLocator.getInstance().affiliate;

			request.data = variables;

			navigateToURL(request,'_self');
		}

		public static function navigateToMonthFreePage(cc:int = 0):void
		{
			var request:URLRequest = new URLRequest("offerUpSale.jsp");
        	request.method = URLRequestMethod.POST;

			var variables:URLVariables = new URLVariables();

			variables.userId = ModelLocator.getInstance().avatar.userId;
			variables.avatarId = ModelLocator.getInstance().avatar.avatarId;
			variables.membershipStatus = ModelLocator.getInstance().avatar.membershipStatus;
			variables.partnerId = ModelLocator.getInstance().affiliate;

			if (cc != 0)
				variables.cc = cc;

			request.data = variables;
			navigateToURL(request,'_self');
		}

		public static function goToMVP(linkId:int,partnerId:int = -1):void
		{
			if (partnerId == -1)
			{
				goToUrl("membership.jsp", {linkId:linkId, avatarId:ModelLocator.getInstance().avatar.avatarId});
			}
			else
			{
				goToUrl("membership.jsp", {linkId:linkId, avatarId:ModelLocator.getInstance().avatar.avatarId, partnerId:partnerId});
			}
		}

		public static function goToUrl(url:String, params:Object = null, window:String = "_self"):void
		{
			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.POST;

			var variables:URLVariables = new URLVariables();

			variables.partnerId = ModelLocator.getInstance().affiliate;

			if (params != null)
			{
				for (var obj:Object in params)
					variables[obj] = params[obj];
			}

			request.data = variables;
			navigateToURL(request, window);
		}

		public static function postAvatarIdToURL(url:String, avatarId:int = 0, cc:int = 0):void
        {
        	var request:URLRequest = new URLRequest(url);
        	request.method = URLRequestMethod.POST;

			var variables:URLVariables = new URLVariables();

			if (avatarId == 0)
			{
				avatarId = ModelLocator.getInstance().avatar.avatarId;

				// if avatarId is still 0, then just navigate to URL
				if (avatarId != 0)
				{
					if (ModelLocator.getInstance().avatar.membershipStatus == 3)
						variables.guestId = avatarId;
					else
						variables.avatarId = avatarId;
				}
			}
			else
				variables.avatarId = avatarId;

			// add the partner id
			variables.partnerId = ModelLocator.getInstance().affiliate;

			if (cc != 0)
				variables.cc = cc;

			request.data = variables;

			navigateToURL(request,'_self');
		}
	}
}
