package  
{
	import Conf.AEV2;
	import Conf.Aurora;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import UISuit.UIComponent.BSSButton;
	import Util.GRA_Util.GraphicsUtil;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ModeSwitcher extends SripteWithRect
	{
		
		private var m_areaArray : Vector.<BSSButton> = new Vector.<BSSButton> ();
		
		public function ModeSwitcher() 
		{
			
			var btn : BSSButton;
			var btnOld : BSSButton;
			btn = BSSButton.createSimpleBSSButton(20, 20, "AEV2" , true , m_areaArray);
			btn .x = 5;
			btn .y = 5 ;
			btn.statusMode = true;
			addChild(btn) ;
			btnOld = btn;
			
			btn.releaseFunction = function (btn:BSSButton):void {
				TextureAltas.inputFunction = AEV2.input;
				TextureAltas.outputFunction = AEV2.output;
				TextureAltas.inputFileFilterArray = AEV2.inputFileFilterArray;
				TextureAltas.outputFileFilterArray = AEV2.outputFileFilterArray;
			}
			
			
			btn = BSSButton.createSimpleBSSButton(20, 20, "Aurora" , true, m_areaArray);
			btn.x = btn.x + btn.width + 5;
			btn.y = 5 ;
			btn.statusMode = true;
			addChild(btn) ;
			btnOld = btn;
			btn.releaseFunction = function (btn:BSSButton):void {
				TextureAltas.inputFunction = Aurora.input;
				TextureAltas.outputFunction = Aurora.output;
				TextureAltas.inputFileFilterArray = Aurora.inputFileFilterArray;
				TextureAltas.outputFileFilterArray = Aurora.outputFileFilterArray;
			}
		}
		
		public override function dispose()
		: void 
		{
			GraphicsUtil.removeAllChildrenWithDispose(this);
		}
		
		
	}

}