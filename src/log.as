package 
{
	import badyoo.toyBricks.components.LogProcess;
	/**
	 * 输出日志 
	 * @param param 内容
	 */
	public function log(...param):void
	{
		trace.apply(null,param);
		if( LogProcess.init )
			LogProcess.Instance.Trace.apply(null,param);
	}
}