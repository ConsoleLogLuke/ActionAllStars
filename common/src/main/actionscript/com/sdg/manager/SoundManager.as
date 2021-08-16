package com.sdg.manager
{
	import com.sdg.net.RemoteSoundBank;

	public class SoundManager extends RemoteSoundBank
	{
		protected static var _instance:SoundManager;
		
		public function SoundManager()
		{
			if (_instance == null)
			{
				super();
			}
			else
			{
				throw new Error("SoundManager is a singleton class. Use 'getInstance()' to access the instance.");
			}
		}
		
		public static function GetInstance():SoundManager
		{
			if (_instance == null) _instance = new SoundManager();
			return _instance;
		}
		
	}
}