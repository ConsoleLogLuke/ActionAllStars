package com.sdg.utils
{
	public class Constants
	{
		public static const MAX_TURF_ITEMS:int = 100;
		
		public static const RBI_GAME_ID:int = 51;
		public static const TOP_SHOT_GAME_ID:int = 52;
		public static const NFL_PA_PUZZLE_1_GAME_ID:int = 53;
		public static const NFL_PA_PUZZLE_2_GAME_ID:int = 54;
		public static const NFL_PA_PUZZLE_3_GAME_ID:int = 55;
		public static const SINGLEPLAYER_MISSION1_GAME_ID:int = 56;
		public static const ROCK_JENGA_GAME_ID:int = 60;
		public static const COMBO_LOCK_GAME_ID:int = 61;
		public static const ZOMBIE_BOSS_GAME_ID:int = 62;
		public static const KICKER_TRY_OUT_GAME_ID:int = 64;
		public static const NBA_ALLSTARS_GAME_ID:int = 65;
		
		public static const HOOPS_GAME_ID:int = 11;
		public static const SNOWBOARDING_GAME_ID:int = 12;
		public static const SURFING_GAME_ID:int = 13;
		public static const BITES_GAME_ID:int = 14;
		public static const THREE_GAME_ID:int = 15;
		public static const HANDLES_GAME_ID:int = 16;
		public static const PITCHING_ACE_GAME_ID:int = 17;
		public static const BUMPER_BASEBALL_GAME_ID:int = 18;
		public static const QB_CHALLENGE_GAME_ID:int = 21;
		
		// Feature toggles.
		public static const FANDAMONIUM_ENABLED:Boolean = true;
		public static const PDA_ENABLED:Boolean = true;
		public static const SWF_SPRITES_ENABLED:Boolean = false;
		public static const PETS_ENABLED:Boolean = true;
		
		public static const QUEST_ENABLED:Boolean = true;
		public static const GAME_CAST_RECORDING_ENABLED:Boolean = false;
		
	    // enable/disable socket trace update messages
	    public static const ENABLE_SOCKET_TRACE_MESSAGES:Boolean = false;

		// time to show chat bubble in ms
	    public static const CHATBUBBLE_TIMEOUT:int = 6000;
	    
	    public static const OVERHEAD_MESSAGE_TIMEOUT:int = 1000;
	    
	    // avatar walk speed
   		public static const DEFAULT_WALK_SPEED:Number = .0032;

	    // on/off world tutorial values
	    public static const TUTORIAL_ON:int = 0;
	    public static const TUTORIAL_OFF:int = 6;
		// AvatarStat ID for tutorial reset value type
	    public static const MAIN_TUTORIAL:int = 7;
	 
	 	public static const MEMBER_STATUS_FREE:int = 0;
	 	public static const MEMBER_STATUS_PREMIUM_CANCELLED:int = 1;
	 	public static const MEMBER_STATUS_PREMIUM:int = 2;
	 	public static const MEMBER_STATUS_GUEST:int = 3;
	 	
	 	// item set ids
	 	public static const APPAREL_SET_ID_SKATEBOARDING:int = 1000;
	 	  
	    // avatar spritesheet layers
		public static const LAYER_SKIN:int = 1000;
		public static const LAYER_EYES:int = 1320;
		public static const LAYER_MOUTH:int = 1340;
		public static const LAYER_SHIRT_LOWER:int = 1100;
		public static const LAYER_ACCESSORY_LOWER:int = 1120;
		public static const SPRITESHEET_PRIORITY_SHOES_LOWER:int = 1125;
		public static const SPRITESHEET_PRIORITY_SHOES_UPPER:int = 1130;
		public static const SPRITESHEET_PRIORITY_PANTS:int = 1150;
		public static const LAYER_SHIRT_TORSO:int = 1200;
		public static const LAYER_SHOES_LOWER:int = 1360;
		public static const LAYER_SHOES_UPPER:int = 1440;    
		public static const LAYER_PANTS:int = 1400;          
		public static const LAYER_GLASSES:int = 1480;
		public static const LAYER_HAIR:int = 1500;           // HAIR A 
		public static const LAYER_HAIR_WITH_HAT:int = 1501;  // HAIR B
		public static const LAYER_HAIR_C:int = 1502;
		public static const LAYER_HAIR_D:int = 1503;
		public static const LAYER_HAIR_E:int = 1504;
		public static const LAYER_HAT:int = 1540;
		public static const LAYER_SHIRT_UPPER:int = 1600;
		public static const LAYER_ACCESSORY_UPPER:int = 1620;

	    // skateboarding avatar spritesheet layers
		public static const LAYER_SKIN_SKATEBOARDING:int = 5000;
		public static const LAYER_SHIRT_LOWER_SKATEBOARDING:int = 5100;
		public static const LAYER_SHOES_LOWER_SKATEBOARDING:int = 5200;
		public static const LAYER_SHOES_UPPER_SKATEBOARDING:int = 5300;
		public static const LAYER_PANTS_SKATEBOARDING:int = 5400;
		public static const LAYER_SHIRT_TORSO_SKATEBOARDING:int = 5500;
		public static const LAYER_GLASSES_SKATEBOARDING:int = 5550;
		public static const LAYER_HAIR_SKATEBOARDING:int = 5600;
		public static const LAYER_HEADGEAR_SKATEBOARDING:int = 5700;
		public static const LAYER_SHIRT_UPPER_SKATEBOARDING:int = 5800;
		
		public static const LAYER_SUIT:int = 5900;
		
		public static const AVATAR_SPRITESHEET_COLS:int = 3;
		public static const AVATAR_SPRITESHEET_ROWS:int = 5;
		
		// SDGResponse Codes		
		public static const SERVER_RESPONSE_NORMAL:int = 1;
		public static const SERVER_RESPONSE_GENERIC_ERROR:int = 0;
		public static const SERVER_RESPONSE_AVATAR_BANNED:int = 100;
		public static const SERVER_RESPONSE_LOGIN_INVALID_CREDENTIALS:int  = 101;
		public static const SERVER_RESPONSE_LOGIN_REGISTRATION_INCOMPLETE:int = 102;
		public static const SERVER_RESPONSE_LOGIN_NAME_REJECTED:int = 103;
		public static const	SERVER_RESPONSE_LOGIN_NOT_ACTIVATED:int = 104;
		public static const	SERVER_RESPONSE_HASH_REJECTED:int = 201;
		public static const	SERVER_RESPONSE_BUILDER_NOCLOTHING:int = 301;
		public static const SERVER_RESPONSE_FREEREG_USERNAME_TAKEN:int = 401;
		public static const SERVER_RESPONSE_FREEREG_PASSWORD_INVALID:int = 402; 
		public static const SERVER_RESPONSE_FREEREG_USERNAME_INVALID:int = 403; 
		public static const SERVER_RESPONSE_FREEREG_PARENT_EMAIL_NOT_EXISTS:int = 405;
		public static const	SERVER_RESPONSE_AVATAR_ALREADY_ACTIVATED:int = 406; 
		public static const SERVER_RESPONSE_NON_EXISTING_AVATAR:int = 407;
		public static const SERVER_RESPONSE_INVALID_CIPHER_PARAMETER:int = 408;
		public static const SERVER_RESPONSE_INVALID_AVATAR_PARAMETER:int = 409;
		public static const SERVER_RESPONSE_USERNAME_EMAIL_DOES_NOT_MATCH:int = 410; 
		public static const SERVER_RESPONSE_ERROR_SENDING_EMAIL:int = 411;
		public static const	SERVER_RESPONSE_NOT_ENOUGH_TOKENS:int = 500;
		public static const SERVER_RESPONSE_CHANGE_SUCCESS:int = 412; 
		public static const SERVER_RESPONSE_CHANGE_FAILURE:int = 413; 
		public static const SERVER_RESPONSE_OLD_EMAIL_FAILURE:int = 414; 
		public static const SERVER_RESPONSE_ALREADY_CHOOSE_TODAY:int = 415;
		
		// room types
		public static const ROOM_TYPE_RWS:int = 6;
		
		// payment types
		public static const CREDIT_CARD:uint = 1;
		public static const PAYPAL:uint = 2;
		
		// avatar level colors
		public static const LEVEL_COLOR_AMATEUR:uint = 0xffffff;
		public static const LEVEL_COLOR_ROOKIE:uint = 0x1a3c69;
		public static const LEVEL_COLOR_PRO:uint = 0x9f091e;
		public static const LEVEL_COLOR_VETERAN:uint = 0xe2a000;
		public static const LEVEL_COLOR_ALLSTAR:uint = 0x000000;
		
		public static const LEVEL_COLOR_AMATEUR_TEXT:uint = 0x4376b7;
		public static const LEVEL_COLOR_ROOKIE_TEXT:uint = 0xffffff;
		public static const LEVEL_COLOR_PRO_TEXT:uint = 0xffffff;
		public static const LEVEL_COLOR_VETERAN_TEXT:uint = 0x382700;
		public static const LEVEL_COLOR_ALLSTAR_TEXT:uint = 0xe2a000;
		
		// Room Ids
		public static const ROOM_ID_RIVERWALK:String = "public_101";
		public static const ROOM_ID_THE_BEND:String = "public_102";
		public static const ROOM_ID_JOE_BOSE_PARK:String = "public_103";
		public static const ROOM_ID_AASTORE:String = "public_105";
		public static const ROOM_ID_HOME_TURF_LEGACY:String = "public_106";
		public static const ROOM_ID_BALLERS_HALL:String = "public_107";
		public static const ROOM_ID_NBA_SHOP:String = "public_108";
		public static const ROOM_ID_BALLERS_PLAZA:String = "public_109";
		public static const ROOM_ID_DIAMONDS_RUN:String = "public_110";
		public static const ROOM_ID_THREE_POINT_COURT:String = "public_111";
		public static const ROOM_ID_MLB_SHOP:String = "public_113";
		public static const ROOM_ID_VERT_VILLAGE:String = "public_114";
		public static const ROOM_ID_AAField:String = "public_115";
		public static const ROOM_ID_VERT_VILLAGE_SHOP:String = "public_116";
		public static const ROOM_ID_THE_PEAK:String = "public_117";
		public static const ROOM_ID_BEACHSIDE:String = "public_118";
		public static const ROOM_ID_MAVERICKS:String = "public_119";
		public static const ROOM_ID_TRADING_CARD_LOBBY:String = "public_120";
		public static const ROOM_ID_FOOTBALL_FIELD:String = "public_121";
		public static const ROOM_ID_TRIVIA:String = "public_122";
		//public static const ROOM_ID_BROADCAST_CENTER_2:String = "public_123";
		//public static const ROOM_ID_BROADCAST_CENTER_3:String = "public_124";
		//public static const ROOM_ID_BROADCAST_CENTER_4:String = "public_125";
		//public static const ROOM_ID_BROADCAST_CENTER_5:String = "public_126";
		//public static const ROOM_ID_BROADCAST_CENTER_6:String = "public_127";
		//public static const ROOM_ID_BROADCAST_CENTER_7:String = "public_128";
		public static const ROOM_ID_BROADCAST_CENTER:String = "public_129";
		//public static const ROOM_ID_TRIVIA_ROOM:String = "public_130";
		public static const ROOM_ID_SPORTS_PSYCHIC:String = "public_131";
		//public static const ROOM_ID_PICKEM_ROOM_2:String = "public_132";
		//public static const ROOM_ID_PICKEM_ROOM_3:String = "public_133";
		//public static const ROOM_ID_PICKEM_ROOM_4:String = "public_134";
		public static const ROOM_ID_HOME_TURF_AM:String = "public_137";
		public static const ROOM_ID_HOME_TURF_RO:String = "public_138";
		public static const ROOM_ID_HOME_TURF_PRO:String = "public_139";
		public static const ROOM_ID_HOME_TURF_VET:String = "public_140";
		public static const ROOM_ID_HOME_TURF_ASTAR:String = "public_141";
		public static const ROOM_ID_BLAKES_PLACE:String = "public_142";
		public static const ROOM_ID_RBI:String = "public_143";
		
		public static const ROOM_ID_MINIMAZE_PRIZE_ROOM_G:String = "public_1136";
		public static const ROOM_ID_BULLPEN:String = "public_149";
		public static const ROOM_ID_PET_SHOP:String = "public_153";
		
		// UI EVENT CODES
		//public static const UI_EVENT_UPDATE_ROOM_AVATAR_SPRITESHEET_I_THINK:uint = 1;
		//public static const UI_EVENT_UNKNOWN_USED_IN_STORE_CONTROLLER:uint = 2;
		//public static const UI_EVENT_UNKNOWN_USED_ON_STORE_PURCHASE_SUCCESS:uint = 3;
		//public static const UI_EVENT_USED_IN_PDA_CONTROLLER:uint = 4;
		//public static const UI_EVENT_USED_IN_SAVE_YOUR_GAME_DIALOG:uint = 5;
		public static const UI_EVENT_PRINT_SHOP_PRINT_EVENT:uint = 6;

		// SDG CLASS ENUMERATION
		public static const ENUM_APPLICATION_CONFIGURATION_COMMAND:uint = 1;
		public static const ENUM_AVATAR_APPAREL_COMMAND:uint = 2;
		public static const ENUM_AVATAR_APPAREL_SAVE_COMMAND:uint = 3;
		public static const ENUM_AVATAR_COMMAND:uint = 4;
		public static const ENUM_AVATAR_LIST_COMMAND:uint = 5;
		public static const ENUM_AVATAR_STAT_COMMAND:uint = 6;
		public static const ENUM_BUDDY_LIST_COMMAND:uint = 7;
		public static const ENUM_BUTTON_CLICK_LOGGING_COMMAND:uint = 8;
		public static const ENUM_CHALLENGES_COMMAND:uint = 9;
		public static const ENUM_CHANGE_CHAT_MODE_COMMAND:uint = 10;
		public static const ENUM_CHANGE_NEWSLETTER_OPTION_COMMAND:uint = 11;
		public static const ENUM_CHANGE_PASSWORD_COMMAND:uint = 12;
		public static const ENUM_GAME_ATTRIBUTES_COMMAND:uint = 13;
		public static const ENUM_GAME_RESULT_COMMAND:uint = 14;
		public static const ENUM_GET_ALBUM_CARDS_COMMAND:uint = 15;
		public static const ENUM_GET_ASN_COMMAND:uint = 16;
		public static const ENUM_GET_BILL_DATE_COMMAND:uint = 17;
		public static const ENUM_GET_EMOTES_COMMAND:uint = 18;
		public static const ENUM_GET_FAV_TEAMS_COMMAND:uint = 19;
		public static const ENUM_GET_ITEM_SETS_COMMAND:uint = 20;
		public static const ENUM_GET_JABS_COMMAND:uint = 21;
		public static const ENUM_GET_KIOSK_CARDS_COMMAND:uint = 22;
		public static const ENUM_GET_SEASONAL_COMMAND:uint = 23;
		public static const ENUM_GET_STATS_COMMAND:uint = 24;
		public static const ENUM_GET_TEAMS_COMMAND:uint = 25;
		public static const ENUM_GET_UNITY_NBA_TEAMS_COMMAND:uint = 26;
		public static const ENUM_GUEST_ACCOUNT_COMMAND:uint = 27;
		public static const ENUM_INVENTORY_ATTRIBUTE_SAVE_COMMAND:uint = 28;
		public static const ENUM_INVENTORY_LIST_COMMAND:uint = 29;
		public static const ENUM_ITEM_PURCHASE_COMMAND:uint = 30;
		public static const ENUM_ITEM_TYPE_LIST_COMMAND:uint = 31;
		public static const ENUM_LOGIN_COMMAND:uint = 32;
		public static const ENUM_MVP_LOGIN_COMMAND:uint = 33;
		public static const ENUM_MVP_LOG_PROCESS_COMMAND:uint = 34;
		public static const ENUM_PAY_BY_PAY_PAL_COMMAND:uint = 35;
		public static const ENUM_PICKEM_SCORECARD_COMMAND:uint = 36;
		public static const ENUM_PRIVATE_ROOM_EDIT_COMMAND:uint = 37;
		public static const ENUM_REGISTRATION_SAVE_COMMAND:uint = 38;
		public static const ENUM_RESEND_ACTIVATION_COMMAND:uint = 39;
		public static const ENUM_ROOM_CHECK_COMMAND:uint = 40;
		public static const ENUM_ROOM_NAVIGATE_COMMAND:uint = 41;
		public static const ENUM_SAVE_FAV_TEAMS_COMMAND:uint = 42;
		public static const ENUM_SAVE_MODERATOR_REPORT_COMMAND:uint = 43;
		public static const ENUM_SEASONAL_GIFT_SELECTION_COMMAND:uint = 44;
		public static const ENUM_SERVER_LIST_COMMAND:uint = 45;
		public static const ENUM_SOCKET_LOGIN_COMMAND:uint = 46;
		public static const ENUM_STORE_CATEGORIES_COMMAND:uint = 47;
		public static const ENUM_STORE_ITEMS_COMMAND:uint = 48;
		public static const ENUM_TICKER_COMMAND:uint = 49;
		public static const ENUM_TRADING_CARD_BACKGROUND_COMMAND:uint = 50;
		public static const ENUM_TRADING_CARD_DELETE_COMMAND:uint = 51;
		public static const ENUM_TRADING_CARD_FRAME_COMMAND:uint = 52;
		public static const ENUM_TRADING_CARD_PURCHASE_COMMAND:uint = 53;
		public static const ENUM_TRADING_CARD_SAVE_COMMAND:uint = 54;
		public static const ENUM_TUTORIAL_RESET_COMMAND:uint = 55;
		public static const ENUM_VALIDATE_USERNAME_COMMAND:uint = 56;
		public static const ENUM_VERIFY_FRIEND_COMMAND:uint = 57;
		public static const ENUM_LOGIN_MXML:uint = 58;
		
		//TURF CONSTANTS
		public static const PARTY_MODE_OFF:int = 0;
		public static const PARTY_MODE_ON:int = 1;
		public static const TURF_ACCESS_FRIENDS:int = 1;
		public static const TURF_ACCESS_ALL:int = 2;
		public static const TURF_ACCESS_PRIVATE:int = 3;
		
		public static const PRESENCE_ONLINE:int = 1;
		
		public static const SFX_URL:String = "/test/static/sfx?sfxId=";
	}
}