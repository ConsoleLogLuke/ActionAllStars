﻿package com.sdg.animation.sequence{	import com.sdg.animation.PlaybackInfo;		public interface ISequence	{		function get duration():uint;				function get playbackInfo():PlaybackInfo;				function getSequenceCursor():ISequenceCursor;	}}