# Vivado Project Generator Script for HUL_firmware
# Usage: Open Vivado Tcl Console, cd to the 'firmware' directory, then run:
# source scripts/project_generator.tcl

# 1. Configuration
set project_name "HUL_firmware"
set project_dir "project"
set target_part "xc7k160tfbg676-1"
set src_dir "src"

# 2. Check current directory & Save Root
# Detect script location to allow running from anywhere
set script_path [file normalize [info script]]
puts "DEBUG: info script returned: '[info script]'"
puts "DEBUG: Normalized script path: '$script_path'"

set script_dir [file dirname $script_path]
# root_dir is one level up from scripts/
set root_dir [file dirname $script_dir]

puts "INFO: Root Dir determined as $root_dir"

# Change to root directory to ensure project is created there
if {[catch {cd $root_dir} err]} {
    puts "ERROR: Could not change directory to $root_dir. Error: $err"
    return
}
puts "INFO: Changed working directory to [pwd]"

# 3. Create Project
# Check if project directory exists and delete it if so (clean start)
if {[file exists $project_dir]} {
    file delete -force $project_dir
}
create_project $project_name $project_dir -part $target_part -force

# 4. Set Project Properties
set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]

# 5. Add Sources

# HDL Sources
puts "INFO: Adding HDL sources from $src_dir/hdl"
# Add toplevel
add_files -norecurse "$src_dir/hdl/toplevel.vhd"

# Add modules (explicitly globbing VHDL files)
set module_files [glob -nocomplain "$src_dir/hdl/modules/*.vhd"]
if {[llength $module_files] > 0} {
    add_files -norecurse $module_files
    
    # Set library 'mylib' for ALL modules in firmware/src/hdl/modules
    puts "INFO: Setting library to 'mylib' for all module files"
    # We use the file list we just found. 
    # Note: If file paths are relative, get_files usage must match.
    set_property LIBRARY mylib [get_files $module_files]
} else {
    puts "WARNING: No VHDL module files found in $src_dir/hdl/modules"
}

# IP Sources
puts "INFO: Adding IP sources from $src_dir/ip"
# Add all .xcix files
set ip_files [glob -nocomplain "$src_dir/ip/*.xcix"]
if {[llength $ip_files] > 0} {
    add_files -norecurse $ip_files
} else {
    puts "WARNING: No IP files found in $src_dir/ip"
}

# Constraints
puts "INFO: Adding Constraints from $src_dir/constrs"
set constr_files [glob -nocomplain "$src_dir/constrs/*.xdc"]
if {[llength $constr_files] > 0} {
    add_files -fileset constrs_1 -norecurse $constr_files
} else {
    puts "WARNING: No constraint files found in $src_dir/constrs"
}

# Set specific constraint properties
set async_groups_file [get_files -quiet -of_objects [get_filesets constrs_1] *hul_async_groups.xdc]
if {$async_groups_file != ""} {
    puts "INFO: Setting processing order to LATE for hul_async_groups.xdc"
    set_property PROCESSING_ORDER LATE $async_groups_file
}

# 6. Handle SiTCP (Automatic search including submodules)
puts "INFO: Checking for SiTCP files in $src_dir/sitcp (including subdirectories)"
set valid_sitcp_files {}
# Get root sitcp dir and immediate subdirs (e.g. submodule)
set search_dirs [list "$src_dir/sitcp"]
set subdirs [glob -nocomplain -directory "$src_dir/sitcp" -type d *]
foreach d $subdirs { lappend search_dirs $d }

foreach dir $search_dirs {
    # Search for specific extensions
    foreach ext {*.v *.vhd *.ngc *.edf *.edif *.xdc} {
        foreach f [glob -nocomplain -directory $dir $ext] {
            lappend valid_sitcp_files $f
        }
    }
}

# Smart Filter: If EDIF exists, remove NGC to avoid version conflicts in Vivado 2023+
set has_edif 0
foreach f $valid_sitcp_files {
    if {[string match -nocase *.edf $f] || [string match -nocase *.edif $f]} {
        set has_edif 1
        break
    }
}

if {$has_edif} {
    puts "INFO: EDIF format found. Excluding .ngc files to prioritize .edf/.edif for newer Vivado versions."
    set filtered {}
    foreach f $valid_sitcp_files {
        if {![string match -nocase *.ngc $f]} {
            lappend filtered $f
        }
    }
    set valid_sitcp_files $filtered
}

if {[llength $valid_sitcp_files] > 0} {
    puts "INFO: Found [llength $valid_sitcp_files] SiTCP files, adding to project..."
    add_files -norecurse $valid_sitcp_files
} else {
    puts "WARNING: No SiTCP files found in $src_dir/sitcp. Please manually place (or submodule) .edf/.v files."
}

# 7. Finalize
set_property top toplevel [current_fileset]
update_compile_order -fileset sources_1

puts "INFO: Project generation complete. Project created at $project_dir/$project_name.xpr"
