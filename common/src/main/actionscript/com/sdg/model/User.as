package com.sdg.model
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class User
	{
		public var username:String;
		public var password:String;
		public var email:String;
		public var userId:uint;
		public var loggedInStatus:int;
		public var isSocketLoggedIn:Boolean;
		public var avatarId:uint;
		public var currentRoomId:int;
		public var firstUser:int;			// non zero on first entry to world
		public var mainTutorialCount:int;	// show world tutorial if count < Constants.TUTORIAL_LIMIT
		public var hash:String;
		public var avatars:ArrayCollection = new ArrayCollection();
		public var lastEditionId:uint;
		public var userEditionId:uint;
		//public var showTos:int;
		//public var freeMonthEligible:Boolean;
	}
}