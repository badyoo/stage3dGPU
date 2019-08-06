package badyoo.toyBricks.gpu
{
	import flash.display.Stage;

	/**
	 * GPUSprite 类是基本GPU显示列表构造块：一个可显示图形并且也可包含子项的显示列表节点。
	 * @author badyoo
	 * @see flash.display.Sprite
	 */
	public class GPUSprite extends GPUDisplayObject
	{
		/**
		 * GPUSprite 类是基本GPU显示列表构造块：一个可显示图形并且也可包含子项的显示列表节点。
		 * @author badyoo
		 * @see flash.display.Sprite
		 */
		public function GPUSprite()
		{
			touchable = true;
			_displayList = new <GPUDisplayObject>[];
		}
		
		/**
		 * 确定 display 是否该显示列表的子对象
		 * @param display
		 * @return 
		 * 
		 */
		public function contains( display:GPUDisplayObject ):Boolean
		{
			return _displayList.indexOf( display ) != -1;
		}
		
		/**
		 * 添加一个显示对象到该显示列表中 
		 * @param display 显示对象
		 * @return 
		 * 
		 */
		public function addChild( display:GPUDisplayObject ):GPUDisplayObject
		{
			addChildAt( display,_numChildren );
			return display;
		}
		
		/**
		 * 添加一个显示对象到该显示列表中指定的索引位置
		 * @param child 显示对象
		 * @param index 索引 不能大于该显示列表的子对象数量
		 * @return 
		 * 
		 */
		public function addChildAt( child:GPUDisplayObject,index:int ):GPUDisplayObject
		{
				
			if ( index >= 0 && index <= _numChildren )
			{
				if ( child._parent == this )
				{
					setChildIndex( child, index ); 
				}
				else
				{
					if ( index == _numChildren ) 
					{
						_displayList[_numChildren] = child;
						_numChildren++;
					}
					else     
					{
						_displayList.splice( index, 0, child );
					}
				}
				
				child._stage = _stage;
				child._parent = this;
				child.onShow();
				
				return child;
			}
			else
			{
				throw new RangeError("Invalid child index");
			}
		}
		
		/**
		 * 从该显示列表中删除指定的显示对象 
		 * @param display 显示对象
		 * @param dispose 释放该对象
		 */
		public function removeChild( display:GPUDisplayObject,dispose:Boolean = false ):void
		{
			var index:int = getChildIndex( display );
			removeChildAt( index,dispose );
		}
		
		/**
		 * 从该显示列表删除指定索引的显示对象 
		 * @param index 索引
		 * @param dispose 释放该对象
		 */
		public function removeChildAt( index:int,dispose:Boolean = false ):void
		{
			if( index >= 0 && index < _numChildren )
			{
				var display:GPUDisplayObject = _displayList[index];
				_displayList.splice( index,1 );
				_numChildren --;
				display._parent = null;
				display.onCallRemove();
				if( dispose )
					display.dispose();
			}
		}
		
		/**
		 * 删除该显示列表指定范围内的显示对象，默认不填参数删除所有显示对象 
		 * @param beginIndex 开始索引
		 * @param endIndex 结束索引
		 * @param dispose 释放身上的子对象
		 */
		public function removeChildren( beginIndex:int=0, endIndex:int=-1,dispose:Boolean = false ):void
		{
			if ( endIndex < 0 || endIndex >= _numChildren ) 
				endIndex = numChildren - 1;
			
			for ( var i:int = beginIndex; i <= endIndex; ++i )
				removeChildAt( beginIndex,dispose );
		}
		
		/**
		 * 获取该显示列表指定索引位置的显示对象 
		 * @param index 索引
		 * @return 
		 * 
		 */
		public function getChildAt( index:int ):GPUDisplayObject
		{
			if ( index >= 0 && index < _numChildren )
				return _displayList[index];
			else
				throw new Error("Invalid child index");
		}
		
		/**
		 * 获取该显示列表指定名字的显示对象 
		 * @param name
		 * @return 
		 * 
		 */
		public function getChildByName( name:String ):GPUDisplayObject
		{
			for ( var i:int=0; i<_numChildren; ++i )
				if ( _displayList[i].name == name ) return _displayList[i];
			
			return null;
		}
		
		/**
		 * 获取相对于该显示列表下的子对象索引 
		 * @param child 子对象
		 * @return 
		 * 
		 */
		public function getChildIndex( child:GPUDisplayObject ):int
		{
			return _displayList.indexOf( child );
		}
		
		public function setChildIndex( child:GPUDisplayObject,index:int ):void
		{
			var oldIndex:int = getChildIndex( child );
			if ( oldIndex == index ) return;
			if ( oldIndex == -1 ) throw new Error("Not a child of this container");
			_displayList.splice( oldIndex, 1 );
			_displayList.splice( index, 0, child );
		}
		
		public function swapChildren( child1:GPUDisplayObject, child2:GPUDisplayObject ):void
		{
			var index1:int = getChildIndex( child1 );
			var index2:int = getChildIndex( child2 );
			if (index1 == -1 || index2 == -1) throw new Error("Not a child of this container");
			swapChildrenAt(index1, index2);
		}
			
		public function swapChildrenAt( index1:int, index2:int ):void
		{
			var child1:GPUDisplayObject = getChildAt( index1 );
			var child2:GPUDisplayObject = getChildAt( index2) ;
			_displayList[index1] = child2;
			_displayList[index2] = child1;
		}
		
		/**
		 * 子对象个数 
		 * 
		 */
		public function get numChildren():int
		{
			return _numChildren;
		}
		
		override public function get height():Number
		{
			if( _numChildren == 0 )
				return 0;
			if( _numChildren == 1 )
				return _displayList[0].height * this.scaleY;
			
			var min:Number = Number.MAX_VALUE,max:Number = - Number.MAX_VALUE;
			
			for( var i:int = 0; i<_numChildren; i++ )
			{
				var child:GPUDisplayObject = _displayList[i];
				var height:Number = child.height;
				if( height > 0 )
				{
					min = min < ( child.y - child.centerY ) ? min : ( child.y - child.centerY );
					max = max > ( child.y - child.centerY + height ) ? max : ( child.y - child.centerY + height );
				}
			}
			
			if( min ==  Number.MAX_VALUE || max == - Number.MAX_VALUE)
				return 0;
			
			return ( max - min ) * this.scaleY;
		}
		
		override public function get width():Number
		{
			if( _numChildren == 0 )
				return 0;
			if( _numChildren == 1 )
				return _displayList[0].width * this.scaleX;
			
			var min:Number = Number.MAX_VALUE,max:Number = - Number.MAX_VALUE;
			
			for( var i:int = 0; i<_numChildren; i++ )
			{
				var child:GPUDisplayObject = _displayList[i];
				var width:Number = child.width;
				if( width > 0 )
				{
					min = min < ( child.x - child.centerX ) ? min : ( child.x - child.centerX );
					max = max > ( child.x - child.centerX + width ) ? max : ( child.x - child.centerX + width );
				}
			}
			
			if( min ==  Number.MAX_VALUE || max == - Number.MAX_VALUE)
				return 0;
			
			return ( max - min ) * this.scaleX;
		}
		
		override internal function onCallRemove():void
		{
			super.onCallRemove();
			for( var i:int = 0 ; i<_numChildren ; i++ )
				_displayList[i].onCallRemove();
		}
		
		override internal function onCallShow(stage:Stage):void
		{
			super.onCallShow(stage);
			for( var i:int = 0 ;i<_numChildren;i++ )
				_displayList[i].onCallShow( stage );
				
		}
		
		override public function dispose():void
		{
			removeChildren( 0,-1,true );
			_displayList = null;
			super.dispose();
		}
		
	}
}