!Image Systems Evaluation Toolkit (ISET) Zemax Macro (ZPL)
!
!Author: P. Maeda, B. Wandell, P. Catrysse
!Date:   March, 2005
!
! This macro is written to work with the ISET simulation technology.
! The macro calculates 
!
!    (a) the local pointspread functions 
!    (b) the geometric distortion, 
!    (c) relative illumination from a lens description file, and 
!    (d) the chief ray angle for each image height and wavelength.
!
! Several other lens parameters are also calculated and saved 
!(effective focal length, effective f-number, and so forth.
!
! The macro analyzes the data in the currently loaded lens.
!
! The data are written to a series .DAT files.  These files 
! are read from within the ISET-Optics window.
! The are stored as an ISET optics structure that can
! be used in the ray trace analysis of image formation.
!
! To run this macro place the file in the Zemax macro directory.
! Then, edit the parameters in the editable section of this file (see below).
! Then invoke this macro from within Zemax from the Macro pulldown.
!
! Instructions for editing setting up Zemax and editing the file can be found at
! <<<<WEB-SITE INFORMATION GOES HERE>>>>>
!
! The output files are stored in the format 
!     <basename>_PSF_<FieldHeightIndex>_<WavelengthIndex>.dat  (many files)
!     <basename>_RI_.dat
!     <basename>_DI_.dat
!     <basename>_CRA_.dat
!
!--------------------------------------------------------------------------------
!modified by D.Bakin:
!added <basename>_CRA_.dat file in the same format as the _DI_ file (June 21, 2005)
!
!
!This version will work with the current lens loaded in Zemax. User should create 
!a new directory, for example,  c:\ZEMAX\ISET\LENSNAME\, where LENSNAME - is the 
!lens title defined in Zemax's General system dialog box
!
!Please save the Huygens PSF settings in Zemax file and match them to: 
!WAVELENGTH = 1, FIELD = 1 
!PSF_SIZE (default value 128), GRID_SPACING (default value 0.25 um)
!before running this macro 
!----------------------------------------
LENS_DIR$=$PATHNAME()	
                      
LENS_FILE$=$FILENAME()              

PARAMETERS_FILE$="C:\ZEMAX\ISET\" + $LENSNAME() + "\ISETPARMS.TXT"

BASENAME$="C:\ZEMAX\ISET\" + $LENSNAME() + "\" + $LENSNAME()	
!$LENSNAME() - Returns the lens title defined in General system dialog box

! -------------------------------------------------
! The user should edit the 6 fields below.  These are
!
! PSF_SIZE:      The number of samples in the psf
! GRID_SPACING:  The spacing between PSF samples (mm)
! WL_NUM:        Number of wavelength samples
! WL_MIN,WL_MAX: Lowest and highest wavelength samples (in nanometers)
! IMGHT_NUM:     Number of samples of the image height from 0 to the max field of view
!--------------------------------------------------

!PSF DIMENSIONS MUST BE 64X64, 128X128, 256X256, 512X512, 1024X1024, 2048X2048, OR 4096X4096
!This parameter must match the value saved in the Zemax Hugens_PSF Settings window
PSF_SIZE=128

!This parameter must match the value saved in the Zemax Hugens_PSF Settings window
!PSF GRID SPACING IN MM
GRID_SPACING=0.00025

!NUMBER OF WAVELENGTHS
WL_NUM=5

!MINIMUM WAVELENGTH IN NANOMETERS                          
WL_MIN=400

!MAXIMUM WAVELENGTH IN NANOMETERS
WL_MAX=700                        

!NUMBER OF PARAXIAL IMAGE HEIGHTS
IMGHT_NUM=21

!---------------------DO NOT EDIT BELOW THIS LINE ----------------------
!-----------------------------------------------------------------------


!MINIMUM PARAXIAL IMAGE HEIGHT IN MM                      
IMGHT_MIN=0

LENS_FULL_PATH$=$FILEPATH()

!Lens dimensions must be specified in millimeters (mm). 
SETUNITS 0

!Lens must have apertures defined on all surfaces, including the aperture stop
!to insure vignetting is properly accounted for. 

!SELECT LENS CONFIGURATION  1         
SETCONFIG 1

!SET STATE OF RAY AIMING FUNCTION:  0 FOR NO RAY AIMING
!                                   1 FOR PARAXIAL REFERENCE
!                                   2 FOR REAL REFERENCE
SETAIM 2               

!PLACE SYSTEM DATA IN VEC1
GETSYSTEMDATA 1                    

!LENS REFERENCE WAVELENGTH NUMBER
WL_REF_NUM=PWAV()

!LENS REFERENCE WAVELENGTH IN NM                     
WL_REF=1000*WAVL(WL_REF_NUM)            

!OBJECT DISTANCE IN MM
OBJ_DIST=THIC(0) 
   
!OPTICAL SYSTEM MAGNIFICATION
MAG=VEC1(16)                       

!EFFECTIVE FOCAL LENGTH
EFL=VEC1(7)

!EFFECTIVE F-NUMBER (WORKING F-NUMBER)
EFNUM=VEC1(10)

!F-NUMBER (IMAGE SPACE F-NUMBER)
FNUM=VEC1(8)

!Paraxial Image Height (DB)
IMGHT_MAX=VEC1(15)

!----------------------------------------------------------
!This section is not used (DB)
!Adjust focus by moving the image surface to minimize parameter 
!around centroid (SECOND ARGUMENT=1): 
!0 - RMS spot radius; 1 - spot x; 2 - spot y; 3 - wavefront OPD
!QUICKFOCUS 0, 1
!------------------------------------------------------------------

!------------------------------------------------------------
!----CALCULATE maximum diagonal half field of view
!------------------------------------------------------------

! This section is modified (DB)

PI=3.14159265

!MAXIMUM FIELD OF VIEW (the value in degrees if the fields are defined in degrees)
FOV=MAXF()

!----------------------------------
!----WRITE Parameters file
!----------------------------------

OUTPUT PARAMETERS_FILE$

TEMPSTR$="% " + LENS_FULL_PATH$
PRINT TEMPSTR$

TEMPSTR$="lensFile='" + LENS_FILE$
PRINT TEMPSTR$, "' % Lens file name"

TEMPSTR$="psfSize="
FORMAT .0
PRINT TEMPSTR$, PSF_SIZE, ";                % PSF ROW AND COL SIZE"

TEMPSTR$="psfSpacing="
FORMAT .7
PRINT TEMPSTR$, GRID_SPACING, ";       % PSF GRID SPACING IN MM"

dW=(WL_MAX-WL_MIN)/(WL_NUM-1)
TEMPSTR$="wave="
FORMAT .0
PRINT TEMPSTR$, WL_MIN, ":", dW, ":", WL_MAX, ";            % WAVELENGTH SAMPLES (NM)"

!Commented out for DB
!dH=(IMGHT_MAX-IMGHT_MIN)/(IMGHT_NUM-1)
!TEMPSTR$="imgHeight="
!FORMAT .3
!PRINT TEMPSTR$, IMGHT_MIN, ":", dH, ":", IMGHT_MAX, ";     % REAL IMAGE HEIGHTS (MM)"

TEMPSTR$="imgHeightNum="
FORMAT .0
PRINT TEMPSTR$, IMGHT_NUM, ";            % Number of IMAGE HEIGHTS "

TEMPSTR$="imgHeightMax="
FORMAT .7
PRINT TEMPSTR$, IMGHT_MAX, ";     % Maximum IMAGE HEIGHT (mm)"

TEMPSTR$="objDist="
FORMAT .3 
PRINT TEMPSTR$, OBJ_DIST, ";           % OBJECT DISTANCE (MM)"

TEMPSTR$="mag="
FORMAT .6 
PRINT TEMPSTR$, MAG, ";              % OPTICAL SYSTEM MAGNIFICATION"

TEMPSTR$="baseLensFileName='" + BASENAME$
PRINT TEMPSTR$, "'"

TEMPSTR$="refWave="
FORMAT .3
PRINT TEMPSTR$, WL_REF, ";            % REFERENCE WAVELENGTH (NM)"

TEMPSTR$="fov="
FORMAT .6
PRINT TEMPSTR$, FOV, ";              % MAXIMUM DIAGONAL HALF FOV (DEGREE)"

TEMPSTR$="efl="
FORMAT .6 
PRINT TEMPSTR$, EFL, ";               % EFFECTIVE FOCAL LENGTH"

TEMPSTR$="fnumber_eff="
FORMAT .6 
PRINT TEMPSTR$, EFNUM, ";       % EFFECTIVE F-NUMBER"

TEMPSTR$="fnumber="
FORMAT .6 
PRINT TEMPSTR$, FNUM, ";           % F-NUMBER"

OUTPUT SCREEN

!----------------------------------
!----END WRITE Parameters file
!----------------------------------
!-------------------------------------
!Set up common parameters
!------------------------------------
!SET TOTAL NUMBER OF FIELDS
NUMFIELD 1

!SELECT FIELD TYPE:  0 FOR ANGLE IN DEGREES
!                    1 FOR OBJECT HEIGHT IN LENS UNITS
!                    2 FOR PARAXIAL IMAGE HEIGHT IN LENS UNITS
!                    3 FOR REAL IMAGE HEIGHT IN LENS UNITS
FTYP=0

!SET TOTAL NUMBER OF WAVELENGTHS
NUMWAVE 1

!Image surface is the last surface
IMG_SURF_NUM=NSUR()

!---------------------------------------
!CALCULATE THE IMAGE DISTORTION 
!---------------------------------------

!SET UP THE DISTORTED IMAGE HEIGHT DATA OUTPUT FILE NAME
OUTPUT SCREEN
OUTPUT_DI_FILE$=BASENAME$ + "_DI_" + ".dat"
PRINT "OUTPUT DISTORTED IMAGE HEIGHT FILENAME:  ", OUTPUT_DI_FILE$
OUTPUT OUTPUT_DI_FILE$

!Calculate normalized paraxial image height,
!convert it to field angle, 
!to be used in RAYTRACE command for each wavelength

FOR J = 1, IMGHT_NUM, 1
   N_IMGHT = (J-1)*TANG(FOV*PI/180)/(IMGHT_NUM-1)
   FLDX 1 = 0.0
   FLDY 1 = ATAN(N_IMGHT)*180/PI

   FOR I = 1, WL_NUM, 1
      WLT=WL_MIN+(I-1)*(WL_MAX-WL_MIN)/(WL_NUM-1)
      WAVL 1  = WLT/1000
      PWAV 1

      !SET VIGNETTING FACTORS FOR GIVEN IMAGE HEIGHT AND WAVELENGTH
      SETVIG
      UPDATE                 
      RAYTRACE 0, 1, 0, 0
      DISTIMGHT=RAYY(IMG_SURF_NUM)
  
      !WRITE DISTORTED IMAGE HEIGHT DATA TO DI OUTPUT FILE
      FORMAT .6 EXP
      IF (I == WL_NUM)
         PRINT DISTIMGHT
      ELSE
         PRINT DISTIMGHT, " ",
      ENDIF    
   NEXT
NEXT

OUTPUT SCREEN

!------------------------------------------------------------------------
!CALCULATE THE CRA
!------------------------------------------------------------------------

!USE THE SAME PARAMETERS AS IN DISTORTION CALCULATIONS

!SET UP THE CRA DATA OUTPUT FILE NAME
OUTPUT SCREEN
OUTPUT_CRA_FILE$=BASENAME$ + "_CRA_" + ".dat"
PRINT "OUTPUT CRA FILENAME:  ", OUTPUT_CRA_FILE$
OUTPUT OUTPUT_CRA_FILE$

FOR J = 1, IMGHT_NUM, 1
   N_IMGHT = (J-1)*TANG(FOV*PI/180)/(IMGHT_NUM-1)
   FLDX 1 = 0.0
   FLDY 1 = ATAN(N_IMGHT)*180/PI

   FOR I = 1, WL_NUM, 1
      WLT=WL_MIN+(I-1)*(WL_MAX-WL_MIN)/(WL_NUM-1)
      WAVL 1 = WLT/1000
      PWAV 1
      !SET VIGNETTING FACTORS FOR GIVEN IMAGE HEIGHT AND WAVELENGTH
     SETVIG
      UPDATE                 
      RAYTRACE 0, 1, 0, 0
      !CALCULATE CRA FOR THE CURRENT FOV (MEASURED IN RADIANS)
      CRA=ACOS(RAYN(IMG_SURF_NUM))
   
      !WRITE CRA DATA TO CRA OUTPUT FILE
      FORMAT .6 EXP
      IF (I == WL_NUM)
         PRINT CRA
      ELSE
         PRINT CRA, " ",
      ENDIF    
   NEXT
NEXT

OUTPUT SCREEN
!---------------------------------------
!CALCULATE THE RELATIVE ILLUMINATION
!---------------------------------------
NUMFIELD 2

!SET UP THE RELATIVE ILLUMINATION DATA OUTPUT FILE NAME
OUTPUT SCREEN
OUTPUT_RI_FILE$=BASENAME$ + "_RI_" + ".dat"
PRINT "OUTPUT RELATIVE ILLUMINATION FILENAME:  ", OUTPUT_RI_FILE$
OUTPUT OUTPUT_RI_FILE$

FLDX 1 = 0.0
FLDY 1 = 0.0
FOR J = 1, IMGHT_NUM, 1
   N_IMGHT = (J-1)*TANG(FOV*PI/180)/(IMGHT_NUM-1)
   FLDX 2 = 0.0
   FLDY 2 = ATAN(N_IMGHT)*180/PI

   FOR I = 1, WL_NUM, 1
      WLT=WL_MIN+(I-1)*(WL_MAX-WL_MIN)/(WL_NUM-1)
      WAVL 1 = WLT/1000
      PWAV 1
 
      !SET VIGNETTING FACTORS FOR GIVEN IMAGE HEIGHT AND WAVELENGTH
      SETVIG
      UPDATE
      RELILLUM=RELI(2)

      !WRITE RELATIVE ILLUMINATION DATA TO RI OUTPUT FILE
      FORMAT .6 EXP
      IF (I == WL_NUM)
         PRINT RELILLUM
      ELSE
         PRINT RELILLUM, " ",
      ENDIF   
   NEXT
NEXT

OUTPUT SCREEN

!-------------------------------------------------------------------
! CALCULATE THE PSF
!-------------------------------------------------------------------
!Please save correct Huygens PSF settings before executing

NUMFIELD 1
!SET THE MAXIMUM SIZE OF THE VECn ARRAYS FOR THE PSF OUTPUT
SETVECSIZE PSF_SIZE*PSF_SIZE+2

FOR I = 1, WL_NUM, 1
   WLT=WL_MIN+(I-1)*(WL_MAX-WL_MIN)/(WL_NUM-1)
   WAVL 1 = WLT/1000
   PWAV 1

   FOR J = 1, IMGHT_NUM, 1
      N_IMGHT = (J-1)*TANG(FOV*PI/180)/(IMGHT_NUM-1)
   FLDX 1 = 0.0
   FLDY 1 = -ATAN(N_IMGHT)*180/PI
      !SET VIGNETTING FACTORS FOR GIVEN IMAGE HEIGHT AND WAVELENGTH
      SETVIG
     
      UPDATE              
      
      OUTPUT SCREEN

      !SET UP THE PSF OUTPUT FILE NAME
      FORMAT .0
      OUTPUT_PSF_FILE$=BASENAME$ + "_PSF_" + $STR(J) + "_" + $STR(I) + ".dat"
      PRINT "OUTPUT PSF FILENAME:  ", OUTPUT_PSF_FILE$

      !CREATE PSF TEXT DATA AND WRITE TO PSF OUTPUT FILE
      GETTEXTFILE OUTPUT_PSF_FILE$, Hps, HPS.CFG, 0
   NEXT
NEXT

OUTPUT SCREEN

!-------------------------------------------------------------------
! CALCULATE THE full Grid Distortion
!-------------------------------------------------------------------

!Grid size for GridDistortion.dat text file is negative double the first number in the first column
!Please set and save the lens setting for Grid Distortion in Zemax to Grid_Size=64

!Set reference point for the grid at zero
FLDX 1 = 0.0
FLDY 1 = 0.0

FOR I = 1, WL_NUM, 1
   WLT=WL_MIN+(I-1)*(WL_MAX-WL_MIN)/(WL_NUM-1)
   WAVL 1 = WLT/1000
   PWAV 1

   !SET VIGNETTING FACTORS FOR GIVEN IMAGE HEIGHT AND WAVELENGTH
   ! Actually I am not sure if it is required, but just in case ...
   SETVIG
   UPDATE              
   OUTPUT SCREEN

   !SET UP THE Grid Distortion OUTPUT FILE NAME
   FORMAT .0
      OUTPUT_GD_FILE$=BASENAME$ + "_GridDistortion_" + $STR(I) + ".dat"
      PRINT "OUTPUT GRID DISTORTION FILENAME:  ", OUTPUT_GD_FILE$

      !CREATE Grid Distortion TEXT DATA AND WRITE TO GD OUTPUT FILE
      GETTEXTFILE OUTPUT_GD_FILE$, Grd, GRD.CFG, 0
NEXT

OUTPUT SCREEN

LABEL 1

!Load original lens file back in Zemax
LOADLENS LENS_FULL_PATH$

!Tell me if you've heard the
BEEP
!because I had not

!---------------------------END OF MACRO-------------------------------------

