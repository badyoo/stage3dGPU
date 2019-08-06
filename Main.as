package  {
	
	import flash.display.MovieClip;
	import badyoo.toyBricks.launch.MobileLaunch;
	import badyoo.toyBricks.components.Application;
	import badyoo.toyBricks.gpu.TextureAtlas;
	import badyoo.toyBricks.gpu.Texture2D;
	import badyoo.toyBricks.gpu.GPU;
	import badyoo.toyBricks.utils.Filter;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.Bitmap;
	import badyoo.toyBricks.gpu.GPUImage;
	import badyoo.toyBricks.gpu.GPUMovieClip;
	import badyoo.toyBricks.utils.GPUColorMatrixUtils;
	import badyoo.toyBricks.gpu.FilterFormat;
	
	/**
	*
	* @author badyoo qq:547243998
	* 一套练手实现的stage3d渲染框架，仅供学习使用谢谢
	* 学习自starling 根据自己的优化经验优化的一套性能更高的渲染
	*/
	public class Main extends MobileLaunch {
		
		private var urlloader:URLLoader = new URLLoader();
		private var loader:Loader = new Loader();
		private var textureAtlas:TextureAtlas;
		public function Main() 
		{
			super(Application);
			
			
		}
		
		override public function init(e:Event = null ):void
		{
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("./assets.png"));
		}
		private function loaded(e:Event):void
		{
			
			urlloader.load(new URLRequest("./assets.xml"));
			urlloader.addEventListener(Event.COMPLETE,xmlLoaded);
		}
		
		private function xmlLoaded(e:Event):void
		{
			trace("loaded");
			var texture:Texture2D = Texture2D.fromBitmap(loader.content as Bitmap,Texture2D.TEXTURE);
			textureAtlas = new TextureAtlas(texture,new XML(urlloader.data) );
			
			var _root:Application = GPU.current.root as Application;
			
			var image:GPUImage = new GPUImage(textureAtlas.getTexture("a0000"));
			_root.gameLayer.addChild(image);
			
			var mc:GPUMovieClip = new GPUMovieClip(textureAtlas.getTextures("d"));
			mc.play();
			_root.gameLayer.addChild(mc);
			
			image = new GPUImage(textureAtlas.getTexture("b0000"));
			image.alpha = 0.5;
			image.x = 100;
			_root.gameLayer.addChild(image);
			
			image = new GPUImage(textureAtlas.getTexture("c0000"));
			image.scaleX = 0.5;
			image.x = 200;
			_root.gameLayer.addChild(image);
			
			image = new GPUImage(textureAtlas.getTexture("c0000"));
			image.scaleY = 0.5;
			image.x = 300;
			_root.gameLayer.addChild(image);
			
			_image = new GPUImage(textureAtlas.getTexture("c0000"));
			//image.scaleY = 0.5;
			_image.x = 400;
			_root.gameLayer.addChild(_image);
			
			
			addEnterFrame(update);
		}
		
		private var _image:GPUImage;
		private function update():void
		{
			_image.rotation +=1;
		}
	}
	
}
