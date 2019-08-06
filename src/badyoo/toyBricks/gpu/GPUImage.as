package badyoo.toyBricks.gpu
{
	import flash.geom.Rectangle;

	/**
	 * GPU加速的图像基础类 
	 * @author badyoo
	 * 
	 */
	public class GPUImage extends GPUDisplayObject
	{
		/**
		 * GPU 图像基础类 
		 * @param texture 该图像的纹理
		 * 
		 */
		public function GPUImage( texture:Texture2D = null )
		{
			setTexture( texture );
		}
		
		/**
		 * 设置纹理 
		 * @param texture
		 * 
		 */
		public function setTexture( texture:Texture2D ):void
		{
			_texture = texture;
			if( _texture )
			{
				_realWidth = texture._width;
				_realHeight = texture._height;
			}
		}
		
		/**
		 * 裁剪区域
		 * @return 
		 * 
		 */
		public function get clipRect():Rectangle
		{
			return _clipRect;
		}
		
		/**
		 * 裁剪区域
		 * @param value
		 * @return 
		 * 
		 */
		public function set clipRect( value:Rectangle ):void
		{
			if (_clipRect && value)
				_clipRect.copyFrom (value );
			else
				_clipRect = ( value ? value.clone() : null);
			
			if( _clipRect )
				_renderClipRect = new Rectangle();
			else
				_renderClipRect = null;
			
		}
		
		override public function dispose():void
		{
			_texture = null;
			_clipRect = null;
			_renderClipRect = null;
			super.dispose();
			
		}
		
	}
}