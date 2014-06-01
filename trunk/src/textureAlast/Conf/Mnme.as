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
	import flash.utils.Endian;
	import util.ByteArrayUtil;

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
			var _rawName :String = saveFile.nativePath;
			saveFile.nativePath = saveFile.nativePath.slice(0 , saveFile.nativePath.length - 7) + ".mmexml";
			
			try{
				var stream:FileStream = new FileStream();
				stream.open(saveFile, FileMode.WRITE);
				stream.position = 0;
				stream.writeMultiByte(inXml.toXMLString() , "utf-8");
				stream.close();
			}catch(e:Error){
			}	
			
			//trace(inXml.toXMLString());
			
			//trace(dirUrl);

			var bitmapDataBAArray : Vector.<ByteArray> = new Vector.<ByteArray>();
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
			
				bitmapDataBAArray.push(ba);
				
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
	
				
			
			
			
			var baBin : ByteArray = new ByteArray;
			baBin.endian = Endian.LITTLE_ENDIAN;
			baBin.writeUTFBytes("MNEB");
			baBin.writeByte(1);
			
			trace("asset length " + inXml.asset.length());
			
			ByteArrayUtil.writeUnsignedByteOrShort(baBin , inXml.asset.length());
			
			for each ( var assetXML : XML in inXml.asset)
			{
				//trace(assetXML.toXMLString());
				
				var centerX : int = -int(assetXML.@x);
				var centerY : int = -int(assetXML.@y);
				var imgX : int = int(assetXML.@imgX);
				var imgY : int = int(assetXML.@imgY);
				var width : int = int(assetXML.@width);
				var height : int = int(assetXML.@height);
				var xName :String = String(assetXML.@assetName);
				var xNameId : String = xName.slice(("mergeImage_").length , xName.indexOf(".png?"));
				var index : int = int(xNameId);
				
				baBin.writeByte(index);
				baBin.writeShort(imgX);
				baBin.writeShort(imgY);
				baBin.writeShort(width);
				baBin.writeShort(height);
				baBin.writeShort(centerX);
				baBin.writeShort(centerY);
				
				//if (bodyXML.Texture2D != undefined && bodyXML.Texture2D[0])
				//	addTexture(bodyXML.Texture2D[0]);
			}
			
			trace("action length " + inXml.action.length());
			
			ByteArrayUtil.writeUnsignedByteOrShort(baBin , inXml.action.length());
			
			for each ( var actionXML : XML in inXml.action)
			{
				var actionName : String = String(actionXML.@name);
				if (!actionName) actionName = "";
				
				trace(actionName + " layer length " + actionXML.layer.length());
				
				var l : int = 0;
				ByteArrayUtil.writeUnsignedByteOrShort(baBin , actionName.length);
				for (l = 0 ; l < actionName.length;l++ )
					baBin.writeShort(actionName.charCodeAt(l));
				
				ByteArrayUtil.writeUnsignedByteOrShort(baBin , actionXML.layer.length());
				
				for each ( var layerXML : XML in actionXML.layer)
				{
					//var lId : int = int(String(layerXML.@id));
					//ByteArrayUtil.writeUnsignedByteOrShort(baBin , lId);
					
					ByteArrayUtil.writeUnsignedByteOrShort(baBin , layerXML.frame.length());
					
					
					for each ( var frameXML : XML in layerXML.frame)
					{
						var fIndex : int = int(String(frameXML.@index));
						var fLength : int = int(String(frameXML.@length));
						var fEvent : String = String(frameXML.@event);
						
						var isEmpty : Boolean = true;
						for each ( var elementXML : XML in frameXML.element)
						{
							var elementId : int = int(elementXML.@assetId);
							var elementX : int = int(elementXML.@x);
							var elementY : int = int(elementXML.@y);
							var extname : String = elementXML.@extname;
							if (!extname)
								isEmpty = false;
						}
						
						
						var flag : int = 0;
						
						if (fLength != 1)
							flag |= 1;
						if (fEvent)
							flag |= 2;
							
						
							
						if (isEmpty)
							flag |= 16;
						else {
							if (elementX)
								flag |= 4;
							if (elementY)
								flag |= 8;
						}

							
						baBin.writeByte(flag);
						ByteArrayUtil.writeUnsignedByteOrShort(baBin , fIndex);
						if (flag & 1)
							ByteArrayUtil.writeUnsignedByteOrShort(baBin , fLength);
						if (flag & 2)
						{
							ByteArrayUtil.writeUnsignedByteOrShort(baBin , fEvent.length);
							for (l = 0 ; l < fEvent.length;l++ )
								baBin.writeShort(fEvent.charCodeAt(l));
						}

						if (!isEmpty) {
							ByteArrayUtil.writeUnsignedByteOrShort(baBin , elementId);
							if (flag & 4)
								baBin.writeShort( elementX);
							if (flag & 8)
								baBin.writeShort( elementY);	
						}
					}
					
				}
			}
			
			try {
				saveFile.nativePath = _rawName.replace(".mmexml" , ".menb");
				stream = new FileStream();
				stream.open(saveFile, FileMode.WRITE);
				stream.position = 0;
				stream.writeBytes(baBin);
				stream.close();
			}catch(e:Error){
			}
			
			baBin[3]++; //menc
			
			ByteArrayUtil.writeUnsignedByteOrShort(baBin , bitmapDataBAArray.length);
			
			for each (var bdba : ByteArray in bitmapDataBAArray)
			{
				bdba[0] ^= 0xFC;
				bdba[1] ^= 0xBF;
				bdba[2] ^= 0x10; //prevent dump png
				
				baBin.writeInt( bdba.length);
				baBin.writeBytes(bdba);
				
			}
			
			
			//ByteArrayUtil.writeUnsignedByteOrShort(baBin , xml.action.length());

			//trace(baBin[1275])
			try {
				saveFile.nativePath = _rawName.replace(".mmexml" , ".menc");
				stream = new FileStream();
				stream.open(saveFile, FileMode.WRITE);
				stream.position = 0;
				stream.writeBytes(baBin);
				stream.close();
			}catch(e:Error){
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
					
					if (bdi.bitmapDataRect.width == 0)
					{
						tXML.@width = bd.width;
						bdi.bitmapDataRect.width = bd.width;
						
					}
					
					if (bdi.bitmapDataRect.height == 0)
					{
						tXML.@height = bd.height;
						bdi.bitmapDataRect.height = bd.height;
						
					}
					
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