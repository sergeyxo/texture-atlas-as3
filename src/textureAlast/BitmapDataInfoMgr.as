package textureAlast
{
	import textureAlast.Conf.*;
	import textureAlast.*;
	
	import textureAlast.ImgMerge.FloorPlane;
	import textureAlast.ImgMerge.RectangleArgs;
	/**
	 * ...
	 * @author blueshell
	 */
	public class BitmapDataInfoMgr
	{
		
		private static var s_bitmapDataRefArray : Vector.<BitmapDataRef> = new Vector.<BitmapDataRef>();
		private static var s_bitmapDataInfoArray : Vector.<BitmapDataInfo> = new Vector.<BitmapDataInfo>();
		private static var s_bitmapDataFileArray : Vector.<String> = new Vector.<String>();
		
		private static var s_totalImages : uint;
		private static var s_loadedImages : uint;
		
		
		private static var completeFunction : Function;
		
		//private static var s_bitmapDataRefArray : Array = new Array();
		//private static var s_bitmapDataInfoArray : Array = new Array();
		//private static var s_bitmapDataFileArray : Array = new Array();
		
		//private static var addTimes : int = 0;
		public static function addABitmapDataInfo(a_ref : Object , a_bdi : BitmapDataInfo) : void
		{
			//trace("addTimes " + addTimes++);
			//return;
			
			//if (a_bdi.bitmapDataName == "images/Mintdq.png")
			//{
			//	trace(a_bdi.bitmapDataRect)
			//}
			
			//trace("******");
			
			for each (var bdr : BitmapDataRef in s_bitmapDataRefArray)
			{
				if (bdr.bitmapDataInfo.isEqual(a_bdi) && bdr.ref === a_ref )
				{	
					trace("!!!!!!!!!!!!here!!")
					return;
				}
			}
			s_bitmapDataRefArray.push(new BitmapDataRef(a_ref , a_bdi));
			//trace(s_bitmapDataRefArray.length);
			
			for each (var bdi : BitmapDataInfo in s_bitmapDataInfoArray)
			{
				if (bdi.isEqual(a_bdi))
				{	
					return;
				}
			}
			s_bitmapDataInfoArray.push(a_bdi);
			
			for each (var url : String in s_bitmapDataFileArray)
			{
				if (a_bdi.bitmapDataName == (url))
					return;
			}
			s_bitmapDataFileArray.push(a_bdi.bitmapDataName);
			
			
			
		}
		
		public static function clear() : void
		{
			s_bitmapDataRefArray.length = 
			s_bitmapDataInfoArray.length = 
			s_bitmapDataFileArray.length = 
			0;
			
			s_totalImages = 0;
			s_loadedImages = 0;
		}
		
		public static function get allLoaded():Boolean
		{
			return s_totalImages > 0 && s_totalImages == s_loadedImages ;
		}
		
		public static function load(preFix : String = "") : void
		{
			s_totalImages = s_bitmapDataFileArray.length;
			s_loadedImages = 0;
			
			//trace("totalImages " + s_totalImages);
			
			//trace(s_bitmapDataFileArray.length);
			for each (var url : String in s_bitmapDataFileArray)
			{
				var lp : LoaderPlus = 
				new LoaderPlus(preFix , url);
				lp.completeFunction = onLoadAImage;
				
				lp.loadImage();
				//trace(url);
			}
			
		}
		
		public static function onLoadAImage(a_lp : LoaderPlus) : void 
		{
			if (!s_bitmapDataInfoArray)
				return;
				
			s_loadedImages++;
			trace("loadedImages " + a_lp.url  + "\t" + s_loadedImages + "/" + s_totalImages);
			for each (var bdr : BitmapDataRef in s_bitmapDataRefArray)
			{
				if (bdr.bitmapDataInfo.bitmapDataName == a_lp.url)
				{
					//trace("setted " + a_lp.url)
					bdr.bitmapDataInfo.bitmapData = a_lp.bitmapData;
				}
					
			}
			
			
			
			if (allLoaded )
			{
				for each ( bdr in s_bitmapDataRefArray)
				{
					if (!bdr.bitmapDataInfo.bitmapData)
					{
						trace("###########Error" + bdr.bitmapDataInfo.bitmapDataName);
					}
				}
				
				for each (var bdi : BitmapDataInfo in s_bitmapDataInfoArray)
				{
					if (!bdi.bitmapData)
					{
						trace("###########Error" + bdi.bitmapDataName);
					}
				}
			
				if (completeFunction != null)
					completeFunction();
			}
				
			
		}
		
		public static function deal(w : int = 512 , space : int = 0): Vector.<Vector.<RectangleArgs>>
		{
			var rawRectArray : Vector.<RectangleArgs> = new Vector.<RectangleArgs>();	
			for each (var bdi : BitmapDataInfo in s_bitmapDataInfoArray)
			{
				//trace(bdr.bitmapDataInfo.bitmapDataName , bdr.bitmapDataInfo.bitmapData)
				if (w < bdi.bitmapDataRect.width)
					return null;
					
				rawRectArray.push(new RectangleArgs(
					bdi.bitmapDataRect.x
					,bdi.bitmapDataRect.y
					,bdi.bitmapDataRect.width
					,bdi.bitmapDataRect.height
					,bdi
				));
			}
			//trace(w , space);
			var raWithBitmapDataInfoArray : Vector.<RectangleArgs> = new FloorPlane().dealRectangleArgsArray(rawRectArray , w , space);
			var raWithBitmapDataRefArray : Vector.<RectangleArgs> = new Vector.<RectangleArgs>();
			
			for each (var raWithBitmapDataInfo : RectangleArgs in raWithBitmapDataInfoArray)
			{
				var bdiDealed : BitmapDataInfo = BitmapDataInfo(raWithBitmapDataInfo.args);
				for each (var bdr : BitmapDataRef in s_bitmapDataRefArray)
				{
					if (bdr.bitmapDataInfo.isEqual(bdiDealed))
					{
						
						raWithBitmapDataRefArray.push(
							new RectangleArgs(
							 raWithBitmapDataInfo.x
							,raWithBitmapDataInfo.y
							,raWithBitmapDataInfo.width
							,raWithBitmapDataInfo.height
							,bdr
						));
					}
				}
			}
			
			trace(s_bitmapDataInfoArray.length , raWithBitmapDataInfoArray.length , s_bitmapDataRefArray.length , raWithBitmapDataRefArray.length)
			
			return Vector.<Vector.<RectangleArgs>>([raWithBitmapDataInfoArray , raWithBitmapDataRefArray]);
		}
	}

}

