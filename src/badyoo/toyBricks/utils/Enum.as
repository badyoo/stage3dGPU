package badyoo.toyBricks.utils
{
	/**
	 * 枚举工具 
	 * @author smallpeak
	 */
	public class Enum
	{
		/** 枚举索引 */
		private static var index:uint;
		
		/** 这个数值以下为系统保留枚举  */
		private static const systemKeep:uint = 100000;
		/**系统保留的枚举索引 */
		private static var systemKeepIndex:uint;
		
		/**
		 * 重置枚举 
		 * @return 0
		 */
		public static function get reset():uint
		{
			return index = 0;
		}
		
		/**
		 * 枚举 + 1
		 * @return 
		 */
		public static function get next():uint
		{
			if( index >  systemKeep )
			{
				throw new Error('枚举大小超过系统保留的大小，可以在Enum.systemKeep 设置其保留的大小');
				return 0;
			}
				
			return  ++index;
		}
		/**
		 * 获得系统保留的枚举 
		 * @return 
		 */
		public static function get systemEnum():uint
		{
			return systemKeep + ++systemKeepIndex;
		}

	}
}