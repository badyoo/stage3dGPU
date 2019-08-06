package badyoo.toyBricks.launch
{
	import badyoo.toyBricks.components.*;
	import badyoo.toyBricks.gpu.*;
	import badyoo.toyBricks.utils.FPS;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.System;
	
	
	/**
	 * 移动端的启动配置 
	 * @author badyoo
	 * 
	 */
	public class MobileLaunch extends Sprite
	{
		private static var _logo:Bitmap;
		private var _w:Number;
		private var _h:Number;
		/**
		 * 移动端启动配置 
		 * @param root 继承GPUSprite 的 类
		 * @param w 游戏的宽 场景大于会自动缩放
		 * @param h 游戏的高 场景大于会自动缩放
		 * @param physics2D 是否开启物理引擎
		 * @param debug 调试开关
		 * 
		 */
		public function MobileLaunch( root:Class,w:Number = 640,h:Number = 960,physics2D:Boolean = false,debug:Boolean = false )
		{
			_w = w;
			_h = h;
			
			if( debug )
			{
				LogProcess.Instance.init( stage );
				LogProcess.showSyS();
				var fps:FPS = new FPS( 20,10,10 );
				fps.mouseEnabled = true;
				fps.showMemory = true;
				stage.addChild( fps )
			}
			
			stage.addEventListener( Event.RESIZE,resize );
			
			var stageW:Number = stage.fullScreenWidth;
			var stageH:Number = stage.fullScreenHeight ;
			
			GPU.current.showBatch = true;
			GPU.current.addEventListener(Event.INIT,init );
			NextFrame( GPU.current.init,stage,root,new Rectangle( 0,0,stageW,stageH ) );
			
			
		}
		
		/**
		 * gpu初始化完成 
		 * @param e
		 * 
		 */
		public function init( e:Event = null ):void
		{
			
		}
		
		/**
		 * 初始化Logo显示 
		 * 
		 */
		public function initLogo():void
		{
			
		}
		
		
		/**
		 * 初始化移动端最佳配置，优化效率 
		 * 
		 */
		public function initOptimize():void
		{
			//游戏品质，保证游戏效率
			stage.quality = StageQuality.LOW;
			stage.align = "TL";
			stage.scaleMode = "noScale";
			stage.color = 0x99CCFF;
			System.pauseForGCIfCollectionImminent( 1 );
		}
		
		
		/**
		 * 隐藏logo 
		 * 
		 */
		public static function hideLogo():void
		{
			if( _logo )
			{
				_logo.parent.removeChild( _logo );
				_logo.bitmapData.dispose();
				_logo.bitmapData = null;
				_logo = null;
			}
		}
		
		/**
		 * 自动调整大小 
		 * @param e
		 * 
		 */
		private function resize( e:Event ):void
		{
			log( "resize",stage.stageWidth,stage.stageHeight );
			GPU.current.viewport( stage.stageWidth,stage.stageHeight );
			this.scaleX = stage.stageWidth/_w;
			this.scaleY = stage.stageHeight/_h;
		}
	}
}