# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "FEATURE_TOP_ODMR" -parent ${Page_0}


}

proc update_PARAM_VALUE.FEATURE_TOP_ODMR { PARAM_VALUE.FEATURE_TOP_ODMR } {
	# Procedure called to update FEATURE_TOP_ODMR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FEATURE_TOP_ODMR { PARAM_VALUE.FEATURE_TOP_ODMR } {
	# Procedure called to validate FEATURE_TOP_ODMR
	return true
}


proc update_MODELPARAM_VALUE.FEATURE_TOP_ODMR { MODELPARAM_VALUE.FEATURE_TOP_ODMR PARAM_VALUE.FEATURE_TOP_ODMR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FEATURE_TOP_ODMR}] ${MODELPARAM_VALUE.FEATURE_TOP_ODMR}
}

