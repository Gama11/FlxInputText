package 
{
	import org.flixel.*;
	
	public class GameState extends FlxState 
	{	
		private static var normalField:FlxInputText;
		private static var upperCaseField:FlxInputText;
		private static var lowerCaseField:FlxInputText;
		private static var numericField:FlxInputText;
		private static var alphaBeticField:FlxInputText;
		private static var alphaNumericField:FlxInputText;
		private static var passwordField:FlxInputText;
		private static var fancyField:FlxInputText;
		private static var invertedField:FlxInputText;
		private static var enterField:FlxInputText;
		private static var maxField:FlxInputText;
		private static var differentFontField:FlxInputText;
		private static var multiLineField:FlxInputText;
		
		private static const TEXTS:Array = 
		[
		"Normal textfield, already has focus.",
		"this one enforces uppercase",
		"THIS ONE ENFORCES LOWERCASE",
		"0nly Numb3rs h3r3",
		"0nly l3tt3rs h3r3",
		"No special characters like ,.-/() or even Space",
		"Nobody can read this password",
		"The colors of this once are fancy",
		"You can also get rid of the borders",
		"Press Enter to activate a callacback",
		"This one has a maximum length of 10 chars",
		"This one uses Arial as Font",
		"This textfield has multiple lines and will get bigger and bigger as you type.",
		];
		
		private var inputFieldGroup:FlxGroup;
		private var actualTexts:FlxGroup;
		
		private var currentY:uint = 100;
		private var currentNumber:uint = 0;
		private	var gap:uint = 20;
		
		[Embed(source = "../assets/arial.ttf", fontFamily = "system", embedAsCFF = "false")] protected var arial:String;
		
		override public function create():void
		{
			FlxG.bgColor = FlxG.WHITE;
			FlxG.mouse.show();
			
			var headline:FlxText = new FlxText(5, 5, FlxG.width, "FlxInputText.as");
			headline.size = 32; 
			headline.shadow = 0xFFa8a8a8;
			headline.color = FlxG.BLACK; 
			add(headline);
			
			var explanation:FlxText = new FlxText(5, 60, FlxG.width, "Input Fields:                Actual text that has been put into:");
			explanation.size = 16; 
			explanation.color = 0xFF313131; 
			add(explanation);
			
			inputFieldGroup = new FlxGroup;
			actualTexts = new FlxGroup;
			
			// Create a number of FlxInputTexts to demonstrate what they're capable of
			normalField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			normalField.hasFocus = true;
			createText();
			
			upperCaseField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			upperCaseField.forceCase = FlxInputText.UPPER_CASE;
			createText();
			
			lowerCaseField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			lowerCaseField.forceCase = FlxInputText.LOWER_CASE;
			createText();

			numericField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			numericField.filterMode = FlxInputText.ONLY_NUMERIC;
			createText();
			
			alphaBeticField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			alphaBeticField.filterMode = FlxInputText.ONLY_ALPHA;
			createText();

			alphaNumericField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			alphaNumericField.filterMode = FlxInputText.ONLY_ALPHANUMERIC;
			createText();
			
			passwordField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			passwordField.passwordMode = true;
			createText();
			
			fancyField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			fancyField.backgroundColor = FlxG.BLUE;
			fancyField.caretColor = FlxG.PINK;
			fancyField.color = FlxG.GREEN;
			fancyField.borderColor = FlxG.RED;
			createText();
			
			invertedField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			invertedField.borderThickness = 0;
			invertedField.backgroundColor = FlxG.BLACK;
			invertedField.caretColor = FlxG.WHITE;
			invertedField.color = FlxG.WHITE;
			createText();
			
			enterField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			enterField.enterCallBack = enterCallback;
			createText();
			
			maxField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			maxField.maxLength = 10;
			createText();
			
			differentFontField = new FlxInputText(10, currentY, TEXTS[currentNumber], 200, 0xFF000000, 0xFFFFFFFF, false);
			differentFontField.font = arial;
			createText();
			
			multiLineField = new FlxInputText(10, currentY, TEXTS[currentNumber]);
			multiLineField.lines = 2;
			createText();

			// Add all the fields to the stage
			inputFieldGroup.add(normalField);
			inputFieldGroup.add(upperCaseField);
			inputFieldGroup.add(lowerCaseField);
			inputFieldGroup.add(numericField);
			inputFieldGroup.add(alphaBeticField);
			inputFieldGroup.add(alphaNumericField);
			inputFieldGroup.add(passwordField);
			inputFieldGroup.add(fancyField);
			inputFieldGroup.add(invertedField);
			inputFieldGroup.add(enterField);
			inputFieldGroup.add(maxField);
			inputFieldGroup.add(differentFontField);
			inputFieldGroup.add(multiLineField);
			
			add(inputFieldGroup);
			add(actualTexts);

			super.create();
		}
		
		private function createText():void
		{
			var text:FlxText = new FlxText(230, currentY, FlxG.width - 300, TEXTS[currentNumber]);
			text.color = FlxG.BLACK;
			actualTexts.add(text);
			currentY += gap;
			currentNumber ++;
		}
		
		private function enterCallback(t:String):void
		{
			(actualTexts.members[9] as FlxText).text = "Text submitted!";
		}
	}
}