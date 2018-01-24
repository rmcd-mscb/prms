!***********************************************************************
!     Output a set of declared basin variables as CSV file
!***********************************************************************
MODULE PRMS_BASIN_SUMMARY
    use kinds_mod, only: r4, r8, i4, i8
    USE prms_constants, ONLY: MAXFILE_LENGTH
    use prms_module, only: BasinOutVars, BasinOut_freq, BasinOutVar_names, BasinOutBaseFileName
    use control_ll_mod, only: control_list
    IMPLICIT NONE

    ! Module Variables
    INTEGER(i4), SAVE :: Begin_results
    INTEGER(i4), SAVE :: Begyr
    INTEGER(i4), SAVE :: Lastyear
    INTEGER(i4), SAVE :: Dailyunit
    INTEGER(i4), SAVE :: Monthlyunit
    INTEGER(i4), SAVE :: Yearlyunit
    INTEGER(i4), SAVE :: Basin_var_type
    INTEGER(i4), SAVE, ALLOCATABLE :: Nc_vars(:)
    CHARACTER(LEN=48), SAVE :: Output_fmt
    CHARACTER(LEN=48), SAVE :: Output_fmt2
    CHARACTER(LEN=48), SAVE :: Output_fmt3
    CHARACTER(LEN=13), SAVE :: MODNAME
    INTEGER(i4), SAVE :: Daily_flag
    INTEGER(i4), SAVE :: Yeardays
    INTEGER(i4), SAVE :: Monthly_flag
    real(r8), SAVE :: Monthdays
    real(r8), SAVE, ALLOCATABLE :: Basin_var_daily(:)
    real(r8), SAVE, ALLOCATABLE :: Basin_var_monthly(:)
    real(r8), SAVE, ALLOCATABLE :: Basin_var_yearly(:)

    private :: basin_summarydecl, basin_summaryinit, basin_summaryrun
    public :: basin_summary

    contains
        ! ******************************************************************
        ! Basin results module
        ! ******************************************************************
        SUBROUTINE basin_summary(ctl_data, var_data)
            USE PRMS_MODULE, ONLY: Process
            use variables_arr_mod, only: variables_arr_t
            IMPLICIT NONE

            type(control_list), intent(in) :: ctl_data
            type(variables_arr_t), intent(in) :: var_data

            !***********************************************************************
            IF (Process == 'run') THEN
                CALL basin_summaryrun(var_data)
            ELSEIF (Process == 'declare') THEN
                CALL basin_summarydecl(ctl_data)
            ELSEIF (Process == 'init') THEN
                CALL basin_summaryinit(var_data)
            ENDIF
        END SUBROUTINE basin_summary

        !***********************************************************************
        !     declare parameters and variables
        !***********************************************************************
        SUBROUTINE basin_summarydecl(ctl_data)
            USE PRMS_MODULE, ONLY: Model, Inputerror_flag, print_module
            ! USE UTILS_PRMS, only: read_error
            use control_ll_mod, only: control_list
            IMPLICIT NONE

            type(control_list), intent(in) :: ctl_data

            ! Functions
            INTRINSIC CHAR

            ! Local Variables
            CHARACTER(LEN=:), allocatable, SAVE :: Version_basin_summary

            !***********************************************************************
            Version_basin_summary = 'basin_summary.f90 2017-09-29 13:49:00Z'
            CALL print_module(Version_basin_summary, 'Basin Output Summary        ', 90)
            MODNAME = 'basin_summary'

            BasinOutVars = 0
            if (ctl_data%exists('basinOutVars')) call ctl_data%get_data('basinOutVars', BasinOutVars)

            ! 1 = daily, 2 = monthly, 3 = both, 4 = mean monthly, 5 = mean yearly, 6 = yearly total
            BasinOut_freq = 0
            if (ctl_data%exists('basinOut_freq')) call ctl_data%get_data('basinOut_freq', BasinOut_freq)
            ! IF (control_integer(BasinOut_freq, 'basinOut_freq') /= 0) BasinOut_freq = 0

            IF (BasinOutVars == 0) THEN
                IF (Model /= 99) THEN
                    PRINT *, 'ERROR, basin_summary requested with basinOutVars equal 0'
                    Inputerror_flag = 1
                    RETURN
                ENDIF
            ELSE
                ALLOCATE (BasinOutVar_names(BasinOutVars), Nc_vars(BasinOutVars))

                call ctl_data%get_data('basinOutVar_names', BasinOutVar_names, missing_stop=.true.)
                call ctl_data%get_data('basinOutBaseFileName', BasinOutBaseFileName, missing_stop=.true.)
            ENDIF

        END SUBROUTINE basin_summarydecl

        !***********************************************************************
        !     Initialize module values
        !***********************************************************************
        SUBROUTINE basin_summaryinit(var_data)
            use prms_constants, only: MAXFILE_LENGTH
            USE PRMS_MODULE, ONLY: Start_year, Prms_warmup
            use UTILS_PRMS, only: PRMS_open_output_file
            use variables_arr_mod, only: variables_arr_t
            IMPLICIT NONE

            INTRINSIC ABS

            type(variables_arr_t), intent(in) :: var_data

            ! Local Variables
            INTEGER(i4) :: ios
            INTEGER(i4) :: ierr
            INTEGER(i4) :: size
            INTEGER(i4) :: jj
            CHARACTER(LEN=MAXFILE_LENGTH) :: fileName

            !***********************************************************************
            Begin_results = 1
            Begyr = Start_year
            IF (Prms_warmup > 0) Begin_results = 0

            Begyr = Begyr + Prms_warmup
            Lastyear = Begyr

            WRITE (Output_fmt, 9001) BasinOutVars

            ierr = 0
            DO jj = 1, BasinOutVars
                Basin_var_type = var_data%getvartype(BasinOutVar_names(jj)%str)

                IF (Basin_var_type /= 3) THEN
                    PRINT *, 'ERROR, invalid basin_summary variable:', BasinOutVar_names(jj)
                    PRINT *, '       only double variables allowed'
                    ierr = 1
                ENDIF

                size = var_data%getvarsize(BasinOutVar_names(jj)%str)

                IF (size /= 1) THEN
                    PRINT *, 'ERROR, invalid Basin_summary variable:', BasinOutVar_names(jj)
                    PRINT *, '       only scalar variables are allowed'
                    ierr = 1
                ENDIF
            ENDDO
            IF (ierr == 1) STOP

            ALLOCATE (Basin_var_daily(BasinOutVars))
            Basin_var_daily = 0.0D0

            Daily_flag = 0
            IF (BasinOut_freq == 1 .OR. BasinOut_freq == 3) Daily_flag = 1

            Monthly_flag = 0
            IF (BasinOut_freq == 2 .OR. BasinOut_freq == 3 .OR. BasinOut_freq == 4) Monthly_flag = 1

            IF (BasinOut_freq > 4) THEN
                Yeardays = 0
                ALLOCATE (Basin_var_yearly(BasinOutVars))
                Basin_var_yearly = 0.0D0
                WRITE (Output_fmt3, 9003) BasinOutVars
            ENDIF
            IF (Monthly_flag == 1) THEN
                Monthdays = 0.0D0
                ALLOCATE (Basin_var_monthly(BasinOutVars))
                Basin_var_monthly = 0.0D0
            ENDIF

            WRITE (Output_fmt2, 9002) BasinOutVars

            IF (Daily_flag == 1) THEN
                fileName = BasinOutBaseFileName // '.csv'

                CALL PRMS_open_output_file(Dailyunit, fileName, 'xxx', 0, ios)
                IF (ios /= 0) STOP 'in basin_summary, daily'

                WRITE (Dailyunit, Output_fmt2) (BasinOutVar_names(jj)%str, jj = 1, BasinOutVars)
            ENDIF

            IF (BasinOut_freq == 5) THEN
                fileName = BasinOutBaseFileName // '_meanyearly.csv'
                CALL PRMS_open_output_file(Yearlyunit, fileName, 'xxx', 0, ios)
                IF (ios /= 0) STOP 'in basin_summary, mean yearly'

                WRITE (Yearlyunit, Output_fmt2) (BasinOutVar_names(jj)%str, jj = 1, BasinOutVars)
            ELSEIF (BasinOut_freq == 6) THEN
                fileName = BasinOutBaseFileName // '_yearly.csv'
                CALL PRMS_open_output_file(Yearlyunit, fileName, 'xxx', 0, ios)
                IF (ios /= 0) STOP 'in basin_summary, yearly'

                WRITE (Yearlyunit, Output_fmt2) (BasinOutVar_names(jj)%str, jj = 1, BasinOutVars)
            ELSEIF (Monthly_flag == 1) THEN
                IF (BasinOut_freq == 4) THEN
                    fileName = BasinOutBaseFileName // '_meanmonthly.csv'
                ELSE
                    fileName = BasinOutBaseFileName // '_monthly.csv'
                ENDIF

                CALL PRMS_open_output_file(Monthlyunit, fileName, 'xxx', 0, ios)
                IF (ios /= 0) STOP 'in basin_summary, monthly'

                WRITE (Monthlyunit, Output_fmt2) (BasinOutVar_names(jj)%str, jj = 1, BasinOutVars)
            ENDIF

            9001 FORMAT ('(I4, 2(''-'',I2.2),', I6, '('',''ES10.3))')
            9002 FORMAT ('("Date"', I6, '('',''A))')
            9003 FORMAT ('(I4,', I6, '('',''ES10.3))')
        END SUBROUTINE basin_summaryinit

        !***********************************************************************
        !     Output set of declared variables in CSV format
        !***********************************************************************
        SUBROUTINE basin_summaryrun(var_data)
            USE PRMS_MODULE, ONLY: Start_month, Start_day, End_year, End_month, End_day
            USE PRMS_SET_TIME, ONLY: Nowyear, Nowmonth, Nowday, last_day_of_month ! , Modays
            use variables_arr_mod, only: variables_arr_t
            IMPLICIT NONE

            type(variables_arr_t), intent(in) :: var_data

            ! FUNCTIONS AND SUBROUTINES
            INTRINSIC SNGL, DBLE

            ! Local Variables
            INTEGER(i4) :: jj
            INTEGER(i4) :: write_month
            INTEGER(i4) :: write_year
            INTEGER(i4) :: last_day

            !***********************************************************************
            IF (Begin_results == 0) THEN
                IF (Nowyear == Begyr .AND. Nowmonth == Start_month .AND. Nowday == Start_day) THEN
                    Begin_results = 1
                ELSE
                    RETURN
                ENDIF
            ENDIF

            !-----------------------------------------------------------------------
            DO jj = 1, BasinOutVars
                CALL var_data%getvar_dble(MODNAME, BasinOutVar_names(jj)%str, 1, Basin_var_daily(jj))
            ENDDO

            write_month = 0
            write_year = 0
            IF (BasinOut_freq > 4) THEN
                last_day = 0
                IF (Nowyear == End_year .AND. Nowmonth == End_month .AND. Nowday == End_day) last_day = 1

                IF (Lastyear /= Nowyear .OR. last_day == 1) THEN
                    IF ((Nowmonth == Start_month .AND. Nowday == Start_day) .OR. last_day == 1) THEN
                        DO jj = 1, BasinOutVars
                            IF (BasinOut_freq == 5) Basin_var_yearly(jj) = Basin_var_yearly(jj) / Yeardays
                        ENDDO

                        WRITE (Yearlyunit, Output_fmt3) Lastyear, (Basin_var_yearly(jj), jj = 1, BasinOutVars)
                        Basin_var_yearly = 0.0D0
                        Yeardays = 0
                        Lastyear = Nowyear
                    ENDIF
                ENDIF
                Yeardays = Yeardays + 1
            ELSEIF (Monthly_flag == 1) THEN
                ! check for last day of month and simulation
                if (Nowday == last_day_of_month(Nowmonth)) then
                    write_month = 1
                ELSEIF (Nowyear == End_year) THEN
                    IF (Nowmonth == End_month) THEN
                        IF (Nowday == End_day) write_month = 1
                    ENDIF
                ENDIF
                Monthdays = Monthdays + 1.0D0
            ENDIF

            IF (BasinOut_freq > 4) THEN
                DO jj = 1, BasinOutVars
                    Basin_var_yearly(jj) = Basin_var_yearly(jj) + Basin_var_daily(jj)
                ENDDO
                RETURN
            ENDIF

            IF (Monthly_flag == 1) THEN
                DO jj = 1, BasinOutVars
                    Basin_var_monthly(jj) = Basin_var_monthly(jj) + Basin_var_daily(jj)

                    IF (write_month == 1) THEN
                        IF (BasinOut_freq == 4) Basin_var_monthly(jj) = Basin_var_monthly(jj) / Monthdays
                    ENDIF
                ENDDO
            ENDIF

            IF (Daily_flag == 1) WRITE (Dailyunit, Output_fmt) Nowyear, Nowmonth, Nowday, (Basin_var_daily(jj), jj = 1, BasinOutVars)

            IF (write_month == 1) THEN
                WRITE (Monthlyunit, Output_fmt) Nowyear, Nowmonth, Nowday, (Basin_var_monthly(jj), jj = 1, BasinOutVars)
                Monthdays = 0.0D0
                Basin_var_monthly = 0.0D0
            ENDIF

        END SUBROUTINE basin_summaryrun

END MODULE PRMS_BASIN_SUMMARY
