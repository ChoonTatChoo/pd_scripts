echo "Usage: place_adjust_bufinv <adjust_inst_list> <start_x> <start_y> <direction> <pitch> \[sort_descending:off>\] \[<offset_x:0.24\] \[offset_y:0.24\]"

proc place_adjust_bufinv {adjust_inst_list start_x start_y direction pitch {sort_descending off} {offset_x 0.24} {offset_y 0.24} } {
  if {[sizeof_collection [get_cells -quiet $adjust_inst_list]] == "0"} {
    echo "Error: Instance $adjust_inst_list not found"
    return
  }
  if {![regexp {^[\.0-9]*$} $start_x] || ![regexp {^[\.0-9]*$} $start_y] } {
    echo "Please set start location ($start_x,$start_y)"
    return
  }
  if {![regexp {^[NWES]$|^[UDRL]$} $direction] } {
    echo "Please set direction ($direction) : \[NWES\]|\[UDRL\]"
    return
  }
  if {![regexp {^[\.0-9]*$} $pitch] && $pitch < 0} {
    echo "Please set pitch ($pitch) > 0"
    return
  }
  if {![regexp {on|off|true|false} $sort_descending] } {
    echo "Please set sort_descending : on or off, true or false"
    return
  }
  if {![regexp {^[\.0-9]*$} $offset_x] } {
    echo "Please set offset_x to floating number ($offset_x)"
    return
  }
  if {![regexp {^[\.0-9]*$} $offset_y] } {
    echo "Please set offset_y to floating number ($offset_y)"
    return
  }

set crnt_snap [get_snap_setting -enabled]
set crnt_lock [get_edit_setting -ignore_locked]
set_snap_setting -enabled {false}
set_edit_setting -ignore_locked {true}

echo "INFO: start place_adjust_bufinv."
if {$sort_descending eq "on" || $sort_descending eq "true"} {
  set adjust_inst_list [sort_collection -descending [get_cells -quiet $adjust_inst_list] full_name]
} else {
  set adjust_inst_list [sort_collection [get_cells -quiet $adjust_inst_list] full_name]
}

set i 0

foreach_in_collection inst $adjust_inst_list {
  incr i
  set name [get_attribute $inst full_name]
  set odd [expr $i % 2]
    if {$i eq "1"} {
      set xxx $start_x
      set yyy $start_y
    } elseif {[regexp {[NU]} $direction] } {
        set xxx [expr $xxx + $offset_x * $odd]
        set yyy [expr $yyy + $pitch * (-1 ** $i) + $offset_y * $odd]
    } elseif {[regexp {[SD]} $direction] } {
        set xxx [expr $xxx + $offset_x * $odd]
        set yyy [expr $yyy - $pitch * (-1 ** $i) + $offset_y * $odd]
    } elseif {[regexp {[WL]} $direction] } {
        set xxx [expr $xxx - $pitch * (-1 ** $i) + $offset_x * $odd]
        set yyy [expr $yyy + $offset_y * $odd]
    } elseif {[regexp {[ER]} $direction] } {
        set xxx [expr $xxx + $pitch * (-1 ** $i) + $offset_x * $odd]
        set yyy [expr $yyy + $offset_y * $odd]
    }

echo "move_objects -to \"$xxx $yyy\" \[get_cells $name\]"
move_objects -to "$xxx $yyy" [get_cells $inst]
}
set nets [get_nets -of [get_pins -of $adjust_inst_list -filter "direction==out"]]
set_attr $nets net_type clock 
change_selection $adjust_inst_list
echo "INFO: end place_adjust_bufinv"

set_snap_setting -enabled $crnt_snap
set_edit_setting -ignore_locked $crnt_lock
}
