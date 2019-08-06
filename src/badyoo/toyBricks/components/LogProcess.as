package badyoo.toyBricks.components
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * DebugManager 这是一个调试管理器
	 * 让你在没有编译器时一样可以看到输出,当然必须调用此类Trace的输出才能看到
	 * 必须调用init方法初始化
	 * @author badyoo QQ:547243998
	 * @langversion 3.0
	 * @playerversion Flash 9
	 */	
	public class LogProcess extends Sprite
	{
		private var _state:Boolean=false;
		private var _text:String="";
		private var _btn_show:TextField=new TextField();
		private var _show_text:TextField=new TextField();
		private var _btn_show_textFormat:TextFormat;
		private var _background:Shape=new Shape();
		private static var _instance:LogProcess;//BitmapManager单例
		/**
		 * DebugManager 这是一个调试管理器
		 * 让你在没有编译器时一样可以看到输出,当然必须调用此类Trace的输出才能看到
		 * 必须调用init方法初始化
		 */	
		public function LogProcess(){};
		/**
		 * DebugManager单例
		 */
		public static function get Instance():LogProcess
		{
			if (!_instance) _instance=new LogProcess();
			return _instance;
		}
		
		/**
		 * 是否已经初始化 
		 * @return 
		 * 
		 */
		public static function get init():Boolean
		{
			if( _instance )
				return true;
			return false;
		}
		
		/**
		 * 显示当前系统信息 
		 * 
		 */
		public static function showSyS():void
		{
			log( "os",Capabilities.os );
			log("screenResolutionX:",Capabilities.screenResolutionX,"screenResolutionY:",Capabilities.screenResolutionY );
			log( "version",Capabilities.version );
		}
		
		/**
		 * 初始化 
		 * @param stage 舞台
		 */		
		public function init(stage:Stage):void{
			if( this.stage ){
				return ;
			}
			stage.getChildAt(0).loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,uncaught_error);
			_background.graphics.beginFill(0,0.5);
			_background.graphics.drawRect(0,0,60,20);
			_background.graphics.beginFill(0xFFFFFF);
			_background.graphics.drawRect(1,1,58,18);
			_background.graphics.beginFill(0xFF9900);
			_background.graphics.drawRect(2,2,56,16);
			_background.graphics.endFill();
			_btn_show_textFormat=new TextFormat("",16,0x0,true);	
			_btn_show.selectable=false;
			_btn_show.defaultTextFormat=_btn_show_textFormat;
			_btn_show.text="debug";
			_btn_show.width=60;
			_btn_show.height=22;
			_btn_show.x=8
			_btn_show.y=-3
			this.addChild(	_background);
			this.addChild(_btn_show);
			this.addChild(_show_text);
			_show_text.defaultTextFormat=new TextFormat("",20,0xFFFFFF);
			_show_text.y=20;
			_show_text.height=stage.fullScreenHeight-20;
			_show_text.width=stage.fullScreenWidth;
			_show_text.visible=false;
			_btn_show.addEventListener(MouseEvent.MOUSE_DOWN,btn_show_click);
			stage.addChild(this);
		}
		/**
		 * 系统报错输出 
		 * @param e
		 */		
		private function uncaught_error(e:UncaughtErrorEvent):void{
			var error:Error=e.error;
			Trace(error.getStackTrace());
		}
		/**
		 * 显示按钮点击处理 
		 * @param e
		 */		
		private function btn_show_click(e:MouseEvent):void{
			if(_state){
				_state=false;
				this.graphics.clear();
				_show_text.visible=false;
			}else {
				_state=true;
				this.graphics.clear();
				this.graphics.beginFill(0,0.5);
				this.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
				this.graphics.endFill();
				_show_text.visible=true;
			}
		}
		/**
		 * 通过此方法输出的内容可以在程序屏幕上通过show按钮显示出来 
		 * @param param 要输出的内存
		 */		
		public function Trace(...param):void{
			var max:int=param.length;
			_show_text.appendText("time:["+getTimer()+"]: ");
			for(var i:int=0;i<max;i++){
				_show_text.appendText(param[i]+" ");
			}
			_show_text.appendText("\n");
			_show_text.scrollV=_show_text.maxScrollV;
			if(this.parent){
				this.parent.setChildIndex(this,this.parent.numChildren-1);
			}
		}
	}
}