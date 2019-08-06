package badyoo.toyBricks.gpu
{
	import badyoo.toyBricks.utils.GPUColorMatrixUtils;
	
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	//import nape.phys.Body;

	/**
	 * GPU加速的显示对象基类,跟DisplayObject一样
	 * @author badyoo
	 * @see flash.display.DisplayObject
	 * 
	 */
	public class GPUDisplayObject
	{
//		/** 物理刚体 */
//		public var physicsBody:Body;
		
		/** 显示对象名字 */
		public var name:String;
		/** 舞台坐标x */
		public var globalX:Number;
		/** 舞台坐标y */
		public var globalY:Number;
		/** 显示对象的原点位置x */
		public var centerX:Number;
		/** 显示对象的原点位置y */
		public var centerY:Number;
		/** 显示对象的x坐标 */
		public var x:Number;
		/** 显示对象的y坐标 */
		public var y:Number;
		/** 显示对象的透明度 */
		public var alpha:Number;
		/** 显示对象的旋转度 */
		public var rotation:Number;
		/** 显示对象的水平缩放比例 */
		public var scaleX:Number;
		/** 显示对象的垂直缩放比例 */
		public var scaleY:Number;
		/** 是否可见的 */
		public var visible:Boolean;
		/** 混合模式 */
		public var blendMode:String;
		/** 对象被触摸时回调函数 */
		public var onTouchBegin:Function;
		/** 对象触摸离开时回调函数 */
		public var onTouchEnd:Function;
		/** 对象触摸移动时回调函数 */
		public var onTouchMove:Function;
		/** 是否使用鼠标样式 */
		public var useHandCursor:Boolean;
		/** 是否接受触摸事件 */
		public var touchable:Boolean;
		/** 滤镜 注意：容器有滤镜情况下是会替换子对象的所有滤镜 */
		public var filter:int;
		
		
		private var _colorMatrix:Vector.<Number>;
		
		
		/** 显示对象的二维矩阵 */
		internal var _matrix:Matrix;
		/** 子对象数量 */
		internal var _numChildren:int;
		/** 子对象列表 */
		internal var _displayList:Vector.<GPUDisplayObject>;
		/** 裁剪区域 */
		internal var _clipRect:Rectangle;
		/** 渲染时用的裁剪区域 */
		internal var _renderClipRect:Rectangle;
		/** 纹理列表 */
		internal var _frameList:Vector.<Texture2D>;
		/** 帧频 */
		internal var _fps:int;
		/** 当前帧经过的时间 */
		internal var _currentTime:Number = 0;
		/** 一帧需要的时间 */
		internal var _totalTime:Number = 0;
		/** 需要跳到下一帧 */
		internal var _needNextFrame:Boolean;
		/** 一个布尔值，指示影片剪辑当前是否正在播放。 */
		internal var _isPlaying:Boolean;
		/** 当前帧 */
		internal var _currentFrame:int;
		/** 总帧数 */
		internal var _totalFrames:int;
		/** 显示对象的纹理 */
		internal var _texture:Texture2D;
		/** 显示对象的真实高 */
		internal var _realHeight:Number;
		/** 显示对象的真实宽 */
		internal var _realWidth:Number;
		/** 显示对象的父级 */
		internal var _parent:GPUSprite;
		/** flashPlayer的舞台对象 */
		internal var _stage:Stage;
		/** 渲染用颜色矩阵 */
		internal var _renderColorMatrix:Vector.<Number>;
		public function GPUDisplayObject()
		{
			name = "";
			_realWidth = _realHeight = _numChildren = globalX = globalY = x = y = centerX = centerY = rotation = 0;
			alpha = scaleX = scaleY = 1.0;
			touchable = false;
			blendMode = "normal";
			visible = true;
			filter = FilterFormat.none;
			_matrix = new Matrix();
		
		}
		
		/**
		 * onShow前处理。
		 * 
		 */
		internal function onCallShow( stage:Stage ):void
		{
			this._stage = stage;
			this.onShow();
		}
		
		/**
		 * 在将显示对象直接添加到舞台显示列表或将包含显示对象的子树添加至舞台显示列表中时调度。
		 * 
		 */
		public function onShow():void
		{
			
		}
		
		/**
		 * onRemove前处理。
		 * 
		 */
		internal function onCallRemove():void
		{
			this._stage = null;
			this.onRemove();
		}
		
		/**
		 * 在从显示列表中直接删除显示对象或删除包含显示对象的子树时调度
		 * 
		 */
		public function onRemove():void
		{
			
		}
		
		/**
		 * 将 point 对象从舞台（全局）坐标转换为显示对象的（本地）坐标。  
		 * 
		 */
		public function globalToLocal( point:Point ):Point
		{
			var currentObject:GPUDisplayObject = this;
			while ( currentObject.parent ) 
				currentObject = currentObject.parent;
			
			var matrix:Matrix = new Matrix();
			while ( currentObject != null ) 
			{
				matrix.concat( currentObject._matrix );
				currentObject = currentObject.parent;
			}
			
			matrix.invert();
			var resultPoint:Point = new Point();
			resultPoint.x = matrix.a * point.x + matrix.c * point.y + matrix.tx;
			resultPoint.y = matrix.d * point.y + matrix.b * point.x + matrix.ty;
			return resultPoint;
		}
		
		/**
		 * 将 point 对象从显示对象的（本地）坐标转换为舞台（全局）坐标。  
		 * 
		 */
		public function localToGlobal( point:Point ):Point
		{
			var currentObject:GPUDisplayObject = this;
			while ( currentObject.parent ) 
				currentObject = currentObject.parent;
			
			var matrix:Matrix = new Matrix();
			while ( currentObject != null ) 
			{
				matrix.concat( currentObject._matrix );
				currentObject = currentObject.parent;
			}
			
			var resultPoint:Point = new Point();
			resultPoint.x = matrix.a * point.x + matrix.c * point.y + matrix.tx;
			resultPoint.y = matrix.d * point.y + matrix.b * point.x + matrix.ty;
			return resultPoint;
		}
		
		
		/**
		 * 移到该对象的xy坐标 
		 * @param x
		 * @param y
		 * 
		 */
		public function move( x:Number,y:Number ):void
		{
			this.x = x;
			this.y = y;
		}
		
		/**
		 * 释放这个显示对象 
		 * 
		 */
		public function dispose():void
		{
			 this.onTouchBegin = this.onTouchEnd = this.onTouchMove = null;
			// this.physicsBody = null;
		}
		
		
		/**
		 * 父显示对象属于您无权访问的安全沙箱。通过让父影片调用 Security.allowDomain() 方法，可以避免发生这种情况。
		 * 
		 */
		public function get parent():GPUSprite
		{
			return _parent;
		}
		
		/**
		 * 表示显示对象的高度，以像素为单位。高度是根据显示对象内容的范围来计算的。
		 * 
		 */
		public function get height():Number
		{
			return _realHeight * scaleY;
		}

		/**
		 * 表示显示对象的高度，以像素为单位。高度是根据显示对象内容的范围来计算的。
		 * 
		 */
		public function set height(value:Number):void
		{
			if ( _realHeight != 0.0 ) 
				scaleY = value / _realHeight;
		}

		/**
		 * 表示显示对象的宽度，以像素为单位。宽度是根据显示对象内容的范围来计算的。
		 * 
		 */
		public function get width():Number
		{
			return _realWidth * scaleX;
		}

		/**
		 * 表示显示对象的宽度，以像素为单位。宽度是根据显示对象内容的范围来计算的。
		 * 
		 */
		public function set width(value:Number):void
		{
			if ( _realWidth != 0.0 ) 
				scaleX = value / _realWidth;
		}
		
		/**
		 * 显示对象的舞台。Flash 运行时应用程序仅包含一个 Stage 对象。例如，您可以创建多个显示对象并加载到显示列表中，每个显示对象的 stage 属性是指相同的 Stage 对象（即使显示对象属于已加载的 SWF 文件）。
		 * 如果显示对象未添加到显示列表，则其 stage 属性会设置为 null。
		 * 
		 */
		public function get stage():Stage
		{
			return _stage;
		}

		/** 颜色矩阵默认值为0 */
		public function get colorMatrix():Vector.<Number>
		{
			return _colorMatrix;
		}

		/**
		 * @private
		 */
		public function set colorMatrix(value:Vector.<Number>):void
		{
			_colorMatrix = value;
			
			if( _colorMatrix != null )
			{
				filter = FilterFormat.ColorMatrixFilter;
				alpha = 0.99;
			}
			
			if( _renderColorMatrix == null )
				_renderColorMatrix = new <Number>[];
			
			GPUColorMatrixUtils.create( _colorMatrix,_renderColorMatrix );
			
		}

	}
}