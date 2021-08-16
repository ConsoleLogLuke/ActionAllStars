package com.sdg.quest
{
	import com.sdg.components.dialog.TeamSelectDialog;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarAchievementCollection;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.Environment;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.LayeredImage;
	import com.sdg.view.avatarcard.AvatarCardTwoSide;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	internal class QuestResolveMovieHandlers extends Object
	{
		private static var _handlers:Array = [];
		private static var _assetMapping:Array = []
		private static var _isInit:Boolean = false;
		
		public static function handleResolveMovie(questId:uint, movie:Object):void
		{
			// Make sure we have initialized.
			init();
			
			// Determine handler.
			var handler:Function = _handlers[questId] as Function;
			
			// Execute.
			if (handler != null) handler(questId, movie);
		}
		
		private static function init():void
		{
			if (_isInit == true) return;
			_isInit = true;
			
			// Hard code resolve movie handlers.
			_handlers['512'] = handleIntroMovie;
			_handlers['514'] = handlePickTeamsMovie;
			
			// Hard code handlers for the hot dog
			// cart pieces.
			_handlers['561'] = handlePieceFoundMovie;
			_handlers['562'] = handlePieceFoundMovie;
			_handlers['563'] = handlePieceFoundMovie;
			_handlers['564'] = handlePieceFoundMovie;
			_handlers['565'] = handlePieceFoundMovie;
			
			_handlers['560'] = handleCollectionProgressMovie;
			
			// Hard code handlers for the scuba cert mission.
			_handlers['577'] = handlePieceFoundMovie;
			_handlers['578'] = handlePieceFoundMovie;
			_handlers['579'] = handlePieceFoundMovie;
			_handlers['580'] = handlePieceFoundMovie;
			_handlers['581'] = handlePieceFoundMovie;
			
			_handlers['576'] = handleCollectionProgressMovie;
			
			// Hard code handlers for the nba underwater scavenger hunt
			_handlers['587'] = handlePieceFoundMovie;
			_handlers['588'] = handlePieceFoundMovie;
			_handlers['589'] = handlePieceFoundMovie;
			_handlers['590'] = handlePieceFoundMovie;
			_handlers['591'] = handlePieceFoundMovie;
			
			_handlers['586'] = handleCollectionProgressMovie;
			
			// Hard code handlers for the trick or treat mission.
			_handlers['609'] = handleCollectionProgressMovie;
			_handlers['610'] = handlePieceFoundMovie;
			_handlers['611'] = handlePieceFoundMovie;
			_handlers['612'] = handlePieceFoundMovie;
			_handlers['613'] = handlePieceFoundMovie;
			_handlers['614'] = handlePieceFoundMovie;
			_handlers['615'] = handlePieceFoundMovie;
			_handlers['616'] = handlePieceFoundMovie;
			_handlers['617'] = handlePieceFoundMovie;
			_handlers['618'] = handlePieceFoundMovie;
			_handlers['619'] = handlePieceFoundMovie;
			_handlers['620'] = handlePieceFoundMovie;
			_handlers['621'] = handlePieceFoundMovie;
			_handlers['622'] = handlePieceFoundMovie;
			_handlers['623'] = handlePieceFoundMovie;
			_handlers['624'] = handlePieceFoundMovie;
			_handlers['625'] = handlePieceFoundMovie;
			_handlers['626'] = handlePieceFoundMovie;
			_handlers['627'] = handlePieceFoundMovie;
			_handlers['628'] = handlePieceFoundMovie;
			_handlers['629'] = handlePieceFoundMovie;
			
			// Hard code handlers for the Zombie Hide and Seek Mission
			_handlers['644'] = handleCollectionProgressMovie;
			_handlers['645'] = handlePieceFoundMovie;
			_handlers['646'] = handlePieceFoundMovie;
			_handlers['647'] = handlePieceFoundMovie;
			_handlers['648'] = handlePieceFoundMovie;
			_handlers['649'] = handlePieceFoundMovie;
			_handlers['650'] = handlePieceFoundMovie;
			_handlers['651'] = handlePieceFoundMovie;
			_handlers['652'] = handlePieceFoundMovie;
			
			// Hard code handlers for the Turkey Hide and Seek Mission
			_handlers['661'] = handleCollectionProgressMovie;
			_handlers['662'] = handlePieceFoundMovie;
			_handlers['663'] = handlePieceFoundMovie;
			_handlers['664'] = handlePieceFoundMovie;
			_handlers['665'] = handlePieceFoundMovie;
			_handlers['666'] = handlePieceFoundMovie;
			_handlers['667'] = handlePieceFoundMovie;
			_handlers['668'] = handlePieceFoundMovie;
			_handlers['669'] = handlePieceFoundMovie;
			_handlers['670'] = handlePieceFoundMovie;
			_handlers['671'] = handlePieceFoundMovie;
			_handlers['672'] = handlePieceFoundMovie;
			_handlers['673'] = handlePieceFoundMovie;
			_handlers['674'] = handlePieceFoundMovie;
			_handlers['675'] = handlePieceFoundMovie;
			_handlers['676'] = handlePieceFoundMovie;
			_handlers['677'] = handlePieceFoundMovie;
			_handlers['678'] = handlePieceFoundMovie;
			_handlers['679'] = handlePieceFoundMovie;
			_handlers['680'] = handlePieceFoundMovie;
			_handlers['681'] = handlePieceFoundMovie;
			_handlers['682'] = handlePieceFoundMovie;
			_handlers['683'] = handlePieceFoundMovie;
			
			// Hard code handlers for the Hat Hide and Seek Mission
			_handlers['690'] = handleCollectionProgressMovie;
			_handlers['691'] = handlePieceFoundMovie;
			_handlers['692'] = handlePieceFoundMovie;
			_handlers['693'] = handlePieceFoundMovie;
			_handlers['694'] = handlePieceFoundMovie;
			_handlers['695'] = handlePieceFoundMovie;
			_handlers['696'] = handlePieceFoundMovie;
			_handlers['697'] = handlePieceFoundMovie;
			_handlers['698'] = handlePieceFoundMovie;
			_handlers['699'] = handlePieceFoundMovie;
			_handlers['700'] = handlePieceFoundMovie;
			_handlers['701'] = handlePieceFoundMovie;
			_handlers['702'] = handlePieceFoundMovie;
			_handlers['703'] = handlePieceFoundMovie;
			_handlers['704'] = handlePieceFoundMovie;
			_handlers['705'] = handlePieceFoundMovie;
			_handlers['706'] = handlePieceFoundMovie;
			_handlers['707'] = handlePieceFoundMovie;
			_handlers['708'] = handlePieceFoundMovie;
			_handlers['709'] = handlePieceFoundMovie;
			_handlers['710'] = handlePieceFoundMovie;
			_handlers['711'] = handlePieceFoundMovie;
			_handlers['712'] = handlePieceFoundMovie;
			_handlers['713'] = handlePieceFoundMovie;
			_handlers['714'] = handlePieceFoundMovie;
			_handlers['715'] = handlePieceFoundMovie;
			_handlers['716'] = handlePieceFoundMovie;
			_handlers['717'] = handlePieceFoundMovie;
			_handlers['718'] = handlePieceFoundMovie;
			_handlers['719'] = handlePieceFoundMovie;
			_handlers['720'] = handlePieceFoundMovie;
			
			//_assetMapping['691'] = 
			//_assetMapping['692'] = 
			//_handlers['693'] = 
			//_handlers['694'] = 
			//_handlers['695'] = 
			//_handlers['696'] = 
			//_handlers['697'] = 
			//_handlers['698'] = 
			//_handlers['699'] = 
			//_handlers['700'] = 
			//_handlers['701'] = 
			//_handlers['702'] = 
			//_handlers['703'] = 
			//_handlers['704'] = 
			//_handlers['705'] = 
			//_handlers['706'] = 
			//_handlers['707'] = 
			//_handlers['708'] = 
			//_handlers['709'] = 
			//_handlers['710'] = 
			//_handlers['711'] = 
			//_handlers['712'] = 
			//_handlers['713'] = 
			//_handlers['714'] = 
			//_handlers['715'] = 
			//_handlers['716'] = 
			//_handlers['717'] = 
			//_handlers['718'] = 
			//_handlers['719'] = 
			//_handlers['720'] = 
		}
		
		private static function handleIntroMovie(questId:uint, movie:Object):void
		{
			// Handle the intro resolve movie.
			
			// Create an avatar card and pass it into the movie.
			var avatar:Avatar = ModelLocator.getInstance().avatar;
			var avCard:AvatarCardTwoSide = new AvatarCardTwoSide(avatar, 263, 362, false);
			avCard.addEventListener(Event.COMPLETE, onAvCardComplete);
			avCard.init();
			movie.isLegacy = avatar.isLegacy;
			
			//Listen for skip and close.
			EventDispatcher(movie).addEventListener('skip click', onSkip);
			EventDispatcher(movie).addEventListener(Event.CLOSE, onClose);
			
			// Create an avatar preview and pass it.
			var avPreview:LayeredImage = new LayeredImage();
			avPreview.addEventListener(Event.COMPLETE, onAvatarImageComplete);
			avPreview.loadItemImage(avatar);
			
			function onAvatarImageComplete(e:Event):void
			{
				// Remove listener.
				avPreview.removeEventListener(Event.COMPLETE, onAvatarImageComplete);
				
				// Scale av preview.
				var maxH:Number = 100;
				var avScale:Number = (maxH / avPreview.height);
				avPreview.width *= avScale;
				avPreview.height *= avScale;
				
				movie.avatarAsset = avPreview;
			}
			
			function onAvCardComplete(e:Event):void
			{
				// Remove listener.
				avCard.removeEventListener(Event.COMPLETE, onAvCardComplete);
				
				// Pass card to movie.
				movie.cardAsset = avCard;
			}
			
			function onSkip(e:Event):void
			{
				LoggingUtil.sendClickLogging(LoggingUtil.MISSION_INTRO_SKIP);
			}
			
			function onClose(e:Event):void
			{
				EventDispatcher(movie).removeEventListener('skip click', onSkip);
				EventDispatcher(movie).removeEventListener(Event.CLOSE, onClose);
			}
		}
		
		private static function handlePickTeamsMovie(questId:uint, movie:Object):void
		{
			// Show team selection.
			// this should never happen anymore because everyone should be able to do team select
			//MainUtil.showDialog(TeamSelectDialog);
		}
		
		private static function handleCollectionProgressMovie(questId:int, movie:Object):void
		{
			// Determine which pieces have been found and pass
			// an array with those values to the movie.
			var activeMissions:AvatarAchievementCollection = QuestManager.activeUserQuests;
			var piecesFoundArray:Array = activeMissions.getCompletedAchievementIdArray();
			
			// Force the piece we just found into the list.
			piecesFoundArray[questId.toString()] = true;
			
			// Pass values into movie.
			if (movie.setPiecesFoundArray != null) movie.setPiecesFoundArray(piecesFoundArray);
		}
		
		private static function handlePieceFoundMovie(questId:int, movie:Object):void
		{
			// First pass found pieces.
			handleCollectionProgressMovie(questId, movie);
			
			// Pass In Display Object
			if ((questId > 690) && (questId < 721))
			{
				handleMissionItemClip(questId.toString(),movie);
			}
			
			// Pass values into movie.
			if (movie.foundPiece != null) movie.foundPiece(questId.toString());
		}
		
		private static function handleMissionItemClip(id:String,movie:Object):void
		{
			//var hatUrl:String = Environment.getAssetUrl() + '/test/gameSwf/gameId/78/gameFile/flag_440.swf';
			var hatUrl:String = Environment.getAssetUrl() + '/test/gameSwf/gameId/78/gameFile/hat_'+id+'.swf';
			
			// Load the hat
			var request:URLRequest = new URLRequest(hatUrl);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFlagCompl);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFlagErr);
			loader.load(request);
			
			function onFlagErr(e:IOErrorEvent):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onFlagCompl);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onFlagErr);
				
				//foundFlagScreen.noFlag();
			}
			function onFlagCompl(e:Event):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onFlagCompl);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onFlagErr);
				
				// Pass the item into the movie
				movie.pieceItem(MovieClip(loader.content));
			}	
			
		}
		
	}
}