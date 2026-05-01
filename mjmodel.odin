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

// global constants
mjPI :: 3.14159265358979323846
mjMAXVAL :: 1E+10 // maximum value in qpos, qvel, qacc
mjMINMU :: 1E-5 // minimum friction coefficient
mjMINIMP :: 0.0001 // minimum constraint impedance
mjMAXIMP :: 0.9999 // maximum constraint impedance
mjMAXCONPAIR :: 50 // maximum number of contacts per geom pair
mjMAXTREEDEPTH :: 50 // maximum bounding volume hierarchy depth
mjMAXFLEXNODES :: 27 // maximum number of flex nodes
mjMINAWAKE :: 10 // minimum number of timesteps before sleeping

//---------------------------------- sizes ---------------------------------------------------------
mjNEQDATA :: 11 // number of eq_data fields
mjNDYN :: 10 // number of actuator dynamics parameters
mjNGAIN :: 10 // number of actuator gain parameters
mjNBIAS :: 10 // number of actuator bias parameters
mjNFLUID :: 12 // number of fluid interaction parameters
mjNREF :: 2 // number of solver reference parameters
mjNIMP :: 5 // number of solver impedance parameters
mjNPOLY :: 2 // number of high-order polynomial coefficients
mjNSENS :: 3 // number of sensor parameters
mjNSOLVER :: 200 // size of one mjData.solver array
mjNISLAND :: 20 // number of mjData.solver arrays

//---------------------------------- enum types (mjt) ----------------------------------------------
tDisableBit :: enum u32 {
	DSBL_CONSTRAINT   = 0, // entire constraint solver
	DSBL_EQUALITY     = 1, // equality constraints
	DSBL_FRICTIONLOSS = 2, // joint and tendon frictionloss constraints
	DSBL_LIMIT        = 3, // joint and tendon limit constraints
	DSBL_CONTACT      = 4, // contact constraints
	DSBL_SPRING       = 5, // passive spring forces
	DSBL_DAMPER       = 6, // passive damping forces
	DSBL_GRAVITY      = 7, // gravitational forces
	DSBL_CLAMPCTRL    = 8, // clamp control to specified range
	DSBL_WARMSTART    = 9, // warmstart constraint solver
	DSBL_FILTERPARENT = 10, // remove collisions with parent body
	DSBL_ACTUATION    = 11, // apply actuation forces
	DSBL_REFSAFE      = 12, // integrator safety: make ref[0]>=2*timestep
	DSBL_SENSOR       = 13, // sensors
	DSBL_MIDPHASE     = 14, // mid-phase collision filtering
	DSBL_EULERDAMP    = 15, // implicit integration of joint damping in Euler integrator
	DSBL_AUTORESET    = 16, // automatic reset when numerical issues are detected
	DSBL_NATIVECCD    = 17, // native convex collision detection
	DSBL_ISLAND       = 18, // constraint island discovery
} // disable default feature bitflags

DisableBit :: bit_set[tDisableBit;u32]

tEnableBit :: enum u32 {
	ENBL_OVERRIDE    = 0, // override contact parameters
	ENBL_ENERGY      = 1, // energy computation
	ENBL_FWDINV      = 2, // record solver statistics
	ENBL_INVDISCRETE = 3, // discrete-time inverse dynamics

	// experimental features:
	ENBL_MULTICCD    = 4, // multi-point convex collision detection
	ENBL_SLEEP       = 5, // sleeping
} // enable optional feature bitflags

EnableBit :: bit_set[tEnableBit;u32]

tJoint :: enum u32 {
	FREE  = 0, // global position and orientation (quat)       (7)
	BALL  = 1, // orientation (quat) relative to parent        (4)
	SLIDE = 2, // sliding distance along body-fixed axis       (1)
	HINGE = 3, // rotation angle (rad) around body-fixed axis  (1)
} // type of degree of freedom

tGeom :: enum u32 {
	// regular geom types
	GEOM_PLANE     = 0, // plane
	GEOM_HFIELD    = 1, // height field
	GEOM_SPHERE    = 2, // sphere
	GEOM_CAPSULE   = 3, // capsule
	GEOM_ELLIPSOID = 4, // ellipsoid
	GEOM_CYLINDER  = 5, // cylinder
	GEOM_BOX       = 6, // box
	GEOM_MESH      = 7, // mesh
	GEOM_SDF       = 8, // signed distance field
	NGEOMTYPES     = 9, // number of regular geom types

	// rendering-only geom types: not used in mjModel, not counted in mjNGEOMTYPES
	GEOM_ARROW     = 100, // arrow
	GEOM_ARROW1    = 101, // arrow without wedges
	GEOM_ARROW2    = 102, // arrow in both directions
	GEOM_LINE      = 103, // line
	GEOM_LINEBOX   = 104, // box with line edges
	GEOM_FLEX      = 105, // flex
	GEOM_SKIN      = 106, // skin
	GEOM_LABEL     = 107, // text label
	GEOM_TRIANGLE  = 108, // triangle
	GEOM_NONE      = 1001, // missing geom type
} // type of geometric shape

tProjection :: enum u32 {
	PERSPECTIVE  = 0, // perspective
	ORTHOGRAPHIC = 1, // orthographic
} // type of camera projection

tCamLight :: enum u32 {
	FIXED         = 0, // pos and rot fixed in body
	TRACK         = 1, // pos tracks body, rot fixed in global
	TRACKCOM      = 2, // pos tracks subtree com, rot fixed in body
	TARGETBODY    = 3, // pos fixed in body, rot tracks target body
	TARGETBODYCOM = 4, // pos fixed in body, rot tracks target subtree com
} // tracking mode for camera and light

tLightType :: enum u32 {
	SPOT        = 0, // spot
	DIRECTIONAL = 1, // directional
	POINT       = 2, // point
	IMAGE       = 3, // image-based
} // type of light

tTexture :: enum u32 {
	_2D    = 0, // 2d texture, suitable for planes and hfields
	CUBE   = 1, // cube texture, suitable for all other geom types
	SKYBOX = 2, // cube texture used as skybox
} // type of texture

tTextureRole :: enum u32 {
	TEXROLE_USER      = 0, // unspecified
	TEXROLE_RGB       = 1, // base color (albedo)
	TEXROLE_OCCLUSION = 2, // ambient occlusion
	TEXROLE_ROUGHNESS = 3, // roughness
	TEXROLE_METALLIC  = 4, // metallic
	TEXROLE_NORMAL    = 5, // normal (bump) map
	TEXROLE_OPACITY   = 6, // opacity
	TEXROLE_EMISSIVE  = 7, // light emission
	TEXROLE_RGBA      = 8, // base color, opacity
	TEXROLE_ORM       = 9, // occlusion, roughness, metallic
	NTEXROLE          = 10,
} // role of texture map in rendering

tColorSpace :: enum u32 {
	AUTO   = 0, // attempts to autodetect color space, defaults to linear
	LINEAR = 1, // linear color space
	SRGB   = 2, // standard RGB color space
} // type of color space encoding

tIntegrator :: enum u32 {
	EULER        = 0, // semi-implicit Euler
	RK4          = 1, // 4th-order Runge Kutta
	IMPLICIT     = 2, // implicit in velocity
	IMPLICITFAST = 3, // implicit in velocity, no rne derivative
} // integrator mode

tCone :: enum u32 {
	PYRAMIDAL = 0, // pyramidal
	ELLIPTIC  = 1, // elliptic
} // type of friction cone

tJacobian :: enum u32 {
	DENSE  = 0, // dense
	SPARSE = 1, // sparse
	AUTO   = 2, // dense if nv<60, sparse otherwise
} // type of constraint Jacobian

tSolver :: enum u32 {
	PGS    = 0, // PGS    (dual)
	CG     = 1, // CG     (primal)
	NEWTON = 2, // Newton (primal)
} // constraint solver algorithm

tEq :: enum u32 {
	CONNECT    = 0, // connect two bodies at a point (ball joint)
	WELD       = 1, // fix relative position and orientation of two bodies
	JOINT      = 2, // couple the values of two scalar joints with cubic
	TENDON     = 3, // couple the lengths of two tendons with cubic
	FLEX       = 4, // fix all edge lengths of a flex
	FLEXVERT   = 5, // fix all vertex lengths of a flex
	FLEXSTRAIN = 6, // constrain strain of a trilinear/quadratic flex (B-bar)
	DISTANCE   = 7, // unsupported, will cause an error if used
} // type of equality constraint

tWrap :: enum u32 {
	NONE     = 0, // null object
	JOINT    = 1, // constant moment arm
	PULLEY   = 2, // pulley used to split tendon
	SITE     = 3, // pass through site
	SPHERE   = 4, // wrap around sphere
	CYLINDER = 5, // wrap around (infinite) cylinder
} // type of tendon wrap object

tTrn :: enum u32 {
	JOINT         = 0, // force on joint
	JOINTINPARENT = 1, // force on joint, expressed in parent frame
	SLIDERCRANK   = 2, // force via slider-crank linkage
	TENDON        = 3, // force on tendon
	SITE          = 4, // force on site
	BODY          = 5, // adhesion force on a body's geoms
	UNDEFINED     = 1000, // undefined transmission type
} // type of actuator transmission

tDyn :: enum u32 {
	NONE        = 0, // no internal dynamics; ctrl specifies force
	INTEGRATOR  = 1, // integrator: da/dt = u
	FILTER      = 2, // linear filter: da/dt = (u-a) / tau
	FILTEREXACT = 3, // linear filter: da/dt = (u-a) / tau, with exact integration
	MUSCLE      = 4, // piecewise linear filter with two time constants
	DCMOTOR     = 5, // DC motor electrical dynamics
	USER        = 6, // user-defined dynamics type
} // type of actuator dynamics

tGain :: enum u32 {
	FIXED   = 0, // fixed gain
	AFFINE  = 1, // const + kp*length + kv*velocity
	MUSCLE  = 2, // muscle FLV curve computed by mju_muscleGain()
	DCMOTOR = 3, // DC motor gain: K or K/R
	USER    = 4, // user-defined gain type
} // type of actuator gain

tBias :: enum u32 {
	NONE    = 0, // no bias
	AFFINE  = 1, // const + kp*length + kv*velocity
	MUSCLE  = 2, // muscle passive force computed by mju_muscleBias()
	DCMOTOR = 3, // DC motor bias: back-EMF, cogging, LuGre friction
	USER    = 4, // user-defined bias type
} // type of actuator bias

tObj :: enum u32 {
	OBJ_UNKNOWN  = 0, // unknown object type
	OBJ_BODY     = 1, // body
	OBJ_XBODY    = 2, // body, used to access regular frame instead of i-frame
	OBJ_JOINT    = 3, // joint
	OBJ_DOF      = 4, // dof
	OBJ_GEOM     = 5, // geom
	OBJ_SITE     = 6, // site
	OBJ_CAMERA   = 7, // camera
	OBJ_LIGHT    = 8, // light
	OBJ_FLEX     = 9, // flex
	OBJ_MESH     = 10, // mesh
	OBJ_SKIN     = 11, // skin
	OBJ_HFIELD   = 12, // heightfield
	OBJ_TEXTURE  = 13, // texture
	OBJ_MATERIAL = 14, // material for rendering
	OBJ_PAIR     = 15, // geom pair to include
	OBJ_EXCLUDE  = 16, // body pair to exclude
	OBJ_EQUALITY = 17, // equality constraint
	OBJ_TENDON   = 18, // tendon
	OBJ_ACTUATOR = 19, // actuator
	OBJ_SENSOR   = 20, // sensor
	OBJ_NUMERIC  = 21, // numeric
	OBJ_TEXT     = 22, // text
	OBJ_TUPLE    = 23, // tuple
	OBJ_KEY      = 24, // keyframe
	OBJ_PLUGIN   = 25, // plugin instance
	NOBJECT      = 26, // number of object types

	// meta elements, do not appear in mjModel
	OBJ_FRAME    = 100, // frame
	OBJ_DEFAULT  = 101, // default
	OBJ_MODEL    = 102, // entire model
} // type of MujoCo object

tSensor :: enum u32 {
	// common robotic sensors, attached to a site
	TOUCH          = 0, // scalar contact normal forces summed over sensor zone
	ACCELEROMETER  = 1, // 3D linear acceleration, in local frame
	VELOCIMETER    = 2, // 3D linear velocity, in local frame
	GYRO           = 3, // 3D angular velocity, in local frame
	FORCE          = 4, // 3D force between site's body and its parent body
	TORQUE         = 5, // 3D torque between site's body and its parent body
	MAGNETOMETER   = 6, // 3D magnetometer
	RANGEFINDER    = 7, // scalar distance to nearest geom along z-axis
	CAMPROJECTION  = 8, // pixel coordinates of a site in the camera image

	// sensors related to scalar joints, tendons, actuators
	JOINTPOS       = 9, // scalar joint position (hinge and slide only)
	JOINTVEL       = 10, // scalar joint velocity (hinge and slide only)
	TENDONPOS      = 11, // scalar tendon position
	TENDONVEL      = 12, // scalar tendon velocity
	ACTUATORPOS    = 13, // scalar actuator position
	ACTUATORVEL    = 14, // scalar actuator velocity
	ACTUATORFRC    = 15, // scalar actuator force
	JOINTACTFRC    = 16, // scalar actuator force, measured at the joint
	TENDONACTFRC   = 17, // scalar actuator force, measured at the tendon

	// sensors related to ball joints
	BALLQUAT       = 18, // 4D ball joint quaternion
	BALLANGVEL     = 19, // 3D ball joint angular velocity

	// joint and tendon limit sensors, in constraint space
	JOINTLIMITPOS  = 20, // joint limit distance-margin
	JOINTLIMITVEL  = 21, // joint limit velocity
	JOINTLIMITFRC  = 22, // joint limit force
	TENDONLIMITPOS = 23, // tendon limit distance-margin
	TENDONLIMITVEL = 24, // tendon limit velocity
	TENDONLIMITFRC = 25, // tendon limit force

	// sensors attached to an object with spatial frame: (x)body, geom, site, camera
	FRAMEPOS       = 26, // 3D position
	FRAMEQUAT      = 27, // 4D unit quaternion orientation
	FRAMEXAXIS     = 28, // 3D unit vector: x-axis of object's frame
	FRAMEYAXIS     = 29, // 3D unit vector: y-axis of object's frame
	FRAMEZAXIS     = 30, // 3D unit vector: z-axis of object's frame
	FRAMELINVEL    = 31, // 3D linear velocity
	FRAMEANGVEL    = 32, // 3D angular velocity
	FRAMELINACC    = 33, // 3D linear acceleration
	FRAMEANGACC    = 34, // 3D angular acceleration

	// sensors related to kinematic subtrees; attached to a body (which is the subtree root)
	SUBTREECOM     = 35, // 3D center of mass of subtree
	SUBTREELINVEL  = 36, // 3D linear velocity of subtree
	SUBTREEANGMOM  = 37, // 3D angular momentum of subtree

	// sensors of geometric relationships
	INSIDESITE     = 38, // 1 if object is inside a site, 0 otherwise
	GEOMDIST       = 39, // signed distance between two geoms
	GEOMNORMAL     = 40, // normal direction between two geoms
	GEOMFROMTO     = 41, // segment between two geoms

	// sensors for reporting contacts which occurred during the simulation
	CONTACT        = 42, // contacts which occurred during the simulation

	// global sensors
	E_POTENTIAL    = 43, // potential energy
	E_KINETIC      = 44, // kinetic energy
	CLOCK          = 45, // simulation time

	// sensors related to SDFs
	TACTILE        = 46, // tactile sensor

	// plugin-controlled sensors
	PLUGIN         = 47, // plugin-controlled

	// user-defined sensor
	USER           = 48, // sensor data provided by mjcb_sensor callback
} // type of sensor

tStage :: enum u32 {
	NONE = 0, // no computations
	POS  = 1, // position-dependent computations
	VEL  = 2, // velocity-dependent computations
	ACC  = 3, // acceleration/force-dependent computations
} // computation stage

tDataType :: enum u32 {
	REAL       = 0, // real values, no constraints
	POSITIVE   = 1, // positive values; 0 or negative: inactive
	AXIS       = 2, // 3D unit vector
	QUATERNION = 3, // unit quaternion
} // data type for sensors

tConDataField :: enum u32 {
	CONDATA_FOUND   = 0, // whether a contact was found
	CONDATA_FORCE   = 1, // contact force
	CONDATA_TORQUE  = 2, // contact torque
	CONDATA_DIST    = 3, // contact penetration distance
	CONDATA_POS     = 4, // contact position
	CONDATA_NORMAL  = 5, // contact frame normal
	CONDATA_TANGENT = 6, // contact frame first tangent
	NCONDATA        = 7, // number of contact sensor data fields
} // data fields returned by contact sensors

tRayDataField :: enum u32 {
	RAYDATA_DIST   = 0, // distance from ray origin to nearest surface
	RAYDATA_DIR    = 1, // normalized ray direction
	RAYDATA_ORIGIN = 2, // ray origin
	RAYDATA_POINT  = 3, // point at which ray intersects nearest surface
	RAYDATA_NORMAL = 4, // surface normal at intersection point
	RAYDATA_DEPTH  = 5, // depth along z-axis
	NRAYDATA       = 6, // number of rangefinder sensor data fields
} // data fields returned by rangefinder sensors

tCamOutBit :: enum u32 {
	CAMOUT_RGB    = 1, // RGB image
	CAMOUT_DEPTH  = 2, // depth image (distance from camera plane)
	CAMOUT_DIST   = 4, // distance image (distance from camera origin)
	CAMOUT_NORMAL = 8, // normal image
	CAMOUT_SEG    = 16, // segmentation image
	NCAMOUT       = 5, // number of camera output types
} // camera output type bitflags

tSameFrame :: enum u32 {
	NONE       = 0, // no alignment
	BODY       = 1, // frame is same as body frame
	INERTIA    = 2, // frame is same as inertial frame
	BODYROT    = 3, // frame orientation is same as body orientation
	INERTIAROT = 4, // frame orientation is same as inertia orientation
} // frame alignment of bodies with their children

tSleepPolicy :: enum u32 {
	AUTO         = 0, // compiler chooses sleep policy
	AUTO_NEVER   = 1, // compiler sleep policy: never
	AUTO_ALLOWED = 2, // compiler sleep policy: allowed
	NEVER        = 3, // user sleep policy: never
	ALLOWED      = 4, // user sleep policy: allowed
	INIT         = 5, // user sleep policy: initialized asleep
} // per-tree sleep policy

tLRMode :: enum u32 {
	NONE       = 0, // do not process any actuators
	MUSCLE     = 1, // process muscle actuators
	MUSCLEUSER = 2, // process muscle and user actuators
	ALL        = 3, // process all actuators
} // mode for actuator length range computation

tFlexSelf :: enum u32 {
	NONE   = 0, // no self-collisions
	NARROW = 1, // skip midphase, go directly to narrowphase
	BVH    = 2, // use BVH in midphase (if midphase enabled)
	SAP    = 3, // use SAP in midphase
	AUTO   = 4, // choose between BVH and SAP automatically
} // mode for flex selfcollide

tSDFType :: enum u32 {
	SINGLE       = 0, // single SDF
	INTERSECTION = 1, // max(A, B)
	MIDSURFACE   = 2, // A - B
	COLLISION    = 3, // A + B + abs(max(A, B))
} // signed distance function (SDF) type

//---------------------------------- mjLROpt -------------------------------------------------------
LROpt :: struct {
	// flags
	mode:        i32, // which actuators to process (mjtLRMode)
	useexisting: i32, // use existing length range if available
	uselimit:    i32, // use joint and tendon limits if available

	// algorithm parameters
	accel:       f64, // target acceleration used to compute force
	maxforce:    f64, // maximum force; 0: no limit
	timeconst:   f64, // time constant for velocity reduction; min 0.01
	timestep:    f64, // simulation timestep; 0: use mjOption.timestep
	inttotal:    f64, // total simulation time interval
	interval:    f64, // evaluation time interval (at the end)
	tolrange:    f64, // convergence tolerance (relative to range)
} // options for mj_setLengthRange()

//---------------------------------- mjCache -------------------------------------------------------
Cache :: struct {
	impl_: rawptr, // internal pointer to cache
} // asset cache used by the compiler

//---------------------------------- mjVFS ---------------------------------------------------------
VFS :: struct {
	impl_: rawptr, // internal pointer to VFS memory
} // virtual file system for loading from memory

//---------------------------------- mjOption ------------------------------------------------------
Option :: struct {
	// timing parameters
	timestep:          f64, // timestep

	// solver parameters
	impratio:          f64, // ratio of friction-to-normal contact impedance
	tolerance:         f64, // main solver tolerance
	ls_tolerance:      f64, // CG/Newton linesearch tolerance
	noslip_tolerance:  f64, // noslip solver tolerance
	ccd_tolerance:     f64, // convex collision solver tolerance

	// sleep settings
	sleep_tolerance:   f64, // sleep velocity tolerance

	// physical constants
	gravity:           [3]f64, // gravitational acceleration
	wind:              [3]f64, // wind (for lift, drag and viscosity)
	magnetic:          [3]f64, // global magnetic flux
	density:           f64, // density of medium
	viscosity:         f64, // viscosity of medium

	// override contact solver parameters (if enabled)
	o_margin:          f64, // margin
	o_solref:          [2]f64, // solref
	o_solimp:          [5]f64, // solimp
	o_friction:        [5]f64, // friction

	// discrete settings
	integrator:        i32, // integration mode (mjtIntegrator)
	cone:              i32, // type of friction cone (mjtCone)
	jacobian:          i32, // type of Jacobian (mjtJacobian)
	solver:            i32, // solver algorithm (mjtSolver)
	iterations:        i32, // maximum number of main solver iterations
	ls_iterations:     i32, // maximum number of CG/Newton linesearch iterations
	noslip_iterations: i32, // maximum number of noslip solver iterations
	ccd_iterations:    i32, // maximum number of convex collision solver iterations
	disableflags:      i32, // bit flags for disabling standard features
	enableflags:       i32, // bit flags for enabling optional features
	disableactuator:   i32, // bit flags for disabling actuators by group id

	// sdf collision settings
	sdf_initpoints:    i32, // number of starting points for gradient descent
	sdf_iterations:    i32, // max number of iterations for gradient descent
} // physics options

//---------------------------------- mjVisual ------------------------------------------------------
Visual :: struct {
	global:    struct {
		cameraid:         i32, // initial camera id (-1: free)
		orthographic:     i32, // is the free camera orthographic (0: no, 1: yes)
		fovy:             f32, // y field-of-view of free camera (orthographic ? length : degree)
		ipd:              f32, // inter-pupilary distance for free camera
		azimuth:          f32, // initial azimuth of free camera (degrees)
		elevation:        f32, // initial elevation of free camera (degrees)
		linewidth:        f32, // line width for wireframe and ray rendering
		glow:             f32, // glow coefficient for selected body
		realtime:         f32, // initial real-time factor (1: real time)
		offwidth:         i32, // width of offscreen buffer
		offheight:        i32, // height of offscreen buffer
		ellipsoidinertia: i32, // geom for inertia visualization (0: box, 1: ellipsoid)
		bvactive:         i32, // visualize active bounding volumes (0: no, 1: yes)
	},
	quality:   struct {
		shadowsize: i32, // size of shadowmap texture
		offsamples: i32, // number of multisamples for offscreen rendering
		numslices:  i32, // number of slices for builtin geom drawing
		numstacks:  i32, // number of stacks for builtin geom drawing
		numquads:   i32, // number of quads for box rendering
	},
	headlight: struct {
		ambient:  [3]f32, // ambient rgb (alpha=1)
		diffuse:  [3]f32, // diffuse rgb (alpha=1)
		specular: [3]f32, // specular rgb (alpha=1)
		active:   i32, // is headlight active
	},
	_map:      struct {
		stiffness:      f32, // mouse perturbation stiffness (space->force)
		stiffnessrot:   f32, // mouse perturbation stiffness (space->torque)
		force:          f32, // from force units to space units
		torque:         f32, // from torque units to space units
		alpha:          f32, // scale geom alphas when transparency is enabled
		fogstart:       f32, // OpenGL fog starts at fogstart * mjModel.stat.extent
		fogend:         f32, // OpenGL fog ends at fogend * mjModel.stat.extent
		znear:          f32, // near clipping plane = znear * mjModel.stat.extent
		zfar:           f32, // far clipping plane = zfar * mjModel.stat.extent
		haze:           f32, // haze ratio
		shadowclip:     f32, // directional light: shadowclip * mjModel.stat.extent
		shadowscale:    f32, // spot light: shadowscale * light.cutoff
		actuatortendon: f32, // scale tendon width
	},
	scale:     struct {
		forcewidth:     f32, // width of force arrow
		contactwidth:   f32, // contact width
		contactheight:  f32, // contact height
		connect:        f32, // autoconnect capsule width
		com:            f32, // com radius
		camera:         f32, // camera object
		light:          f32, // light object
		selectpoint:    f32, // selection point
		jointlength:    f32, // joint length
		jointwidth:     f32, // joint width
		actuatorlength: f32, // actuator length
		actuatorwidth:  f32, // actuator width
		framelength:    f32, // bodyframe axis length
		framewidth:     f32, // bodyframe axis width
		constraint:     f32, // constraint width
		slidercrank:    f32, // slidercrank width
		frustum:        f32, // frustum zfar plane
	},
	rgba:      struct {
		fog:              [4]f32, // fog
		haze:             [4]f32, // haze
		force:            [4]f32, // external force
		inertia:          [4]f32, // inertia box
		joint:            [4]f32, // joint
		actuator:         [4]f32, // actuator, neutral
		actuatornegative: [4]f32, // actuator, negative limit
		actuatorpositive: [4]f32, // actuator, positive limit
		com:              [4]f32, // center of mass
		camera:           [4]f32, // camera object
		light:            [4]f32, // light object
		selectpoint:      [4]f32, // selection point
		connect:          [4]f32, // auto connect
		contactpoint:     [4]f32, // contact point
		contactforce:     [4]f32, // contact force
		contactfriction:  [4]f32, // contact friction force
		contacttorque:    [4]f32, // contact torque
		contactgap:       [4]f32, // contact point in gap
		rangefinder:      [4]f32, // rangefinder ray
		constraint:       [4]f32, // constraint
		slidercrank:      [4]f32, // slidercrank
		crankbroken:      [4]f32, // used when crank must be stretched/broken
		frustum:          [4]f32, // camera frustum
		bv:               [4]f32, // bounding volume
		bvactive:         [4]f32, // active bounding volume
	},
} // visualization options

//---------------------------------- mjStatistic ---------------------------------------------------
Statistic :: struct {
	meaninertia: f64, // mean diagonal inertia
	meanmass:    f64, // mean body mass
	meansize:    f64, // mean body size
	extent:      f64, // spatial extent
	center:      [3]f64, // center of model
} // model statistics (in qpos0)

//---------------------------------- mjModel -------------------------------------------------------
Model :: struct {
	// ------------------------------- sizes

	// sizes needed at mjModel construction
	nq:                    i64, // number of generalized coordinates = dim(qpos)
	nv:                    i64, // number of degrees of freedom = dim(qvel)
	nu:                    i64, // number of actuators/controls = dim(ctrl)
	na:                    i64, // number of activation states = dim(act)
	nbody:                 i64, // number of bodies
	nbvh:                  i64, // number of total bounding volumes in all bodies
	nbvhstatic:            i64, // number of static bounding volumes (aabb stored in mjModel)
	nbvhdynamic:           i64, // number of dynamic bounding volumes (aabb stored in mjData)
	noct:                  i64, // number of total octree cells in all meshes
	njnt:                  i64, // number of joints
	ntree:                 i64, // number of kinematic trees under world body
	nM:                    i64, // number of non-zeros in sparse inertia matrix
	nB:                    i64, // number of non-zeros in sparse body-dof matrix
	nC:                    i64, // number of non-zeros in sparse reduced dof-dof matrix
	nD:                    i64, // number of non-zeros in sparse dof-dof matrix
	ngeom:                 i64, // number of geoms
	nsite:                 i64, // number of sites
	ncam:                  i64, // number of cameras
	nlight:                i64, // number of lights
	nflex:                 i64, // number of flexes
	nflexnode:             i64, // number of dofs in all flexes
	nflexvert:             i64, // number of vertices in all flexes
	nflexedge:             i64, // number of edges in all flexes
	nflexelem:             i64, // number of elements in all flexes
	nflexelemdata:         i64, // number of element vertex ids in all flexes
	nflexstiffness:        i64, // number of stiffness parameters in all flexes
	nflexelemedge:         i64, // number of element edge ids in all flexes
	nflexshelldata:        i64, // number of shell fragment vertex ids in all flexes
	nflexevpair:           i64, // number of element-vertex pairs in all flexes
	nflextexcoord:         i64, // number of vertices with texture coordinates
	nJfe:                  i64, // number of non-zeros in sparse flexedge Jacobian matrix
	nJfv:                  i64, // number of non-zeros in sparse flexvert Jacobian matrix
	nmesh:                 i64, // number of meshes
	nmeshvert:             i64, // number of vertices in all meshes
	nmeshnormal:           i64, // number of normals in all meshes
	nmeshtexcoord:         i64, // number of texcoords in all meshes
	nmeshface:             i64, // number of triangular faces in all meshes
	nmeshgraph:            i64, // number of ints in mesh auxiliary data
	nmeshpoly:             i64, // number of polygons in all meshes
	nmeshpolyvert:         i64, // number of vertices in all polygons
	nmeshpolymap:          i64, // number of polygons in vertex map
	nskin:                 i64, // number of skins
	nskinvert:             i64, // number of vertices in all skins
	nskintexvert:          i64, // number of vertices with texcoords in all skins
	nskinface:             i64, // number of triangular faces in all skins
	nskinbone:             i64, // number of bones in all skins
	nskinbonevert:         i64, // number of vertices in all skin bones
	nhfield:               i64, // number of heightfields
	nhfielddata:           i64, // number of data points in all heightfields
	ntex:                  i64, // number of textures
	ntexdata:              i64, // number of bytes in texture rgb data
	nmat:                  i64, // number of materials
	npair:                 i64, // number of predefined geom pairs
	nexclude:              i64, // number of excluded geom pairs
	neq:                   i64, // number of equality constraints
	ntendon:               i64, // number of tendons
	nJten:                 i64, // number of non-zeros in sparse ten_J matrix
	nwrap:                 i64, // number of wrap objects in all tendon paths
	nsensor:               i64, // number of sensors
	nnumeric:              i64, // number of numeric custom fields
	nnumericdata:          i64, // number of mjtNums in all numeric fields
	ntext:                 i64, // number of text custom fields
	ntextdata:             i64, // number of mjtBytes in all text fields
	ntuple:                i64, // number of tuple custom fields
	ntupledata:            i64, // number of objects in all tuple fields
	nkey:                  i64, // number of keyframes
	nmocap:                i64, // number of mocap bodies
	nplugin:               i64, // number of plugin instances
	npluginattr:           i64, // number of chars in all plugin config attributes
	nuser_body:            i64, // number of mjtNums in body_user
	nuser_jnt:             i64, // number of mjtNums in jnt_user
	nuser_geom:            i64, // number of mjtNums in geom_user
	nuser_site:            i64, // number of mjtNums in site_user
	nuser_cam:             i64, // number of mjtNums in cam_user
	nuser_tendon:          i64, // number of mjtNums in tendon_user
	nuser_actuator:        i64, // number of mjtNums in actuator_user
	nuser_sensor:          i64, // number of mjtNums in sensor_user
	nnames:                i64, // number of chars in all names
	npaths:                i64, // number of chars in all paths

	// sizes set after mjModel construction
	nnames_map:            i64, // number of slots in the names hash map
	nJmom:                 i64, // number of non-zeros in sparse actuator_moment matrix
	ngravcomp:             i64, // number of bodies with nonzero gravcomp
	nemax:                 i64, // number of potential equality-constraint rows
	njmax:                 i64, // number of available rows in constraint Jacobian (legacy)
	nconmax:               i64, // number of potential contacts in contact list (legacy)
	nuserdata:             i64, // number of mjtNums reserved for the user
	nsensordata:           i64, // number of mjtNums in sensor data vector
	npluginstate:          i64, // number of mjtNums in plugin state vector
	nhistory:              i64, // number of mjtNums in history buffer

	// buffer sizes
	narena:                i64, // number of bytes in the mjData arena (inclusive of stack)
	nbuffer:               i64, // number of bytes in buffer

	// ------------------------------- options and statistics
	opt:                   Option, // physics options
	vis:                   Visual, // visualization options
	stat:                  Statistic, // model statistics

	// ------------------------------- buffers

	// main buffer
	buffer:                rawptr, // main buffer; all pointers point in it    (nbuffer)

	// default generalized coordinates
	qpos0:                 [^]f64, // qpos values at default pose              (nq x 1)
	qpos_spring:           [^]f64, // reference pose for springs               (nq x 1)

	// bodies
	body_parentid:         [^]i32, // id of body's parent                      (nbody x 1)
	body_rootid:           [^]i32, // ancestor that is direct child of world   (nbody x 1)
	body_weldid:           [^]i32, // top ancestor with no dofs to this body   (nbody x 1)
	body_mocapid:          [^]i32, // id of mocap data; -1: none               (nbody x 1)
	body_jntnum:           [^]i32, // number of joints for this body           (nbody x 1)
	body_jntadr:           [^]i32, // start addr of joints; -1: no joints      (nbody x 1)
	body_dofnum:           [^]i32, // number of motion degrees of freedom      (nbody x 1)
	body_dofadr:           [^]i32, // start addr of dofs; -1: no dofs          (nbody x 1)
	body_treeid:           [^]i32, // id of body's kinematic tree; -1: static  (nbody x 1)
	body_geomnum:          [^]i32, // number of geoms                          (nbody x 1)
	body_geomadr:          [^]i32, // start addr of geoms; -1: no geoms        (nbody x 1)
	body_simple:           [^]b8, // 1: diag M; 2: diag M, sliders only       (nbody x 1)
	body_sameframe:        [^]b8, // same frame as inertia (mjtSameframe)     (nbody x 1)
	body_pos:              [^]f64, // position offset rel. to parent body      (nbody x 3)
	body_quat:             [^]f64, // orientation offset rel. to parent body   (nbody x 4)
	body_ipos:             [^]f64, // local position of center of mass         (nbody x 3)
	body_iquat:            [^]f64, // local orientation of inertia ellipsoid   (nbody x 4)
	body_mass:             [^]f64, // mass                                     (nbody x 1)
	body_subtreemass:      [^]f64, // mass of subtree starting at this body    (nbody x 1)
	body_inertia:          [^]f64, // diagonal inertia in ipos/iquat frame     (nbody x 3)
	body_invweight0:       [^]f64, // mean inv inert in qpos0 (trn, rot)       (nbody x 2)
	body_gravcomp:         [^]f64, // antigravity force, units of body weight  (nbody x 1)
	body_margin:           [^]f64, // MAX over all geom margins                (nbody x 1)
	body_user:             [^]f64, // user data                                (nbody x nuser_body)
	body_plugin:           [^]i32, // plugin instance id; -1: not in use       (nbody x 1)
	body_contype:          [^]i32, // OR over all geom contypes                (nbody x 1)
	body_conaffinity:      [^]i32, // OR over all geom conaffinities           (nbody x 1)
	body_bvhadr:           [^]i32, // address of bvh root                      (nbody x 1)
	body_bvhnum:           [^]i32, // number of bounding volumes               (nbody x 1)

	// bounding volume hierarchy
	bvh_depth:             [^]i32, // depth in the bounding volume hierarchy   (nbvh x 1)
	bvh_child:             [^]i32, // left and right children in tree          (nbvh x 2)
	bvh_nodeid:            [^]i32, // geom or elem id of node; -1: non-leaf    (nbvh x 1)
	bvh_aabb:              [^]f64, // local bounding box (center, size)        (nbvhstatic x 6)

	// octree spatial partitioning
	oct_depth:             [^]i32, // depth in the octree                      (noct x 1)
	oct_child:             [^]i32, // children of octree node                  (noct x 8)
	oct_aabb:              [^]f64, // octree node bounding box (center, size)  (noct x 6)
	oct_coeff:             [^]f64, // octree interpolation coefficients        (noct x 8)

	// joints
	jnt_type:              [^]i32, // type of joint (mjtJoint)                 (njnt x 1)
	jnt_qposadr:           [^]i32, // start addr in 'qpos' for joint's data    (njnt x 1)
	jnt_dofadr:            [^]i32, // start addr in 'qvel' for joint's data    (njnt x 1)
	jnt_bodyid:            [^]i32, // id of joint's body                       (njnt x 1)
	jnt_actuatorid:        [^]i32, // actuator contributing damping / armature (njnt x 1)
	jnt_group:             [^]i32, // group for visibility                     (njnt x 1)
	jnt_limited:           [^]b8, // does joint have limits                   (njnt x 1)
	jnt_actfrclimited:     [^]b8, // does joint have actuator force limits    (njnt x 1)
	jnt_actgravcomp:       [^]b8, // is gravcomp force applied via actuators  (njnt x 1)
	jnt_solref:            [^]f64, // constraint solver reference: limit       (njnt x mjNREF)
	jnt_solimp:            [^]f64, // constraint solver impedance: limit       (njnt x mjNIMP)
	jnt_pos:               [^]f64, // local anchor position                    (njnt x 3)
	jnt_axis:              [^]f64, // local joint axis                         (njnt x 3)
	jnt_stiffness:         [^]f64, // linear stiffness coefficient             (njnt x 1)
	jnt_stiffnesspoly:     [^]f64, // high-order stiffness coefficients        (njnt x mjNPOLY)
	jnt_range:             [^]f64, // joint limits                             (njnt x 2)
	jnt_actfrcrange:       [^]f64, // range of total actuator force            (njnt x 2)
	jnt_margin:            [^]f64, // min distance for limit detection         (njnt x 1)
	jnt_user:              [^]f64, // user data                                (njnt x nuser_jnt)

	// dofs
	dof_bodyid:            [^]i32, // id of dof's body                         (nv x 1)
	dof_jntid:             [^]i32, // id of dof's joint                        (nv x 1)
	dof_parentid:          [^]i32, // id of dof's parent; -1: none             (nv x 1)
	dof_treeid:            [^]i32, // id of dof's kinematic tree               (nv x 1)
	dof_Madr:              [^]i32, // dof address in M-diagonal                (nv x 1)
	dof_simplenum:         [^]i32, // number of consecutive simple dofs        (nv x 1)
	dof_solref:            [^]f64, // constraint solver reference:frictionloss (nv x mjNREF)
	dof_solimp:            [^]f64, // constraint solver impedance:frictionloss (nv x mjNIMP)
	dof_frictionloss:      [^]f64, // dof friction loss                        (nv x 1)
	dof_armature:          [^]f64, // dof armature inertia/mass                (nv x 1)
	dof_damping:           [^]f64, // linear damping coefficient               (nv x 1)
	dof_dampingpoly:       [^]f64, // high-order damping coefficients          (nv x mjNPOLY)
	dof_invweight0:        [^]f64, // diag. inverse inertia in qpos0           (nv x 1)
	dof_M0:                [^]f64, // diag. inertia in qpos0                   (nv x 1)
	dof_length:            [^]f64, // linear: 1; angular: approx. length scale (nv x 1)

	// trees
	tree_bodyadr:          [^]i32, // start addr of bodies                     (ntree x 1)
	tree_bodynum:          [^]i32, // number of bodies in tree                 (ntree x 1)
	tree_dofadr:           [^]i32, // start addr of dofs                       (ntree x 1)
	tree_dofnum:           [^]i32, // number of dofs in tree                   (ntree x 1)
	tree_sleep_policy:     [^]i32, // sleep policy (mjtSleepPolicy)            (ntree x 1)

	// geoms
	geom_type:             [^]i32, // geometric type (mjtGeom)                 (ngeom x 1)
	geom_contype:          [^]i32, // geom contact type                        (ngeom x 1)
	geom_conaffinity:      [^]i32, // geom contact affinity                    (ngeom x 1)
	geom_condim:           [^]i32, // contact dimensionality (1, 3, 4, 6)      (ngeom x 1)
	geom_bodyid:           [^]i32, // id of geom's body                        (ngeom x 1)
	geom_dataid:           [^]i32, // id of geom's mesh/hfield; -1: none       (ngeom x 1)
	geom_matid:            [^]i32, // material id for rendering; -1: none      (ngeom x 1)
	geom_group:            [^]i32, // group for visibility                     (ngeom x 1)
	geom_priority:         [^]i32, // geom contact priority                    (ngeom x 1)
	geom_plugin:           [^]i32, // plugin instance id; -1: not in use       (ngeom x 1)
	geom_sameframe:        [^]b8, // same frame as body (mjtSameframe)        (ngeom x 1)
	geom_solmix:           [^]f64, // mixing coef for solref/imp in geom pair  (ngeom x 1)
	geom_solref:           [^]f64, // constraint solver reference: contact     (ngeom x mjNREF)
	geom_solimp:           [^]f64, // constraint solver impedance: contact     (ngeom x mjNIMP)
	geom_size:             [^]f64, // geom-specific size parameters            (ngeom x 3)
	geom_aabb:             [^]f64, // bounding box, (center, size)             (ngeom x 6)
	geom_rbound:           [^]f64, // radius of bounding sphere                (ngeom x 1)
	geom_pos:              [^]f64, // local position offset rel. to body       (ngeom x 3)
	geom_quat:             [^]f64, // local orientation offset rel. to body    (ngeom x 4)
	geom_friction:         [^]f64, // friction for (slide, spin, roll)         (ngeom x 3)
	geom_margin:           [^]f64, // detect contact if dist<margin            (ngeom x 1)
	geom_gap:              [^]f64, // include in solver if dist<margin-gap     (ngeom x 1)
	geom_fluid:            [^]f64, // fluid interaction parameters             (ngeom x mjNFLUID)
	geom_user:             [^]f64, // user data                                (ngeom x nuser_geom)
	geom_rgba:             [^]f32, // rgba when material is omitted            (ngeom x 4)

	// sites
	site_type:             [^]i32, // geom type for rendering (mjtGeom)        (nsite x 1)
	site_bodyid:           [^]i32, // id of site's body                        (nsite x 1)
	site_matid:            [^]i32, // material id for rendering; -1: none      (nsite x 1)
	site_group:            [^]i32, // group for visibility                     (nsite x 1)
	site_sameframe:        [^]b8, // same frame as body (mjtSameframe)        (nsite x 1)
	site_size:             [^]f64, // geom size for rendering                  (nsite x 3)
	site_pos:              [^]f64, // local position offset rel. to body       (nsite x 3)
	site_quat:             [^]f64, // local orientation offset rel. to body    (nsite x 4)
	site_user:             [^]f64, // user data                                (nsite x nuser_site)
	site_rgba:             [^]f32, // rgba when material is omitted            (nsite x 4)

	// cameras
	cam_mode:              [^]i32, // camera tracking mode (mjtCamLight)       (ncam x 1)
	cam_bodyid:            [^]i32, // id of camera's body                      (ncam x 1)
	cam_targetbodyid:      [^]i32, // id of targeted body; -1: none            (ncam x 1)
	cam_pos:               [^]f64, // position rel. to body frame              (ncam x 3)
	cam_quat:              [^]f64, // orientation rel. to body frame           (ncam x 4)
	cam_poscom0:           [^]f64, // global position rel. to sub-com in qpos0 (ncam x 3)
	cam_pos0:              [^]f64, // global position rel. to body in qpos0    (ncam x 3)
	cam_mat0:              [^]f64, // global orientation in qpos0              (ncam x 9)
	cam_projection:        [^]i32, // projection type (mjtProjection)          (ncam x 1)
	cam_fovy:              [^]f64, // y field-of-view (ortho ? len : deg)      (ncam x 1)
	cam_ipd:               [^]f64, // inter-pupilary distance                  (ncam x 1)
	cam_resolution:        [^]i32, // resolution: pixels [width, height]       (ncam x 2)
	cam_output:            [^]i32, // output types (mjtCamOut bit flags)       (ncam x 1)
	cam_sensorsize:        [^]f32, // sensor size: length [width, height]      (ncam x 2)
	cam_intrinsic:         [^]f32, // [focal length; principal point]          (ncam x 4)
	cam_user:              [^]f64, // user data                                (ncam x nuser_cam)

	// lights
	light_mode:            [^]i32, // light tracking mode (mjtCamLight)        (nlight x 1)
	light_bodyid:          [^]i32, // id of light's body                       (nlight x 1)
	light_targetbodyid:    [^]i32, // id of targeted body; -1: none            (nlight x 1)
	light_type:            [^]i32, // spot, directional, etc. (mjtLightType)   (nlight x 1)
	light_texid:           [^]i32, // texture id for image lights              (nlight x 1)
	light_castshadow:      [^]b8, // does light cast shadows                  (nlight x 1)
	light_bulbradius:      [^]f32, // light radius for soft shadows            (nlight x 1)
	light_intensity:       [^]f32, // intensity, in candela                    (nlight x 1)
	light_range:           [^]f32, // range of effectiveness                   (nlight x 1)
	light_active:          [^]b8, // is light on                              (nlight x 1)
	light_pos:             [^]f64, // position rel. to body frame              (nlight x 3)
	light_dir:             [^]f64, // direction rel. to body frame             (nlight x 3)
	light_poscom0:         [^]f64, // global position rel. to sub-com in qpos0 (nlight x 3)
	light_pos0:            [^]f64, // global position rel. to body in qpos0    (nlight x 3)
	light_dir0:            [^]f64, // global direction in qpos0                (nlight x 3)
	light_attenuation:     [^]f32, // OpenGL attenuation (quadratic model)     (nlight x 3)
	light_cutoff:          [^]f32, // OpenGL cutoff                            (nlight x 1)
	light_exponent:        [^]f32, // OpenGL exponent                          (nlight x 1)
	light_ambient:         [^]f32, // ambient rgb (alpha=1)                    (nlight x 3)
	light_diffuse:         [^]f32, // diffuse rgb (alpha=1)                    (nlight x 3)
	light_specular:        [^]f32, // specular rgb (alpha=1)                   (nlight x 3)

	// flexes: contact properties
	flex_contype:          [^]i32, // flex contact type                        (nflex x 1)
	flex_conaffinity:      [^]i32, // flex contact affinity                    (nflex x 1)
	flex_condim:           [^]i32, // contact dimensionality (1, 3, 4, 6)      (nflex x 1)
	flex_priority:         [^]i32, // flex contact priority                    (nflex x 1)
	flex_solmix:           [^]f64, // mix coef for solref/imp in contact pair  (nflex x 1)
	flex_solref:           [^]f64, // constraint solver reference: contact     (nflex x mjNREF)
	flex_solimp:           [^]f64, // constraint solver impedance: contact     (nflex x mjNIMP)
	flex_friction:         [^]f64, // friction for (slide, spin, roll)         (nflex x 3)
	flex_margin:           [^]f64, // detect contact if dist<margin            (nflex x 1)
	flex_gap:              [^]f64, // include in solver if dist<margin-gap     (nflex x 1)
	flex_internal:         [^]b8, // internal flex collision enabled          (nflex x 1)
	flex_selfcollide:      [^]i32, // self collision mode (mjtFlexSelf)        (nflex x 1)
	flex_activelayers:     [^]i32, // number of active element layers, 3D only (nflex x 1)
	flex_passive:          [^]i32, // passive collisions enabled               (nflex x 1)

	// flexes: other properties
	flex_dim:              [^]i32, // 1: lines, 2: triangles, 3: tetrahedra    (nflex x 1)
	flex_matid:            [^]i32, // material id for rendering                (nflex x 1)
	flex_group:            [^]i32, // group for visibility                     (nflex x 1)
	flex_interp:           [^]i32, // interpolation (0: vertex, 1: nodes)      (nflex x 1)
	flex_bandwidth:        [^]i32, // precomputed solver bandwidth             (nflex x 1)
	flex_cellnum:          [^]i32, // finite cell num per dimension            (nflex x 3)
	flex_nodeadr:          [^]i32, // first node address                       (nflex x 1)
	flex_nodenum:          [^]i32, // number of nodes                          (nflex x 1)
	flex_vertadr:          [^]i32, // first vertex address                     (nflex x 1)
	flex_vertnum:          [^]i32, // number of vertices                       (nflex x 1)
	flex_edgeadr:          [^]i32, // first edge address                       (nflex x 1)
	flex_edgenum:          [^]i32, // number of edges                          (nflex x 1)
	flex_elemadr:          [^]i32, // first element address                    (nflex x 1)
	flex_elemnum:          [^]i32, // number of elements                       (nflex x 1)
	flex_elemdataadr:      [^]i32, // first element vertex id address          (nflex x 1)
	flex_stiffnessadr:     [^]i32, // stiffness matrix address                 (nflex x 1)
	flex_elemedgeadr:      [^]i32, // first element edge id address            (nflex x 1)
	flex_shellnum:         [^]i32, // number of shells                         (nflex x 1)
	flex_shelldataadr:     [^]i32, // first shell data address                 (nflex x 1)
	flex_evpairadr:        [^]i32, // first evpair address                     (nflex x 1)
	flex_evpairnum:        [^]i32, // number of evpairs                        (nflex x 1)
	flex_texcoordadr:      [^]i32, // address in flex_texcoord; -1: none       (nflex x 1)
	flex_nodebodyid:       [^]i32, // node body ids                            (nflexnode x 1)
	flex_vertbodyid:       [^]i32, // vertex body ids                          (nflexvert x 1)
	flex_vertedgeadr:      [^]i32, // first edge address                       (nflexvert x 1)
	flex_vertedgenum:      [^]i32, // number of edges                          (nflexvert x 1)
	flex_vertedge:         [^]i32, // edge indices                             (nflexedge x 2)
	flex_edge:             [^]i32, // edge vertex ids (2 per edge)             (nflexedge x 2)
	flex_edgeflap:         [^]i32, // adjacent vertex ids (dim=2 only)         (nflexedge x 2)
	flex_elem:             [^]i32, // element vertex ids (dim+1 per elem)      (nflexelemdata x 1)
	flex_elemtexcoord:     [^]i32, // element texture coordinates (dim+1)      (nflexelemdata x 1)
	flex_elemedge:         [^]i32, // element edge ids                         (nflexelemedge x 1)
	flex_elemlayer:        [^]i32, // element distance from surface, 3D only   (nflexelem x 1)
	flex_shell:            [^]i32, // shell fragment vertex ids (dim per frag) (nflexshelldata x 1)
	flex_evpair:           [^]i32, // (element, vertex) collision pairs        (nflexevpair x 2)
	flex_vert:             [^]f64, // vertex positions in local body frames    (nflexvert x 3)
	flex_vert0:            [^]f64, // vertex positions in qpos0 on [0, 1]^d    (nflexvert x 3)
	flex_vertmetric:       [^]f64, // inverse of reference shape matrix        (nflexvert x 4)
	flex_node:             [^]f64, // node positions in local body frames      (nflexnode x 3)
	flex_node0:            [^]f64, // Cartesian node positions in qpos0        (nflexnode x 3)
	flexedge_length0:      [^]f64, // edge lengths in qpos0                    (nflexedge x 1)
	flexedge_invweight0:   [^]f64, // edge inv. weight in qpos0                (nflexedge x 1)
	flex_radius:           [^]f64, // radius around primitive element          (nflex x 1)
	flex_size:             [^]f64, // vertex bounding box half sizes in qpos0  (nflex x 3)
	flex_stiffness:        [^]f64, // finite element stiffness matrix          (nflexstiffness x 1)
	flex_bending:          [^]f64, // bending stiffness                        (nflexedge x 17)
	flex_damping:          [^]f64, // Rayleigh's damping coefficient           (nflex x 1)
	flex_edgestiffness:    [^]f64, // edge stiffness                           (nflex x 1)
	flex_edgedamping:      [^]f64, // edge damping                             (nflex x 1)
	flex_edgeequality:     [^]i32, // 0:none, 1:edges, 2:vertices, 3:strain    (nflex x 1)
	flex_rigid:            [^]b8, // are all vertices in the same body        (nflex x 1)
	flexedge_rigid:        [^]b8, // are both edge vertices in same body      (nflexedge x 1)
	flex_centered:         [^]b8, // are all vertex coordinates (0,0,0)       (nflex x 1)
	flex_flatskin:         [^]b8, // render flex skin with flat shading       (nflex x 1)
	flex_bvhadr:           [^]i32, // address of bvh root; -1: no bvh          (nflex x 1)
	flex_bvhnum:           [^]i32, // number of bounding volumes               (nflex x 1)
	flexedge_J_rownnz:     [^]i32, // number of non-zeros in Jacobian row      (nflexedge x 1)
	flexedge_J_rowadr:     [^]i32, // row start address in colind array        (nflexedge x 1)
	flexedge_J_colind:     [^]i32, // column indices in sparse Jacobian        (nJfe x 1)
	flexvert_J_rownnz:     [^]i32, // number of non-zeros in Jacobian row      (nflexvert x 2)
	flexvert_J_rowadr:     [^]i32, // row start address in colind array        (nflexvert x 2)
	flexvert_J_colind:     [^]i32, // column indices in sparse Jacobian        (nJfv x 2)
	flex_rgba:             [^]f32, // rgba when material is omitted            (nflex x 4)
	flex_texcoord:         [^]f32, // vertex texture coordinates               (nflextexcoord x 2)

	// meshes
	mesh_vertadr:          [^]i32, // first vertex address                     (nmesh x 1)
	mesh_vertnum:          [^]i32, // number of vertices                       (nmesh x 1)
	mesh_faceadr:          [^]i32, // first face address                       (nmesh x 1)
	mesh_facenum:          [^]i32, // number of faces                          (nmesh x 1)
	mesh_bvhadr:           [^]i32, // address of bvh root                      (nmesh x 1)
	mesh_bvhnum:           [^]i32, // number of bvh                            (nmesh x 1)
	mesh_octadr:           [^]i32, // address of octree root                   (nmesh x 1)
	mesh_octnum:           [^]i32, // number of octree nodes                   (nmesh x 1)
	mesh_normaladr:        [^]i32, // first normal address                     (nmesh x 1)
	mesh_normalnum:        [^]i32, // number of normals                        (nmesh x 1)
	mesh_texcoordadr:      [^]i32, // texcoord data address; -1: no texcoord   (nmesh x 1)
	mesh_texcoordnum:      [^]i32, // number of texcoord                       (nmesh x 1)
	mesh_graphadr:         [^]i32, // graph data address; -1: no graph         (nmesh x 1)
	mesh_vert:             [^]f32, // vertex positions for all meshes          (nmeshvert x 3)
	mesh_normal:           [^]f32, // normals for all meshes                   (nmeshnormal x 3)
	mesh_texcoord:         [^]f32, // vertex texcoords for all meshes          (nmeshtexcoord x 2)
	mesh_face:             [^]i32, // vertex face data                         (nmeshface x 3)
	mesh_facenormal:       [^]i32, // normal face data                         (nmeshface x 3)
	mesh_facetexcoord:     [^]i32, // texture face data                        (nmeshface x 3)
	mesh_graph:            [^]i32, // convex graph data                        (nmeshgraph x 1)
	mesh_scale:            [^]f64, // scaling applied to asset vertices        (nmesh x 3)
	mesh_pos:              [^]f64, // translation applied to asset vertices    (nmesh x 3)
	mesh_quat:             [^]f64, // rotation applied to asset vertices       (nmesh x 4)
	mesh_pathadr:          [^]i32, // address of asset path for mesh; -1: none (nmesh x 1)
	mesh_polynum:          [^]i32, // number of polygons per mesh              (nmesh x 1)
	mesh_polyadr:          [^]i32, // first polygon address per mesh           (nmesh x 1)
	mesh_polynormal:       [^]f64, // all polygon normals                      (nmeshpoly x 3)
	mesh_polyvertadr:      [^]i32, // polygon vertex start address             (nmeshpoly x 1)
	mesh_polyvertnum:      [^]i32, // number of vertices per polygon           (nmeshpoly x 1)
	mesh_polyvert:         [^]i32, // all polygon vertices                     (nmeshpolyvert x 1)
	mesh_polymapadr:       [^]i32, // first polygon address per vertex         (nmeshvert x 1)
	mesh_polymapnum:       [^]i32, // number of polygons per vertex            (nmeshvert x 1)
	mesh_polymap:          [^]i32, // vertex to polygon map                    (nmeshpolymap x 1)

	// skins
	skin_matid:            [^]i32, // skin material id; -1: none               (nskin x 1)
	skin_group:            [^]i32, // group for visibility                     (nskin x 1)
	skin_rgba:             [^]f32, // skin rgba                                (nskin x 4)
	skin_inflate:          [^]f32, // inflate skin in normal direction         (nskin x 1)
	skin_vertadr:          [^]i32, // first vertex address                     (nskin x 1)
	skin_vertnum:          [^]i32, // number of vertices                       (nskin x 1)
	skin_texcoordadr:      [^]i32, // texcoord data address; -1: no texcoord   (nskin x 1)
	skin_faceadr:          [^]i32, // first face address                       (nskin x 1)
	skin_facenum:          [^]i32, // number of faces                          (nskin x 1)
	skin_boneadr:          [^]i32, // first bone in skin                       (nskin x 1)
	skin_bonenum:          [^]i32, // number of bones in skin                  (nskin x 1)
	skin_vert:             [^]f32, // vertex positions for all skin meshes     (nskinvert x 3)
	skin_texcoord:         [^]f32, // vertex texcoords for all skin meshes     (nskintexvert x 2)
	skin_face:             [^]i32, // triangle faces for all skin meshes       (nskinface x 3)
	skin_bonevertadr:      [^]i32, // first vertex in each bone                (nskinbone x 1)
	skin_bonevertnum:      [^]i32, // number of vertices in each bone          (nskinbone x 1)
	skin_bonebindpos:      [^]f32, // bind pos of each bone                    (nskinbone x 3)
	skin_bonebindquat:     [^]f32, // bind quat of each bone                   (nskinbone x 4)
	skin_bonebodyid:       [^]i32, // body id of each bone                     (nskinbone x 1)
	skin_bonevertid:       [^]i32, // mesh ids of vertices in each bone        (nskinbonevert x 1)
	skin_bonevertweight:   [^]f32, // weights of vertices in each bone         (nskinbonevert x 1)
	skin_pathadr:          [^]i32, // address of asset path for skin; -1: none (nskin x 1)

	// height fields
	hfield_size:           [^]f64, // (x, y, z_top, z_bottom)                  (nhfield x 4)
	hfield_nrow:           [^]i32, // number of rows in grid                   (nhfield x 1)
	hfield_ncol:           [^]i32, // number of columns in grid                (nhfield x 1)
	hfield_adr:            [^]i32, // address in hfield_data                   (nhfield x 1)
	hfield_data:           [^]f32, // elevation data                           (nhfielddata x 1)
	hfield_pathadr:        [^]i32, // address of hfield asset path; -1: none   (nhfield x 1)

	// textures
	tex_type:              [^]i32, // texture type (mjtTexture)                (ntex x 1)
	tex_colorspace:        [^]i32, // texture colorspace (mjtColorSpace)       (ntex x 1)
	tex_height:            [^]i32, // number of rows in texture image          (ntex x 1)
	tex_width:             [^]i32, // number of columns in texture image       (ntex x 1)
	tex_nchannel:          [^]i32, // number of channels in texture image      (ntex x 1)
	tex_adr:               [^]i64, // start address in tex_data                (ntex x 1)
	tex_data:              [^]b8, // pixel values                             (ntexdata x 1)
	tex_pathadr:           [^]i32, // address of texture asset path; -1: none  (ntex x 1)

	// materials
	mat_texid:             [^]i32, // indices of textures; -1: none            (nmat x mjNTEXROLE)
	mat_texuniform:        [^]b8, // make texture cube uniform                (nmat x 1)
	mat_texrepeat:         [^]f32, // texture repetition for 2d mapping        (nmat x 2)
	mat_emission:          [^]f32, // emission (x rgb)                         (nmat x 1)
	mat_specular:          [^]f32, // specular (x white)                       (nmat x 1)
	mat_shininess:         [^]f32, // shininess coef                           (nmat x 1)
	mat_reflectance:       [^]f32, // reflectance (0: disable)                 (nmat x 1)
	mat_metallic:          [^]f32, // metallic coef                            (nmat x 1)
	mat_roughness:         [^]f32, // roughness coef                           (nmat x 1)
	mat_rgba:              [^]f32, // rgba                                     (nmat x 4)

	// predefined geom pairs for collision detection; has precedence over exclude
	pair_dim:              [^]i32, // contact dimensionality                   (npair x 1)
	pair_geom1:            [^]i32, // id of geom1                              (npair x 1)
	pair_geom2:            [^]i32, // id of geom2                              (npair x 1)
	pair_signature:        [^]i32, // body1 << 16 + body2                      (npair x 1)
	pair_solref:           [^]f64, // solver reference: contact normal         (npair x mjNREF)
	pair_solreffriction:   [^]f64, // solver reference: contact friction       (npair x mjNREF)
	pair_solimp:           [^]f64, // solver impedance: contact                (npair x mjNIMP)
	pair_margin:           [^]f64, // detect contact if dist<margin            (npair x 1)
	pair_gap:              [^]f64, // include in solver if dist<margin-gap     (npair x 1)
	pair_friction:         [^]f64, // tangent1, 2, spin, roll1, 2              (npair x 5)

	// excluded body pairs for collision detection
	exclude_signature:     [^]i32, // body1 << 16 + body2                      (nexclude x 1)

	// equality constraints
	eq_type:               [^]i32, // constraint type (mjtEq)                  (neq x 1)
	eq_obj1id:             [^]i32, // id of object 1                           (neq x 1)
	eq_obj2id:             [^]i32, // id of object 2                           (neq x 1)
	eq_objtype:            [^]i32, // type of both objects (mjtObj)            (neq x 1)
	eq_active0:            [^]b8, // initial enable/disable constraint state  (neq x 1)
	eq_solref:             [^]f64, // constraint solver reference              (neq x mjNREF)
	eq_solimp:             [^]f64, // constraint solver impedance              (neq x mjNIMP)
	eq_data:               [^]f64, // numeric data for constraint              (neq x mjNEQDATA)

	// tendons
	tendon_adr:            [^]i32, // address of first object in tendon's path (ntendon x 1)
	tendon_num:            [^]i32, // number of objects in tendon's path       (ntendon x 1)
	tendon_matid:          [^]i32, // material id for rendering                (ntendon x 1)
	tendon_actuatorid:     [^]i32, // actuator contributing damping / armature (ntendon x 1)
	tendon_group:          [^]i32, // group for visibility                     (ntendon x 1)
	tendon_treenum:        [^]i32, // number of trees along tendon's path      (ntendon x 1)
	tendon_treeid:         [^]i32, // first two trees along tendon's path      (ntendon x 2)
	ten_J_rownnz:          [^]i32, // number of non-zeros in Jacobian row      (ntendon x 1)
	ten_J_rowadr:          [^]i32, // row start address in colind array        (ntendon x 1)
	ten_J_colind:          [^]i32, // column indices in sparse Jacobian        (nJten x 1)
	tendon_limited:        [^]b8, // does tendon have length limits           (ntendon x 1)
	tendon_actfrclimited:  [^]b8, // does tendon have actuator force limits   (ntendon x 1)
	tendon_width:          [^]f64, // width for rendering                      (ntendon x 1)
	tendon_solref_lim:     [^]f64, // constraint solver reference: limit       (ntendon x mjNREF)
	tendon_solimp_lim:     [^]f64, // constraint solver impedance: limit       (ntendon x mjNIMP)
	tendon_solref_fri:     [^]f64, // constraint solver reference: friction    (ntendon x mjNREF)
	tendon_solimp_fri:     [^]f64, // constraint solver impedance: friction    (ntendon x mjNIMP)
	tendon_range:          [^]f64, // tendon length limits                     (ntendon x 2)
	tendon_actfrcrange:    [^]f64, // range of total actuator force            (ntendon x 2)
	tendon_margin:         [^]f64, // min distance for limit detection         (ntendon x 1)
	tendon_stiffness:      [^]f64, // linear stiffness coefficient             (ntendon x 1)
	tendon_stiffnesspoly:  [^]f64, // high-order stiffness coefficients        (ntendon x mjNPOLY)
	tendon_damping:        [^]f64, // linear damping coefficient               (ntendon x 1)
	tendon_dampingpoly:    [^]f64, // high-order damping coefficients          (ntendon x mjNPOLY)
	tendon_armature:       [^]f64, // inertia associated with tendon velocity  (ntendon x 1)
	tendon_frictionloss:   [^]f64, // loss due to friction                     (ntendon x 1)
	tendon_lengthspring:   [^]f64, // spring resting length range              (ntendon x 2)
	tendon_length0:        [^]f64, // tendon length in qpos0                   (ntendon x 1)
	tendon_invweight0:     [^]f64, // inv. weight in qpos0                     (ntendon x 1)
	tendon_user:           [^]f64, // user data                                (ntendon x nuser_tendon)
	tendon_rgba:           [^]f32, // rgba when material is omitted            (ntendon x 4)

	// list of all wrap objects in tendon paths
	wrap_type:             [^]i32, // wrap object type (mjtWrap)               (nwrap x 1)
	wrap_objid:            [^]i32, // object id: geom, site, joint             (nwrap x 1)
	wrap_prm:              [^]f64, // divisor, joint coef, or site id          (nwrap x 1)

	// actuators
	actuator_trntype:      [^]i32, // transmission type (mjtTrn)               (nu x 1)
	actuator_dyntype:      [^]i32, // dynamics type (mjtDyn)                   (nu x 1)
	actuator_gaintype:     [^]i32, // gain type (mjtGain)                      (nu x 1)
	actuator_biastype:     [^]i32, // bias type (mjtBias)                      (nu x 1)
	actuator_trnid:        [^]i32, // transmission id: joint, tendon, site     (nu x 2)
	actuator_damping:      [^]f64, // linear damping coefficient               (nu x 1)
	actuator_dampingpoly:  [^]f64, // high-order damping coefficients          (nu x mjNPOLY)
	actuator_armature:     [^]f64, // armature added to target (joint, tendon) (nu x 1)
	actuator_actadr:       [^]i32, // first activation address; -1: stateless  (nu x 1)
	actuator_actnum:       [^]i32, // number of activation variables           (nu x 1)
	actuator_group:        [^]i32, // group for visibility                     (nu x 1)
	actuator_history:      [^]i32, // history buffer: [nsample, interp]        (nu x 2)
	actuator_historyadr:   [^]i32, // address in history buffer; -1: none      (nu x 1)
	actuator_delay:        [^]f64, // delay time in seconds; 0: no delay       (nu x 1)
	actuator_ctrllimited:  [^]b8, // is control limited                       (nu x 1)
	actuator_forcelimited: [^]b8, // is force limited                         (nu x 1)
	actuator_actlimited:   [^]b8, // is activation limited                    (nu x 1)
	actuator_dynprm:       [^]f64, // dynamics parameters                      (nu x mjNDYN)
	actuator_gainprm:      [^]f64, // gain parameters                          (nu x mjNGAIN)
	actuator_biasprm:      [^]f64, // bias parameters                          (nu x mjNBIAS)
	actuator_actearly:     [^]b8, // step activation before force             (nu x 1)
	actuator_ctrlrange:    [^]f64, // range of controls                        (nu x 2)
	actuator_forcerange:   [^]f64, // range of forces                          (nu x 2)
	actuator_actrange:     [^]f64, // range of activations                     (nu x 2)
	actuator_gear:         [^]f64, // scale length and transmitted force       (nu x 6)
	actuator_cranklength:  [^]f64, // crank length for slider-crank            (nu x 1)
	actuator_acc0:         [^]f64, // acceleration from unit force in qpos0    (nu x 1)
	actuator_length0:      [^]f64, // actuator length in qpos0                 (nu x 1)
	actuator_lengthrange:  [^]f64, // feasible actuator length range           (nu x 2)
	actuator_user:         [^]f64, // user data                                (nu x nuser_actuator)
	actuator_plugin:       [^]i32, // plugin instance id; -1: not a plugin     (nu x 1)

	// sensors
	sensor_type:           [^]i32, // sensor type (mjtSensor)                  (nsensor x 1)
	sensor_datatype:       [^]i32, // numeric data type (mjtDataType)          (nsensor x 1)
	sensor_needstage:      [^]i32, // required compute stage (mjtStage)        (nsensor x 1)
	sensor_objtype:        [^]i32, // type of sensorized object (mjtObj)       (nsensor x 1)
	sensor_objid:          [^]i32, // id of sensorized object                  (nsensor x 1)
	sensor_reftype:        [^]i32, // type of reference frame (mjtObj)         (nsensor x 1)
	sensor_refid:          [^]i32, // id of reference frame; -1: global frame  (nsensor x 1)
	sensor_intprm:         [^]i32, // sensor parameters                        (nsensor x mjNSENS)
	sensor_dim:            [^]i32, // number of scalar outputs                 (nsensor x 1)
	sensor_adr:            [^]i32, // address in sensor array                  (nsensor x 1)
	sensor_cutoff:         [^]f64, // cutoff for real and positive; 0: ignore  (nsensor x 1)
	sensor_noise:          [^]f64, // noise standard deviation                 (nsensor x 1)
	sensor_history:        [^]i32, // history buffer: [nsample, interp]        (nsensor x 2)
	sensor_historyadr:     [^]i32, // address in history buffer; -1: none      (nsensor x 1)
	sensor_delay:          [^]f64, // delay time in seconds; 0: no delay       (nsensor x 1)
	sensor_interval:       [^]f64, // interval: [period, phase] in seconds     (nsensor x 2)
	sensor_user:           [^]f64, // user data                                (nsensor x nuser_sensor)
	sensor_plugin:         [^]i32, // plugin instance id; -1: not a plugin     (nsensor x 1)

	// plugin instances
	plugin:                [^]i32, // globally registered plugin slot number   (nplugin x 1)
	plugin_stateadr:       [^]i32, // address in the plugin state array        (nplugin x 1)
	plugin_statenum:       [^]i32, // number of states in the plugin instance  (nplugin x 1)
	plugin_attr:           [^]cstring, // config attributes of plugin instances    (npluginattr x 1)
	plugin_attradr:        [^]i32, // address to each instance's config attrib (nplugin x 1)

	// custom numeric fields
	numeric_adr:           [^]i32, // address of field in numeric_data         (nnumeric x 1)
	numeric_size:          [^]i32, // size of numeric field                    (nnumeric x 1)
	numeric_data:          [^]f64, // array of all numeric fields              (nnumericdata x 1)

	// custom text fields
	text_adr:              [^]i32, // address of text in text_data             (ntext x 1)
	text_size:             [^]i32, // size of text field (strlen+1)            (ntext x 1)
	text_data:             [^]cstring, // array of all text fields (0-terminated)  (ntextdata x 1)

	// custom tuple fields
	tuple_adr:             [^]i32, // address of text in text_data             (ntuple x 1)
	tuple_size:            [^]i32, // number of objects in tuple               (ntuple x 1)
	tuple_objtype:         [^]i32, // array of object types in all tuples      (ntupledata x 1)
	tuple_objid:           [^]i32, // array of object ids in all tuples        (ntupledata x 1)
	tuple_objprm:          [^]f64, // array of object params in all tuples     (ntupledata x 1)

	// keyframes
	key_time:              [^]f64, // key time                                 (nkey x 1)
	key_qpos:              [^]f64, // key position                             (nkey x nq)
	key_qvel:              [^]f64, // key velocity                             (nkey x nv)
	key_act:               [^]f64, // key activation                           (nkey x na)
	key_mpos:              [^]f64, // key mocap position                       (nkey x nmocap*3)
	key_mquat:             [^]f64, // key mocap quaternion                     (nkey x nmocap*4)
	key_ctrl:              [^]f64, // key control                              (nkey x nu)

	// names
	name_bodyadr:          [^]i32, // body name pointers                       (nbody x 1)
	name_jntadr:           [^]i32, // joint name pointers                      (njnt x 1)
	name_geomadr:          [^]i32, // geom name pointers                       (ngeom x 1)
	name_siteadr:          [^]i32, // site name pointers                       (nsite x 1)
	name_camadr:           [^]i32, // camera name pointers                     (ncam x 1)
	name_lightadr:         [^]i32, // light name pointers                      (nlight x 1)
	name_flexadr:          [^]i32, // flex name pointers                       (nflex x 1)
	name_meshadr:          [^]i32, // mesh name pointers                       (nmesh x 1)
	name_skinadr:          [^]i32, // skin name pointers                       (nskin x 1)
	name_hfieldadr:        [^]i32, // hfield name pointers                     (nhfield x 1)
	name_texadr:           [^]i32, // texture name pointers                    (ntex x 1)
	name_matadr:           [^]i32, // material name pointers                   (nmat x 1)
	name_pairadr:          [^]i32, // geom pair name pointers                  (npair x 1)
	name_excludeadr:       [^]i32, // exclude name pointers                    (nexclude x 1)
	name_eqadr:            [^]i32, // equality constraint name pointers        (neq x 1)
	name_tendonadr:        [^]i32, // tendon name pointers                     (ntendon x 1)
	name_actuatoradr:      [^]i32, // actuator name pointers                   (nu x 1)
	name_sensoradr:        [^]i32, // sensor name pointers                     (nsensor x 1)
	name_numericadr:       [^]i32, // numeric name pointers                    (nnumeric x 1)
	name_textadr:          [^]i32, // text name pointers                       (ntext x 1)
	name_tupleadr:         [^]i32, // tuple name pointers                      (ntuple x 1)
	name_keyadr:           [^]i32, // keyframe name pointers                   (nkey x 1)
	name_pluginadr:        [^]i32, // plugin instance name pointers            (nplugin x 1)
	names:                 [^]cstring, // names of all objects, 0-terminated       (nnames x 1)
	names_map:             [^]i32, // internal hash map of names               (nnames_map x 1)

	// paths
	paths:                 [^]cstring, // paths to assets, 0-terminated            (npaths x 1)

	// sparse structures
	B_rownnz:              [^]i32, // body-dof: non-zeros in each row          (nbody x 1)
	B_rowadr:              [^]i32, // body-dof: row addresses                  (nbody x 1)
	B_colind:              [^]i32, // body-dof: column indices                 (nB x 1)
	M_rownnz:              [^]i32, // reduced inertia: non-zeros in each row   (nv x 1)
	M_rowadr:              [^]i32, // reduced inertia: row addresses           (nv x 1)
	M_colind:              [^]i32, // reduced inertia: column indices          (nC x 1)
	mapM2M:                [^]i32, // index mapping from qM to M               (nC x 1)
	D_rownnz:              [^]i32, // full inertia: non-zeros in each row      (nv x 1)
	D_rowadr:              [^]i32, // full inertia: row addresses              (nv x 1)
	D_diag:                [^]i32, // full inertia: index of diagonal element  (nv x 1)
	D_colind:              [^]i32, // full inertia: column indices             (nD x 1)
	mapM2D:                [^]i32, // index mapping from M to D                (nD x 1)
	mapD2M:                [^]i32, // index mapping from D to M                (nC x 1)

	// compilation signature
	signature:             u64, // also held by the mjSpec that compiled this model
}
