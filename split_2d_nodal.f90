! =====================================
! Split 2D modal algorithm for tracer transport
! Strang splitting and Legendre basis to simulate 2D tracer transport equations with variable windspeeds
!
! Dependencies:
! 	netCDF
!	  LAPACK
!
! By: Devin Light ; Mar. 2015
! =====================================

PROGRAM EXECUTE
    USE commonTestParameters
    USE netCDF

    IMPLICIT NONE
    INTEGER :: startRes,noutput,nRuns,nScale
    REAL(KIND=8) :: muMAX,cflCoeff

    INTERFACE
      SUBROUTINE DRIVER(nex0,ney0,nscale,nruns,noutput,maxCFL)
        INTEGER, INTENT(IN) :: nex0,ney0,nscale,nruns,noutput
        REAL(KIND=8), INTENT(IN) :: maxCFL
      END SUBROUTINE DRIVER
    END INTERFACE

    NAMELIST /inputs/ startRes,nRuns,nScale,maxPolyDegree,cflCoeff,noutput,meqn, &
                      testID,tfinal,TRANSIENT,DOREACTIVE,DEBUG,uMean,vMean
    inUnit=20
    OPEN(unit=inUnit,file="inputs.nl",action="read")
    READ(inUnit,NML=inputs)

    doposlimit = .FALSE.

    write(*,*) meqn
    muMAX  = determineCFL(maxPolyDegree,cflCoeff)

    write(*,*) '======================================================'
    write(*,*) '             BEGINNING RUN OF NODAL TESTS             '
    write(*,'(A27,F7.4)') 'muMAX=',muMAX
    write(*,'(A13,L5)') 'TRANSIENT =',transient
    write(*,'(A13,L5)') 'REACTIVE  =',doreactive
    write(*,'(A9,I5)') 'meqn = ',meqn
    write(*,'(A20,2F7.4)') 'mean flow (U,V) = ',uMean,vMean
    write(*,*) '======================================================'

    write(*,*) '======'
    SELECT CASE(testID)
        CASE(0)
        	write(*,*) 'TEST 0: Consistency test'
        CASE(1)
        	write(*,*) 'TEST 1: Uniform advection (u=v=1)'
        CASE(2)
        	write(*,*) 'TEST 2: Reactive Half-plane flow'
        CASE(5)
          write(*,*) 'TEST 5: LeVeque Cosbell Deformation Test'
        CASE(6)
        	write(*,*) 'TEST 6: LeVeque Smoother Cosbell Deformation Test'
        CASE(7)
        	write(*,*) 'TEST 7: Slotted Cylinder Deformation Test'
        CASE(99)
          write(*,*) 'TEST 99: Non-advective Flow'
        CASE DEFAULT
          write(*,*) ' ******** WARNING:: TEST NOT AVAILABLE *******'
          STOP
    END SELECT
  write(*,*) 'WARNING: Only periodic BCs are implemented'
	write(*,*) '======'
	CALL driver(startRes,startRes,nScale,nRuns,noutput,muMAX)
  CLOSE(inUnit)
  WRITE(*,*) 'PROGRAM COMPLETE!'

CONTAINS
  FUNCTION determineCFL(maxPolyDegree,cflCoeff)
    ! ===============================================================
    ! Determines max CFL for SSPRK3 timestepping as a function of
    ! maximum reconstructing polynomial degree
    ! ===============================================================
    IMPLICIT NONE
    ! Inputs
    INTEGER, INTENT(IN) :: maxPolyDegree
    DOUBLE PRECISION :: cflCoeff
    ! Outputs
    DOUBLE PRECISION determineCFL
    ! Local variables

    SELECT CASE(maxPolyDegree)
      CASE(2)
        determineCFL = 0.450D0
      CASE(3)
        determineCFL = 0.255D0
      CASE(4)
        determineCFL = 0.168D0
      CASE(5)
        determineCFL = 0.120D0
      CASE(6)
        determineCFL = 0.091D0
      CASE(7)
        determineCFL = 0.073D0
      CASE(8)
        determineCFL = 0.059D0
      CASE(9)
        determineCFL = 0.049D0
    END SELECT
    determineCFL = determineCFL*cflCoeff

  END FUNCTION determineCFL

END PROGRAM EXECUTE
