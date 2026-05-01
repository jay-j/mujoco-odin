// Copyright 2021 DeepMind Technologies Limited
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package mujoco

mjMAXUISECT     :: 10      // maximum number of sections
mjMAXUIITEM     :: 200     // maximum number of items per section
mjMAXUITEXT     :: 300     // maximum number of chars in edittext and other
mjMAXUINAME     :: 40      // maximum number of chars in name
mjMAXUIMULTI    :: 35      // maximum number of radio/select items in group
mjMAXUIEDIT     :: 7       // maximum number of elements in edit list
mjMAXUIRECT     :: 25      // maximum number of rectangles
mjSEPCLOSED     :: 1000    // closed state of adjustable separator
mjPRESERVE      :: 2000    // preserve section or separator state

// key codes matching GLFW (user must remap for other frameworks)
mjKEY_ESCAPE     :: 256
mjKEY_ENTER      :: 257
mjKEY_TAB        :: 258
mjKEY_BACKSPACE  :: 259
mjKEY_INSERT     :: 260
mjKEY_DELETE     :: 261
mjKEY_RIGHT      :: 262
mjKEY_LEFT       :: 263
mjKEY_DOWN       :: 264
mjKEY_UP         :: 265
mjKEY_PAGE_UP    :: 266
mjKEY_PAGE_DOWN  :: 267
mjKEY_HOME       :: 268
mjKEY_END        :: 269
mjKEY_F1         :: 290
mjKEY_F2         :: 291
mjKEY_F3         :: 292
mjKEY_F4         :: 293
mjKEY_F5         :: 294
mjKEY_F6         :: 295
mjKEY_F7         :: 296
mjKEY_F8         :: 297
mjKEY_F9         :: 298
mjKEY_F10        :: 299
mjKEY_F11        :: 300
mjKEY_F12        :: 301
mjKEY_NUMPAD_0   :: 320
mjKEY_NUMPAD_9   :: 329

//---------------------------------- primitive types (mjt) -----------------------------------------
tButton :: enum u32 {
	NONE   = 0, // no button
	LEFT   = 1, // left button
	RIGHT  = 2, // right button
	MIDDLE = 3, // middle button
} // mouse button

tEvent :: enum u32 {
	NONE      = 0, // no event
	MOVE      = 1, // mouse move
	PRESS     = 2, // mouse button press
	RELEASE   = 3, // mouse button release
	SCROLL    = 4, // scroll
	KEY       = 5, // key press
	RESIZE    = 6, // resize
	REDRAW    = 7, // redraw
	FILESDROP = 8, // files drop
} // mouse and keyboard event type

tItem :: enum i32 {
	ITEM_END       = -2, // end of definition list (not an item)
	ITEM_SECTION   = -1, // section (not an item)
	ITEM_SEPARATOR = 0,  // separator
	ITEM_STATIC    = 1,  // static text
	ITEM_BUTTON    = 2,  // button

	// the rest have data pointer
	ITEM_CHECKINT  = 3,  // check box, int value
	ITEM_CHECKBYTE = 4,  // check box, mjtByte value
	ITEM_RADIO     = 5,  // radio group
	ITEM_RADIOLINE = 6,  // radio group, single line
	ITEM_SELECT    = 7,  // selection box
	ITEM_SLIDERINT = 8,  // slider, int value
	ITEM_SLIDERNUM = 9,  // slider, mjtNum value
	ITEM_EDITINT   = 10, // editable array, int values
	ITEM_EDITNUM   = 11, // editable array, mjtNum values
	ITEM_EDITFLOAT = 12, // editable array, float values
	ITEM_EDITTXT   = 13, // editable text
	NITEM          = 14, // number of item types
} // UI item type

tSection :: enum u32 {
	CLOSED = 0, // closed state (regular section)
	OPEN   = 1, // open state (regular section)
	FIXED  = 2, // fixed section: always open, no title
} // UI section state

// predicate function: set enable/disable based on item category
fItemEnable :: proc "c" (category: i32, data: rawptr) -> i32

//---------------------------------- mjuiState -----------------------------------------------------
uiState :: struct {
	// constants set by user
	nrect:    i32,       // number of rectangles used
	rect:     [25]rRect, // rectangles (index 0: entire window)
	userdata: rawptr,    // pointer to user data (for callbacks)

	// event type
	type: i32, // (type mjtEvent)

	// mouse buttons
	left:        i32, // is left button down
	right:       i32, // is right button down
	middle:      i32, // is middle button down
	doubleclick: i32, // is last press a double click
	button:      i32, // which button was pressed (mjtButton)
	buttontime:  f64, // time of last button press

	// mouse position
	x:  f64, // x position
	y:  f64, // y position
	dx: f64, // x displacement
	dy: f64, // y displacement
	sx: f64, // x scroll
	sy: f64, // y scroll

	// keyboard
	control: i32, // is control down
	shift:   i32, // is shift down
	alt:     i32, // is alt down
	key:     i32, // which key was pressed
	keytime: f64, // time of last key press

	// rectangle ownership and dragging
	mouserect:  i32, // which rectangle contains mouse
	dragrect:   i32, // which rectangle is dragged with mouse
	dragbutton: i32, // which button started drag (mjtButton)

	// files dropping (only valid when type == mjEVENT_FILESDROP)
	dropcount: i32,      // number of files dropped
	droppaths: ^cstring, // paths to files dropped
} // mouse and keyboard state

//---------------------------------- mjuiThemeSpacing ----------------------------------------------
uiThemeSpacing :: struct {
	total:      i32, // total width
	scroll:     i32, // scrollbar width
	label:      i32, // label width
	section:    i32, // section gap
	cornersect: i32, // corner radius for section
	cornersep:  i32, // corner radius for separator
	itemside:   i32, // item side gap
	itemmid:    i32, // item middle gap
	itemver:    i32, // item vertical gap
	texthor:    i32, // text horizontal gap
	textver:    i32, // text vertical gap
	linescroll: i32, // number of pixels to scroll
	samples:    i32, // number of multisamples
} // UI visualization theme spacing

//---------------------------------- mjuiThemeColor ------------------------------------------------
uiThemeColor :: struct {
	master:            [3]f32, // master background
	thumb:             [3]f32, // scrollbar thumb
	secttitle:         [3]f32, // section title
	secttitle2:        [3]f32, // section title: bottom color
	secttitleuncheck:  [3]f32, // section title with unchecked box
	secttitleuncheck2: [3]f32, // section title with unchecked box: bottom color
	secttitlecheck:    [3]f32, // section title with checked box
	secttitlecheck2:   [3]f32, // section title with checked box: bottom color
	sectfont:          [3]f32, // section font
	sectsymbol:        [3]f32, // section symbol
	sectpane:          [3]f32, // section pane
	separator:         [3]f32, // separator title
	separator2:        [3]f32, // separator title: bottom color
	shortcut:          [3]f32, // shortcut background
	fontactive:        [3]f32, // font active
	fontinactive:      [3]f32, // font inactive
	decorinactive:     [3]f32, // decor inactive
	decorinactive2:    [3]f32, // inactive slider color 2
	button:            [3]f32, // button
	check:             [3]f32, // check
	radio:             [3]f32, // radio
	select:            [3]f32, // select
	select2:           [3]f32, // select pane
	slider:            [3]f32, // slider
	slider2:           [3]f32, // slider color 2
	edit:              [3]f32, // edit
	edit2:             [3]f32, // edit invalid
	cursor:            [3]f32, // edit cursor
} // UI visualization theme color

//---------------------------------- mjuiItem ------------------------------------------------------
uiItemSingle :: struct {
	modifier: i32, // 0: none, 1: control, 2: shift; 4: alt
	shortcut: i32, // shortcut key; 0: undefined
} // check and button-related

uiItemMulti :: struct {
	nelem: i32,        // number of elements in group
	name:  [35][40]i8, // element names
} // static, radio and select-related

uiItemSlider :: struct {
	range:     [2]f64, // slider range
	divisions: f64,    // number of range divisions
} // slider-related

uiItemEdit :: struct {
	nelem: i32,       // number of elements in list
	range: [7][2]f64, // element range (min>=max: ignore)
} // edit-related

uiItem :: struct {
	// common properties
	type:      i32,    // type (mjtItem)
	name:      [40]i8, // name
	state:     i32,    // 0: disable, 1: enable, 2+: use predicate
	pdata:     rawptr, // data pointer (type-specific)
	sectionid: i32,    // id of section containing item
	itemid:    i32,    // id of item within section
	userid:    i32,    // user-supplied id (for event handling)

	// type-specific properties
	using _: struct #raw_union {
		single: uiItemSingle, // check and button
		multi:  uiItemMulti,  // static, radio and select
		slider: uiItemSlider, // slider
		edit:   uiItemEdit,   // edit
	},

	// internal
	rect: rRect, // rectangle occupied by item
	skip: i32,   // item skipped due to closed separator
} // UI item

//---------------------------------- mjuiSection ---------------------------------------------------
uiSection :: struct {
	// properties
	name:     [40]i8,      // name
	state:    i32,         // section state (mjtSection)
	modifier: i32,         // 0: none, 1: control, 2: shift; 4: alt
	shortcut: i32,         // shortcut key; 0: undefined
	checkbox: i32,         // 0: none, 1: unchecked, 2: checked
	nitem:    i32,         // number of items in use
	item:     [200]uiItem, // preallocated array of items

	// internal
	rtitle:    rRect, // rectangle occupied by title
	rcontent:  rRect, // rectangle occupied by content
	lastclick: i32,   // last mouse click over this section
} // UI section

//---------------------------------- mjUI ----------------------------------------------------------
UI :: struct {
	// constants set by user
	spacing:   uiThemeSpacing, // UI theme spacing
	color:     uiThemeColor,   // UI theme color
	predicate: fItemEnable,    // callback to set item state programmatically
	userdata:  rawptr,         // pointer to user data (passed to predicate)
	rectid:    i32,            // index of this ui rectangle in mjuiState
	auxid:     i32,            // aux buffer index of this ui
	radiocol:  i32,            // number of radio columns (0 defaults to 2)

	// UI sizes (framebuffer units)
	width:     i32, // width
	height:    i32, // current height
	maxheight: i32, // height when all sections open
	scroll:    i32, // scroll from top of UI

	// mouse focus and count
	mousesect:      i32, // 0: none, -1: scroll, otherwise 1+section
	mouseitem:      i32, // item within section
	mousehelp:      i32, // help button down: print shortcuts
	mouseclicks:    i32, // number of mouse clicks over UI
	mousesectcheck: i32, // 0: none, otherwise 1+section

	// keyboard focus and edit
	editsect:    i32,     // 0: none, otherwise 1+section
	edititem:    i32,     // item within section
	editcursor:  i32,     // cursor position
	editscroll:  i32,     // horizontal scroll
	edittext:    [300]i8, // current text
	editchanged: ^uiItem, // pointer to changed edit in last mjui_event

	// sections
	nsect: i32,           // number of sections in use
	sect:  [10]uiSection, // preallocated array of sections
} // entire UI

//---------------------------------- mjuiDef -------------------------------------------------------
uiDef :: struct {
	type:     i32,     // type (mjtItem); -1: section
	name:     [40]i8,  // name
	state:    i32,     // state
	pdata:    rawptr,  // pointer to data
	other:    [300]i8, // string with type-specific properties
	otherint: i32,     // int with type-specific properties
} // table passed to mjui_add()

