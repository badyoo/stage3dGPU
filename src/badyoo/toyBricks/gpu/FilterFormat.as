package badyoo.toyBricks.gpu
{
	import badyoo.toyBricks.utils.Enum;

	/**
	 * 滤镜格式 
	 * @author badyoo
	 * 
	 */
	public class FilterFormat
	{
		/** 没有的 */
		public static const none:int = Enum.reset;
		/** 颜色滤镜 对象的alpha = 1时 会显示异常 */
		public static const ColorMatrixFilter:int = Enum.next;
		public function FilterFormat()
		{
			
		}
	}
}