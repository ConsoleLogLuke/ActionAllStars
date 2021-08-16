package com.sdg.npc
{
	import com.sdg.model.AvatarAchievement;
	import com.sdg.model.AvatarAchievementCollection;
	import com.sdg.quest.QuestManager;
	import com.sdg.quest.QuestMovieUtil;
	import com.sdg.util.AssetUtil;
	import com.sdg.util.LoaderTimeout;
	import com.sdg.view.IRoomView;
	import com.sdg.view.MissionResolveMovieContainer;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class NPCClickHandlers extends Object
	{
		private static var _handlers:Array = [];
		private static var _isInit:Boolean = false;
		
		public static function handleNPCClick(npcId:String, roomView:IRoomView):void
		{
			// Make sure we have initialized.
			init();
			
			// Determine handler.
			var handler:Function = _handlers[npcId] as Function;
			
			// Execute.
			if (handler != null) handler(npcId, roomView);
		}
		
		private static function init():void
		{
			if (_isInit == true) return;
			_isInit = true;
			
			// Hard code Scuba Cert piece handlers.
			// The keys are UserInventory ids.
			_handlers['486'] = handleScubaPieceClick;
			_handlers['487'] = handleScubaPieceClick;
			_handlers['488'] = handleScubaPieceClick;
			_handlers['489'] = handleScubaPieceClick;
			_handlers['490'] = handleScubaPieceClick;
			
			// Hard code NBA Scavenger
			// The keys are UserInventory ids.
			_handlers['493'] = handleNBAHuntPieceClick;
			_handlers['494'] = handleNBAHuntPieceClick;
			_handlers['495'] = handleNBAHuntPieceClick;
			_handlers['497'] = handleNBAHuntPieceClick;
			_handlers['498'] = handleNBAHuntPieceClick;
			
			// Hard code for Trick or Treat
			// The keys are UserInventory ids.
			_handlers['514'] = handleTrickOrTreatPieceClick;
			_handlers['515'] = handleTrickOrTreatPieceClick;
			_handlers['516'] = handleTrickOrTreatPieceClick;
			_handlers['517'] = handleTrickOrTreatPieceClick;
			_handlers['518'] = handleTrickOrTreatPieceClick;
			_handlers['519'] = handleTrickOrTreatPieceClick;
			_handlers['520'] = handleTrickOrTreatPieceClick;
			_handlers['521'] = handleTrickOrTreatPieceClick;
			_handlers['522'] = handleTrickOrTreatPieceClick;
			_handlers['523'] = handleTrickOrTreatPieceClick;
			_handlers['524'] = handleTrickOrTreatPieceClick;
			_handlers['525'] = handleTrickOrTreatPieceClick;
			_handlers['526'] = handleTrickOrTreatPieceClick;
			_handlers['527'] = handleTrickOrTreatPieceClick;
			_handlers['528'] = handleTrickOrTreatPieceClick;
			_handlers['529'] = handleTrickOrTreatPieceClick;
			_handlers['530'] = handleTrickOrTreatPieceClick;
			_handlers['531'] = handleTrickOrTreatPieceClick;
			_handlers['532'] = handleTrickOrTreatPieceClick;
			_handlers['533'] = handleTrickOrTreatPieceClick;
			
			// Hard code for Zombie Hide and Seek
			// The keys are UserInventory ids.
			_handlers['542'] = handleZombieChiefClick;
			_handlers['543'] = handleZombieChiefClick;
			_handlers['544'] = handleZombieChiefClick;
			_handlers['545'] = handleZombieChiefClick;
			_handlers['546'] = handleZombieChiefClick;
			_handlers['547'] = handleZombieChiefClick;
			_handlers['548'] = handleZombieChiefClick;
			_handlers['549'] = handleZombieChiefClick;
			
			// Hard code for Zombie Hide and Seek
			_handlers['725'] = handleTurkeyHuntClick;
			_handlers['726'] = handleTurkeyHuntClick;
			_handlers['727'] = handleTurkeyHuntClick;
			_handlers['728'] = handleTurkeyHuntClick;
			_handlers['729'] = handleTurkeyHuntClick;
			_handlers['730'] = handleTurkeyHuntClick;
			_handlers['731'] = handleTurkeyHuntClick;
			_handlers['732'] = handleTurkeyHuntClick;
			_handlers['733'] = handleTurkeyHuntClick;
			_handlers['734'] = handleTurkeyHuntClick;
			_handlers['735'] = handleTurkeyHuntClick;
			_handlers['736'] = handleTurkeyHuntClick;
			_handlers['737'] = handleTurkeyHuntClick;
			_handlers['738'] = handleTurkeyHuntClick;
			_handlers['739'] = handleTurkeyHuntClick;
			_handlers['740'] = handleTurkeyHuntClick;
			_handlers['741'] = handleTurkeyHuntClick;
			_handlers['742'] = handleTurkeyHuntClick;
			_handlers['743'] = handleTurkeyHuntClick;
			_handlers['744'] = handleTurkeyHuntClick;
			_handlers['745'] = handleTurkeyHuntClick;
			_handlers['746'] = handleTurkeyHuntClick;
			
			// Hard Code for Hat Mission
			_handlers['751'] = handleHatHuntClick;
			_handlers['752'] = handleHatHuntClick;
			_handlers['753'] = handleHatHuntClick;
			_handlers['754'] = handleHatHuntClick;
			_handlers['755'] = handleHatHuntClick;
			_handlers['756'] = handleHatHuntClick;
			_handlers['757'] = handleHatHuntClick;
			_handlers['758'] = handleHatHuntClick;
			_handlers['759'] = handleHatHuntClick;
			_handlers['760'] = handleHatHuntClick;
			_handlers['761'] = handleHatHuntClick;
			_handlers['762'] = handleHatHuntClick;
			_handlers['763'] = handleHatHuntClick;
			_handlers['764'] = handleHatHuntClick;
			_handlers['765'] = handleHatHuntClick;
			_handlers['766'] = handleHatHuntClick;
			_handlers['767'] = handleHatHuntClick;
			_handlers['768'] = handleHatHuntClick;
			_handlers['769'] = handleHatHuntClick;
			_handlers['770'] = handleHatHuntClick;
			_handlers['771'] = handleHatHuntClick;
			_handlers['772'] = handleHatHuntClick;
			_handlers['773'] = handleHatHuntClick;
			_handlers['774'] = handleHatHuntClick;
			_handlers['775'] = handleHatHuntClick;
			_handlers['776'] = handleHatHuntClick;
			_handlers['777'] = handleHatHuntClick;
			_handlers['778'] = handleHatHuntClick;
			_handlers['779'] = handleHatHuntClick;
			_handlers['780'] = handleHatHuntClick;
		}
		
		private static function handleScubaPieceClick(npcId:int, roomView:IRoomView):void
		{
			// Map NPC ids to mission ids.
			var npcToMissionMap:Array = [];
			npcToMissionMap['486'] = '577';
			npcToMissionMap['487'] = '578';
			npcToMissionMap['488'] = '579';
			npcToMissionMap['489'] = '580';
			npcToMissionMap['490'] = '581';
			
			var missionNotStartedScreenUrl:String = AssetUtil.GetGameAssetUrl(75, 'pre_scuba_cert.swf');
			handleCollectionScreen(QuestManager.SCUBA_CERTIFICATION_MISSION_ID, npcToMissionMap, npcId, missionNotStartedScreenUrl, roomView);
		}

		private static function handleNBAHuntPieceClick(npcId:int, roomView:IRoomView):void
		{
			// Map NPC ids to mission ids.
			var npcToMissionMap:Array = [];
			npcToMissionMap['493'] = '589';
			npcToMissionMap['494'] = '587';
			npcToMissionMap['495'] = '588';
			npcToMissionMap['497'] = '590';
			npcToMissionMap['498'] = '591';
			
			handleCollectionScreen(QuestManager.NBA_SCAVENGER_HUNT_MISSION_ID, npcToMissionMap, npcId, '', roomView);
		}
		
		private static function handleTrickOrTreatPieceClick(npcId:int, roomView:IRoomView):void
		{
			// Map NPC ids to mission ids.
			var npcToMissionMap:Array = [];
			npcToMissionMap['514'] = '610';
			npcToMissionMap['515'] = '611';
			npcToMissionMap['516'] = '612';
			npcToMissionMap['517'] = '613';
			npcToMissionMap['518'] = '614';
			npcToMissionMap['519'] = '615';
			npcToMissionMap['520'] = '616';
			npcToMissionMap['521'] = '617';
			npcToMissionMap['522'] = '618';
			npcToMissionMap['523'] = '619';
			npcToMissionMap['524'] = '620';
			npcToMissionMap['525'] = '621';
			npcToMissionMap['526'] = '622';
			npcToMissionMap['527'] = '623';
			npcToMissionMap['528'] = '624';
			npcToMissionMap['529'] = '625';
			npcToMissionMap['530'] = '626';
			npcToMissionMap['531'] = '627';
			npcToMissionMap['532'] = '628';
			npcToMissionMap['533'] = '629';
			
			var missionNotStartedScreenUrl:String = AssetUtil.GetGameAssetUrl(75, 'pre_trick_treat.swf');
			handleCollectionScreen(QuestManager.TRICK_OR_TREAT_MISSION_ID, npcToMissionMap, npcId, missionNotStartedScreenUrl, roomView);
		}
		
		private static function handleZombieChiefClick(npcId:int, roomView:IRoomView):void
		{
			// Map NPC ids to mission ids.
			var npcToMissionMap:Array = [];
			npcToMissionMap['542'] = '645';
			npcToMissionMap['543'] = '646';
			npcToMissionMap['544'] = '647';
			npcToMissionMap['545'] = '648';
			npcToMissionMap['546'] = '649';
			npcToMissionMap['547'] = '650';
			npcToMissionMap['548'] = '651';
			npcToMissionMap['549'] = '652';
			
			var missionNotStartedScreenUrl:String = AssetUtil.GetGameAssetUrl(75, 'pre_zombie_hide_seek.swf');
			handleCollectionScreen(QuestManager.ZOMBIE_HIDE_AND_SEEK_MISSION_ID, npcToMissionMap, npcId, missionNotStartedScreenUrl, roomView);
		}
		
		private static function handleTurkeyHuntClick(npcId:int, roomView:IRoomView):void
		{
			// Map NPC ids to mission ids.
			var npcToMissionMap:Array = [];
			npcToMissionMap['725'] = '662';
			npcToMissionMap['726'] = '663';
			npcToMissionMap['727'] = '664';
			npcToMissionMap['728'] = '665';
			npcToMissionMap['729'] = '666';
			npcToMissionMap['730'] = '667';
			npcToMissionMap['731'] = '668';
			npcToMissionMap['732'] = '669';
			npcToMissionMap['733'] = '670';
			npcToMissionMap['734'] = '671';
			npcToMissionMap['735'] = '672';
			npcToMissionMap['736'] = '673';
			npcToMissionMap['737'] = '674';
			npcToMissionMap['738'] = '675';
			npcToMissionMap['739'] = '676';
			npcToMissionMap['740'] = '677';
			npcToMissionMap['741'] = '678';
			npcToMissionMap['742'] = '679';
			npcToMissionMap['743'] = '680';
			npcToMissionMap['744'] = '681';
			npcToMissionMap['745'] = '682';
			npcToMissionMap['746'] = '683';
			
			var missionNotStartedScreenUrl:String = AssetUtil.GetGameAssetUrl(75, 'pre_turkey_hide_seek.swf');
			handleCollectionScreen(QuestManager.TURKEY_HIDE_AND_SEEK_MISSION_ID, npcToMissionMap, npcId, missionNotStartedScreenUrl, roomView);
		}
		
		private static function handleHatHuntClick(npcId:int, roomView:IRoomView):void
		{
			// Map NPC ids to mission ids.
			var npcToMissionMap:Array = [];
			npcToMissionMap['751'] = '691';
			npcToMissionMap['752'] = '692';
			npcToMissionMap['753'] = '693';
			npcToMissionMap['754'] = '694';
			npcToMissionMap['755'] = '695';
			npcToMissionMap['756'] = '696';
			npcToMissionMap['757'] = '697';
			npcToMissionMap['758'] = '698';
			npcToMissionMap['759'] = '699';
			npcToMissionMap['760'] = '700';
			npcToMissionMap['761'] = '701';
			npcToMissionMap['762'] = '702';
			npcToMissionMap['763'] = '703';
			npcToMissionMap['764'] = '704';
			npcToMissionMap['765'] = '705';
			npcToMissionMap['766'] = '706';
			npcToMissionMap['767'] = '707';
			npcToMissionMap['768'] = '708';
			npcToMissionMap['769'] = '709';
			npcToMissionMap['770'] = '710';
			npcToMissionMap['771'] = '711';
			npcToMissionMap['772'] = '712';
			npcToMissionMap['773'] = '713';
			npcToMissionMap['774'] = '714';
			npcToMissionMap['775'] = '715';
			npcToMissionMap['776'] = '716';
			npcToMissionMap['777'] = '717';
			npcToMissionMap['778'] = '718';
			npcToMissionMap['779'] = '719';
			npcToMissionMap['780'] = '720';
			
			var missionNotStartedScreenUrl:String = AssetUtil.GetGameAssetUrl(75, 'pre_missing_hats.swf');
			handleCollectionScreen(QuestManager.HAT_HIDE_AND_SEEK_MISSION_ID, npcToMissionMap, npcId, missionNotStartedScreenUrl, roomView);
		}
		
		private static function handleCollectionScreen(collectionMissionId:int, npcIdToAchievementIdMap:Array, npcId:int, missionNotStartedScreenUrl:String, roomView:IRoomView):void
		{
			var mission:AvatarAchievement = QuestManager.getActiveQuest(collectionMissionId);
			if (mission == null)
			{
				// User has not yet accepted mission.
				// Show them a screen that messages this.
				var url:String = missionNotStartedScreenUrl;
				
				// Create a movie container.
				var movieContainer:MissionResolveMovieContainer = new MissionResolveMovieContainer();
				movieContainer.name = "Loading";
				roomView.addQuedPopUp(movieContainer);
				
				// Show the message.
				var movie:DisplayObject;
				var request:URLRequest = new URLRequest(url);
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.load(request);
				
				function onError(e:IOErrorEvent):void
				{
					// Remove listeners.
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
					
					// Remove movie pop up without transition.
					roomView.removeQuedPopUp(movieContainer);
				}
				
				function onComplete(e:Event):void
				{
					// Remove listeners.
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
					
					// Get reference to movie.
					movie = loader.content;
					movie.addEventListener(Event.CLOSE, onClose);
										
					// Pass mission data to the movie.
					var pieceMissionId:String = npcIdToAchievementIdMap[npcId] as String;
					if (pieceMissionId == null) return;
					var movieObj:Object = movie;
					if (movieObj.foundPiece != null) movieObj.foundPiece(pieceMissionId);
					
					// Add the movie to the container.
					movieContainer.movie = movie;
					movieContainer.show();
				}
				
				function onClose(e:Event):void
				{
					// Remove listener.
					movie.removeEventListener(Event.CLOSE, onClose);
					
					// Remove movie pop up without transition.
					roomView.removeQuedPopUp(movieContainer);
				}
			}
			else
			{
				// They have accepted the mission.
				// Determine if they have completed the mission
				// that is associated with this piece (npc).
				var pieceMissionId:String = npcIdToAchievementIdMap[npcId] as String;
				var pieceMission:AvatarAchievement = QuestManager.getActiveQuest(uint(pieceMissionId));
				if (pieceMission == null || pieceMission.isComplete != true) return;
				
				// They have not completed the mission.
				// Show the screen.
				var pieceFoundMovieUrl:String = QuestMovieUtil.GetMovieUrl(uint(pieceMissionId));
				
				// Create a movie container.
				var pieceFoundMovieContainer:MissionResolveMovieContainer = new MissionResolveMovieContainer();
				pieceFoundMovieContainer.name = "Loading";
				roomView.addQuedPopUp(pieceFoundMovieContainer);
				
				// Show the cutscene.
				var cutscene:DisplayObject;
				var movieRequest:URLRequest = new URLRequest(pieceFoundMovieUrl);
				var movieLoader:Loader = new Loader();
				movieLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError2);
				movieLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete2);
				movieLoader.load(movieRequest);
				
				// Create timeout.
				LoaderTimeout.StartTimeout(movieLoader, 3000, onFoundPieceMovieTimeout);
				
				function onError2(e:IOErrorEvent):void
				{
					// Remove listeners.
					movieLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError2);
					movieLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete2);
					
					// Remove cutscene pop up without transition.
					roomView.removeQuedPopUp(pieceFoundMovieContainer);
				}
				
				function onComplete2(e:Event):void
				{
					// Remove listeners.
					movieLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError2);
					movieLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete2);
					
					// Get reference to quest resolve movie.
					cutscene = movieLoader.content;
					cutscene.addEventListener(Event.CLOSE, onClose2);
					
					// Pass data into movie.
					// Determine which pieces have been found and pass
					// an array with those values to the movie.
					var activeMissions:AvatarAchievementCollection = QuestManager.activeUserQuests;
					var piecesFoundArray:Array = activeMissions.getCompletedAchievementIdArray();
					// Force the piece we just found into the list.
					piecesFoundArray[pieceMissionId] = true;
					
					// Pass values into movie.
					var movieObj:Object = cutscene;
					if (movieObj.setPiecesFoundArray != null) movieObj.setPiecesFoundArray(piecesFoundArray);
					if (movieObj.foundPiece != null) movieObj.foundPiece(pieceMissionId, false);
					
					// Add the movie to the container.
					pieceFoundMovieContainer.movie = cutscene;
					pieceFoundMovieContainer.show();
				}
				
				function onFoundPieceMovieTimeout():void
				{
					// On timeout.
					
					// If the movie has not been loaded,
					// remove the movie container.
					if (cutscene == null)
					{
						// Remove cutscene pop up without transition.
						roomView.removeQuedPopUp(pieceFoundMovieContainer);
					}
				}
				
				function onClose2(e:Event):void
				{
					// Remove listener.
					cutscene.removeEventListener(Event.CLOSE, onClose2);
					
					// Remove cutscene pop up without transition.
					roomView.removeQuedPopUp(pieceFoundMovieContainer);
				}
			}
		}
		
	}
}