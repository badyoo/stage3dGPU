package badyoo.toyBricks.utils
{
	public class GPUColorMatrixUtils
	{
		public static var gray:Vector.<Number> = new <Number>[
			1/3,1/3,1/3,0,0,   
			1/3,1/3,1/3,0,0,   
			1/3,1/3,1/3,0,0,   
			0,  0,  0,1,0
		]
			
		public static var style_1:Vector.<Number> = new <Number>[
			1/2,1/2,1/2,0,0,   
			1/3,1/3,1/3,0,0,   
			1/4,1/4,1/4,0,0,   
			0,  0,  0,1,0
		]	
			
		private static const IDENTITY:Array = [1,0,0,0,0,  0,1,0,0,0,  0,0,1,0,0,  0,0,0,1,0];
		
		public static function create( value:Vector.<Number>,renderColorMatrix:Vector.<Number> ):void
		{
			var mUserMatrix:Vector.<Number> = new <Number>[];
			if ( value && value.length != 20 ) 
				throw new Error("Invalid matrix length: must be 20");
			
			if (value == null)
			{
				mUserMatrix.length = 0;
				mUserMatrix.push.apply(mUserMatrix, IDENTITY);
			}
			else
			{
				copyMatrix(value, mUserMatrix);
				function copyMatrix(from:Vector.<Number>, to:Vector.<Number>):void
				{
					for (var i:int=0; i<20; ++i)
						to[i] = from[i];
				}
			}
			
			updateShaderMatrix( renderColorMatrix );
			function updateShaderMatrix( mShaderMatrix:Vector.<Number> ):void
			{
				mShaderMatrix.length = 0;
				mShaderMatrix.push(
					mUserMatrix[0],  mUserMatrix[1],  mUserMatrix[2],  mUserMatrix[3],
					mUserMatrix[5],  mUserMatrix[6],  mUserMatrix[7],  mUserMatrix[8],
					mUserMatrix[10], mUserMatrix[11], mUserMatrix[12], mUserMatrix[13], 
					mUserMatrix[15], mUserMatrix[16], mUserMatrix[17], mUserMatrix[18],
					mUserMatrix[4] / 255.0,  mUserMatrix[9] / 255.0,  mUserMatrix[14] / 255.0,  
					mUserMatrix[19] / 255.0
				);
			}
		}
		
	}
}