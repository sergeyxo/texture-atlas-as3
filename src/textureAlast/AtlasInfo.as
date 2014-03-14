package textureAlast
{
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author blueshell
	 */
	public class AtlasInfo
	{
		public var url : String;
		public var x : int;
		public var y : int;		
		public var bitmapData : BitmapData;
		
		public function AtlasInfo (_url : String )
		{
			url = _url ;
		}
	}

}