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

mjNGROUP        :: 6         // number of geom, site, joint, skin groups with visflags
mjMAXLIGHT      :: 100       // maximum number of lights in a scene
mjMAXOVERLAY    :: 500       // maximum number of characters in overlay text
mjMAXLINE       :: 100       // maximum number of lines per plot
mjMAXLINEPNT    :: 1001      // maximum number points per line
mjMAXPLANEGRID  :: 200       // maximum number of grid divisions for plane

//---------------------------------- primitive types (mjt) -----------------------------------------
tCatBit :: enum u32 {
	STATIC  = 1, // model elements in body 0
	DYNAMIC = 2, // model elements in all other bodies
	DECOR   = 4, // decorative geoms
	ALL     = 7, // select all categories
} // bitflags for mjvGeom category

tMouse :: enum u32 {
	NONE       = 0, // no action
	ROTATE_V   = 1, // rotate, vertical plane
	ROTATE_H   = 2, // rotate, horizontal plane
	MOVE_V     = 3, // move, vertical plane
	MOVE_H     = 4, // move, horizontal plane
	ZOOM       = 5, // zoom
	MOVE_V_REL = 6, // move, vertical plane, relative to target
	MOVE_H_REL = 7, // move, horizontal plane, relative to target
} // mouse interaction mode

tPertBit :: enum u32 {
	TRANSLATE = 1, // translation
	ROTATE    = 2, // rotation
} // mouse perturbations

tCamera :: enum u32 {
	FREE     = 0, // free camera
	TRACKING = 1, // tracking camera; uses trackbodyid
	FIXED    = 2, // fixed camera; uses fixedcamid
	USER     = 3, // user is responsible for setting OpenGL camera
} // abstract camera type

tLabel :: enum u32 {
	LABEL_NONE         = 0,  // nothing
	LABEL_BODY         = 1,  // body labels
	LABEL_JOINT        = 2,  // joint labels
	LABEL_GEOM         = 3,  // geom labels
	LABEL_SITE         = 4,  // site labels
	LABEL_CAMERA       = 5,  // camera labels
	LABEL_LIGHT        = 6,  // light labels
	LABEL_TENDON       = 7,  // tendon labels
	LABEL_ACTUATOR     = 8,  // actuator labels
	LABEL_CONSTRAINT   = 9,  // constraint labels
	LABEL_FLEX         = 10, // flex labels
	LABEL_SKIN         = 11, // skin labels
	LABEL_SELECTION    = 12, // selected object
	LABEL_SELPNT       = 13, // coordinates of selection point
	LABEL_CONTACTPOINT = 14, // contact information
	LABEL_CONTACTFORCE = 15, // magnitude of contact force
	LABEL_ISLAND       = 16, // id of island
	NLABEL             = 17, // number of label types
} // object labeling

tFrame :: enum u32 {
	FRAME_NONE    = 0, // no frames
	FRAME_BODY    = 1, // body frames
	FRAME_GEOM    = 2, // geom frames
	FRAME_SITE    = 3, // site frames
	FRAME_CAMERA  = 4, // camera frames
	FRAME_LIGHT   = 5, // light frames
	FRAME_CONTACT = 6, // contact frames
	FRAME_WORLD   = 7, // world frame
	NFRAME        = 8, // number of visualization frames
} // frame visualization

tVisFlag :: enum u32 {
	VIS_CONVEXHULL   = 0,  // mesh convex hull
	VIS_TEXTURE      = 1,  // textures
	VIS_JOINT        = 2,  // joints
	VIS_CAMERA       = 3,  // cameras
	VIS_ACTUATOR     = 4,  // actuators
	VIS_ACTIVATION   = 5,  // activations
	VIS_LIGHT        = 6,  // lights
	VIS_TENDON       = 7,  // tendons
	VIS_RANGEFINDER  = 8,  // rangefinder sensors
	VIS_CONSTRAINT   = 9,  // point constraints
	VIS_INERTIA      = 10, // equivalent inertia boxes
	VIS_SCLINERTIA   = 11, // scale equivalent inertia boxes with mass
	VIS_PERTFORCE    = 12, // perturbation force
	VIS_PERTOBJ      = 13, // perturbation object
	VIS_CONTACTPOINT = 14, // contact points
	VIS_ISLAND       = 15, // constraint islands
	VIS_CONTACTFORCE = 16, // contact force
	VIS_CONTACTSPLIT = 17, // split contact force into normal and tangent
	VIS_TRANSPARENT  = 18, // make dynamic geoms more transparent
	VIS_AUTOCONNECT  = 19, // auto connect joints and body coms
	VIS_COM          = 20, // center of mass
	VIS_SELECT       = 21, // selection point
	VIS_STATIC       = 22, // static bodies
	VIS_SKIN         = 23, // skin
	VIS_FLEXVERT     = 24, // flex vertices
	VIS_FLEXEDGE     = 25, // flex edges
	VIS_FLEXFACE     = 26, // flex element faces
	VIS_FLEXSKIN     = 27, // flex smooth skin (disables the rest)
	VIS_BODYBVH      = 28, // body bounding volume hierarchy
	VIS_MESHBVH      = 29, // mesh bounding volume hierarchy
	VIS_SDFITER      = 30, // iterations of SDF gradient descent
	NVISFLAG         = 31, // number of visualization flags
} // flags enabling model element visualization

tRndFlag :: enum u32 {
	RND_SHADOW     = 0,  // shadows
	RND_WIREFRAME  = 1,  // wireframe
	RND_REFLECTION = 2,  // reflections
	RND_ADDITIVE   = 3,  // additive transparency
	RND_SKYBOX     = 4,  // skybox
	RND_FOG        = 5,  // fog
	RND_HAZE       = 6,  // haze
	RND_DEPTH      = 7,  // depth
	RND_SEGMENT    = 8,  // segmentation with random color
	RND_IDCOLOR    = 9,  // segmentation with segid+1 color
	RND_CULL_FACE  = 10, // cull backward faces
	NRNDFLAG       = 11, // number of rendering flags
} // flags enabling rendering effects

tStereo :: enum u32 {
	NONE         = 0, // no stereo; use left eye only
	QUADBUFFERED = 1, // quad buffered; revert to side-by-side if no hardware support
	SIDEBYSIDE   = 2, // side-by-side
} // type of stereo rendering

//---------------------------------- mjvPerturb ----------------------------------------------------
vPerturb :: struct {
	select:     i32,    // selected body id; non-positive: none
	flexselect: i32,    // selected flex id; negative: none
	skinselect: i32,    // selected skin id; negative: none
	active:     i32,    // perturbation bitmask (mjtPertBit)
	active2:    i32,    // secondary perturbation bitmask (mjtPertBit)
	refpos:     [3]f64, // reference position for selected object
	refquat:    [4]f64, // reference orientation for selected object
	refselpos:  [3]f64, // reference position for selection point
	localpos:   [3]f64, // selection point in object coordinates
	localmass:  f64,    // spatial inertia at selection point
	scale:      f64,    // relative mouse motion-to-space scaling (set by initPerturb)
} // object selection and perturbation

//---------------------------------- mjvCamera -----------------------------------------------------
vCamera :: struct {
	// type and ids
	type:        i32, // camera type (mjtCamera)
	fixedcamid:  i32, // fixed camera id
	trackbodyid: i32, // body id to track

	// abstract camera pose specification
	lookat:    [3]f64, // lookat point
	distance:  f64,    // distance to lookat point or tracked body
	azimuth:   f64,    // camera azimuth (deg)
	elevation: f64,    // camera elevation (deg)

	// orthographic / perspective
	orthographic: i32, // 0: perspective; 1: orthographic
} // abstract camera

//---------------------------------- mjvGLCamera ---------------------------------------------------
vGLCamera :: struct {
	// camera frame
	pos:     [3]f32, // position
	forward: [3]f32, // forward direction
	up:      [3]f32, // up direction

	// camera projection
	frustum_center: f32, // hor. center (left,right set to match aspect)
	frustum_width:  f32, // width (not used for rendering)
	frustum_bottom: f32, // bottom
	frustum_top:    f32, // top
	frustum_near:   f32, // near
	frustum_far:    f32, // far

	// orthographic / perspective
	orthographic: i32, // 0: perspective; 1: orthographic
} // OpenGL camera

//---------------------------------- mjvGeom -------------------------------------------------------
vGeom :: struct {
	// type info
	type:     i32, // geom type (mjtGeom)
	dataid:   i32, // mesh, hfield or plane id; -1: none; mesh: 2*id or 2*id+1 (hull)
	objtype:  i32, // mujoco object type; mjOBJ_UNKNOWN for decor
	objid:    i32, // mujoco object id; -1 for decor
	category: i32, // visual category
	matid:    i32, // material id; -1: no textured material
	texcoord: i32, // mesh or flex geom has texture coordinates
	segid:    i32, // segmentation id; -1: not shown

	// spatial transform
	size: [3]f32, // size parameters
	pos:  [3]f32, // Cartesian position
	mat:  [9]f32, // Cartesian orientation

	// material properties
	rgba:        [4]f32,  // color and transparency
	emission:    f32,     // emission coef
	specular:    f32,     // specular coef
	shininess:   f32,     // shininess coef
	reflectance: f32,     // reflectance coef
	label:       [100]i8, // text label

	// transparency rendering (set internally)
	camdist:     f32, // distance to camera (used by sorter)
	modelrbound: f32, // geom rbound from model, 0 if not model geom
	transparent: b8,  // treat geom as transparent
} // abstract geom

//---------------------------------- mjvLight ------------------------------------------------------
vLight :: struct {
	id:          i32,    // light id, -1 for headlight
	pos:         [3]f32, // position rel. to body frame
	dir:         [3]f32, // direction rel. to body frame
	type:        i32,    // type (mjtLightType)
	texid:       i32,    // texture id for image lights
	attenuation: [3]f32, // OpenGL attenuation (quadratic model)
	cutoff:      f32,    // OpenGL cutoff
	exponent:    f32,    // OpenGL exponent
	ambient:     [3]f32, // ambient rgb (alpha=1)
	diffuse:     [3]f32, // diffuse rgb (alpha=1)
	specular:    [3]f32, // specular rgb (alpha=1)
	headlight:   b8,     // headlight
	castshadow:  b8,     // does light cast shadows
	bulbradius:  f32,    // bulb radius for soft shadows
	intensity:   f32,    // intensity, in candelas
	range:       f32,    // range of effectiveness
} // OpenGL light

//---------------------------------- mjvOption -----------------------------------------------------
vOption :: struct {
	label:         i32,    // what objects to label (mjtLabel)
	frame:         i32,    // which frame to show (mjtFrame)
	geomgroup:     [6]b8,  // geom visualization by group
	sitegroup:     [6]b8,  // site visualization by group
	jointgroup:    [6]b8,  // joint visualization by group
	tendongroup:   [6]b8,  // tendon visualization by group
	actuatorgroup: [6]b8,  // actuator visualization by group
	flexgroup:     [6]b8,  // flex visualization by group
	skingroup:     [6]b8,  // skin visualization by group
	flags:         [31]b8, // visualization flags (indexed by mjtVisFlag)
	bvh_depth:     i32,    // depth of the bounding volume hierarchy to be visualized
	flex_layer:    i32,    // element layer to be visualized for 3D flex
} // abstract visualization options

//---------------------------------- mjvScene ------------------------------------------------------
vScene :: struct {
	// abstract geoms
	maxgeom:   i32,    // size of allocated geom buffer
	ngeom:     i32,    // number of geoms currently in buffer
	geoms:     ^vGeom, // buffer for geoms (ngeom)
	geomorder: ^i32,   // buffer for ordering geoms by distance to camera (ngeom)

	// flex data
	nflex:        i32,  // number of flexes
	flexedgeadr:  ^i32, // address of flex edges (nflex)
	flexedgenum:  ^i32, // number of edges in flex (nflex)
	flexvertadr:  ^i32, // address of flex vertices (nflex)
	flexvertnum:  ^i32, // number of vertices in flex (nflex)
	flexfaceadr:  ^i32, // address of flex faces (nflex)
	flexfacenum:  ^i32, // number of flex faces allocated (nflex)
	flexfaceused: ^i32, // number of flex faces currently in use (nflex)
	flexedge:     ^i32, // flex edge data (2*nflexedge)
	flexvert:     ^f32, // flex vertices (3*nflexvert)
	flexface:     ^f32, // flex faces vertices (9*sum(flexfacenum))
	flexnormal:   ^f32, // flex face normals (9*sum(flexfacenum))
	flextexcoord: ^f32, // flex face texture coordinates (6*sum(flexfacenum))
	flexvertopt:  b8,   // copy of mjVIS_FLEXVERT mjvOption flag
	flexedgeopt:  b8,   // copy of mjVIS_FLEXEDGE mjvOption flag
	flexfaceopt:  b8,   // copy of mjVIS_FLEXFACE mjvOption flag
	flexskinopt:  b8,   // copy of mjVIS_FLEXSKIN mjvOption flag

	// skin data
	nskin:       i32,  // number of skins
	skinfacenum: ^i32, // number of faces in skin (nskin)
	skinvertadr: ^i32, // address of skin vertices (nskin)
	skinvertnum: ^i32, // number of vertices in skin (nskin)
	skinvert:    ^f32, // skin vertex data (3*nskinvert)
	skinnormal:  ^f32, // skin normal data (3*nskinvert)

	// OpenGL lights
	nlight: i32,         // number of lights currently in buffer
	lights: [100]vLight, // buffer for lights (nlight)

	// OpenGL cameras
	camera: [2]vGLCamera, // left and right camera

	// OpenGL model transformation
	enabletransform: b8,     // enable model transformation
	translate:       [3]f32, // model translation
	rotate:          [4]f32, // model quaternion rotation
	scale:           f32,    // model scaling

	// OpenGL rendering effects
	stereo: i32,    // stereoscopic rendering (mjtStereo)
	flags:  [11]b8, // rendering flags (indexed by mjtRndFlag)

	// framing
	framewidth: i32,    // frame pixel width; 0: disable framing
	framergb:   [3]f32, // frame color

	// geom buffer status
	status: i32, // 0: ok, 1: geoms exhausted, warning issued
} // abstract scene passed to OpenGL renderer

//---------------------------------- mjvFigure -----------------------------------------------------
vFigure :: struct {
	// enable flags
	flg_legend:    i32,    // show legend
	flg_ticklabel: [2]i32, // show grid tick labels (x,y)
	flg_extend:    i32,    // automatically extend axis ranges to fit data
	flg_barplot:   i32,    // isolated line segments (i.e. GL_LINES)
	flg_selection: i32,    // vertical selection line
	flg_symmetric: i32,    // symmetric y-axis

	// style settings
	linewidth:  f32,         // line width
	gridwidth:  f32,         // grid line width
	gridsize:   [2]i32,      // number of grid points in (x,y)
	gridrgb:    [3]f32,      // grid line rgb
	figurergba: [4]f32,      // figure color and alpha
	panergba:   [4]f32,      // pane color and alpha
	legendrgba: [4]f32,      // legend color and alpha
	textrgb:    [3]f32,      // text color
	linergb:    [100][3]f32, // line colors
	range:      [2][2]f32,   // axis ranges; (min>=max) automatic
	xformat:    [20]i8,      // x-tick label format for sprintf
	yformat:    [20]i8,      // y-tick label format for sprintf
	minwidth:   [20]i8,      // string used to determine min y-tick width

	// text labels
	title:    [1000]i8,     // figure title; subplots separated with 2+ spaces
	xlabel:   [100]i8,      // x-axis label
	linename: [100][100]i8, // line names for legend

	// dynamic settings
	legendoffset: i32,    // number of lines to offset legend
	subplot:      i32,    // selected subplot (for title rendering)
	highlight:    [2]i32, // if point is in legend rect, highlight line
	highlightid:  i32,    // if id>=0 and no point, highlight id
	selection:    f32,    // selection line x-value

	// line data
	linepnt:  [100]i32,       // number of points in line; (0) disable
	linedata: [100][2002]f32, // line data (x,y)

	// output from renderer
	xaxispixel: [2]i32, // range of x-axis in pixels
	yaxispixel: [2]i32, // range of y-axis in pixels
	xaxisdata:  [2]f32, // range of x-axis in data units
	yaxisdata:  [2]f32, // range of y-axis in data units
} // abstract 2D figure passed to OpenGL renderer

