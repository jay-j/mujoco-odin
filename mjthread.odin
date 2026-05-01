// Copyright 2023 DeepMind Technologies Limited
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

mjMAXTHREAD :: 128 // maximum number of threads in a thread pool

tTaskStatus :: enum u32 {
	NEW       = 0, // newly created
	QUEUED    = 1, // enqueued in a thread pool
	COMPLETED = 2, // completed execution
} // status values for mjTask

// function pointer type for mjTask
fTask :: proc "c" (_: rawptr) -> rawptr

// An opaque type representing a thread pool.
ThreadPool :: struct {
	nworker: i32, // number of workers in the pool
}

Task :: struct {
	func:   fTask, // pointer to the function that implements the task
	args:   rawptr, // arguments to func
	status: i32, // status of the task
} // a task that can be executed by a thread pool.
