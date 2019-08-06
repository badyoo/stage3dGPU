package badyoo.toyBricks.gpu
{
	import badyoo.toyBricks.utils.Enum;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	

	/**
	 * GPU的2d纹理对象，通过这里的静态方法创建对应的纹理对象
	 * @author badyoo
	 * @see badyoo.toyBricks.gpu.Texture2D.fromBitmap
	 * @see badyoo.toyBricks.gpu.Texture2D.fromBitmapData
	 * @see badyoo.toyBricks.gpu.Texture2D.fromAtfData
	 * @see badyoo.toyBricks.gpu.Texture2D.fromBGRA_PVR
	 * @see badyoo.toyBricks.gpu.Texture2D.fromTexture
	 */
	public class Texture2D
	{
		/** 纹理类型 --普通纹理 */
		public static const TEXTURE:int = Enum.reset;
		/** 纹理类型 --矩形纹理 */
		public static const RECTANGLE_TEXTURE:int = Enum.next;
		/** 纹理类型 --压缩纹理 */
		public static const ATF:int = Enum.next;
		/** 纹理类型 */
		internal var _type:int;
		/** 纹理的宽 */
		internal var _width:int;
		/** 纹理的高 */
		internal var _height:int;
		/** 纹理的格式 */
		internal var _format:String;
		/** 根纹理 */
		internal var _root:Texture2D;
		/** 用于stage3d的纹理对象 */
		internal var _base:TextureBase;
		/** 当前纹理的UV坐标 */
		internal var _uvFrame:Rectangle;
		/** 当前纹理相对于根纹理里的范围 */
		internal var _region:Rectangle;
		/** 当前纹理导出前影片剪辑的信息 */
		internal var _frame:Rectangle;
		/** 3d上下文，stage3d创建时，GPU会引用给它 */
		internal static var context3d:Context3D;
		public function Texture2D( rect:Rectangle )
		{
			_width = rect.width;
			_height = rect.height;
			_region = rect;
		}
		
		/**
		 * 释放掉当前纹理 
		 * 
		 */
		public function dispose():void
		{
			if( _root == this )
				_base.dispose();
			
			_root = null;
			_base = null;
			_uvFrame = null;
			_region = null;
		}
		
		/**
		 * 设置该纹理的根纹理 
		 * @param value
		 * 
		 */
		internal function set root( value:Texture2D ):void
		{
			_base = value._base;
			_root = value;
			_uvFrame = new Rectangle(
				_region.x / _root._width,
				_region.y / _root._height,
				(_region.width + _region.x) / _root._width,
				(_region.height + _region.y) / _root._height
			)
		}
		
		/**
		 * 用bitmap创建一个纹理对象 
		 * @param bitmap bitmap对象
		 * @param type 纹理的类型 
		 * @param format 纹理的格式
		 * @param optimizeForRenderToTexture 如果纹理很可能用作呈现目标，则设置为 true
		 * @return 
		 * 
		 */
		public static function fromBitmap( bitmap:Bitmap,type:int = 0,format:String = Context3DTextureFormat.BGRA,optimizeForRenderToTexture:Boolean = false ):Texture2D
		{
			return fromBitmapData( bitmap.bitmapData,type,format,optimizeForRenderToTexture );
		}
		
		/**
		 * 用bitmapData创建一个纹理对象 
		 * @param bitmapData bitmapData对象
		 * @param type 纹理的类型 
		 * @param format 纹理的格式
		 * @param optimizeForRenderToTexture 如果纹理很可能用作呈现目标，则设置为 true
		 * @return 
		 * 
		 */
		public static function fromBitmapData( bitmapData:BitmapData,type:int = 0,format:String = Context3DTextureFormat.BGRA,optimizeForRenderToTexture:Boolean = false ):Texture2D
		{
			var texture2d:Texture2D;
			var rect:Rectangle = bitmapData.rect.clone();
			var texture:Texture;
			var rectangleTexture:*;
			
			if( type == TEXTURE )
			{
				texture = context3d.createTexture( rect.width,rect.height,format,optimizeForRenderToTexture );
				texture.uploadFromBitmapData( bitmapData );
				texture2d = new Texture2D( rect );
				texture2d._base = texture;
			}
			else 
			{
				if( "createRectangleTexture" in context3d == false )
				{
					throw new Error( "context3d.createRectangleTexture Method does not exist,Please upgrade to more than 3.6 " );
					return;
				}
				rectangleTexture = context3d["createRectangleTexture"]( rect.width,rect.height,format,optimizeForRenderToTexture );
				rectangleTexture.uploadFromBitmapData( bitmapData );
				texture2d = new Texture2D( rect );
				texture2d._base = rectangleTexture;
				
			}
			texture2d._format = format;
			texture2d._type = type;
			texture2d.root = texture2d;
			return texture2d;
		}
		
		/**
		 * 用ATF纹理创建一个纹理对象,要使用该功能请设置GPU.useATF = true;同时可以看下useATF_alpha,useRGBA
		 * @param atfByte ATF纹理字节数组
		 * @param callBack 纹理异步加载的回调
		 * @return 
		 * 
		 */
		public static function fromAtfData( atfByte:ByteArray,callBack:Function = null,format:String = "" ):Texture2D
		{
			var atf:AtfData = new AtfData( atfByte );
			var texture2d:Texture2D;
			var rect:Rectangle = new Rectangle(0,0,atf.width,atf.height);
			var texture:Texture;
			texture = context3d.createTexture( rect.width,rect.height, format != "" ? format : atf.format,false );
			
			if( callBack != null )
				texture.addEventListener( "textureReady",textureReady );
			
			function textureReady( e:Event ):void
			{
				log( "textureReady",getTimer() - t );
				texture.removeEventListener( "textureReady",textureReady );
				callBack();
			}
			
			var t:int = getTimer();
			texture.uploadCompressedTextureFromByteArray( atf.data,0,callBack != null ? true : false );
			texture2d = new Texture2D( rect );
			texture2d._base = texture;
			texture2d._format = atf.format;
			texture2d._type = ( atf.format == Context3DTextureFormat.COMPRESSED || "compressedAlpha") ? ATF : TEXTURE;
			texture2d.root = texture2d;
			return texture2d;
		}
		
		/**
		 * 用 BRGA8888 pvr纹理创建一个纹理对象 
		 * @param pvrByte  BRGA8888 pvr 字节数组
		 * @param byteArrayOffset 字节数组对象中开始读取纹理数据的位置。
		 * @return 
		 * 
		 */
		public static function fromBGRA_PVR( pvrByte:ByteArray,byteArrayOffset:uint):Texture2D
		{
			if( "createRectangleTexture" in context3d == false )
			{
				throw new Error( "context3d.createRectangleTexture Method does not exist,Please upgrade to more than 3.6 " );
				return;
			}
			var texture2d:Texture2D;
			var rect:Rectangle = new Rectangle(0,0,2042,1500);
			var texture:*;
			texture = context3d["createRectangleTexture"]( rect.width,rect.height,Context3DTextureFormat.BGRA,false );
			texture.uploadFromByteArray( pvrByte,byteArrayOffset + 52 );
			texture2d = new Texture2D( rect );
			texture2d._base = texture;
			texture2d._format = Context3DTextureFormat.BGRA;
			texture2d._type = RECTANGLE_TEXTURE;
			texture2d.root = texture2d;
			return texture2d;
		}
		
		/**
		 * 通过一个Texture2D纹理对象创建一个纹理 
		 * @param texture Texture2D纹理对象
		 * @param region 相对于该纹理对象的矩形位置
		 * @param texture 当前纹理导出前影片剪辑的信息
		 * @return 
		 * 
		 */
		public static function fromTexture( texture:Texture2D, region:Rectangle = null,frame:Rectangle = null ):Texture2D
		{
			var texture2d:Texture2D = new Texture2D( region );  
			texture2d._format = texture._format;
			texture2d._type = texture._type;
			texture2d._frame = frame;
			texture2d.root = texture;
			return texture2d;
		}
	}
}