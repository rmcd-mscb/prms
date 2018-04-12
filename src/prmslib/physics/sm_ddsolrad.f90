submodule (PRMS_DDSOLRAD) sm_ddsolrad
contains
  !***********************************************************************
  ! Ddsolrad constructor
  module function constructor_Ddsolrad(ctl_data) result(this)
    ! use Control_class, only: Control
    use UTILS_PRMS, only: print_module_info
    implicit none

    type(Ddsolrad) :: this
    type(Control), intent(in) :: ctl_data

    ! ------------------------------------------------------------------------
    associate(print_debug => ctl_data%print_debug%value)
      if (print_debug > -2) then
        ! Output module and version information
        call print_module_info(MODNAME, MODDESC, MODVERSION)
      endif

    end associate
  end function


  module subroutine run_Ddsolrad(this, ctl_data, param_data, model_time, solt, climate, model_basin)
    ! use Control_class, only: Control
    ! use Parameters_class, only: Parameters
    ! use PRMS_BASIN, only: Basin
    ! use PRMS_CLIMATEVARS, only: Climateflow
    ! use PRMS_SOLTAB, only: Soltab
    ! use PRMS_SET_TIME, only: Time_t

    implicit none

    class(Ddsolrad), intent(in) :: this
    type(Control), intent(in) :: ctl_data
    type(Parameters), intent(in) :: param_data
    type(Time_t), intent(in) :: model_time
    type(Soltab), intent(in) :: solt
    type(Climateflow), intent(inout) :: climate
    type(Basin), intent(inout) :: model_basin


    ! Functions
    INTRINSIC INT, FLOAT, DBLE, SNGL

    ! Local Variables
    integer(i32) :: chru
    integer(i32) :: jj
    integer(i32) :: kp
    integer(i32) :: kp1
    integer(i32) :: idx1D
      !! 1D index from 2D
    real(r32) :: pptadj
    real(r32) :: radadj
    real(r32) :: dday
    real(r32) :: ddayi

    !***********************************************************************

    !rsr using julian day as the soltab arrays are filled by julian day
    climate%basin_horad = solt%soltab_basinpotsw(model_time%day_of_year)
    climate%basin_swrad = 0.0D0
    climate%basin_orad = 0.0D0

    do jj = 1, model_basin%active_hrus
      chru = model_basin%hru_route_order(jj)
      idx1D = (model_time%Nowmonth - 1) * ctl_data%nhru%values(1) + chru

      ! set degree day and radiation adjustment limited by radmax
      dday = param_data%dday_slope%values(idx1D) * climate%tmax_hru(chru) + &
             param_data%dday_intcp%values(idx1D) + 1.0
      if (dday < 1.0) dday = 1.0

      if (dday < 26.0) then
        kp = INT(dday)
        ddayi = FLOAT(kp)
        kp1 = kp + 1
        radadj = SOLF(kp) + ((SOLF(kp1) - SOLF(kp)) * (dday - ddayi))

        if (radadj > param_data%radmax%values(idx1D)) then
          radadj = param_data%radmax%values(idx1D)
        endif
      else
        radadj = param_data%radmax%values(idx1D)
      endif

      ! Set precipitation adjument factor based on temperature
      ! and amount of precipitation
      pptadj = 1.0
      if (climate%hru_ppt(chru) > param_data%ppt_rad_adj%values(idx1D)) then
        if (climate%tmax_hru(chru) < param_data%tmax_index%values(idx1D)) then
          pptadj = param_data%radj_sppt%values(chru)

          if (climate%tmax_hru(chru) >= climate%tmax_allrain(chru, model_time%Nowmonth)) then
            if (model_time%Summer_flag == 0) then
              ! Winter
              pptadj = param_data%radj_wppt%values(chru)
            endif
          else
            pptadj = param_data%radj_wppt%values(chru)
          endif
        else
          pptadj = param_data%radadj_intcp%values(idx1D) + &
                   param_data%radadj_slope%values(idx1D) * &
                   (climate%tmax_hru(chru) - param_data%tmax_index%values(idx1D))
          if (pptadj > 1.0) pptadj = 1.0
        endif
      endif

      radadj = radadj * pptadj
      if (radadj < 0.2) radadj = 0.2

      climate%orad_hru(chru) = radadj * SNGL(solt%soltab_horad_potsw(model_time%day_of_year, chru))
      climate%basin_orad = climate%basin_orad + &
                           DBLE(climate%orad_hru(chru) * param_data%hru_area%values(chru))
      climate%swrad(chru) = SNGL(solt%soltab_potsw(model_time%day_of_year, chru) / solt%soltab_horad_potsw(model_time%day_of_year, chru) * &
                            DBLE(climate%orad_hru(chru)) / solt%hru_cossl(chru))
      climate%basin_swrad = climate%basin_swrad + &
                            DBLE(climate%swrad(chru) * param_data%hru_area%values(chru))
    enddo

    climate%basin_orad = climate%basin_orad * model_basin%basin_area_inv
    climate%basin_swrad = climate%basin_swrad * model_basin%basin_area_inv
  end subroutine

end submodule
