package badyoo.toyBricks.gpu
{	
	
	/**
	 * 基础的影片剪辑动画 
	 * @author badyoo
	 * 
	 */
	public class GPUMovieClip extends GPUImage
	{
		/** 需要帧回调的GPUMovieClip列表 */
		internal static var _needScript:Vector.<GPUMovieClip> = new Vector.<GPUMovieClip>();
		/** 需要帧回调的GPUMovieClip数量 */
		internal static var _needScriptIndex:int;
		/** 帧回调列表 */
		internal var _frameScriptList:Vector.<Function>;
		/** 帧回调数量 */
		internal var _frameScriptIndex:int;
		/**
		 * 基础的影片剪辑动画 
		 * @param frameList 帧纹理列表 @see badyoo.toyBricks.gpu.TextureAtlas
		 * @param fps 帧频
		 * 
		 */
		public function GPUMovieClip( frameList:Vector.<Texture2D>,fps:int = 12 )
		{
			super( null );
			_needNextFrame = _isPlaying = false;
			_currentFrame = 0;
			_totalFrames = frameList.length;
			_frameList = frameList;
			_frameScriptList = new Vector.<Function>( _totalFrames );
			this.fps = fps;
			gotoAndStop( 1 );
		}
		
		/**
		 * 给某帧添加回调函数 
		 * @param param 格式为 帧编号，回调...... 帧编号从0开始，每个帧添加的函数只能有一个，多次添加会进行替换
		 * 
		 */
		public function addFrameScript( ...param ):void
		{	
			var len:int = param.length;
	 		for ( var i:int = 0 ; i<len ; i+=2 )
			{
				_frameScriptList[param[i]] = param[i+1];
				_frameScriptIndex ++;
			}
			
			if( _frameScriptIndex > 0 && _needScript.indexOf( this ) == -1 )
			{
				_needScript.push( this );
				_needScriptIndex++;
			}
				
		}
		
		/**
		 * 删除某帧添加过的回调函数 
		 * @param param 格式 帧编号......帧编号从0开始
		 * 
		 */
		public function removeFrameScript( ...param ):void
		{
			var len:int = param.length;
			for ( var i:int = 0 ; i<len ; i+=2 )
			{
				_frameScriptList[param[i]] = null;
				_frameScriptIndex --;
			}
			
		}
		
		/**
		 * 播放 
		 * 
		 */
		public function play():void
		{
			_isPlaying = true;
		}
		
		/**
		 * 停止播放
		 */
		public function stop():void
		{
			_isPlaying = false;
		}
		
		/**
		 * 跳转到指定的帧并且播放 
		 * @param frame 帧编号
		 * 
		 */
		public function gotoAndPlay( frame:int ):void
		{
			if( frame > 0 && frame<= _totalFrames )
			{	
				_currentFrame = frame - 1;
				_isPlaying = true;
				_texture = _frameList[_currentFrame];
				_realWidth = _texture._width;
				_realHeight = _texture._height;
				centerX = _texture._frame ? _texture._frame.x : 0;
				centerY = _texture._frame ? _texture._frame.y : 0;
				_needNextFrame = false;
			}
			
		}
		
		/**
		 * 跳转到指定的帧并且停止播放 
		 * @param frame 帧编号
		 * 
		 */
		public function gotoAndStop( frame:int ):void
		{
			if( frame > 0 && frame<= _totalFrames )
			{
				_currentFrame = frame - 1;
				_isPlaying = false;
				_texture = _frameList[_currentFrame];
				_realWidth = _texture._width;
				_realHeight = _texture._height;
				centerX = _texture._frame ? _texture._frame.x : 0;
				centerY = _texture._frame ? _texture._frame.y : 0;
				_needNextFrame = false;
			}
		}
		
		/**
		 * 一个布尔值，指示影片剪辑当前是否正在播放。 
		 * @return 
		 * 
		 */
		public function get isPlaying():Boolean
		{
			return _isPlaying
		}
		
		/**
		 * 总帧数 
		 * @return 
		 * 
		 */
		public function get totalFrames():int
		{
			return _totalFrames;
		}
		
		/**
		 * 当前帧 
		 * @return 
		 * 
		 */
		public function get currentFrame():int
		{
			return _currentFrame + 1;
		}
		
		/** 帧频 */
		public function get fps():int
		{
			return _fps;
		}
		
		/** 帧频 */
		public function set fps( value:int ):void
		{
			_totalTime = 1.0 / value;
			_fps = value;
		}
		
		override public function dispose():void
		{
			_frameScriptList = null;
			_frameList = null;
			super.dispose();
		}
		
	}
}