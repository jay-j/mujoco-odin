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

//---------------------------------- primitive types (mjt) -----------------------------------------
tState :: enum u32 {
	STATE_TIME         = 0, // time
	STATE_QPOS         = 1, // position
	STATE_QVEL         = 2, // velocity
	STATE_ACT          = 3, // actuator activation
	STATE_HISTORY      = 4, // history buffers (control, sensor)
	STATE_WARMSTART    = 5, // acceleration used for warmstart
	STATE_CTRL         = 6, // control
	STATE_QFRC_APPLIED = 7, // applied generalized force
	STATE_XFRC_APPLIED = 8, // applied Cartesian force/torque
	STATE_EQ_ACTIVE    = 9, // enable/disable constraints
	STATE_MOCAP_POS    = 10, // positions of mocap bodies
	STATE_MOCAP_QUAT   = 11, // orientations of mocap bodies
	STATE_USERDATA     = 12, // user data
	STATE_PLUGIN       = 13, // plugin state
} // state elements
State :: distinct bit_set[tState;u32]

// convenience values for commonly used state specifications
State_Physics ::
	State{.STATE_QPOS} | State{.STATE_QVEL} | State{.STATE_ACT} | State{.STATE_HISTORY}
State_FullPhysics :: State{.STATE_TIME} | State{.STATE_PLUGIN} | State_Physics
State_User ::
	State{.STATE_CTRL} |
	State{.STATE_QFRC_APPLIED} |
	State{.STATE_XFRC_APPLIED} |
	State{.STATE_EQ_ACTIVE} |
	State{.STATE_MOCAP_POS} |
	State{.STATE_MOCAP_QUAT} |
	State{.STATE_USERDATA}
State_Integration :: State_FullPhysics | State_User | State{.STATE_WARMSTART}


tConstraint :: enum u32 {
	EQUALITY             = 0, // equality constraint
	FRICTION_DOF         = 1, // dof friction
	FRICTION_TENDON      = 2, // tendon friction
	LIMIT_JOINT          = 3, // joint limit
	LIMIT_TENDON         = 4, // tendon limit
	CONTACT_FRICTIONLESS = 5, // frictionless contact
	CONTACT_PYRAMIDAL    = 6, // frictional contact, pyramidal friction cone
	CONTACT_ELLIPTIC     = 7, // frictional contact, elliptic friction cone
} // type of constraint

tConstraintState :: enum u32 {
	SATISFIED = 0, // constraint satisfied, zero cost (limit, contact)
	QUADRATIC = 1, // quadratic cost (equality, friction, limit, contact)
	LINEARNEG = 2, // linear cost, negative side (friction)
	LINEARPOS = 3, // linear cost, positive side (friction)
	CONE      = 4, // squared distance to cone cost (elliptic contact)
} // constraint state

tWarning :: enum u32 {
	WARN_INERTIA     = 0, // (near) singular inertia matrix
	WARN_CONTACTFULL = 1, // too many contacts in contact list
	WARN_CNSTRFULL   = 2, // too many constraints
	WARN_BADQPOS     = 3, // bad number in qpos
	WARN_BADQVEL     = 4, // bad number in qvel
	WARN_BADQACC     = 5, // bad number in qacc
	WARN_BADCTRL     = 6, // bad number in ctrl
	NWARNING         = 7, // number of warnings
} // warning types

tTimer :: enum u32 {
	// main api
	TIMER_STEP           = 0, // step
	TIMER_FORWARD        = 1, // forward
	TIMER_INVERSE        = 2, // inverse

	// breakdown of step/forward
	TIMER_POSITION       = 3, // fwdPosition
	TIMER_VELOCITY       = 4, // fwdVelocity
	TIMER_ACTUATION      = 5, // fwdActuation
	TIMER_CONSTRAINT     = 6, // fwdConstraint
	TIMER_ADVANCE        = 7, // mj_Euler, mj_implicit

	// breakdown of fwdPosition
	TIMER_POS_KINEMATICS = 8, // kinematics, com, tendon, transmission
	TIMER_POS_INERTIA    = 9, // inertia computations
	TIMER_POS_COLLISION  = 10, // collision detection
	TIMER_POS_MAKE       = 11, // make constraints
	TIMER_POS_PROJECT    = 12, // project constraints

	// breakdown of mj_collision
	TIMER_COL_BROAD      = 13, // broadphase
	TIMER_COL_NARROW     = 14, // narrowphase
	NTIMER               = 15, // number of timers
} // internal timers

tSleepState :: enum i32 {
	STATIC = -1, // object is static
	ASLEEP = 0, // object is asleep
	AWAKE  = 1, // object is awake
} // sleep state of an object

//---------------------------------- mjContact -----------------------------------------------------
Contact :: struct {
	// contact parameters set by near-phase collision function
	dist:           f64, // distance between nearest points; neg: penetration
	pos:            [3]f64, // position of contact point: midpoint between geoms
	frame:          [9]f64, // normal is in [0-2], points from geom[0] to geom[1]

	// contact parameters set by mj_collideGeoms
	includemargin:  f64, // include if dist<includemargin=margin-gap
	friction:       [5]f64, // tangent1, 2, spin, roll1, 2
	solref:         [2]f64, // constraint solver reference, normal direction
	solreffriction: [2]f64, // constraint solver reference, friction directions
	solimp:         [5]f64, // constraint solver impedance

	// internal storage used by solver
	mu:             f64, // friction of regularized cone, set by mj_makeConstraint
	H:              [36]f64, // cone Hessian, set by mj_constraintUpdate

	// contact descriptors set by mj_collideXXX
	dim:            i32, // contact space dimensionality: 1, 3, 4 or 6
	geom1:          i32, // id of geom 1; deprecated, use geom[0]
	geom2:          i32, // id of geom 2; deprecated, use geom[1]
	geom:           [2]i32, // geom ids; -1 for flex
	flex:           [2]i32, // flex ids; -1 for geom
	elem:           [2]i32, // element ids; -1 for geom or flex vertex
	vert:           [2]i32, // vertex ids;  -1 for geom or flex element

	// flag set by mj_setContact or mj_instantiateContact
	exclude:        i32, // 0: include, 1: in gap, 2: fused, 3: no dofs, 4: passive

	// address computed by mj_instantiateContact
	efc_address:    i32, // address in efc; -1: not included
} // result of collision detection functions

//---------------------------------- diagnostics ---------------------------------------------------
WarningStat :: struct {
	lastinfo: i32, // info from last warning
	number:   i32, // how many times was warning raised
} // warning statistics

TimerStat :: struct {
	duration: f64, // cumulative duration
	number:   i32, // how many times was timer called
} // timer statistics

SolverStat :: struct {
	improvement: f64, // cost reduction, scaled by 1/trace(M(qpos0))
	gradient:    f64, // gradient norm (primal only, scaled)
	lineslope:   f64, // slope in linesearch
	nactive:     i32, // number of active constraints
	nchange:     i32, // number of constraint state changes
	neval:       i32, // number of cost evaluations in line search
	nupdate:     i32, // number of Cholesky updates in line search
} // per-iteration solver statistics

//---------------------------------- mjData --------------------------------------------------------
Data :: struct {
	// constant sizes
	narena:             i64, // size of the arena in bytes (inclusive of the stack)
	nbuffer:            i64, // size of main buffer in bytes
	nplugin:            i32, // number of plugin instances

	// stack pointer
	pstack:             c.size_t, // first available byte in stack (mutable)
	pbase:              c.size_t, // value of pstack when mj_markStack was last called (mutable)

	// arena pointer
	parena:             c.size_t, // first available byte in arena

	// memory utilization statistics
	maxuse_stack:       i64, // maximum stack allocation in bytes (mutable)
	maxuse_threadstack: [128]i64, // maximum stack allocation per thread in bytes
	maxuse_arena:       i64, // maximum arena allocation in bytes
	maxuse_con:         i32, // maximum number of contacts
	maxuse_efc:         i32, // maximum number of scalar constraints

	// solver statistics
	solver:             [4000]SolverStat, // solver statistics per island, per iteration
	solver_niter:       [20]i32, // number of solver iterations, per island
	solver_nnz:         [20]i32, // number of nonzeros in Hessian or efc_AR, per island
	solver_fwdinv:      [2]f64, // forward-inverse comparison: qfrc, efc

	// diagnostics
	warning:            [7]WarningStat, // warning statistics (mutable)
	timer:              [15]TimerStat, // timer statistics

	// variable sizes
	ncon:               i32, // number of detected contacts
	ne:                 i32, // number of equality constraints
	nf:                 i32, // number of friction constraints
	nl:                 i32, // number of limit constraints
	nefc:               i32, // number of constraints
	nJ:                 i32, // number of non-zeros in constraint Jacobian
	nA:                 i32, // number of non-zeros in constraint inverse inertia matrix
	nisland:            i32, // number of detected constraint islands
	nidof:              i32, // number of dofs in all islands
	ntree_awake:        i32, // number of awake trees
	nbody_awake:        i32, // number of awake dynamic and static bodies
	nparent_awake:      i32, // number of bodies with awake parents
	nv_awake:           i32, // number of awake dofs

	// flags marking lazily evaluated stages
	flg_energypos:      b8, // has mj_energyPos been called
	flg_energyvel:      b8, // has mj_energyVel been called
	flg_subtreevel:     b8, // has mj_subtreeVel been called
	flg_rnepost:        b8, // has mj_rnePostConstraint been called

	// global properties
	time:               f64, // simulation time
	energy:             [2]f64, // potential, kinetic energy

	//-------------------- end of info header

	// buffers
	buffer:             rawptr, // main buffer; all pointers point in it            (nbuffer bytes)
	arena:              rawptr, // arena+stack buffer                               (narena bytes)

	//-------------------- main inputs and outputs of the computation

	// state
	qpos:               [^]f64, // position                                         (nq x 1)
	qvel:               [^]f64, // velocity                                         (nv x 1)
	act:                [^]f64, // actuator activation                              (na x 1)
	history:            [^]f64, // history buffer                                   (nhistory x 1)
	qacc_warmstart:     [^]f64, // acceleration used for warmstart                  (nv x 1)
	plugin_state:       [^]f64, // plugin state                                     (npluginstate x 1)

	// control
	ctrl:               [^]f64, // control                                          (nu x 1)
	qfrc_applied:       [^]f64, // applied generalized force                        (nv x 1)
	xfrc_applied:       [^]f64, // applied Cartesian force/torque                   (nbody x 6)
	eq_active:          [^]b8, // enable/disable constraints                       (neq x 1)

	// mocap data
	mocap_pos:          [^]f64, // positions of mocap bodies                        (nmocap x 3)
	mocap_quat:         [^]f64, // orientations of mocap bodies                     (nmocap x 4)

	// dynamics
	qacc:               [^]f64, // acceleration                                     (nv x 1)
	act_dot:            [^]f64, // time-derivative of actuator activation           (na x 1)

	// user data
	userdata:           [^]f64, // user data, not touched by engine                 (nuserdata x 1)

	// sensors
	sensordata:         [^]f64, // sensor data array                                (nsensordata x 1)

	// sleep state
	tree_asleep:        [^]i32, // <0: awake; >=0: index cycle of sleeping trees    (ntree x 1)

	// plugins
	plugin:             [^]i32, // copy of m->plugin, required for deletion         (nplugin x 1)
	plugin_data:        [^]c.uintptr_t, // pointer to plugin-managed data structure         (nplugin x 1)

	//-------------------- POSITION dependent

	// computed by mj_fwdPosition/mj_kinematics
	xpos:               [^]f64, // Cartesian position of body frame                 (nbody x 3)
	xquat:              [^]f64, // Cartesian orientation of body frame              (nbody x 4)
	xmat:               [^]f64, // Cartesian orientation of body frame              (nbody x 9)
	xipos:              [^]f64, // Cartesian position of body com                   (nbody x 3)
	ximat:              [^]f64, // Cartesian orientation of body inertia            (nbody x 9)
	xanchor:            [^]f64, // Cartesian position of joint anchor               (njnt x 3)
	xaxis:              [^]f64, // Cartesian joint axis                             (njnt x 3)
	geom_xpos:          [^]f64, // Cartesian geom position                          (ngeom x 3)
	geom_xmat:          [^]f64, // Cartesian geom orientation                       (ngeom x 9)
	site_xpos:          [^]f64, // Cartesian site position                          (nsite x 3)
	site_xmat:          [^]f64, // Cartesian site orientation                       (nsite x 9)
	cam_xpos:           [^]f64, // Cartesian camera position                        (ncam x 3)
	cam_xmat:           [^]f64, // Cartesian camera orientation                     (ncam x 9)
	light_xpos:         [^]f64, // Cartesian light position                         (nlight x 3)
	light_xdir:         [^]f64, // Cartesian light direction                        (nlight x 3)

	// computed by mj_fwdPosition/mj_comPos
	subtree_com:        [^]f64, // center of mass of each subtree                   (nbody x 3)
	cdof:               [^]f64, // com-based motion axis of each dof (rot:lin)      (nv x 6)
	cinert:             [^]f64, // com-based body inertia and mass                  (nbody x 10)

	// computed by mj_fwdPosition/mj_flex
	flexvert_xpos:      [^]f64, // Cartesian flex vertex positions                  (nflexvert x 3)
	flexelem_aabb:      [^]f64, // flex element bounding boxes (center, size)       (nflexelem x 6)
	flexedge_J:         [^]f64, // flex edge Jacobian                               (nJfe x 1)
	flexedge_length:    [^]f64, // flex edge lengths                                (nflexedge x 1)
	flexvert_J:         [^]f64, // flex vertex Jacobian                             (nJfv x 2)
	flexvert_length:    [^]f64, // flex vertex lengths                              (nflexvert x 2)
	bvh_aabb_dyn:       [^]f64, // global bounding box (center, size)               (nbvhdynamic x 6)

	// computed by mj_fwdPosition/mj_tendon
	ten_wrapadr:        [^]i32, // start address of tendon's path                   (ntendon x 1)
	ten_wrapnum:        [^]i32, // number of wrap points in path                    (ntendon x 1)
	ten_J:              [^]f64, // tendon Jacobian                                  (nJten x 1)
	ten_length:         [^]f64, // tendon lengths                                   (ntendon x 1)
	wrap_obj:           [^]i32, // geom id; -1: site; -2: pulley                    (nwrap x 2)
	wrap_xpos:          [^]f64, // Cartesian 3D points in all paths                 (nwrap x 6)

	// computed by mj_fwdPosition/mj_transmission
	actuator_length:    [^]f64, // actuator lengths                                 (nu x 1)
	moment_rownnz:      [^]i32, // number of non-zeros in actuator_moment row       (nu x 1)
	moment_rowadr:      [^]i32, // row start address in colind array                (nu x 1)
	moment_colind:      [^]i32, // column indices in sparse Jacobian                (nJmom x 1)
	actuator_moment:    [^]f64, // actuator moments                                 (nJmom x 1)

	// computed by mj_fwdPosition/mj_makeM
	crb:                [^]f64, // com-based composite inertia and mass             (nbody x 10)
	qM:                 [^]f64, // inertia (sparse)                                 (nM x 1)
	M:                  [^]f64, // reduced inertia (compressed sparse row)          (nC x 1)

	// computed by mj_fwdPosition/mj_factorM
	qLD:                [^]f64, // L'*D*L factorization of M (sparse)               (nC x 1)
	qLDiagInv:          [^]f64, // 1/diag(D)                                        (nv x 1)

	// computed by mj_collision/mj_collideTree
	bvh_active:         [^]b8, // was bounding volume checked for collision        (nbvh x 1)

	// computed by mj_updateSleep
	tree_awake:         [^]i32, // is tree awake; 0: asleep; 1: awake               (ntree x 1)
	body_awake:         [^]i32, // body sleep state (mjtSleepState)                 (nbody x 1)
	body_awake_ind:     [^]i32, // indices of awake and static bodies               (nbody x 1)
	parent_awake_ind:   [^]i32, // indices of bodies with awake or static parents   (nbody x 1)
	dof_awake_ind:      [^]i32, // indices of awake dofs                            (nv x 1)

	//-------------------- POSITION, VELOCITY dependent

	// computed by mj_fwdVelocity
	flexedge_velocity:  [^]f64, // flex edge velocities                             (nflexedge x 1)
	ten_velocity:       [^]f64, // tendon velocities                                (ntendon x 1)
	actuator_velocity:  [^]f64, // actuator velocities                              (nu x 1)

	// computed by mj_fwdVelocity/mj_comVel
	cvel:               [^]f64, // com-based velocity (rot:lin)                     (nbody x 6)
	cdof_dot:           [^]f64, // time-derivative of cdof (rot:lin)                (nv x 6)

	// computed by mj_fwdVelocity/mj_rne (without acceleration)
	qfrc_bias:          [^]f64, // C(qpos,qvel)                                     (nv x 1)

	// computed by mj_fwdVelocity/mj_passive
	qfrc_spring:        [^]f64, // passive spring force                             (nv x 1)
	qfrc_damper:        [^]f64, // passive damper force                             (nv x 1)
	qfrc_gravcomp:      [^]f64, // passive gravity compensation force               (nv x 1)
	qfrc_fluid:         [^]f64, // passive fluid force                              (nv x 1)
	qfrc_passive:       [^]f64, // total passive force                              (nv x 1)

	// computed by mj_sensorVel/mj_subtreeVel if needed
	subtree_linvel:     [^]f64, // linear velocity of subtree com                   (nbody x 3)
	subtree_angmom:     [^]f64, // angular momentum about subtree com               (nbody x 3)

	// computed by mj_Euler or mj_implicit
	qH:                 [^]f64, // L'*D*L factorization of modified M               (nC x 1)
	qHDiagInv:          [^]f64, // 1/diag(D) of modified M                          (nv x 1)

	// computed by mj_implicit/mj_derivative
	qDeriv:             [^]f64, // d (passive + actuator - bias) / d qvel           (nD x 1)

	// computed by mj_implicit/mju_factorLUSparse
	qLU:                [^]f64, // sparse LU of (qM - dt*qDeriv)                    (nD x 1)

	//-------------------- POSITION, VELOCITY, CONTROL/ACCELERATION dependent

	// computed by mj_fwdActuation
	actuator_force:     [^]f64, // actuator force in actuation space                (nu x 1)
	qfrc_actuator:      [^]f64, // actuator force                                   (nv x 1)

	// computed by mj_fwdAcceleration
	qfrc_smooth:        [^]f64, // net unconstrained force                          (nv x 1)
	qacc_smooth:        [^]f64, // unconstrained acceleration                       (nv x 1)

	// computed by mj_fwdConstraint/mj_inverse
	qfrc_constraint:    [^]f64, // constraint force                                 (nv x 1)

	// computed by mj_inverse
	qfrc_inverse:       [^]f64, // net external force; should equal: qfrc_applied + J'*xfrc_applied + qfrc_actuator   (nv x 1)

	// computed by mj_sensorAcc/mj_rnePostConstraint if needed; rotation:translation format
	cacc:               [^]f64, // com-based acceleration                           (nbody x 6)
	cfrc_int:           [^]f64, // com-based interaction force with parent          (nbody x 6)
	cfrc_ext:           [^]f64, // com-based external force on body                 (nbody x 6)

	//-------------------- arena-allocated: POSITION dependent

	// computed by mj_collision
	contact:            [^]Contact, // array of all detected contacts                   (ncon x 1)

	// computed by mj_makeConstraint
	efc_type:           [^]i32, // constraint type (mjtConstraint)                  (nefc x 1)
	efc_id:             [^]i32, // id of object of specified type                   (nefc x 1)
	efc_J_rownnz:       [^]i32, // number of non-zeros in constraint Jacobian row   (nefc x 1)
	efc_J_rowadr:       [^]i32, // row start address in colind array                (nefc x 1)
	efc_J_rowsuper:     [^]i32, // number of subsequent rows in supernode           (nefc x 1)
	efc_J_colind:       [^]i32, // column indices in constraint Jacobian            (nJ x 1)
	efc_J:              [^]f64, // constraint Jacobian                              (nJ x 1)
	efc_pos:            [^]f64, // constraint position (equality, contact)          (nefc x 1)
	efc_margin:         [^]f64, // inclusion margin (contact)                       (nefc x 1)
	efc_frictionloss:   [^]f64, // frictionloss (friction)                          (nefc x 1)
	efc_diagApprox:     [^]f64, // approximation to diagonal of A                   (nefc x 1)
	efc_KBIP:           [^]f64, // stiffness, damping, impedance, imp'              (nefc x 4)
	efc_D:              [^]f64, // constraint mass                                  (nefc x 1)
	efc_R:              [^]f64, // inverse constraint mass                          (nefc x 1)
	tendon_efcadr:      [^]i32, // first efc address involving tendon; -1: none     (ntendon x 1)

	// computed by mj_island (island tree structure)
	tree_island:        [^]i32, // island id of this tree; -1: none                 (ntree x 1)
	island_ntree:       [^]i32, // number of trees in this island                   (nisland x 1)
	island_itreeadr:    [^]i32, // island start address in itree vector             (nisland x 1)
	map_itree2tree:     [^]i32, // map from itree to tree                           (ntree x 1)

	// computed by mj_island (island dof structure)
	dof_island:         [^]i32, // island id of this dof; -1: none                  (nv x 1)
	island_nv:          [^]i32, // number of dofs in this island                    (nisland x 1)
	island_idofadr:     [^]i32, // island start address in idof vector              (nisland x 1)
	island_dofadr:      [^]i32, // island start address in dof vector               (nisland x 1)
	map_dof2idof:       [^]i32, // map from dof to idof                             (nv x 1)
	map_idof2dof:       [^]i32, // map from idof to dof;  >= nidof: unconstrained   (nv x 1)

	// computed by mj_island (dofs sorted by island)
	ifrc_smooth:        [^]f64, // net unconstrained force                          (nidof x 1)
	iacc_smooth:        [^]f64, // unconstrained acceleration                       (nidof x 1)
	iM_rownnz:          [^]i32, // inertia: non-zeros in each row                   (nidof x 1)
	iM_rowadr:          [^]i32, // inertia: address of each row in iM_colind        (nidof x 1)
	iM_colind:          [^]i32, // inertia: column indices of non-zeros             (nC x 1)
	iM:                 [^]f64, // total inertia (sparse)                           (nC x 1)
	iLD:                [^]f64, // L'*D*L factorization of M (sparse)               (nC x 1)
	iLDiagInv:          [^]f64, // 1/diag(D)                                        (nidof x 1)
	iacc:               [^]f64, // acceleration                                     (nidof x 1)

	// computed by mj_island (island constraint structure)
	efc_island:         [^]i32, // island id of this constraint                     (nefc x 1)
	island_ne:          [^]i32, // number of equality constraints in island         (nisland x 1)
	island_nf:          [^]i32, // number of friction constraints in island         (nisland x 1)
	island_nefc:        [^]i32, // number of constraints in island                  (nisland x 1)
	island_iefcadr:     [^]i32, // start address in iefc vector                     (nisland x 1)
	map_efc2iefc:       [^]i32, // map from efc to iefc                             (nefc x 1)
	map_iefc2efc:       [^]i32, // map from iefc to efc                             (nefc x 1)

	// computed by mj_island (constraints sorted by island)
	iefc_type:          [^]i32, // constraint type (mjtConstraint)                  (nefc x 1)
	iefc_id:            [^]i32, // id of object of specified type                   (nefc x 1)
	iefc_J_rownnz:      [^]i32, // number of non-zeros in constraint Jacobian row   (nefc x 1)
	iefc_J_rowadr:      [^]i32, // row start address in colind array                (nefc x 1)
	iefc_J_rowsuper:    [^]i32, // number of subsequent rows in supernode           (nefc x 1)
	iefc_J_colind:      [^]i32, // column indices in constraint Jacobian            (nJ x 1)
	iefc_J:             [^]f64, // constraint Jacobian                              (nJ x 1)
	iefc_frictionloss:  [^]f64, // frictionloss (friction)                          (nefc x 1)
	iefc_D:             [^]f64, // constraint mass                                  (nefc x 1)
	iefc_R:             [^]f64, // inverse constraint mass                          (nefc x 1)

	// computed by mj_projectConstraint (PGS solver)
	efc_AR_rownnz:      [^]i32, // number of non-zeros in AR                        (nefc x 1)
	efc_AR_rowadr:      [^]i32, // row start address in colind array                (nefc x 1)
	efc_AR_colind:      [^]i32, // column indices in sparse AR                      (nA x 1)
	efc_AR:             [^]f64, // J*inv(M)*J' + R                                  (nA x 1)

	//-------------------- arena-allocated: POSITION, VELOCITY dependent

	// computed by mj_fwdVelocity/mj_referenceConstraint
	efc_vel:            [^]f64, // velocity in constraint space: J*qvel             (nefc x 1)
	efc_aref:           [^]f64, // reference pseudo-acceleration                    (nefc x 1)

	//-------------------- arena-allocated: POSITION, VELOCITY, CONTROL/ACCELERATION dependent

	// computed by mj_fwdConstraint/mj_inverse
	efc_b:              [^]f64, // linear cost term: J*qacc_smooth - aref           (nefc x 1)
	iefc_aref:          [^]f64, // reference pseudo-acceleration                    (nefc x 1)
	iefc_state:         [^]i32, // constraint state (mjtConstraintState)            (nefc x 1)
	iefc_force:         [^]f64, // constraint force in constraint space             (nefc x 1)
	efc_state:          [^]i32, // constraint state (mjtConstraintState)            (nefc x 1)
	efc_force:          [^]f64, // constraint force in constraint space             (nefc x 1)
	ifrc_constraint:    [^]f64, // constraint force                                 (nidof x 1)

	// thread pool pointer
	threadpool:         c.uintptr_t,

	// compilation signature
	signature:          u64, // also held by the mjSpec that compiled the model
}

// generic MuJoCo function
fGeneric :: proc "c" (m: ^Model, d: ^Data)

// contact filter: 1- discard, 0- collide
fConFilt :: proc "c" (m: ^Model, d: ^Data, geom1: i32, geom2: i32) -> i32

// sensor simulation
fSensor :: proc "c" (m: ^Model, d: ^Data, stage: i32)

// timer
fTime :: proc "c" () -> f64

// actuator dynamics, gain, bias
fAct :: proc "c" (m: ^Model, d: ^Data, id: i32) -> f64

// collision detection
fCollision :: proc "c" (m: ^Model, d: ^Data, con: ^Contact, g1: i32, g2: i32, margin: f64) -> i32
