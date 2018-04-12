submodule (Control_class) sm_control

contains

  !====================================================================!
  module function constructor_Control(control_filename) result(this)
    use iso_fortran_env
    use UTILS_PRMS, only: print_module_info
    implicit none

    type(Control) :: this
    character(len=*), intent(in) :: control_filename

    ! --------------------------------------------------------------------------
    ! if (print_debug > -2) then
      ! Output module and version information
      call print_module_info(MODNAME, MODDESC, MODVERSION)
    ! endif

    ! Initialize certain dimensions with default values
    this%ndays = iScalar(366)
    this%one = iScalar(1)
    this%nobs = iScalar(0)
    this%nrain = iScalar(0)
    this%ntemp = iScalar(0)

    ! Initialize defaults for some control file parameters
    this%prms_warmup = iScalar(0)

    this%control_filename = control_filename

    call this%read()

    this%model_output_unit = this%open_model_output_file()

    if (this%save_vars_to_file%values(1) == 1) then
      this%restart_output_unit = this%open_var_save_file()
    endif

    ! TODO: if print_debug > -2 output control file to model_output_file
    !                           model_output_file to stdout
    !       if print_debug > -1 output control file to stdout
    !                           output var_init_file to stdout (if used)
    !                           output var_save_file to stdout (if used)
  end function
  !====================================================================!

  !====================================================================!
  module subroutine read_Control(this) !, this%control_filename)
    use iso_fortran_env
    use variableKind, only: cLen
    use m_errors, only: eMsg, fErr, IO_OPEN
    use m_strings, only: compact, isString, lowerCase, str
    implicit none

    class(Control), intent(inout) :: this

    integer(i32) :: istat
      !! Contains the IOSTAT result from a read command
    integer(i32) :: iUnit
      !! Unit of the opened control file
    integer(i32) :: line
      !! Tracks the number of the last line read in the file
    character(len=cLen) :: buf
      !! Buffer for reading control file
    character(len=:), allocatable :: last
      !! Previous line read from file
    integer(i32), parameter :: ENTRY_OFFSET = 2
      !! Additional offset for counting entry line numbers

    logical :: go

    go = .true.

    iUnit = 1
    !call openFile(this%control_filename, iUnit, 'old', istat)
    open(unit=iUnit, file=this%control_filename, status='old', iostat=istat)
    call fErr(istat, this%control_filename, IO_OPEN)

    ! Read the Header line
    read(iUnit, 1) buf
    line = 1
    last = 'Header'

    ! Read the next line - should be '####'
    read(iUnit, 1) buf
    call compact(buf)
    line = line + 1

    do while (go)
      ! NOTE: This will break if a line has a comment included
      !       Comments after an entry are denoted with ' //'
      !       (not including ')
      if (isString(buf(1:4), '####', .true.)) then
        read(iUnit, 1) buf
        call compact(buf)
        line = line + 1
        last = trim(buf)

        select case(buf)
          ! Dimensions
          case('ncascade')
            this%ncascade%name = last
            call this%ncascade%read(iUnit)
            line = line + 1 + ENTRY_OFFSET
          case('ncascdgw')
            this%ncascdgw%name = last
            call this%ncascdgw%read(iUnit)
            line = line + this%ncascdgw%size() + ENTRY_OFFSET
          case('nconsumed')
            this%nconsumed%name = last
            call this%nconsumed%read(iUnit)
            line = line + this%nconsumed%size() + ENTRY_OFFSET
          case('ndays')
            this%ndays%name = last
            call this%ndays%read(iUnit)
            line = line + 1 + ENTRY_OFFSET
          case('ndepl')
            this%ndepl%name = last
            call this%ndepl%read(iUnit)
            line = line + this%ndepl%size() + ENTRY_OFFSET
          case('ndeplval')
            this%ndeplval%name = last
            call this%ndeplval%read(iUnit)
            line = line + this%ndeplval%size() + ENTRY_OFFSET
          case('nevap')
            this%nevap%name = last
            call this%nevap%read(iUnit)
            line = line + this%nevap%size() + ENTRY_OFFSET
          case('nexternal')
            this%nexternal%name = last
            call this%nexternal%read(iUnit)
            line = line + this%nexternal%size() + ENTRY_OFFSET
          case('ngw')
            this%ngw%name = last
            call this%ngw%read(iUnit)
            line = line + this%ngw%size() + ENTRY_OFFSET
          case('ngwcell')
            this%ngwcell%name = last
            call this%ngwcell%read(iUnit)
            line = line + this%ngwcell%size() + ENTRY_OFFSET
          case('nhru')
            this%nhru%name = last
            call this%nhru%read(iUnit)
            line = line + this%nhru%size() + ENTRY_OFFSET
          case('nhrucell')
            this%nhrucell%name = last
            call this%nhrucell%read(iUnit)
            line = line + this%nhrucell%size() + ENTRY_OFFSET
          case('nhumid')
            this%nhumid%name = last
            call this%nhumid%read(iUnit)
            line = line + this%nhumid%size() + ENTRY_OFFSET
          case('nlake')
            this%nlake%name = last
            call this%nlake%read(iUnit)
            line = line + this%nlake%size() + ENTRY_OFFSET
          case('nlakeelev')
            this%nlakeelev%name = last
            call this%nlakeelev%read(iUnit)
            line = line + this%nlakeelev%size() + ENTRY_OFFSET
          case('nlapse')
            this%nlapse%name = last
            call this%nlapse%read(iUnit)
            line = line + this%nlapse%size() + ENTRY_OFFSET
          case('nmonths')
            this%nmonths%name = last
            call this%nmonths%read(iUnit)
            line = line + 1 + ENTRY_OFFSET
          case('nobs')
            this%nobs%name = last
            call this%nobs%read(iUnit)
            line = line + 1 + ENTRY_OFFSET
          case('npoigages')
            this%npoigages%name = last
            call this%npoigages%read(iUnit)
            line = line + this%npoigages%size() + ENTRY_OFFSET
          case('nrain')
            this%nrain%name = last
            call this%nrain%read(iUnit)
            line = line + 1 + ENTRY_OFFSET
          case('nratetbl')
            this%nratetbl%name = last
            call this%nratetbl%read(iUnit)
            line = line + this%nratetbl%size() + ENTRY_OFFSET
          case('nsegment')
            this%nsegment%name = last
            call this%nsegment%read(iUnit)
            line = line + this%nsegment%size() + ENTRY_OFFSET
          case('nsnow')
            this%nsnow%name = last
            call this%nsnow%read(iUnit)
            line = line + this%nsnow%size() + ENTRY_OFFSET
          case('nsol')
            this%nsol%name = last
            call this%nsol%read(iUnit)
            line = line + this%nsol%size() + ENTRY_OFFSET
          case('nssr')
            this%nssr%name = last
            call this%nssr%read(iUnit)
            line = line + this%nssr%size() + ENTRY_OFFSET
          case('nsub')
            this%nsub%name = last
            call this%nsub%read(iUnit)
            line = line + this%nsub%size() + ENTRY_OFFSET
          case('ntemp')
            this%ntemp%name = last
            call this%ntemp%read(iUnit)
            line = line + 1 + ENTRY_OFFSET
          case('nwateruse')
            this%nwateruse%name = last
            call this%nwateruse%read(iUnit)
            line = line + this%nwateruse%size() + ENTRY_OFFSET
          case('nwind')
            this%nwind%name = last
            call this%nwind%read(iUnit)
            line = line + this%nwind%size() + ENTRY_OFFSET
          case('one')
            this%one%name = last
            call this%one%read(iUnit)
            line = line + 1 + ENTRY_OFFSET


          ! All other control file parameters
          case('aniOutON_OFF')
            this%aniOutON_OFF%name = last
            call this%aniOutON_OFF%read(iUnit)
            line = line + this%aniOutON_OFF%size() + ENTRY_OFFSET
          case('aniOutVar_names')
            this%aniOutVar_names%name = last
            call this%aniOutVar_names%read(iUnit)
            line = line + this%aniOutVar_names%size() + ENTRY_OFFSET
          case('ani_output_file')
            this%ani_output_file%name = last
            call this%ani_output_file%read(iUnit)
            line = line + this%ani_output_file%size() + ENTRY_OFFSET
          case('basinOutBaseFileName')
            this%basinOutBaseFileName%name = last
            call this%basinOutBaseFileName%read(iUnit)
            line = line + this%basinOutBaseFileName%size() + ENTRY_OFFSET
          case('basinOutON_OFF')
            this%basinOutON_OFF%name = last
            call this%basinOutON_OFF%read(iUnit)
            line = line + this%basinOutON_OFF%size() + ENTRY_OFFSET
          case('basinOutVar_names')
            this%basinOutVar_names%name = last
            call this%basinOutVar_names%read(iUnit)
            line = line + this%basinOutVar_names%size() + ENTRY_OFFSET
          case('basinOutVars')
            this%basinOutVars%name = last
            call this%basinOutVars%read(iUnit)
            line = line + this%basinOutVars%size() + ENTRY_OFFSET
          case('basinOut_freq')
            this%basinOut_freq%name = last
            call this%basinOut_freq%read(iUnit)
            line = line + this%basinOut_freq%size() + ENTRY_OFFSET
          case('canopy_transferON_OFF')
            this%canopy_transferON_OFF%name = last
            call this%canopy_transferON_OFF%read(iUnit)
            line = line + this%canopy_transferON_OFF%size() + ENTRY_OFFSET
          case('capillary_module')
            this%capillary_module%name = last
            call this%capillary_module%read(iUnit)
            line = line + this%capillary_module%size() + ENTRY_OFFSET
          case('cascade_flag')
            this%cascade_flag%name = last
            call this%cascade_flag%read(iUnit)
            line = line + this%cascade_flag%size() + ENTRY_OFFSET
          case('cascadegw_flag')
            this%cascadegw_flag%name = last
            call this%cascadegw_flag%read(iUnit)
            line = line + this%cascadegw_flag%size() + ENTRY_OFFSET
          case('cbh_binary_flag')
            this%cbh_binary_flag%name = last
            call this%cbh_binary_flag%read(iUnit)
            line = line + 1 + ENTRY_OFFSET
          case('cbh_check_flag')
            this%cbh_check_flag%name = last
            call this%cbh_check_flag%read(iUnit)
            line = line + 1 + ENTRY_OFFSET
          case('consumed_transferON_OFF')
            this%consumed_transferON_OFF%name = last
            call this%consumed_transferON_OFF%read(iUnit)
            line = line + this%consumed_transferON_OFF%size() + ENTRY_OFFSET
          case('covden_sum_dynamic')
            this%covden_sum_dynamic%name = last
            call this%covden_sum_dynamic%read(iUnit)
            line = line + this%covden_sum_dynamic%size() + ENTRY_OFFSET
          case('covden_win_dynamic')
            this%covden_win_dynamic%name = last
            call this%covden_win_dynamic%read(iUnit)
            line = line + this%covden_win_dynamic%size() + ENTRY_OFFSET
          case('covtype_dynamic')
            this%covtype_dynamic%name = last
            call this%covtype_dynamic%read(iUnit)
            line = line + this%covtype_dynamic%size() + ENTRY_OFFSET
          case('creator_email')
            this%creator_email%name = last
            call this%creator_email%read(iUnit)
            line = line + this%creator_email%size() + ENTRY_OFFSET
          case('csvON_OFF')
            this%csvON_OFF%name = last
            call this%csvON_OFF%read(iUnit)
            line = line + this%csvON_OFF%size() + ENTRY_OFFSET
          case('csv_output_file')
            this%csv_output_file%name = last
            call this%csv_output_file%read(iUnit)
            line = line + this%csv_output_file%size() + ENTRY_OFFSET
          case('data_file')
            this%data_file%name = last
            call this%data_file%read(iUnit)
            line = line + this%data_file%size() + ENTRY_OFFSET
          case('dispGraphsBuffSize')
            this%dispGraphsBuffSize%name = last
            call this%dispGraphsBuffSize%read(iUnit)
            line = line + this%dispGraphsBuffSize%size() + ENTRY_OFFSET
          case('dprst_area_dynamic')
            this%dprst_area_dynamic%name = last
            call this%dprst_area_dynamic%read(iUnit)
            line = line + this%dprst_area_dynamic%size() + ENTRY_OFFSET
          case('dprst_depth_dynamic')
            this%dprst_depth_dynamic%name = last
            call this%dprst_depth_dynamic%read(iUnit)
            line = line + this%dprst_depth_dynamic%size() + ENTRY_OFFSET
          case('dprst_flag')
            this%dprst_flag%name = last
            call this%dprst_flag%read(iUnit)
            line = line + this%dprst_flag%size() + ENTRY_OFFSET
          case('dprst_frac_dynamic')
            this%dprst_frac_dynamic%name = last
            call this%dprst_frac_dynamic%read(iUnit)
            line = line + this%dprst_frac_dynamic%size() + ENTRY_OFFSET
          case('dprst_transferON_OFF')
            this%dprst_transferON_OFF%name = last
            call this%dprst_transferON_OFF%read(iUnit)
            line = line + this%dprst_transferON_OFF%size() + ENTRY_OFFSET
          case('dyn_covden_flag')
            this%dyn_covden_flag%name = last
            call this%dyn_covden_flag%read(iUnit)
            line = line + this%dyn_covden_flag%size() + ENTRY_OFFSET
          case('dyn_covtype_flag')
            this%dyn_covtype_flag%name = last
            call this%dyn_covtype_flag%read(iUnit)
            line = line + this%dyn_covtype_flag%size() + ENTRY_OFFSET
          case('dyn_dprst_flag')
            this%dyn_dprst_flag%name = last
            call this%dyn_dprst_flag%read(iUnit)
            line = line + this%dyn_dprst_flag%size() + ENTRY_OFFSET
          case('dyn_fallfrost_flag')
            this%dyn_fallfrost_flag%name = last
            call this%dyn_fallfrost_flag%read(iUnit)
            line = line + this%dyn_fallfrost_flag%size() + ENTRY_OFFSET
          case('dyn_imperv_flag')
            this%dyn_imperv_flag%name = last
            call this%dyn_imperv_flag%read(iUnit)
            line = line + this%dyn_imperv_flag%size() + ENTRY_OFFSET
          case('dyn_intcp_flag')
            this%dyn_intcp_flag%name = last
            call this%dyn_intcp_flag%read(iUnit)
            line = line + this%dyn_intcp_flag%size() + ENTRY_OFFSET
          case('dyn_potet_flag')
            this%dyn_potet_flag%name = last
            call this%dyn_potet_flag%read(iUnit)
            line = line + this%dyn_potet_flag%size() + ENTRY_OFFSET
          case('dyn_radtrncf_flag')
            this%dyn_radtrncf_flag%name = last
            call this%dyn_radtrncf_flag%read(iUnit)
            line = line + this%dyn_radtrncf_flag%size() + ENTRY_OFFSET
          case('dyn_snareathresh_flag')
            this%dyn_snareathresh_flag%name = last
            call this%dyn_snareathresh_flag%read(iUnit)
            line = line + this%dyn_snareathresh_flag%size() + ENTRY_OFFSET
          case('dyn_soil_flag')
            this%dyn_soil_flag%name = last
            call this%dyn_soil_flag%read(iUnit)
            line = line + this%dyn_soil_flag%size() + ENTRY_OFFSET
          case('dyn_springfrost_flag')
            this%dyn_springfrost_flag%name = last
            call this%dyn_springfrost_flag%read(iUnit)
            line = line + this%dyn_springfrost_flag%size() + ENTRY_OFFSET
          case('dyn_sro2dprst_imperv_flag')
            this%dyn_sro2dprst_imperv_flag%name = last
            call this%dyn_sro2dprst_imperv_flag%read(iUnit)
            line = line + this%dyn_sro2dprst_imperv_flag%size() + ENTRY_OFFSET
          case('dyn_sro2dprst_perv_flag')
            this%dyn_sro2dprst_perv_flag%name = last
            call this%dyn_sro2dprst_perv_flag%read(iUnit)
            line = line + this%dyn_sro2dprst_perv_flag%size() + ENTRY_OFFSET
          case('dyn_sro_to_dprst_flag')
            this%dyn_sro_to_dprst_flag%name = last
            call this%dyn_sro_to_dprst_flag%read(iUnit)
            line = line + this%dyn_sro_to_dprst_flag%size() + ENTRY_OFFSET
          case('dyn_sro_to_imperv_flag')
            this%dyn_sro_to_imperv_flag%name = last
            call this%dyn_sro_to_imperv_flag%read(iUnit)
            line = line + this%dyn_sro_to_imperv_flag%size() + ENTRY_OFFSET
          case('dyn_transp_flag')
            this%dyn_transp_flag%name = last
            call this%dyn_transp_flag%read(iUnit)
            line = line + this%dyn_transp_flag%size() + ENTRY_OFFSET
          case('dyn_transp_on_flag')
            this%dyn_transp_on_flag%name = last
            call this%dyn_transp_on_flag%read(iUnit)
            line = line + this%dyn_transp_on_flag%size() + ENTRY_OFFSET
          case('end_time')
            this%end_time%name = last
            call this%end_time%read(iUnit)
            line = line + this%end_time%size() + ENTRY_OFFSET
          case('et_module')
            this%et_module%name = last
            call this%et_module%read(iUnit)
            line = line + this%et_module%size() + ENTRY_OFFSET
          case('executable_desc')
            this%executable_desc%name = last
            call this%executable_desc%read(iUnit)
            line = line + this%executable_desc%size() + ENTRY_OFFSET
          case('executable_model')
            this%executable_model%name = last
            call this%executable_model%read(iUnit)
            line = line + this%executable_model%size() + ENTRY_OFFSET
          case('external_transferON_OFF')
            this%external_transferON_OFF%name = last
            call this%external_transferON_OFF%read(iUnit)
            line = line + this%external_transferON_OFF%size() + ENTRY_OFFSET
          case('fallfrost_dynamic')
            this%fallfrost_dynamic%name = last
            call this%fallfrost_dynamic%read(iUnit)
            line = line + this%fallfrost_dynamic%size() + ENTRY_OFFSET
          case('frozen_flag')
            this%frozen_flag%name = last
            call this%frozen_flag%read(iUnit)
            line = line + this%frozen_flag%size() + ENTRY_OFFSET
          case('glacier_flag')
            this%glacier_flag%name = last
            call this%glacier_flag%read(iUnit)
            line = line + this%glacier_flag%size() + ENTRY_OFFSET
          case('gsf_rpt')
            this%gsf_rpt%name = last
            call this%gsf_rpt%read(iUnit)
            line = line + this%gsf_rpt%size() + ENTRY_OFFSET
          case('gsflow_csv_file')
            this%gsflow_csv_file%name = last
            call this%gsflow_csv_file%read(iUnit)
            line = line + this%gsflow_csv_file%size() + ENTRY_OFFSET
          case('gsflow_output_file')
            this%gsflow_output_file%name = last
            call this%gsflow_output_file%read(iUnit)
            line = line + this%gsflow_output_file%size() + ENTRY_OFFSET
          case('gwflow_cbh_flag')
            this%gwflow_cbh_flag%name = last
            call this%gwflow_cbh_flag%read(iUnit)
            line = line + this%gwflow_cbh_flag%size() + ENTRY_OFFSET
          case('gwr_swale_flag')
            this%gwr_swale_flag%name = last
            call this%gwr_swale_flag%read(iUnit)
            line = line + this%gwr_swale_flag%size() + ENTRY_OFFSET
          case('gwr_transferON_OFF')
            this%gwr_transferON_OFF%name = last
            call this%gwr_transferON_OFF%read(iUnit)
            line = line + this%gwr_transferON_OFF%size() + ENTRY_OFFSET
          case('gwres_flow_day')
            this%gwres_flow_day%name = last
            call this%gwres_flow_day%read(iUnit)
            line = line + this%gwres_flow_day%size() + ENTRY_OFFSET
          case('humidity_cbh_flag')
            this%humidity_cbh_flag%name = last
            call this%humidity_cbh_flag%read(iUnit)
            line = line + this%humidity_cbh_flag%size() + ENTRY_OFFSET
          case('humidity_day')
            this%humidity_day%name = last
            call this%humidity_day%read(iUnit)
            line = line + this%humidity_day%size() + ENTRY_OFFSET
          case('ignore_data_file_end')
            this%ignore_data_file_end%name = last
            call this%ignore_data_file_end%read(iUnit)
            line = line + this%ignore_data_file_end%size() + ENTRY_OFFSET
          case('imperv_frac_dynamic')
            this%imperv_frac_dynamic%name = last
            call this%imperv_frac_dynamic%read(iUnit)
            line = line + this%imperv_frac_dynamic%size() + ENTRY_OFFSET
          case('imperv_stor_dynamic')
            this%imperv_stor_dynamic%name = last
            call this%imperv_stor_dynamic%read(iUnit)
            line = line + this%imperv_stor_dynamic%size() + ENTRY_OFFSET
          case('init_vars_from_file')
            this%init_vars_from_file%name = last
            call this%init_vars_from_file%read(iUnit)
            line = line + this%init_vars_from_file%size() + ENTRY_OFFSET
          case('initial_deltat')
            this%initial_deltat%name = last
            call this%initial_deltat%read(iUnit)
            line = line + this%initial_deltat%size() + ENTRY_OFFSET
          case('jhcoef_dynamic')
            this%jhcoef_dynamic%name = last
            call this%jhcoef_dynamic%read(iUnit)
            line = line + this%jhcoef_dynamic%size() + ENTRY_OFFSET
          case('lake_transferON_OFF')
            this%lake_transferON_OFF%name = last
            call this%lake_transferON_OFF%read(iUnit)
            line = line + this%lake_transferON_OFF%size() + ENTRY_OFFSET
          case('mapOutON_OFF')
            this%mapOutON_OFF%name = last
            call this%mapOutON_OFF%read(iUnit)
            line = line + this%mapOutON_OFF%size() + ENTRY_OFFSET
          case('mapOutVar_names')
            this%mapOutVar_names%name = last
            call this%mapOutVar_names%read(iUnit)
            line = line + this%mapOutVar_names%size() + ENTRY_OFFSET
          case('mbInit_flag')
            this%mbInit_flag%name = last
            call this%mbInit_flag%read(iUnit)
            line = line + this%mbInit_flag%size() + ENTRY_OFFSET
          case('model_mode')
            this%model_mode%name = last
            call this%model_mode%read(iUnit)
            line = line + this%model_mode%size() + ENTRY_OFFSET
          case('model_output_file')
            this%model_output_file%name = last
            call this%model_output_file%read(iUnit)
            line = line + this%model_output_file%size() + ENTRY_OFFSET
          case('modflow_name')
            this%modflow_name%name = last
            call this%modflow_name%read(iUnit)
            line = line + this%modflow_name%size() + ENTRY_OFFSET
          case('modflow_time_zero')
            this%modflow_time_zero%name = last
            call this%modflow_time_zero%read(iUnit)
            line = line + this%modflow_time_zero%size() + ENTRY_OFFSET
          case('musroute_flag')
            this%musroute_flag%name = last
            call this%musroute_flag%read(iUnit)
            line = line + this%musroute_flag%size() + ENTRY_OFFSET
          case('naniOutVars')
            this%naniOutVars%name = last
            call this%naniOutVars%read(iUnit)
            line = line + this%naniOutVars%size() + ENTRY_OFFSET
          case('ndispGraphs')
            this%ndispGraphs%name = last
            call this%ndispGraphs%read(iUnit)
            line = line + this%ndispGraphs%size() + ENTRY_OFFSET
          case('nhruOutBaseFileName')
            this%nhruOutBaseFileName%name = last
            call this%nhruOutBaseFileName%read(iUnit)
            line = line + this%nhruOutBaseFileName%size() + ENTRY_OFFSET
          case('nhruOutON_OFF')
            this%nhruOutON_OFF%name = last
            call this%nhruOutON_OFF%read(iUnit)
            line = line + this%nhruOutON_OFF%size() + ENTRY_OFFSET
          case('nhruOutVar_names')
            this%nhruOutVar_names%name = last
            call this%nhruOutVar_names%read(iUnit)
            line = line + this%nhruOutVar_names%size() + ENTRY_OFFSET
          case('nhruOutVars')
            this%nhruOutVars%name = last
            call this%nhruOutVars%read(iUnit)
            line = line + this%nhruOutVars%size() + ENTRY_OFFSET
          case('nhruOut_freq')
            this%nhruOut_freq%name = last
            call this%nhruOut_freq%read(iUnit)
            line = line + this%nhruOut_freq%size() + ENTRY_OFFSET
          case('nmapOutVars')
            this%nmapOutVars%name = last
            call this%nmapOutVars%read(iUnit)
            line = line + this%nmapOutVars%size() + ENTRY_OFFSET
          case('nsegmentOutBaseFileName')
            this%nsegmentOutBaseFileName%name = last
            call this%nsegmentOutBaseFileName%read(iUnit)
            line = line + this%nsegmentOutBaseFileName%size() + ENTRY_OFFSET
          case('nsegmentOutON_OFF')
            this%nsegmentOutON_OFF%name = last
            call this%nsegmentOutON_OFF%read(iUnit)
            line = line + this%nsegmentOutON_OFF%size() + ENTRY_OFFSET
          case('nsegmentOutVars')
            this%nsegmentOutVars%name = last
            call this%nsegmentOutVars%read(iUnit)
            line = line + this%nsegmentOutVars%size() + ENTRY_OFFSET
          case('nsegmentOut_freq')
            this%nsegmentOut_freq%name = last
            call this%nsegmentOut_freq%read(iUnit)
            line = line + this%nsegmentOut_freq%size() + ENTRY_OFFSET
          case('nstatVars')
            this%nstatVars%name = last
            call this%nstatVars%read(iUnit)
            line = line + this%nstatVars%size() + ENTRY_OFFSET
          case('nsubOutBaseFileName')
            this%nsubOutBaseFileName%name = last
            call this%nsubOutBaseFileName%read(iUnit)
            line = line + this%nsubOutBaseFileName%size() + ENTRY_OFFSET
          case('nsubOutON_OFF')
            this%nsubOutON_OFF%name = last
            call this%nsubOutON_OFF%read(iUnit)
            line = line + this%nsubOutON_OFF%size() + ENTRY_OFFSET
          case('nsubOutVar_names')
            this%nsubOutVar_names%name = last
            call this%nsubOutVar_names%read(iUnit)
            line = line + this%nsubOutVar_names%size() + ENTRY_OFFSET
          case('nsubOutVars')
            this%nsubOutVars%name = last
            call this%nsubOutVars%read(iUnit)
            line = line + this%nsubOutVars%size() + ENTRY_OFFSET
          case('nsubOut_freq')
            this%nsubOut_freq%name = last
            call this%nsubOut_freq%read(iUnit)
            line = line + this%nsubOut_freq%size() + ENTRY_OFFSET
          case('orad_flag')
            this%orad_flag%name = last
            call this%orad_flag%read(iUnit)
            line = line + this%orad_flag%size() + ENTRY_OFFSET
          case('param_file')
            this%param_file%name = last
            call this%param_file%read(iUnit)
            line = line + this%param_file%size() + ENTRY_OFFSET
          case('parameter_check_flag')
            this%parameter_check_flag%name = last
            call this%parameter_check_flag%read(iUnit)
            line = line + this%parameter_check_flag%size() + ENTRY_OFFSET
          case('pk_depth_day')
            this%pk_depth_day%name = last
            call this%pk_depth_day%read(iUnit)
            line = line + this%pk_depth_day%size() + ENTRY_OFFSET
          case('pkwater_equiv_day')
            this%pkwater_equiv_day%name = last
            call this%pkwater_equiv_day%read(iUnit)
            line = line + this%pkwater_equiv_day%size() + ENTRY_OFFSET
          case('potet_coef_dynamic')
            this%potet_coef_dynamic%name = last
            call this%potet_coef_dynamic%read(iUnit)
            line = line + this%potet_coef_dynamic%size() + ENTRY_OFFSET
          case('potet_day')
            this%potet_day%name = last
            call this%potet_day%read(iUnit)
            line = line + this%potet_day%size() + ENTRY_OFFSET
          case('precip_day')
            this%precip_day%name = last
            call this%precip_day%read(iUnit)
            line = line + this%precip_day%size() + ENTRY_OFFSET
          case('precip_module')
            this%precip_module%name = last
            call this%precip_module%read(iUnit)
            line = line + this%precip_module%size() + ENTRY_OFFSET
          case('print_debug')
            this%print_debug%name = last
            call this%print_debug%read(iUnit)
            line = line + 1 + ENTRY_OFFSET
          case('prms_warmup')
            this%prms_warmup%name = last
            call this%prms_warmup%read(iUnit)
            line = line + 1 + ENTRY_OFFSET
          case('radtrncf_dynamic')
            this%radtrncf_dynamic%name = last
            call this%radtrncf_dynamic%read(iUnit)
            line = line + this%radtrncf_dynamic%size() + ENTRY_OFFSET
          case('rpt_days')
            this%rpt_days%name = last
            call this%rpt_days%read(iUnit)
            line = line + this%rpt_days%size() + ENTRY_OFFSET
          case('save_vars_to_file')
            this%save_vars_to_file%name = last
            call this%save_vars_to_file%read(iUnit)
            line = line + this%save_vars_to_file%size() + ENTRY_OFFSET
          case('seg2hru_flag')
            this%seg2hru_flag%name = last
            call this%seg2hru_flag%read(iUnit)
            line = line + this%seg2hru_flag%size() + ENTRY_OFFSET
          case('segmentOutON_OFF')
            this%segmentOutON_OFF%name = last
            call this%segmentOutON_OFF%read(iUnit)
            line = line + this%segmentOutON_OFF%size() + ENTRY_OFFSET
          case('segmentOutVar_names')
            this%segmentOutVar_names%name = last
            call this%segmentOutVar_names%read(iUnit)
            line = line + this%segmentOutVar_names%size() + ENTRY_OFFSET
          case('segment_transferON_OFF')
            this%segment_transferON_OFF%name = last
            call this%segment_transferON_OFF%read(iUnit)
            line = line + this%segment_transferON_OFF%size() + ENTRY_OFFSET
          case('snow_cbh_flag')
            this%snow_cbh_flag%name = last
            call this%snow_cbh_flag%read(iUnit)
            line = line + this%snow_cbh_flag%size() + ENTRY_OFFSET
          case('snow_evap_day')
            this%snow_evap_day%name = last
            call this%snow_evap_day%read(iUnit)
            line = line + this%snow_evap_day%size() + ENTRY_OFFSET
          case('snow_intcp_dynamic')
            this%snow_intcp_dynamic%name = last
            call this%snow_intcp_dynamic%read(iUnit)
            line = line + this%snow_intcp_dynamic%size() + ENTRY_OFFSET
          case('snowcov_area_day')
            this%snowcov_area_day%name = last
            call this%snowcov_area_day%read(iUnit)
            line = line + this%snowcov_area_day%size() + ENTRY_OFFSET
          case('snowmelt_day')
            this%snowmelt_day%name = last
            call this%snowmelt_day%read(iUnit)
            line = line + this%snowmelt_day%size() + ENTRY_OFFSET
          case('soilmoist_dynamic')
            this%soilmoist_dynamic%name = last
            call this%soilmoist_dynamic%read(iUnit)
            line = line + this%soilmoist_dynamic%size() + ENTRY_OFFSET
          case('soilrechr_dynamic')
            this%soilrechr_dynamic%name = last
            call this%soilrechr_dynamic%read(iUnit)
            line = line + this%soilrechr_dynamic%size() + ENTRY_OFFSET
          case('soilzone_module')
            this%soilzone_module%name = last
            call this%soilzone_module%read(iUnit)
            line = line + this%soilzone_module%size() + ENTRY_OFFSET
          case('soilzone_transferON_OFF')
            this%soilzone_transferON_OFF%name = last
            call this%soilzone_transferON_OFF%read(iUnit)
            line = line + this%soilzone_transferON_OFF%size() + ENTRY_OFFSET
          case('solrad_module')
            this%solrad_module%name = last
            call this%solrad_module%read(iUnit)
            line = line + this%solrad_module%size() + ENTRY_OFFSET
          case('springfrost_dynamic')
            this%springfrost_dynamic%name = last
            call this%springfrost_dynamic%read(iUnit)
            line = line + this%springfrost_dynamic%size() + ENTRY_OFFSET
          case('srain_intcp_dynamic')
            this%srain_intcp_dynamic%name = last
            call this%srain_intcp_dynamic%read(iUnit)
            line = line + this%srain_intcp_dynamic%size() + ENTRY_OFFSET
          case('sro2dprst_imperv_dynamic')
            this%sro2dprst_imperv_dynamic%name = last
            call this%sro2dprst_imperv_dynamic%read(iUnit)
            line = line + this%sro2dprst_imperv_dynamic%size() + ENTRY_OFFSET
          case('sro2dprst_perv_dynamic')
            this%sro2dprst_perv_dynamic%name = last
            call this%sro2dprst_perv_dynamic%read(iUnit)
            line = line + this%sro2dprst_perv_dynamic%size() + ENTRY_OFFSET
          case('srunoff_module')
            this%srunoff_module%name = last
            call this%srunoff_module%read(iUnit)
            line = line + this%srunoff_module%size() + ENTRY_OFFSET
          case('start_time')
            this%start_time%name = last
            call this%start_time%read(iUnit)
            line = line + this%start_time%size() + ENTRY_OFFSET
          case('stat_var_file')
            this%stat_var_file%name = last
            call this%stat_var_file%read(iUnit)
            line = line + this%stat_var_file%size() + ENTRY_OFFSET
          case('statsON_OFF')
            this%statsON_OFF%name = last
            call this%statsON_OFF%read(iUnit)
            line = line + this%statsON_OFF%size() + ENTRY_OFFSET
          case('stats_output_file')
            this%stats_output_file%name = last
            call this%stats_output_file%read(iUnit)
            line = line + this%stats_output_file%size() + ENTRY_OFFSET
          case('stream_temp_flag')
            this%stream_temp_flag%name = last
            call this%stream_temp_flag%read(iUnit)
            line = line + this%stream_temp_flag%size() + ENTRY_OFFSET
          case('stream_temp_shade_flag')
            this%stream_temp_shade_flag%name = last
            call this%stream_temp_shade_flag%read(iUnit)
            line = line + this%stream_temp_shade_flag%size() + ENTRY_OFFSET
          case('strmflow_module')
            this%strmflow_module%name = last
            call this%strmflow_module%read(iUnit)
            line = line + this%strmflow_module%size() + ENTRY_OFFSET
          case('subbasin_flag')
            this%subbasin_flag%name = last
            call this%subbasin_flag%read(iUnit)
            line = line + this%subbasin_flag%size() + ENTRY_OFFSET
          case('swrad_day')
            this%swrad_day%name = last
            call this%swrad_day%read(iUnit)
            line = line + this%swrad_day%size() + ENTRY_OFFSET
          case('temp_module')
            this%temp_module%name = last
            call this%temp_module%read(iUnit)
            line = line + this%temp_module%size() + ENTRY_OFFSET
          case('tmax_day')
            this%tmax_day%name = last
            call this%tmax_day%read(iUnit)
            line = line + this%tmax_day%size() + ENTRY_OFFSET
          case('tmin_day')
            this%tmin_day%name = last
            call this%tmin_day%read(iUnit)
            line = line + this%tmin_day%size() + ENTRY_OFFSET
          case('transp_day')
            this%transp_day%name = last
            call this%transp_day%read(iUnit)
            line = line + this%transp_day%size() + ENTRY_OFFSET
          case('transp_module')
            this%transp_module%name = last
            call this%transp_module%read(iUnit)
            line = line + this%transp_module%size() + ENTRY_OFFSET
          case('transp_on_dynamic')
            this%transp_on_dynamic%name = last
            call this%transp_on_dynamic%read(iUnit)
            line = line + this%transp_on_dynamic%size() + ENTRY_OFFSET
          case('transpbeg_dynamic')
            this%transpbeg_dynamic%name = last
            call this%transpbeg_dynamic%read(iUnit)
            line = line + this%transpbeg_dynamic%size() + ENTRY_OFFSET
          case('transpend_dynamic')
            this%transpend_dynamic%name = last
            call this%transpend_dynamic%read(iUnit)
            line = line + this%transpend_dynamic%size() + ENTRY_OFFSET
          case('var_init_file')
            this%var_init_file%name = last
            call this%var_init_file%read(iUnit)
            line = line + this%var_init_file%size() + ENTRY_OFFSET
          case('var_save_file')
            this%var_save_file%name = last
            call this%var_save_file%read(iUnit)
            line = line + this%var_save_file%size() + ENTRY_OFFSET
          case('windspeed_cbh_flag')
            this%windspeed_cbh_flag%name = last
            call this%windspeed_cbh_flag%read(iUnit)
            line = line + this%windspeed_cbh_flag%size() + ENTRY_OFFSET
          case('windspeed_day')
            this%windspeed_day%name = last
            call this%windspeed_day%read(iUnit)
            line = line + this%windspeed_day%size() + ENTRY_OFFSET
          case('wrain_intcp_dynamic')
            this%wrain_intcp_dynamic%name = last
            call this%wrain_intcp_dynamic%read(iUnit)
            line = line + this%wrain_intcp_dynamic%size() + ENTRY_OFFSET
          case default
            ! Skip to the next ####
        end select
      else
        ! Backup the line counter by one which will be where the problem occurred
        line = line - 1

        call eMsg("Could not read from file " // this%control_filename // &
                  " for entry " // last // " at line " // str(line))
      endif

      read(iUnit, 1, IOSTAT=istat) buf
      if (istat == IOSTAT_END) exit
      call compact(buf)
      line = line + 1
    enddo

    call closeFile(this%control_filename, iUnit, '', istat)
    1   format(a)
  end subroutine


  module function open_model_output_file(this)
    !! Opens the model_output_file, if present, and sets this%model_output_unit
    use m_errors, only: fErr, IO_OPEN
    implicit none

    integer(i32) :: open_model_output_file
    class(Control), intent(inout) :: this

    integer(i32) :: istat
    integer(i32) :: iunit

    ! --------------------------------------------------------------------------
    if (allocated(this%model_output_file%values)) then
      open(newunit=iunit, file=this%model_output_file%values(1)%s, status='replace', iostat=istat)

      call fErr(istat, this%model_output_file%values(1)%s, IO_OPEN)

      open_model_output_file = iunit
    endif
  end function


  module function open_var_save_file(this)
    !! Open the var_save_file (aka restart file)
    use m_errors, only: fErr, IO_OPEN
    implicit none

    integer(i32) :: open_var_save_file
    class(Control), intent(inout) :: this

    integer(i32) :: istat
    integer(i32) :: iunit

    ! --------------------------------------------------------------------------
    if (allocated(this%var_save_file%values)) then
      open(newunit=iunit, file=this%var_save_file%values(1)%s, status='replace', &
           form='unformatted', access='stream', iostat=istat)

      call fErr(istat, this%var_save_file%values(1)%s, IO_OPEN)

      open_var_save_file = iunit
    endif
  end function

end submodule
