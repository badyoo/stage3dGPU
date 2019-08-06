package badyoo.toyBricks.utils
{
	import flash.geom.Point;

	/**
	 * DisplayUtil 这是一个集合对显示对象操作的工具类
	 * @author badyoo QQ:547243998
	 * @langversion 3.0
	 * @playerversion Flash 9
	 */	
	public class DisplayUtil
	{
		/**
		 * 在指定的容器里，批量添加显示对象 
		 * @param container 容器 
		 * @param child 显示对象
		 */
		public static function addChilds(container:Object,...child):void{
			var max:int=child.length;
			for(var i:int=0;i<max;i++){
				container.addChild(child[i]);
			}	
		}
		/**
		 * 设置指定显示对象的坐标
		 * @param target 指定显示对象
		 * @param x 
		 * @param y
		 */		
		public static function move(target:Object,x:Number,y:Number):void{
			target.x=x;
			target.y=y;
		}
		
		/**
		 * 获得显示对象的全局坐标
		 * @param sprite 显示对象
		 * @return 位置
		 */		
		public static function findScreenPosition(sprite:Object):Point
		{
			if (!sprite) return null;
			
			var result_x:Number=sprite.x;
			var result_y:Number=sprite.y;
			
			var _parent:Object = sprite.parent
			while (_parent)
			{
				result_x = result_x+_parent.x;
				result_y = result_y+_parent.y;
				_parent = _parent.parent
			}
			return new Point(result_x,result_y);
		}
		/**
		 * 绘制扇形
		 * @param mc 扇形所在影片剪辑的名字
		 * @param x 扇形原点的x坐标
		 * @param y 扇形原点的y坐标
		 * @param r 扇形的半径
		 * @param angle 扇形的角度
		 * @param startFrom 扇形的起始角度
		 * @param color 扇形的颜色
		 */		
		public static function DrawSector(mc:Object,x:Number=200,y:Number=200,r:Number=100,angle:Number=27,startFrom:Number=270,color:Number=0xff0000):void
		{
			mc.graphics.clear();
			mc.graphics.beginFill(color,50);
			mc.graphics.lineStyle(0,0xff0000);
			mc.graphics.moveTo(x,y);
			angle=(Math.abs(angle)>360)?360:angle;
			var n:Number = Math.ceil(Math.abs(angle) / 45);
			var angleA:Number = angle / n;
			angleA = angleA * Math.PI / 180;
			startFrom = startFrom * Math.PI / 180;
			mc.graphics.lineTo(x+r*Math.cos(startFrom),y+r*Math.sin(startFrom));
			for (var i:int=1; i<=n; i++)
			{
				startFrom +=  angleA;
				var angleMid:* = startFrom - angleA / 2;
				var bx:* =x+r/Math.cos(angleA/2)*Math.cos(angleMid);
				var by:* =y+r/Math.cos(angleA/2)*Math.sin(angleMid);
				var cx:*  = x + r * Math.cos(startFrom);
				var cy:*  = y + r * Math.sin(startFrom);
				mc.graphics.curveTo(bx,by,cx,cy);
			}
			if (angle!=360)
			{
				mc.graphics.lineTo(x,y);
			}
			mc.graphics.endFill();
		}
		/**
		 * 移动到某个位置 
		 * @param oneself 要移动的对象
		 * @param target 目标位置
		 * @param speed 速度
		 */		
		public static function moveTo(oneself:Object,targetPoint:Point,speed:Number):Boolean{
			var dy:Number=targetPoint.y-oneself.y;
			var dx:Number=targetPoint.x-oneself.x;
			var angle:Number=Math.atan2(dy,dx);
			if(dy*dy+dx*dx>speed*speed){
				oneself.x += speed*Math.cos(angle);
				oneself.y += speed*Math.sin(angle);
				return true
			}
			return  false;
		}
		/**
		 * 基于时间计算
		 * 无论帧频多少依然能保证最后数值的结果差不多
		 * 比如我一个人物以30帧运行，每帧x轴递增10 ，那么他到达坐标100时需要 1000/30x10的时间；
		 * 如果我游戏变成60祯时，我想让其走到100坐标位置也使用1000/30x10的时间。那么我只要在每秒递增的值后面乘以现在值要相乘的比例 即可。
		 * 注意：当前程序的帧频越低结果误差越大。
		 * @param frameRate 保持多少帧计算。
		 * @param lastTime 每一帧经过的时间
		 * @return 现在值要相乘的比例
		 */		
		public static function getbalanceValue(frameRate:int,lastTime:int):Number{
			var frameRateTime:Number= 1000/frameRate;
			return lastTime/frameRateTime;
		}
	}
}