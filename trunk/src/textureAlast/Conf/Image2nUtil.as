package textureAlast.Conf 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author blueshell
	 */
	public class Image2nUtil
	{
		
		public static function ImageTo2n(bd : BitmapData) : BitmapData
		{
			var w : int = bd.width;
			var h : int = bd.height;
			var i : int;
			
			i = 1;
			if ((w != 1) && (w & (w - 1)) != 0) {
				i = 1;
				while(i < w)
					i <<= 1;
				w = i;
			}
			
			if ((h != 1) && (h & (h - 1)) != 0) {
				i = 1;
				while(i < h)
					i <<= 1;
				h = i;
			}
			
			
			
			
			
			var destBD : BitmapData = new BitmapData(w , h , true , 0x00FFFFFF);
			
			//trace(destBD.width , destBD.height  , bd.width , bd.height , bd.rect);
			var ba : ByteArray = bd.getPixels(	bd.rect);
			ba.position = 0;
			destBD.setPixels(bd.rect , ba);
			
			return destBD;
		}
		
	}

}