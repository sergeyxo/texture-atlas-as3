package textureAlast.ImgMerge
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author blueshell
	 */
	public class RectangleArgs extends Rectangle
	{
		public var args : Object;
		public var newBitmapData : BitmapData;
		public var newBitmapDataId : int;
		
		public function RectangleArgs(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0 , a_args:Object = null)
		{
			super(x, y, width, height);
			args = a_args;
		}
		
		public function cloneArgs () : RectangleArgs
		{
			return new RectangleArgs(
				  this.x
				, this.y
				, this.width
				, this.height
				, this.args
			);
			
			
		}
	}

}