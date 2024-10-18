set_global_assignment -entity "vga" -library "lib_vga" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "vga" -library "lib_vga" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "vga" -library "lib_vga" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_vga" -name SPD_FILE [file join $::quartus(sip_path) "../vga.spd"]
set_global_assignment -library "lib_vga" -name MISC_FILE [file join $::quartus(sip_path) "../../vga.qsys"]

set_global_assignment -library "lib_vga" -name MISC_FILE [file join $::quartus(sip_path) "vga.v"]
