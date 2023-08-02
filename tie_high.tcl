set pins_list {
xxx
xxx
xxx
}

change_selection [get_pins $pins_list]
append_to_collection pins_list_2 [get_selection]
change_selection

set i 0
set E E02                ;# Put the ECO number
set F SameNetConnection  ;# Put the fixes name

foreach_in_collection pins $pins_list_2 {
  set tie_prefix ${E}_${F}_tie_high_i_${i}
  set net_prefix ${E}_${F}_tie_high_n_${i}
  set aa [get_attribute [get_pins $pins] full_name]
  set string $aa
  set tmp [split $string "/"]
  set tmp2 [join [lrange $tmp 0 end-2] "/"]
  set tmp3 [join [lrange $tmp 0 end-1] "/"]
  set tie_cells [join [list $tmp2 $tie_prefix] "/"]
  set net_name [join [list $tmp2 $net_prefix] "/"]
  set ori_net [get_net -of $pins]
  set xx [lindex [get_attribute $tmp3 origin] 0]
  set yy [lindex [get_attribute $tmp3 origin] 1]

    create_cell $tie_cells SNISCH240B57L11STVTCLHA ;# Please change the cell name accordingly
    create_net $net_name
    disconnect_net [get_nets $ori_net] [get_pins $pins]
    connect_net -net $net_name [get_pins -phy ${tie_cells}/Z]
    connect_net -net $net_name [get_pins -phy $pins]
    set_cell_location -coordinate [list $xx $yy] $tie_cells
    incr i
}

change_selection [get_cells -phy *tie_high*]
legalize_placement -cell [get_selection]
change_selection
