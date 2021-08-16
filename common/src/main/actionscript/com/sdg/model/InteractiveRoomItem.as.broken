package com.sdg.model
{
	import com.sdg.interactive.SDIE;
	import com.sdg.interactive.SDIEStompRocket;

	public class InteractiveRoomItem extends SdgItem
	{
		// Tommy McGlynn
		// tommymcglynn@gmail.com
		// This class will be used to define Interactive Room Items
		// for example a soccer ball that can be kicked around the room by users

		private static const ITEM_INFO_MAP:Object =
		{
			// these are defining classes is to be used dynamically
			interactiveStompRocket:{ definition:SDIEStompRocket, idField:"interactiveStompRocketId" }
		}

		private var objectClass:Class;
		public var interactiveObj:SDIE;


		public function InteractiveRoomItem()
		{
			super();
		}

		public function SetObjectClass(name:String):Class
		{
			var info:Object = ITEM_INFO_MAP[name];
			if (!info) throw new ArgumentError("Definition not found for 'name' " + name + ".");
			objectClass = info.definition;
			return objectClass;
		}


		public function get ObjectClass():Class { return objectClass; }

	}
}
