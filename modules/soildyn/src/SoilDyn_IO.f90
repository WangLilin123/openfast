!**********************************************************************************************************************************
! LICENSING
! Copyright (C) 2020  National Renewable Energy Laboratory
!
!    This file is part of SoilDyn.
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
!
!**********************************************************************************************************************************
MODULE SoilDyn_IO

   USE   SoilDyn_Types
   USE   NWTC_Library

   IMPLICIT NONE


!FIXME: add the matlab generated output stuff here.
! ===================================================================================================
! NOTE: The following lines of code were generated by a Matlab script called "Write_ChckOutLst.m"
!      using the parameters listed in the "OutListParameters.xlsx" Excel file. Any changes to these
!      lines should be modified in the Matlab script and/or Excel worksheet as necessary.
! ===================================================================================================
! This code was generated by Write_ChckOutLst.m at 23-Apr-2015 13:13:13.


     ! Parameters related to output length (number of characters allowed in the output data headers):
   INTEGER(IntKi), PARAMETER      :: OutStrLenM1 = ChanLen - 1

     ! Indices for computing output channels:
     ! NOTES:
     !    (1) These parameters are in the order stored in "OutListParameters.xlsx"
     !    (2) Array y%AllOuts() must be dimensioned to the value of the largest output parameter

     !  Time:

   INTEGER(IntKi), PARAMETER      :: Time      =  0

     ! The maximum number of output channels which can be output by the code.
   INTEGER(IntKi), PARAMETER      :: MaxOutPts = 1

!   INTEGER(IntKi), PARAMETER      :: WindMeas(5) = (/ WindMeas1, WindMeas2, WindMeas3, WindMeas4, WindMeas5 /)                                               ! Array of output constants
!   INTEGER(IntKi), PARAMETER      :: WindVelX(9) = (/ Wind1VelX, Wind2VelX, Wind3VelX, Wind4VelX, Wind5VelX, Wind6VelX, Wind7VelX, Wind8VelX, Wind9VelX /)   ! Array of output constants
!   INTEGER(IntKi), PARAMETER      :: WindVelY(9) = (/ Wind1VelY, Wind2VelY, Wind3VelY, Wind4VelY, Wind5VelY, Wind6VelY, Wind7VelY, Wind8VelY, Wind9VelY /)   ! Array of output constants
!   INTEGER(IntKi), PARAMETER      :: WindVelZ(9) = (/ Wind1VelZ, Wind2VelZ, Wind3VelZ, Wind4VelZ, Wind5VelZ, Wind6VelZ, Wind7VelZ, Wind8VelZ, Wind9VelZ /)   ! Array of output constants


! ===================================================================================================

CONTAINS


!====================================================================================================
!>  This public subroutine reads the input required for SoilDyn from the file whose name is an
!!     input parameter.
subroutine SoilDyn_ReadInput( InputFileName, EchoFileName, InputFileData, ErrStat, ErrMsg )

   character(*),                       intent(in   )  :: InputFileName        !< name of the input file
   character(*),                       intent(in   )  :: EchoFileName         !< name of the echo file
   type(SlD_InputFile),                intent(inout)  :: InputFileData        !< The data for initialization
   integer(IntKi),                     intent(  out)  :: ErrStat              !< Returned error status  from this subroutine
   character(*),                       intent(  out)  :: ErrMsg               !< Returned error message from this subroutine

   integer(IntKi)                                     :: UnitInput            !< Unit number for the input file
   integer(IntKi)                                     :: UnitEcho             !< The local unit number for this module's echo file
   character(1024)                                    :: TmpPath              !< Temporary storage for relative path name
   character(1024)                                    :: TmpFmt               !< Temporary storage for format statement
   character(35)                                      :: Frmt                 !< Output format for logical parameters. (matches NWTC Subroutine Library format)
   character(200)                                     :: Line                 !< Temporary storage of a line from the input file (to compare with "default")
   integer(IntKi)                                     :: LineLen              !< Length of the line read
   integer(IntKi)                                     :: i                    !< Generic counter

   integer(IntKi)                                     :: TmpErrStat           !< Temporary error status
   integer(IntKi)                                     :: IOS                  !< Temporary error status
   character(ErrMsgLen)                               :: TmpErrMsg            !< Temporary error message
   character(1024)                                    :: PriPath              !< Path name of the primary file
   character(*),                       PARAMETER      :: RoutineName="SoilDyn_ReadInput"


      ! Initialize local data

   UnitEcho                = -1
   Frmt                    = "( 2X, L11, 2X, A, T30, ' - ', A )"
   ErrStat                 = ErrID_None
   ErrMsg                  = ""
   InputFileData%EchoFlag  = .FALSE.  ! initialize for error handling (cleanup() routine)
   CALL GetPath( InputFileName, PriPath )    ! Input files will be relative to the path where the primary input file is located.


      ! allocate the array for the OutList
   CALL AllocAry( InputFileData%OutList, MaxOutPts, "SoilDyn Input File's OutList", TmpErrStat, TmpErrMsg ); if (Failed()) return;

   !-------------------------------------------------------------------------------------------------
   ! Open the file
   !-------------------------------------------------------------------------------------------------

   CALL GetNewUnit( UnitInput, TmpErrStat, TmpErrMsg ); if (Failed()) return;
   CALL OpenFInpFile( UnitInput, TRIM(InputFileName), TmpErrStat, TmpErrMsg ); if (Failed()) return;


   !-------------------------------------------------------------------------------------------------
   ! File header
   !-------------------------------------------------------------------------------------------------

   call ReadCom( UnitInput, InputFileName, 'SoilDyn input file header line 1',   TmpErrStat, TmpErrMsg );   if (Failed()) return;
   call ReadCom( UnitInput, InputFileName, 'SoilDyn input file header line 2',   TmpErrStat, TmpErrMsg );   if (Failed()) return;
   call ReadCom( UnitInput, InputFileName, 'SoilDyn input file separator line',  TmpErrStat, TmpErrMsg );   if (Failed()) return;

     ! Echo Input Files.
   call ReadVar ( UnitInput, InputFileName, InputFileData%EchoFlag, 'Echo', 'Echo Input', TmpErrStat, TmpErrMsg ); if (Failed()) return;

      ! If we are Echoing the input then we should re-read the first three lines so that we can echo them
      ! using the NWTC_Library routines.  The echoing is done inside those routines via a global variable
      ! which we must store, set, and then replace on error or completion.
   IF ( InputFileData%EchoFlag ) THEN
      call OpenEcho ( UnitEcho, TRIM(EchoFileName), TmpErrStat, TmpErrMsg ); if (Failed()) return;
      rewind(UnitInput)

      call ReadCom( UnitInput, InputFileName, 'SoilDyn input file header line 1',   TmpErrStat, TmpErrMsg, UnitEcho );  if (Failed()) return;
      call ReadCom( UnitInput, InputFileName, 'SoilDyn input file header line 2',   TmpErrStat, TmpErrMsg, UnitEcho );  if (Failed()) return;
      call ReadCom( UnitInput, InputFileName, 'SoilDyn input file separator line',  TmpErrStat, TmpErrMsg, UnitEcho );  if (Failed()) return;

         ! Echo Input Files.
      call ReadVar ( UnitInput, InputFileName, InputFileData%EchoFlag, 'Echo', 'Echo the input file data', TmpErrStat, TmpErrMsg, UnitEcho ); if (Failed()) return;
   end if

      ! DT - Time interval for aerodynamic calculations {or default} (s):
   Line = ""
   CALL ReadVar( UnitInput, InputFileName, Line, "DT", "Time interval for soil calculations {or default} (s)", TmpErrStat, TmpErrMsg, UnitEcho); if (Failed()) return;
      CALL Conv2UC( Line )
      IF ( INDEX(Line, "DEFAULT" ) /= 1 ) THEN ! If it's not "default", read this variable; otherwise use the value already stored in InputFileData%DTAero
         READ( Line, *, IOSTAT=IOS) InputFileData%DT
            CALL CheckIOS ( IOS, InputFileName, 'DT', NumType, TmpErrStat, TmpErrMsg ); if (Failed()) return;
      END IF

      ! CalcOption -- option on which calculation methodology to use {1: Stiffness / Damping matrices [unavailable], 2: P-Y curves [unavailable], 3: coupled REDWIN DLL}
   call ReadVar( UnitInput, InputFileName, InputFileData%CalcOption, "CalcOption", "Calculation methodology to use", TmpErrStat, TmpErrMsg, UnitEcho); if (Failed()) return;


   !-------------------------------------------------------------------------------------------------
   !> Read Stiffness / Damping section [ CalcOption == 1 only ]
   !-------------------------------------------------------------------------------------------------

   call ReadCom( UnitInput, InputFileName, 'SoilDyn input file separator line',  TmpErrStat, TmpErrMsg, UnitEcho );   if (Failed()) return;

      ! In general, the stiffness and damping matrices will have the following symetries:
   !  K11 = K22
   !  K15 = -K24
   !  K51 = -K42
   !  K55 = K44

      ! Stiffness
   call ReadCom( UnitInput, InputFileName, 'SoilDyn input file separator line',  TmpErrStat, TmpErrMsg, UnitEcho );   if (Failed()) return;
   do i=1,6
      call ReadAry( UnitInput, InputFileName, InputFileData%Stiffness(i,:), 6, 'Stiffness', 'Elastic stiffness matrix', TmpErrStat, TmpErrMsg, UnitEcho); if (Failed()) return;
   enddo

      ! Damping
   call ReadCom( UnitInput, InputFileName, 'SoilDyn input file separator line',  TmpErrStat, TmpErrMsg, UnitEcho );   if (Failed()) return;
   do i=1,6
      call ReadAry( UnitInput, InputFileName, InputFileData%Damping(i,:), 6, 'Damping', 'Elastic damping ratio (-)',    TmpErrStat, TmpErrMsg, UnitEcho); if (Failed()) return;
   enddo

   !-------------------------------------------------------------------------------------------------
   !> Read P-Y curve section  [ CalcOption == 2 only ]
   !-------------------------------------------------------------------------------------------------

   call ReadCom( UnitInput, InputFileName, 'SoilDyn input file separator line',  TmpErrStat, TmpErrMsg, UnitEcho );   if (Failed()) return;

   call ReadVar( UnitInput, InputFileName, InputFileData%PY_NumPoints, "PY_NumPoints", "Number of PY curve points", TmpErrStat, TmpErrMsg, UnitEcho );  if (Failed()) return;

      ! Allocate arrays to hold the information that will be read in next
   allocate( InputFileData%PY_locations(InputFileData%PY_NumPoints,3), STAT=TmpErrStat )
   if (TmpErrStat /= 0) then
      call SetErrStat(ErrID_Fatal, 'Could not allocate PY_locations', ErrStat, ErrMsg, RoutineName)
      return
   endif
   allocate( InputFileData%PY_inputFile(InputFileData%PY_NumPoints), STAT=TmpErrStat )
   if (TmpErrStat /= 0) then
      call SetErrStat(ErrID_Fatal, 'Could not allocate PY_inputFile', ErrStat, ErrMsg, RoutineName)
      return
   endif

      ! Now read in the set of PY curves
   call ReadCom( UnitInput, InputFileName, 'SoilDyn input file separator line in PY curve data',  TmpErrStat, TmpErrMsg, UnitEcho );   if (Failed()) return;

      ! Read in each line of location and input file ( ---- Location (x,y,z) ------- Point InputFile ------------- )
   do i=1,InputFileData%PY_NumPoints
      Line = ""
      call ReadLine( UnitInput, '', Line, LineLen, TmpErrStat )
      if (TmpErrStat /= 0) then
         call SetErrStat( ErrID_Fatal, 'Error reading PY_curve line '//trim(Num2LStr(i))//' from '//InputFileName//'.', ErrStat, ErrMsg, RoutineName)
         return
      endif
      READ( Line, *, IOSTAT=IOS) InputFileData%PY_locations(i,1:3), InputFileData%PY_inputFile(i)
      CALL CheckIOS ( IOS, InputFileName, 'DT', NumType, TmpErrStat, TmpErrMsg ); if (Failed()) return;        ! NOTE: unclear if the message returned will match what was misread.

         ! Check for relative paths in the file names
      if ( PathIsRelative( InputFileData%PY_inputFile(i) ) ) InputFileData%PY_inputFile(i) = TRIM(PriPath)//TRIM(InputFileData%PY_inputFile(i))
   enddo


   !-------------------------------------------------------------------------------------------------
   !> Read REDWIN interface for DLL  section  [ CalcOption == 3 only ]
   !-------------------------------------------------------------------------------------------------

   call ReadCom( UnitInput, InputFileName, 'SoilDyn input file separator line',  TmpErrStat, TmpErrMsg, UnitEcho );   if (Failed()) return;

   call ReadVar( UnitInput, InputFileName, InputFileData%DLL_model, "DLL_model", "REDWIN DLL model used", TmpErrStat, TmpErrMsg, UnitEcho );  if (Failed()) return;

      ! DLL_FileName - Name of the Bladed DLL [used only with DLL Interface] (-):
   call ReadVar( UnitInput, InputFileName, InputFileData%DLL_FileName, "DLL_FileName", "Name/location of the external library {.dll [Windows]} in the REDWIN-DLL format [used only with CalcOption==3] (-)", TmpErrStat, TmpErrMsg, UnitEcho )
   if ( PathIsRelative( InputFileData%DLL_FileName ) ) InputFileData%DLL_FileName = TRIM(PriPath)//TRIM(InputFileData%DLL_FileName)

      ! DLL_ProcName - Name of procedure to be called in DLL [used only with DLL Interface] (-):
   call ReadVar( UnitInput, InputFileName, InputFileData%DLL_ProcName, "DLL_ProcName", "Name of procedure to be called in DLL [used only with DLL Interface] (-)", TmpErrStat, TmpErrMsg, UnitEcho)

   call ReadVar( UnitInput, InputFileName, InputFileData%DLL_NumPoints, "DLL_NumPoints", "Number of DLL interfaces", TmpErrStat, TmpErrMsg, UnitEcho );  if (Failed()) return;

      ! Allocate arrays to hold the information that will be read in next
   allocate( InputFileData%DLL_locations(InputFileData%DLL_NumPoints,3), STAT=TmpErrStat )
   if (TmpErrStat /= 0) then
      call SetErrStat(ErrID_Fatal, 'Could not allocate DLL_locations', ErrStat, ErrMsg, RoutineName)
      return
   endif
   allocate( InputFileData%DLL_PropsFile(InputFileData%DLL_NumPoints), STAT=TmpErrStat )
   if (TmpErrStat /= 0) then
      call SetErrStat(ErrID_Fatal, 'Could not allocate DLL_PropsFile', ErrStat, ErrMsg, RoutineName)
      return
   endif
   allocate( InputFileData%DLL_LDispFile(InputFileData%DLL_NumPoints), STAT=TmpErrStat )
   if (TmpErrStat /= 0) then
      call SetErrStat(ErrID_Fatal, 'Could not allocate DLL_LDispFile', ErrStat, ErrMsg, RoutineName)
      return
   endif

      ! Now read in the set of DLL connections
   call ReadCom( UnitInput, InputFileName, 'SoilDyn input file separator line in DLL data',  TmpErrStat, TmpErrMsg, UnitEcho );   if (Failed()) return;

      ! Read in each line of location and input file ( ---- Location (x,y,z) ------- Point InputFile ------------- )
   do i=1,InputFileData%DLL_NumPoints
      Line = ""
      call ReadLine( UnitInput, '', Line, LineLen, TmpErrStat )
      if (TmpErrStat /= 0) then
         call SetErrStat( ErrID_Fatal, 'Error reading DLL_curve line '//trim(Num2LStr(i))//' from '//InputFileName//'.', ErrStat, ErrMsg, RoutineName)
         return
      endif
      READ( Line, *, IOSTAT=IOS) InputFileData%DLL_locations(i,1:3), InputFileData%DLL_PropsFile(i), InputFileData%DLL_LDispFile(i)
      CALL CheckIOS ( IOS, InputFileName, 'DLL info', NumType, TmpErrStat, TmpErrMsg ); if (Failed()) return;        ! NOTE: unclear if the message returned will match what was misread.

         ! Check for relative paths in the file names
      if ( PathIsRelative( InputFileData%DLL_PropsFile(i) ) ) InputFileData%DLL_PropsFile(i) = TRIM(PriPath)//TRIM(InputFileData%DLL_PropsFile(i))
      if ( PathIsRelative( InputFileData%DLL_LDispFile(i) ) ) InputFileData%DLL_LDispFile(i) = TRIM(PriPath)//TRIM(InputFileData%DLL_LDispFile(i))
   enddo

   !---------------------- OUTPUT --------------------------------------------------
   CALL ReadCom( UnitInput, InputFileName, 'Section Header: Output', TmpErrStat, TmpErrMsg, UnitEcho )
   CALL SetErrStat( TmpErrStat, TmpErrMsg, ErrStat, ErrMsg, RoutineName )
   IF (ErrStat >= AbortErrLev) THEN
      CALL Cleanup()
      RETURN
   END IF

      ! SumPrint - Print summary data to <RootName>.IfW.sum (flag):
   CALL ReadVar( UnitInput, InputFileName, InputFileData%SumPrint, "SumPrint", "Print summary data to <RootName>.SlD.sum (flag)", TmpErrStat, TmpErrMsg, UnitEcho )
   CALL SetErrStat( TmpErrStat, TmpErrMsg, ErrStat, ErrMsg, RoutineName )
   IF (ErrStat >= AbortErrLev) THEN
      CALL Cleanup()
      RETURN
   END IF


   !---------------------- OUTLIST  --------------------------------------------
   CALL ReadCom( UnitInput, InputFileName, 'Section Header: OutList', TmpErrStat, TmpErrMsg, UnitEcho )
   CALL SetErrStat( TmpErrStat, TmpErrMsg, ErrStat, ErrMsg, RoutineName )
   IF (ErrStat >= AbortErrLev) THEN
      CALL Cleanup()
      RETURN
   END IF

      ! OutList - List of user-requested output channels (-):     -- uses routine from the NWTC_Library
   CALL ReadOutputList ( UnitInput, InputFileName, InputFileData%OutList, InputFileData%NumOuts, 'OutList',    &
               "List of user-requested output channels", TmpErrStat, TmpErrMsg, UnitEcho  )
   CALL SetErrStat( TmpErrStat, TmpErrMsg, ErrStat, ErrMsg, RoutineName )
   IF (ErrStat >= AbortErrLev) THEN
      CALL Cleanup()
      RETURN
   END IF




   !-------------------------------------------------------------------------------------------------
   ! This is the end of the input file
   !-------------------------------------------------------------------------------------------------

   call Cleanup()
   return

      CONTAINS
         logical function Failed()
            call SetErrStat( TmpErrStat, TmpErrMsg, ErrStat, ErrMsg, RoutineName )
            Failed =  ErrStat >= AbortErrLev
            if (Failed) call CleanUp()
         end function Failed
         subroutine Cleanup()
               ! Close input file
            close ( UnitInput )
               ! Cleanup the Echo file and global variables
            if ( InputFileData%EchoFlag ) then
               close(UnitEcho)
            end if
         end subroutine Cleanup

END SUBROUTINE SoilDyn_ReadInput


!====================================================================================================
!> This private subroutine verifies the input required for SoilDyn is correctly specified.  This
!! routine checkes all the parameters that are common with all the wind types, then calls subroutines
!! that check the parameters specific to each wind type.  Only the parameters corresponding to the
!! desired wind type are evaluated; the rest are ignored.  Additional checks will be performed after
!! the respective wind file has been read in, but these checks will be performed within the respective
!! wind module.
!
!  The reason for structuring it this way is to allow for relocating the validation routines for the
!  wind type into their respective modules. It might also prove useful later if we change languages
!  but retain the fortran wind modules.
SUBROUTINE SoilDyn_ValidateInput( InitInp, InputFileData, ErrStat, ErrMsg )
   TYPE(SlD_InitInputType),            INTENT(IN   )  :: InitInp              !< Input data for initialization
   TYPE(SlD_InputFile),                INTENT(INOUT)  :: InputFileData        !< The data for initialization
   INTEGER(IntKi),                     INTENT(  OUT)  :: ErrStat              !< Error status  from this subroutine
   CHARACTER(*),                       INTENT(  OUT)  :: ErrMsg               !< Error message from this subroutine
   INTEGER(IntKi)                                     :: TmpErrStat           !< Temporary error status  for subroutine and function calls
   CHARACTER(ErrMsgLen)                               :: TmpErrMsg            !< Temporary error message for subroutine and function calls
   INTEGER(IntKi)                                     :: I                    !< Generic counter
   CHARACTER(*),                       PARAMETER      :: RoutineName="SoilDyn_ValidateInput"

      ! Initialize ErrStat
   ErrStat = ErrID_None
   ErrMsg  = ""

CONTAINS
   subroutine ValidateStiffnessMatrix()
      ! Placeholder
   end subroutine ValidateStiffnessMatrix

   subroutine ValidatePYcurves()
      ! Placeholder
   end subroutine ValidatePYcurves

   subroutine ValidateDLL()
      ! Placeholder
   end subroutine ValidateDLL

END SUBROUTINE SoilDyn_ValidateInput


!====================================================================================================
!> This private subroutine copies the info from the input file over to the parameters for SoilDyn.
SUBROUTINE SoilDyn_SetParameters( InitInp, InputFileData, p, m, ErrStat, ErrMsg )
   TYPE(Sld_InitInputType),            INTENT(IN   )  :: InitInp              !< Input data for initialization
   TYPE(Sld_InputFile),                INTENT(INOUT)  :: InputFileData        !< The data for initialization
   TYPE(Sld_ParameterType),            INTENT(INOUT)  :: p                    !< The parameters for SoilDyn
   TYPE(Sld_MiscVarType),              INTENT(INOUT)  :: m                    !< The misc/optimization variables for SoilDyn
   INTEGER(IntKi),                     INTENT(  OUT)  :: ErrStat              !< Error status  from this subroutine
   CHARACTER(*),                       INTENT(  OUT)  :: ErrMsg               !< Error message from this subroutine
   INTEGER(IntKi)                                     :: TmpErrStat           !< Temporary error status  for subroutine and function calls
   CHARACTER(ErrMsgLen)                               :: TmpErrMsg            !< Temporary error message for subroutine and function calls
   INTEGER(IntKi)                                     :: I                    !< Generic counter
   CHARACTER(*),                       PARAMETER      :: RoutineName="SoilDyn_SetParameters"

      ! Initialize ErrStat
   ErrStat = ErrID_None
   ErrMsg  = ""

END SUBROUTINE SoilDyn_SetParameters



!**********************************************************************************************************************************
! NOTE: The following lines of code were generated by a Matlab script called "Write_ChckOutLst.m"
!      using the parameters listed in the "OutListParameters.xlsx" Excel file. Any changes to these
!      lines should be modified in the Matlab script and/or Excel worksheet as necessary.
! This code was generated by Write_ChckOutLst.m at 23-Apr-2015 13:13:13.
!----------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE SetOutParam(OutList, p, ErrStat, ErrMsg )
! This routine checks to see if any requested output channel names (stored in the OutList(:)) are invalid. It returns a
! warning if any of the channels are not available outputs from the module.
!  It assigns the settings for OutParam(:) (i.e, the index, name, and units of the output channels, WriteOutput(:)).
!  the sign is set to 0 if the channel is invalid.
! It sets assumes the value p%NumOuts has been set before this routine has been called, and it sets the values of p%OutParam here.
!..................................................................................................................................

   IMPLICIT                        NONE

   CHARACTER(ChanLen),              INTENT(IN)     :: OutList(:)                 !< The list out user-requested outputs
   TYPE(Sld_ParameterType),         INTENT(INOUT)  :: p                          !< The module parameters
   INTEGER(IntKi),                  INTENT(OUT)    :: ErrStat                    !< The error status code
   CHARACTER(*),                    INTENT(OUT)    :: ErrMsg                     !< The error message, if an error occurred

   INTEGER                                         :: ErrStat2                   ! temporary (local) error status
   INTEGER                                         :: I                          ! Generic loop-counting index
   INTEGER                                         :: J                          ! Generic loop-counting index
   INTEGER                                         :: INDX                       ! Index for valid arrays

   LOGICAL                                         :: CheckOutListAgain          ! Flag used to determine if output parameter starting with "M" is valid (or the negative of another parameter)
   LOGICAL                                         :: InvalidOutput(0:MaxOutPts) ! This array determines if the output channel is valid for this configuration
   CHARACTER(ChanLen)                              :: OutListTmp                 ! A string to temporarily hold OutList(I)
   CHARACTER(*),                    PARAMETER      :: RoutineName = "SetOutParam"

!!!   CHARACTER(OutStrLenM1), PARAMETER  :: ValidParamAry(32) =  (/ &                  ! This lists the names of the allowed parameters, which must be sorted alphabetically
!!!                               "WIND1VELX","WIND1VELY","WIND1VELZ","WIND2VELX","WIND2VELY","WIND2VELZ","WIND3VELX", &
!!!                               "WIND3VELY","WIND3VELZ","WIND4VELX","WIND4VELY","WIND4VELZ","WIND5VELX","WIND5VELY", &
!!!                               "WIND5VELZ","WIND6VELX","WIND6VELY","WIND6VELZ","WIND7VELX","WIND7VELY","WIND7VELZ", &
!!!                               "WIND8VELX","WIND8VELY","WIND8VELZ","WIND9VELX","WIND9VELY","WIND9VELZ","WINDMEAS1", &
!!!                               "WINDMEAS2","WINDMEAS3","WINDMEAS4","WINDMEAS5"/)
!!!   INTEGER(IntKi), PARAMETER :: ParamIndxAry(32) =  (/ &                            ! This lists the index into AllOuts(:) of the allowed parameters ValidParamAry(:)
!!!                                Wind1VelX , Wind1VelY , Wind1VelZ , Wind2VelX , Wind2VelY , Wind2VelZ , Wind3VelX , &
!!!                                Wind3VelY , Wind3VelZ , Wind4VelX , Wind4VelY , Wind4VelZ , Wind5VelX , Wind5VelY , &
!!!                                Wind5VelZ , Wind6VelX , Wind6VelY , Wind6VelZ , Wind7VelX , Wind7VelY , Wind7VelZ , &
!!!                                Wind8VelX , Wind8VelY , Wind8VelZ , Wind9VelX , Wind9VelY , Wind9VelZ , WindMeas1 , &
!!!                                WindMeas2 , WindMeas3 , WindMeas4 , WindMeas5 /)
!!!   CHARACTER(ChanLen), PARAMETER :: ParamUnitsAry(32) =  (/ &                     ! This lists the units corresponding to the allowed parameters
!!!                               "(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ", &
!!!                               "(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ", &
!!!                               "(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ", &
!!!                               "(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     ", &
!!!                               "(m/s)     ","(m/s)     ","(m/s)     ","(m/s)     "/)
!!!
!!!
!!!      ! Initialize values
!!!   ErrStat = ErrID_None
!!!   ErrMsg = ""
!!!   InvalidOutput = .FALSE.
!!!
!!!
!!!!   ..... Developer must add checking for invalid inputs here: .....
!!!      ! NOTE:  we are not checking that the coordinates input for the WindVxi, WindVyi, and WindVzi are valid here.  We are
!!!      !        checking that at the input file validation (they simply get zeroed with a warning if there is an issue).
!!!
!!!      ! make sure we don't ask for outputs that don't exist:
!!!   DO I = p%NWindVel+1, 9
!!!      InvalidOutput( WindVelX(I) ) =  .TRUE.
!!!      InvalidOutput( WindVelY(I) ) =  .TRUE.
!!!      InvalidOutput( WindVelZ(I) ) =  .TRUE.
!!!   END DO
!!!
!!!   DO I=p%lidar%NumPulseGate+1,5
!!!      InvalidOutput( WindMeas(I) ) = .TRUE.
!!!   END DO
!!!
!!!!   ................. End of validity checking .................
!!!
!!!
!!!   !-------------------------------------------------------------------------------------------------
!!!   ! Allocate and set index, name, and units for the output channels
!!!   ! If a selected output channel is not available in this module, set error flag.
!!!   !-------------------------------------------------------------------------------------------------
!!!
!!!   ALLOCATE ( p%OutParam(0:p%NumOuts) , STAT=ErrStat2 )
!!!   IF ( ErrStat2 /= 0_IntKi )  THEN
!!!      CALL SetErrStat( ErrID_Fatal,"Error allocating memory for the SoilDyn OutParam array.", ErrStat, ErrMsg, RoutineName )
!!!      RETURN
!!!   ENDIF
!!!
!!!      ! Set index, name, and units for the time output channel:
!!!
!!!   p%OutParam(0)%Indx  = Time
!!!   p%OutParam(0)%Name  = "Time"    ! OutParam(0) is the time channel by default.
!!!   p%OutParam(0)%Units = "(s)"
!!!   p%OutParam(0)%SignM = 1
!!!
!!!
!!!      ! Set index, name, and units for all of the output channels.
!!!      ! If a selected output channel is not available by this module set ErrStat = ErrID_Warn.
!!!
!!!   DO I = 1,p%NumOuts
!!!
!!!      p%OutParam(I)%Name  = OutList(I)
!!!      OutListTmp          = OutList(I)
!!!
!!!      ! Reverse the sign (+/-) of the output channel if the user prefixed the
!!!      !   channel name with a "-", "_", "m", or "M" character indicating "minus".
!!!
!!!
!!!      CheckOutListAgain = .FALSE.
!!!
!!!      IF      ( INDEX( "-_", OutListTmp(1:1) ) > 0 ) THEN
!!!         p%OutParam(I)%SignM = -1                         ! ex, "-TipDxc1" causes the sign of TipDxc1 to be switched.
!!!         OutListTmp          = OutListTmp(2:)
!!!      ELSE IF ( INDEX( "mM", OutListTmp(1:1) ) > 0 ) THEN ! We'll assume this is a variable name for now, (if not, we will check later if OutListTmp(2:) is also a variable name)
!!!         CheckOutListAgain   = .TRUE.
!!!         p%OutParam(I)%SignM = 1
!!!      ELSE
!!!         p%OutParam(I)%SignM = 1
!!!      END IF
!!!
!!!      CALL Conv2UC( OutListTmp )    ! Convert OutListTmp to upper case
!!!
!!!
!!!      Indx = IndexCharAry( OutListTmp(1:OutStrLenM1), ValidParamAry )
!!!
!!!
!!!         ! If it started with an "M" (CheckOutListAgain) we didn't find the value in our list (Indx < 1)
!!!
!!!      IF ( CheckOutListAgain .AND. Indx < 1 ) THEN    ! Let's assume that "M" really meant "minus" and then test again
!!!         p%OutParam(I)%SignM = -1                     ! ex, "MTipDxc1" causes the sign of TipDxc1 to be switched.
!!!         OutListTmp          = OutListTmp(2:)
!!!
!!!         Indx = IndexCharAry( OutListTmp(1:OutStrLenM1), ValidParamAry )
!!!      END IF
!!!
!!!
!!!      IF ( Indx > 0 ) THEN ! we found the channel name
!!!         p%OutParam(I)%Indx     = ParamIndxAry(Indx)
!!!         IF ( InvalidOutput( ParamIndxAry(Indx) ) ) THEN  ! but, it isn't valid for these settings
!!!            p%OutParam(I)%Units = "INVALID"
!!!            p%OutParam(I)%SignM = 0
!!!         ELSE
!!!            p%OutParam(I)%Units = ParamUnitsAry(Indx) ! it's a valid output
!!!         END IF
!!!      ELSE ! this channel isn't valid
!!!         p%OutParam(I)%Indx  = Time                 ! pick any valid channel (I just picked "Time" here because it's universal)
!!!         p%OutParam(I)%Units = "INVALID"
!!!         p%OutParam(I)%SignM = 0                    ! multiply all results by zero
!!!
!!!         CALL SetErrStat(ErrID_Warn, TRIM(p%OutParam(I)%Name)//" is not an available output channel.",ErrStat,ErrMsg,RoutineName)
!!!      END IF
!!!
!!!   END DO
!!!
   RETURN
END SUBROUTINE SetOutParam
!----------------------------------------------------------------------------------------------------------------------------------
!End of code generated by Matlab script
!**********************************************************************************************************************************

!====================================================================================================
SUBROUTINE SetAllOuts( p, y, m, ErrStat, ErrMsg )
   TYPE(Sld_ParameterType),            INTENT(IN   )  :: p            !< The parameters for SoilDyn
   TYPE(Sld_OutputType),               INTENT(IN   )  :: y            !< Outputs
   TYPE(Sld_MiscVarType),              INTENT(INOUT)  :: m            !< Misc variables for optimization (not copied in glue code)
   INTEGER(IntKi),                     INTENT(  OUT)  :: ErrStat      !< Error status  from this subroutine
   CHARACTER(*),                       INTENT(  OUT)  :: ErrMsg       !< Error message from this subroutine
   INTEGER(IntKi)                                     :: I            ! Generic counter
   CHARACTER(*),              PARAMETER               :: RoutineName="SetAllOuts"

      ! Initialization
   ErrStat  = ErrID_None
   ErrMsg   = ''

!      ! We set the unused values to 0 at init, so we don't need to set them again here:
!   DO I = 1,p%NWindVel
!
!      m%AllOuts( WindVelX(I) ) =  m%WindViUVW(1,I)
!      m%AllOuts( WindVelY(I) ) =  m%WindViUVW(2,I)
!      m%AllOuts( WindVelZ(I) ) =  m%WindViUVW(3,I)
!
!   END DO
!
!      !FIXME:  Add in Wind1Dir, Wind1Mag etc.  -- allthough those can be derived outside of FAST.
!
!   DO I = 1,MIN(5, p%lidar%NumPulseGate )
!      m%AllOuts( WindMeas(I) ) = y%lidar%lidSpeed(I)
!   END DO
END SUBROUTINE SetAllOuts

!====================================================================================================
SUBROUTINE SoilDyn_OpenSumFile( SumFileUnit, SummaryName, IfW_Prog, WindType, ErrStat, ErrMsg )
   INTEGER(IntKi),                  INTENT(  OUT)  :: SumFileUnit    !< the unit number for the SoilDynsummary file
   CHARACTER(*),                    INTENT(IN   )  :: SummaryName    !< the name of the SoilDyn summary file
   TYPE(ProgDesc),                  INTENT(IN   )  :: IfW_Prog       !< the name/version/date of the SoilDyn program
   INTEGER(IntKi),                  INTENT(IN   )  :: WindType       !< type identifying what wind we are using
   INTEGER(IntKi),                  INTENT(  OUT)  :: ErrStat        !< returns a non-zero value when an error occurs
   CHARACTER(*),                    INTENT(  OUT)  :: ErrMsg         !< Error message if ErrStat /= ErrID_None
   INTEGER(IntKi)                                  :: TmpErrStat     !< Temporary error status for checking how the WRITE worked

       ! Initialize ErrStat
   ErrStat = ErrID_None
   ErrMsg  = ""

   SumFileUnit = -1
   CALL GetNewUnit( SumFileUnit )
   CALL OpenFOutFile ( SumFileUnit, SummaryName, ErrStat, ErrMsg )
   IF (ErrStat >=AbortErrLev) RETURN

         ! Write the summary file header
   WRITE(SumFileUnit,'(/,A/)',IOSTAT=TmpErrStat)   'This summary file was generated by '//TRIM( IfW_Prog%Name )//&
                     ' '//TRIM( IfW_Prog%Ver )//' on '//CurDate()//' at '//CurTime()//'.'
   WRITE(SumFileUnit,'(A14,I1)',IOSTAT=TmpErrStat) '  WindType:   ',WindType
   IF ( TmpErrStat /= 0 ) THEN
      CALL SetErrStat(ErrID_Fatal,'Error writing to summary file.',ErrStat,ErrMsg,'')
      RETURN
   END IF
END SUBROUTINE SoilDyn_OpenSumFile
!====================================================================================================
SUBROUTINE SoilDyn_CloseSumFile( SumFileUnit, ErrStat, ErrMsg )
   INTEGER(IntKi),                  INTENT(INOUT)  :: SumFileUnit    !< the unit number for the SoilDynsummary file
   INTEGER(IntKi),                  INTENT(  OUT)  :: ErrStat        !< returns a non-zero value when an error occurs
   CHARACTER(*),                    INTENT(  OUT)  :: ErrMsg         !< Error message if ErrStat /= ErrID_None
   INTEGER(IntKi)                                  :: TmpErrStat
   CHARACTER(1024)                                 :: TmpErrMsg

      ! Initialize ErrStat
   ErrStat     = ErrID_None
   ErrMsg      = ''
   TmpErrStat  = ErrID_None
   TmpErrMsg   = ''

      ! Write any closing information in the summary file
   IF ( SumFileUnit > 0_IntKi ) THEN
      WRITE (SumFileUnit,'(/,A/)', IOSTAT=TmpErrStat)  'This summary file was closed on '//CurDate()//' at '//CurTime()//'.'
      IF (TmpErrStat /= 0_IntKi)    CALL SetErrStat( ErrID_Fatal, 'Problem writing to the SoilDyn summary file.', ErrStat, ErrMsg, '' )

         ! Close the file
      CLOSE( SumFileUnit, IOSTAT=TmpErrStat )
      IF (TmpErrStat /= 0_IntKi)    CALL SetErrStat( ErrID_Fatal, 'Problem closing the SoilDyn summary file.', ErrStat, ErrMsg, '' )
   END IF
END SUBROUTINE SoilDyn_CloseSumFile
!====================================================================================================


!**********************************************************************************************************************************
END MODULE SoilDyn_IO
