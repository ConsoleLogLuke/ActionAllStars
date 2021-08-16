package com.sdg.audio
{
	public class EmbeddedAudio extends Object
	{
		[Embed(source="audio/circlebloop.mp3")]
		public static var OpenSound:Class;

		[Embed(source="audio/circletick.mp3")]
		public static var OverSound:Class;

	}
}
