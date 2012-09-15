package ImgMerge
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author blueshell
	 */
	public class Main extends Sprite 
	{
		
		private var bmp : Bitmap = new Bitmap();
		private var floorPlane : FloorPlane = new FloorPlane();
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = "LT";
			addChild(bmp);
			
			var rectArray : Vector.<RectangleArgs> = floorPlane.test();
			createBmp(rectArray);
			
			//stage.addEventListener(MouseEvent.MOUSE_DOWN , onTestStepNext);

		}
		
		
		private function onTestStepNext(e:MouseEvent):void 
		{
			var rectArray : Vector.<RectangleArgs> = floorPlane.testStepNext();
			if (rectArray)
				createBmp(rectArray);
		}
		
		private var iColor:int;
		private function createBmp(rectArray : Vector.<RectangleArgs>):void
		{
			var hMax : int;
			var wMax : int;
			var bi : int;
			for (bi = 0 ; bi < rectArray.length; bi++ )
			{
				hMax = Math.max(hMax , rectArray[bi].y + rectArray[bi].height);
				wMax = Math.max(wMax , rectArray[bi].x + rectArray[bi].width);
			}
			
			var bd : BitmapData = new BitmapData(wMax , hMax , true , 0);
				
			iColor = 0;
			for (bi = 0 ; bi < rectArray.length; bi++ )
			{
				bd.fillRect(rectArray[bi] , (ColorSmaple.color[iColor] | 0xFF000000));
				iColor = (iColor + 31) %  ColorSmaple.color.length;
			}
			bmp.bitmapData = bd;
		}
		
	}
	
}