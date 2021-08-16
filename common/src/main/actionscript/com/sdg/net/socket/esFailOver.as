package com.sdg.net.socket
{
	import com.sdg.model.Server;
	import com.sdg.model.User;
	import com.sdg.utils.Constants;
	
	import flash.errors.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;

	/**
	* 
	* @author jmalbanese 01/29/09
	*	
	*   
	**/

	public class esFailOver
	{
	private static const TICK_TIME:uint = 100;			// state clock rate every .1 sec TICK_TIME ms
	private static const CONNECT_TICK_LIMIT:int =  100;	// nunmber of state clocks we allow before giving up

	// state machine vars
	private var _testTimer:Timer;
	private var _ticksToGo:int;							// countdown to failure decremented each state clock
	private var _testState:int;					// current state of test 

	// test states	
	private static const IDLE:int			= 0; // "IDLE";
	private static const CONNECT:int		= 1; // "Connecting to IP PORT 1";	
	private static const TESTING:int		= 2; // "Testing IP PORT 1";
	private static const TEST_COMPLETE:int	= 8; // "Test Complete, report results via callback";
	
	// operational vars
 	private var _socketOne:sdgSocket = null;
 	private var _callbackResult:Function = null;
 	private var _server:Server = null;
	private var _user:User = null;
	 	
 	// start a timer, hit the stateMachine every TICK_TIME ms
	public function startTimer():void
	{
    	_testTimer = new Timer(TICK_TIME, 0);	// 1 second ticker
        _testTimer.addEventListener(TimerEvent.TIMER, stateMachine);
        _testTimer.start();
	}

	public function stopTimer():void
	{
		_testTimer.removeEventListener(TimerEvent.TIMER, stateMachine );
		_testTimer = null;
	}

	//called every TICK_TIME interval, switches to current case
	//tests and update state on results
	 
  	private function stateMachine(event:TimerEvent):void
	{
//		trace("Timer Event... Test State = " + _testState );

		switch(_testState)
		{
			// do nothing
			case	IDLE :
			{
				break;
			};
			
			//attempt connection to port one
			case	CONNECT :		
			{
				_ticksToGo = CONNECT_TICK_LIMIT;
				_socketOne.connect();
				_testState = TESTING;
				break;
			}  

			//watch this port's connected var for true
			case	TESTING :			
			{
				if( _socketOne.getConnected() == true ) 		// we connected
				{
					trace( "socketOne reports connected" );
					_socketOne.close();
					_testState = TEST_COMPLETE;				// this test passed, we are done
				}
				else
				{	// timer tick came though before connect
					if( _ticksToGo-- < 0 )			// all out of tries?
					{
						trace( " Connect failed on " + _socketOne.getPort() );
						_socketOne.close();
						_testState = TEST_COMPLETE;		// test passed
					}
					else
					{
						trace( "Waiting for connect socket one ticksToGo " + _ticksToGo );
					}
				}
				break;
			}
			
			// shut down timer, remove the listeners etc.
			// set state to IDLE
			// call back with results
			
			case	TEST_COMPLETE :
			{
//				trace( "Test Complete " );
				stopTimer();			// turn off, remove listeners
				_testState = IDLE;		// stop all the action
				_socketOne.cleanup();	// clean up

				_server.useFailover = true;
				
				if (_socketOne.getConnected() == true ) // we got a connect
				{
					_server.useFailover = false;
				}

				// diagnostic - remove after debug
				if( _server.useFailover == true )
				{	trace("Primary Socket Failed " );		}
				else
				{ 	trace("Primary Socket Connected" );							}
				
				_callbackResult( _server, _user);
				break;
			}  
		}  
	}

	// create two sockets for our test 
	// set state to CONNECT_TO_1 to get things started
	// start the master clock
	// set socketResult to callback f() for results reporting on test completion
	public function startTest( server:Server, user:User, callbackResult:Function):void
	{
		_server = server;
		_user = user;
		_callbackResult = callbackResult;
		_socketOne = new sdgSocket(server.domain, server.port );
		_testState = CONNECT;
		startTimer();
	};

	}
}// ActionScript file
