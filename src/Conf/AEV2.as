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
	public class AEV2
	{
		public static var inputFileFilterArray : Array = [new FileFilter("xml|anixml", "*.anixml;*.xml") , new FileFilter("*.*", "*.*;") ];
		public static var outputFileFilterArray : Array = [new FileFilter("*.*", "*.anixml;")];
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
				xml.@imgX = s_result[bi].x;
				xml.@imgY = s_result[bi].y; 
				xml.@filename = "mergeImage_" + s_result[bi].newBitmapDataId + ".png"
				
				
				//trace("+++" + xml.toXMLString());
				
				
			}
			
			
			for each (var imgXMLList : XML in inXml.ImageDataList)
			{
				for each (var imgXML : XML in imgXMLList.ImageData)
				{	
					for (bi = 0 ; bi < s_result.length; bi++ )
					{
						var ra : RectangleArgs = s_result[bi];
						bdr = BitmapDataRef(ra.args);
						
						
						if (imgXML.@filename == bdr.bitmapDataInfo.bitmapDataName
						&& imgXML.@x == bdr.bitmapDataInfo.bitmapDataRect.x
						&& imgXML.@y == bdr.bitmapDataInfo.bitmapDataRect.y
						&& imgXML.@w == bdr.bitmapDataInfo.bitmapDataRect.width
						&& imgXML.@h == bdr.bitmapDataInfo.bitmapDataRect.height
						)
						{
							if (String(imgXML.@desc))
							{
							}
							else
								imgXML.@desc = imgXML.@filename;
								
							imgXML.@filename = "mergeImage_" + ra.newBitmapDataId + ".png"
							imgXML.@x = ra.x;
							imgXML.@y = ra.y;
							break;
						}
					}
					
					//trace(imgXML.toXMLString());
				
				}
			}
			
			
			
			
		

			var file:File = new File();
			file.addEventListener(Event.SELECT, fileSelected); 
			file.browseForSave("保存配置");
			
			
		}	 
 
		private static function fileSelected(event : Event): void
		{ 
			var saveFile:File = File(event.currentTarget);
			var dirUrl : String = saveFile.nativePath.substring(0 , saveFile.nativePath.length - saveFile.name.length)

						
			if ((saveFile.name.toLocaleUpperCase()).indexOf(".ANIXML") == -1)
			{
				saveFile.nativePath += ".anixml";
			}
			
			try{
				var stream:FileStream = new FileStream();
				stream.open(saveFile, FileMode.WRITE);
				stream.position = 0;
				stream.writeMultiByte(inXml.toXMLString() , "utf-8");
				stream.close();
			}catch(e:Error){
			}	
			
			trace(dirUrl);

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

		public static function input(data:ByteArray) : void
		{
			var string : String = data.readUTFBytes(data.length);
			//trace(string);
			
			inXml = new XML(string);
			
			for each (var adXML : XML in inXml.AnimeData)
			{
				//trace(adfXML);
				for each (var adfXML : XML in adXML.AnimeDataFrame)
				{
					//trace(adfXML);
					if ( String(adfXML.@filename))
					{
						//trace(adfXML.toXMLString());
						
						var bdi : BitmapDataInfo = new BitmapDataInfo();
						bdi.bitmapDataRect.x = int(adfXML.@imgX);
						bdi.bitmapDataRect.y = int(adfXML.@imgY);
						bdi.bitmapDataRect.width = int(adfXML.@w);
						bdi.bitmapDataRect.height = int(adfXML.@h);
						bdi.bitmapDataName = String(adfXML.@filename);
						
						//trace(bdi.bitmapDataRect , bdi.bitmapDataName);
						
						BitmapDataInfoMgr.addABitmapDataInfo(adfXML , bdi);
					}
				}
				
				
				
			}
		}
		
	}

}