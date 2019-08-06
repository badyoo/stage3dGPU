package badyoo.toyBricks.gpu
{
    import badyoo.toyBricks.gpu.Texture2D;
    
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
	
	/**
	 * GPU 纹理集，使用格式为Starling的格式 Flash cs6 以上 or texturePacker 支持导出 
	 * @author badyoo
	 * 
	 */
    public class TextureAtlas
    {
        private var _base:Texture2D;
        private var _textureRegions:Dictionary;
        private var _textureFrames:Dictionary;
		private var _textureList:Dictionary;
        
        /** helper objects */
        private static var sNames:Vector.<String> = new <String>[];
        
		/**
		 * 创建纹理集 
		 * @param texture 纹理集对应的Texture2D
		 * @param atlasXml 纹理集的配置
		 * 
		 */
        public function TextureAtlas( texture:Texture2D,atlasXml:XML = null )
        {
            _textureRegions = new Dictionary( true );
            _textureFrames  = new Dictionary( true );
			_textureList = new Dictionary( true );
			
            _base   = texture;
            
            if (atlasXml)
                parseAtlasXml(atlasXml);
        }
        
        /** 释放该纹理就集 */
        public function dispose():void
        {
			_textureList = _textureRegions = _textureFrames = null;
            _base.dispose();
        }
        
		/** 解析纹理集配置 */
        protected function parseAtlasXml( atlasXml:XML ):void
        {
            var scale:Number = 1;
            
            for each (var subTexture:XML in atlasXml.SubTexture)
            {
                var name:String        = subTexture.attribute("name");
                var x:Number           = parseFloat(subTexture.attribute("x")) / scale;
                var y:Number           = parseFloat(subTexture.attribute("y")) / scale;
                var width:Number       = parseFloat(subTexture.attribute("width")) / scale;
                var height:Number      = parseFloat(subTexture.attribute("height")) / scale;
                var frameX:Number      = parseFloat(subTexture.attribute("frameX")) / scale;
                var frameY:Number      = parseFloat(subTexture.attribute("frameY")) / scale;
                var frameWidth:Number  = parseFloat(subTexture.attribute("frameWidth")) / scale;
                var frameHeight:Number = parseFloat(subTexture.attribute("frameHeight")) / scale;
                
                var region:Rectangle = new Rectangle(x, y, width, height);
                var frame:Rectangle  = frameWidth > 0 && frameHeight > 0 ?
                        new Rectangle(frameX, frameY, frameWidth, frameHeight) : null;
                
                addRegion(name, region, frame);
            }
        }
        
        /** 根据名字获取纹理集里对应的子纹理 */
        public function getTexture( name:String ):Texture2D
        {
			if( _textureList[name] )
				return _textureList[name];
			
            var region:Rectangle = _textureRegions[name];
            
            if (region == null) 
				return null;
			
			_textureList[name] = Texture2D.fromTexture( _base, region,_textureFrames[name] );
			return _textureList[name];
        }
        
		/**
		 * 获取名字前戳一样的子纹理列表，这个主要用于GPUMovieClip
		 * @param prefix 名字前戳
		 * @param result 返回结果 可以为空
		 * @return 
		 * 
		 */
        public function getTextures( prefix:String = "",result:Vector.<Texture2D> = null ):Vector.<Texture2D>
        {
            if (result == null) result = new <Texture2D>[];
            
            for each ( var name:String in getNames( prefix,sNames ) ) 
                result.push( getTexture( name ) ); 

            sNames.length = 0;
            return result;
        }
        
        /** Returns all texture names that start with a certain string, sorted alphabetically. */
        private function getNames( prefix:String = "", result:Vector.<String> = null ):Vector.<String>
        {
            if (result == null) result = new <String>[];
            
            for ( var name:String in _textureRegions )
                if ( name.indexOf( prefix ) == 0 )
                    result.push( name );
            
            result.sort( Array.CASEINSENSITIVE );
            return result;
        }
        
        /** Returns the region rectangle associated with a specific name. */
        private function getRegion( name:String ):Rectangle
        {
            return _textureRegions[name];
        }
        
        /** Returns the frame rectangle of a specific region, or <code>null</code> if that region 
         *  has no frame. */
        private function getFrame(name:String):Rectangle
        {
            return _textureFrames[name];
        }
        
        /** Adds a named region for a subtexture (described by rectangle with coordinates in 
         *  pixels) with an optional frame. */
        private function addRegion(name:String, region:Rectangle, frame:Rectangle=null):void
        {
            _textureRegions[name] = region;
            _textureFrames[name]  = frame;
        }
        
        /** Removes a region with a certain name. */
        private function removeRegion(name:String):void
        {
            delete _textureRegions[name];
            delete _textureFrames[name];
        }
        
        /** 纹理集的基础Texture2D */
        public function get texture():Texture2D 
		{ 
			return _base; 
		}

		public function get textureRegions():Dictionary
		{
			return _textureRegions;
		}

    }
}