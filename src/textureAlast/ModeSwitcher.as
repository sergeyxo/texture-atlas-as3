package textureAlast
{
	import  textureAlast.Conf.*;
	import UISuit.UIUtils.GraphicsUtil;


	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import UISuit.UIComponent.BSSButton;
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
				TextureAtlas.inputFunction = AEV2.input;
				TextureAtlas.outputFunction = AEV2.output;
				TextureAtlas.inputFileFilterArray = AEV2.inputFileFilterArray;
				TextureAtlas.outputFileFilterArray = AEV2.outputFileFilterArray;
			}
			
			
			btn = BSSButton.createSimpleBSSButton(20, 20, "Aurora" , true, m_areaArray);
			btn.x = btnOld.x + btnOld.width + 5;
			btn.y = 5 ;
			btn.statusMode = true;
			addChild(btn) ;
			btnOld = btn;
			btn.releaseFunction = function (btn:BSSButton):void {
				TextureAtlas.inputFunction = Aurora.input;
				TextureAtlas.outputFunction = Aurora.output;
				TextureAtlas.inputFileFilterArray = Aurora.inputFileFilterArray;
				TextureAtlas.outputFileFilterArray = Aurora.outputFileFilterArray;
			}
			
			btn = BSSButton.createSimpleBSSButton(20, 20, "AvtMote" , true, m_areaArray);
			btn.x = btnOld.x + btnOld.width + 5;
			btn.y = 5 ;
			btn.statusMode = true;
			addChild(btn) ;
			btnOld = btn;
			btn.releaseFunction = function (btn:BSSButton):void {
				TextureAtlas.inputFunction = AvtMote.input;
				TextureAtlas.outputFunction = AvtMote.output;
				TextureAtlas.inputFileFilterArray = AvtMote.inputFileFilterArray;
				TextureAtlas.outputFileFilterArray = AvtMote.outputFileFilterArray;
			}
			
			btn = BSSButton.createSimpleBSSButton(20, 20, "Mnme" , true, m_areaArray);
			btn.x = btnOld.x + btnOld.width + 5;
			btn.y = 5 ;
			btn.statusMode = true;
			addChild(btn) ;
			btnOld = btn;
			btn.releaseFunction = function (btn:BSSButton):void {
				TextureAtlas.inputFunction = Mnme.input;
				TextureAtlas.outputFunction = Mnme.output;
				TextureAtlas.inputFileFilterArray = Mnme.inputFileFilterArray;
				TextureAtlas.outputFileFilterArray = Mnme.outputFileFilterArray;
			}
			
		}
		
		public override function dispose()
		: void 
		{
			GraphicsUtil.removeAllChildrenWithDispose(this);
		}
		
		
	}

}