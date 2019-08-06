package badyoo.toyBricks.gpu
{
	import adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3DProgramType;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * gpu辅助程序 
	 * @author badyoo
	 * 
	 */
	public class GPUAuxiliary
	{
		/**
		 * 创建顶点程序 
		 * @param needAplha 需要透明通道
		 * @return 
		 * 
		 */
		private static function getVertexAGAL( needAlpha:Boolean = false ):String
		{
			var vertexAGAL:String;
			if( GPU.current.useCPUlocation == false )
				vertexAGAL = "m44 op, va0, vc0 \n" // 图像坐标 = 顶点坐标*与点着色器矩阵
			else
				vertexAGAL = "mov op, va0 \n" //不用GPU进行矩阵运算
			
			vertexAGAL += "mov v0, va1.xy \n"// 设置顶点寄存器1的xy 为纹理的uv坐标 给传递变量 v0 传给 片段程序 
			if( needAlpha )
				vertexAGAL += "mov v1, va0.z \n" // 复制 顶点寄存器2的z 为透明度 给传递变量 v1 传给 片段程序 
			
			return vertexAGAL;
		}
		
		/**
		 * 创建片段程序 
		 * @param textureFormat 纹理格式 ATF 或者 ATFAlpha 或者""
		 * @param tinted 是否需要着色运算 这个很消耗效率
		 * @param repeat 纹理重复 repeat、wrap、clamp
		 * @param filtering 纹理过滤 nearest、linear
		 * @param mipmapping  mip 映射 mipnone、mipnearest、miplinear
		 * @see flash.dislay3D.Context3DWrapMode
		 * @see flash.dislay3D.Context3DTextureFilter
		 * @see flash.dislay3D.Context3DMipFilter
		 */
		private static function getFragmentAGAL( textureFormat:String,tinted:Boolean = false,repeat:String = "clamp",filtering:String = "linear",mipmapping:String = "mipnone",filterFormat:int = 0 ):String
		{
			
			var fragmentAGAL:String;
			fragmentAGAL = "tex "//纹理取样 
			
			if( tinted || filterFormat == FilterFormat.ColorMatrixFilter )
				fragmentAGAL += "ft0";//输出给 临时片断变量
			else
				fragmentAGAL += "oc";//输出显示
			
			//纹理坐标 uv 来自 传递变量 v0 .来自纹理fs0 纹理格式为2d的
			fragmentAGAL += " v0, fs0 <2d,";
			fragmentAGAL += repeat+","; //纹理重复
			fragmentAGAL += filtering+",";//纹理过滤方式
			fragmentAGAL += mipmapping+"";//纹理mip映射
			
			if( textureFormat == "ATF" )
				fragmentAGAL += ",dxt1";//无透明的压缩纹理
			if( textureFormat == "ATFAlpha" )
				fragmentAGAL += ",dxt5";//有透明的压缩纹理
			
			fragmentAGAL += ">\n";//结尾
			
			if( filterFormat == FilterFormat.ColorMatrixFilter )
			{
				fragmentAGAL += "mul ft0, ft0, v1.zzzz\n";//纹理的透明度来自顶点v0的z属性		
				//				var fragmentProgramCode:String =
				//					"tex ft0, v0,  fs0 <2d, clamp, linear, mipnone>  \n" + // read texture color
				fragmentAGAL += "max ft0, ft0, fc5              \n" + // avoid division through zero in next step
					"div ft0.xyz, ft0.xyz, ft0.www  \n" + // restore original (non-PMA) RGB values
					"m44 ft0, ft0, fc0              \n" + // multiply color with 4x4 matrix
					"add ft0, ft0, fc4              \n" + // add offset
					"mul ft0.xyz, ft0.xyz, ft0.www  \n" + // multiply with alpha again (PMA)
					"mov oc, ft0                    \n";  // copy to output
			}
				
			else if( tinted )
			{
				fragmentAGAL += "mul ft0, ft0, v1.zzzz\n";//纹理的透明度来自顶点v0的z属性		
				fragmentAGAL += "mov oc, ft0 \n";   //渲染纹理
			}
			
			return fragmentAGAL;
		}
		
		/**
		 * 初始化stage3d 依赖的着色器，预创建的顶点 
		 * 
		 */
		public static function install( gpu:GPU ):void
		{
			log( "install stage3d" );
			
			gpu._lastProgram = null;
			gpu._lastTexture = null;
			
			gpu._programList = new Vector.<Program3D>( gpu._program_none,true );
			
			gpu._lastBlendMode ="";
			
			Texture2D.context3d = gpu._context3d;
			
			var program:Program3D;
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			var fragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
			//-----------不需要着色的纹理着色器 ---------
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,GPUAuxiliary.getVertexAGAL() );
			//RGBA
			if( gpu.useRGBA )
			{
				fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,GPUAuxiliary.getFragmentAGAL( "" ) );
				program = gpu._context3d.createProgram();
				program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
				gpu._programList[ gpu._program_rgb ] = program;
				log( "install stage3d program RGBA done" );
				
			}
			
			if( gpu.useATF )
			{
				//ATF 无透明的
				fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,GPUAuxiliary.getFragmentAGAL( "ATF" ) );
				program = gpu._context3d.createProgram();
				program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
				gpu._programList[ gpu._program_compressed ] = program;
				log( "install stage3d program ATF done" );
			}
			
			if( gpu.useATF_alpha )
			{
				//ATF 透明的
				fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,GPUAuxiliary.getFragmentAGAL( "ATFAlpha" ) );
				program = gpu._context3d.createProgram();
				program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
				gpu._programList[ gpu._program_compressed_alpha ] = program;
				log( "install stage3d program ATF_alpha done" );
			}
			
			//-----------需要着色的纹理着色器 ---------
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,GPUAuxiliary.getVertexAGAL( true ) );		
			if( gpu.useRGBA )
			{
				fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,GPUAuxiliary.getFragmentAGAL( "",true ) );
				program = gpu._context3d.createProgram();
				program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
				gpu._programList[ gpu._program_rgb_tinted ] = program;
				log( "install stage3d program RGBA_Tinted done" );
				
				if( gpu.useColorMatrix )
				{
					fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,GPUAuxiliary.getFragmentAGAL( "",false,"clamp","linear","mipnone",FilterFormat.ColorMatrixFilter ) );
					program = gpu._context3d.createProgram();
					program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
					gpu._programList[ gpu._program_rgb_colorMatrix ] = program;
					log( "install stage3d program RGBA ColorMatrix done" );
				}
			}
			
			//ATF 无透明的
			if( gpu.useATF )
			{
				fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,GPUAuxiliary.getFragmentAGAL( "ATF",true ) );
				program = gpu._context3d.createProgram();
				program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
				gpu._programList[ gpu._program_compressed_tinted ] = program;
				log( "install stage3d program ATF_Tinted done" );
				if( gpu.useColorMatrix )
				{
					fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,GPUAuxiliary.getFragmentAGAL( "ATF",false,"clamp","linear","mipnone",FilterFormat.ColorMatrixFilter ) );
					program = gpu._context3d.createProgram();
					program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
					gpu._programList[ gpu._program_compressed_colorMatrix ] = program;
					log( "install stage3d program ATF ColorMatrix done" );
				}
			}
			//ATF 透明的
			if( gpu.useATF_alpha )
			{
				fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,GPUAuxiliary.getFragmentAGAL( "ATFAlpha",true ));
				program = gpu._context3d.createProgram();
				program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
				gpu._programList[ gpu._program_compressed_alpha_tinted] = program;
				log( "install stage3d program ATF_alpha_Tinted done" );
				if(gpu. useColorMatrix )
				{
					fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,GPUAuxiliary.getFragmentAGAL( "ATFAlpha",false,"clamp","linear","mipnone",FilterFormat.ColorMatrixFilter ) );
					program = gpu._context3d.createProgram();
					program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
					gpu._programList[ gpu._program_compressed_alpha_colorMatrix] = program;
					log( "install stage3d program ATF_alpha ColorMatrix done" );
				}
			}
			
			log( "install stage3d program done" );
			
			gpu._indexBufferList = new Vector.<IndexBuffer3D>(gpu._indexNum,true);
			gpu._positionBufferList = new Vector.<VertexBuffer3D>( gpu._indexNum,true );
			gpu._alphaPositionBufferList = new Vector.<VertexBuffer3D>( gpu._indexNum,true );
			for ( var i:int = 1 ; i <= gpu._indexMin ; i++ )
			{
				gpu._positionBufferList[ i -1 ] = geVertexBuffer( 4*i,4 );
				gpu._alphaPositionBufferList[ i-1 ] = geVertexBuffer( 4*i,5 );
				gpu._indexBufferList[i - 1] = getindexBuffer( i );
				
			}
			log( "install stage3d in advance IndexBuffer3D VertexBuffer3D" );
		}
		
		/**
		 * 根据顶点数量创建对应的顶点数据区
		 * @param numVertices 顶点数量
		 * @param data32PerVertex
		 * 与每个顶点关联的 32 位（4 字节）数据值的数量。每个顶点的 32 位数据元素数量最多为 64 个（或 256 个字节）。请注意，顶点着色器程序在任何给定时间只能访问 8 个属性寄存器。使用 SetVertextBufferAt() 在顶点缓冲区内选择属性。
		 * 
		 */
		public static function geVertexBuffer( numVertices:int,data32PerVertex:int ):VertexBuffer3D
		{
			var fun:Function = GPU.context3d.createVertexBuffer;
			var vertexBuffer3D:VertexBuffer3D = fun.length == 3 ? fun.call( null,numVertices,data32PerVertex,"dynamicDraw" ): fun.call( null,numVertices,data32PerVertex );
			
			return vertexBuffer3D;
		}
		
		/**
		 * 根据四边形数量创建对应的顶点索引区
		 * @param numIndices 四边形数量
		 * @return 
		 * 
		 */
		public static function getindexBuffer( numIndices:int ):IndexBuffer3D
		{
			var fun:Function = GPU.context3d.createIndexBuffer;
			var indexBuffer3D:IndexBuffer3D = fun.length == 2 ? fun.call( null,6 * numIndices,"dynamicDraw" ): fun.call( null,6 * numIndices );
			var indexVector:ByteArray = new ByteArray();indexVector.endian = Endian.LITTLE_ENDIAN;
			for ( var num:int = 0 ;num <numIndices ;num++ )
			{
				var index:int = num * 4;
				indexVector.writeShort( index );
				indexVector.writeShort( index + 1 );
				indexVector.writeShort( index + 2 );
				indexVector.writeShort( index + 0 );
				indexVector.writeShort( index + 2 );
				indexVector.writeShort( index + 3 );
			}
			indexBuffer3D.uploadFromByteArray( indexVector,0,0,6*numIndices );
			return indexBuffer3D;
		}
		
	}
}