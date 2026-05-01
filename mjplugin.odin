// Copyright 2022 DeepMind Technologies Limited
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

//---------------------------------- Resource Provider ---------------------------------------------
Resource :: struct {
	name:      cstring,            // name of resource (filename, etc)
	data:      rawptr,             // opaque data pointer
	vfs:       ^VFS,               // pointer to the VFS
	timestamp: [512]i8,            // timestamp of the resource
	provider:  ^pResourceProvider, // pointer to the provider
}

// callback for opening a resource, returns zero on failure
fOpenResource :: proc "c" (resource: ^Resource) -> i32

// callback for reading a resource
// return number of bytes stored in buffer, return -1 if error
fReadResource :: proc "c" (resource: ^Resource, buffer: ^rawptr) -> i32

// callback for closing a resource (responsible for freeing any allocated memory)
fCloseResource :: proc "c" (resource: ^Resource)

// callback for mounting a resource (provider), returns zero on failure
fMountResource :: proc "c" (resource: ^Resource) -> i32

// callback for unmounting a resource (provider), returns zero on failure
fUnmountResource :: proc "c" (resource: ^Resource) -> i32

// callback for checking if the current resource was modified from the time
// specified by the timestamp
// returns 0 if the resource's timestamp matches the provided timestamp
// returns > 0 if the resource is younger than the given timestamp
// returns < 0 if the resource is older than the given timestamp
fResourceModified :: proc "c" (resource: ^Resource, timestamp: cstring) -> i32

// struct describing a single resource provider
pResourceProvider :: struct {
	prefix:   cstring,           // prefix for match against a resource name
	open:     fOpenResource,     // opening callback
	read:     fReadResource,     // reading callback
	close:    fCloseResource,    // closing callback
	mount:    fMountResource,    // mounting callback (optional)
	unmount:  fUnmountResource,  // unmounting callback (optional)
	modified: fResourceModified, // resource modified callback (optional)
	data:     rawptr,            // opaque data pointer (resource invariant)
}

// function pointer types
// return an mjSpec representing the decoded resource.
fDecode :: proc "c" (resource: ^Resource, vfs: ^VFS) -> ^Spec

// return true if the given resource can be decoded.
fCanDecode :: proc "c" (resource: ^Resource) -> i32

// the struct defining the decoder plugin's interface
pDecoder :: struct {
	content_type: cstring,
	extension:    cstring,

	// user-facing functions
	can_decode: fCanDecode, // quickly check if this decoder can handle the resource
	decode:     fDecode,    // main decoding function
}

//---------------------------------- Encoder -------------------------------------------------------
fEncode :: proc "c" (s: ^Spec, m: ^Model, vfs: ^VFS, resource: ^Resource) -> i32

pEncoder :: struct {
	content_type:   cstring,
	extension:      cstring,
	encode:         fEncode,        //  Function to encode an mjSpec and mjModel to a mjResource.
	close_resource: fCloseResource, // Function to close/free the resource.
}

//---------------------------------- Plugins -------------------------------------------------------
tPluginCapabilityBit :: enum u32 {
	ACTUATOR = 1, // actuator forces
	SENSOR   = 2, // sensor measurements
	PASSIVE  = 4, // passive forces
	SDF      = 8, // signed distance fields
}

pPlugin :: struct {
	name:            cstring,  // globally unique name identifying the plugin
	nattribute:      i32,      // number of configuration attributes
	attributes:      ^cstring, // name of configuration attributes
	capabilityflags: i32,      // plugin capabilities: bitfield of mjtPluginCapabilityBit
	needstage:       i32,      // sensor computation stage (mjtStage)

	// number of mjtNums needed to store the state of a plugin instance (required)
	nstate: proc "c" (m: ^Model, instance: i32) -> i32,

	// dimension of the specified sensor's output (required only for sensor plugins)
	nsensordata: proc "c" (m: ^Model, instance: i32, sensor_id: i32) -> i32,

	// called when a new mjData is being created (required), returns 0 on success or -1 on failure
	init: proc "c" (m: ^Model, d: ^Data, instance: i32) -> i32,

	// called when an mjData is being freed (optional)
	destroy: proc "c" (d: ^Data, instance: i32),

	// called when an mjData is being copied (optional)
	copy: proc "c" (dest: ^Data, m: ^Model, src: ^Data, instance: i32),

	// called when an mjData is being reset (required)
	reset: proc "c" (m: ^Model, plugin_state: ^f64, plugin_data: rawptr, instance: i32),

	// called when the plugin needs to update its outputs (required)
	compute: proc "c" (m: ^Model, d: ^Data, instance: i32, capability_bit: i32),

	// called when time integration occurs (optional)
	advance: proc "c" (m: ^Model, d: ^Data, instance: i32),

	// called by mjv_updateScene (optional)
	visualize: proc "c" (m: ^Model, d: ^Data, opt: ^vOption, scn: ^vScene, instance: i32),

	// methods specific to actuators (optional)
	
	// updates the actuator plugin's entries in act_dot
	// called after native act_dot is computed and before the compute callback
	actuator_act_dot: proc "c" (m: ^Model, d: ^Data, instance: i32),

	// methods specific to signed distance fields (optional)
	
	// signed distance from the surface
	sdf_distance: proc "c" (point: ^[3]f64, d: ^Data, instance: i32) -> f64,

	// gradient of distance with respect to local coordinates
	sdf_gradient: proc "c" (gradient: ^[3]f64, point: ^[3]f64, d: ^Data, instance: i32),

	// called during compilation for marching cubes
	sdf_staticdistance: proc "c" (point: ^[3]f64, attributes: ^f64) -> f64,

	// convert attributes and provide defaults if not present
	sdf_attribute: proc "c" (attribute: [^]f64, name: [^]cstring, value: [^]cstring),

	// bounding box of implicit surface
	sdf_aabb: proc "c" (aabb: ^[6]f64, attributes: ^f64),
}

SDF :: struct {
	plugin:   ^^pPlugin,
	id:       ^i32,
	type:     tSDFType,
	relpos:   ^f64,
	relmat:   ^f64,
	geomtype: ^tGeom,
}

// function pointer type for mj_loadAllPluginLibraries callback
fPluginLibraryLoadCallback :: proc "c" (filename: cstring, first: i32, count: i32)

