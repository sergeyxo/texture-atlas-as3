package  
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author blueshell
	 */
	public class BitmapDataInfo
	{
		public var bitmapData : BitmapData;
		public var bitmapDataName : String;
		public var bitmapDataRect : Rectangle = new Rectangle;
		
		public function BitmapDataInfo() 
		{
			
		}
		
		public function isEqual(a_bdi : BitmapDataInfo) : Boolean
		{
			return a_bdi.bitmapData == bitmapData
			&& a_bdi.bitmapDataName == bitmapDataName
			//&& a_bdi.bitmapDataRect == bitmapDataRect
			
			&& a_bdi.bitmapDataRect.x == bitmapDataRect.x
			&& a_bdi.bitmapDataRect.y == bitmapDataRect.y
			&& a_bdi.bitmapDataRect.width == bitmapDataRect.width
			&& a_bdi.bitmapDataRect.height == bitmapDataRect.height
		}
		
	}

}