#--------------------------------------------------------
set target_clock  XXX ; # Please set a target clock name
set target_pin_N  YYY ; # Please put in your target pins
set direction     U ; # U|D|L|R
#--------------------------------------------------------

set stepnum 10 ; # Please change the number according to your own needs
set target_pin [get_pins $target_pin_N]
set startx  [lindex [get_attri [get_cells -of $target_pin] origin] 0]
set starty  [lindex [get_attri [get_cells -of $target_pin] origin] 1]

echo "Choo-INFO: Add latency [expr $stepnum*27.65*2]\[ps\] by insert buffer [expr ${stepnum}*2]pcs."

  for {set i 1} {$i<=$stepnum} {incr i} {
    insert_buffer [get_pins $target_pin] \
      CKND4BWP240H11P57CPDLVT \
      -inverter_pair \
      -new_net_name "ADJ_${target_clock}_LATENCY_NET_${i}_1 ADJ_${target_clock}_LATENCY_NET_${i}_2" \
      -new_cell_name "ADJ_${target_clock}_LATENCY_INST_${i}_1 ADJ_${target_clock}_LATENCY_INST_${i}_2"
  }

source ./place_adjust_bufinv.mod.tcl
  place_adjust_bufinv [get_cells -hier -phys -filter "name=~ADJ_${target_clock}_LATENCY_INST_*"] \
  $startx \
  $starty \
  $direction \
  50 ; #Pitch distance between cells inserted 
