package Conf 
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import ImgMerge.RectangleArgs;
	/**
	 * ...
	 * @author blueshell
	 */
	public class AvtMote
	{
		public static var inputFileFilterArray : Array = [new FileFilter("xml | amxmla", "*.amxmla;*.xml") , new FileFilter("*.*", "*.*;") ];
		public static var outputFileFilterArray : Array = [new FileFilter("*.*", "*.amxmla;")];
		private static var inXml : XML;
		private static var bitmapDataArray : Vector.<BitmapData>;
		
		public static function output(s_result :  Vector.<RectangleArgs>) : void
		{
			if (!s_result)
				return;
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
				xml.rectX = s_result[bi].x;
				xml.rectY = s_result[bi].y; 
				
				if (xml.name.text().indexOf("#FLIP") != -1)
				{
					xml.rectX = int(xml.rectX.text()) - int(xml.rectW.text());
				}
					
				xml.filename = "mergeImage_" + s_result[bi].newBitmapDataId + ".png"
				
				
				//trace("+++" + xml.toXMLString());
				
				
			}
		

			var file:File = new File();
			file.addEventListener(Event.SELECT, fileSelected); 
			file.browseForSave("保存配置");
			
			
		}	 
 
		private static function fileSelected(event : Event): void
		{ 
			var saveFile:File = File(event.currentTarget);
			var dirUrl : String = saveFile.nativePath.substring(0 , saveFile.nativePath.length - saveFile.name.length)

						
			if ((saveFile.name.toLocaleUpperCase()).indexOf(".AMXMLA") == -1)
			{
				saveFile.nativePath += ".amxmla";
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

		public static function addTexture(tXML  : XML) : void
		{
			//trace(tXML);
				
			{
				//trace(adfXML);
				if ( String(tXML.filename.text()))
				{
					//trace(adfXML.toXMLString());
					
					var bdi : BitmapDataInfo = new BitmapDataInfo();
					bdi.bitmapDataRect.x = int(tXML.rectX.text());
					bdi.bitmapDataRect.y = int(tXML.rectY.text());
					bdi.bitmapDataRect.width = int(tXML.rectW.text());
					bdi.bitmapDataRect.height = int(tXML.rectH.text());
					bdi.bitmapDataName = String(tXML.filename.text());
					//trace(bdi.bitmapDataRect , bdi.bitmapDataName);
					var idx : int = (tXML.name.text()).indexOf("#FLIP");
					if (idx != -1)
					{
						bdi.bitmapDataRect.x += bdi.bitmapDataRect.width;
						bdi.bitmapDataRect.width = -bdi.bitmapDataRect.width;
						
						//trace("convert to" , bdi.bitmapDataRect , bdi.bitmapDataName);
					}
					
					
					
					BitmapDataInfoMgr.addABitmapDataInfo(tXML , bdi);
				}
			}
		}
		
		public static function input(data:ByteArray) : void
		{
			var string : String = data.readUTFBytes(data.length);
			//trace(string);
			
			inXml = new XML(string);
			
			for each (var tXML : XML in inXml.ModuleHead.Texture2D)
			{
				addTexture(tXML);
			}
			
			for each ( var eyeXML : XML in inXml.ModuleEye.ModuleEyeFrames.ModuleEyeFrame)
			{
				//trace(eyeXML);
				
				if (eyeXML.eyeWhite != undefined && eyeXML.eyeWhite.Texture2D != undefined && eyeXML.eyeWhite.Texture2D[0])
					addTexture(eyeXML.eyeWhite.Texture2D[0]);
				if (eyeXML.eyeBall != undefined && eyeXML.eyeBall.Texture2D != undefined && eyeXML.eyeBall.Texture2D[0])
					addTexture(eyeXML.eyeBall.Texture2D[0]);
				if (eyeXML.eyeLip != undefined && eyeXML.eyeLip.Texture2D != undefined && eyeXML.eyeLip.Texture2D[0])
					addTexture(eyeXML.eyeLip.Texture2D[0]);
			}
			
			for each ( var hairXML : XML in inXml.ModuleHair.ModuleHairFrames.ModuleHairFrame)
			{
				//trace(eyeXML);
				
				if (hairXML.Texture2D != undefined && hairXML.Texture2D[0])
					addTexture(hairXML.Texture2D[0]);
			}
			
			for each ( var bodyXML : XML in inXml.ModuleBody.ModuleBodyFrames.ModuleBodyFrame)
			{
				//trace(eyeXML);
				
				if (bodyXML.Texture2D != undefined && bodyXML.Texture2D[0])
					addTexture(bodyXML.Texture2D[0]);
			}
		}
		
	}

}