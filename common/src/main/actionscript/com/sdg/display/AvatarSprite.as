package com.sdg.display
{
	import com.sdg.animation.AnimationSet;
	import com.sdg.animation.AnimationSetResource;
	import com.sdg.business.resource.RemoteResourceMap;
	import com.sdg.business.resource.SdgResourceLocator;
	import com.sdg.core.ApplicationManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.SdgItem;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;

	public class AvatarSprite extends CharacterSprite
	{
		[Embed(source='images/spritesheets/generic_avatar_optimized_01.png')]
		private static const genericAvatarImageClass:Class;

		// Color matrix array: generated with tool at "http://www.adobetutorialz.com/articles/1987/1/Color-Matrix"
		private static const avatarColorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter([1.700776,-0.511896,-0.06888,0,-7.62,-0.259224,1.448104,-0.06888,0,-7.62,-0.259224,-0.511896,1.89112,0,-7.62,0,0,0,1,0]);
		private static const avatarStroke:GlowFilter = new GlowFilter(0x000000, 1, 3, 3, 6);
		private static const avatarPreviewStroke:GlowFilter = new GlowFilter(0, 1, 4, 4, 20);
		public static const DefaultAvatarCompositeFilters:Array = [avatarStroke, avatarColorMatrixFilter];
		public static const DefaultAvatarPreviewFilters:Array = [avatarPreviewStroke, avatarColorMatrixFilter];
		private static const genericAvatarFilters:Array = [new GlowFilter(0xffffff, 1, 4, 4, 4)];

		private static const _defaultAvatarSpriteCellWidth:int = 120;
		private static const _defaultAvatarSpriteCellHeight:int = 120;

		private static var genericAvatarImage:Bitmap;
		private static var genericAnimationSet:AnimationSet;
		private static var genericMaleImageSource:BitmapData;
		private static var genericFemaleImageSource:BitmapData;

		protected var _avatar:Avatar;
		private var _rewardsCounter:int;
		//protected var _rewards:Array;
		//protected var _reward:Reward;
		//protected var _firstReward:Reward;
		//protected var _secondReward:Reward;
		//protected var _rewardItem:SdgItem;
		//protected var _queuedRewardType:String;
		//protected var _rewardEffect:RewardEffect;

		public function AvatarSprite(item:SdgItem)
		{
			super(item);

			_avatar = item as Avatar;

			// Create default animation set.
			if (genericAnimationSet == null)
			{
				var animResourceMap:RemoteResourceMap = new RemoteResourceMap();
				animResourceMap.setResource("animationSet", SdgResourceLocator.getInstance().getAnimationSet(201));
				animResourceMap.addEventListener(Event.COMPLETE, onDefaultAnimationSetComplete);
				animResourceMap.load();
			}
			else
			{
				// Determine which animation resource to use for this avatar.
				var animationResource:AnimationSetResource = createGenericAvatarResource();

				animationPlayer.addResourceList([animationResource]);
				initDisplay();
			}

			function onDefaultAnimationSetComplete(e:Event):void
			{
				// Remove listener.
				animResourceMap.removeEventListener(Event.COMPLETE, onDefaultAnimationSetComplete);

				// Set generic animation set.
				genericAnimationSet = animResourceMap.getContent("animationSet") as AnimationSet;

				// Set static image.
				genericAvatarImage = new genericAvatarImageClass();

				// Determine which animation resource to use for this avatar.
				var animationResource:AnimationSetResource = createGenericAvatarResource();

				animationPlayer.addResourceList([animationResource]);
				initDisplay();
			}
		}

		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////

		public static function GetColorTransformForSkin(skinItemId:int):ColorTransform
		{
			// Assuming you have the lightest skin bitmap,
			// this returns a color transform that would make it match the color of the item id passed in.
			switch (skinItemId)
			{
				case 2644:
				case 2648:
					return new ColorTransform(0.93, 0.93, 0.93);
					break;
				case 2645:
				case 2649:
				return new ColorTransform(0.78, 0.78, 0.78);
					break;
				case 2646:
				case 2650:
					return new ColorTransform(0.60, 0.60, 0.60);
					break;
				default:
					return new ColorTransform(1, 1, 1);
			}
		}

		public static function GetColorTransformForHair(hairItemId:int):ColorTransform
		{
			// Assuming you have the lightest hair bitmap,
			// this returns a color transform that would make it match the color of the item id passed in.
			switch (hairItemId)
			{
				// red hair
				case 3465:
				case 3476:
				case 3486:
				case 3468:
				case 3483:
				case 3479:
				case 3472:
				case 3490:
				case 3501:
				case 3497:
				case 3504:
				case 3494:
				case 2635:
				case 3511:
					return new ColorTransform(0.82, 0.45, 0.48);
					break;

				// brown hair
				case 3466:
				case 2632:
				case 3487:
				case 3469:
				case 2633:
				case 3480:
				case 3473:
				case 3491:
				case 2977:
				case 3498:
				case 3505:
				case 3495:
				case 3508:
				case 3512:
					return new ColorTransform(0.37, 0.29, 0.19);
					break;

				// black hair
				case 2631:
				case 3477:
				case 3488:
				case 3470:
				case 3484:
				case 3481:
				case 3474:
				case 3492:
				case 3502:
				case 3499:
				case 3506:
				case 2634:
				case 3509:
				case 3513:
					return new ColorTransform(0.09, 0.10, 0.19);
					break;
				default:
					return new ColorTransform(1, 1, 1);
			}
		}

		public function showRewardEffect(rewards:Array, rewardItem:SdgItem):void
		{
			ApplicationManager.getInstance().addPopUpsHiddenListener(showQueuedReward);

			function showQueuedReward():void
			{
				ApplicationManager.getInstance().removePopUpsHiddenListener(showQueuedReward);

				var rewardEffect:RewardEffect = new RewardEffect(rewards, rewardItem);

				if (rewardEffect.hasPendingEffect == true)
				{
					rewardEffect.addEventListener(Event.COMPLETE, rewardEffectCompleteHandler);
					_rewardsCounter++;
				}

				if (rewardEffect.rewardDisplay != null)
				{
					addChild(rewardEffect.rewardDisplay);
				}
			}
		}

		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////

		protected function createGenericAvatarResource():AnimationSetResource
		{
			// Depends on gender.
			var imageSource:BitmapData;
			var spriteSheet:SpriteSheet;
			var animationResource:AnimationSetResource;
			if (_avatar.gender == 1)
			{
				// Generic male.
				if (genericMaleImageSource)
				{
					imageSource = genericMaleImageSource;
				}
				else
				{
					imageSource = new BitmapData(genericAvatarImage.width, genericAvatarImage.height, true, 0x00ff00);
					imageSource.draw(genericAvatarImage, null, new ColorTransform(1, 1, 1, 1, -217, -158, -80));
					genericMaleImageSource = imageSource;
				}
			}
			else
			{
				// Generic female.
				if (genericFemaleImageSource)
				{
					imageSource = genericFemaleImageSource;
				}
				else
				{
					imageSource = new BitmapData(genericAvatarImage.width, genericAvatarImage.height, true, 0x00ff00);
					imageSource.draw(genericAvatarImage, null, new ColorTransform(1, 1, 1, 1, -72, -161, -97));
					genericFemaleImageSource = imageSource;
				}
			}

			spriteSheet = new SpriteSheet(_defaultAvatarSpriteCellWidth, _defaultAvatarSpriteCellHeight, imageSource);
			animationResource = new AnimationSetResource(genericAnimationSet, [spriteSheet], item, genericAvatarFilters);

			return animationResource;
		}

		protected function rewardEffectCompleteHandler(event:Event):void
		{
			var rewardEffect:RewardEffect = event.currentTarget as RewardEffect;
			rewardEffect.removeEventListener(Event.COMPLETE, rewardEffectCompleteHandler);

			if (rewardEffect.rewardDisplay != null)
			{
				removeChild(rewardEffect.rewardDisplay);
			}

			_rewardsCounter--;

			if (_rewardsCounter == 0)
			{
				_avatar.resetRewardSync();
			}
		}
	}
}
