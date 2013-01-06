package org.flixel
{
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import org.flixel.*;
	
	/**
	 * FlxInputText v1.10, Input text field extension for Flixel
	 * contributors: Gama11, Mr_Walrus, Nitram_cero, and Martin Sebastian Wain
	 */
	
	public class FlxInputText extends FlxText 
	{
		
		static public const NO_FILTER:uint				= 0;
		static public const ONLY_ALPHA:uint				= 1;
		static public const ONLY_NUMERIC:uint			= 2;
		static public const ONLY_ALPHANUMERIC:uint		= 3;
		static public const CUSTOM_FILTER:uint			= 4;
		
		static public const ALL_CASES:uint				= 0;
		static public const UPPER_CASE:uint				= 1;
		static public const LOWER_CASE:uint				= 2;
		
		/**
		 * Defines what text to filter. It can be NO_FILTER, ONLY_ALPHA, ONLY_NUMERIC, ONLY_ALPHA_NUMERIC or CUSTOM_FILTER
		 * (Remember to append "FlxInputText." as a prefix to those constants)
		 */
		private var _filterMode:uint = NO_FILTER;
		
		/**
		 * This regular expression will filter out (remove) everything that matches. 
		 * This is activated by setting filterMode = FlxInputText.CUSTOM_FILTER.
		 */
		public var customFilterPattern:RegExp = /[]*/g;
		
		/**
		 * A function called when the enter key is pressed on this text box. 
		 * Function should be formatted "onEnterPressed(text:String)".
		 */
		public var enterCallBack:Function;
		
		/**
		 * Whether this text box has focus on the screen.
		 */
		private var _hasFocus:Boolean;
		
		/**
		 * The position of the selection cursor. An index of 0 means the carat is before the character at index 0.
		 */
		public var _caretIndex:int = -1;
		
		/**
		 * If this is set to true, text typed is forced to be uppercase.
		 */
		private var _forceCase:uint = ALL_CASES;
		
		/**
		 * The max amount of characters the textfield can contain.
		 */
		private var _maxLength:uint = 0;
		
		/**
		 * The amount of lines allowed in the textfield.
		 */
		private var _lines:uint = 1;
		
		/**
		 * The color of the background of the textbox.
		 */
		public var backgroundColor:uint;
		
		/**
		 * Whether or not the textbox has a background
		 */
		public var background:Boolean = false;
		
		/**
		 * A timer for the flashing caret effect.
		 */
		protected var caretTimer:FlxTimer;
		
		/**
		 * A FlxSprite representing the flashing caret when editing text.
		 */
		protected var caret:FlxSprite;
		
		/**
		 * The caret's color. Has the same color as the text by default.
		 */
		public var caretColor:uint;
		
		/**
		 * A FlxSprite representing the borders.
		 */
		private var borderSprite:FlxSprite;
		
		/**
		 * The thickness of the borders. 0 to disable.
		 */
		private var _borderThickness:uint = 1;
		
		/**
		 * The color of the borders.
		 */
		private var _borderColor:uint = 0xFF000000;
		
		/**
		 * Creates a new editable text box.
		 * @param	X					The X position of the text.
		 * @param	Y					The Y position of the text.
		 * @param	Width				The width of the text box.
		 * @param	Text				The text to display initially.
		 * @param	TextColor			The color of the text.
		 * @param	BackgroundColor		The color of the box background. Set to 0 to disable background.
		 * @param	EmbeddedFont		Whether this text field uses embedded fonts.
		 */
		public function FlxInputText(X:Number, Y:Number, Text:String=null, Width:uint=200, TextColor:uint = 0xFF000000, BackgroundColor:uint = 0xFFFFFFFF, EmbeddedFont:Boolean=true)
		{
			super(X, Y, Width, Text, EmbeddedFont);
			
			backgroundColor = BackgroundColor;
			if (BackgroundColor != 0) background = true;
			
			color = TextColor;
			caretColor = TextColor;
			
			caretTimer = new FlxTimer();
			
			caret = new FlxSprite();
			caret.makeGraphic(1, size + 2, 0xFFFFFFFF);
			caret.color = caretColor;
			caretIndex = 0;
			
			hasFocus = false;

			borderSprite = new FlxSprite(X, Y);
			
			lines = 1;

			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			
			calcFrame();
		}
		
		/**
		 * Draw the caret in addition to the text.
		 */
		override public function draw():void 
		{
			drawSprite(borderSprite);
			
			super.draw();
			
			// In case careColor was changed
			if (caretColor != caret.color || caret.height != size + 2) 
				caret.color = caretColor;
			
			drawSprite(caret);
		}
		
		/**
		 * Helper function that makes sure sprites are drawn up even though they haven't been added.
		 * @param	Sprite		The Sprite to be drawn.
		 */
		private function drawSprite(Sprite:FlxSprite):void
		{
			if (Sprite != null && Sprite.visible) {
				Sprite.scrollFactor = scrollFactor;
				Sprite.cameras = cameras;
				Sprite.draw();
			}
		}
		
		/**
		 * Check for mouse input every tick.
		 */
		override public function update():void 
		{
			super.update();
			
			// Set focus and caretIndex as a response to mouse press
			if (FlxG.mouse.justPressed()) {
				if (overlapsPoint(new FlxPoint(FlxG.mouse.x, FlxG.mouse.y))) {
					caretIndex = getCaretIndexFromPoint(new FlxPoint(FlxG.mouse.x, FlxG.mouse.y));
					hasFocus = true;
				}
				else {
					hasFocus = false;
				}
			}
		}
		
		/**
		 * Handles keypresses generated on the stage.
		 * @param	e		The triggering keyboard event.
		 */
		private function handleKeyDown(e:KeyboardEvent):void 
		{
			var key:uint = e.keyCode;
			
			if (hasFocus) {
				// Do nothing for Shift, Ctrl and flixel console hotkey
				if (key == 16 || key == 17 || key == 220) 
				{
					return;
				}
				// Left arrow
				else if (key == 37) 
				{ 
					if (caretIndex > 0) caretIndex --;
				}
				// Right arrow
				else if (key == 39) 
				{ 
					if (caretIndex < text.length) caretIndex ++;
				}
				// Backspace
				else if (key == 8) 
				{
					if (caretIndex > 0) {
						text = text.slice(0, caretIndex - 1) + text.slice(caretIndex);
						caretIndex --;
					}
				}
				// Delete
				else if (key == 46)
				{
					if (text.length > 0 && caretIndex < text.length) {
						text = text.slice(0, caretIndex) + text.slice(caretIndex+1);
					}
				}
				// Enter
				else if (key == 13) 
				{
					if (enterCallBack != null) enterCallBack(text);
				}
				// Actually add some text
				else 
				{
					var newText:String = filter(String.fromCharCode(e.charCode));
					
					if (newText.length > 0 && (maxLength == 0 || (text.length + newText.length) < maxLength)) {
						text = insertSubstring(text, newText, caretIndex);
						caretIndex++;
					}
				}
			}
		}
		
		/**
		 * Inserts a substring into a string at a specific index
		 * @param	Insert			The string to have something inserted into
		 * @param	Insert			The string to insert
		 * @param	Index			The index to insert at
		 * @return					Returns the joined string for chaining.
		 */
		private function insertSubstring(Original:String, Insert:String, Index:uint):String 
		{
			if (Index != Original.length) {
				Original = Original.slice(0, Index).concat(Insert).concat(Original.slice(Index));
			}
			else {
				Original = Original.concat(Insert);
			}
			return Original;
		}
		
		/**
		 * Gets the index of a character in this box at a point
		 * @param	Landing			The point to check for.
		 * @return					The index of the character hit by the point. 
		 * 							Returns -1 if the point is not found.
		 */
		public function getCaretIndexFromPoint(Landing:FlxPoint):int
		{
			var hit:FlxPoint = new FlxPoint(FlxG.mouse.x - x, FlxG.mouse.y - y);
			var caretRightOfText:Boolean = false;
			if (hit.y < 2) hit.y = 2;
			else if (hit.y > _textField.textHeight + 2) hit.y = _textField.textHeight + 2;
			if (hit.x < 2) hit.x = 2;
			else if (hit.x > _textField.getLineMetrics(0).width) {
				hit.x = _textField.getLineMetrics(0).width;
				caretRightOfText = true;
			}
			else if (hit.x > _textField.getLineMetrics(_textField.numLines-1).width && hit.y > _textField.textHeight - _textField.getLineMetrics(_textField.numLines - 1).ascent) {
				hit.x = _textField.getLineMetrics(_textField.numLines - 1).width;
				caretRightOfText = true;
			}
			var index:uint;
			if (caretRightOfText) index = _textField.getCharIndexAtPoint(hit.x, hit.y) + 1;
			else {
				index = _textField.getCharIndexAtPoint(hit.x, hit.y);
			}
			return index;
		}
		
		/**
		 * Draws the frame of animation for the input text.
		 */
		override protected function calcFrame():void 
		{
			super.calcFrame();
			
			if (borderSprite != null && borderThickness > 0) {
				borderSprite.makeGraphic(width + borderThickness * 2, height + borderThickness * 2, borderColor);
				borderSprite.x = x - borderThickness;
				borderSprite.y = y - borderThickness;
			}
			else if (borderThickness == 0) 
				borderSprite.visible = false;

			// Draw background
			if (background) 
			{
				var buffer:BitmapData = new BitmapData(width, height * 2, true, backgroundColor); 
				buffer.draw(framePixels);
				framePixels = buffer;		
			}
		}
		
		/**
		 * Turns the caret on/off for the caret flashing animation.
		 */
		protected function toggleCaret(timer:FlxTimer = null):void
		{
			caretTimer.loops ++; // Run the timer forever
			caret.visible = !caret.visible;
		}
		
		/**
		 * Clean up after ourselves
		 */
		override public function destroy():void 
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			super.destroy();
		}
		
		/**
		 * Checks an input string against the current 
		 * filter and returns a filtered string
		 * @param	text	Unfiltered text
		 * @return			Text filtered by the the filter mode of the box
		 */
		private function filter(text:String):String
		{
			if (forceCase == UPPER_CASE)
				text = text.toUpperCase();
			else if (forceCase == LOWER_CASE)
				text = text.toLowerCase();
				
			if (filterMode != NO_FILTER) {
				var pattern:RegExp;
				switch(filterMode) {
					case ONLY_ALPHA:		pattern = /[^a-zA-Z]*/g;		break;
					case ONLY_NUMERIC:		pattern = /[^0-9]*/g;			break;
					case ONLY_ALPHANUMERIC:	pattern = /[^a-zA-Z0-9]*/g;		break;
					case CUSTOM_FILTER:		pattern = customFilterPattern;	break;
					default:
						throw new Error("FlxInputText: Unknown filterMode ("+filterMode+")");
				}
				text = text.replace(pattern, "");
			}
			return text;
		}
		
		/**
		 * Whether or not the text box is the active object on the screen.
		 */
		public function get hasFocus():Boolean
		{
			return _hasFocus;
		}
		
		/**
		 * @private
		 */
		public function set hasFocus(newFocus:Boolean):void
		{
			if (newFocus) 
			{
				if (hasFocus != newFocus) {
					caretTimer.start(0.5, 4, toggleCaret);
					caret.visible = true;
					caretIndex = text.length;
				}
				
			}
			else 
			{
				// Graphics
				caret.visible = false;
				caretTimer.stop();
			}
			if (newFocus != _hasFocus) calcFrame();
			_hasFocus = newFocus;
		}
		
		/**
		 * The position of the selection cursor. An index of 0 means the carat is before the character at index 0.
		 */
		public function get caretIndex():int
		{
			return _caretIndex;
		}
		
		/**
		 * @private
		 */
		public function set caretIndex(newCaretIndex:int):void
		{
			_caretIndex = newCaretIndex;
			
			// If caret is too far to the right something is wrong
			if (_caretIndex > text.length + 1) _caretIndex = -1; 
			
			// Caret is OK, proceed to position
			if (_caretIndex != -1) 
			{
				var boundaries:Rectangle;
				
				// Caret is not to the right of text
				if (_caretIndex < _textField.length) { 
					boundaries = _textField.getCharBoundaries(_caretIndex);
					if (boundaries != null) {
						caret.x = boundaries.left + x;
						caret.y = boundaries.top + y;
					}
				}
				// Caret is to the right of text
				else { 
					boundaries = _textField.getCharBoundaries(_caretIndex - 1);
					if (boundaries != null) {
						caret.x = boundaries.right + x;
						caret.y = boundaries.top + y;
					}
					// Text box is empty
					else if (text.length == 0) { 
						// 2 px gutters
						caret.x = x + 2; 
						caret.y = y + 2; 
					}
				}
			}
			
			// Make sure the caret doesn't leave the textfield on single-line input texts
			if (lines == 1 && caret.x + caret.width > x + width) 
				caret.x = x + width - 2;
		}
		
		/**
		 * Enforce upper-case or lower-case
		 * @param	Case		The Case that's being enforced. Either ALL_CASES, UPPER_CASE or LOWER_CASE.
		 */
		public function get forceCase():uint
		{ 
			return _forceCase;
		}
		
		public function set forceCase(Case:uint):void
		{ 
			_forceCase = Case;
			text = filter(text);size
		}
		
		override public function set size(Size:Number):void
		{
			super.size = Size;
			
			caret.makeGraphic(1, size + 2, 0xFFFFFFFF);
		}
		
		/**
		 * Set the maximum length for the field (e.g. "3" 
		 * for Arcade type hi-score initials)
		 * @param	Length		The maximum length. 0 means unlimited.
		 */
		public function get maxLength():uint
		{
			return _maxLength;
		}
		
		public function set maxLength(Length:uint):void
		{
			_maxLength = Length;
			if (text.length > _maxLength) 
				text = text.substring(0, _maxLength);
		}
		
		/**
		 * Change the amount of lines that are allowed.
		 * @param	Lines		How many lines are allowed
		 */
		
		public function get lines():uint
		{
			return _lines;
		}
		
		public function set lines(Lines:uint):void
		{
			if (Lines == 0) return;
			
			if (Lines > 1) {
				_textField.wordWrap = true;
				_textField.multiline = true;
			}
			else {
				_textField.wordWrap = false;
				_textField.multiline = false;
			}
			
			_lines = Lines;
			calcFrame();
		}
		
		/**
		 * Whether or not the textfield is a password textfield
		 * @param	enable		Whether to en- or disable password mode
		 */
		public function get passwordMode():Boolean
		{
			return _textField.displayAsPassword;
		}
		
		public function set passwordMode(enable:Boolean):void
		{
			_textField.displayAsPassword = enable;
			calcFrame();
		}
	
		/**
		 * Defines what text to filter. It can be NO_FILTER, ONLY_ALPHA, ONLY_NUMERIC, ONLY_ALPHA_NUMERIC or CUSTOM_FILTER
		 * (Remember to append "FlxInputText." as a prefix to those constants)
		 * @param	newFilter		The filtering mode
		 */
		public function get filterMode():uint
		{
			return _filterMode;
		}
		
		public function set filterMode(newFilter:uint):void
		{
			_filterMode = newFilter;
			text = filter(text);
		}
		
		/**
		 * The color of the borders
		 * @param	newColor		The new color 
		 */
		public function set borderColor(newColor:uint):void
		{
			_borderColor = newColor;
			calcFrame();
		}
		
		public function get borderColor():uint
		{
			return _borderColor;
		}
		
		/**
		 * The thickness of the borders
		 * @param	newThickness		The new thickness 
		 */
		public function set borderThickness(newThickness:uint):void
		{
			_borderThickness = newThickness;
			calcFrame();
		}
		
		public function get borderThickness():uint
		{
			return _borderThickness;
		}
	}
}