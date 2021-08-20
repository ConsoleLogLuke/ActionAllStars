package com.sdg.model
{
	public class NotificationIcon
	{
		public static const GENERIC:int = 0;
		public static const RWS:int = 2;
		public static const BUDDY:int = 3;

		private static const ICON_BORDER_MAP:Object =
		{
			0:{icon:"swfs/hud/generic.swf"},
			2:{icon:"swfs/hud/rws.swf"},
			3:{icon:"swfs/hud/buddy.swf"}
		};

		public static function getIcon(type:int = 0):Object
		{
			var icon:Object = ICON_BORDER_MAP[type];

			if (icon == null)
				icon = ICON_BORDER_MAP[0];

			return icon;
		}
	}
}
