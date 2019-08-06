package badyoo.toyBricks.core
{
	import badyoo.toyBricks.utils.Key;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * LoopManager 是一个游戏循环管理器，循环间隔为程序帧率
	 * @author badyoo QQ:547243998
	 * @langversion 3.0
	 * @playerversion Flash 9
	 */
	public class LoopManager extends Sprite
	{
		public static var timeScale:Number = 1; 
		public static var debug:Boolean;
		private static var instance:LoopManager
		public static var passTime:Number;
		public static var noScalePassTime:Number;
		public static var pause:Boolean;
		private var _LastFrameTimestamp:Number;
		private var _now:Number
		private var array:Vector.<Function> = new <Function>[];
		private var arrayIndex:Dictionary = new Dictionary( true );
		private var index:int=0;
		public function LoopManager()
		{
			_LastFrameTimestamp = getTimer() / 1000.0;
			this.addEventListener(  Event.ENTER_FRAME,onEventFrame,false,100 );
			

		}
		/**
		 * 进入帧循环 
		 * @param e
		 */		
		private function onEventFrame( e:Event ):void
		{
			if( debug )
			{
				if( Key.onkeyDown(Keyboard.ESCAPE) )
				{
					pause = !pause;
				}
			}
			if( pause ) return;
			_now = getTimer() / 1000.0;
			passTime = _now - _LastFrameTimestamp;
			_LastFrameTimestamp = _now;
			
			if( passTime > 0.1 ) passTime = 0.1;
			
			noScalePassTime = passTime;
			passTime *= timeScale;
			
			for( var i:int = 0;i<index;i++ ) array[i]();
		}
		
		/**
		 * 添加帧循环 
		 * @param frame onEnterFrame(passTime:Number):void
		 */		
		public function addFrame( frame:Function,updatafirst:Boolean = false ):void{
			if( arrayIndex[ frame ] ) return ;
			
			if( updatafirst )
			{
				log( "1",array.length )
				array.splice(0,0,frame);
				log( array.length )
			}
			else
			{
				array[index] = frame;
			}
			arrayIndex[ frame ] = true;
			index += 1;
		}
		/**
		 * 删除帧循环 
		 * @param frame 实现OnEventFrame接口的实例
		 */		
		public function removeFrame(frame:Function):void{
			
			if( arrayIndex[ frame ] )
			{
				var i:int = array.indexOf( frame );
				if( i == -1 ) return ;
				array.splice( i,1 );
				index-=1;
				
				delete arrayIndex[ frame ];
			}
			
		}
		/**
		 * 帧循环管理器实例 
		 * @return   帧循环管理器实例 
		 */		
		public static function getInstance():LoopManager
		{
			if (instance == null)
				instance=new LoopManager();
			return instance;
		}
	}
}