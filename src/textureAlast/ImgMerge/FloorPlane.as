package  textureAlast.ImgMerge
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author blueshell
	 */
	public class FloorPlane
	{
		private var rectArray : Vector.<RectangleArgs>;
		public function dealRectangleArgsArray(a_rectArray : Vector.<RectangleArgs> , maxWidth : int  , gap : int = 1)
		: Vector.<RectangleArgs>
		{
			
			var rectArraySort : Array = [];
			rectArraySort.length = a_rectArray.length;
			
			for (var bi : int = 0 ; bi < a_rectArray.length; bi++ )
			{
				rectArraySort[bi] = a_rectArray[bi].cloneArgs();
			}
			
			rectArraySort.sortOn(["height" , "width"] , Array.NUMERIC | Array.DESCENDING);
			rectArray = Vector.<RectangleArgs>(rectArraySort);
			rectArraySort = null;
			
			if (gap)
			{
				for each (var rect : RectangleArgs in rectArray)
				{
					rect.width += gap;
					rect.height += gap;
				}
			}
			
			floorplane(maxWidth , gap);
			
			if (gap)
			{
				for each ( rect in rectArray)
				{
					rect.width -= gap;
					rect.height -= gap;
				}
			}
			
			return rectArray;
			
		}
		
		internal function  test() : Vector.<RectangleArgs> 
		{
						
			const MAX_W : int = 80;
			const MIN_W : int = 5;
			const MAX_H : int = 80;
			const MIN_H : int = 5;
			
			//expression.push(new PolishExpressionElementRect(new Rectangle(0, 0, 

			const total : int  = 50;
			var rawRectArray : Vector.<RectangleArgs> = new Vector.<RectangleArgs>();
			for (var bi : int = 0 ; bi < total; bi++ )
			{
				rawRectArray.push((new RectangleArgs(0, 0, 
					MIN_W + int(Math.random() * (MAX_W  - MIN_W)),
					MIN_H + int(Math.random() * (MAX_H  - MIN_H)))
				));
			}
			return dealRectangleArgsArray(rawRectArray , 256 , 1);
		}
		

	
		
		private var step :  int = 0;
		internal function testStepNext() : Vector.<RectangleArgs> 
		{
			if (step == 0)
			{
				const MAX_W : int = 80;
				const MIN_W : int = 5;
				const MAX_H : int = 80;
				const MIN_H : int = 5;
				
				//expression.push(new PolishExpressionElementRect(new Rectangle(0, 0, 

				const total : int  = 50;
				
				var rectArraySort : Array = [];
				for (var bi : int = 0 ; bi < total; bi++ )
				{
					rectArraySort.push((new RectangleArgs(0, 0, 
						MIN_W + int(Math.random() * (MAX_W  - MIN_W)),
						MIN_H + int(Math.random() * (MAX_H  - MIN_H)))
					));
				}
				rectArraySort.sortOn(["height" , "width"] , Array.NUMERIC | Array.DESCENDING);
				rectArray = Vector.<RectangleArgs>(rectArraySort);
				
				
				for (bi = 1 ; bi < rectArray.length; bi++ )
				{
					rectArray[bi].x = rectArray[bi - 1].x + rectArray[bi - 1].width;
				}

				
				for each (var rect : Rectangle in rectArray)
				{	
					rect.y += 512;
				}
			}
			
			if (step < rectArray.length)
			{
				floorplane(256 , step , step + 1);
				step++;
				
				return rectArray;
			}
			return null;
			
		}
		
		private function countMaxH(heightArray : Vector.<int>  , width : int , i : int) : int
		{
			var len : int = i + width;
			var maxH : int = heightArray[i];
			i++;
			
			for (; i < len; i++ )
			{
				if (maxH <  heightArray[i])
				{
					maxH =  heightArray[i];
				}
			}
			
			return maxH;
		}
		
		private function findMinHRight( heightArray : Vector.<int>  , width : int ) : PostionXH
		{
			var len : int = heightArray.length - width;
			var pxh : PostionXH = new PostionXH();
			pxh.startHeight = int.MAX_VALUE;
			CONFIG::ASSERT {
				ASSERT(len >= 0 , "error len" );
			}
			
			if (len == 0) {
				h = countMaxH(heightArray , width , i);
				pxh.startX = 0;
				pxh.startHeight = h;
			}
			else {
				for (var i : int = len-1 ; i >=0 ; i-- )
				{
					var h : int = countMaxH(heightArray , width , i);
					
					if (h < pxh.startHeight)
					{
						pxh.startX = i;
						pxh.startHeight = h;
					}
				}
			}
			
			return pxh;
			
		}
		
		private function findMinHLeft( heightArray : Vector.<int>  , width : int ) : PostionXH
		{
			var len : int = heightArray.length - width;
			var pxh : PostionXH = new PostionXH();
			pxh.startHeight = int.MAX_VALUE;
			CONFIG::ASSERT {
				ASSERT(len >= 0 , "error len" );
			}
			
			if (len == 0) {
				h = countMaxH(heightArray , width , i);
				pxh.startX = 0;
				pxh.startHeight = h;
			}
			else {
				for (var i : int = 0 ; i < len; i++ )
				{
					var h : int = countMaxH(heightArray , width , i);
					
					if (h < pxh.startHeight)
					{
						pxh.startX = i;
						pxh.startHeight = h;
					}
				}
			}
			
			
			return pxh;
			
		}
		
		private var heightArray : Vector.<int>;// = new Vector.<int>();
		private var startX : int
		private var isLeftAglin : Boolean ;
		private var widthLineSum : int;
		private var modeSwitch : int ;
		
		private function floorplane(maxWidth : int  , gap : int , start : int = 0, end  : int = -1):void
		{
			maxWidth += gap;
			var total : int = rectArray.length;
			var mode1 : int = 1;
			
			if (end == -1)
				end = total;
			
			if (start == 0)
			{	
				heightArray = new Vector.<int>();
				heightArray.length = maxWidth;
				startX = 0;
				isLeftAglin = true;
				widthLineSum = 0;
				
				modeSwitch = Math.log(maxWidth) /  Math.log(2);
				//trace(modeSwitch);
			}
				
			for (var bi : int = start ; bi < end; )
			{
				var rect : Rectangle = rectArray[bi];
				var h : int = rect.height;
				
				
				
				if (widthLineSum + rect.width > maxWidth)
				{
					var restSpace : int = maxWidth - widthLineSum;
					for (var bi2 : int = bi + 1; bi2 < total; bi2++ )
					{
						if (rectArray[bi2].width <= restSpace)
						{
							//trace(rectArray[bi] ,rect.width , restSpace );
							var rect2 : Rectangle = rectArray[bi2];
							//trace("BBBBB"+rect2);
							rectArray.splice(bi2 , 1);
							rectArray.splice(bi , 0 , rect2);
							//trace("AAAA"+rectArray[bi] , restSpace );
							break;
						}
					}
					
					if (rect != rectArray[bi])
						continue;
					else
					{
						isLeftAglin = !isLeftAglin;
						widthLineSum = 0;
						startX = isLeftAglin ? 0 : maxWidth;
						continue;
					}
				}
				else
				{
					
					bi++ ;
					
					widthLineSum += rect.width;
					var pxh : PostionXH ;
					
					if (total - bi <  modeSwitch)
						mode1 = 0;
						
					if (mode1)
					{
						if (!pxh)
						{
							pxh = new PostionXH();
						}
						
						if (isLeftAglin)
						{
							pxh.startHeight = countMaxH(heightArray , rect.width , startX);
							pxh.startX = startX;
							startX += rect.width;
						}
						else
						{
							pxh.startHeight = countMaxH(heightArray , rect.width , startX - rect.width);
							pxh.startX = startX - rect.width;
							startX -= rect.width;
							
						}
					}
					else
					{
						if (isLeftAglin)
						{
							pxh = findMinHLeft(heightArray , rect.width);
						}
						else
						{
							pxh = findMinHRight(heightArray , rect.width);
						}
					}
					
					
					
					rect.x = pxh.startX;
					rect.y = pxh.startHeight;
					var xMax : int = pxh.startX + rect.width;
					var hMax : int = pxh.startHeight + rect.height;
					
					for (var i : int = pxh.startX ; i < xMax; i++ )
					{
						heightArray[i] = hMax;
					}
				}
				
			}
		}
		
		
		
	}

}