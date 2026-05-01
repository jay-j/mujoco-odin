// Copyright 2024 DeepMind Technologies Limited
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

// C: opaque types
String      :: struct {}
StringVec   :: struct {}
IntVec      :: struct {}
IntVecVec   :: struct {}
FloatVec    :: struct {}
FloatVecVec :: struct {}
DoubleVec   :: struct {}
ByteVec     :: struct {}

//-------------------------------- enum types (mjt) ------------------------------------------------
tGeomInertia :: enum u32 {
	VOLUME = 0, // mass distributed in the volume
	SHELL  = 1, // mass distributed on the surface
} // type of inertia inference

tMeshInertia :: enum u32 {
	CONVEX = 0, // convex mesh inertia
	EXACT  = 1, // exact mesh inertia
	LEGACY = 2, // legacy mesh inertia
	SHELL  = 3, // shell mesh inertia
} // type of mesh inertia

tMeshBuiltin :: enum u32 {
	NONE        = 0, // no built-in mesh
	SPHERE      = 1, // sphere
	HEMISPHERE  = 2, // hemisphere
	CONE        = 3, // cone
	SUPERSPHERE = 4, // supersphere
	SUPERTORUS  = 5, // supertorus
	WEDGE       = 6, // wedge
	PLATE       = 7, // plate
} // type of built-in procedural mesh

tBuiltin :: enum u32 {
	NONE     = 0, // no built-in texture
	GRADIENT = 1, // gradient: rgb1->rgb2
	CHECKER  = 2, // checker pattern: rgb1, rgb2
	FLAT     = 3, // 2d: rgb1; cube: rgb1-up, rgb2-side, rgb3-down
} // type of built-in procedural texture

tMark :: enum u32 {
	NONE   = 0, // no mark
	EDGE   = 1, // edges
	CROSS  = 2, // cross
	RANDOM = 3, // random dots
} // mark type for procedural textures

tLimited :: enum u32 {
	FALSE = 0, // not limited
	TRUE  = 1, // limited
	AUTO  = 2, // limited inferred from presence of range
} // type of limit specification

tAlignFree :: enum u32 {
	FALSE = 0, // don't align
	TRUE  = 1, // align
	AUTO  = 2, // respect the global compiler flag
} // whether to align free joints with the inertial frame

tInertiaFromGeom :: enum u32 {
	FALSE = 0, // do not use; inertial element required
	TRUE  = 1, // always use; overwrite inertial element
	AUTO  = 2, // use only if inertial element is missing
} // whether to infer body inertias from child geoms

tOrientation :: enum u32 {
	QUAT      = 0, // quaternion
	AXISANGLE = 1, // axis and angle
	XYAXES    = 2, // x and y axes
	ZAXIS     = 3, // z axis (minimal rotation)
	EULER     = 4, // Euler angles
} // type of orientation specifier

//-------------------------------- attribute structs (mjs) -----------------------------------------
sElement :: struct {
	elemtype:  tObj, // element type
	signature: u64,  // compilation signature
} // element type, do not modify

sCompiler :: struct {
	autolimits:        b8,      // infer "limited" attribute based on range
	boundmass:         f64,     // enforce minimum body mass
	boundinertia:      f64,     // enforce minimum body diagonal inertia
	settotalmass:      f64,     // rescale masses and inertias; <=0: ignore
	balanceinertia:    b8,      // automatically impose A + B >= C rule
	fitaabb:           b8,      // meshfit to aabb instead of inertia box
	degree:            b8,      // angles in radians or degrees
	eulerseq:          [3]i8,   // sequence for euler rotations
	discardvisual:     b8,      // discard visual geoms in parser
	usethread:         b8,      // use multiple threads to speed up compiler
	fusestatic:        b8,      // fuse static bodies with parent
	inertiafromgeom:   i32,     // use geom inertias (mjtInertiaFromGeom)
	inertiagrouprange: [2]i32,  // range of geom groups used to compute inertia
	saveinertial:      b8,      // save explicit inertial clause for all bodies to XML
	alignfree:         i32,     // align free joints with inertial frame
	LRopt:             LROpt,   // options for lengthrange computation
	meshdir:           ^String, // mesh and hfield directory
	texturedir:        ^String, // texture directory
} // compiler options

Spec :: struct {
	element:   ^sElement, // element type
	modelname: ^String,   // model name

	// compiler data
	compiler:  sCompiler, // compiler options
	strippath: b8,        // automatically strip paths from mesh files

	// engine data
	option: Option,    // physics options
	visual: Visual,    // visual options
	stat:   Statistic, // statistics override (if defined)

	// sizes
	memory:         i64, // number of bytes in arena+stack memory
	nemax:          i32, // max number of equality constraints
	nuserdata:      i32, // number of mjtNums in userdata
	nuser_body:     i32, // number of mjtNums in body_user
	nuser_jnt:      i32, // number of mjtNums in jnt_user
	nuser_geom:     i32, // number of mjtNums in geom_user
	nuser_site:     i32, // number of mjtNums in site_user
	nuser_cam:      i32, // number of mjtNums in cam_user
	nuser_tendon:   i32, // number of mjtNums in tendon_user
	nuser_actuator: i32, // number of mjtNums in actuator_user
	nuser_sensor:   i32, // number of mjtNums in sensor_user
	nkey:           i32, // number of keyframes
	njmax:          i32, // (deprecated) max number of constraints
	nconmax:        i32, // (deprecated) max number of detected contacts
	nstack:         i64, // (deprecated) number of mjtNums in mjData stack

	// global data
	comment:      ^String, // comment at top of XML
	modelfiledir: ^String, // path to model file

	// other
	hasImplicitPluginElem: b8, // already encountered an implicit plugin sensor/actuator
} // model specification

sOrientation :: struct {
	type:      tOrientation, // active orientation specifier
	axisangle: [4]f64,       // axis and angle
	xyaxes:    [6]f64,       // x and y axes
	zaxis:     [3]f64,       // z axis (minimal rotation)
	euler:     [3]f64,       // Euler angles
} // alternative orientation specifiers

sPlugin :: struct {
	element:     ^sElement, // element type
	name:        ^String,   // instance name
	plugin_name: ^String,   // plugin name
	active:      b8,        // is the plugin active
	info:        ^String,   // message appended to compiler errors
} // plugin specification

sBody :: struct {
	element:    ^sElement, // element type
	childclass: ^String,   // childclass name

	// body frame
	pos:  [3]f64,       // frame position
	quat: [4]f64,       // frame orientation
	alt:  sOrientation, // frame alternative orientation

	// inertial frame
	mass:        f64,          // mass
	ipos:        [3]f64,       // inertial frame position
	iquat:       [4]f64,       // inertial frame orientation
	inertia:     [3]f64,       // diagonal inertia (in i-frame)
	ialt:        sOrientation, // inertial frame alternative orientation
	fullinertia: [6]f64,       // non-axis-aligned inertia matrix

	// other
	mocap:            b8,           // is this a mocap body
	gravcomp:         f64,          // gravity compensation
	sleep:            tSleepPolicy, // sleep policy
	userdata:         ^DoubleVec,   // user data
	explicitinertial: b8,           // whether to save the body with explicit inertial clause
	plugin:           sPlugin,      // passive force plugin
	info:             ^String,      // message appended to compiler errors
} // body specification

sFrame :: struct {
	element:    ^sElement,    // element type
	childclass: ^String,      // childclass name
	pos:        [3]f64,       // position
	quat:       [4]f64,       // orientation
	alt:        sOrientation, // alternative orientation
	info:       ^String,      // message appended to compiler errors
} // frame specification

sJoint :: struct {
	element: ^sElement, // element type
	type:    tJoint,    // joint type

	// kinematics
	pos:   [3]f64, // anchor position
	axis:  [3]f64, // joint axis
	ref:   f64,    // value at reference configuration: qpos0
	align: i32,    // align free joint with body com (mjtAlignFree)

	// stiffness
	stiffness:    [3]f64, // stiffness coefficients
	springref:    f64,    // spring reference value: qpos_spring
	springdamper: [2]f64, // timeconst, dampratio

	// limits
	limited:       i32,    // does joint have limits (mjtLimited)
	range:         [2]f64, // joint limits
	margin:        f64,    // margin value for joint limit detection
	solref_limit:  [2]f64, // solver reference: joint limits
	solimp_limit:  [5]f64, // solver impedance: joint limits
	actfrclimited: i32,    // are actuator forces on joint limited (mjtLimited)
	actfrcrange:   [2]f64, // actuator force limits

	// dof properties
	armature:        f64,    // armature inertia (mass for slider)
	damping:         [3]f64, // damping coefficients
	frictionloss:    f64,    // friction loss
	solref_friction: [2]f64, // solver reference: dof friction
	solimp_friction: [5]f64, // solver impedance: dof friction

	// other
	group:       i32,        // group
	actgravcomp: b8,         // is gravcomp force applied via actuators
	userdata:    ^DoubleVec, // user data
	info:        ^String,    // message appended to compiler errors
} // joint specification

sGeom :: struct {
	element: ^sElement, // element type
	type:    tGeom,     // geom type

	// frame, size
	pos:    [3]f64,       // position
	quat:   [4]f64,       // orientation
	alt:    sOrientation, // alternative orientation
	fromto: [6]f64,       // alternative for capsule, cylinder, box, ellipsoid
	size:   [3]f64,       // type-specific size

	// contact related
	contype:     i32,    // contact type
	conaffinity: i32,    // contact affinity
	condim:      i32,    // contact dimensionality
	priority:    i32,    // contact priority
	friction:    [3]f64, // one-sided friction coefficients: slide, roll, spin
	solmix:      f64,    // solver mixing for contact pairs
	solref:      [2]f64, // solver reference
	solimp:      [5]f64, // solver impedance
	margin:      f64,    // margin for contact detection
	gap:         f64,    // include in solver if dist < margin-gap

	// inertia inference
	mass:        f64,          // used to compute density
	density:     f64,          // used to compute mass and inertia from volume or surface
	typeinertia: tGeomInertia, // selects between surface and volume inertia

	// fluid forces
	fluid_ellipsoid: f64,    // whether ellipsoid-fluid model is active
	fluid_coefs:     [5]f64, // ellipsoid-fluid interaction coefs

	// visual
	material: ^String, // name of material
	rgba:     [4]f32,  // rgba when material is omitted
	group:    i32,     // group

	// other
	hfieldname: ^String,    // heightfield attached to geom
	meshname:   ^String,    // mesh attached to geom
	fitscale:   f64,        // scale mesh uniformly
	userdata:   ^DoubleVec, // user data
	plugin:     sPlugin,    // sdf plugin
	info:       ^String,    // message appended to compiler errors
} // geom specification

sSite :: struct {
	element: ^sElement, // element type

	// frame, size
	pos:    [3]f64,       // position
	quat:   [4]f64,       // orientation
	alt:    sOrientation, // alternative orientation
	fromto: [6]f64,       // alternative for capsule, cylinder, box, ellipsoid
	size:   [3]f64,       // geom size

	// visual
	type:     tGeom,   // geom type
	material: ^String, // name of material
	group:    i32,     // group
	rgba:     [4]f32,  // rgba when material is omitted

	// other
	userdata: ^DoubleVec, // user data
	info:     ^String,    // message appended to compiler errors
} // site specification

sCamera :: struct {
	element: ^sElement, // element type

	// extrinsics
	pos:        [3]f64,       // position
	quat:       [4]f64,       // orientation
	alt:        sOrientation, // alternative orientation
	mode:       tCamLight,    // tracking mode
	targetbody: ^String,      // target body for tracking/targeting

	// intrinsics
	proj:             tProjection, // camera projection type
	resolution:       [2]i32,      // resolution (pixel)
	output:           i32,         // bit flags for output type
	fovy:             f64,         // y-field of view
	ipd:              f64,         // inter-pupillary distance
	intrinsic:        [4]f32,      // camera intrinsics (length)
	sensor_size:      [2]f32,      // sensor size (length)
	focal_length:     [2]f32,      // focal length (length)
	focal_pixel:      [2]f32,      // focal length (pixel)
	principal_length: [2]f32,      // principal point (length)
	principal_pixel:  [2]f32,      // principal point (pixel)

	// other
	userdata: ^DoubleVec, // user data
	info:     ^String,    // message appended to compiler errors
} // camera specification

sLight :: struct {
	element: ^sElement, // element type

	// frame
	pos:        [3]f64,    // position
	dir:        [3]f64,    // direction
	mode:       tCamLight, // tracking mode
	targetbody: ^String,   // target body for targeting

	// intrinsics
	active:      b8,         // is light active
	type:        tLightType, // type of light
	texture:     ^String,    // texture name for image lights
	castshadow:  b8,         // does light cast shadows
	bulbradius:  f32,        // bulb radius, for soft shadows
	intensity:   f32,        // intensity, in candelas
	range:       f32,        // range of effectiveness
	attenuation: [3]f32,     // OpenGL attenuation (quadratic model)
	cutoff:      f32,        // OpenGL cutoff
	exponent:    f32,        // OpenGL exponent
	ambient:     [3]f32,     // ambient color
	diffuse:     [3]f32,     // diffuse color
	specular:    [3]f32,     // specular color

	// other
	info: ^String, // message appended to compiler errorsx
} // light specification

sFlex :: struct {
	element: ^sElement, // element type

	// contact properties
	contype:     i32,    // contact type
	conaffinity: i32,    // contact affinity
	condim:      i32,    // contact dimensionality
	priority:    i32,    // contact priority
	friction:    [3]f64, // one-sided friction coefficients: slide, roll, spin
	solmix:      f64,    // solver mixing for contact pairs
	solref:      [2]f64, // solver reference
	solimp:      [5]f64, // solver impedance
	margin:      f64,    // margin for contact detection
	gap:         f64,    // include in solver if dist<margin-gap

	// other properties
	dim:           i32,     // element dimensionality
	radius:        f64,     // radius around primitive element
	size:          [3]f64,  // vertex bounding box half sizes in qpos0
	internal:      b8,      // enable internal collisions
	flatskin:      b8,      // render flex skin with flat shading
	selfcollide:   i32,     // mode for flex self collision
	passive:       i32,     // mode for passive collisions
	activelayers:  i32,     // number of active element layers in 3D
	group:         i32,     // group for visualization
	edgestiffness: f64,     // edge stiffness
	edgedamping:   f64,     // edge damping
	rgba:          [4]f32,  // rgba when material is omitted
	material:      ^String, // name of material used for rendering
	young:         f64,     // Young's modulus
	poisson:       f64,     // Poisson's ratio
	damping:       f64,     // Rayleigh's damping
	thickness:     f64,     // thickness (2D only)
	elastic2d:     i32,     // 2D passive forces; 0: none, 1: bending, 2: stretching, 3: both
	cellcount:     [3]i32,  // grid cell count for finite cell method
	order:         i32,     // interpolation order (1: trilinear, 2: quadratic)

	// mesh properties
	nodebody:     ^StringVec, // node body names
	vertbody:     ^StringVec, // vertex body names
	node:         ^DoubleVec, // node positions
	vert:         ^DoubleVec, // vertex positions
	elem:         ^IntVec,    // element vertex ids
	texcoord:     ^FloatVec,  // vertex texture coordinates
	elemtexcoord: ^IntVec,    // element texture coordinates

	// other
	info: ^String, // message appended to compiler errors
} // flex specification

sMesh :: struct {
	element:          ^sElement,    // element type
	content_type:     ^String,      // content type of file
	file:             ^String,      // mesh file
	refpos:           [3]f64,       // reference position
	refquat:          [4]f64,       // reference orientation
	scale:            [3]f64,       // rescale mesh
	inertia:          tMeshInertia, // inertia type (convex, legacy, exact, shell)
	smoothnormal:     b8,           // do not exclude large-angle faces from normals
	needsdf:          b8,           // compute sdf from mesh
	maxhullvert:      i32,          // maximum vertex count for the convex hull
	uservert:         ^FloatVec,    // user vertex data
	usernormal:       ^FloatVec,    // user normal data
	usertexcoord:     ^FloatVec,    // user texcoord data
	userface:         ^IntVec,      // user vertex indices
	userfacenormal:   ^IntVec,      // user face normal indices
	userfacetexcoord: ^IntVec,      // user texcoord indices
	plugin:           sPlugin,      // sdf plugin
	material:         ^String,      // name of material
	info:             ^String,      // message appended to compiler errors
} // mesh specification

sHField :: struct {
	element:      ^sElement, // element type
	content_type: ^String,   // content type of file
	file:         ^String,   // file: (nrow, ncol, [elevation data])
	size:         [4]f64,    // hfield size (ignore referencing geom size)
	nrow:         i32,       // number of rows
	ncol:         i32,       // number of columns
	userdata:     ^FloatVec, // user-provided elevation data
	info:         ^String,   // message appended to compiler errors
} // height field specification

sSkin :: struct {
	element:  ^sElement, // element type
	file:     ^String,   // skin file
	material: ^String,   // name of material used for rendering
	rgba:     [4]f32,    // rgba when material is omitted
	inflate:  f32,       // inflate in normal direction
	group:    i32,       // group for visualization

	// mesh
	vert:     ^FloatVec, // vertex positions
	texcoord: ^FloatVec, // texture coordinates
	face:     ^IntVec,   // faces

	// skin
	bodyname:   ^StringVec,   // body names
	bindpos:    ^FloatVec,    // bind pos
	bindquat:   ^FloatVec,    // bind quat
	vertid:     ^IntVecVec,   // vertex ids
	vertweight: ^FloatVecVec, // vertex weights

	// other
	info: ^String, // message appended to compiler errors
} // skin specification

sTexture :: struct {
	element:    ^sElement,   // element type
	type:       tTexture,    // texture type
	colorspace: tColorSpace, // colorspace

	// method 1: builtin
	builtin:  i32,    // builtin type (mjtBuiltin)
	mark:     i32,    // mark type (mjtMark)
	rgb1:     [3]f64, // first color for builtin
	rgb2:     [3]f64, // second color for builtin
	markrgb:  [3]f64, // mark color
	random:   f64,    // probability of random dots
	height:   i32,    // height in pixels (square for cube and skybox)
	width:    i32,    // width in pixels
	nchannel: i32,    // number of channels

	// method 2: single file
	content_type: ^String, // content type of file
	file:         ^String, // png file to load; use for all sides of cube
	gridsize:     [2]i32,  // size of grid for composite file; (1,1)-repeat
	gridlayout:   [12]i8,  // row-major: L,R,F,B,U,D for faces; . for unused

	// method 3: separate files
	cubefiles: ^StringVec, // different file for each side of the cube

	// method 4: from buffer read by user
	data: ^ByteVec, // texture data

	// flip options
	hflip: b8, // horizontal flip
	vflip: b8, // vertical flip

	// other
	info: ^String, // message appended to compiler errors
} // texture specification

sMaterial :: struct {
	element:     ^sElement,  // element type
	textures:    ^StringVec, // names of textures (empty: none)
	texuniform:  b8,         // make texture cube uniform
	texrepeat:   [2]f32,     // texture repetition for 2D mapping
	emission:    f32,        // emission
	specular:    f32,        // specular
	shininess:   f32,        // shininess
	reflectance: f32,        // reflectance
	metallic:    f32,        // metallic
	roughness:   f32,        // roughness
	rgba:        [4]f32,     // rgba
	info:        ^String,    // message appended to compiler errors
} // material specification

sPair :: struct {
	element:   ^sElement, // element type
	geomname1: ^String,   // name of geom 1
	geomname2: ^String,   // name of geom 2

	// optional parameters: computed from geoms if not set by user
	condim:         i32,     // contact dimensionality
	solref:         [2]f64,  // solver reference, normal direction
	solreffriction: [2]f64,  // solver reference, frictional directions
	solimp:         [5]f64,  // solver impedance
	margin:         f64,     // margin for contact detection
	gap:            f64,     // include in solver if dist<margin-gap
	friction:       [5]f64,  // full contact friction
	info:           ^String, // message appended to errors
} // pair specification

sExclude :: struct {
	element:   ^sElement, // element type
	bodyname1: ^String,   // name of geom 1
	bodyname2: ^String,   // name of geom 2
	info:      ^String,   // message appended to errors
} // exclude specification

sEquality :: struct {
	element: ^sElement, // element type
	type:    tEq,       // constraint type
	data:    [11]f64,   // type-dependent data
	active:  b8,        // is equality initially active
	name1:   ^String,   // name of object 1
	name2:   ^String,   // name of object 2
	objtype: tObj,      // type of both objects
	solref:  [2]f64,    // solver reference
	solimp:  [5]f64,    // solver impedance
	info:    ^String,   // message appended to errors
} // equality specification

sTendon :: struct {
	element: ^sElement, // element type

	// stiffness, damping, friction, armature
	stiffness:       [3]f64, // stiffness coefficients
	springlength:    [2]f64, // spring resting length; {-1, -1}: use qpos_spring
	damping:         [3]f64, // damping coefficients
	frictionloss:    f64,    // friction loss
	solref_friction: [2]f64, // solver reference: tendon friction
	solimp_friction: [5]f64, // solver impedance: tendon friction
	armature:        f64,    // inertia associated with tendon velocity

	// length range
	limited:       i32,    // does tendon have limits (mjtLimited)
	actfrclimited: i32,    // does tendon have actuator force limits
	range:         [2]f64, // length limits
	actfrcrange:   [2]f64, // actuator force limits
	margin:        f64,    // margin value for tendon limit detection
	solref_limit:  [2]f64, // solver reference: tendon limits
	solimp_limit:  [5]f64, // solver impedance: tendon limits

	// visual
	material: ^String, // name of material for rendering
	width:    f64,     // width for rendering
	rgba:     [4]f32,  // rgba when material is omitted
	group:    i32,     // group

	// other
	userdata: ^DoubleVec, // user data
	info:     ^String,    // message appended to errors
} // tendon specification

sWrap :: struct {
	element: ^sElement, // element type
	type:    tWrap,     // wrap type
	info:    ^String,   // message appended to errors
} // wrapping object specification

sActuator :: struct {
	element: ^sElement, // element type

	// gain, bias
	gaintype: tGain,   // gain type
	gainprm:  [10]f64, // gain parameters
	biastype: tBias,   // bias type
	biasprm:  [10]f64, // bias parameters

	// activation state
	dyntype:  tDyn,    // dynamics type
	dynprm:   [10]f64, // dynamics parameters
	actdim:   i32,     // number of activation variables
	actearly: b8,      // apply next activations to qfrc

	// transmission
	trntype:      tTrn,    // transmission type
	gear:         [6]f64,  // length and transmitted force scaling
	target:       ^String, // name of transmission target
	refsite:      ^String, // reference site, for site transmission
	slidersite:   ^String, // site defining cylinder, for slider-crank
	cranklength:  f64,     // crank length, for slider-crank
	lengthrange:  [2]f64,  // transmission length range
	inheritrange: f64,     // automatic range setting for position and intvelocity
	damping:      [3]f64,  // damping coefficients
	armature:     f64,     // armature inertia

	// input/output clamping
	ctrllimited:  i32,    // are control limits defined (mjtLimited)
	ctrlrange:    [2]f64, // control range
	forcelimited: i32,    // are force limits defined (mjtLimited)
	forcerange:   [2]f64, // force range
	actlimited:   i32,    // are activation limits defined (mjtLimited)
	actrange:     [2]f64, // activation range

	// other
	group:    i32,        // group
	nsample:  i32,        // number of samples in history buffer
	interp:   i32,        // interpolation order (0=ZOH, 1=linear, 2=cubic)
	delay:    f64,        // delay time in seconds; 0: no delay
	userdata: ^DoubleVec, // user data
	plugin:   sPlugin,    // actuator plugin
	info:     ^String,    // message appended to compiler errors
} // actuator specification

sSensor :: struct {
	element: ^sElement, // element type

	// sensor definition
	type:    tSensor, // type of sensor
	objtype: tObj,    // type of sensorized object
	objname: ^String, // name of sensorized object
	reftype: tObj,    // type of referenced object
	refname: ^String, // name of referenced object
	intprm:  [3]i32,  // integer parameters

	// user-defined sensors
	datatype:  tDataType, // data type for sensor measurement
	needstage: tStage,    // compute stage needed to simulate sensor
	dim:       i32,       // number of scalar outputs

	// output post-processing
	cutoff: f64, // cutoff for real and positive datatypes
	noise:  f64, // noise stdev

	// history buffer
	nsample:  i32,    // number of samples in history buffer
	interp:   i32,    // interpolation order (0=ZOH, 1=linear, 2=cubic)
	delay:    f64,    // delay time in seconds
	interval: [2]f64, // [period, time_prev] in seconds

	// other
	userdata: ^DoubleVec, // user data
	plugin:   sPlugin,    // sensor plugin
	info:     ^String,    // message appended to compiler errors
} // sensor specification

sNumeric :: struct {
	element: ^sElement,  // element type
	data:    ^DoubleVec, // initialization data
	size:    i32,        // array size, can be bigger than data size
	info:    ^String,    // message appended to compiler errors
} // custom numeric field specification

sText :: struct {
	element: ^sElement, // element type
	data:    ^String,   // text string
	info:    ^String,   // message appended to compiler errors
} // custom text specification

sTuple :: struct {
	element: ^sElement,  // element type
	objtype: ^IntVec,    // object types
	objname: ^StringVec, // object names
	objprm:  ^DoubleVec, // object parameters
	info:    ^String,    // message appended to compiler errors
} // tuple specification

sKey :: struct {
	element: ^sElement,  // element type
	time:    f64,        // time
	qpos:    ^DoubleVec, // qpos
	qvel:    ^DoubleVec, // qvel
	act:     ^DoubleVec, // act
	mpos:    ^DoubleVec, // mocap pos
	mquat:   ^DoubleVec, // mocap quat
	ctrl:    ^DoubleVec, // ctrl
	info:    ^String,    // message appended to compiler errors
} // keyframe specification

sDefault :: struct {
	element:  ^sElement,  // element type
	joint:    ^sJoint,    // joint defaults
	geom:     ^sGeom,     // geom defaults
	site:     ^sSite,     // site defaults
	camera:   ^sCamera,   // camera defaults
	light:    ^sLight,    // light defaults
	flex:     ^sFlex,     // flex defaults
	mesh:     ^sMesh,     // mesh defaults
	material: ^sMaterial, // material defaults
	pair:     ^sPair,     // pair defaults
	equality: ^sEquality, // equality defaults
	tendon:   ^sTendon,   // tendon defaults
	actuator: ^sActuator, // actuator defaults
} // default specification

