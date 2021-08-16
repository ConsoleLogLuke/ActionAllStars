package com.sdg.net.socket
{
	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	import flash.net.XMLSocket;
    import flash.system.Security;

	import com.sdg.utils.Constants;

	public class sdgSocket
	{
		private var _connected:Boolean;		// T == connected
		private var _closed:Boolean;		// T == closed
		private var _socket:XMLSocket;
	    private var response:String;
	    
	    private var _url:String;
	    private var _port:int;
	
		public function sdgSocket( url:String, port:int )
		{
		 	_socket = new XMLSocket(null, 0 );
			_url = url;
			_port = port;
			_connected = false;
			_closed = false;
			addListeners();
		}

		public function getPort():int
		{
			return(_port);
		}
		
		public function getUrl():String
		{
			return(_url);
		}

		public function getConnected():Boolean
		{
			return _connected;
		}

		public function getClosed():Boolean
		{
			return _closed;
		}
		
		public function connect():void
		{

			try {
				_socket.connect(  _url, _port );
			}catch( e:Error ){
				trace( "Failover Socket Connect " + e.message );
			}
			
		};


		public function close():void
		{
			if( _connected == true )
			{
				try
				{
					_socket.close();
				} catch( e:Error ) {
					trace( "Failover Socket Close " + e.message );
				}						
			}
		};


		public function cleanup():void
		{
			removeListeners();
			_socket = null;
		}

		private function addListeners():void
		{
    		_socket.addEventListener(Event.CLOSE, closeHandler);
       		_socket.addEventListener(Event.CONNECT, connectHandler);
       		_socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
       		_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}

		private function removeListeners():void
		{
    		_socket.removeEventListener(Event.CLOSE, closeHandler);
       		_socket.removeEventListener(Event.CONNECT, connectHandler);
       		_socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
       		_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}


   		private function closeHandler(event:Event):void 
   		{
        	_closed = true;
//        	trace("closeHandler: " + _url  + " " + _port + " " + event);
//        	trace(response.toString());
   		}

	    private function connectHandler(event:Event):void 
	    {
    		_connected = true;
//    		trace("connectHandler: "  + _url + " " + _port + " " + event);
//s	       	var str:String = _socket.readUTFBytes(_socket.bytesAvailable);
//s	       	_socket.flush();
//	        trace( "bytes read " + str);
    	}

   
    	private function ioErrorHandler(event:IOErrorEvent):void 
    	{
        	trace("failover ioErrorHandler: "  + _url + " " + _port + " " + event);
    	}

		private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
	       	 trace("faileover securityErrorHandler: "  + _url + " " + _port + " " + event);
	    }
   
 }
}