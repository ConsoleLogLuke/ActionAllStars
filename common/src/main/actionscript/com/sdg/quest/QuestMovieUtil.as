package com.sdg.quest
{
	import com.sdg.net.Environment;
	
	public class QuestMovieUtil extends Object
	{	
		private static var _urlOverrides:Array = [];
		private static var _isInit:Boolean = false;
		
		private static function init():void
		{
			if (_isInit == true) return;
			_isInit = true;
			
			//
			// HARD CODED FOR SCUBA CERTIFICATION
			//
			// Hard code url for the movie that displays
			// when you find a hot dog cart piece.
			//
			var scubaPieceResolveMovieUrl:String = 'http://' + Environment.getApplicationDomain() + '/test/static/achievement/cutscene?achievementId=576';
			
			// Hard code url overrides for scuba certification pieces.
			_urlOverrides['577'] = scubaPieceResolveMovieUrl;
			_urlOverrides['578'] = scubaPieceResolveMovieUrl;
			_urlOverrides['579'] = scubaPieceResolveMovieUrl;
			_urlOverrides['580'] = scubaPieceResolveMovieUrl;
			_urlOverrides['581'] = scubaPieceResolveMovieUrl;
			
			
			//
			// HARD CODED FOR SCAVENGER MAZE
			//
			// Hard code url for the movie that displays
			// when you find a note piece.
			//
			var notePieceResolveMovieUrl:String = 'http://' + Environment.getApplicationDomain() + '/test/static/achievement/cutscene?achievementId=586';
			
			// Hard code url overrides for pieces.
			_urlOverrides['587'] = notePieceResolveMovieUrl;
			_urlOverrides['588'] = notePieceResolveMovieUrl;
			_urlOverrides['589'] = notePieceResolveMovieUrl;
			_urlOverrides['590'] = notePieceResolveMovieUrl;
			_urlOverrides['591'] = notePieceResolveMovieUrl;
			
			
			//
			// HARD CODED FOR TRICK OR TREAT
			//
			// Hard code url for the movie that displays
			// when you find a piece.
			//
			var trickOrTreatResolveMovieUrl:String = 'http://' + Environment.getApplicationDomain() + '/test/static/achievement/cutscene?achievementId=609';
			
			//
			// HARD CODED FOR HAT MISSION
			//
			// Hard code url for the movie that displays
			// when you find a piece.
			//
			var hatResolveMovieUrl:String = 'http://' + Environment.getApplicationDomain() + '/test/static/achievement/cutscene?achievementId=690';

			
			// Hard code url overrides for pieces.
			_urlOverrides['610'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['611'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['612'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['613'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['614'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['615'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['616'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['617'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['618'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['619'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['620'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['621'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['622'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['623'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['624'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['625'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['626'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['627'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['628'] = trickOrTreatResolveMovieUrl;
			_urlOverrides['629'] = trickOrTreatResolveMovieUrl;
			
			// HARD CODED FOR ZOMBIE HIDE AND SEEK
			//
			// Hard code url for the movie that displays
			// when you cure a zombie
			var hideAndSeekResolveMovieUrl:String = 'http://' + Environment.getApplicationDomain() + '/test/static/achievement/cutscene?achievementId=644';
			
			_urlOverrides['645'] = hideAndSeekResolveMovieUrl;
			_urlOverrides['646'] = hideAndSeekResolveMovieUrl;
			_urlOverrides['647'] = hideAndSeekResolveMovieUrl;
			_urlOverrides['648'] = hideAndSeekResolveMovieUrl;
			_urlOverrides['649'] = hideAndSeekResolveMovieUrl;
			_urlOverrides['650'] = hideAndSeekResolveMovieUrl;
			_urlOverrides['651'] = hideAndSeekResolveMovieUrl;
			_urlOverrides['652'] = hideAndSeekResolveMovieUrl;
			
			// HARD CODED FOR TURKEY HIDE AND SEEK
			//
			// Hard code url for the movie that displays
			// when you find a turkey
			var turkeyHuntResolveMovieUrl:String = 'http://' + Environment.getApplicationDomain() + '/test/static/achievement/cutscene?achievementId=661';
			
			_urlOverrides['662'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['663'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['664'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['665'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['666'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['667'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['668'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['669'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['670'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['671'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['672'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['673'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['674'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['675'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['676'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['677'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['678'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['679'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['680'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['681'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['682'] = turkeyHuntResolveMovieUrl;
			_urlOverrides['683'] = turkeyHuntResolveMovieUrl;
			
			_urlOverrides['691'] = hatResolveMovieUrl;
			_urlOverrides['692'] = hatResolveMovieUrl;
			_urlOverrides['693'] = hatResolveMovieUrl;
			_urlOverrides['694'] = hatResolveMovieUrl;
			_urlOverrides['695'] = hatResolveMovieUrl;
			_urlOverrides['696'] = hatResolveMovieUrl;
			_urlOverrides['697'] = hatResolveMovieUrl;
			_urlOverrides['698'] = hatResolveMovieUrl;
			_urlOverrides['699'] = hatResolveMovieUrl;
			_urlOverrides['700'] = hatResolveMovieUrl;
			_urlOverrides['701'] = hatResolveMovieUrl;
			_urlOverrides['702'] = hatResolveMovieUrl;
			_urlOverrides['703'] = hatResolveMovieUrl;
			_urlOverrides['704'] = hatResolveMovieUrl;
			_urlOverrides['705'] = hatResolveMovieUrl;
			_urlOverrides['706'] = hatResolveMovieUrl;
			_urlOverrides['707'] = hatResolveMovieUrl;
			_urlOverrides['708'] = hatResolveMovieUrl;
			_urlOverrides['709'] = hatResolveMovieUrl;
			_urlOverrides['710'] = hatResolveMovieUrl;
			_urlOverrides['711'] = hatResolveMovieUrl;
			_urlOverrides['712'] = hatResolveMovieUrl;
			_urlOverrides['713'] = hatResolveMovieUrl;
			_urlOverrides['714'] = hatResolveMovieUrl;
			_urlOverrides['715'] = hatResolveMovieUrl;
			_urlOverrides['716'] = hatResolveMovieUrl;
			_urlOverrides['717'] = hatResolveMovieUrl;
			_urlOverrides['718'] = hatResolveMovieUrl;
			_urlOverrides['719'] = hatResolveMovieUrl;
			_urlOverrides['720'] = hatResolveMovieUrl;
		}
		
		public static function GetMovieUrl(questId:uint):String
		{
			// Make sure we have initialized.
			init();
			
			// Build url.
			var url:String = 'http://' + Environment.getApplicationDomain() + '/test/static/achievement/cutscene?achievementId=' + questId;
			
			// Determine if there is a url override.
			var urlOverride:String = _urlOverrides[questId] as String;
			if (urlOverride != null) url = urlOverride;
			
			// Return url.
			return url;
		}
		
	}
}