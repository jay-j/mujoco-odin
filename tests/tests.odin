package mujoco_tests

import mj ".."
import "core:log"
import "core:testing"

// Hello world test; just open a single model
@(test)
test_hello :: proc(t: ^testing.T) {

	model := mj.loadXML("demo.xml", nil, nil, 0)

	log.warnf("model: %v", model)

	testing.expect(t, model != nil)
}
