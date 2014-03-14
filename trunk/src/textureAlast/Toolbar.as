package textureAlast
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIComponent.BSSCheckBox;
	/**
	 * ...
	 * @author blueshell
	 */
	public class Toolbar extends SripteWithRect
	{
		
		public var btnNew : BSSButton;
		public var btnOpen : BSSButton;
		public var btnSave : BSSButton;
		public var btnMerge : BSSButton;
		
		public var widthInput : TextField;
		public var spaceInput : TextField;
		
		public var checkBoxImage : BSSCheckBox;
		
		public function Toolbar() 
		{
			
			btnNew= BSSButton.createSimpleBSSButton(20, 20, StringPool.NEW , true);
			btnNew.x = 5;
			btnNew.y = 5 ;
			addChild(btnNew) ;
			
			btnOpen = BSSButton.createSimpleBSSButton(20, 20, StringPool.OPEN , true);
			btnOpen.x = btnNew.x + btnNew.width + 5;
			btnOpen.y = 5 ;
			addChild(btnOpen) ;
			
			btnSave =  BSSButton.createSimpleBSSButton(20, 20, StringPool.SAVE , true);
			btnSave.x = btnOpen.x + btnOpen.width + 5;
			btnSave.y = 5 ;
			addChild(btnSave) ;
			
			btnMerge =  BSSButton.createSimpleBSSButton(20, 20, StringPool.MERGE , true);
			btnMerge.x = btnSave.x + btnSave.width + 5;
			btnMerge.y = 5 ;
			addChild(btnMerge) ;
			
			var textField : TextField;
			textField = new TextField();
			textField.width = 1000;
			textField.height = 20;
			textField.text = StringPool.WIDTH;
			textField.width = textField.textWidth + 4;
			textField.x = btnMerge.x + btnMerge.width + 5;
			textField.y = 5 ;
			addChild(textField) ;
			
			
			widthInput = new TextField();
			widthInput.width = 48;
			widthInput.height = 20;
			widthInput.text = "256";
			widthInput.maxChars = 4;
			widthInput.restrict = "0-9";
			widthInput.x = textField.x + textField.width + 5;
			widthInput.y = 5 ;
			widthInput.border = true;
			widthInput.background = true;
			widthInput.type = TextFieldType.INPUT;
			addChild(widthInput) ;
			
			
			
			textField = new TextField();
			textField.width = 1000;
			textField.height = 20;
			textField.text = StringPool.SPACE;
			textField.width = textField.textWidth + 4;
			textField.x = widthInput.x + widthInput.width + 5;
			textField.y = 5 ;
			addChild(textField) ;
			
			
			spaceInput = new TextField();
			spaceInput.width = 48;
			spaceInput.height = 20;
			spaceInput.text = "1";
			spaceInput.maxChars = 2;
			spaceInput.restrict = "0-9";
			spaceInput.x = textField.x + textField.width + 5;
			spaceInput.y = 5 ;
			spaceInput.border = true;
			spaceInput.background = true;
			spaceInput.type = TextFieldType.INPUT;
			addChild(spaceInput) ;
			
			
			textField = new TextField();
			textField.width = 1000;
			textField.height = 20;
			textField.text = StringPool.IMAGE_2;
			textField.width = textField.textWidth + 4;
			textField.x = spaceInput.x + spaceInput.width + 5;
			textField.y = 5 ;
			addChild(textField) ;
		
			checkBoxImage = BSSCheckBox.createSimpleBSSCheckBox(16);
			checkBoxImage.x = textField.x + textField.width + 5;
			checkBoxImage.y = 5 + 2 ;
			addChild(checkBoxImage) ;
		}
		
		public override function dispose()
		: void 
		{
			
			btnNew.dispose() ; btnNew = null;
			btnOpen.dispose() ; btnOpen = null;
			btnSave.dispose() ; btnSave = null;

		}
		
		
	}

}