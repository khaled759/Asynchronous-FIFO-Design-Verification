# ai generated script for fast simulation 

# ============================================================
# QuestaSim Run Script
# Async FIFO Project
# ============================================================

# Explicit project root
set PROJECT_ROOT "C:/digital_electronics/Projects/async_fifo"

set SRC_DIR     [file join $PROJECT_ROOT src]
set TB_DIR      [file join $PROJECT_ROOT tb/class_based_tb]
set REPORTS_DIR [file join $PROJECT_ROOT reports]


puts ""
puts "=========================================="
puts " Directory Info"
puts "=========================================="
puts "Project Root : $PROJECT_ROOT"
puts "Source Dir   : $SRC_DIR"
puts "Testbench Dir: $TB_DIR"
puts "Reports Dir  : $REPORTS_DIR"
puts "=========================================="

set TB_TOP "fifo_tb_top"

puts ""
puts "Testbench Top: $TB_TOP"

if {![file exists $REPORTS_DIR]} {
    puts ""
    puts "Creating reports directory..."
    file mkdir $REPORTS_DIR
}

# Coverage files
set COV_UCDB [file join $REPORTS_DIR fifo_coverage.ucdb]
set COV_RPT  [file join $REPORTS_DIR coverage_report.txt]

puts ""
puts "=========================================="
puts " Creating Work Library"

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

proc find_files {directory extensions} {
    set result {}
    foreach file [glob -nocomplain -directory $directory *] {
        if {[file isdirectory $file]} {
            set result [concat $result [find_files $file $extensions]]
        } else {
            set ext [string tolower [file extension $file]]
            if {[lsearch -exact $extensions $ext] != -1} {
                lappend result $file
            }
        }
    }
    return $result
}

puts ""
puts "=========================================="
puts " Compiling RTL Sources"

set src_files [find_files $SRC_DIR {.v .sv}]

if {[llength $src_files] == 0} {
    puts "ERROR: No RTL source files found!"
    quit -code 1
}

foreach file $src_files {
    puts ""
    puts "Compiling RTL:"
    puts "  $file"

    vlog -sv \
         +cover \
         +define+SIM \
         +incdir+$SRC_DIR \
         -work work \
         $file
}

puts ""
puts "=========================================="
puts " Compiling Testbench"

set tb_files [find_files $TB_DIR {.v .sv}]

if {[llength $tb_files] == 0} {
    puts "ERROR: No testbench files found!"
    quit -code 1
}

foreach file $tb_files {
    puts ""
    puts "Compiling TB:"
    puts "  $file"

    vlog -sv \
         +cover \
         +define+SIM \
         +incdir+$SRC_DIR \
         +incdir+$TB_DIR \
         -work work \
         $file
}

puts ""
puts "=========================================="
puts " Starting Simulation"

vsim -voptargs=+acc fifo_tb_top -cover

puts ""
puts "=========================================="
puts " Adding Signals to Waveform"

add wave -r /$TB_TOP/fifo_if/*
add wave -position insertpoint sim:/$TB_TOP/DUT/u_write_handler/*
add wave -position insertpoint sim:/$TB_TOP/DUT/u_read_handler/*

puts ""
puts "=========================================="
puts " Running Simulation & Saving Coverage"

# Automatically save UCDB coverage file upon simulation finish
coverage save $COV_UCDB -onexit
onbreak {resume}
run -all

# ============================================================
# Generate Text Coverage Report
vcover report C:\digital_electronics\Projects\async_fifo\reports\fifo_coverage.ucdb -details -annotate -all -output C:\digital_electronics\Projects\async_fifo\reports\rpt.txt