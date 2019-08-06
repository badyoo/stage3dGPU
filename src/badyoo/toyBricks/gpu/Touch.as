package badyoo.toyBricks.gpu
{
	/**
	 * 触摸对象，包括触摸事件，跟鼠标事件的代理类 
	 * @author badyoo
	 * 
	 */
	public class Touch
	{
		/** 事件类型 */
		public var type:String;
		/** 全局坐标x */
		public var globalX:Number;
		/** 全局坐标y */
		public var globalY:Number;
		/** 触摸的手指ID，鼠标事件没有 */
		public var touchID:int;
		/** 激活的 */
		public var active:Boolean;
		public function Touch()
		{
			type = "";
			globalX = globalY = 0;
			touchID = -1;
		}
	}
}