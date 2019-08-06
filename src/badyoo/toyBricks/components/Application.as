package badyoo.toyBricks.components
{
	import badyoo.toyBricks.gpu.GPUSprite;
	import badyoo.toyBricks.utils.DisplayUtil;
	
	/**
	 * 通用的程序根，继承GPUSprite
	 * 提供分好的图层
	 * @author badyoo
	 * 
	 */
	public class Application extends GPUSprite
	{
		public static var gameWidth:int = 640;
		public static var gameHeight:int = 960;
		private static var _this:Application;
		private var _topLayer:GPUSprite;
		private var _uiLayer:GPUSprite;
		private var _gameLayer:GPUSprite;
		private var _bottomLayer:GPUSprite;
		public function Application()
		{
			_topLayer = new GPUSprite();
			_uiLayer = new GPUSprite();
			_gameLayer = new GPUSprite();
			_bottomLayer = new GPUSprite();
			DisplayUtil.addChilds( this,_bottomLayer,_gameLayer,_uiLayer,_topLayer );
			_this = this;
		}

		/**
		 * 顶部图层，图层顺序 topLayer > uiLayer > gameLayer > bottomLayer
		 * @return 
		 * 
		 */
		public function get topLayer():GPUSprite
		{
			return _topLayer;
		}

		/**
		 * ui图层，图层顺序 topLayer > uiLayer > gameLayer > bottomLayer
		 * @return 
		 * 
		 */
		public function get uiLayer():GPUSprite
		{
			return _uiLayer;
		}

		/**
		 * 游戏图层，图层顺序 topLayer > uiLayer > gameLayer > bottomLayer
		 * @return 
		 * 
		 */
		public function get gameLayer():GPUSprite
		{
			return _gameLayer;
		}

		/**
		 * 底部图层，图层顺序 topLayer > uiLayer > gameLayer > bottomLayer
		 * @return 
		 * 
		 */
		public function get bottomLayer():GPUSprite
		{
			return _bottomLayer;
		}


	}
}