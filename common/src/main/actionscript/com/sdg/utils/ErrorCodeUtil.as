package com.sdg.utils
{
	import com.sdg.commands.*;
	import flash.utils.getQualifiedClassName;
	
	public class ErrorCodeUtil
	{
		public static const classMapping:Object = {"com.sdg.commands::ApplicationConfigurationCommand":Constants.ENUM_APPLICATION_CONFIGURATION_COMMAND,
													"com.sdg.commands::AvatarApparelCommand":Constants.ENUM_AVATAR_APPAREL_COMMAND,
													"com.sdg.commands::AvatarApparelSaveCommand":Constants.ENUM_AVATAR_APPAREL_SAVE_COMMAND,
													"com.sdg.commands::AvatarCommand":Constants.ENUM_AVATAR_COMMAND,
													"com.sdg.commands::AvatarListCommand":Constants.ENUM_AVATAR_LIST_COMMAND,
													"com.sdg.commands::AvatarStatCommand":Constants.ENUM_AVATAR_STAT_COMMAND,
													"com.sdg.commands::BuddyListCommand":Constants.ENUM_BUDDY_LIST_COMMAND,
													"com.sdg.commands::ButtonClickLoggingCommand":Constants.ENUM_BUTTON_CLICK_LOGGING_COMMAND,
													"com.sdg.commands::ChallengesCommand":Constants.ENUM_CHALLENGES_COMMAND,
													"com.sdg.commands::ChangeChatModeCommand":Constants.ENUM_CHANGE_CHAT_MODE_COMMAND,
													"com.sdg.commands::ChangeNewsletterOptionCommand":Constants.ENUM_CHANGE_NEWSLETTER_OPTION_COMMAND,
													"com.sdg.commands::ChangePasswordCommand":Constants.ENUM_CHANGE_PASSWORD_COMMAND,
													"com.sdg.commands::GameAttributesCommand":Constants.ENUM_GAME_ATTRIBUTES_COMMAND,
													"com.sdg.commands::GameResultCommand":Constants.ENUM_GAME_RESULT_COMMAND,
													"com.sdg.commands::GetAlbumCardsCommand":Constants.ENUM_GET_ALBUM_CARDS_COMMAND,
													"com.sdg.commands::GetAsnCommand":Constants.ENUM_GET_ASN_COMMAND,
													"com.sdg.commands::GetBillDateCommand":Constants.ENUM_GET_BILL_DATE_COMMAND,
													"com.sdg.commands::GetEmotesCommand":Constants.ENUM_GET_EMOTES_COMMAND,
													"com.sdg.commands::GetFavTeamsCommand":Constants.ENUM_GET_FAV_TEAMS_COMMAND,
													"com.sdg.commands::GetItemSetsCommand":Constants.ENUM_GET_ITEM_SETS_COMMAND,
													"com.sdg.commands::GetJabsCommand":Constants.ENUM_GET_JABS_COMMAND,
													"com.sdg.commands::GEtKioskCardsCommand":Constants.ENUM_GET_KIOSK_CARDS_COMMAND,
													"com.sdg.commands::GetSeasonalCommand":Constants.ENUM_GET_SEASONAL_COMMAND,
													"com.sdg.commands::GetStatsCommand":Constants.ENUM_GET_STATS_COMMAND,
													"com.sdg.commands::GetTeamsCommand":Constants.ENUM_GET_TEAMS_COMMAND,
													"com.sdg.commands::GetUnityNBATeamsCommand":Constants.ENUM_GET_UNITY_NBA_TEAMS_COMMAND,
													"com.sdg.commands::GuestAccountCommand":Constants.ENUM_GUEST_ACCOUNT_COMMAND,
													"com.sdg.commands::InventoryAttributeSaveCommand":Constants.ENUM_INVENTORY_ATTRIBUTE_SAVE_COMMAND,
													"com.sdg.commands::InventoryListCommand":Constants.ENUM_INVENTORY_LIST_COMMAND,
													"com.sdg.commands::ItemPurchasenfigurationCommand":Constants.ENUM_ITEM_PURCHASE_COMMAND,
													"com.sdg.commands::ItemTypeListCommand":Constants.ENUM_ITEM_TYPE_LIST_COMMAND,
													"com.sdg.commands::LoginCommand":Constants.ENUM_LOGIN_COMMAND,
													"com.sdg.commands::MVPLoginCommand":Constants.ENUM_MVP_LOGIN_COMMAND,
													"com.sdg.commands::MVPLoginProcessCommand":Constants.ENUM_MVP_LOG_PROCESS_COMMAND,
													"com.sdg.commands::PayByPayPalCommand":Constants.ENUM_PAY_BY_PAY_PAL_COMMAND,
													"com.sdg.commands::PickemScorecardCommand":Constants.ENUM_PICKEM_SCORECARD_COMMAND,
													"com.sdg.commands::PrivateRoomEditCommand":Constants.ENUM_PRIVATE_ROOM_EDIT_COMMAND,
													"com.sdg.commands::RegistrationSaveCommand":Constants.ENUM_REGISTRATION_SAVE_COMMAND,
													"com.sdg.commands::ResendActivationCommand":Constants.ENUM_RESEND_ACTIVATION_COMMAND,
													"com.sdg.commands::RoomCheckCommand":Constants.ENUM_ROOM_CHECK_COMMAND,
													"com.sdg.commands::RoomNavigateCommand":Constants.ENUM_ROOM_NAVIGATE_COMMAND,
													"com.sdg.commands::SaveFavonfigurationCommand":Constants.ENUM_SAVE_FAV_TEAMS_COMMAND,
													"com.sdg.commands::SaveModeratorReportCommand":Constants.ENUM_SAVE_MODERATOR_REPORT_COMMAND,
													"com.sdg.commands::SeasonalGiftSelectionCommand":Constants.ENUM_SEASONAL_GIFT_SELECTION_COMMAND,
													"com.sdg.commands::ServerListCommand":Constants.ENUM_SERVER_LIST_COMMAND,
													"com.sdg.commands::SocketLoginCommand":Constants.ENUM_SOCKET_LOGIN_COMMAND,
													"com.sdg.commands::StoreCategoriesCommand":Constants.ENUM_STORE_CATEGORIES_COMMAND,
													"com.sdg.commands::StoreItemsCommand":Constants.ENUM_STORE_ITEMS_COMMAND,
													"com.sdg.commands::TickerCommand":Constants.ENUM_TICKER_COMMAND,
													"com.sdg.commands::TradingCardBackgroundCommand":Constants.ENUM_TRADING_CARD_BACKGROUND_COMMAND,
													"com.sdg.commands::TradingCardDeleteCommand":Constants.ENUM_TRADING_CARD_DELETE_COMMAND,
													"com.sdg.commands::TradingCardDeleteCommand":Constants.ENUM_TRADING_CARD_FRAME_COMMAND,
													"com.sdg.commands::TradingCardPurchaseCommand":Constants.ENUM_TRADING_CARD_PURCHASE_COMMAND,
													"com.sdg.commands::TradingCardSaveCommand":Constants.ENUM_TRADING_CARD_SAVE_COMMAND,
													"com.sdg.commands::TutorialResetCommand":Constants.ENUM_TUTORIAL_RESET_COMMAND,
													"com.sdg.commands::ValidateUsernameCommand":Constants.ENUM_VALIDATE_USERNAME_COMMAND,
													"com.sdg.commands::VerifyFriendCommand":Constants.ENUM_VERIFY_FRIEND_COMMAND,
													"Login":Constants.ENUM_LOGIN_MXML};
		
		// Returns: Error Code of the format 
		public static function constructCode(cl:Class,status:String):String
		{
			var classCode:String = "0";
			var statusCode:String = status;
			
			var className:String = getQualifiedClassName(cl);
			
			if (classMapping[className])
				classCode = classMapping[className];
				
			return classCode+"-"+statusCode;
		}
	}
}