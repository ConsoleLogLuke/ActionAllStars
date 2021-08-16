package com.sdg.model
{
	import com.sdg.utils.Constants;
	
	import flash.geom.Point;
	
	public class HardCodedExitPoints extends Object
	{
		public static function GetHardCodedExitPoint(fromRoomId:String, toRoomId:String):Point
		{
			switch (fromRoomId)
			{
				case Constants.ROOM_ID_RIVERWALK:
					if (toRoomId == Constants.ROOM_ID_AASTORE)
						return new Point(12, 9);
					else if (toRoomId == Constants.ROOM_ID_JOE_BOSE_PARK)
						return new Point(17, 10);
					else if (toRoomId == Constants.ROOM_ID_BROADCAST_CENTER)
						return new Point(10, 10);
					else if (toRoomId == Constants.ROOM_ID_BLAKES_PLACE)
						return new Point(8, 12);
					break;
				case Constants.ROOM_ID_AASTORE:
					if (toRoomId == Constants.ROOM_ID_RIVERWALK)
						return new Point(7, 10);
					break;
				case Constants.ROOM_ID_BALLERS_HALL:
					if (toRoomId == Constants.ROOM_ID_THREE_POINT_COURT)
						return new Point(2, 5);
					else if (toRoomId == Constants.ROOM_ID_NBA_SHOP)
						return new Point(4, 11);
					break;
				case Constants.ROOM_ID_NBA_SHOP:
					if (toRoomId == Constants.ROOM_ID_BALLERS_HALL)
						return new Point(14, 5);
					break;
				case Constants.ROOM_ID_HOME_TURF_LEGACY: // home turf
					if (toRoomId == Constants.ROOM_ID_RIVERWALK)
						return new Point(8, 14);
					break;
				case Constants.ROOM_ID_HOME_TURF_AM: // home turf
					if (toRoomId == Constants.ROOM_ID_RIVERWALK)
						return new Point(13, 16);
					break;
				case Constants.ROOM_ID_HOME_TURF_RO: // home turf
					if (toRoomId == Constants.ROOM_ID_RIVERWALK)
						return new Point(11, 17);
					break;
				case Constants.ROOM_ID_HOME_TURF_PRO: // home turf
					if (toRoomId == Constants.ROOM_ID_RIVERWALK)
						return new Point(13, 20);
					break;
				case Constants.ROOM_ID_HOME_TURF_VET: // home turf
					if (toRoomId == Constants.ROOM_ID_RIVERWALK)
						return new Point(9, 14);
					break;
				case Constants.ROOM_ID_HOME_TURF_ASTAR: // home turf
					if (toRoomId == Constants.ROOM_ID_RIVERWALK)
						return new Point(9, 17);
					break;
				case Constants.ROOM_ID_THE_BEND:
					if (toRoomId == Constants.ROOM_ID_BALLERS_PLAZA)
						return new Point(6, 13);
					break;
				case Constants.ROOM_ID_BALLERS_PLAZA:
					if (toRoomId == Constants.ROOM_ID_BALLERS_HALL)
						return new Point(15, 19);
					else if (toRoomId == Constants.ROOM_ID_DIAMONDS_RUN)
						return new Point(18, 11);
					break;
				case Constants.ROOM_ID_DIAMONDS_RUN:
					if (toRoomId == Constants.ROOM_ID_MLB_SHOP)
						return new Point(22, 14);
					else if (toRoomId == Constants.ROOM_ID_AAField)
						return new Point(10, 11);
					break;
				case Constants.ROOM_ID_MLB_SHOP:
					if (toRoomId == Constants.ROOM_ID_DIAMONDS_RUN)
						return new Point(7, 7);
					break;
				case Constants.ROOM_ID_VERT_VILLAGE:
					if (toRoomId == Constants.ROOM_ID_BEACHSIDE)
						return new Point(12, 10);
					else if (toRoomId == Constants.ROOM_ID_THE_PEAK)
						return new Point(11, 17);
					else if (toRoomId == Constants.ROOM_ID_MAVERICKS)
						return new Point(11, 13);
					else if (toRoomId == Constants.ROOM_ID_VERT_VILLAGE_SHOP)
						return new Point(18, 11);
					break;
				case Constants.ROOM_ID_MAVERICKS:
					if (toRoomId == Constants.ROOM_ID_VERT_VILLAGE)
						return new Point(9, 19);
					break;
				case Constants.ROOM_ID_THE_PEAK:
					if (toRoomId == Constants.ROOM_ID_VERT_VILLAGE)
						return new Point(6, 3);
					break;
				case Constants.ROOM_ID_JOE_BOSE_PARK:
					if (toRoomId == Constants.ROOM_ID_FOOTBALL_FIELD)
						return new Point(8, 3);
					break;
				case Constants.ROOM_ID_BLAKES_PLACE:
					if (toRoomId == Constants.ROOM_ID_RIVERWALK)
						return new Point(8, 8);
					break;
				default:
					return null;
					break;				
			}
			
			return null;
		}
		
	}
}