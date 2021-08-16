package com.sdg.business
{
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.events.SocketEvent;
	import com.sdg.model.Server;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.net.socket.SocketEventFilter;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.rpc.IResponder;
	
	public class SdgSocketDelegate
	{
		public static const DEFAULT_TTL:uint = 10000; //20000;
		
		protected var responder:IResponder;
		protected var responseFilter:SocketEventFilter = new SocketEventFilter(responseHandler);
		protected var socketClient:SocketClient = SocketClient.getInstance();
		protected var ttlTimer:Timer = new Timer(DEFAULT_TTL, 1);
		
		public function SdgSocketDelegate(responder:IResponder):void
		{
			this.responder = responder;
			ttlTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timeoutHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Requests
		//
		//--------------------------------------------------------------------------
		
		public function connect(useFailover:Boolean = false):void
		{
			var s:Server = Server.getCurrent();
			if (s != null)
			{
				trace("SdgSocketDelegate socket domain         = " + s.domain + ":" +s.port);
				trace("SdgSocketDelegate socket failoverDomain = " + s.failoverDomain + ":" +s.failoverPort);
				trace("SdgSocketDelegate socket useFailover = " + s.useFailover);
				//SdgAlertChrome.show("domain "+ s.domain + " port " + s.port + " failDomain " + s.failoverDomain + " failPort " + s.failoverPort + " useFail " + useFailover, "elec");
				setup(SocketEvent.CONNECTION);
				//socketClient.connect(s.domain, s.port, s.failoverDomain, s.failoverPort, s.useFailover);
				socketClient.connect(s.domain, s.port, s.failoverDomain, s.failoverPort, useFailover);
			}
			else
				throw new Error("No socket servers defined");
		}
		
		public function login(username:String, password:String, avatarId:uint, serverId:uint):void
		{
			trace("username = " + username + " password = " + password + " avatarId = " + avatarId + " serverId = " + serverId);
			setup(SocketEvent.LOGIN);
			socketClient.login(username, password, avatarId, serverId);
		}
		
		public function loginWithHash(username:String, hash:String, avatarId:uint, serverId:uint):void
		{		
			trace("username = " + username + " hash = " + hash + " avatarId = " + avatarId + " serverId = " + serverId);
			setup(SocketEvent.LOGIN);
			socketClient.loginWithHash(username, hash, avatarId, serverId);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Response handlers
		//
		//--------------------------------------------------------------------------
		
		protected function responseHandler(event:SocketEvent):void
		{
			ttlTimer.stop();
			
			if (event.params.success)
				responder.result(event);
			else
				responder.fault(event);
		}
		
		protected function timeoutHandler(event:TimerEvent):void
		{
			trace("SdgSocketDelegate: Request timeout.");
			responseFilter.enabled = false;
			responder.fault(event);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Request invokation.
		//
		//--------------------------------------------------------------------------
		
		protected function setup(eventType:String, validParams:Object = null):void
		{
			responseFilter.eventType = eventType;
			responseFilter.validParams = validParams;
			responseFilter.enabled = true;
			ttlTimer.reset();
			ttlTimer.start();
		}
		
		protected function sendPlugin(pluginName:String, action:String, params:Object, validParams:Object = null):void							
		{
			if (!validParams) validParams = {};
			
			// Add default response validation params.
			validParams.pluginName = pluginName;
			validParams.action = action;
			
			// Setup.
			setup(SocketEvent.PLUGIN_EVENT, validParams);
			
			// Send plugin request.
			socketClient.sendPluginMessage(pluginName, action, params);
		}
	}
}