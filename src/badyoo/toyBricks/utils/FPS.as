package  badyoo.toyBricks.utils
{
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.profiler.showRedrawRegions;
	import flash.system.System;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * FPS 是一个简单的调试类 可以看到当前游戏的帧频，和内存消耗
	 * @author badyoo QQ:547243998
	 * @langversion 3.0
	 * @playerversion Flash 9
	 */	
	public class FPS extends TextField
	{
		public var showMemory:Boolean;
		private var frameCount:int = 0;
		private var timer:int;
		private var ms_prev:int;
		private var lastfps :int = 0; 
		public static var num:int=0;
		public static var cout:int=0;
		public static var redraw:Boolean=false;
		public static var NumChildren:Boolean=false;
		/**
		 * 这是一个简单的调试类
		 * 可以看到当前游戏的帧频，和内存消耗
		 * @param size 文字大小
		 * @param inX 初始化x位置
		 * @param inY 初始化y位置
		 * @param inCol 颜色
		 */		
		public function FPS(size:int=10,inX:Number=10.0, inY:Number=10.0, inCol:int = 0x000000)
		{
			x = inX;
			y = inY;
			this.mouseEnabled = false;
			selectable = false;
			defaultTextFormat=new TextFormat("宋体", size, 0, true);
			textColor = inCol;
			height=150;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE,dispose);
		}
		/**
		 * 计算当前程序的显示对象个数 
		 * @param stage
		 */		
		public static function getNumChildren(stage:Stage):void{
			FPS.num=-1;
			calculate(stage)
			function calculate(mc:DisplayObjectContainer):void{
				var max:int=mc.numChildren;
				FPS.num+=max;
				for(var i:int=0;i<max;i++){
					if(mc.getChildAt(i) is DisplayObjectContainer){
						calculate(mc.getChildAt(i) as DisplayObjectContainer)
					}
				}
			}
		}
		private function click(e:MouseEvent):void{
			System.gc();
			System.gc();
		}
		private function onAddedHandler(e:Event):void {
			text = "FPS:\n./.";
			if( showMemory )
				appendText('\nMemory:\n'+(System.privateMemory /1024)+"K");
//			appendText('\nChildren:\n'+num);
			this.addEventListener(MouseEvent.MOUSE_DOWN,click);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		private function onEnterFrame(evt:Event):void
		{
			frameCount++;
			if(redraw){
				showRedrawRegions(true,0x0)	
			}
			timer = getTimer();
			if( timer - 1000 > ms_prev )
			{
				lastfps = Math.round(frameCount/(timer-ms_prev)*1000);
				ms_prev = timer;
				text = "FPS:\n" + lastfps + "/" + stage.frameRate;
				if( showMemory )
					appendText('\nMemory:\n'+(System.totalMemory /1024)+"K");
				if( cout > 0 )
					appendText('\nbatch:'+ cout );
				appendText('\n'+num);
				frameCount = 0;
				showRedrawRegions(false,0x0)
				if(NumChildren){
					getNumChildren(stage);
				}
			}
			this.parent.setChildIndex(this,this.parent.numChildren-1);
		}
		private function dispose(e:Event):void{
			this.removeEventListener(MouseEvent.MOUSE_DOWN,click);
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			frameCount = 0;
			timer=0;
			ms_prev=0;
			lastfps=0; 
			num=0;
			cout=0;
			redraw=false;
		}
	}
	
}