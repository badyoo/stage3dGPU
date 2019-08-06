package badyoo.toyBricks.gpu
{
	import adobe.utils.AGALMiniAssembler;
	
	import badyoo.toyBricks.components.Application;
	import badyoo.toyBricks.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.ui.*;
	import flash.utils.*;
	
	//import nape.geom.Vec2;
	
	[Event( type="flash.events.Event", name="init" )]
	/**
	 * 2D 渲染引擎 
	 * @author badyoo
	 * 
	 */
	public class GPU extends EventDispatcher
	{		
		
		/** GPU状态 停止 */
		public static const GPU_STATE_STOP:int = Enum.reset;
		/** GPU状态 运行 */
		public static const GPU_STATE_RUN:int = Enum.next;
		/** GPU状态 暂停 */
		public static const GPU_STATE_PAUSE:int = Enum.next;
		private static var _current:GPU;
		/** 当前gpu环境 */
		public static function get current():GPU
		{
			if( _current == null )
				_current = new GPU();
			
			return _current;
		}
		public static function get context3d():Context3D
		{
			return current._context3d;
		}
		
		/** 显示重绘次数 需要addChild FPS */
		public var showBatch:Boolean = false;
		/** 启用多点触摸 */
		public var multitouchEnabled:Boolean;
		/** 使用透明压缩纹理 */
		public var useATF_alpha:Boolean;
		/** 使用非透明压缩纹理 */
		public var useATF:Boolean;
		/** 使用普通位图 */
		public var useRGBA:Boolean;
		/** 使用颜色矩阵 */
		public var useColorMatrix:Boolean;
		/** 使用CPU运算2维坐标 */
		public var useCPUlocation:Boolean;
		
		/** GPU显示列表的root类 */
		private var _rootClass:Class;
		private var _root:GPUSprite;
		/** 舞台 */
		private var _stage:Stage;
		/** 是否启用debug */
		private var _debug:Boolean;
		/** GPU 运行状态 */
		private var _runstate:int
		/** GPU显示的区域 */
		private var _showRectangle:Rectangle;
		/** GPU显示区域是否改变 */
		private var _changeViewPort:Boolean;
		/** GPU 背景色 R */
		private var _red:Number;
		/** GPU 背景色 G */
		private var _green:Number;
		/** GPU 背景色 B */
		private var _blue:Number;
		/** GPU缓存的顶点索引缓冲器 */
		internal var _indexBufferList:Vector.<IndexBuffer3D>;
		/** GPU缓存的顶点缓冲器 4个矢量*/
		internal var _positionBufferList:Vector.<VertexBuffer3D>;
		/** GPU缓存的顶点缓冲器 需要透明度的 5个矢量*/
		internal var _alphaPositionBufferList:Vector.<VertexBuffer3D>;
		/** GPU 缓存器的大小 */
		internal var _indexNum:int = 36000;
		/** GPU 顶点索引,顶点 初始化创建的数量,数量也代表其支持的顶点数 */
		internal var _indexMin:int = 100;
		/** GPU RGBA着色器 */
		internal var _program_rgb:int = Enum.reset;
		/** GPU RGBA着色器 需要着色运算的*/
		internal var _program_rgb_tinted:int = Enum.next;
		/** GPU RGBA颜色矩阵着色器  */
		internal var _program_rgb_colorMatrix:int = Enum.next;
		/** GPU 透明ATF着色器*/
		internal var _program_compressed_alpha:int = Enum.next;
		/** GPU 透明ATF着色器 需要着色运算的*/
		internal var _program_compressed_alpha_tinted:int = Enum.next;
		/** GPU 透明ATF颜色矩阵着色器  */
		internal var _program_compressed_alpha_colorMatrix:int = Enum.next;
		/** GPU ATF着色器*/
		internal var _program_compressed:int = Enum.next;
		/** GPU ATF着色器 需要着色运算的*/
		internal var _program_compressed_tinted:int = Enum.next;
		/** GPU ATF颜色矩阵着色器  */
		internal var _program_compressed_colorMatrix:int = Enum.next;
		/** GPU 着色器 长度*/
		internal var _program_none:int = Enum.next;
		/** GPU 颜色矩阵着色器 最小颜色*/
		private static const MIN_COLOR:Vector.<Number> = new <Number>[0, 0, 0, 0.0001];
		
		/** GPU stage3d 实例 */
		private var _stage3d:Stage3D;
		/** GPU Context3D环境 */
		internal var _context3d:Context3D;
		/** GPU 二维矩阵 */
		internal var _camera:Matrix3D;
		/** GPU 着色器列表 */
		internal var _programList:Vector.<Program3D>;
		/** GPU 上一个次的着色器 */
		internal var _lastProgram:Program3D;
		/** GPU 上一个次的纹理 */
		internal var _lastTexture:Texture2D;
		/** GPU 上一个使用的混合模式 */
		internal var _lastBlendMode:String;
		/** GPU 混合模式列表 预乘 alpha*/
		internal var _blendModePremultipliedAlpha:Object = { 
			"none"     : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO ],
			"normal"   : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
			"add"      : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE ],
			"multiply" : [ Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
			"screen"   : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR ],
			"erase"    : [ Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ]
		}
		/** GPU 混合模式列表  没有预乘 alpha*/
		internal var _blendMode:Object = { 
			"none"     : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO ],
			"normal"   : [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
			"add"      : [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA ],
			"multiply" : [ Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
			"screen"   : [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE ],
			"erase"    : [ Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ]
		}
			
		public function GPU()
		{
			useATF = useATF_alpha = false;
			useRGBA = true;
		}
		
		/** GPU环境 运行  */
		public function run():void
		{
			_runstate = GPU_STATE_RUN;
		}
		
		/** GPU环境 暂停 */
		public function pause():void
		{
			_runstate = GPU_STATE_PAUSE;
		}
		
		/**
		 * GPU场景大小 
		 * @param width
		 * @param height
		 * 
		 */
		public function viewport( width:int,height:int ):void
		{
			if( _showRectangle )
			{
				_showRectangle.width = width;
				_showRectangle.height = height;
				_changeViewPort = true;
			}
			
		}
		
		/**
		 * 设置GPU背景颜色 
		 * @param rgb
		 * 
		 */
		public function setColor( rgb:uint ):void{
			_red = Color.getRed( rgb ) / 255.0; _green = Color.getGreen( rgb ) / 255.0; _blue = Color.getBlue( rgb ) / 255.0;
		}
		
		/**
		 * 初始化GPU渲染器 
		 * @param stage 舞台
		 * @param rootClass GPU显示列表的Root
		 * @param showRectangle GPU场景大小
		 * @param debug 是否启用GPU debug
		 * 
		 */
		public function init( stage:Stage,rootClass:Class,showRectangle:Rectangle,stage3d:Stage3D = null,debug:Boolean = false ):void
		{
			if( _rootClass ) return;
			var rootClassStr:String = getQualifiedSuperclassName( rootClass );
			if( rootClassStr.indexOf( "GPUSprite" ) == -1 && rootClassStr.indexOf("Application") == -1 && rootClass != GPUSprite && rootClass != Application )
			{
				log( " gpu 显示列表的根 必须继承 GPUSprite " );
				return;
			}
			
			positionVector.endian = Endian.LITTLE_ENDIAN;
			_runstate = GPU_STATE_STOP;_stage = stage;_debug = debug;_rootClass = rootClass;_showRectangle = showRectangle;
			_stage3d = stage3d ? stage3d :_stage.stage3Ds[0];
			_camera = new Matrix3D();
			
			setColor( _stage.color );
			
			//mouse Event
			if( multitouchEnabled )
			{
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				_stage.addEventListener( TouchEvent.TOUCH_BEGIN,onTouch );
				_stage.addEventListener( TouchEvent.TOUCH_END,onTouch );
				_stage.addEventListener( TouchEvent.TOUCH_MOVE,onTouch );
			}
			else
			{
				_stage.addEventListener( MouseEvent.MOUSE_MOVE,onTouch );
				_stage.addEventListener( MouseEvent.MOUSE_DOWN,onTouch );
				_stage.addEventListener( MouseEvent.MOUSE_UP,onTouch );
			}
			
			//stage3d Event
			_stage3d.addEventListener( ErrorEvent.ERROR,stage3dRequest,false,99999,true );
			_stage3d.addEventListener( Event.CONTEXT3D_CREATE,stage3dRequest,false,99999,true );
			
			if( "requestContext3DMatchingProfiles" in _stage3d )
			{
				var profiles:Vector.<String> = new Vector.<String>();
				var context3DProfileClass:Object = getDefinitionByName( "flash.display3D.Context3DProfile" );
				if( context3DProfileClass["STANDARD"] ) profiles.push("standard");
				if( context3DProfileClass["BASELINE_EXTENDED"] ) profiles.push("baselineExtended");
				if( context3DProfileClass["BASELINE"] ) profiles.push("baseline");
				_stage3d["requestContext3DMatchingProfiles"]( profiles );
			}
			else
			{
				var requestContext3D:Function = _stage3d.requestContext3D;
				if(	requestContext3D.length > 1 )
					requestContext3D( "auto","baseline" );
				else
					requestContext3D( "auto" );
			}
			
			
			_stage.addEventListener( Event.ENTER_FRAME,onRender,false, -999999, false );
		}
			
		/**
		 * stage3d 请求处理，构建依赖的着色器跟预创建的顶点，初始化根显示列表 
		 * @param e
		 * 
		 */
		private function stage3dRequest( e:Event ):void
		{
			if( e.type == ErrorEvent.ERROR ){
				log( "stage3dRequest error" );
			}
			else
			{
				pause();
				
				if( _context3d ) log( "GPU lost response ,Restructure stage3d done" );
				else log( "stage3dRequest done" );
				
				_changeViewPort = true;
				_context3d = _stage3d.context3D;
				_context3d.enableErrorChecking = _debug;
				_context3d.setCulling( Context3DTriangleFace.NONE );
				_context3d.setDepthTest( false,Context3DCompareMode.ALWAYS );
				GPUAuxiliary.install( this );
				
				if( _root == null )
				{
					_root = new _rootClass;
					_root.onCallShow( _stage );
				}
				
				dispatchEvent( new Event( Event.INIT ) );
				
				run();
				
				if( "profile" in _context3d ) log( _context3d.driverInfo,_context3d["profile"] );
				else log( _context3d.driverInfo );
				
				
			}
		}		
		
		
		
		/** 当前处理的递归的鼠标事件 */
		private var touch:Touch;
		
		/**
		 * 将舞台的鼠标事件派遣到显示列表
		 * @param e
		 * 
		 */
		private function onTouch( e:Object ):void
		{
			if( _root == null ) return;
			
			if( touch == null ) touch = new Touch();
			
			touch.type = e.type;touch.active = true;
			
			if( e is MouseEvent )
			{
				touch.globalX = e.stageX;
				touch.globalY = e.stageY;
			}
			
			if( e is TouchEvent )
			{
				touch.globalX = e.localX;
				touch.globalY = e.localY;
				touch.touchID = e.touchPointID;
			}
			
			//派遣鼠标事件
			dispatchTouchEvent( _root,stage3d.x,stage3d.y,true );
		}
		
		/** 对象的触发区域 */
		private var bound:Rectangle = new Rectangle();
		/** 点击事件递归的触发点 */
		private var touchPoint:Point = new Point();
		private var touchMatrix:Matrix = new Matrix();
		/**
		 * 递归所有显示对象，由上到下的递归并且转换点击矩阵到触发对象的局部区域 
		 * @param container 显示容器
		 * @param localX 鼠标当前容器的坐标
		 * @param localY 鼠标当前容器的坐标
		 * @param isRoot 是否根容器
		 * 
		 */
		private function dispatchTouchEvent( container:GPUDisplayObject,localX:Number = 0,localY:Number = 0,isRoot:Boolean = false ):void
		{
			var display:GPUDisplayObject,parent:GPUDisplayObject,displayList:Vector.<GPUDisplayObject> = container._displayList;
			var x:Number = localX,y:Number = localY;
			if( isRoot )
			{
				if( touch.active == false )
					return;
				
				touchMatrix.setTo( container._matrix.a,container._matrix.b,container._matrix.c,container._matrix.d,container._matrix.tx+x,container._matrix.ty+y );
				touchMatrix.invert();
				x = touchMatrix.a * touch.globalX + touchMatrix.c * touch.globalY + touchMatrix.tx;
				y = touchMatrix.d * touch.globalY + touchMatrix.b * touch.globalX + touchMatrix.ty;
			}
			
			for ( var i:int = container._numChildren - 1;i >= 0;i-- )
			{
				if( touch.active == false ) return;
				
				display = displayList[i];
				
				if( display.visible && display.touchable && touch.active )
				{
					//touchMatrix.copyFrom( display._matrix );
					touchMatrix.setTo( display._matrix.a,display._matrix.b,display._matrix.c,display._matrix.d,display._matrix.tx,display._matrix.ty );
					touchMatrix.invert();
					bound.width  = display.width;
					bound.height = display.height;
					touchPoint.x = touchMatrix.a * x + touchMatrix.c * y + touchMatrix.tx;
					touchPoint.y = touchMatrix.d * y + touchMatrix.b * x + touchMatrix.ty;
					
					if( display._numChildren > 0 )
					{
						dispatchTouchEvent( display,touchPoint.x,touchPoint.y );
					}
					else
					{
						if( display && bound.containsPoint( touchPoint ) )
						{
							switch( touch.type )
							{
								case MouseEvent.MOUSE_DOWN:
								case TouchEvent.TOUCH_BEGIN:
									
									if( display.onTouchBegin != null ) display.onTouchBegin.call( null,display );
									
									parent = display.parent;
									
									while( parent )
									{
										if( parent.onTouchBegin != null ) parent.onTouchBegin.call( null,display );
										
										parent = parent.parent;
									}
									
									break;
								
								case MouseEvent.MOUSE_UP:
								case TouchEvent.TOUCH_END:
									
									if( display.onTouchEnd != null ) display.onTouchEnd.call( null,display );
									
									parent = display.parent;
									
									while( parent )
									{
										if( parent.onTouchEnd != null ) parent.onTouchEnd.call( null,display );
										
										parent = parent.parent;
									}
									break;
								
								case MouseEvent.MOUSE_MOVE:
								case TouchEvent.TOUCH_MOVE:
									Mouse.cursor = display.useHandCursor ? MouseCursor.BUTTON : MouseCursor.AUTO;
									
									if( display.onTouchMove != null ) display.onTouchMove.call( null,display );
									
									parent = display.parent;
									
									while( parent )
									{
										if( parent.onTouchMove != null ) parent.onTouchMove.call( null,display );
										
										parent = parent.parent;
									}
									
									break;
							}
							
							touch.active = false;
						}
					}
				}
				
			}
			
		}
		
		/**
		 * 运行GPUMovieClip的帧脚本回调
		 */
		private function runFrameScript( len:int ):void
		{
			var movieCliplist:Vector.<GPUMovieClip> = GPUMovieClip._needScript;
			for ( var i:int = 0 ; i<len ; i++ )
			{
				var movieClip:GPUMovieClip = movieCliplist[i];
				
				if( movieClip._frameScriptIndex == 0 )
				{
					movieCliplist.splice( i,1 );
					GPUMovieClip._needScriptIndex --;
					i--;
					len--;
					continue;
				}
				
				var callBack:Function = movieClip._frameScriptList[movieClip._currentFrame];
				if( callBack != null ) callBack();
			}
		}
		
		/** 渲染计时 */
		private var t:int;
		/** 渲染绘制次数 */
		public var cout:int;
		/** 上一帧的时间 */
		private var _LastTime:Number = 0.0;
		/** 现在的时间 */
		private var _nowTime:Number = 0.0;
		private var _passTime:Number = 0.0;
		
		/**
		 * 渲染stage3d 
		 * @param e
		 * 
		 */
		private function onRender( e:Event ):void
		{
			if( _context3d && _context3d.driverInfo != "Disposed")
			{
				//创建GPU场景区域
				if( _changeViewPort )
				{
					_context3d.configureBackBuffer( _showRectangle.width,_showRectangle.height,0,false );
					_camera.identity();
					//3维转2维空间
					_camera.appendTranslation( -_showRectangle.width/2, -_showRectangle.height/2, 0 );
					_camera.appendScale( 2.0/_showRectangle.width, -2.0/_showRectangle.height, 1 );
					_context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _camera,true );
					_changeViewPort = false;
				
				}
				
				_nowTime = getTimer() / 1000.0;_passTime = _nowTime - _LastTime;_LastTime = _nowTime;
				
				if( _runstate == GPU_STATE_RUN )
				{
					cout = 0;
					//删除上次渲染的东西
					_context3d.clear( _red,_green,_blue );
					
					//GPUMovieClip帧脚本回调
					if( GPUMovieClip._needScriptIndex > 0 ) runFrameScript( GPUMovieClip._needScriptIndex );
					
					if( _root.filter != FilterFormat.none ) lastFilterDisPlay = _root;
					//渲染前计算
					renderSprite( _root,_root.alpha,null,_root.filter );
					lastFilterDisPlay = null;
					//渲染
					_context3d.present();
					
				}
			}
			
			if( showBatch )
				FPS.cout = cout;
			//			log( cout );
			//			log("render", getTimer() -t );
		}
		/** 顶点数据池 byte */
		private var positionVector:ByteArray = new ByteArray();
		private var matrixPool:Vector.<Matrix> = new <Matrix>[];
		private var batchIndex:int;
		private var lastAlpha:Boolean;
		private var last:GPUDisplayObject;
		private var lastFilterDisPlay:GPUDisplayObject;
		//private var graphicOffset:Vec2 = new Vec2();
		/**
		 * 递归渲染，按照画家算法，形成2d显示列表的深度排序，转换矩阵实现显示列表的缩放，旋转，透明度，坐标空间等 
		 * @param container 显示容器
		 * @param parentAlpha 上一级的透明值
		 * @param parentMatrix 上一级的二维矩阵
		 * @param filter 滤镜枚举
		 * 
		 */
		private function renderSprite( container:GPUDisplayObject,parentAlpha:Number = 1.0,parentMatrix:Matrix = null,filter:int = 0 ):void
		{
			var childMatrix:Matrix = matrixPool.shift();
			
			if( childMatrix == null ) 
				childMatrix = new Matrix();
			
			var len:int = container._numChildren;
			var positionVertexBuffer3D:VertexBuffer3D,indexBudder3d:IndexBuffer3D;
			var displayList:Vector.<GPUDisplayObject> = container._displayList;
			var display:GPUDisplayObject;
			var blendModeArray:Array,i:int,needAlpha:Boolean;
			var cos:Number,sin:Number,a:Number,b:Number,c:Number,d:Number,tx:Number,ty:Number;
			//显示列表矩阵
			if( parentMatrix == null )
			{	
				parentMatrix = container._matrix;
				if ( container.rotation == 0 )
				{
					parentMatrix.setTo(
						container.scaleX, 0.0, 0.0, container.scaleY, 
						container.x - container.centerX * container.scaleX, container.y - container.centerY * container.scaleY
					);
				}
				else
				{
					cos = Math.cos( container.rotation );
					sin = Math.sin( container.rotation );
					a = container.scaleX *  cos;
					b = container.scaleX *  sin;
					c = container.scaleY * -sin;
					d = container.scaleY *  cos;
					tx = container.x - container.centerX * a - container.centerY * c;
					ty = container.y - container.centerX * b - container.centerY * d;
					
					parentMatrix.setTo( a, b, c, d, tx, ty );
				}
				
			}
			
			for ( i= 0 ; i<len ; i++ )
			{
				
				display = displayList[i];
				
//				//物理引擎位置更新
//				if( display.physicsBody && display.physicsBody.isSleeping == false )
//				{
//					graphicOffset.x = display.physicsBody.userData.graphicOffsetX;
//					graphicOffset.y = display.physicsBody.userData.graphicOffsetY;
//					var position:Vec2 = display.physicsBody.localPointToWorld(graphicOffset);
//					display.x = position.x;
//					display.y = position.y;
//					display.rotation = display.physicsBody.rotation;
//					position.dispose();
//				}
				
				needAlpha = false;
				
				//如果是影片剪辑，那么判断是否满足换帧的需求
				if( display._isPlaying && display._totalFrames > 1 )
				{
					if( display._needNextFrame )
					{
						display._currentTime += _passTime;
						var passFrame:int = display._currentTime/display._totalTime;
						if( passFrame > 0 )
						{
							display._currentTime = 0;
							display._currentFrame += passFrame;
							if( display._currentFrame >=  display._totalFrames )
								display._currentFrame = 0;
							
							display._texture = display._frameList[display._currentFrame];
							display._realWidth = display._texture._width;
							display._realHeight = display._texture._height;
							display.centerX = display._texture._frame ? display._texture._frame.x : 0;
							display.centerY = display._texture._frame ? display._texture._frame.y : 0;
						}
					}
					display._needNextFrame = true;
				}
				
				var tempMatrix:Matrix = display._matrix;
				//显示列表矩阵
				if ( display.rotation == 0 )
				{
					tempMatrix.setTo(
						display.scaleX, 0.0, 0.0, display.scaleY, 
						display.x - display.centerX * display.scaleX, display.y - display.centerY * display.scaleY
					);
				}
				else
				{
					cos = Math.cos( display.rotation );
					sin = Math.sin( display.rotation );
					a = display.scaleX *  cos;
					b = display.scaleX *  sin;
					c = display.scaleY * -sin;
					d = display.scaleY *  cos;
					tx = display.x - display.centerX * a - display.centerY * c;
					ty = display.y - display.centerX * b - display.centerY * d;
					
					tempMatrix.setTo(a, b, c, d, tx, ty);
				}
				
				
				childMatrix.setTo(
					parentMatrix.a * tempMatrix.a + parentMatrix.c * tempMatrix.b,
					parentMatrix.b * tempMatrix.a + parentMatrix.d * tempMatrix.b,
					parentMatrix.a * tempMatrix.c + parentMatrix.c * tempMatrix.d,
					parentMatrix.b * tempMatrix.c + parentMatrix.d * tempMatrix.d,
					parentMatrix.tx + parentMatrix.a * tempMatrix.tx + parentMatrix.c * tempMatrix.ty,
					parentMatrix.ty + parentMatrix.b * tempMatrix.tx + parentMatrix.d * tempMatrix.ty
				);
				
				display.globalX =  childMatrix.tx;
				display.globalY =  childMatrix.ty;
				
				
				var alpha:Number = display.alpha * parentAlpha;
				//需要透明混合的
				if( alpha < 1 ) needAlpha = true;
				
				//相邻的矩形状态不一样就会触发绘制，一样的会放在一起，下次批处理 ,必须有纹理的对象才进行对比
				if( last && display._texture && display._texture._root )
				{
					if( last._texture._root != display._texture._root 
						|| display.blendMode != last.blendMode 
						|| needAlpha != lastAlpha 
						|| last._clipRect != display._clipRect 
						||( filter == FilterFormat.none && last.filter != display.filter )
					)
					{
						var currentBatchIndex:int = batchIndex -1;
						var vertexMax:int = 4*batchIndex;
						positionVertexBuffer3D = lastAlpha ? _alphaPositionBufferList[currentBatchIndex] : _positionBufferList[currentBatchIndex];
						if( positionVertexBuffer3D == null )
						{
							if( lastAlpha )
								_alphaPositionBufferList[currentBatchIndex] = positionVertexBuffer3D = GPUAuxiliary.geVertexBuffer( vertexMax,5 );
							else
								_positionBufferList[currentBatchIndex] = positionVertexBuffer3D = GPUAuxiliary.geVertexBuffer( vertexMax,4 );
						}
						
						positionVertexBuffer3D.uploadFromByteArray( positionVector,0,0,vertexMax );
						
						var programIndex:int;
						//判断是否使用透明混合的着色器 ，这个着色器是手机的克星，效率很低
						if( last._texture._format == Context3DTextureFormat.COMPRESSED )
						{
							if( filter == FilterFormat.ColorMatrixFilter || last.filter == FilterFormat.ColorMatrixFilter )
							{
								_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, filter == FilterFormat.ColorMatrixFilter ? lastFilterDisPlay._renderColorMatrix : last._renderColorMatrix );
								_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, MIN_COLOR);
								_context3d.setProgram( _programList[ _program_compressed_colorMatrix ] );
								_lastProgram =_programList[ _program_compressed_colorMatrix ];
							}
							else 
							{
								programIndex = lastAlpha ? _program_compressed_tinted:_program_compressed;
							}
						}
						else if( last._texture._format == "compressedAlpha" )
						{
							if( filter == FilterFormat.ColorMatrixFilter || last.filter == FilterFormat.ColorMatrixFilter )
							{
								_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, filter == FilterFormat.ColorMatrixFilter ? lastFilterDisPlay._renderColorMatrix : last._renderColorMatrix );
								_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, MIN_COLOR);
								_context3d.setProgram( _programList[ _program_compressed_alpha_colorMatrix ] );
								_lastProgram =_programList[ _program_compressed_alpha_colorMatrix ];
							}
							else 
							{
								programIndex = lastAlpha ? _program_compressed_alpha_tinted:_program_compressed_alpha;	
							}
						}
						else
						{
							if( filter == FilterFormat.ColorMatrixFilter || last.filter == FilterFormat.ColorMatrixFilter )
							{
								_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, filter == FilterFormat.ColorMatrixFilter ? lastFilterDisPlay._renderColorMatrix : last._renderColorMatrix );
								_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, MIN_COLOR);
								_context3d.setProgram( _programList[ _program_rgb_colorMatrix ] );
								_lastProgram =_programList[ _program_rgb_colorMatrix ];
							}
							else 
							{
								programIndex = lastAlpha ? _program_rgb_tinted:_program_rgb;
							}
						}
						
						if( _lastProgram !=  _programList[ programIndex ] )
						{
							_context3d.setProgram( _programList[ programIndex ] );
							_lastProgram = _programList[ programIndex ];
						}
						
						if( _lastTexture != last._texture._root )
						{
							_context3d.setTextureAt( 0, last._texture._base );
							_lastTexture = last._texture._root;	
						}
						
						_context3d.setVertexBufferAt( 0,positionVertexBuffer3D,0,lastAlpha ? Context3DVertexBufferFormat.FLOAT_3: Context3DVertexBufferFormat.FLOAT_2 );
						_context3d.setVertexBufferAt( 1,positionVertexBuffer3D,lastAlpha ? 3: 2,Context3DVertexBufferFormat.FLOAT_2 );
						
						//设置混合模式
						if( _lastBlendMode != last.blendMode )
						{
							if( last._texture._type != Texture2D.ATF )
								blendModeArray = _blendModePremultipliedAlpha[last.blendMode];
							else 
								blendModeArray = _blendMode[last.blendMode];
							
							_context3d.setBlendFactors( blendModeArray[0],blendModeArray[1] );
							_lastBlendMode = last.blendMode;
						}
						
						indexBudder3d = _indexBufferList[currentBatchIndex];
						if( indexBudder3d == null )
							_indexBufferList[currentBatchIndex] = indexBudder3d = GPUAuxiliary.getindexBuffer( batchIndex );
						
						if( last._clipRect )
						{
							_context3d.setScissorRectangle( last._renderClipRect );
						}
							
						
						_context3d.drawTriangles( indexBudder3d );
						
						if( last._clipRect )
							_context3d.setScissorRectangle( null );
						
						batchIndex = 0;
						lastAlpha = false;
						cout ++;
						last = null;
						positionVector.position = 0;
					}					
				}
				
				if( display.visible )
				{
					//纹理贴图，2维坐标计算
					if( display._texture )
					{
						var positionIndex:int = batchIndex * ( needAlpha ? 20 : 16 );
						var widthA:Number = childMatrix.a *  display._realWidth;
						var widthB:Number = childMatrix.b *  display._realWidth;
						var heightC:Number = childMatrix.c * display._realHeight;
						var heightD:Number = childMatrix.d * display._realHeight;
						
						if( useCPUlocation )
						{
							var showRectangle2width:Number = 2/_showRectangle.width;
							var showRectangle2height:Number = 2/-_showRectangle.height;
						}
						
						var temp:Number = 0;
						
						//该对象有裁剪
						if( display._clipRect )
						{
							display._renderClipRect.x = display.globalX;
							display._renderClipRect.y = display.globalY;
							
							display._renderClipRect.width = display._clipRect.width * childMatrix.a;
							display._renderClipRect.height = display._clipRect.height * childMatrix.d;
							
						}
						
						var uvX:Number = display._texture._uvFrame.x;
						var uvY:Number = display._texture._uvFrame.y;
						var uvWidth:Number = display._texture._uvFrame.width;
						var uvheight:Number = display._texture._uvFrame.height;
						
						//position 0
						temp = heightC + childMatrix.tx;
						if( useCPUlocation ) temp = showRectangle2width * temp -1;
						//positionVector[ positionIndex++ ] = temp; //x
						positionVector.writeFloat( temp );
						
						temp = heightD + childMatrix.ty;
						if( useCPUlocation ) temp = showRectangle2height * temp +1;
						//positionVector[ positionIndex++ ] = temp; //y
						positionVector.writeFloat( temp );						
						if( needAlpha ) positionVector.writeFloat( alpha );
						
						//positionVector[ positionIndex++ ] = uvX;//uv x
						positionVector.writeFloat( uvX )
						//positionVector[ positionIndex++ ] = uvheight;//uv y
						positionVector.writeFloat( uvheight )
						
						//position 1
						temp = childMatrix.tx;
						if( useCPUlocation ) temp = showRectangle2width * temp -1
						positionVector.writeFloat( temp );
						
						temp = childMatrix.ty;
						if( useCPUlocation ) temp = showRectangle2height * temp +1
						positionVector.writeFloat( temp );
						
						if( needAlpha )	positionVector.writeFloat( alpha );
						
						positionVector.writeFloat( uvX );
						positionVector.writeFloat( uvY );
						
						//position 2
						temp = widthA + childMatrix.tx;
						if( useCPUlocation ) temp = showRectangle2width * temp -1;
						positionVector.writeFloat( temp );
						
						temp = widthB + childMatrix.ty;
						if( useCPUlocation ) temp = showRectangle2height * temp + 1
						positionVector.writeFloat( temp );
						
						if( needAlpha ) positionVector.writeFloat( alpha );
						
						positionVector.writeFloat( uvWidth );
						positionVector.writeFloat( uvY );
						
						//position 3
						temp = widthA + heightC + childMatrix.tx;
						if( useCPUlocation ) temp = showRectangle2width * temp - 1;
						positionVector.writeFloat( temp );
						
						temp = heightD + widthB + childMatrix.ty;
						if( useCPUlocation ) temp = showRectangle2height * temp + 1
						positionVector.writeFloat( temp );
						
						if( needAlpha ) positionVector.writeFloat( alpha );
						
						positionVector.writeFloat( uvWidth );
						positionVector.writeFloat( uvheight );
						
						batchIndex ++;
						last = display;
						lastAlpha = needAlpha;
					}
					
					if( display._numChildren > 0 )
					{
						if( filter == FilterFormat.none && display.filter != FilterFormat.none )
								lastFilterDisPlay = display;
							
						renderSprite( display,alpha,childMatrix,filter != FilterFormat.none ? filter : display.filter );
						
						if( lastFilterDisPlay == display )
							lastFilterDisPlay = null;
					}
				}
				
			}
			
			//下面这里是当一个容器只批处理一次时需要的
			if( batchIndex > 0 && container == _root )
			{
				currentBatchIndex = batchIndex -1;
				vertexMax = 4*batchIndex;
				positionVertexBuffer3D = lastAlpha ? _alphaPositionBufferList[currentBatchIndex] : _positionBufferList[currentBatchIndex];
				if( positionVertexBuffer3D == null )
				{
					if( lastAlpha )
						_alphaPositionBufferList[currentBatchIndex] = positionVertexBuffer3D = GPUAuxiliary.geVertexBuffer( vertexMax,5 );
					else
						_positionBufferList[currentBatchIndex] = positionVertexBuffer3D = GPUAuxiliary.geVertexBuffer( vertexMax,4 );
				}
				
				positionVertexBuffer3D.uploadFromByteArray( positionVector,0,0,vertexMax );
				//判断是否使用透明混合的着色器 ，这个着色器是手机的克星，效率很低
				if( last._texture._format == Context3DTextureFormat.COMPRESSED )
				{
					if( filter == FilterFormat.ColorMatrixFilter || last.filter == FilterFormat.ColorMatrixFilter )
					{
						_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, filter == FilterFormat.ColorMatrixFilter ? lastFilterDisPlay._renderColorMatrix : last._renderColorMatrix );
						_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, MIN_COLOR);
						_context3d.setProgram( _programList[ _program_compressed_colorMatrix ] );
						_lastProgram =_programList[ _program_compressed_colorMatrix ];
					}
					else 
					{
						 programIndex = lastAlpha ? _program_compressed_tinted:_program_compressed;
					}
				}
				else if( last._texture._format == "compressedAlpha" )
				{
					if( filter == FilterFormat.ColorMatrixFilter || last.filter == FilterFormat.ColorMatrixFilter )
					{
						_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, filter == FilterFormat.ColorMatrixFilter ? lastFilterDisPlay._renderColorMatrix : last._renderColorMatrix );
						_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, MIN_COLOR);
						_context3d.setProgram( _programList[ _program_compressed_alpha_colorMatrix ] );
						_lastProgram =_programList[ _program_compressed_alpha_colorMatrix ];
					}
					else 
					{
						programIndex = lastAlpha ? _program_compressed_alpha_tinted:_program_compressed_alpha;	
					}
				}
				else
				{
					if( filter == FilterFormat.ColorMatrixFilter || last.filter == FilterFormat.ColorMatrixFilter )
					{
						_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, filter == FilterFormat.ColorMatrixFilter ? lastFilterDisPlay._renderColorMatrix : last._renderColorMatrix );
						_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, MIN_COLOR);
						_context3d.setProgram( _programList[ _program_rgb_colorMatrix ] );
						_lastProgram =_programList[ _program_rgb_colorMatrix ];
					}
					else 
					{
						 programIndex = lastAlpha ? _program_rgb_tinted:_program_rgb;
					}
				}
				
				if( _lastProgram !=  _programList[ programIndex ] )
				{
					_context3d.setProgram( _programList[ programIndex ] );
					_lastProgram = _programList[ programIndex ];
				}
				
				
				if( _lastTexture != last._texture._root )
				{
					_context3d.setTextureAt( 0, last._texture._base );
					_lastTexture = last._texture._root;	
				}
				
				_context3d.setVertexBufferAt( 0,positionVertexBuffer3D,0,lastAlpha ? Context3DVertexBufferFormat.FLOAT_3: Context3DVertexBufferFormat.FLOAT_2 );
				_context3d.setVertexBufferAt( 1,positionVertexBuffer3D,lastAlpha ? 3: 2,Context3DVertexBufferFormat.FLOAT_2 );
				
				//设置混合模式
				if( _lastBlendMode != last.blendMode )
				{
					blendModeArray = last._texture._type != Texture2D.ATF ?_blendModePremultipliedAlpha[last.blendMode]:_blendMode[last.blendMode];
					_context3d.setBlendFactors( blendModeArray[0],blendModeArray[1] );
					_lastBlendMode = last.blendMode;
				}
				
				indexBudder3d = _indexBufferList[currentBatchIndex];
				if( indexBudder3d == null ) _indexBufferList[currentBatchIndex] = indexBudder3d = GPUAuxiliary.getindexBuffer( batchIndex );
				
				if( last._clipRect ) _context3d.setScissorRectangle( last._renderClipRect );
				
				_context3d.drawTriangles( indexBudder3d );
				
				if( last._clipRect ) _context3d.setScissorRectangle( null );
				
				batchIndex = 0;lastAlpha = false;cout ++;last = null;positionVector.position = 0;
			}
			
			matrixPool.push( childMatrix );
			
		}

		/** GPU显示列表的root */
		public function get root():GPUSprite
		{
			return _root;
		}

		/** GPU stage3d 实例 */
		public function get stage3d():Stage3D
		{
			return _stage3d;
		}


	}
}