package com.sdg.business
{
	import com.sdg.factory.IXMLObjectFactory;
	import com.sdg.utils.Constants;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import mx.rpc.IResponder;
	
	public class SdgServiceResponder implements IResponder
	{
		private var response:SdgServiceResponse;
		private var resultHandler:Function;
		private var faultHandler:Function;
		private var resultFactory:IXMLObjectFactory;
		private var key:Object;
		
		/**
		 *	Constructor.
		 */
		public function SdgServiceResponder(resultHandler:Function, faultHandler:Function, resultFactory:IXMLObjectFactory = null, key:Object = null):void
		{
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
			this.resultFactory = resultFactory;
			this.key = key;
		}
		
		public function fault(info:Object):void
		{
			trace("SdgServiceResponder: A Fault occurred.", "Fault=" + info);
			invokeFault(<SDGResponse status="0"></SDGResponse>);
		}
		
		public function result(event:Object):void
		{
			response = new SdgServiceResponse(event.result);
			
			// Validate the status code.\
			switch (response.status)
			{
				case Constants.SERVER_RESPONSE_NORMAL:
				case Constants.SERVER_RESPONSE_ALREADY_CHOOSE_TODAY:
					// Create a result with the resultFactory if it exists.
					if (resultFactory != null)
					{
						try
						{
							resultFactory.setXML(response.data);
							invokeResult(resultFactory.createInstance());
						}
						catch(error:Error)
						{
							trace("SdgServiceResponder: Error creating factory instance.", "Error=" + error, "Data=" + response.data);
							invokeFault(response.data);
						}
					}
					else
					{
						// Invoke the result handler with the raw data.
						invokeResult(response.data);
					}					
					break;
				default:
					trace("SdgServiceResponder: Invalid status.", "Status=" + response.status);
					invokeFault(response.data);
					break;
						
			}
//			if (response.status == 1)
//			{
//				// Create a result with the resultFactory if it exists.
//				if (resultFactory != null)
//				{
//					try
//					{
//						resultFactory.setXML(response.data);
//						invokeResult(resultFactory.createInstance());
//					}
//					catch(error:Error)
//					{
//						trace("SdgServiceResponder: Error creating factory instance.", "Error=" + error, "Data=" + response.data);
//						invokeFault(response.data);
//					}
//				}
//				if (Constants.ALLREADY_CHOSEN)
//				{
//					
//				}
//				// Invoke the result handler with the raw data.
//				else
//				{
//					invokeResult(response.data);
//				}
//			}
//			// A Server-side fault occurred if the status is not 1.
//			else
//			{
//				trace("SdgServiceResponder: Invalid status.", "Status=" + response.status);
//				invokeFault(response.data);
//			}
		}
		
		/**
		 *	Passes the result data to the resultHandler.
		 */
		protected function invokeResult(data:Object):void
		{
			resultHandler(data, key);
		}
		
		/**
		 *	Passes the fault info to the faultHandler.
		 */
		protected function invokeFault(info:Object):void
		{
			faultHandler(info, key);
		}
	}
}