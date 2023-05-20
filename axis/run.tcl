####################################################################################
# 1.create project and add files
####################################################################################
set launchDir [file dirname [file normalize [info script]]]
set srcDir ${launchDir}/src
set xdcDir ${launchDir}/xdc
set projName "proj"
set projDir "./${projName}"
set projPart "xcvu37p-fsvh2892-2L-e"
create_project ${projName} ${projDir} -part ${projPart}

####################################################################################
# 2.create design
####################################################################################
# create block design
set bdName "axis"
source ${srcDir}/tcl/axis.tcl
# add verilog file
add_files -norecurse ${srcDir}/hdl/top.v
add_files -norecurse ${srcDir}/hdl/data_gen.v
add_files -norecurse ${srcDir}/hdl/data_recv.v
# add constrain file
add_files -fileset constrs_1 -norecurse ${xdcDir}/axis.xdc
# add simulation file
add_files -fileset sim_1 -norecurse ${srcDir}/sim/top_tb.v

####################################################################################
# 3.synth, impl and generate bitstream
####################################################################################
regenerate_bd_layout
validate_bd_design
save_bd_design
make_wrapper -files [get_files ${projDir}/${projName}.srcs/sources_1/bd/${bdName}/${bdName}.bd] -top
add_files -norecurse ${projDir}/${projName}.gen/sources_1/bd/${bdName}/hdl/${bdName}_wrapper.v
launch_runs synth_1 -jobs 20
wait_on_run synth_1
launch_runs impl_1 -jobs 20
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 20