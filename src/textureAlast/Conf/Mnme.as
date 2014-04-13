package textureAlast.Conf 
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	import textureAlast.BitmapDataInfo;
	import textureAlast.BitmapDataInfoMgr;
	import textureAlast.BitmapDataRef;
	import textureAlast.ImgMerge.RectangleArgs;
	import textureAlast.PNGEncoder;
	/**
	 * ...
	 * @author blueshell
	 */
	public class Mnme
	{
		public static var inputFileFilterArray : Array = [new FileFilter(".swf", "*.swf") , new FileFilter("*.*", "*.*;") ];
		public static var outputFileFilterArray : Array = [new FileFilter("*.*", "*.xml;")];
		private static var inXml : XML;
		public static var bitmapDataArray : Vector.<BitmapData>;
		
		public static function output(s_result :  Vector.<RectangleArgs>) : void
		{
			processDestFile(s_result);
			saveDestFile();
		}	 
 
		public static function processDestFile(s_result :  Vector.<RectangleArgs>):XML
		{
			if (!s_result)
				return null;
			bitmapDataArray = new Vector.<BitmapData>(100);
			
			for (var bi : int = 0 ; bi < s_result.length; bi++ )
			{
				if (bitmapDataArray[s_result[bi].newBitmapDataId] == null)
				{
					bitmapDataArray[s_result[bi].newBitmapDataId] = s_result[bi].newBitmapData;
				}
				else
				{
					ASSERT(bitmapDataArray[s_result[bi].newBitmapDataId] == s_result[bi].newBitmapData , "errror array");
				}
				
				var bdr : BitmapDataRef = BitmapDataRef(s_result[bi].args);
				var xml : XML = XML(bdr.ref);
				
				//trace(xml.toXMLString());
				xml.@imgX = s_result[bi].x;
				xml.@imgY = s_result[bi].y; 
				
				xml.@assetName = "mergeImage_" + s_result[bi].newBitmapDataId + ".png" + "?raw=" + xml.@assetName;
				
				//trace("+++" + xml.toXMLString());
			}
			return inXml;
		}
		
		protected static function saveDestFile():void
		{
			var file:File = new File();
			file.addEventListener(Event.SELECT, fileSelected); 
			file.browseForSave("保存配置");
		}
		
		
		private static function fileSelected(event : Event): void
		{ 
			var saveFile:File = File(event.currentTarget);
			var dirUrl : String = saveFile.nativePath.substring(0 , saveFile.nativePath.length - saveFile.name.length)

			if ((saveFile.name.toLocaleUpperCase()).indexOf(".MMEXML") == -1)
			{
				saveFile.nativePath += ".mmexml";
			}
			
			try{
				var stream:FileStream = new FileStream();
				stream.open(saveFile, FileMode.WRITE);
				stream.position = 0;
				stream.writeMultiByte(inXml.toXMLString() , "utf-8");
				stream.close();
			}catch(e:Error){
			}	
			
			//trace(dirUrl);

			for (var i : int = 0; i < bitmapDataArray.length ; i++)
			{
				if (bitmapDataArray[i] == null)
				{
					break;
				}
				
				var ba : ByteArray;
				if (Config.imageForceTo2n)
				{
					ba = PNGEncoder.encode( Image2nUtil.ImageTo2n(bitmapDataArray[i]) );
				}
				else
				{
					ba = PNGEncoder.encode(bitmapDataArray[i] );
				}

				
				
				
				try{
					stream = new FileStream();
					
					saveFile = new File();
					saveFile.nativePath = dirUrl + "mergeImage_" + i + ".png"
					stream.open(saveFile, FileMode.WRITE);
					stream.position = 0;
					stream.writeBytes(ba , 0 , ba.length);
					stream.close();
				}catch(e:Error){
				}	
			}
		}


		
		public static function addTexture(tXML  : XML , a_applicationDomain : ApplicationDomain) : void
		{
			//trace(tXML);
				
			{
				//trace(adfXML);
				
				var clsName : String =  String(tXML.@className);
				
				if (!clsName)
					return;
				
				try {
					var runtimeClassRef : Class = a_applicationDomain.getDefinition(clsName)  as  Class;
					
					if (runtimeClassRef != null) {
						var bd : BitmapData = new runtimeClassRef() as BitmapData;
					}
					
				
				} catch (e:Error) {
					trace("decode error");
					return;
				}
				if (bd)
				{
					//trace(adfXML.toXMLString());
					
					var bdi : BitmapDataInfo = new BitmapDataInfo();
					bdi.bitmapDataRect.x = 0;
					bdi.bitmapDataRect.y = 0;
					bdi.bitmapDataRect.width = int(tXML.@width);
					bdi.bitmapDataRect.height = int(tXML.@height);
					bdi.bitmapDataName = String(tXML.@assetName);
					
					bdi.bitmapData = bd;
					
					BitmapDataInfoMgr.addABitmapDataInfo(tXML , bdi);
				}
			}
		}
		
		private static function loadCom(e:Event):void
		{
			e.currentTarget.removeEventListener(e.type, arguments.callee);
			var loader : Loader = e.currentTarget.loader as Loader;
			try {
				var runtimeClassRef : Class = loader.contentLoaderInfo.applicationDomain.getDefinition("Config")  as  Class;
				
				if (runtimeClassRef != null) {
					var ba : ByteArray = new runtimeClassRef() as ByteArray;
					var xml : XML = new XML(ba);
				}
				
				
			
			} catch (e:Error) {
				trace("decode error");
			}
			
			//trace(xml);
			if (xml)
			{
				inXml = xml;
				for each ( var assetXML : XML in xml.asset)
				{
					//trace(assetXML.toXMLString());
					addTexture(assetXML , loader.contentLoaderInfo.applicationDomain);
					
					//if (bodyXML.Texture2D != undefined && bodyXML.Texture2D[0])
					//	addTexture(bodyXML.Texture2D[0]);
				}
			}
			
			
		}
		
		public static function input(data:ByteArray) : void
		{
			
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCom);
			var context:LoaderContext = new LoaderContext();        
			context.allowLoadBytesCodeExecution = true;   
			loader.loadBytes(data , context);
			
		}
		
	}

}