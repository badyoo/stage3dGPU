package badyoo.toyBricks.utils
{
	import flash.filters.*;

	public class Filter
	{
		/** 灰阶滤镜矩阵 **/
		private static const grayMatrix:Array = 
			[
				0.3086, 0.6094, 0.0820, 0, 0,
				0.3086, 0.6094, 0.0820, 0, 0, 
				0.3086, 0.6094, 0.0820, 0, 0, 
				0,		0,		0, 		1, 0
			];
		/** 灰色滤镜 **/
		public static const GRAY_FILTER:ColorMatrixFilter = new ColorMatrixFilter( grayMatrix );
		/** 有mask时的描边 **/
		public static const HAVE_MASK_FILTER:GlowFilter = new GlowFilter( 0, 0.8, 2, 2, 1.8 );
		/** 发光滤镜( 黑色 ) **/
		public static const GLOW_FILTER:GlowFilter = new GlowFilter( 0, 0.8, 2, 2, 4 );
		/** 发光滤镜( 白色 ) **/
		public static const GLOW_WHITE_FILTER:GlowFilter = new GlowFilter( 0xfce6cc, 0.5, 2, 2, 3 );
		/** 闪烁发淡蓝光滤镜 **/
		public static const FLASH_BLUE_FILTER:DropShadowFilter = new DropShadowFilter( 0, 0, 0x00aeff, 1, 6, 6, 3, 8 );
		/** 闪烁发紫色光滤镜 **/
		public static const FLASH_PURPLE_FILTER:DropShadowFilter = new DropShadowFilter( 0, 0, 0x9900cc, 1, 6, 6, 3, 8 );
		/** 闪烁发光滤镜内 **/
		public static const FLASH_FILTER_INNER:DropShadowFilter = new DropShadowFilter( 0, 0, 0xffc90e, 1, 4, 4, 3, 8, true );
		/** 闪烁发光滤镜外( 黄色 ) **/
		public static const FLASH_FILTER:DropShadowFilter = new DropShadowFilter( 0, 0, 0xffc90e, 1, 6, 6, 3, 8 );
		/** 闪烁发光滤镜外( 绿色 ) **/
		public static const FLASH_FILTER_BLUE:DropShadowFilter = new DropShadowFilter( 0, 0, 0x00ff00, 1, 6, 6, 3, 8 );
		/** 闪烁发光滤镜外( 白色 ) **/
		public static const FLASH_FILTER_WHITE:DropShadowFilter = new DropShadowFilter( 0, 0, 0xffffff, 1, 6, 6, 3, 8 );
		/** 小范围发光滤镜 **/
		public static const NARROW_FILTER:DropShadowFilter = new DropShadowFilter( 0, 0, 0xffc90e, 0.3, 3, 3, 3, 8 );
		/** 边框发光滤镜 **/
		public static const BORDER_FILTER:DropShadowFilter = new DropShadowFilter( 0, 0, 0xffc90e, 1, 6, 6, 3, 3 );
		/** 黄色边框 挖空滤镜 **/
		public static const YELLOW_KNOCKOUT_BORDER_FILTER:DropShadowFilter = new DropShadowFilter( 0, 0, 0xffc90e, 1, 6, 6, 3, 3, false, true );
		/** 阴影效果 **/
		public static const SHADOW_FILTER:DropShadowFilter = new DropShadowFilter( 6, 45, 0, 0.5 );
		/** 浮雕效果 **/
		public static const FLOAT_SHADOW_FILTER:DropShadowFilter = new DropShadowFilter( 12, 65, 0, 3 );
		/** 蓝白挖空 滤镜 **/
		public static const KNOCKOUT_FILTER:GlowFilter = new GlowFilter( 0xe0ffff, 1, 4, 4, 3, 4, false, true );
		/** 淡黄发光滤镜 自动战斗技能选择面板 等面板选中 **/
		public static const OVER_FILTER:DropShadowFilter = new DropShadowFilter( 0, 0, 0xFFFF00, 0.6, 5, 5, 3, 10 );
		/** 黄色挖空 滤镜 **/
		public static const YELLOW_KNOCKOUT_FILTER:GlowFilter = new GlowFilter( 0xffc90e, 1, 6, 6, 3, 3, false, true );
		/** 蓝色挖空 滤镜 **/
		public static const BLUE_KNOCKOUT_FILTER:GlowFilter = new GlowFilter( 0x00aeff, 1, 6, 6, 3, 3, false, true );
	}
}