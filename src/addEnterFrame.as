package
{
	import badyoo.toyBricks.core.LoopManager;

	/**
	 * 添加帧循环
	 * @param onFrame onEnterFrame(passTime:Number):void,需要用removeEnterFrame删除 
	 */
	public function addEnterFrame( onFrame:Function,updatafirst:Boolean = false ):void
	{
		LoopManager.getInstance().addFrame( onFrame,updatafirst );
	}
}