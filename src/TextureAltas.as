package 
{
	import Conf.AEV2;
	import Conf.Config;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import ImgMerge.ColorSample;
	import ImgMerge.RectangleArgs;
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIComponent.BSSCheckBox;
	import UISuit.UIComponent.BSSDropDownMenu;
	import UISuit.UIComponent.BSSDropDownMenuScrollable;
	import UISuit.UIComponent.BSSItemList;
	import UISuit.UIComponent.BSSItemListScrollBar;
	import UISuit.UIComponent.BSSScrollBar;
	import Util.GRA_Util.GraphicsUtil;
	
	/**
	 * ...
	 * @author blueshell
	 */
	public class TextureAltas extends Sprite 
	{
		private var m_il : BSSItemListScrollBar ;
		private var m_tb : Toolbar = new Toolbar();
		
		public static var inputFunction : Function;
		public static var outputFunction : Function;
		public static var inputFileFilterArray : Array = [new FileFilter("*.*", "*.*;")];
		public static var outputFileFilterArray : Array = [new FileFilter("*.*", "*.*;")];
		public static var DISMEMBER_HEIGHT : int = 1024;
		
		
		public static var s_result :  Vector.<RectangleArgs>;
		public function TextureAltas():void 
		{
			stage.scaleMode = "noScale";
			//stage.align = "LT";
			
			m_tb = new Toolbar();
			addChild(m_tb);
			m_tb.btnNew.releaseFunction = onNew;
			m_tb.btnSave.releaseFunction = onSave;
			m_tb.btnOpen.releaseFunction = onOpen;
			m_tb.btnMerge.releaseFunction = onMerge;
			m_tb.checkBoxImage.selectFunction = function (cb:BSSCheckBox):void
			{
				Config.imageForceTo2n = cb.selected;
				
				//trace(Config.imageForceTo2n);
			}
			
			//m_il
			var scrollBar : BSSScrollBar = BSSScrollBar.createSimpleBSSScrollBar(12, false);
			scrollBar.x = 1050 - 12 - 8;
			m_il = new BSSItemListScrollBar(scrollBar);
			m_il.height = 540;
			m_il.width = 1050;
			m_il.x = 4;
			
			addChild(m_il).y = 30;
			
			//var shape:Shape = new Shape();
			//shape.graphics.beginFill(0);
			//shape.graphics.drawRect(0, 0, 30, 30);
			//shape.graphics.endFill();
			
			//m_il.addItem(shape);
			
			addChild(new ModeSwitcher()).x = m_tb.x + m_tb.width + 5;
			
			
			 stage.addEventListener(MouseEvent.MOUSE_WHEEL , onMouseWheel);
		}
		
		
		private static function onMouseWheel(e : MouseEvent)
		: void 
		{
			CallBackMgr.CallBackMgr_notifyEvent(CALLBACK.ON_STAGE_MOUSE_WHEEL , [e] );
		}
		
		public function onNew( btn : BSSButton = null)
		: void 
		{
			BitmapDataInfoMgr.clear();
			if (s_result)
			{
				for each (var ra : RectangleArgs in s_result) 
					if (ra.newBitmapData)
						ra.newBitmapData.dispose();
						
				s_result.length = 0;
				s_result = null;
			}
			
			m_il.clearAllItem(true);
		
		}
		
		private static function onSave( btn : BSSButton)
		: void 
		{
			if ( outputFunction != null)
				outputFunction(s_result);
		}
		
		private function onMerge( btn : BSSButton)
		: void 
		{
			if (BitmapDataInfoMgr.allLoaded)
			{
				m_il.clearAllItem(true);
				
				var result : Vector.<Vector.<RectangleArgs>> = 
				 BitmapDataInfoMgr.deal( int(m_tb.widthInput.text) , int(m_tb.spaceInput.text) );
				
				 s_result = result[1];
				 createBmp(result[0]);
				 

				var raWithBitmapDataInfoArray : Vector.<RectangleArgs> = result[0];
				var raWithBitmapDataRefArray : Vector.<RectangleArgs> = result[1];
				
				for each (var raWithBitmapDataInfo : RectangleArgs in raWithBitmapDataInfoArray)
				{
					
					var bdiDealed : BitmapDataInfo = BitmapDataInfo(raWithBitmapDataInfo.args);
					
					for each (var raWithBitmapDataRef : RectangleArgs in raWithBitmapDataRefArray)
					{
						var bdr : BitmapDataRef = BitmapDataRef(raWithBitmapDataRef.args)
						if (bdr.bitmapDataInfo.isEqual (bdiDealed))
						{
							raWithBitmapDataRef.newBitmapData = raWithBitmapDataInfo.newBitmapData;
							raWithBitmapDataRef.newBitmapDataId = raWithBitmapDataInfo.newBitmapDataId;
							
							CONFIG::ASSERT {
								ASSERT( (raWithBitmapDataRef.x == raWithBitmapDataInfo.x
								&& raWithBitmapDataRef.width == raWithBitmapDataInfo.width
								&& raWithBitmapDataRef.height == raWithBitmapDataInfo.height) , "error"
								);
							}
							
							raWithBitmapDataRef.x = raWithBitmapDataInfo.x;
							raWithBitmapDataRef.y = raWithBitmapDataInfo.y;
							
							//Config::ASSERT {
							//}
							
						}
					}
					 
				}
			}
			
			//System.setClipboard(xml);
		}
		
		private var iColor:int;
		private function createBmp(rectArray : Vector.<RectangleArgs>) : void
		{
			var hMax : int;
			var wMax : int;
			var bi : int;
			var loop : int = 0;
			var done : Boolean = true;
			
			do {
				
				done = true;
				wMax = 0;
				hMax = 0;
				
				for (bi = 0 ; bi < rectArray.length; bi++ )
				{
					if (rectArray[bi].y + rectArray[bi].height >= DISMEMBER_HEIGHT)
					{
						done = false;
						continue;
					}	
					
				//	trace(rectArray[bi].newBitmapData)
				//	trace(rectArray[bi].newBitmapData)
					if (rectArray[bi].newBitmapData != null)
						continue;
						
					hMax = Math.max(hMax , rectArray[bi].y + rectArray[bi].height);
					wMax = Math.max(wMax , rectArray[bi].x + rectArray[bi].width);
					
					//trace(hMax , wMax)
				}
				//trace("^^^^^^^^^^^" , done, loop ,  hMax , wMax);
				
				var bd : BitmapData = new BitmapData(wMax , hMax , true , 0);
				var bdColor : BitmapData = new BitmapData(wMax , hMax , true , 0);

				iColor = 0;
				
				
				
				
				for (bi = 0 ; bi < rectArray.length; bi++ )
				{
					if (rectArray[bi].y + rectArray[bi].height >= DISMEMBER_HEIGHT)
						continue;
					
					if (rectArray[bi].newBitmapData != null)
						continue;
						
					var bdi : BitmapDataInfo = BitmapDataInfo(rectArray[bi].args);
					var rect : Rectangle = 	bdi.bitmapDataRect.clone();
					//trace("rectRaw " + rect + bdr.bitmapDataInfo.bitmapDataName , bdr.bitmapDataInfo.bitmapData.width , bdr.bitmapDataInfo.bitmapData.height);
					
					//trace(bdr , bdr.bitmapDataInfo , bdr.bitmapDataInfo.bitmapDataName , bdr.bitmapDataInfo.bitmapData);
					
					var ba : ByteArray = bdi.bitmapData.getPixels(rect);
					//trace("ba.length " + ba.length);

					rect.x = rectArray[bi] .x;
					rect.y = rectArray[bi] .y;
					ba.position = 0;
					
					//trace(loop , bi , rect , ba.length , bd.width , bd.height);
					bd.setPixels(rect , ba);
					
					rectArray[bi].newBitmapData = bd;
					rectArray[bi].newBitmapDataId = loop;
					
					bdColor.fillRect(rectArray[bi] , (ColorSample.color[iColor] | 0xFF000000));
					iColor = (iColor + 31) %  ColorSample.color.length;
				}
				
				
				
				var bmp : Bitmap = new Bitmap(bd);
				var bmp2 : Bitmap = new Bitmap(bdColor);
				
				while (bmp.width > 1024)
				{
					bmp.scaleX /= 2;
					bmp.scaleY /= 2;
					
					bmp2.scaleX /= 2;
					bmp2.scaleY /= 2;
				}
				
				
				var btnSp : Sprite = new Sprite();
				btnSp.addChild(bmp);
				var sp : Sprite = new Sprite();
				sp.addChild(new Bitmap(bmp.bitmapData));
				sp.addChild(new Bitmap(bmp2.bitmapData)).alpha = 0.5;
				btnSp.addChild( sp);
				var textField : TextField = new TextField();
				textField.y = bmp.bitmapData.height + 10;
				textField.width = 120;
				textField.text = "" +  bmp.bitmapData.width + "*" + bmp.bitmapData.height;
				btnSp.addChild( textField);

				btnSp.addChild( bmp2);
				
				m_il.addItem(new BSSButton(btnSp));
			
				
				if (!done)
				{
					for (bi = 0 ; bi < rectArray.length; bi++ )
					{
						if (rectArray[bi].newBitmapData == null)
						{	
							ASSERT(rectArray[bi].y + rectArray[bi].height >= DISMEMBER_HEIGHT , "error0" );
							rectArray[bi].y -= DISMEMBER_HEIGHT;
						}
					}
					
					
					
					var minYAva : int = DISMEMBER_HEIGHT;
					for (bi = 0 ; bi < rectArray.length; bi++ )
					{
						if (rectArray[bi].newBitmapData == null  && rectArray[bi].y < minYAva)
							minYAva = rectArray[bi].y;
					}
					
					if (minYAva)
					{
						for (bi = 0 ; bi < rectArray.length; bi++ )
						{
							if (rectArray[bi].newBitmapData == null)
							{	
								ASSERT(rectArray[bi].y >= minYAva , "error" , rectArray[bi].y , minYAva);
								rectArray[bi].y -= minYAva;
							}
						}
						
					}
					
				}
				loop++;
				
				if (!done)
				{
					var shape : Shape = new Shape();
					GraphicsUtil.DrawRect(shape.graphics , 0 , 0 , 512 , 24 , 0xFFFFFF , 0);
					shape.graphics.lineStyle(1 , 0);
					shape.graphics.moveTo(0, 12);
					shape.graphics.lineTo(1024, 12);
					
					m_il.addItem(shape);
				}
				
			} while (!done);
		}
		
		
		public static var s_loadFile:File;
		
		private function onOpen(btn : BSSButton)
		: void {
			if (inputFunction == null)
				return;
			
			var file:File = new File();
			file.addEventListener(Event.SELECT, onLoaded);
			file.browseForOpen("打开配置", inputFileFilterArray);
			s_loadFile = file;
		}
		
		private function onLoaded(e:Event):void{
			try{
				var data:ByteArray = new ByteArray();
				var stream:FileStream = new FileStream();
				stream.open(s_loadFile, FileMode.READ);
				stream.position = 0;
				stream.readBytes(data, 0, stream.bytesAvailable);
				stream.close();
				data.position = 0;
				
				
				//new ImageByteLoader().load([data], __imageLoaded);
			}catch (e:Error) {
				
				//JOptionPane.showMessageDialog("读取图形文件出错", e+"", null, pane);
			}	
			onNew();
			onDeal(data);
		}

		
/*		private static function onSelect(event : Event)
		: void 
		{
			var fb : FileReference = FileReference(event.currentTarget);
			fb.removeEventListener(event.type, arguments.callee);
			//Version.filename = fb.name;
			//DBG_TRACE("onSelect " + fb.name);
			
			fb.addEventListener(Event.COMPLETE , onSelectLoad);
			fb.load();
		}
*/	
		
		public static function onDeal(data:ByteArray)
		: void 
		{
			if (inputFunction != null)
			{
				inputFunction(data);
			}
			
			//trace(s_loadFile.name)
			BitmapDataInfoMgr.load(s_loadFile.nativePath.substring(0 , s_loadFile.nativePath.length - s_loadFile.name.length));

		}
		

		
		
	}
	
}