# MuJoCo Odin Bindings
[MuJoCo](https://mujoco.org/) is fantastic! Here is a set of Odin bindings for MuJoCo 3.8.0.

# Note to Self: Updating Bindings
1. Use [odin-c-bindgen](https://github.com/karl-zylinski/odin-c-bindgen/tree/main) with the `bindgen.sjson` included here to make a rough first pass.
2. Update several fields to `bit_set`:
  - `mjdata.odin : tState `
  - `mjModel.odin : tDisableBit`
  - `mjModel.odin : tEnableBit`

3. Convert all array pointers to multi-pointers.
Search regex: ` ^.*\(.* x .*\)`

4. Remove the `mj_` prefix from foreign functions in  `mujoco.odin` and add in the linked library loading.

5. Delete otherwise-empty files.

## TODO:
- What to do with the `mju_` prefix functions?
- Change functions taking integers to the correct enum types.

# Building on Mac

1. Download MuJoCo
2. Copy the dylib into the project: `cp /Volumes/MuJoCo/mujoco.framework/Versions/A/libmujoco.3.8.0.dylib ~/GitHub/sotibot/mujoco/`
2. Fix the tool name by running this for your directory: `install_name_tool -change @rpath/mujoco.framework/Versions/A/libmujoco.3.8.0.dylib @executable_path/libmujoco.3.8.0.dylib ~/GitHub/sotibot/mujoco/tests/prog.bin`