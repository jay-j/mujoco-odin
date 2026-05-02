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

import "core:c"

// header version; should match the library version as returned by mj_version()
mjVERSION_HEADER :: 3008000

when ODIN_OS == .Windows {
	foreign import mujoco "mujoco.dll"
} else {
	foreign import mujoco "libmujoco.so.3.8.0"
}

@(default_calling_convention = "c", link_prefix = "mj_")
foreign mujoco {
	// Initialize an empty VFS, mj_deleteVFS must be called to deallocate the VFS.
	defaultVFS :: proc(vfs: ^VFS) ---

	// Mount a ResourceProvider to handle file operations under the given path; return 0: success,
	// 2: repeated name, -1: invalid resource provider.
	mountVFS :: proc(vfs: ^VFS, filepath: cstring, provider: ^pResourceProvider) -> i32 ---

	// Unmount a previously mounted ResourceProvider; return 0: success, -1: not found in VFS.
	unmountVFS :: proc(vfs: ^VFS, filename: cstring) -> i32 ---

	// Add file to VFS; return 0: success, 2: repeated name, -1: failed to load.
	addFileVFS :: proc(vfs: ^VFS, directory: cstring, filename: cstring) -> i32 ---

	// Add file to VFS from buffer; return 0: success, 2: repeated name, -1: failed to load.
	addBufferVFS :: proc(vfs: ^VFS, name: cstring, buffer: rawptr, nbuffer: i32) -> i32 ---

	// Delete file from VFS; return 0: success, -1: not found in VFS.
	deleteFileVFS :: proc(vfs: ^VFS, filename: cstring) -> i32 ---

	// Check if buffer exists in VFS; return 1: exists, 0: not found.
	containsBufferVFS :: proc(vfs: ^VFS, name: cstring) -> i32 ---

	// Check if file exists in VFS; return 1: exists, 0: not found.
	containsFileVFS :: proc(vfs: ^VFS, directory: cstring, filename: cstring) -> i32 ---

	// Delete all files from VFS and deallocates VFS internal memory.
	deleteVFS :: proc(vfs: ^VFS) ---

	// Get the current size of the asset cache in bytes.
	getCacheSize :: proc(cache: ^Cache) -> c.size_t ---

	// Get the capacity of the asset cache in bytes.
	getCacheCapacity :: proc(cache: ^Cache) -> c.size_t ---

	// Set the capacity of the asset cache in bytes (0 to disable); return the new capacity.
	setCacheCapacity :: proc(cache: ^Cache, size: c.size_t) -> c.size_t ---

	// Get the internal asset cache used by the compiler.
	getCache :: proc() -> ^Cache ---

	// Clear the asset cache.
	clearCache :: proc(cache: ^Cache) ---

	// Parse XML file in MJCF or URDF format, compile it; return low-level model.
	// If vfs is not NULL, look up files in vfs before reading from disk.
	// If error is not NULL, it must have size error_sz.
	// Nullable: vfs, error
	loadXML :: proc(filename: cstring, vfs: ^VFS, error: cstring, error_sz: i32) -> ^Model ---

	// Parse spec from XML file.
	// Nullable: vfs, error
	parseXML :: proc(filename: cstring, vfs: ^VFS, error: cstring, error_sz: i32) -> ^Spec ---

	// Parse spec from XML string.
	// Nullable: vfs, error
	parseXMLString :: proc(xml: cstring, vfs: ^VFS, error: cstring, error_sz: i32) -> ^Spec ---

	// Parse spec from a file.
	// Nullable: vfs, error
	parse :: proc(filename: cstring, content_type: cstring, vfs: ^VFS, error: cstring, error_sz: i32) -> ^Spec ---

	// Encode spec/model to a file using a registered encoder.
	// Returns the number of bytes written on success, -1 on failure.
	// Nullable: m, vfs, error
	encode :: proc(s: ^Spec, m: ^Model, filename: cstring, content_type: cstring, vfs: ^VFS, error: cstring, error_sz: i32) -> i32 ---

	// Compile spec to model.
	// Nullable: vfs
	compile :: proc(s: ^Spec, vfs: ^VFS) -> ^Model ---

	// Copy real-valued arrays from model to spec; return 1 on success.
	copyBack :: proc(s: ^Spec, m: ^Model) -> i32 ---

	// Recompile spec to model, preserving the state; return 0 on success.
	// Nullable: vfs
	recompile :: proc(s: ^Spec, vfs: ^VFS, m: ^Model, d: ^Data) -> i32 ---

	// Update XML data structures with info from low-level model created with mj_loadXML, save as MJCF.
	// If error is not NULL, it must have size error_sz.
	// Nullable: error
	saveLastXML :: proc(filename: cstring, m: ^Model, error: cstring, error_sz: i32) -> i32 ---

	// Free last XML model if loaded. Called internally at each load.
	freeLastXML :: proc() ---

	// Save spec to XML string; return 0 on success, -1 on failure.
	// If length of the output buffer is too small; return the required size.
	// Nullable: error
	saveXMLString :: proc(s: ^Spec, xml: cstring, xml_sz: i32, error: cstring, error_sz: i32) -> i32 ---

	// Save spec to XML file; return 0 on success, -1 otherwise.
	// Nullable: error
	saveXML :: proc(s: ^Spec, filename: cstring, error: cstring, error_sz: i32) -> i32 ---

	// Given MJCF filename, fills dependencies with a list of all other asset files it depends on.
	// The search is recursive, and the list includes the filename itself.
	mju_getXMLDependencies :: proc(filename: cstring, dependencies: ^StringVec) ---

	// Advance simulation, use control callback to obtain external force and control.
	step :: proc(m: ^Model, d: ^Data) ---

	// Advance simulation in two steps: before external force and control is set by user.
	step1 :: proc(m: ^Model, d: ^Data) ---

	// Advance simulation in two steps: after external force and control is set by user.
	step2 :: proc(m: ^Model, d: ^Data) ---

	// Forward dynamics: same as mj_step but do not integrate in time.
	forward :: proc(m: ^Model, d: ^Data) ---

	// Inverse dynamics: qacc must be set before calling.
	inverse :: proc(m: ^Model, d: ^Data) ---

	// Forward dynamics with skip; skipstage is mjtStage.
	forwardSkip :: proc(m: ^Model, d: ^Data, skipstage: i32, skipsensor: i32) ---

	// Inverse dynamics with skip; skipstage is mjtStage.
	inverseSkip :: proc(m: ^Model, d: ^Data, skipstage: i32, skipsensor: i32) ---

	// Set default options for length range computation.
	defaultLROpt :: proc(opt: ^LROpt) ---

	// Set solver parameters to default values.
	// Nullable: solref, solimp
	defaultSolRefImp :: proc(solref: ^f64, solimp: ^f64) ---

	// Set physics options to default values.
	defaultOption :: proc(opt: ^Option) ---

	// Set visual options to default values.
	defaultVisual :: proc(vis: ^Visual) ---

	// Copy mjModel, allocate new if dest is NULL.
	// Nullable: dest
	copyModel :: proc(dest: ^Model, src: ^Model) -> ^Model ---

	// Save model to binary MJB file or memory buffer; buffer has precedence when given.
	// Nullable: filename, buffer
	saveModel :: proc(m: ^Model, filename: cstring, buffer: rawptr, buffer_sz: i32) ---

	// Load model from binary MJB file.
	// If vfs is not NULL, look up file in vfs before reading from disk.
	// Nullable: vfs
	loadModel :: proc(filename: cstring, vfs: ^VFS) -> ^Model ---

	// Load model from memory buffer.
	loadModelBuffer :: proc(buffer: rawptr, buffer_sz: i32) -> ^Model ---

	// Free memory allocation in model.
	deleteModel :: proc(m: ^Model) ---

	// Return size of buffer needed to hold model.
	sizeModel :: proc(m: ^Model) -> i64 ---

	// Allocate mjData corresponding to given model.
	// If the model buffer is unallocated the initial configuration will not be set.
	makeData :: proc(m: ^Model) -> ^Data ---

	// Copy mjData.
	// m is only required to contain the size fields from MJMODEL_INTS.
	copyData :: proc(dest: ^Data, m: ^Model, src: ^Data) -> ^Data ---

	// Copy mjData, skip large arrays not required for visualization.
	mjv_copyData :: proc(dest: ^Data, m: ^Model, src: ^Data) -> ^Data ---

	// Reset data to defaults.
	resetData :: proc(m: ^Model, d: ^Data) ---

	// Reset data to defaults, fill everything else with debug_value.
	resetDataDebug :: proc(m: ^Model, d: ^Data, debug_value: u8) ---

	// Reset data. If 0 <= key < nkey, set fields from specified keyframe.
	resetDataKeyframe :: proc(m: ^Model, d: ^Data, key: i32) ---

	// Mark a new frame on the mjData stack.
	markStack :: proc(d: ^Data) ---

	// Free the current mjData stack frame. All pointers returned by mj_stackAlloc since the last call
	// to mj_markStack must no longer be used afterwards.
	freeStack :: proc(d: ^Data) ---

	// Allocate a number of bytes on mjData stack at a specific alignment.
	// Call mju_error on stack overflow.
	stackAllocByte :: proc(d: ^Data, bytes: c.size_t, alignment: c.size_t) -> rawptr ---

	// Allocate array of mjtNums on mjData stack. Call mju_error on stack overflow.
	stackAllocNum :: proc(d: ^Data, size: c.size_t) -> ^f64 ---

	// Allocate array of ints on mjData stack. Call mju_error on stack overflow.
	stackAllocInt :: proc(d: ^Data, size: c.size_t) -> ^i32 ---

	// Free memory allocation in mjData.
	deleteData :: proc(d: ^Data) ---

	// Reset all callbacks to NULL pointers (NULL is the default).
	resetCallbacks :: proc() ---

	// Set constant fields of mjModel, corresponding to qpos0 configuration.
	setConst :: proc(m: ^Model, d: ^Data) ---

	// Set actuator_lengthrange for specified actuator; return 1 if ok, 0 if error.
	// Nullable: error
	setLengthRange :: proc(m: ^Model, d: ^Data, index: i32, opt: ^LROpt, error: cstring, error_sz: i32) -> i32 ---

	// Create empty spec.
	makeSpec :: proc() -> ^Spec ---

	// Copy spec.
	copySpec :: proc(s: ^Spec) -> ^Spec ---

	// Free memory allocation in mjSpec.
	deleteSpec :: proc(s: ^Spec) ---

	// Activate plugin; return 0 on success.
	mjs_activatePlugin :: proc(s: ^Spec, name: cstring) -> i32 ---

	// Turn deep copy on or off attach; return 0 on success.
	mjs_setDeepCopy :: proc(s: ^Spec, deepcopy: i32) -> i32 ---

	// Print mjModel to text file, specifying format.
	// float_format must be a valid printf-style format string for a single float value.
	printFormattedModel :: proc(m: ^Model, filename: cstring, float_format: cstring) ---

	// Print model to text file.
	printModel :: proc(m: ^Model, filename: cstring) ---

	// Print mjData to text file, specifying format.
	// float_format must be a valid printf-style format string for a single float value.
	printFormattedData :: proc(m: ^Model, d: ^Data, filename: cstring, float_format: cstring) ---

	// Print data to text file.
	printData :: proc(m: ^Model, d: ^Data, filename: cstring) ---

	// Print internal XML schema as plain text or HTML, with style-padding or &nbsp;.
	printSchema :: proc(filename: cstring, buffer: cstring, buffer_sz: i32, flg_html: i32, flg_pad: i32) -> i32 ---

	// Print scene to text file.
	printScene :: proc(s: ^vScene, filename: cstring) ---

	// Print scene to text file, specifying format.
	// float_format must be a valid printf-style format string for a single float value.
	printFormattedScene :: proc(s: ^vScene, filename: cstring, float_format: cstring) ---

	// Run all kinematics-like computations (kinematics, comPos, camlight, flex, tendon).
	fwdKinematics :: proc(m: ^Model, d: ^Data) ---

	// Run position-dependent computations.
	fwdPosition :: proc(m: ^Model, d: ^Data) ---

	// Run velocity-dependent computations.
	fwdVelocity :: proc(m: ^Model, d: ^Data) ---

	// Compute actuator force qfrc_actuator.
	fwdActuation :: proc(m: ^Model, d: ^Data) ---

	// Add up all non-constraint forces, compute qacc_smooth.
	fwdAcceleration :: proc(m: ^Model, d: ^Data) ---

	// Run selected constraint solver.
	fwdConstraint :: proc(m: ^Model, d: ^Data) ---

	// Euler integrator, semi-implicit in velocity.
	Euler :: proc(m: ^Model, d: ^Data) ---

	// Runge-Kutta explicit order-N integrator.
	RungeKutta :: proc(m: ^Model, d: ^Data, N: i32) ---

	// Implicit-in-velocity integrators.
	implicit :: proc(m: ^Model, d: ^Data) ---

	// Run position-dependent computations in inverse dynamics.
	invPosition :: proc(m: ^Model, d: ^Data) ---

	// Run velocity-dependent computations in inverse dynamics.
	invVelocity :: proc(m: ^Model, d: ^Data) ---

	// Apply the analytical formula for inverse constraint dynamics.
	invConstraint :: proc(m: ^Model, d: ^Data) ---

	// Compare forward and inverse dynamics, save results in fwdinv.
	compareFwdInv :: proc(m: ^Model, d: ^Data) ---

	// Evaluate position-dependent sensors.
	sensorPos :: proc(m: ^Model, d: ^Data) ---

	// Evaluate velocity-dependent sensors.
	sensorVel :: proc(m: ^Model, d: ^Data) ---

	// Evaluate acceleration and force-dependent sensors.
	sensorAcc :: proc(m: ^Model, d: ^Data) ---

	// Evaluate position-dependent energy (potential).
	energyPos :: proc(m: ^Model, d: ^Data) ---

	// Evaluate velocity-dependent energy (kinetic).
	energyVel :: proc(m: ^Model, d: ^Data) ---

	// Check qpos, reset if any element is too big or nan.
	checkPos :: proc(m: ^Model, d: ^Data) ---

	// Check qvel, reset if any element is too big or nan.
	checkVel :: proc(m: ^Model, d: ^Data) ---

	// Check qacc, reset if any element is too big or nan.
	checkAcc :: proc(m: ^Model, d: ^Data) ---

	// Run forward kinematics.
	kinematics :: proc(m: ^Model, d: ^Data) ---

	// Map inertias and motion dofs to global frame centered at CoM.
	comPos :: proc(m: ^Model, d: ^Data) ---

	// Compute camera and light positions and orientations.
	camlight :: proc(m: ^Model, d: ^Data) ---

	// Compute flex-related quantities.
	flex :: proc(m: ^Model, d: ^Data) ---

	// Compute tendon lengths, velocities and moment arms.
	tendon :: proc(m: ^Model, d: ^Data) ---

	// Compute actuator transmission lengths and moments.
	transmission :: proc(m: ^Model, d: ^Data) ---

	// Run composite rigid body inertia algorithm (CRB).
	crb :: proc(m: ^Model, d: ^Data) ---

	// Make inertia matrix.
	makeM :: proc(m: ^Model, d: ^Data) ---

	// Compute sparse L'*D*L factorizaton of inertia matrix.
	factorM :: proc(m: ^Model, d: ^Data) ---

	// Solve linear system M * x = y using factorization:  x = inv(L'*D*L)*y
	solveM :: proc(m: ^Model, d: ^Data, x: ^f64, y: ^f64, n: i32) ---

	// Half of linear solve:  x = sqrt(inv(D))*inv(L')*y
	solveM2 :: proc(m: ^Model, d: ^Data, x: ^f64, y: ^f64, sqrtInvD: ^f64, n: i32) ---

	// Compute cvel, cdof_dot.
	comVel :: proc(m: ^Model, d: ^Data) ---

	// Compute qfrc_passive from spring-dampers, gravity compensation and fluid forces.
	passive :: proc(m: ^Model, d: ^Data) ---

	// Sub-tree linear velocity and angular momentum: compute subtree_linvel, subtree_angmom.
	subtreeVel :: proc(m: ^Model, d: ^Data) ---

	// RNE: compute M(qpos)*qacc + C(qpos,qvel); flg_acc=0 removes inertial term.
	rne :: proc(m: ^Model, d: ^Data, flg_acc: i32, result: ^f64) ---

	// RNE with complete data: compute cacc, cfrc_ext, cfrc_int.
	rnePostConstraint :: proc(m: ^Model, d: ^Data) ---

	// Return the maximum number of contacts that can be generated between two geoms.
	// If has_margin is -1, then the margin is pulled from the model, otherwise if has_margin > 0
	// indicates that the geoms have a positive margin.
	maxContact :: proc(m: ^Model, g1: i32, g2: i32, has_margin: i32) -> i32 ---

	// Run collision detection.
	collision :: proc(m: ^Model, d: ^Data) ---

	// Construct constraints.
	makeConstraint :: proc(m: ^Model, d: ^Data) ---

	// Find constraint islands.
	island :: proc(m: ^Model, d: ^Data) ---

	// Compute inverse constraint inertia efc_AR.
	projectConstraint :: proc(m: ^Model, d: ^Data) ---

	// Compute efc_vel, efc_aref.
	referenceConstraint :: proc(m: ^Model, d: ^Data) ---

	// Compute efc_state, efc_force, qfrc_constraint, and (optionally) cone Hessians.
	// If cost is not NULL, set *cost = s(jar) where jar = Jac*qacc-aref.
	// Nullable: cost
	constraintUpdate :: proc(m: ^Model, d: ^Data, jar: ^f64, cost: ^[1]f64, flg_coneHessian: i32) ---

	// Return size of state signature.
	stateSize :: proc(m: ^Model, sig: i32) -> i32 ---

	// Get state.
	getState :: proc(m: ^Model, d: ^Data, state: ^f64, sig: i32) ---

	// Extract a subset of components from a state previously obtained via mj_getState.
	extractState :: proc(m: ^Model, src: ^f64, srcsig: i32, dst: ^f64, dstsig: i32) ---

	// Set state.
	setState :: proc(m: ^Model, d: ^Data, state: ^f64, sig: i32) ---

	// Copy state from src to dst.
	copyState :: proc(m: ^Model, src: ^Data, dst: ^Data, sig: i32) ---

	// Read ctrl value for actuator at given time.
	// Returns d->ctrl[id] if no history, otherwise reads from history buffer.
	// interp: 0=zero-order-hold, 1=linear, 2=cubic spline.
	readCtrl :: proc(m: ^Model, d: ^Data, id: i32, time: f64, interp: i32) -> f64 ---

	// Read sensor value from history buffer at given time.
	// Returns pointer to sensordata (no history) or history buffer (exact match),
	// or NULL if interpolation performed (writes to result).
	// interp: 0=zero-order-hold, 1=linear, 2=cubic spline.
	readSensor :: proc(m: ^Model, d: ^Data, id: i32, time: f64, result: ^f64, interp: i32) -> ^f64 ---

	// Initialize history buffer for actuator; if times is NULL, uses existing buffer timestamps.
	// Nullable: times
	initCtrlHistory :: proc(m: ^Model, d: ^Data, id: i32, times: ^f64, values: ^f64) ---

	// Initialize history buffer for sensor; if times is NULL, uses existing buffer timestamps.
	// phase sets the user slot (last computation time for interval sensors).
	// Nullable: times
	initSensorHistory :: proc(m: ^Model, d: ^Data, id: i32, times: ^f64, values: ^f64, phase: f64) ---

	// Copy current state to the k-th model keyframe.
	setKeyframe :: proc(m: ^Model, d: ^Data, k: i32) ---

	// Add contact to d->contact list; return 0 if success; 1 if buffer full.
	addContact :: proc(m: ^Model, d: ^Data, con: ^Contact) -> i32 ---

	// Determine type of friction cone.
	isPyramidal :: proc(m: ^Model) -> b32 ---

	// Determine type of constraint Jacobian.
	isSparse :: proc(m: ^Model) -> b32 ---

	// Determine type of solver (PGS is dual, CG and Newton are primal).
	isDual :: proc(m: ^Model) -> b32 ---

	// Multiply dense or sparse constraint Jacobian by vector.
	mulJacVec :: proc(m: ^Model, d: ^Data, res: ^f64, vec: ^f64) ---

	// Multiply dense or sparse constraint Jacobian transpose by vector.
	mulJacTVec :: proc(m: ^Model, d: ^Data, res: ^f64, vec: ^f64) ---

	// Compute 3/6-by-nv end-effector Jacobian of global point attached to given body.
	// Nullable: jacp, jacr
	jac :: proc(m: ^Model, d: ^Data, jacp: ^f64, jacr: ^f64, point: ^[3]f64, body: i32) ---

	// Compute body frame end-effector Jacobian.
	// Nullable: jacp, jacr
	jacBody :: proc(m: ^Model, d: ^Data, jacp: ^f64, jacr: ^f64, body: i32) ---

	// Compute body center-of-mass end-effector Jacobian.
	// Nullable: jacp, jacr
	jacBodyCom :: proc(m: ^Model, d: ^Data, jacp: ^f64, jacr: ^f64, body: i32) ---

	// Compute subtree center-of-mass end-effector Jacobian.
	jacSubtreeCom :: proc(m: ^Model, d: ^Data, jacp: ^f64, body: i32) ---

	// Compute geom end-effector Jacobian.
	// Nullable: jacp, jacr
	jacGeom :: proc(m: ^Model, d: ^Data, jacp: ^f64, jacr: ^f64, geom: i32) ---

	// Compute site end-effector Jacobian.
	// Nullable: jacp, jacr
	jacSite :: proc(m: ^Model, d: ^Data, jacp: ^f64, jacr: ^f64, site: i32) ---

	// Compute translation end-effector Jacobian of point, and rotation Jacobian of axis.
	// Nullable: jacPoint, jacAxis
	jacPointAxis :: proc(m: ^Model, d: ^Data, jacPoint: ^f64, jacAxis: ^f64, point: ^[3]f64, axis: ^[3]f64, body: i32) ---

	// Compute 3/6-by-nv Jacobian time derivative of global point attached to given body.
	// Nullable: jacp, jacr
	jacDot :: proc(m: ^Model, d: ^Data, jacp: ^f64, jacr: ^f64, point: ^[3]f64, body: i32) ---

	// Compute subtree angular momentum matrix.
	angmomMat :: proc(m: ^Model, d: ^Data, mat: ^f64, body: i32) ---

	// Get id of object with the specified mjtObj type and name; return -1 if id not found.
	name2id :: proc(m: ^Model, type: tObj, name: cstring) -> i32 ---

	// Get name of object with the specified mjtObj type and id; return NULL if name not found.
	id2name :: proc(m: ^Model, type: tObj, id: i32) -> cstring ---

	// Convert sparse inertia matrix M into full (i.e. dense) matrix.
	fullM :: proc(m: ^Model, dst: ^f64, M: ^f64) ---

	// Multiply vector by inertia matrix.
	mulM :: proc(m: ^Model, d: ^Data, res: ^f64, vec: ^f64) ---

	// Multiply vector by (inertia matrix)^(1/2).
	mulM2 :: proc(m: ^Model, d: ^Data, res: ^f64, vec: ^f64) ---

	// Add inertia matrix to destination matrix (lower triangle only).
	// Destination can be sparse or dense when all int* are NULL.
	// Nullable: rownnz, rowadr, colind
	addM :: proc(m: ^Model, d: ^Data, dst: ^f64, rownnz: ^i32, rowadr: ^i32, colind: ^i32) ---

	// Apply Cartesian force and torque (outside xfrc_applied mechanism).
	// Nullable: force, torque
	applyFT :: proc(m: ^Model, d: ^Data, force: ^[3]f64, torque: ^[3]f64, point: ^[3]f64, body: i32, qfrc_target: ^f64) ---

	// Compute object 6D velocity (rot:lin) in object-centered frame, world/local orientation.
	objectVelocity :: proc(m: ^Model, d: ^Data, objtype: tObj, objid: i32, res: ^[6]f64, flg_local: i32) ---

	// Compute object 6D acceleration (rot:lin) in object-centered frame, world/local orientation.
	objectAcceleration :: proc(m: ^Model, d: ^Data, objtype: tObj, objid: i32, res: ^[6]f64, flg_local: i32) ---

	// Return smallest signed distance between two geoms and optionally segment from geom1 to geom2.
	// Nullable: fromto
	geomDistance :: proc(m: ^Model, d: ^Data, geom1: i32, geom2: i32, distmax: f64, fromto: ^[6]f64) -> f64 ---

	// Extract 6D force:torque given contact id, in the contact frame.
	contactForce :: proc(m: ^Model, d: ^Data, id: i32, result: ^[6]f64) ---

	// Compute velocity by finite-differencing two positions.
	differentiatePos :: proc(m: ^Model, qvel: ^f64, dt: f64, qpos1: ^f64, qpos2: ^f64) ---

	// Integrate position with given velocity.
	integratePos :: proc(m: ^Model, qpos: ^f64, qvel: ^f64, dt: f64) ---

	// Normalize all quaternions in qpos-type vector.
	normalizeQuat :: proc(m: ^Model, qpos: ^f64) ---

	// Map from body local to global Cartesian coordinates, sameframe takes values from mjtSameFrame.
	local2Global :: proc(d: ^Data, xpos: ^[3]f64, xmat: ^[9]f64, pos: ^[3]f64, quat: ^[4]f64, body: i32, sameframe: b8) ---

	// Sum all body masses.
	getTotalmass :: proc(m: ^Model) -> f64 ---

	// Scale body masses and inertias to achieve specified total mass.
	setTotalmass :: proc(m: ^Model, newmass: f64) ---

	// Return a config attribute value of a plugin instance;
	// NULL: invalid plugin instance ID or attribute name
	getPluginConfig :: proc(m: ^Model, plugin_id: i32, attrib: cstring) -> cstring ---

	// Load a dynamic library. The dynamic library is assumed to register one or more plugins.
	loadPluginLibrary :: proc(path: cstring) ---

	// Scan a directory and load all dynamic libraries. Dynamic libraries in the specified directory
	// are assumed to register one or more plugins. Optionally, if a callback is specified, it is called
	// for each dynamic library encountered that registers plugins.
	loadAllPluginLibraries :: proc(directory: cstring, callback: fPluginLibraryLoadCallback) ---

	// Return version number: 1.0.2 is encoded as 102.
	version :: proc() -> i32 ---

	// Return the current version of MuJoCo as a null-terminated string.
	versionString :: proc() -> cstring ---

	// Intersect ray (pnt+x*vec, x>=0) with visible geoms, except geoms in bodyexclude.
	// Return distance (x) to nearest surface, or -1 if no intersection.
	// geomgroup, flg_static are as in mjvOption; geomgroup==NULL skips group exclusion.
	// Nullable: geomgroup, geomid, normal
	ray :: proc(m: ^Model, d: ^Data, pnt: ^[3]f64, vec: ^[3]f64, geomgroup: ^b8, flg_static: b8, bodyexclude: i32, geomid: ^[1]i32, normal: ^[3]f64) -> f64 ---

	// Intersect multiple rays emanating from a single point, compute normals if given.
	// Similar semantics to mj_ray, but vec, normal and dist are arrays.
	// Geoms further than cutoff are ignored.
	// Nullable: geomgroup, geomid, normal
	multiRay :: proc(m: ^Model, d: ^Data, pnt: ^[3]f64, vec: ^f64, geomgroup: ^b8, flg_static: b8, bodyexclude: i32, geomid: ^i32, dist: ^f64, normal: ^f64, nray: i32, cutoff: f64) ---

	// Intersect ray with hfield; return nearest distance or -1 if no intersection.
	// Nullable: normal
	rayHfield :: proc(m: ^Model, d: ^Data, geomid: i32, pnt: ^[3]f64, vec: ^[3]f64, normal: ^[3]f64) -> f64 ---

	// Intersect ray with mesh; return nearest distance or -1 if no intersection.
	// Nullable: normal
	rayMesh :: proc(m: ^Model, d: ^Data, geomid: i32, pnt: ^[3]f64, vec: ^[3]f64, normal: ^[3]f64) -> f64 ---

	// High-level warning function: count warnings in mjData, print only the first.
	warning :: proc(d: ^Data, warning: i32, info: i32) ---

}


@(default_calling_convention = "c")
foreign mujoco {
	// Print matrix to screen.
	mju_printMat :: proc(mat: ^f64, nr: i32, nc: i32) ---

	// Print sparse matrix to screen.
	mju_printMatSparse :: proc(mat: ^f64, nr: i32, rownnz: ^i32, rowadr: ^i32, colind: ^i32) ---


	// Intersect ray with pure geom; return nearest distance or -1 if no intersection.
	// Nullable: normal
	mju_rayGeom :: proc(pos: ^[3]f64, mat: ^[9]f64, size: ^[3]f64, pnt: ^[3]f64, vec: ^[3]f64, geomtype: tGeom, normal: ^[3]f64) -> f64 ---

	// Intersect ray with flex; return nearest distance or -1 if no intersection,
	// and also output nearest vertex id and surface normal.
	// Nullable: vertid, normal
	rayFlex :: proc(m: ^Model, d: ^Data, flex_layer: i32, flg_vert: b8, flg_edge: b8, flg_face: b8, flg_skin: b8, flexid: i32, pnt: ^[3]f64, vec: ^[3]f64, vertid: ^[1]i32, normal: ^[3]f64) -> f64 ---

	// Intersect ray with skin; return nearest distance or -1 if no intersection,
	// and also output nearest vertex id.
	// Nullable: vertid
	mju_raySkin :: proc(nface: i32, nvert: i32, face: ^i32, vert: ^f32, pnt: ^[3]f64, vec: ^[3]f64, vertid: ^[1]i32) -> f64 ---

	// Set default camera.
	mjv_defaultCamera :: proc(cam: ^vCamera) ---

	// Set default free camera.
	mjv_defaultFreeCamera :: proc(m: ^Model, cam: ^vCamera) ---

	// Set default perturbation.
	mjv_defaultPerturb :: proc(pert: ^vPerturb) ---

	// Transform pose from room to model space.
	mjv_room2model :: proc(modelpos: ^[3]f64, modelquat: ^[4]f64, roompos: ^[3]f64, roomquat: ^[4]f64, scn: ^vScene) ---

	// Transform pose from model to room space.
	mjv_model2room :: proc(roompos: ^[3]f64, roomquat: ^[4]f64, modelpos: ^[3]f64, modelquat: ^[4]f64, scn: ^vScene) ---

	// Get camera info in model space; average left and right OpenGL cameras.
	mjv_cameraInModel :: proc(headpos: ^[3]f64, forward: ^[3]f64, up: ^[3]f64, scn: ^vScene) ---

	// Get camera info in room space; average left and right OpenGL cameras.
	mjv_cameraInRoom :: proc(headpos: ^[3]f64, forward: ^[3]f64, up: ^[3]f64, scn: ^vScene) ---

	// Get frustum height at unit distance from camera; average left and right OpenGL cameras.
	mjv_frustumHeight :: proc(scn: ^vScene) -> f64 ---

	// Rotate 3D vec in horizontal plane by angle between (0,1) and (forward_x,forward_y).
	mjv_alignToCamera :: proc(res: ^[3]f64, vec: ^[3]f64, forward: ^[3]f64) ---

	// Move camera with mouse; action is mjtMouse.
	mjv_moveCamera :: proc(m: ^Model, action: i32, reldx: f64, reldy: f64, scn: ^vScene, cam: ^vCamera) ---

	// Move perturb object with mouse; action is mjtMouse.
	mjv_movePerturb :: proc(m: ^Model, d: ^Data, action: i32, reldx: f64, reldy: f64, scn: ^vScene, pert: ^vPerturb) ---

	// Move model with mouse; action is mjtMouse.
	mjv_moveModel :: proc(m: ^Model, action: i32, reldx: f64, reldy: f64, roomup: ^[3]f64, scn: ^vScene) ---

	// Copy perturb pos,quat from selected body; set scale for perturbation.
	mjv_initPerturb :: proc(m: ^Model, d: ^Data, scn: ^vScene, pert: ^vPerturb) ---

	// Set perturb pos,quat in d->mocap when selected body is mocap, and in d->qpos otherwise.
	// Write d->qpos only if flg_paused and subtree root for selected body has free joint.
	mjv_applyPerturbPose :: proc(m: ^Model, d: ^Data, pert: ^vPerturb, flg_paused: i32) ---

	// Set perturb force,torque in d->xfrc_applied, if selected body is dynamic.
	mjv_applyPerturbForce :: proc(m: ^Model, d: ^Data, pert: ^vPerturb) ---

	// Return the average of two OpenGL cameras.
	mjv_averageCamera :: proc(cam1: ^vGLCamera, cam2: ^vGLCamera) -> vGLCamera ---

	// Select geom, flex or skin with mouse; return bodyid; -1: none selected.
	// Nullable: geomid, flexid, skinid
	mjv_select :: proc(m: ^Model, d: ^Data, vopt: ^vOption, aspectratio: f64, relx: f64, rely: f64, scn: ^vScene, selpnt: ^[3]f64, geomid: ^[1]i32, flexid: ^[1]i32, skinid: ^[1]i32) -> i32 ---

	// Set default visualization options.
	mjv_defaultOption :: proc(opt: ^vOption) ---

	// Set default figure.
	mjv_defaultFigure :: proc(fig: ^vFigure) ---

	// Initialize given geom fields when not NULL, set the rest to their default values.
	// Nullable: size, pos, mat, rgba
	mjv_initGeom :: proc(geom: ^vGeom, type: i32, size: ^[3]f64, pos: ^[3]f64, mat: ^[9]f64, rgba: ^[4]f32) ---

	// Set (type, size, pos, mat) for connector-type geom between given points.
	// Assume that mjv_initGeom was already called to set all other properties.
	// Width of mjGEOM_LINE is denominated in pixels.
	mjv_connector :: proc(geom: ^vGeom, type: i32, width: f64, from: ^[3]f64, to: ^[3]f64) ---

	// Set default abstract scene.
	mjv_defaultScene :: proc(scn: ^vScene) ---

	// Allocate resources in abstract scene.
	mjv_makeScene :: proc(m: ^Model, scn: ^vScene, maxgeom: i32) ---

	// Free abstract scene.
	mjv_freeScene :: proc(scn: ^vScene) ---

	// Update entire scene given model state.
	mjv_updateScene :: proc(m: ^Model, d: ^Data, opt: ^vOption, pert: ^vPerturb, cam: ^vCamera, catmask: tCatBit, scn: ^vScene) ---

	// Copy mjModel, skip large arrays not required for abstract visualization.
	// Nullable: dest
	mjv_copyModel :: proc(dest: ^Model, src: ^Model) ---

	// Add geoms from selected categories.
	mjv_addGeoms :: proc(m: ^Model, d: ^Data, opt: ^vOption, pert: ^vPerturb, catmask: tCatBit, scn: ^vScene) ---

	// Make list of lights.
	mjv_makeLights :: proc(m: ^Model, d: ^Data, scn: ^vScene) ---

	// Update camera.
	mjv_updateCamera :: proc(m: ^Model, d: ^Data, cam: ^vCamera, scn: ^vScene) ---

	// Update skins.
	mjv_updateSkin :: proc(m: ^Model, d: ^Data, scn: ^vScene) ---

	// Compute camera position and forward, up, and right vectors.
	// Nullable: headpos, forward, up, right
	mjv_cameraFrame :: proc(headpos: ^[3]f64, forward: ^[3]f64, up: ^[3]f64, right: ^[3]f64, d: ^Data, cam: ^vCamera) ---

	// Compute camera frustum: vertical, horizontal, and clip planes.
	// Nullable: zver, zhor, zclip
	mjv_cameraFrustum :: proc(zver: ^[2]f32, zhor: ^[2]f32, zclip: ^[2]f32, m: ^Model, cam: ^vCamera) ---

	// Set default mjrContext.
	mjr_defaultContext :: proc(con: ^rContext) ---

	// Allocate resources in custom OpenGL context; fontscale is mjtFontScale.
	mjr_makeContext :: proc(m: ^Model, con: ^rContext, fontscale: i32) ---

	// Change font of existing context.
	mjr_changeFont :: proc(fontscale: i32, con: ^rContext) ---

	// Add Aux buffer with given index to context; free previous Aux buffer.
	mjr_addAux :: proc(index: i32, width: i32, height: i32, samples: i32, con: ^rContext) ---

	// Free resources in custom OpenGL context, set to default.
	mjr_freeContext :: proc(con: ^rContext) ---

	// Resize offscreen buffers.
	mjr_resizeOffscreen :: proc(width: i32, height: i32, con: ^rContext) ---

	// Upload texture to GPU, overwriting previous upload if any.
	mjr_uploadTexture :: proc(m: ^Model, con: ^rContext, texid: i32) ---

	// Upload mesh to GPU, overwriting previous upload if any.
	mjr_uploadMesh :: proc(m: ^Model, con: ^rContext, meshid: i32) ---

	// Upload height field to GPU, overwriting previous upload if any.
	mjr_uploadHField :: proc(m: ^Model, con: ^rContext, hfieldid: i32) ---

	// Make con->currentBuffer current again.
	mjr_restoreBuffer :: proc(con: ^rContext) ---

	// Set OpenGL framebuffer for rendering: mjFB_WINDOW or mjFB_OFFSCREEN.
	// If only one buffer is available, set that buffer and ignore framebuffer argument.
	mjr_setBuffer :: proc(framebuffer: i32, con: ^rContext) ---

	// Read pixels from current OpenGL framebuffer to client buffer.
	// Viewport is in OpenGL framebuffer; client buffer starts at (0,0).
	mjr_readPixels :: proc(rgb: ^u8, depth: ^f32, viewport: rRect, con: ^rContext) ---

	// Draw pixels from client buffer to current OpenGL framebuffer.
	// Viewport is in OpenGL framebuffer; client buffer starts at (0,0).
	mjr_drawPixels :: proc(rgb: ^u8, depth: ^f32, viewport: rRect, con: ^rContext) ---

	// Blit from src viewpoint in current framebuffer to dst viewport in other framebuffer.
	// If src, dst have different size and flg_depth==0, color is interpolated with GL_LINEAR.
	mjr_blitBuffer :: proc(src: rRect, dst: rRect, flg_color: i32, flg_depth: i32, con: ^rContext) ---

	// Set Aux buffer for custom OpenGL rendering (call restoreBuffer when done).
	mjr_setAux :: proc(index: i32, con: ^rContext) ---

	// Blit from Aux buffer to con->currentBuffer.
	mjr_blitAux :: proc(index: i32, src: rRect, left: i32, bottom: i32, con: ^rContext) ---

	// Draw text at (x,y) in relative coordinates; font is mjtFont.
	mjr_text :: proc(font: i32, txt: cstring, con: ^rContext, x: f32, y: f32, r: f32, g: f32, b: f32) ---

	// Draw text overlay; font is mjtFont; gridpos is mjtGridPos.
	mjr_overlay :: proc(font: i32, gridpos: i32, viewport: rRect, overlay: cstring, overlay2: cstring, con: ^rContext) ---

	// Get maximum viewport for active buffer.
	mjr_maxViewport :: proc(con: ^rContext) -> rRect ---

	// Draw rectangle.
	mjr_rectangle :: proc(viewport: rRect, r: f32, g: f32, b: f32, a: f32) ---

	// Draw rectangle with centered text.
	mjr_label :: proc(viewport: rRect, font: i32, txt: cstring, r: f32, g: f32, b: f32, a: f32, rt: f32, gt: f32, bt: f32, con: ^rContext) ---

	// Draw 2D figure.
	mjr_figure :: proc(viewport: rRect, fig: ^vFigure, con: ^rContext) ---

	// Render 3D scene.
	mjr_render :: proc(viewport: rRect, scn: ^vScene, con: ^rContext) ---

	// Call glFinish.
	mjr_finish :: proc() ---

	// Call glGetError and return result.
	mjr_getError :: proc() -> i32 ---

	// Find first rectangle containing mouse, -1: not found.
	mjr_findRect :: proc(x: i32, y: i32, nrect: i32, rect: ^rRect) -> i32 ---

	// Get builtin UI theme spacing (ind: 0-1).
	mjui_themeSpacing :: proc(ind: i32) -> uiThemeSpacing ---

	// Get builtin UI theme color (ind: 0-3).
	mjui_themeColor :: proc(ind: i32) -> uiThemeColor ---

	// Add definitions to UI.
	mjui_add :: proc(ui: ^UI, def: ^uiDef) ---

	// Add definitions to UI section.
	mjui_addToSection :: proc(ui: ^UI, sect: i32, def: ^uiDef) ---

	// Compute UI sizes.
	mjui_resize :: proc(ui: ^UI, con: ^rContext) ---

	// Update specific section/item; -1: update all.
	mjui_update :: proc(section: i32, item: i32, ui: ^UI, state: ^uiState, con: ^rContext) ---

	// Handle UI event; return pointer to changed item, NULL if no change.
	mjui_event :: proc(ui: ^UI, state: ^uiState, con: ^rContext) -> ^uiItem ---

	// Copy UI image to current buffer.
	mjui_render :: proc(ui: ^UI, state: ^uiState, con: ^rContext) ---

	// Main error function; does not return to caller.
	mju_error :: proc(msg: cstring, #c_vararg _: ..any) ---

	// Deprecated: use mju_error.
	mju_error_i :: proc(msg: cstring, i: i32) ---

	// Deprecated: use mju_error.
	mju_error_s :: proc(msg: cstring, text: cstring) ---

	// Main warning function; returns to caller.
	mju_warning :: proc(msg: cstring, #c_vararg _: ..any) ---

	// Deprecated: use mju_warning.
	mju_warning_i :: proc(msg: cstring, i: i32) ---

	// Deprecated: use mju_warning.
	mju_warning_s :: proc(msg: cstring, text: cstring) ---

	// Clear user error and memory handlers.
	mju_clearHandlers :: proc() ---

	// Allocate memory; byte-align on 64; pad size to multiple of 64.
	mju_malloc :: proc(size: c.size_t) -> rawptr ---

	// Free memory, using free() by default.
	mju_free :: proc(ptr: rawptr) ---

	// Write [datetime, type: message] to MUJOCO_LOG.TXT.
	mju_writeLog :: proc(type: cstring, msg: cstring) ---

	// Get compiler error message from spec.
	mjs_getError :: proc(s: ^Spec) -> cstring ---

	// Return 1 if compiler error is a warning.
	mjs_isWarning :: proc(s: ^Spec) -> b32 ---

	// Set res = 0.
	mju_zero3 :: proc(res: ^[3]f64) ---

	// Set res = vec.
	mju_copy3 :: proc(res: ^[3]f64, data: ^[3]f64) ---

	// Set res = vec*scl.
	mju_scl3 :: proc(res: ^[3]f64, vec: ^[3]f64, scl: f64) ---

	// Set res = vec1 + vec2.
	mju_add3 :: proc(res: ^[3]f64, vec1: ^[3]f64, vec2: ^[3]f64) ---

	// Set res = vec1 - vec2.
	mju_sub3 :: proc(res: ^[3]f64, vec1: ^[3]f64, vec2: ^[3]f64) ---

	// Set res = res + vec.
	mju_addTo3 :: proc(res: ^[3]f64, vec: ^[3]f64) ---

	// Set res = res - vec.
	mju_subFrom3 :: proc(res: ^[3]f64, vec: ^[3]f64) ---

	// Set res = res + vec*scl.
	mju_addToScl3 :: proc(res: ^[3]f64, vec: ^[3]f64, scl: f64) ---

	// Set res = vec1 + vec2*scl.
	mju_addScl3 :: proc(res: ^[3]f64, vec1: ^[3]f64, vec2: ^[3]f64, scl: f64) ---

	// Normalize vector; return length before normalization.
	mju_normalize3 :: proc(vec: ^[3]f64) -> f64 ---

	// Return vector length (without normalizing the vector).
	mju_norm3 :: proc(vec: ^[3]f64) -> f64 ---

	// Return dot-product of vec1 and vec2.
	mju_dot3 :: proc(vec1: ^[3]f64, vec2: ^[3]f64) -> f64 ---

	// Return Cartesian distance between 3D vectors pos1 and pos2.
	mju_dist3 :: proc(pos1: ^[3]f64, pos2: ^[3]f64) -> f64 ---

	// Multiply 3-by-3 matrix by vector: res = mat * vec.
	mju_mulMatVec3 :: proc(res: ^[3]f64, mat: ^[9]f64, vec: ^[3]f64) ---

	// Multiply transposed 3-by-3 matrix by vector: res = mat' * vec.
	mju_mulMatTVec3 :: proc(res: ^[3]f64, mat: ^[9]f64, vec: ^[3]f64) ---

	// Compute cross-product: res = cross(a, b).
	mju_cross :: proc(res: ^[3]f64, a: ^[3]f64, b: ^[3]f64) ---

	// Set res = 0.
	mju_zero4 :: proc(res: ^[4]f64) ---

	// Set res = (1,0,0,0).
	mju_unit4 :: proc(res: ^[4]f64) ---

	// Set res = vec.
	mju_copy4 :: proc(res: ^[4]f64, data: ^[4]f64) ---

	// Normalize vector; return length before normalization.
	mju_normalize4 :: proc(vec: ^[4]f64) -> f64 ---

	// Set res = 0.
	mju_zero :: proc(res: ^f64, n: i32) ---

	// Set res = val.
	mju_fill :: proc(res: ^f64, val: f64, n: i32) ---

	// Set res = vec.
	mju_copy :: proc(res: ^f64, vec: ^f64, n: i32) ---

	// Return sum(vec).
	mju_sum :: proc(vec: ^f64, n: i32) -> f64 ---

	// Return L1 norm: sum(abs(vec)).
	mju_L1 :: proc(vec: ^f64, n: i32) -> f64 ---

	// Set res = vec*scl.
	mju_scl :: proc(res: ^f64, vec: ^f64, scl: f64, n: i32) ---

	// Set res = vec1 + vec2.
	mju_add :: proc(res: ^f64, vec1: ^f64, vec2: ^f64, n: i32) ---

	// Set res = vec1 - vec2.
	mju_sub :: proc(res: ^f64, vec1: ^f64, vec2: ^f64, n: i32) ---

	// Set res = res + vec.
	mju_addTo :: proc(res: ^f64, vec: ^f64, n: i32) ---

	// Set res = res - vec.
	mju_subFrom :: proc(res: ^f64, vec: ^f64, n: i32) ---

	// Set res = res + vec*scl.
	mju_addToScl :: proc(res: ^f64, vec: ^f64, scl: f64, n: i32) ---

	// Set res = vec1 + vec2*scl.
	mju_addScl :: proc(res: ^f64, vec1: ^f64, vec2: ^f64, scl: f64, n: i32) ---

	// Normalize vector; return length before normalization.
	mju_normalize :: proc(res: ^f64, n: i32) -> f64 ---

	// Return vector length (without normalizing vector).
	mju_norm :: proc(res: ^f64, n: i32) -> f64 ---

	// Return dot-product of vec1 and vec2.
	mju_dot :: proc(vec1: ^f64, vec2: ^f64, n: i32) -> f64 ---

	// Multiply matrix and vector: res = mat * vec.
	mju_mulMatVec :: proc(res: ^f64, mat: ^f64, vec: ^f64, nr: i32, nc: i32) ---

	// Multiply transposed matrix and vector: res = mat' * vec.
	mju_mulMatTVec :: proc(res: ^f64, mat: ^f64, vec: ^f64, nr: i32, nc: i32) ---

	// Multiply square matrix with vectors on both sides: return vec1' * mat * vec2.
	mju_mulVecMatVec :: proc(vec1: ^f64, mat: ^f64, vec2: ^f64, n: i32) -> f64 ---

	// Transpose matrix: res = mat'.
	mju_transpose :: proc(res: ^f64, mat: ^f64, nr: i32, nc: i32) ---

	// Symmetrize square matrix res = (mat + mat')/2.
	mju_symmetrize :: proc(res: ^f64, mat: ^f64, n: i32) ---

	// Set mat to the identity matrix.
	mju_eye :: proc(mat: ^f64, n: i32) ---

	// Multiply matrices: res = mat1 * mat2.
	mju_mulMatMat :: proc(res: ^f64, mat1: ^f64, mat2: ^f64, r1: i32, c1: i32, c2: i32) ---

	// Multiply matrices, second argument transposed: res = mat1 * mat2'.
	mju_mulMatMatT :: proc(res: ^f64, mat1: ^f64, mat2: ^f64, r1: i32, c1: i32, r2: i32) ---

	// Multiply matrices, first argument transposed: res = mat1' * mat2.
	mju_mulMatTMat :: proc(res: ^f64, mat1: ^f64, mat2: ^f64, r1: i32, c1: i32, c2: i32) ---

	// Set res = mat' * diag * mat if diag is not NULL, and res = mat' * mat otherwise.
	mju_sqrMatTD :: proc(res: ^f64, mat: ^f64, diag: ^f64, nr: i32, nc: i32) ---

	// Coordinate transform of 6D motion or force vector in rotation:translation format.
	// rotnew2old is 3-by-3, NULL means no rotation; flg_force specifies force or motion type.
	// Nullable: rotnew2old
	mju_transformSpatial :: proc(res: ^[6]f64, vec: ^[6]f64, flg_force: i32, newpos: ^[3]f64, oldpos: ^[3]f64, rotnew2old: ^[9]f64) ---

	// Convert matrix from dense to sparse.
	//  nnz is size of res and colind; return 1 if too small, 0 otherwise.
	mju_dense2sparse :: proc(res: ^f64, mat: ^f64, nr: i32, nc: i32, rownnz: ^i32, rowadr: ^i32, colind: ^i32, nnz: i32) -> i32 ---

	// Convert matrix from sparse to dense.
	mju_sparse2dense :: proc(res: ^f64, mat: ^f64, nr: i32, nc: i32, rownnz: ^i32, rowadr: ^i32, colind: ^i32) ---

	// Rotate vector by quaternion.
	mju_rotVecQuat :: proc(res: ^[3]f64, vec: ^[3]f64, quat: ^[4]f64) ---

	// Conjugate quaternion, corresponding to opposite rotation.
	mju_negQuat :: proc(res: ^[4]f64, quat: ^[4]f64) ---

	// Multiply quaternions.
	mju_mulQuat :: proc(res: ^[4]f64, quat1: ^[4]f64, quat2: ^[4]f64) ---

	// Multiply quaternion and axis.
	mju_mulQuatAxis :: proc(res: ^[4]f64, quat: ^[4]f64, axis: ^[3]f64) ---

	// Convert axisAngle to quaternion.
	mju_axisAngle2Quat :: proc(res: ^[4]f64, axis: ^[3]f64, angle: f64) ---

	// Convert quaternion (corresponding to orientation difference) to 3D velocity.
	mju_quat2Vel :: proc(res: ^[3]f64, quat: ^[4]f64, dt: f64) ---

	// Subtract quaternions, express as 3D velocity: qb*quat(res) = qa.
	mju_subQuat :: proc(res: ^[3]f64, qa: ^[4]f64, qb: ^[4]f64) ---

	// Convert quaternion to 3D rotation matrix.
	mju_quat2Mat :: proc(res: ^[9]f64, quat: ^[4]f64) ---

	// Convert 3D rotation matrix to quaternion.
	mju_mat2Quat :: proc(quat: ^[4]f64, mat: ^[9]f64) ---

	// Compute time-derivative of quaternion, given 3D rotational velocity.
	mju_derivQuat :: proc(res: ^[4]f64, quat: ^[4]f64, vel: ^[3]f64) ---

	// Integrate quaternion given 3D angular velocity.
	mju_quatIntegrate :: proc(quat: ^[4]f64, vel: ^[3]f64, scale: f64) ---

	// Construct quaternion performing rotation from z-axis to given vector.
	mju_quatZ2Vec :: proc(quat: ^[4]f64, vec: ^[3]f64) ---

	// Extract 3D rotation from an arbitrary 3x3 matrix by refining the input quaternion.
	// Return the number of iterations required to converge.
	mju_mat2Rot :: proc(quat: ^[4]f64, mat: ^[9]f64) -> i32 ---

	// Convert sequence of Euler angles (radians) to quaternion.
	// seq[0,1,2] must be in 'xyzXYZ', lower/upper-case mean intrinsic/extrinsic rotations.
	mju_euler2Quat :: proc(quat: ^[4]f64, euler: ^[3]f64, seq: cstring) ---

	// Multiply two poses.
	mju_mulPose :: proc(posres: ^[3]f64, quatres: ^[4]f64, pos1: ^[3]f64, quat1: ^[4]f64, pos2: ^[3]f64, quat2: ^[4]f64) ---

	// Conjugate pose, corresponding to the opposite spatial transformation.
	mju_negPose :: proc(posres: ^[3]f64, quatres: ^[4]f64, pos: ^[3]f64, quat: ^[4]f64) ---

	// Transform vector by pose.
	mju_trnVecPose :: proc(res: ^[3]f64, pos: ^[3]f64, quat: ^[4]f64, vec: ^[3]f64) ---

	// Cholesky decomposition: mat = L*L'; return rank, decomposition performed in-place into mat.
	mju_cholFactor :: proc(mat: ^f64, n: i32, mindiag: f64) -> i32 ---

	// Solve (mat*mat') * res = vec, where mat is a Cholesky factor.
	mju_cholSolve :: proc(res: ^f64, mat: ^f64, vec: ^f64, n: i32) ---

	// Cholesky rank-one update: L*L' +/- x*x'; return rank.
	mju_cholUpdate :: proc(mat: ^f64, x: ^f64, n: i32, flg_plus: i32) -> i32 ---

	// Band-dense Cholesky decomposition.
	//  Return minimum value in the factorized diagonal, or 0 if rank-deficient.
	//  mat has (ntotal-ndense) x nband + ndense x ntotal elements.
	//  The first (ntotal-ndense) x nband store the band part, left of diagonal, inclusive.
	//  The second ndense x ntotal store the band part as entire dense rows.
	//  Add diagadd+diagmul*mat_ii to diagonal before factorization.
	mju_cholFactorBand :: proc(mat: ^f64, ntotal: i32, nband: i32, ndense: i32, diagadd: f64, diagmul: f64) -> f64 ---

	// Solve (mat*mat')*res = vec where mat is a band-dense Cholesky factor.
	mju_cholSolveBand :: proc(res: ^f64, mat: ^f64, vec: ^f64, ntotal: i32, nband: i32, ndense: i32) ---

	// Convert banded matrix to dense matrix, fill upper triangle if flg_sym>0.
	mju_band2Dense :: proc(res: ^f64, mat: ^f64, ntotal: i32, nband: i32, ndense: i32, flg_sym: b8) ---

	// Convert dense matrix to banded matrix.
	mju_dense2Band :: proc(res: ^f64, mat: ^f64, ntotal: i32, nband: i32, ndense: i32) ---

	// Multiply band-diagonal matrix with nvec vectors, include upper triangle if flg_sym>0.
	mju_bandMulMatVec :: proc(res: ^f64, mat: ^f64, vec: ^f64, ntotal: i32, nband: i32, ndense: i32, nvec: i32, flg_sym: b8) ---

	// Address of diagonal element i in band-dense matrix representation.
	mju_bandDiag :: proc(i: i32, ntotal: i32, nband: i32, ndense: i32) -> i32 ---

	// Eigenvalue decomposition of symmetric 3x3 matrix, mat = eigvec * diag(eigval) * eigvec'.
	mju_eig3 :: proc(eigval: ^[3]f64, eigvec: ^[9]f64, quat: ^[4]f64, mat: ^[9]f64) -> i32 ---

	// minimize 0.5*x'*H*x + x'*g  s.t. lower <= x <= upper; return rank or -1 if failed
	//   inputs:
	//     n           - problem dimension
	//     H           - SPD matrix                n*n
	//     g           - bias vector               n
	//     lower       - lower bounds              n
	//     upper       - upper bounds              n
	//     res         - solution warmstart        n
	//   return value:
	//     nfree <= n  - rank of unconstrained subspace, -1 if failure
	//   outputs (required):
	//     res         - solution                  n
	//     R           - subspace Cholesky factor  nfree*nfree    allocated: n*(n+7)
	//   outputs (optional):
	//     index       - set of free dimensions    nfree          allocated: n
	//   notes:
	//     the initial value of res is used to warmstart the solver
	//     R must have allocatd size n*(n+7), but only nfree*nfree values are used in output
	//     index (if given) must have allocated size n, but only nfree values are used in output
	//     only the lower triangles of H and R and are read from and written to, respectively
	//     the convenience function mju_boxQPmalloc allocates the required data structures
	// Nullable: index, lower, upper
	mju_boxQP :: proc(res: ^f64, R: ^f64, index: ^i32, H: ^f64, g: ^f64, n: i32, lower: ^f64, upper: ^f64) -> i32 ---

	// allocate heap memory for box-constrained Quadratic Program
	//   as in mju_boxQP, index, lower, and upper are optional
	//   free all pointers with mju_free()
	mju_boxQPmalloc :: proc(res: ^^f64, R: ^^f64, index: ^^i32, H: ^^f64, g: ^^f64, n: i32, lower: ^^f64, upper: ^^f64) ---

	// Muscle active force, prm = (range[2], force, scale, lmin, lmax, vmax, fpmax, fvmax).
	mju_muscleGain :: proc(len: f64, vel: f64, lengthrange: ^[2]f64, acc0: f64, prm: ^[9]f64) -> f64 ---

	// Muscle passive force, prm = (range[2], force, scale, lmin, lmax, vmax, fpmax, fvmax).
	mju_muscleBias :: proc(len: f64, lengthrange: ^[2]f64, acc0: f64, prm: ^[9]f64) -> f64 ---

	// Muscle activation dynamics, prm = (tau_act, tau_deact, smoothing_width).
	mju_muscleDynamics :: proc(ctrl: f64, act: f64, prm: ^[3]f64) -> f64 ---

	// Convert contact force to pyramid representation.
	mju_encodePyramid :: proc(pyramid: ^f64, force: ^f64, mu: ^f64, dim: i32) ---

	// Convert pyramid representation to contact force.
	mju_decodePyramid :: proc(force: ^f64, pyramid: ^f64, mu: ^f64, dim: i32) ---

	// Integrate spring-damper analytically; return pos(dt).
	mju_springDamper :: proc(pos0: f64, vel0: f64, Kp: f64, Kv: f64, dt: f64) -> f64 ---

	// Return min(a,b) with single evaluation of a and b.
	mju_min :: proc(a: f64, b: f64) -> f64 ---

	// Return max(a,b) with single evaluation of a and b.
	mju_max :: proc(a: f64, b: f64) -> f64 ---

	// Clip x to the range [min, max].
	mju_clip :: proc(x: f64, min: f64, max: f64) -> f64 ---

	// Return sign of x: +1, -1 or 0.
	mju_sign :: proc(x: f64) -> f64 ---

	// Round x to nearest integer.
	mju_round :: proc(x: f64) -> i32 ---

	// Convert type id (mjtObj) to type name.
	mju_type2Str :: proc(type: tObj) -> cstring ---

	// Convert type name to type id (mjtObj).
	mju_str2Type :: proc(str: cstring) -> tObj ---

	// Return human readable number of bytes using standard letter suffix.
	mju_writeNumBytes :: proc(nbytes: c.size_t) -> cstring ---

	// Construct a warning message given the warning type and info.
	mju_warningText :: proc(warning: i32, info: c.size_t) -> cstring ---

	// Return 1 if nan or abs(x)>mjMAXVAL, 0 otherwise. Used by check functions.
	mju_isBad :: proc(x: f64) -> b32 ---

	// Return 1 if all elements are 0.
	mju_isZero :: proc(vec: ^f64, n: i32) -> b32 ---

	// Standard normal random number generator (optional second number).
	mju_standardNormal :: proc(num2: ^f64) -> f64 ---

	// Convert from float to mjtNum.
	mju_f2n :: proc(res: ^f64, vec: ^f32, n: i32) ---

	// Convert from mjtNum to float.
	mju_n2f :: proc(res: ^f32, vec: ^f64, n: i32) ---

	// Convert from double to mjtNum.
	mju_d2n :: proc(res: ^f64, vec: ^f64, n: i32) ---

	// Convert from mjtNum to double.
	mju_n2d :: proc(res: ^f64, vec: ^f64, n: i32) ---

	// Insertion sort, resulting list is in increasing order.
	mju_insertionSort :: proc(list: ^f64, n: i32) ---

	// Integer insertion sort, resulting list is in increasing order.
	mju_insertionSortInt :: proc(list: ^i32, n: i32) ---

	// Generate Halton sequence.
	mju_Halton :: proc(index: i32, base: i32) -> f64 ---

	// Call strncpy, then set dst[n-1] = 0.
	mju_strncpy :: proc(dst: cstring, src: cstring, n: i32) -> cstring ---

	// Sigmoid function over 0<=x<=1 using quintic polynomial.
	mju_sigmoid :: proc(x: f64) -> f64 ---

	// get sdf from geom id
	mjc_getSDF :: proc(m: ^Model, id: i32) -> ^pPlugin ---

	// signed distance function
	mjc_distance :: proc(m: ^Model, d: ^Data, s: ^SDF, x: ^[3]f64) -> f64 ---

	// gradient of sdf
	mjc_gradient :: proc(m: ^Model, d: ^Data, s: ^SDF, gradient: ^[3]f64, x: ^[3]f64) ---

	// Finite differenced transition matrices (control theory notation)
	//   d(x_next) = A*dx + B*du
	//   d(sensor) = C*dx + D*du
	//   required output matrix dimensions:
	//      A: (2*nv+na x 2*nv+na)
	//      B: (2*nv+na x nu)
	//      D: (nsensordata x 2*nv+na)
	//      C: (nsensordata x nu)
	// Nullable: A, B, C, D
	mjd_transitionFD :: proc(m: ^Model, d: ^Data, eps: f64, flg_centered: b8, A: ^f64, B: ^f64, C: ^f64, D: ^f64) ---

	// Finite differenced Jacobians of (force, sensors) = mj_inverse(state, acceleration)
	//   All outputs are optional. Output dimensions (transposed w.r.t Control Theory convention):
	//     DfDq: (nv x nv)
	//     DfDv: (nv x nv)
	//     DfDa: (nv x nv)
	//     DsDq: (nv x nsensordata)
	//     DsDv: (nv x nsensordata)
	//     DsDa: (nv x nsensordata)
	//     DmDq: (nv x nM)
	//   single-letter shortcuts:
	//     inputs: q=qpos, v=qvel, a=qacc
	//     outputs: f=qfrc_inverse, s=sensordata, m=qM
	//   notes:
	//     optionally computes mass matrix Jacobian DmDq
	//     flg_actuation specifies whether to subtract qfrc_actuator from qfrc_inverse
	// Nullable: DfDq, DfDv, DfDa, DsDq, DsDv, DsDa, DmDq
	mjd_inverseFD :: proc(m: ^Model, d: ^Data, eps: f64, flg_actuation: b8, DfDq: ^f64, DfDv: ^f64, DfDa: ^f64, DsDq: ^f64, DsDv: ^f64, DsDa: ^f64, DmDq: ^f64) ---

	// Derivatives of mju_subQuat.
	// Nullable: Da, Db
	mjd_subQuat :: proc(qa: ^[4]f64, qb: ^[4]f64, Da: ^[9]f64, Db: ^[9]f64) ---

	// Derivatives of mju_quatIntegrate.
	// Nullable: Dquat, Dvel, Dscale
	mjd_quatIntegrate :: proc(vel: ^[3]f64, scale: f64, Dquat: ^[9]f64, Dvel: ^[9]f64, Dscale: ^[3]f64) ---

	// Set default plugin definition.
	mjp_defaultPlugin :: proc(plugin: ^pPlugin) ---

	// Globally register a plugin. This function is thread-safe.
	// If an identical mjpPlugin is already registered, this function does nothing.
	// If a non-identical mjpPlugin with the same name is already registered, an mju_error is raised.
	// Two mjpPlugins are considered identical if all member function pointers and numbers are equal,
	// and the name and attribute strings are all identical, however the char pointers to the strings
	// need not be the same.
	mjp_registerPlugin :: proc(plugin: ^pPlugin) -> i32 ---

	// Return the number of globally registered plugins.
	mjp_pluginCount :: proc() -> i32 ---

	// Look up a plugin by name. If slot is not NULL, also write its registered slot number into it.
	mjp_getPlugin :: proc(name: cstring, slot: ^i32) -> ^pPlugin ---

	// Look up a plugin by the registered slot number that was returned by mjp_registerPlugin.
	mjp_getPluginAtSlot :: proc(slot: i32) -> ^pPlugin ---

	// Set default resource provider definition.
	mjp_defaultResourceProvider :: proc(provider: ^pResourceProvider) ---

	// Globally register a resource provider in a thread-safe manner. The provider must have a prefix
	// that is not a sub-prefix or super-prefix of any current registered providers.
	// Return a slot number >= 0 on success, -1 on failure.
	mjp_registerResourceProvider :: proc(provider: ^pResourceProvider) -> i32 ---

	// Return the number of globally registered resource providers.
	mjp_resourceProviderCount :: proc() -> i32 ---

	// Return the resource provider with the prefix that matches against the resource name.
	// If no match, return NULL.
	mjp_getResourceProvider :: proc(resource_name: cstring) -> ^pResourceProvider ---

	// Look up a resource provider by slot number returned by mjp_registerResourceProvider.
	// If invalid slot number, return NULL.
	mjp_getResourceProviderAtSlot :: proc(slot: i32) -> ^pResourceProvider ---

	// Globally register a decoder. This function is thread-safe.
	// If an identical mjpDecoder is already registered, this function does nothing.
	// If a non-identical mjpDecoder with the same name is already registered, an mju_error is raised.
	mjp_registerDecoder :: proc(decoder: ^pDecoder) ---

	// Set default resource decoder definition.
	mjp_defaultDecoder :: proc(decoder: ^pDecoder) ---

	// Return the resource provider with the prefix that matches against the resource name.
	// If no match, return NULL.
	mjp_findDecoder :: proc(resource: ^Resource, content_type: cstring) -> ^pDecoder ---

	// Globally register an encoder. This function is thread-safe.
	// If an identical mjpEncoder is already registered, this function does nothing.
	// If a non-identical mjpEncoder with the same name is already registered, an mju_error is raised.
	mjp_registerEncoder :: proc(encoder: ^pEncoder) ---

	// Set default resource encoder definition.
	mjp_defaultEncoder :: proc(encoder: ^pEncoder) ---

	// Return the encoder that matches against the content type or filename extension.
	// If no match, return NULL.
	mjp_findEncoder :: proc(filename: cstring, content_type: cstring) -> ^pEncoder ---

	// Open a resource; if the name doesn't have a prefix matching a registered resource provider,
	// then the OS filesystem is used.
	// Nullable: dir, vfs, error
	mju_openResource :: proc(dir: cstring, name: cstring, vfs: ^VFS, error: cstring, nerror: c.size_t) -> ^Resource ---

	// Close a resource; no-op if resource is NULL.
	mju_closeResource :: proc(resource: ^Resource) ---

	// Set buffer to bytes read from the resource and return number of bytes in buffer;
	// return negative value if error.
	mju_readResource :: proc(resource: ^Resource, buffer: ^rawptr) -> i32 ---

	// For a resource with a name partitioned as {dir}{filename}, get the dir and ndir pointers.
	mju_getResourceDir :: proc(resource: ^Resource, dir: ^cstring, ndir: ^i32) ---

	// Compare resource timestamp to provided timestamp.
	// Return 0 if timestamps match, >0 if resource is newer, <0 if resource is older.
	mju_isModifiedResource :: proc(resource: ^Resource, timestamp: cstring) -> i32 ---

	// Find the decoder for a resource and return the decoded spec.
	// The caller takes ownership of the spec and is responsible for cleaning it up.
	// Nullable: vfs
	mju_decodeResource :: proc(resource: ^Resource, content_type: cstring, vfs: ^VFS) -> ^Spec ---

	// Create a thread pool with the specified number of threads running.
	mju_threadPoolCreate :: proc(number_of_threads: c.size_t) -> ^ThreadPool ---

	// Adds a thread pool to mjData and configures it for multi-threaded use.
	mju_bindThreadPool :: proc(d: ^Data, thread_pool: rawptr) ---

	// Enqueue a task in a thread pool.
	mju_threadPoolEnqueue :: proc(thread_pool: ^ThreadPool, task: ^Task) ---

	// Destroy a thread pool.
	mju_threadPoolDestroy :: proc(thread_pool: ^ThreadPool) ---

	// Initialize an mjTask.
	mju_defaultTask :: proc(task: ^Task) ---

	// Wait for a task to complete.
	mju_taskJoin :: proc(task: ^Task) ---

	// Attach child to a parent; return the attached element if success or NULL otherwise.
	mjs_attach :: proc(parent: ^sElement, child: ^sElement, prefix: cstring, suffix: cstring) -> ^sElement ---

	// Add child body to body; return child.
	// Nullable: def
	mjs_addBody :: proc(body: ^sBody, def: ^sDefault) -> ^sBody ---

	// Add site to body; return site spec.
	// Nullable: def
	mjs_addSite :: proc(body: ^sBody, def: ^sDefault) -> ^sSite ---

	// Add joint to body.
	// Nullable: def
	mjs_addJoint :: proc(body: ^sBody, def: ^sDefault) -> ^sJoint ---

	// Add freejoint to body.
	mjs_addFreeJoint :: proc(body: ^sBody) -> ^sJoint ---

	// Add geom to body.
	// Nullable: def
	mjs_addGeom :: proc(body: ^sBody, def: ^sDefault) -> ^sGeom ---

	// Add camera to body.
	// Nullable: def
	mjs_addCamera :: proc(body: ^sBody, def: ^sDefault) -> ^sCamera ---

	// Add light to body.
	// Nullable: def
	mjs_addLight :: proc(body: ^sBody, def: ^sDefault) -> ^sLight ---

	// Add frame to body.
	mjs_addFrame :: proc(body: ^sBody, parentframe: ^sFrame) -> ^sFrame ---

	// Remove object corresponding to the given element; return 0 on success.
	mjs_delete :: proc(spec: ^Spec, element: ^sElement) -> i32 ---

	// Add actuator.
	// Nullable: def
	mjs_addActuator :: proc(s: ^Spec, def: ^sDefault) -> ^sActuator ---

	// Add sensor.
	mjs_addSensor :: proc(s: ^Spec) -> ^sSensor ---

	// Add flex.
	mjs_addFlex :: proc(s: ^Spec) -> ^sFlex ---

	// Add contact pair.
	// Nullable: def
	mjs_addPair :: proc(s: ^Spec, def: ^sDefault) -> ^sPair ---

	// Add excluded body pair.
	mjs_addExclude :: proc(s: ^Spec) -> ^sExclude ---

	// Add equality.
	// Nullable: def
	mjs_addEquality :: proc(s: ^Spec, def: ^sDefault) -> ^sEquality ---

	// Add tendon.
	// Nullable: def
	mjs_addTendon :: proc(s: ^Spec, def: ^sDefault) -> ^sTendon ---

	// Wrap site using tendon.
	mjs_wrapSite :: proc(tendon: ^sTendon, name: cstring) -> ^sWrap ---

	// Wrap geom using tendon.
	mjs_wrapGeom :: proc(tendon: ^sTendon, name: cstring, sidesite: cstring) -> ^sWrap ---

	// Wrap joint using tendon.
	mjs_wrapJoint :: proc(tendon: ^sTendon, name: cstring, coef: f64) -> ^sWrap ---

	// Wrap pulley using tendon.
	mjs_wrapPulley :: proc(tendon: ^sTendon, divisor: f64) -> ^sWrap ---

	// Add numeric.
	mjs_addNumeric :: proc(s: ^Spec) -> ^sNumeric ---

	// Add text.
	mjs_addText :: proc(s: ^Spec) -> ^sText ---

	// Add tuple.
	mjs_addTuple :: proc(s: ^Spec) -> ^sTuple ---

	// Add keyframe.
	mjs_addKey :: proc(s: ^Spec) -> ^sKey ---

	// Add plugin.
	mjs_addPlugin :: proc(s: ^Spec) -> ^sPlugin ---

	// Add default.
	// Nullable: parent
	mjs_addDefault :: proc(s: ^Spec, classname: cstring, parent: ^sDefault) -> ^sDefault ---

	// Set actuator to motor; return error if any.
	mjs_setToMotor :: proc(actuator: ^sActuator) -> cstring ---

	// Set actuator to position; return error if any.
	mjs_setToPosition :: proc(actuator: ^sActuator, kp: f64, kv: ^[1]f64, dampratio: ^[1]f64, timeconst: ^[1]f64, inheritrange: f64) -> cstring ---

	// Set actuator to integrated velocity; return error if any.
	mjs_setToIntVelocity :: proc(actuator: ^sActuator, kp: f64, kv: ^[1]f64, dampratio: ^[1]f64, timeconst: ^[1]f64, inheritrange: f64) -> cstring ---

	// Set actuator to velocity servo; return error if any.
	mjs_setToVelocity :: proc(actuator: ^sActuator, kv: f64) -> cstring ---

	// Set actuator to activate damper; return error if any.
	mjs_setToDamper :: proc(actuator: ^sActuator, kv: f64) -> cstring ---

	// Set actuator to hydraulic or pneumatic cylinder; return error if any.
	mjs_setToCylinder :: proc(actuator: ^sActuator, timeconst: f64, bias: f64, area: f64, diameter: f64) -> cstring ---

	// Set actuator to muscle; return error if any.a
	mjs_setToMuscle :: proc(actuator: ^sActuator, timeconst: ^[2]f64, tausmooth: f64, range: ^[2]f64, force: f64, scale: f64, lmin: f64, lmax: f64, vmax: f64, fpmax: f64, fvmax: f64) -> cstring ---

	// Set actuator to active adhesion; return error if any.
	mjs_setToAdhesion :: proc(actuator: ^sActuator, gain: f64) -> cstring ---

	// Set actuator to DC motor; return error if any.
	// Nullable: motorconst, nominal, saturation, inductance, cogging, controller, thermal, lugre
	mjs_setToDCMotor :: proc(actuator: ^sActuator, motorconst: ^[2]f64, resistance: f64, nominal: ^[3]f64, saturation: ^[3]f64, inductance: ^[2]f64, cogging: ^[3]f64, controller: ^[6]f64, thermal: ^[6]f64, lugre: ^[5]f64, input_mode: i32) -> cstring ---

	// Add mesh.
	// Nullable: def
	mjs_addMesh :: proc(s: ^Spec, def: ^sDefault) -> ^sMesh ---

	// Add height field.
	mjs_addHField :: proc(s: ^Spec) -> ^sHField ---

	// Add skin.
	mjs_addSkin :: proc(s: ^Spec) -> ^sSkin ---

	// Add texture.
	mjs_addTexture :: proc(s: ^Spec) -> ^sTexture ---

	// Add material.
	// Nullable: def
	mjs_addMaterial :: proc(s: ^Spec, def: ^sDefault) -> ^sMaterial ---

	// Sets the vertices and normals of a mesh.
	mjs_makeMesh :: proc(mesh: ^sMesh, builtin: tMeshBuiltin, params: ^f64, nparams: i32) -> i32 ---

	// Get spec from body.
	mjs_getSpec :: proc(element: ^sElement) -> ^Spec ---

	// Get compiler associated with element's origin spec.
	mjs_getCompiler :: proc(element: ^sElement) -> ^sCompiler ---

	// Find spec (model asset) by name.
	mjs_findSpec :: proc(spec: ^Spec, name: cstring) -> ^Spec ---

	// Find body in spec by name.
	mjs_findBody :: proc(s: ^Spec, name: cstring) -> ^sBody ---

	// Find element in spec by name.
	mjs_findElement :: proc(s: ^Spec, type: tObj, name: cstring) -> ^sElement ---

	// Find child body by name.
	mjs_findChild :: proc(body: ^sBody, name: cstring) -> ^sBody ---

	// Get parent body.
	mjs_getParent :: proc(element: ^sElement) -> ^sBody ---

	// Get parent frame.
	mjs_getFrame :: proc(element: ^sElement) -> ^sFrame ---

	// Find frame by name.
	mjs_findFrame :: proc(s: ^Spec, name: cstring) -> ^sFrame ---

	// Get default corresponding to an element.
	mjs_getDefault :: proc(element: ^sElement) -> ^sDefault ---

	// Find default in model by class name.
	mjs_findDefault :: proc(s: ^Spec, classname: cstring) -> ^sDefault ---

	// Get global default from model.
	mjs_getSpecDefault :: proc(s: ^Spec) -> ^sDefault ---

	// Get element id.
	mjs_getId :: proc(element: ^sElement) -> i32 ---

	// Return body's first child of given type. If recurse is nonzero, also search the body's subtree.
	mjs_firstChild :: proc(body: ^sBody, type: tObj, recurse: i32) -> ^sElement ---

	// Return body's next child of the same type; return NULL if child is last.
	// If recurse is nonzero, also search the body's subtree.
	mjs_nextChild :: proc(body: ^sBody, child: ^sElement, recurse: i32) -> ^sElement ---

	// Return spec's first element of selected type.
	mjs_firstElement :: proc(s: ^Spec, type: tObj) -> ^sElement ---

	// Return spec's next element; return NULL if element is last.
	mjs_nextElement :: proc(s: ^Spec, element: ^sElement) -> ^sElement ---

	// Get wrapped element in tendon path.
	mjs_getWrapTarget :: proc(wrap: ^sWrap) -> ^sElement ---

	// Get wrapped element side site in tendon path if it has one, nullptr otherwise.
	mjs_getWrapSideSite :: proc(wrap: ^sWrap) -> ^sSite ---

	// Get divisor of mjsWrap wrapping a puller.
	mjs_getWrapDivisor :: proc(wrap: ^sWrap) -> f64 ---

	// Get coefficient of mjsWrap wrapping a joint.
	mjs_getWrapCoef :: proc(wrap: ^sWrap) -> f64 ---

	// Set element's name; return 0 on success.
	mjs_setName :: proc(element: ^sElement, name: cstring) -> i32 ---

	// Copy buffer.
	mjs_setBuffer :: proc(dest: ^ByteVec, array: rawptr, size: i32) ---

	// Copy text to string.
	mjs_setString :: proc(dest: ^String, text: cstring) ---

	// Split text to entries and copy to string vector.
	mjs_setStringVec :: proc(dest: ^StringVec, text: cstring) ---

	// Set entry in string vector.
	mjs_setInStringVec :: proc(dest: ^StringVec, i: i32, text: cstring) -> b8 ---

	// Append text entry to string vector.
	mjs_appendString :: proc(dest: ^StringVec, text: cstring) ---

	// Copy int array to vector.
	mjs_setInt :: proc(dest: ^IntVec, array: ^i32, size: i32) ---

	// Append int array to vector of arrays.
	mjs_appendIntVec :: proc(dest: ^IntVecVec, array: ^i32, size: i32) ---

	// Copy float array to vector.
	mjs_setFloat :: proc(dest: ^FloatVec, array: ^f32, size: i32) ---

	// Append float array to vector of arrays.
	mjs_appendFloatVec :: proc(dest: ^FloatVecVec, array: ^f32, size: i32) ---

	// Copy double array to vector.
	mjs_setDouble :: proc(dest: ^DoubleVec, array: ^f64, size: i32) ---

	// Set plugin attributes.
	mjs_setPluginAttributes :: proc(plugin: ^sPlugin, attributes: rawptr) ---

	// Get element's name.
	mjs_getName :: proc(element: ^sElement) -> ^String ---

	// Get string contents.
	mjs_getString :: proc(source: ^String) -> cstring ---

	// Get double array contents and optionally its size.
	// Nullable: size
	mjs_getDouble :: proc(source: ^DoubleVec, size: ^i32) -> ^f64 ---

	// Get number of elements a tendon wraps.
	mjs_getWrapNum :: proc(tendonspec: ^sTendon) -> i32 ---

	// Get mjsWrap element at position i in the tendon path.
	mjs_getWrap :: proc(tendonspec: ^sTendon, i: i32) -> ^sWrap ---

	// Get plugin attributes.
	mjs_getPluginAttributes :: proc(plugin: ^sPlugin) -> rawptr ---

	// Set element's default.
	mjs_setDefault :: proc(element: ^sElement, def: ^sDefault) ---

	// Set element's enclosing frame; return 0 on success.
	mjs_setFrame :: proc(dest: ^sElement, frame: ^sFrame) -> i32 ---

	// Resolve alternative orientations to quat; return error if any.
	mjs_resolveOrientation :: proc(quat: ^[4]f64, degree: b8, sequence: cstring, orientation: ^sOrientation) -> cstring ---

	// Transform body into a frame.
	mjs_bodyToFrame :: proc(body: ^^sBody) -> ^sFrame ---

	// Set user payload, overriding the existing value for the specified key if present.
	mjs_setUserValue :: proc(element: ^sElement, key: cstring, data: rawptr) ---

	// Set user payload, overriding the existing value for the specified key if
	// present. This version differs from mjs_setUserValue in that it takes a
	// cleanup function that will be called when the user payload is deleted.
	mjs_setUserValueWithCleanup :: proc(element: ^sElement, key: cstring, data: rawptr, cleanup: proc "c" (_: rawptr)) ---

	// Return user payload or NULL if none found.
	mjs_getUserValue :: proc(element: ^sElement, key: cstring) -> rawptr ---

	// Delete user payload.
	mjs_deleteUserValue :: proc(element: ^sElement, key: cstring) ---

	// Return sensor dimension.
	mjs_sensorDim :: proc(sensor: ^sSensor) -> i32 ---

	// Default spec attributes.
	mjs_defaultSpec :: proc(spec: ^Spec) ---

	// Default orientation attributes.
	mjs_defaultOrientation :: proc(orient: ^sOrientation) ---

	// Default body attributes.
	mjs_defaultBody :: proc(body: ^sBody) ---

	// Default frame attributes.
	mjs_defaultFrame :: proc(frame: ^sFrame) ---

	// Default joint attributes.
	mjs_defaultJoint :: proc(joint: ^sJoint) ---

	// Default geom attributes.
	mjs_defaultGeom :: proc(geom: ^sGeom) ---

	// Default site attributes.
	mjs_defaultSite :: proc(site: ^sSite) ---

	// Default camera attributes.
	mjs_defaultCamera :: proc(camera: ^sCamera) ---

	// Default light attributes.
	mjs_defaultLight :: proc(light: ^sLight) ---

	// Default flex attributes.
	mjs_defaultFlex :: proc(flex: ^sFlex) ---

	// Default mesh attributes.
	mjs_defaultMesh :: proc(mesh: ^sMesh) ---

	// Default height field attributes.
	mjs_defaultHField :: proc(hfield: ^sHField) ---

	// Default skin attributes.
	mjs_defaultSkin :: proc(skin: ^sSkin) ---

	// Default texture attributes.
	mjs_defaultTexture :: proc(texture: ^sTexture) ---

	// Default material attributes.
	mjs_defaultMaterial :: proc(material: ^sMaterial) ---

	// Default pair attributes.
	mjs_defaultPair :: proc(pair: ^sPair) ---

	// Default equality attributes.
	mjs_defaultEquality :: proc(equality: ^sEquality) ---

	// Default tendon attributes.
	mjs_defaultTendon :: proc(tendon: ^sTendon) ---

	// Default actuator attributes.
	mjs_defaultActuator :: proc(actuator: ^sActuator) ---

	// Default sensor attributes.
	mjs_defaultSensor :: proc(sensor: ^sSensor) ---

	// Default numeric attributes.
	mjs_defaultNumeric :: proc(numeric: ^sNumeric) ---

	// Default text attributes.
	mjs_defaultText :: proc(text: ^sText) ---

	// Default tuple attributes.
	mjs_defaultTuple :: proc(tuple: ^sTuple) ---

	// Default keyframe attributes.
	mjs_defaultKey :: proc(key: ^sKey) ---

	// Default plugin attributes.
	mjs_defaultPlugin :: proc(plugin: ^sPlugin) ---

	// Safely cast an element as mjsBody, or return NULL if the element is not an mjsBody.
	mjs_asBody :: proc(element: ^sElement) -> ^sBody ---

	// Safely cast an element as mjsGeom, or return NULL if the element is not an mjsGeom.
	mjs_asGeom :: proc(element: ^sElement) -> ^sGeom ---

	// Safely cast an element as mjsJoint, or return NULL if the element is not an mjsJoint.
	mjs_asJoint :: proc(element: ^sElement) -> ^sJoint ---

	// Safely cast an element as mjsSite, or return NULL if the element is not an mjsSite.
	mjs_asSite :: proc(element: ^sElement) -> ^sSite ---

	// Safely cast an element as mjsCamera, or return NULL if the element is not an mjsCamera.
	mjs_asCamera :: proc(element: ^sElement) -> ^sCamera ---

	// Safely cast an element as mjsLight, or return NULL if the element is not an mjsLight.
	mjs_asLight :: proc(element: ^sElement) -> ^sLight ---

	// Safely cast an element as mjsFrame, or return NULL if the element is not an mjsFrame.
	mjs_asFrame :: proc(element: ^sElement) -> ^sFrame ---

	// Safely cast an element as mjsActuator, or return NULL if the element is not an mjsActuator.
	mjs_asActuator :: proc(element: ^sElement) -> ^sActuator ---

	// Safely cast an element as mjsSensor, or return NULL if the element is not an mjsSensor.
	mjs_asSensor :: proc(element: ^sElement) -> ^sSensor ---

	// Safely cast an element as mjsFlex, or return NULL if the element is not an mjsFlex.
	mjs_asFlex :: proc(element: ^sElement) -> ^sFlex ---

	// Safely cast an element as mjsPair, or return NULL if the element is not an mjsPair.
	mjs_asPair :: proc(element: ^sElement) -> ^sPair ---

	// Safely cast an element as mjsEquality, or return NULL if the element is not an mjsEquality.
	mjs_asEquality :: proc(element: ^sElement) -> ^sEquality ---

	// Safely cast an element as mjsExclude, or return NULL if the element is not an mjsExclude.
	mjs_asExclude :: proc(element: ^sElement) -> ^sExclude ---

	// Safely cast an element as mjsTendon, or return NULL if the element is not an mjsTendon.
	mjs_asTendon :: proc(element: ^sElement) -> ^sTendon ---

	// Safely cast an element as mjsNumeric, or return NULL if the element is not an mjsNumeric.
	mjs_asNumeric :: proc(element: ^sElement) -> ^sNumeric ---

	// Safely cast an element as mjsText, or return NULL if the element is not an mjsText.
	mjs_asText :: proc(element: ^sElement) -> ^sText ---

	// Safely cast an element as mjsTuple, or return NULL if the element is not an mjsTuple.
	mjs_asTuple :: proc(element: ^sElement) -> ^sTuple ---

	// Safely cast an element as mjsKey, or return NULL if the element is not an mjsKey.
	mjs_asKey :: proc(element: ^sElement) -> ^sKey ---

	// Safely cast an element as mjsMesh, or return NULL if the element is not an mjsMesh.
	mjs_asMesh :: proc(element: ^sElement) -> ^sMesh ---

	// Safely cast an element as mjsHField, or return NULL if the element is not an mjsHField.
	mjs_asHField :: proc(element: ^sElement) -> ^sHField ---

	// Safely cast an element as mjsSkin, or return NULL if the element is not an mjsSkin.
	mjs_asSkin :: proc(element: ^sElement) -> ^sSkin ---

	// Safely cast an element as mjsTexture, or return NULL if the element is not an mjsTexture.
	mjs_asTexture :: proc(element: ^sElement) -> ^sTexture ---

	// Safely cast an element as mjsMaterial, or return NULL if the element is not an mjsMaterial.
	mjs_asMaterial :: proc(element: ^sElement) -> ^sMaterial ---

	// Safely cast an element as mjsPlugin, or return NULL if the element is not an mjsPlugin.
	mjs_asPlugin :: proc(element: ^sElement) -> ^sPlugin ---
}
