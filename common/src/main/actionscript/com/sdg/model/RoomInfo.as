package com.sdg.model
{
	public class RoomInfo extends Object
	{
		public var id:String;
		public var name:String;
		public var numAvatars:int;
		public var maxAvatars:Number;
		
		public function RoomInfo(id:String, name:String, numAvatars:int = 0, maxAvatars:int = 30)
		{
			super();
			
			this.id = id;
			this.name = name;
			this.numAvatars = numAvatars;
			this.maxAvatars = maxAvatars;
		}
		
	}
}