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
	public class Aurora
	{
		public static var inputFileFilterArray : Array = [new FileFilter("sprite file", "*.sprite;*.asprite") , new FileFilter("*.*", "*.*;") ];
		public static var outputFileFilterArray : Array = [new FileFilter("*.*", "*.sprite;")];
		private static var inString : String;
		private static var outString : String;
		private static var bitmapDataArray : Vector.<BitmapData>;
		
		private static var m_imageString : String = null;
		private static var m_moduleString : String = null;
		
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
				var str : String = String(bdr.ref);
				
				var arr : Array = str.split(/\s/);
				
				//trace(str);
				//for ( si  = 0 ; si < arr.length; si++ )
				//{
				//	trace(arr[si] );
				//}
				
				for (var si : int = 0 ; si < arr.length; si++ )
				{
					
					
					
					if (arr[si] == "MD_IMAGE")
					{
						arr[si + 1]  = "" + s_result[bi].newBitmapDataId;
						arr[si + 2]  = s_result[bi].x;
						arr[si + 3]  = s_result[bi].y;
						//arr[si + 4]  =
						//arr[si + 5]  =
					}
				}
				
				var newString : String = arr.join("\t");
				newString += "\n"
				
				//trace( str + "\n" + newString);
				
				
				outString = outString.replace( str , newString);
				
				
				//trace(xml.toXMLString());
				//xml.@imgX = s_result[bi].x;
				//xml.@imgY = s_result[bi].y; 
				//xml.@filename = "mergeImage_" + s_result[bi].newBitmapDataId + ".png";
				
				
				//trace("+++" + xml.toXMLString());
				
				
			}
		
			
			var destImgString : String = "";
			
			for (bi  = 0 ; bi < bitmapDataArray.length ; bi++ )
			{
				if (!bitmapDataArray[bi])
				{
					
					break;
				}
				else
				{
					destImgString += "IMAGE\t0x00" + int(int( bi / 10) % 10) + "" + int(bi % 10) + "\t\"mergeImage_" + bi + ".png\"\n";
				}
			}
			
			outString = outString.replace( m_imageString , destImgString);
			
			var file:File = new File();
			file.addEventListener(Event.SELECT, fileSelected); 
			file.browseForSave("保存配置");
			
		
		}	 
 
		private static function fileSelected(event : Event): void
		{ 
		
			var saveFile:File = File(event.currentTarget);
			
			
			try{
				var stream:FileStream = new FileStream();
				stream.open(saveFile, FileMode.WRITE);
				stream.position = 0;
				stream.writeMultiByte(outString , "gb2312");
				stream.close();
			}catch(e:Error){
			}	
			
			var dirUrl : String = saveFile.nativePath.substring(0 , saveFile.nativePath.length - saveFile.name.length)
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

		public static function input(data:ByteArray) : void
		{
			inString = data.readMultiByte(data.length , "gb2312");
			outString = inString;
			m_imageString = null;
			//trace(inString);
			
			var imgRegExp : RegExp = /IMAGE[\s]+0x[0-9]+[\s]+\"([^\"]+)\"\s/gi;
			
			var filenameArray : Vector.<String> = new Vector.<String>();
			
			do {
			
				var  imgObj : Object = imgRegExp.exec(inString);
			
				if (imgObj)
				{
					if (m_imageString == null)
						m_imageString = imgObj[0];
					
					filenameArray.push(imgObj[1]);
				}
					//if (imgObj)
				//trace(imgObj[1]);
			
			} while (imgObj);
			
			if (filenameArray.length == 0)
			{	
				CONFIG::ASSERT {ASSERT(false , "no img");}
				return;
			}
				
			for (var i : int = 1 ; i < filenameArray.length; i++)
				outString = outString.replace(filenameArray[i] , ""); //only reserve one space
				
				
			var moduleRegExp : RegExp = /MODULES[\s]+\{[^\{]*}/gi;
			var moduleObj : Object = moduleRegExp.exec(inString);
			
			m_moduleString = null;
			if (moduleObj)
				m_moduleString = (moduleObj[0]);
			
			if (!m_moduleString)
			{
				CONFIG::ASSERT {ASSERT(false , "no modules");}
				return;
			}
	
			
			//trace(m_moduleString);
			
			var moduleLineRegExp : RegExp = /MD[\s]+[xX0-9a-fA-F]+[\s]+MD_IMAGE[\s]+([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+\"[^\n]+[\n]/gi;
			
			
			do {
			
				var  moduleLineObj : Object = moduleLineRegExp.exec(m_moduleString);
			
				if (moduleLineObj)
				{
						//trace(moduleLineObj[0]);
						
						var bdi : BitmapDataInfo = new BitmapDataInfo();
						bdi.bitmapDataRect.x = int(moduleLineObj[2]);
						bdi.bitmapDataRect.y = int(moduleLineObj[3]);
						bdi.bitmapDataRect.width = int(moduleLineObj[4]);
						bdi.bitmapDataRect.height = int(moduleLineObj[5]);
						bdi.bitmapDataName = filenameArray[int(moduleLineObj[1])];
						
						//trace(bdi.bitmapDataRect , bdi.bitmapDataName);
						BitmapDataInfoMgr.addABitmapDataInfo(moduleLineObj[0] , bdi);
						

				}
			
			} while (moduleLineObj);
			
		}

	}

}