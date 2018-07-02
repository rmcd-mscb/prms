module SOLAR_RADIATION_DEGDAY
  use variableKind
  use SOLAR_RADIATION, only: SolarRadiation
  use Control_class, only: Control
  use Parameters_class, only: Parameters
  use PRMS_BASIN, only: Basin
  use PRMS_CLIMATEVARS, only: Climateflow
  use PRMS_OBS, only: Obs
  use PRMS_SET_TIME, only: Time_t
  implicit none

  private
  public :: Solrad_degday

  character(len=*), parameter :: MODDESC = 'Solar Radiation Distribution'
  character(len=*), parameter :: MODNAME = 'solrad_degday'
  character(len=*), parameter :: MODVERSION = '2018-07-02 14:04:00Z'

  real(r32), dimension(26), parameter :: SOLF = [.20, .35, .45, .51, .56, .59, &
                                                 .62, .64, .655, .67, .682, .69, &
                                                 .70, .71, .715, .72, .722, .724, &
                                                 .726, .728, .73, .734, .738, &
                                                 .742, .746, .75]

  type, extends(SolarRadiation) :: Solrad_degday
    logical, private :: has_obs_station
      !! When true has solar radiation stations available
    real(r32), private :: radiation_cv_factor
      !! Conversion factor to Langleys for measured radiation. Defaults to 1.0, but can be overridden by parameter rad_conv

    real(r32), allocatable :: orad_hru(:)

    contains
      procedure, public :: run => run_Solrad_degday
  end type

  interface Solrad_degday
    !! Solrad_degday constructor
    module function constructor_Solrad_degday(ctl_data, param_data, model_basin) result(this)
      type(Solrad_degday) :: this
        !! Solrad_degday class
      type(Control), intent(in) :: ctl_data
        !! Control file parameters
      type(Parameters), intent(in) :: param_data
        !! Parameters
      type(Basin), intent(in) :: model_basin
    end function
  end interface

  interface
    module subroutine run_Solrad_degday(this, ctl_data, param_data, model_time, model_obs, climate, model_basin)
      class(Solrad_degday), intent(inout) :: this
      type(Control), intent(in) :: ctl_data
      type(Parameters), intent(in) :: param_data
      type(Time_t), intent(in) :: model_time
      type(Obs), intent(in) :: model_obs
      ! type(Soltab), intent(in) :: solt
      type(Climateflow), intent(inout) :: climate
      type(Basin), intent(inout) :: model_basin
    end subroutine
  end interface
end module
