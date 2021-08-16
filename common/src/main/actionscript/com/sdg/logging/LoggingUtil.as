package com.sdg.logging
{
	import com.sdg.net.socket.SocketClient;
	
	public class LoggingUtil
	{
		public static const PDA_CLOSE_BUTTON:int = 1799;
		public static const PDA_CATALOG_BUTTON:int = 1702;
		public static const PDA_CUSTOMIZER_BUTTON:int = 1703;
		public static const PDA_MESSAGES_BUTTON:int = 1704;
		public static const PDA_LEADERBOARDS_BUTTON:int = 1705;
		public static const PDA_MISSIONS_BUTTON:int = 1706;
		public static const PDA_FRIENDS_BUTTON:int = 1707;
		public static const PDA_ASN_BUTTON:int = 1708;
		public static const PDA_AWARDS_BUTTON:int = 1709;
		public static const PDA_SPORTS_PSYCHIC_BUTTON:int = 1710;
		public static const PDA_GAMES_BUTTON:int = 1711;
		public static const PDA_COMMENTS_BUTTON:int = 1712;
		public static const PDA_CUSTOMIZER_FROM_AVATAR_CLICK:int = 1715;
		
		public static const LEADER_CLOSE_BUTTON:int = 2799;
		public static const LEADER_FLIP_CARD:int = 2701;
		public static const LEADER_GAMER_TAB:int = 2702;
		public static const LEADER_GURU_TAB:int = 2703;
		public static const LEADER_COLLECTOR_TAB:int = 2704;
		public static const LEADER_ALLSTAR_HALL_TAB:int = 2705;
		public static const LEADER_WEEKLY_TAB:int = 2706;
		public static const LEADER_MONTHLY_TAB:int = 2707;
		public static const LEADER_ALL_TIME_TAB:int = 2708;
		public static const LEADER_FRIENDS_PULLDOWN:int = 2709;
		public static const LEADER_TEAM_PULLDOWN:int = 2710;
		public static const LEADER_WORLD_PULLDOWN:int = 2711;
		public static const LEADER_GAMER_XP_BUTTON:int = 2720;
		public static const LEADER_HOOPS_BUTTON:int = 2721;
		public static const LEADER_SNOWBOARDING_BUTTON:int = 2722;
		public static const LEADER_SURFING_BUTTON:int = 2723;
		public static const LEADER_BLB_BUTTON:int = 2724;
		public static const LEADER_THREE_BUTTON:int = 2725;
		public static const LEADER_HANDLES_BUTTON:int = 2726;
		public static const LEADER_PITCHING_ACE_BUTTON:int = 2727;
		public static const LEADER_BATTER_PINBALL_BUTTON:int = 2728;
		public static const LEADER_QBC_BUTTON:int = 2729;
		public static const LEADER_GURU_XP_BUTTON:int = 2750;
		public static const LEADER_TRIVIA_BUTTON:int = 2751;
		public static const LEADER_SPORTS_PSYCHIC_BUTTON:int = 2752;
		public static const LEADER_COLLECTOR_XP_BUTTON:int = 2760;
		public static const LEADER_TURF_VALUE_BUTTON:int = 2761;
		
		// ORIGINAL GAME CONSOLE BUTTONS NOW UNUSED
		public static const CONSOLE_FAV_TEAM:int = 2801;
		public static const CONSOLE_MAP_BUTTON:int = 2802;
		public static const CONSOLE_ASN_BUTTON:int = 2803;
		public static const CONSOLE_TURF_BUTTON:int = 2804;
		public static const CONSOLE_FRIENDS_BUTTON:int = 2805;
		public static const CONSOLE_FULL_SCREEN_BUTTON:int = 2809;
		public static const CONSOLE_MUTE_BUTTON:int = 2810;
		public static const CONSOLE_PDA_BUTTON:int = 2811;
		public static const CONSOLE_ADD_TOKENS_BUTTON:int = 2812;
		public static const NON_CONSOLE_ASN_BUTTON:int = 2814;
		
		// OLD CONSOLE LOGGING STILL IN USE
		public static const CONSOLE_SCRIPTED_CHAT_BUTTON:int = 2806;
		public static const CONSOLE_EMOTES_BUTTON:int = 2807; // Button No Longer in Console
		public static const CONSOLE_AWARDS_BUTTON:int = 2808; // Button No Longer in Console
		
		// NEW GAME CONSOLE BUTTONS
		//public static const HUD_STORE_BUTTON:int = 2813; // Old LinkId;
		public static const HUD_WORLD_MAP_BUTTON_CLICK:uint = 2815;
		public static const HUD_FRIENDS_BUTTON_CLICK:uint = 2816;
		public static const HUD_PETS_BUTTON_CLICK:uint = 2817;
		public static const HUD_HOME_TURF_BUTTON_CLICK:uint = 2818;
		public static const HUD_TURF_BUILDER_BUTTON_CLICK:uint = 2819;
		public static const HUD_SHOP_BUTTON_CLICK:uint = 2820;
		public static const HUD_PDA_BUTTON_CLICK:uint = 2821;
		public static const HUD_MUSIC_BUTTON_CLICK:uint = 2824;
		public static const HUD_SFX_BUTTON_CLICK:uint = 2823;
		public static const HUD_FULL_SCREEN_BUTTON_CLICK:uint = 2825;
		public static const HUD_ASN_NEWSPAPER_BUTTON_CLICK:uint = 2822;
		public static const HUD_FULL_SCREEN_INSUFF_VERSION:uint = 2827;
		public static const HUD_FULL_SCREEN_SUFFICIENT_VERSION:uint = 2828;
		public static const HUD_BADGE_BUTTON_CLICK:int = 2829;
		
		public static const MISSION_INTRO_SKIP:int = 2900;
		
		public static const WORLD_MAP_RIVERWALK:int = 3011;
		public static const WORLD_MAP_JOE_BOSE_PARK:int = 3015;
		public static const WORLD_MAP_AAS_STORE:int = 3010;
		public static const WORLD_MAP_MY_TURF:int = 3003;
		public static const WORLD_MAP_BALLERS_HALL:int = 3000;
		public static const WORLD_MAP_NBA_STORE:int = 3001;
		public static const WORLD_MAP_BALLERS_PLAZA:int = 3002;
		public static const WORLD_MAP_DIAMONDS_RUN:int = 3021;
		public static const WORLD_MAP_MLB_STORE:int = 3020;
		public static const WORLD_MAP_VERT_VILLAGE:int = 3019;
		public static const WORLD_MAP_VERT_VILLAGE_STORE:int = 3016;
		public static const WORLD_MAP_THE_PEAK:int = 3022;
		public static const WORLD_MAP_BEACHSIDE:int = 3018;
		public static const WORLD_MAP_MAVERICKS:int = 3017;
		public static const WORLD_MAP_FOOTBALL_FIELD:int = 3014;
		public static const WORLD_MAP_BROADCAST_CENTER:int = 3013;
		public static const WORLD_MAP_BLAKES_PLACE:int = 3012;
		
		public static const WORLD_MAP_KOBE_TURF:int = 3004;
		public static const WORLD_MAP_LEBRON_TURF:int = 3005;
		public static const WORLD_MAP_STEVE_NASH_TURF:int = 3006;
		public static const WORLD_MAP_DUANE_WAYDE_TURF:int = 3007;
		public static const WORLD_MAP_DWIGHT_HOWARD_TURF:int = 3008;
		public static const WORLD_MAP_SAM_TURF:int = 3009;
		
		
		public static const WEATHER_WARNING_DIAMONDS_RUN:int = 3100;
		public static const WEATHER_WARNING_VERT_VILLAGE:int = 3101;
		public static const WEATHER_WARNING_JOE_BOSE_PARK:int = 3105;
		public static const WEATHER_WARNING_BALLERS_PARK:int = 3106;
		public static const WEATHER_WARNING_RIVERWALK:int = 3107;
		public static const HIGH_SURF_VERT_VILLAGE:int = 3102;
		public static const HIGH_SURF_BEACH_SIDE_1:int = 3103;
		public static const HIGH_SURF_BEACH_SIDE_2:int = 3104;
		
		public static const HELP_WANTED_DIAMONDS_RUN:int = 3111;
		public static const HELP_WANTED_VERT_VILLAGE:int = 3112;
		public static const HELP_WANTED_JOE_BOSE_PARK:int = 3113;
		public static const HELP_WANTED_RIVERWALK:int = 3114;
		public static const HELP_WANTED_BALLERS_PLAZA:int = 3115;
		
		public static const HELP_WANTED_TRANSPORT_DIAMONDS_RUN:int = 3117;
		public static const HELP_WANTED_TRANSPORT_VERT_VILLAGE:int = 3118;
		public static const HELP_WANTED_TRANSPORT_RIVERWALK:int = 3119;
		public static const HELP_WANTED_TRANSPORT_JOE_BOSE_PARK:int = 3120;
		public static const HELP_WANTED_TRANSPORT_BALLERS_HALL:int = 3121;
		
		public static const THERMOMETER_DIAMONDS_RUN:int = 3122;
		public static const THERMOMETER_RIVERWALK:int = 3109;
		public static const THERMOMETER_VERT_VILLAGE:int = 3110;
		public static const THERMOMETER_JOE_BOSE_PARK:int = 3108;
		
		public static const TONY_AWAY_SIGN_DIAMONDS_RUN:int = 3300;
		
		public static const WANTED_POSTER_BALLERS_HALL:int = 3301;
		public static const WANTED_POSTER_JOE_BOSE_PARK:int = 3302;
		public static const WANTED_POSTER_RIVERWALK:int = 3303;
		public static const WANTED_POSTER_VERT_VILLAGE:int = 3304;

		public static const POLICE_SIGN_BALLERS_PLAZA:int = 3310;
		public static const POLICE_SIGN_FOOTBALL_FIELD:int = 3311;
		public static const POLICE_SIGN_JOE_BOSE_PARK:int = 3312;
		public static const POLICE_SIGN_RIVERWALK:int = 3313;
		public static const POLICE_SIGN_VERT_VILLAGE:int = 3314;
		
		public static const POLICE_SIGN_TRANSPORT_BALLERS_PLAZA:int = 3320;
		public static const POLICE_SIGN_TRANSPORT_FOOTBALL_FIELD:int = 3321;
		public static const POLICE_SIGN_TRANSPORT_JOE_BOSE_PARK:int = 3322;
		public static const POLICE_SIGN_TRANSPORT_RIVERWALK:int = 3323;
		public static const POLICE_SIGN_TRANSPORT_VERT_VILLAGE:int = 3324;

		public static const BINOCULARS_BEACHSIDE:int = 3500;
		public static const MESSAGE_BOTTLE_BEACHSIDE:int = 3501;
		

		public static const TRAINING_CAMP_BALLERS_HALL:int = 3504;
		public static const TRAINING_CAMP_BEACHSIDE:int = 3505;
		public static const TRAINING_CAMP_DIAMONDS_RUN:int = 3506;
		public static const TRAINING_CAMP_FOOTBALL_FIELD:int = 3507;
		public static const TRAINING_CAMP_JOSE_BOSE_PARK:int = 3508;
		public static const TRAINING_CAMP_RIVERWALK:int = 3509;
		public static const TRAINING_CAMP_VERT_VILLAGE:int = 3510;
		
		public static const TRAINING_CAMP_TRANSPORT_BALLERS_HALL:int = 3511;
		public static const TRAINING_CAMP_TRANSPORT_BEACHSIDE:int = 3512;
		public static const TRAINING_CAMP_TRANSPORT_DIAMONDS_RUN:int = 3513;
		public static const TRAINING_CAMP_TRANSPORT_FOOTBALL_FIELD:int = 3514;
		public static const TRAINING_CAMP_TRANSPORT_JOSE_BOSE_PARK:int = 3515;
		public static const TRAINING_CAMP_TRANSPORT_RIVERWALK:int = 3516;
		public static const TRAINING_CAMP_TRANSPORT_VERT_VILLAGE:int = 3517;
		
		public static const STADIUM_BLOCKER_JOE_BOSE_PARK:int = 3502;
		public static const STADIUM_BLOCKER_VERT_VILLAGE:int = 3503;
		
		public static const PRINT_SHOP_ENTERED:uint = 3521;
		public static const PRINT_SHOP_MY_CARD_FRONT:uint = 3527;
		public static const PRINT_SHOP_FOLDABLE_CARDS:uint = 3526;
		public static const PRINT_SHOP_ALLSTAR_STANDUPS:int = 3528;
		public static const PRINT_SHOP_EASTER_2011:int = 3530;
		
		public static const NBA_PRESEASON_PROMO_RIVERWALK:int = 3600;
		public static const NBA_PRESEASON_PROMO_VERT_VILLAGE:int = 3601;
		public static const NBA_PRESEASON_PROMO_BALLERS_HALL:int = 3602;
		public static const NBA_PRESEASON_PROMO_BALLERS_PLAZA:int = 3603;
		
		// Temp Value
		public static const BINOCULARS_BEACH:int = 0;
		
		public static const ROOM_FULL_MAVERICKS:int = 3200;
		public static const ROOM_FULL_FOOTBALL_FIELD:int = 3201;
		public static const ROOM_FULL_ROCK_AVALANCHE:int = 3202;
		public static const ROOM_FULL_PRIZE_ROOM:int = 3203;
		public static const ROOM_FULL_MAVERICKS_ARCADE:int = 3204;
		public static const ROOM_FULL_BULLPEN:int = 3205;
		public static const ROOM_FULL_BUNNY:int = 3206;
		public static const ROOM_FULL_BALLERS_HALL:int = 3207;
		
		public static const ROOM_ENTER_CLICK_STADIUM:int = 3826;
		
		public static const RBI_STATS_PAGE:int = 3401;
		
		public static const MVP_NAV_BAR_CLICK:int = 3606;
		
		public static const MVP_UPSELL_VIEW_MVP_EXPIRED:int = 3707;
		public static const MVP_UPSELL_VIEW_STORE:int = 3708;
		public static const MVP_UPSELL_VIEW_CUSTOMIZER:int = 3709;
		public static const MVP_UPSELL_VIEW_TURF_BUILDER:int = 3710;
		public static const MVP_UPSELL_VIEW_RBI:int = 3711;
		public static const MVP_UPSELL_VIEW_MAVS_ARCADE:int = 3712;
		public static const MVP_UPSELL_VIEW_ROCK_AVALANCHE:int = 3713;
		public static const MVP_UPSELL_VIEW_INTERACTIVE_DIALOG:int = 3721;
		public static const MVP_UPSELL_VIEW_HOME_DUGOUT:int = 3722;
		public static const MVP_UPSELL_VIEW_ZOMBIE_BOSSFIGHT:int = 3723;
		public static const MVP_UPSELL_VIEW_KICKER_TRY_OUT:int = 3733;
		public static const MVP_UPSELL_VIEW_PET_BUTTON_ON_HUD:int = 3737;
		public static const MVP_UPSELL_VIEW_PET_STORE:int = 3748;
		public static const MVP_UPSELL_VIEW_SINGLEPLAYERMISSION:int = 3735;
		public static const MVP_UPSELL_VIEW_CARROT_STORE:int = 3750;
		public static const MVP_UPSELL_VIEW_BUNNY_GAME_LIMIT:int = 3751;
		public static const MVP_UPSELL_VIEW_RBI_BASEBALL_STORE:int = 3758;
		
		public static const MVP_UPSELL_VIEW_MSG_BOARD_STICKER:int = 3754;
		public static const MVP_UPSELL_VIEW_MSG_BOARD_COLOR:int = 3755;

		public static const MVP_UPSELL_VIEW_MAVERICKS:int = 3731;
		
		public static const MVP_UPSELL_VIEW_SAM_TRICK_TREAT:int = 3729;
		public static const MVP_UPSELL_VIEW_FIND_BURNIE:int = 3727;
		
		public static const MVP_UPSELL_VIEW_NBA_ALLSTARS:int = 3742;
		
		public static const MVP_UPSELL_CLICK_MVP_EXPIRED:int = 3714;
		public static const MVP_UPSELL_CLICK_STORE:int = 3715;
		public static const MVP_UPSELL_CLICK_CUSTOMIZER:int = 3716;
		public static const MVP_UPSELL_CLICK_TURF_BUILDER:int = 3717;
		public static const MVP_UPSELL_CLICK_RBI:int = 3718;
		public static const MVP_UPSELL_CLICK_MAVS_ARCADE:int = 3719;
		public static const MVP_UPSELL_CLICK_ROCK_AVALANCHE:int = 3720;
		public static const MVP_UPSELL_CLICK_INTERACTIVE_DIALOG:int = 3724;
		public static const MVP_UPSELL_CLICK_HOME_DUGOUT:int = 3725;
		public static const MVP_UPSELL_CLICK_ZOMBIE_BOSSFIGHT:int = 3726;
		public static const MVP_UPSELL_CLICK_KICKER_TRY_OUT:int = 3734;
		public static const MVP_UPSELL_CLICK_PET_BUTTON_ON_HUD:int = 3738;
		public static const MVP_UPSELL_CLICK_PET_STORE:int = 3740;
		public static const MVP_UPSELL_CLICK_SINGLEPLAYERMISSION:int = 3736;
		public static const MVP_UPSELL_CLICK_RBI_BASEBALL_STORE:int = 3759;
		
		public static const MVP_UPSELL_CLICK_MAVERICKS:int = 3732;
		
		public static const MVP_UPSELL_CLICK_SAM_TRICK_TREAT:int = 3730;
		public static const MVP_UPSELL_CLICK_FIND_BURNIE:int = 3728;
		
		public static const MVP_UPSELL_CLICK_NBA_ALLSTARS:int = 3743;
		
		public static const MVP_UPSELL_CLICK_CARROT_STORE:int = 3752;
		public static const MVP_UPSELL_CLICK_BUNNY_GAME_LIMIT:int = 3753;
		
		public static const MVP_UPSELL_CLICK_MSG_BOARD_STICKER:int = 3756;
		public static const MVP_UPSELL_CLICK_MSG_BOARD_COLOR:int = 3757;		
		
		public static const TELEPORT_SUCCESS:int = 1712;
		public static const TELEPORT_BLOCKED:int = 1713;
		public static const TELEPORT_CLOSEST_POINT:int = 1714;
		
		public static const BURNIE_MISSING_RIVERWALK:int = 3604; //637
		public static const BURNIE_MISSING_BALLERS_HALL:int = 3605; //636
		public static const BURNIE_MISSING_JOE_BOSE_PARK:int = 3606; //634
		public static const BURNIE_MISSING_VERT_VILLAGE:int = 3607; //635
		
		public static const NBA_OCTOPII_RIVERWALK:int = 3608; //649
		public static const NBA_OCTOPII_BALLERS_HALL:int = 3609; //651
		public static const NBA_OCTOPII_BALLERS_PLAZA:int = 3610; //652
		public static const NBA_OCTOPII_FOOTBALL_FIELD:int = 3611; //650
		
		public static const NBA_OCTOPII_TRANSPORT_RIVERWALK:int = 3612; //649
		public static const NBA_OCTOPII_TRANSPORT_BALLERS_HALL:int = 3613; //651
		public static const NBA_OCTOPII_TRANSPORT_BALLERS_PLAZA:int = 3614; //652
		public static const NBA_OCTOPII_TRANSPORT_FOOTBALL_FIELD:int = 3615; //650
		
		public static const ZOMBIE_SIGN_RIVERWALK:int = 3809; // 659
		public static const ZOMBIE_SIGN_VERT_VILLAGE:int = 3810; // 660
		public static const ZOMBIE_SIGN_BALLERS_PLAZA:int = 3805; // 661 (logging says Ballers Hall)
		public static const ZOMBIE_SIGN_DIAMONDS_RUN:int = 3807; // 662
		public static const ZOMBIE_SIGN_BEACHSIDE:int = 3806; // 663
		public static const ZOMBIE_SIGN_FOOTBALL_FIELD:int = 3808; // 664 (logging says Joe Bose Park)
		
		public static const ZOMBIE_SIGN_TRANSPORT_RIVERWALK:int = 3815; // 659
		public static const ZOMBIE_SIGN_TRANSPORT_VERT_VILLAGE:int = 3816; // 660
		public static const ZOMBIE_SIGN_TRANSPORT_BALLERS_PLAZA:int = 3811; // 661 (logging says Ballers Hall)
		public static const ZOMBIE_SIGN_TRANSPORT_DIAMONDS_RUN:int = 3813; // 662
		public static const ZOMBIE_SIGN_TRANSPORT_BEACHSIDE:int = 3812; // 663
		public static const ZOMBIE_SIGN_TRANSPORT_FOOTBALL_FIELD:int = 3814; // 664 (logging says Joe Bose Park)
		
		public static const PICKLES_WARNING_RIVERWALK:int = 3821; // 654
		public static const PICKLES_WARNING_JOE_BOSE_PARK:int = 3822; // 655
		public static const PICKLES_WARNING_DIAMONDS_RUN:int = 3823; // 656
		public static const PICKLES_WARNING_BALLERS_HALL:int = 3824; // 657
		public static const PICKLES_WARNING_VERT_VILLAGE:int = 3825; // 658
		
		public static const RAF_FOOTBALL_FIELD_KIOSK_REGISTER:int = 3900;
		public static const RAF_BALLERS_HALL_KIOSK_REGISTER:int = 3901;
		public static const RAF_RIVERWALK_KIOSK_REGISTER:int = 3902;
		public static const RAF_REFER_A_FRIEND_PDA_REGISTER:int = 3903;
		
		public static const RAF_FOOTBALL_FIELD_KIOSK_UNAPPROVED:int = 3904;
		public static const RAF_BALLERS_HALL_KIOSK_UNAPPROVED:int = 3905;
		public static const RAF_RIVERWALK_KIOSK_UNAPPROVED:int = 3906;
		public static const RAF_REFER_A_FRIEND_PDA_UNAPPROVED:int = 3907;
		
		public static const RAF_FOOTBALL_FIELD_KIOSK_VIEW:int = 3908;
		public static const RAF_BALLERS_HALL_KIOSK_VIEW:int = 3909;
		public static const RAF_RIVERWALK_KIOSK_VIEW:int = 3910;
		public static const RAF_REFER_A_FRIEND_PDA_VIEW:int = 3911;
		
		public static const RAF_FOOTBALL_FIELD_KIOSK_CLICK:int = 3912;
		public static const RAF_BALLERS_HALL_KIOSK_CLICK:int = 3913;
		public static const RAF_RIVERWALK_KIOSK_CLICK:int = 3914;
		public static const RAF_REFER_A_FRIEND_PDA_CLICK:int = 3915;
		
		public static const RAF_GET_PRIZE_BUTTON:int = 3916;
		public static const RAF_MISSPELLED_REFERRER_NAME:int = 3917;
		public static const RAF_ALMOST_DONE:int = 3922;
		public static const RAF_REGISTRATION_SCREEN_VIEW:int = 3923;
		public static const RAF_REGISTERED_WITH_FRIEND:int = 3918;
		public static const RAF_FRIEND_REQUEST_ACCEPTED:int = 3919;
		
		public static const NEW_MAVERICKS_GAME_PROMO_VERT_VILLAGE:int = 4000;
		
		public static const TURKEY_SIGN_RIVERWALK:int = 4001; // 20000011
		public static const TURKEY_SIGN_JOE_BOSE_PARK:int = 4002; // 20000001
		public static const TURKEY_SIGN_VERT_VILLAGE:int = 4005; // 20000004
		public static const TURKEY_SIGN_BALLERS_HALL:int = 4003; // 20000002
		public static const TURKEY_SIGN_DIAMONDS_RUN:int = 4004; // 20000003
		public static const TURKEY_SIGN_FOOTBALL_FIELD:int = 4006; // 20000005
		
		
		public static const PET_MENU_ACTION1:int = 4211;
		public static const PET_MENU_ACTION2:int = 4212;
		public static const PET_MENU_ACTION3:int = 4213;
		public static const PET_MENU_LEASH:int = 4214;
		//offset for the HUD menu
		public static const PET_MENU_HUD_OFFSET:int = 10;
		
		public static const PET_BUTTON_REG:int = 4230;
		public static const PET_BUTTON_BUY_PET:int = 4231;
		public static const PET_BUTTON_IN_TURF:int = 4232;
		
		public static const TURF_PANEL_RATE_TURF:uint = 2826;
		
		public static const MY_ACCOUNT_GET_MVP:int = 3747;
		public static const MY_ACCOUNT_RENEW:int = 3749;
		
		public static const PARTY_BUTTON_CLICK:int = 2845;
		
		public static const SNOWMAN_SIGN_RIVERWALK:int = 4400;
		public static const SNOWMAN_SIGN_BALLERS_HALL:int = 4401;
		
		public static const ALLSTAR_SIGN_RIVERWALK:int = 4500;
		public static const ALLSTAR_SIGN_THE_PEAK:int = 4502;
		public static const ALLSTAR_SIGN_TRANSPORT_RIVERWALK:int = 4501;
		public static const ALLSTAR_SIGN_TRANSPORT_THE_PEAK:int = 4503;
		
		public static const CHUTE_PROMOTION:int = 4600;
		public static const STADIUM_PROMOTION:int = 4606;
		public static const TELESCOPE_PROMOTION:int = 4650;
		public static const SKATE_PROMOTION:int = 4651;
		public static const SAM_SHOP_EGG_PROMOTION:int = 4652;
		// TURF UI Logging
		public static const TURF_UI_TURF_ACCESS_CHANGE:int = 4301;
		public static const TURF_UI_PARTY_MODE_CHANGE:int = 4302;
		public static const TURF_UI_TURF_MESSAGE_CLICK:int = 4303;
		
		public static const MSG_BOARD_ADD_MESSAGE:int = 4304;
		public static const MSG_BOARD_CHANGE_COLOR_MVP:int = 4305;
		public static const MSG_BOARD_CHANGE_STICKER_MVP:int = 4306;
		public static const MSG_BOARD_POST_IT:int = 4307;
		public static const MSG_BOARD_DELETE_MESSAGE:int = 4308;
		public static const MSG_BOARD_GO_TO_TURF:int = 4309;
		public static const MSG_BOARD_ADD_FRIEND:int = 4310;
		public static const MSG_BOARD_REPORT_MESSAGE:int = 4311;
		public static const MSG_BOARD_REMOVE_FRIEND:int = 4312;
		public static const MSG_BOARD_REPLY:int = 4313;
		
		public static const ROVING_NPC_CLICK_BABY_PICKLES:int = 4601;
		public static const ROVING_NPC_CLICK_BUTTER_PICKLES:int = 4602;
		public static const ROVING_NPC_CLICK_GARLIC_PICKLES:int = 4603;
		public static const ROVING_NPC_CLICK_MADPOPPA_PICKLES:int = 4604;
		public static const ROVING_NPC_CLICK_PAULIE_PICKLES:int = 4605; // Not Used
		public static const ROVING_NPC_POPUP_SAM:int = 4607;
		public static const ROVING_NPC_POPUP_ROGER_BLUE:int = 4609;
		public static const ROVING_NPC_POPUP_BILLY_BOMBER:int = 4608;
		
		public static const HATS_WANTED_SIGNS_RIVERWALK:int = 4641;
		public static const HATS_WANTED_SIGNS_THE_PEAK:int = 4642;
		public static const HATS_WANTED_SIGNS_BEACHSIDE:int = 4640;
		
		public static const INTERACT_BALLOON_SUCCESS_ARIZONA:int = 4610;
		public static const INTERACT_BALLOON_SUCCESS_ATLANTA:int = 4611;
		public static const INTERACT_BALLOON_SUCCESS_CHI_CUBS:int = 4612;
		public static const INTERACT_BALLOON_SUCCESS_CINCINNATI:int = 4613;
		public static const INTERACT_BALLOON_SUCCESS_COLORADO:int = 4614;
		public static const INTERACT_BALLOON_SUCCESS_FLORIDA:int = 4615;
		public static const INTERACT_BALLOON_SUCCESS_HOUSTON:int = 4616;
		public static const INTERACT_BALLOON_SUCCESS_LA_DODGERS:int = 4617;
		public static const INTERACT_BALLOON_SUCCESS_MILWAUKEE:int = 4618;
		public static const INTERACT_BALLOON_SUCCESS_NY_METS:int = 4619;
		public static const INTERACT_BALLOON_SUCCESS_PHILADELPHIA:int = 4620;
		public static const INTERACT_BALLOON_SUCCESS_PITTSBURGH:int = 4621;
		public static const INTERACT_BALLOON_SUCCESS_SAN_DIEGO:int = 4622;
		public static const INTERACT_BALLOON_SUCCESS_ST_LOUIS:int = 4623;
		public static const INTERACT_BALLOON_SUCCESS_WASHINGTON_DC:int = 4624;
		public static const INTERACT_BALLOON_SUCCESS_BALTIMORE:int = 4625;
		public static const INTERACT_BALLOON_SUCCESS_BOSTON:int = 4626;
		public static const INTERACT_BALLOON_SUCCESS_LA_ANGELS:int = 4627;
		public static const INTERACT_BALLOON_SUCCESS_CHI_WHITE_SOX:int = 4628;
		public static const INTERACT_BALLOON_SUCCESS_CLEVELAND:int = 4629;
		public static const INTERACT_BALLOON_SUCCESS_DETRIOT:int = 4630;
		public static const INTERACT_BALLOON_SUCCESS_KANSAS_CITY:int = 4631;
		public static const INTERACT_BALLOON_SUCCESS_MINNESOTA:int = 4632;
		public static const INTERACT_BALLOON_SUCCESS_NY_YANKEES:int = 4633;
		public static const INTERACT_BALLOON_SUCCESS_OAKLAND:int = 4634;
		public static const INTERACT_BALLOON_SUCCESS_SEATTLE:int = 4635;
		public static const INTERACT_BALLOON_SUCCESS_TAMPA_BAY:int = 4636;
		public static const INTERACT_BALLOON_SUCCESS_TORONTO:int = 4637;
		public static const INTERACT_BALLOON_SUCCESS_TEXAS:int = 4638;
		public static const INTERACT_BALLOON_SUCCESS_SAN_FRANCISCO:int = 4639;
		
		public static const ONBOARDING_START:int = 4710;
		public static const ONBOARDING_END:int = 4711;
				
		/* maps mvp locked mission achievementIds to the mvp upsell view and click linkIds*/
		public static const missionLockViewLinkIdMapping:Object = {608:MVP_UPSELL_VIEW_SAM_TRICK_TREAT, 585:MVP_UPSELL_VIEW_FIND_BURNIE};
		public static const missionLockClickLinkIdMapping:Object = {608:MVP_UPSELL_CLICK_SAM_TRICK_TREAT, 585:MVP_UPSELL_CLICK_FIND_BURNIE};
		
		
		public static const roomFullLinkIdMapping:Object = {public_119:ROOM_FULL_MAVERICKS,
															public_121:ROOM_FULL_FOOTBALL_FIELD,
															public_1135:ROOM_FULL_ROCK_AVALANCHE,
															public_1136:ROOM_FULL_PRIZE_ROOM,
															public_147:ROOM_FULL_MAVERICKS_ARCADE,
															public_149:ROOM_FULL_BULLPEN,
															public_157:ROOM_FULL_BUNNY,
															public_158:ROOM_FULL_BUNNY,
															public_159:ROOM_FULL_BUNNY,
															public_160:ROOM_FULL_BUNNY,
															public_107:ROOM_FULL_BALLERS_HALL};
							
		public static const invItemMapping:Object = {20000011:TURKEY_SIGN_RIVERWALK,
													20000004:TURKEY_SIGN_VERT_VILLAGE,20000002:TURKEY_SIGN_BALLERS_HALL,
													20000003:TURKEY_SIGN_DIAMONDS_RUN,20000001:TURKEY_SIGN_JOE_BOSE_PARK,
													20000005:TURKEY_SIGN_FOOTBALL_FIELD,622:NEW_MAVERICKS_GAME_PROMO_VERT_VILLAGE,
													6403:ROVING_NPC_CLICK_BABY_PICKLES,6400:ROVING_NPC_CLICK_BUTTER_PICKLES,
													6399:ROVING_NPC_CLICK_GARLIC_PICKLES,6402:ROVING_NPC_CLICK_MADPOPPA_PICKLES,
													6401:ROVING_NPC_CLICK_PAULIE_PICKLES,6377:ROVING_NPC_POPUP_ROGER_BLUE,
													6378:ROVING_NPC_POPUP_BILLY_BOMBER, 5480:ROVING_NPC_POPUP_SAM,
													677:HATS_WANTED_SIGNS_RIVERWALK,678:HATS_WANTED_SIGNS_THE_PEAK,
													679:HATS_WANTED_SIGNS_BEACHSIDE,
													769:INTERACT_BALLOON_SUCCESS_ARIZONA,758:INTERACT_BALLOON_SUCCESS_ATLANTA,
													751:INTERACT_BALLOON_SUCCESS_CHI_CUBS,776:INTERACT_BALLOON_SUCCESS_CINCINNATI,
													770:INTERACT_BALLOON_SUCCESS_COLORADO,757:INTERACT_BALLOON_SUCCESS_FLORIDA,
													754:INTERACT_BALLOON_SUCCESS_HOUSTON,780:INTERACT_BALLOON_SUCCESS_LA_DODGERS,
													775:INTERACT_BALLOON_SUCCESS_MILWAUKEE,760:INTERACT_BALLOON_SUCCESS_NY_METS,
													762:INTERACT_BALLOON_SUCCESS_PHILADELPHIA,778:INTERACT_BALLOON_SUCCESS_PITTSBURGH,
													764:INTERACT_BALLOON_SUCCESS_SAN_DIEGO,759:INTERACT_BALLOON_SUCCESS_ST_LOUIS,
													779:INTERACT_BALLOON_SUCCESS_WASHINGTON_DC,773:INTERACT_BALLOON_SUCCESS_BALTIMORE,
													756:INTERACT_BALLOON_SUCCESS_BOSTON,755:INTERACT_BALLOON_SUCCESS_LA_ANGELS,
													763:INTERACT_BALLOON_SUCCESS_CHI_WHITE_SOX,777:INTERACT_BALLOON_SUCCESS_CLEVELAND,
													765:INTERACT_BALLOON_SUCCESS_DETRIOT,772:INTERACT_BALLOON_SUCCESS_KANSAS_CITY,
													766:INTERACT_BALLOON_SUCCESS_MINNESOTA,752:INTERACT_BALLOON_SUCCESS_NY_YANKEES,
													771:INTERACT_BALLOON_SUCCESS_OAKLAND,753:INTERACT_BALLOON_SUCCESS_SEATTLE,
													774:INTERACT_BALLOON_SUCCESS_TAMPA_BAY,767:INTERACT_BALLOON_SUCCESS_TORONTO,
													768:INTERACT_BALLOON_SUCCESS_TEXAS,761:INTERACT_BALLOON_SUCCESS_SAN_FRANCISCO};
													
		public static const altInvItemMapping:Object = {101:ALLSTAR_SIGN_TRANSPORT_RIVERWALK,102:ALLSTAR_SIGN_TRANSPORT_THE_PEAK};
											

		
		public static function sendClickLogging(linkId:int):void
		{
			if (linkId < 1) return;
			var uiEventTags:String = "<uiId>" + linkId + "</uiId>";
			sendLogging(uiEventTags);
		}
		
		public static function sendLogging(uiEventTags:String):void
		{			
			var uiEventString:String = "<uiEvent>" + uiEventTags + "</uiEvent>";
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "uiEvent", { uiEvent:uiEventString });
		}
		
		public static function sendSignClickLogging(inventoryItemId:int):void
		{
			var linkId:int = getLinkIdFromInvItemId(inventoryItemId);
			
			sendClickLogging(linkId);
		}
		
		public static function sendSignTransportClickLogging(inventoryItemId:int):void
		{
			var linkId:int = getAltLinkIdFromInvItemId(inventoryItemId);
			
			sendClickLogging(linkId);
		}
		
		
		private static function getLinkIdFromInvItemId(invItemId:int):int
		{
			return invItemMapping[invItemId.toString()];
		}
		
		private static function getAltLinkIdFromInvItemId(invItemId:int):int
		{
			return altInvItemMapping[invItemId.toString()];
		}
	
	}
}
