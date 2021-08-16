/**
* ...
* @author Lance Sanders
* @version 0.1
*/
package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;

	public class LoginEvent extends CairngormEvent
	{
		public static const LOGIN:String = "login";
		public static const MVPLOGIN:String = "mvp login";
		
		public var username:String;
		public var password:String;
		public var linkId:int;
		public var planId:int;
		public var paymentMethodId:int;
		
		public function LoginEvent(username:String, password:String, linkId:int = 0, planId:int = 0, paymentMethodId:int = 0, type:String = LOGIN)
		{
			super(type);
			this.username = username;
			this.password = password;
			this.linkId = linkId;
			this.planId = planId;
			this.paymentMethodId = paymentMethodId;
		}
	}
}