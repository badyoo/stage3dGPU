package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	/**
	 * 当前帧最后阶段
	 */
	public function EndFrame( complete:Function,...param ):void
	{
		
		var mc:MovieClip = new MovieClip();
		nextFrameList.mcList[mc] = mc;
		mc.addEventListener( Event.EXIT_FRAME,
			function frame( e:Event ):void
			{
				delete nextFrameList.mcList[e.target];
				e.target.removeEventListener( Event.EXIT_FRAME,frame );
				if( complete != null )
				{
					if( param.length )
						complete.apply( null,param );
					else
						complete();
				}
				
			}
			,false,0
		)
		
		
		
	}
}
import flash.utils.Dictionary;

class nextFrameList 
{
	//锁住引用，防止垃圾回收
	public static var mcList:Dictionary = new Dictionary();
	public function nextFrameList()
	{
		
	}
}