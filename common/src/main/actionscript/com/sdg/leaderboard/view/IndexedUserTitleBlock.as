package com.sdg.leaderboard.view
{
	import com.good.goodui.FluidView;
	import com.sdg.model.IInitable;
	import com.sdg.view.IndexBlock;
	import com.sdg.view.UserTitleBlock;

	public class IndexedUserTitleBlock extends FluidView implements IInitable
	{
		protected var _indexBlock:IndexBlock;
		protected var _userTitle:UserTitleBlock;
		
		public function IndexedUserTitleBlock(width:Number, height:Number, index:uint, userTitle:UserTitleBlock)
		{
			_indexBlock = new IndexBlock(index, width, height);
			
			_userTitle = userTitle;
			
			addChild(_indexBlock);
			addChild(_userTitle);
			
			super(width, height);
			
			render();
		}
		
		public function init():void
		{
			_userTitle.init();
		}
		
		public function destroy():void
		{
			// Remove displays.
			removeChild(_indexBlock);
			removeChild(_userTitle);
			
			// Destroy children.
			_userTitle.destroy();
			
			// Destroy references to help garbage collection.
			_indexBlock = null;
			_userTitle = null;
		}
		
		override protected function render():void
		{
			super.render();
			
			var spc:Number = 10;
			
			_indexBlock.width = _width * 0.3 - spc / 2;
			_indexBlock.height = _height;
			
			_userTitle.width = _width * 0.7 - spc / 2;
			_userTitle.height = _height;
			_userTitle.x = _indexBlock.width + spc;
		}
		
		public function get maxIndex():uint
		{
			return _indexBlock.maxIndex;
		}
		public function set maxIndex(value:uint):void
		{
			_indexBlock.maxIndex = value;
		}
		
	}
}