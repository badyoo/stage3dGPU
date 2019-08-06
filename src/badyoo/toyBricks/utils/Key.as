package badyoo.toyBricks.utils
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	/**
	 * Key 是一个键盘类
	 * 使用此类必须调用init()初始化
	 * @author badyoo QQ:547243998
	 * @langversion 3.0
	 * @playerversion Flash 9
	 */
	public class Key
	{
		private static var keyObj:Object = {}
		private static var buttonList:Object = {};
		private static var keyOneDownList:Object = {};
		public static function init( stage:Stage ):void
		{
			stage.addEventListener(KeyboardEvent.KEY_UP ,onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN ,onKeyDown);
			stage.addEventListener(Event.ENTER_FRAME,onExit,false,99999);
		}
		
		private static function onKeyUp( e:KeyboardEvent ):void
		{
			keyObj[e.keyCode] = false;
			
			delete keyOneDownList[e.keyCode];
			
		}
		
		private static function onKeyDown( e:KeyboardEvent ):void
		{
			keyObj[e.keyCode] = true;
			
			if( keyOneDownList[e.keyCode] == null )
				keyOneDownList[e.keyCode] = 2;
		}
		
		private static function onExit( e:Event ):void
		{
			for( var str:String in keyOneDownList ) 
			{
				if( keyOneDownList[str] > 0 ) keyOneDownList[str] --;
			}
			
		}
		public static function setButton( name:String,key:uint ):String
		{
			buttonList[name] = key;
			return name;
		}
		
		
		/**
		 * 按着对应的按键
		 * @param key 键控代码值
		 * @return 是否按下
		 */
		public static function isDown( key:uint ):Boolean
		{
			return keyObj[ key ];
		}
		
		/**
		 * 按下对应的按键
		 * @param key 键控代码值
		 * @return 是否按下
		 */
		public static function onkeyDown( key:uint ):Boolean
		{
			if( keyOneDownList[key] == 1 )
				return true;
			return false
		}
		
		/**
		 * 按着按钮 
		 * @param button 按钮名字
		 * @return 
		 * 
		 */
		public static function onButton( button:String ):Boolean
		{
			if( buttonList[button] == null ) return false;
			
			return keyObj[buttonList[button]];
		}
		
		/**
		 * 按下按钮 
		 * @param button 按钮名字
		 * @return 
		 * 
		 */
		public static function onButtonDown( button:String ):Boolean
		{
			if( buttonList[button] == null ) return false;
			
			return onkeyDown(buttonList[button]);
		}
	}
}