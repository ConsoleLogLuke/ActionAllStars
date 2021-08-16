﻿package com.sdg.factory{		import com.sdg.animation.AnimationSet;	import com.sdg.animation.PlaybackInfo;	import com.sdg.animation.sequence.FrameSequence;	import com.sdg.animation.sequence.ISequence;	import com.sdg.events.AnimationFrameEvent;	    public class AnimationSetFactory extends AbstractXMLObjectFactory implements IXMLObjectFactory	{		public function createInstance():Object		{			// Create an instance of AnimationSet.			var animationSet:AnimationSet = new AnimationSet();						// Compile animations frin the XML file.			for each (var animationNode:XML in xml.animationSet.animation)			{				var playbackInfo:PlaybackInfo = new PlaybackInfo(animationNode.frameRate, animationNode.loopCount);								// Compile individual sequences within the animation, from the XML file.				for each (var sequenceNode:XML in animationNode.sequences.sequence)				{					var sequence:FrameSequence = new FrameSequence(playbackInfo);										// frames					var frameNodes:XMLList = sequenceNode.children();					var frameIndex:uint = 0;					var frameDuration:uint;										for each (var frameNode:XML in frameNodes)					{						// frame events						var eventNodes:XMLList = frameNode.children();												for each (var eventNode:XML in eventNodes)						{							sequence.addFrameEvent(frameIndex, new AnimationFrameEvent(eventNode.name(), eventNode));						}												// frame duration						frameDuration = frameNode.@duration;						frameIndex += (frameDuration == 0) ? 1 : frameDuration;					}										sequence.duration = frameIndex;					animationSet.addSequence(animationNode.name.text() + sequenceNode.@name, sequence);				}			}						return animationSet;		}    }}