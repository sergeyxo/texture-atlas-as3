package textureAlast 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Blueshell
	 */
	public class LoaderPlus extends Loader 
	{
		public var url : String;
		public var prefix : String;
		public var bitmapData : BitmapData;
		public var completeFunction : Function;
		public function LoaderPlus(a_prefix : String , a_url : String) 
		{
			url = a_url;
			prefix = a_prefix;
			
			super();
		}
		
		public function loadImage():void
		{
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			this.load(new URLRequest(prefix + url));
			
		}
		
		public function dispose():void
		{
			this.loaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			this.loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			if (bitmapData)
			{
				bitmapData.dispose(); bitmapData = null;
			}
			
			url = prefix = null;
			completeFunction = null;
		}
		
		private function onComplete(e:Event):void 
		{
			var l:Loader=Loader(e.target.loader);
			bitmapData = Bitmap(l.content).bitmapData;
			
			trace(url + " w: " + bitmapData.width +  " h: " + bitmapData.height);
			
			if (completeFunction != null)
				completeFunction(this);
		}
		
		private function onError(e:IOErrorEvent):void 
		{
			trace("error load " + prefix + url);
		}
		
	}

}