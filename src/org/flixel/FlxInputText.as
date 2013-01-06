package org.flixel
{
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import org.flixel.*;
	
	/**
	FlxInputText v1.00, Input text field extension for Flixel
	author Mr_Walrus
	original by Nitram_cero, Martin Sebastian Wain
	 */
	
	public class FlxInputText extends FlxText {
		
		static public const NO_FILTER:uint				= 0;
		static public const ONLY_ALPHA:uint				= 1;
		static public const ONLY_NUMERIC:uint			= 2;
		static public const ONLY_ALPHANUMERIC:uint		= 3;
		static public const CUSTOM_FILTER:uint			= 4;
		
		/**
		 * Defines what text to filter. It can be NO_FILTER, ONLY_ALPHA, ONLY_NUMERIC, ONLY_ALPHA_NUMERIC or CUSTOM_FILTER
		 * (Remember to append "FlxInputText." as a prefix to those constants)
		 */
		public var filterMode:uint = NO_FILTER;
		
		/**
		 * This regular expression will filter out (remove) everything that matches. 
		 * This is activated by setting filterMode = FlxInputText.CUSTOM_FILTER.
		 */
		public var customFilterPattern:RegExp = /[]*/g;
		
		/**
		 * If this is set to true, text typed is forced to be uppercase.
		 */
		public var forceUpperCase:Boolean = false;
		
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
		 * The color of the text when it is highlighted.
		 */
		public var highlightColor:uint;
		
		/**
		 * The background color of the text when it is highlighted.
		 */
		public var highlightBGColor:uint;
		
		/**
		 * Whether the text is being selected as a chunk.
		 */
		protected var dragging:Boolean = false;
		
		/**
		 * The color of the background of the textbox.
		 */
		public var backgroundColor:uint;
		
		/**
		 * Whether or not the textbox has a background
		 */
		public var background:Boolean;
		
		/**
		 * A timer for the flashing caret effect.
		 */
		protected var caretTimer:FlxTimer;
		
		/**
		 * A FlxSprite representing the flashing caret when editing text.
		 */
		protected var caret:FlxSprite;
		
		/**
		 * Creates a new editable text box.
		 * @param	X					The X position of the text.
		 * @param	Y					The Y position of the text.
		 * @param	Width				The width of the text box.
		 * @param	Text				The text to display initially.
		 * @param	Color				The color of the text.
		 * @param	BackgroundColor		The color of the box background.
		 * @param	EmbeddedFont		Whether this text field uses embedded fonts.
		 */
		public function FlxInputText(X:Number, Y:Number, Width:uint, Text:String=null, Color:uint = 0xffffff, BackgroundColor:uint = 0x00000000, EmbeddedFont:Boolean=true)
		{
			super(X, Y, Width, Text, EmbeddedFont);
			backgroundColor = BackgroundColor;
			color = Color;
			background = true;
			
			caretTimer = new FlxTimer();
			
			caret = new FlxSprite();
			caret.makeGraphics(1, 10);
			caretIndex = 0;
			
			hasFocus = false;
			
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		}
		
		/**
		 * Draw the caret in addition to the text.
		 */
		override public function draw():void 
		{
			super.draw();
			if (caret != null && caret.visible) {
				caret.scrollFactor = scrollFactor;
				caret.cameras = cameras;
				caret.draw();
			}
		}
		
		/**
		 * Check for mouse input every tick.
		 */
		override public function update():void 
		{
			super.update();
			// set focus and caretIndex as a response to mouse press
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
			if (hasFocus) {
				if (e.keyCode == 37) // left arrow
				{ 
					if (caretIndex > 0) caretIndex --;
				}				
				else if (e.keyCode == 39) // right arrow
				{ 
					if (caretIndex < text.length) caretIndex ++;
				}				
				else if (e.keyCode == 8) // backspace
				{
					if (caretIndex > 0) {
						text = text.slice(0, caretIndex - 1) + text.slice(caretIndex);
						caretIndex --;
					}
				}
				else if (e.keyCode == 46) // delete
				{
					if (text.length > 0 && caretIndex < text.length) {
						text = text.slice(0, caretIndex) + text.slice(caretIndex+1);
					}
				}
				else if (e.keyCode == 13) // enter
				{
					if (enterCallBack != null) enterCallBack(text);
				}
				else 
				{
					var newText:String = filter(String.fromCharCode(e.charCode));
					if (newText.length > 0) {
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
			
			// draw background
			if (background) 
			{
				var buffer:BitmapData = new BitmapData(width, height, true, backgroundColor); 
				buffer.draw(framePixels);
				framePixels = buffer;		
			}
			
		}
		
		
		/**
		 * Turns the caret on/off for the caret flashing animation.
		 */
		protected function toggleCaret(timer:FlxTimer = null):void
		{
			caretTimer.loops ++; // run the timer forever
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
			if(forceUpperCase)
				text = text.toUpperCase();
				
			if(filterMode != NO_FILTER) {
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
		 * The color of the border around the text box.
		 */
		public function get borderColor():uint
		{ 
			return _textField.borderColor;
		}
		
		/**
		 * @private
		 */
		public function set borderColor(Color:uint):void
		{ 
			_textField.borderColor = Color;
		}
		/**
		 * Whether the textbox has a border.
		 */
		public function get border():Boolean
		{ 
			return _textField.border;
		}
		
		/**
		 * @private
		 */
		public function set border(Enabled:Boolean):void
		{ 
			_textField.border = Enabled; 
		}
		
		/**
		 * Set the maximum length for the field (e.g. "3" 
		 * for Arcade type hi-score initials)
		 * @param	Length		The maximum length. 0 means unlimited.
		 */
		public function setMaxLength(Length:uint):void
		{
			_textField.maxChars = Length;
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
					caretTimer.start(.5, 4, toggleCaret);
					caret.visible = true;
				}
			}
			else 
			{
				// graphics
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
			if (newCaretIndex != caretIndex) {
				caret.visible = true;					
				caretTimer.start(.5, 4, toggleCaret);
			}
			_caretIndex = newCaretIndex;
			if (_caretIndex > text.length + 1) _caretIndex = -1; // if caret is too far to the right something is wrong
			if (_caretIndex != -1) // caret is OK, proceed to position
			{
				var boundaries:Rectangle;
				if (_caretIndex < _textField.length) { // caret is not to the right of text
					boundaries = _textField.getCharBoundaries(_caretIndex);
					if (boundaries != null) {
						caret.x = boundaries.left + x;
						caret.y = boundaries.top + y;
					}
				}
				else { // caret is to the right of text
					boundaries = _textField.getCharBoundaries(_caretIndex - 1);
					if (boundaries != null) {
						caret.x = boundaries.right + x;
						caret.y = boundaries.top + y;
					}
					else if (text.length == 0) { // text box is empty
						caret.x = x + 2; // 2 px gutters
						caret.y = y + 2; 
					}
				}
			}
		}
	}
}