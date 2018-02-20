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
!modified by D.Bakin to add <basename>_CRA_.dat file in the same format as the _DI_ file
!date: June 21, 2005
!
!This version will work with the current lens loaded in Zemax. User needs to create 
!a new directory, say  c:\ZEMAX\ISET\LENSNAME\, where LENSNAME - is the lens title defined 
!in Zemax's General system dialog box 
!----------------------------------------
LENS_DIR$=$PATHNAME()	
                      
LENS_FILE$=$FILENAME()              

!PARAMETERS_FILE$="C:\ZEMAX_Tutorial\" + $LENSNAME() + "\ISETPARMS.TXT"

!BASENAME$="C:\ZEMAX_Tutorial\" + $LENSNAME() + "\" + $LENSNAME()	

PARAMETERS_FILE$= LENS_DIR$ + "\" + $LENSNAME() + "\ISETPARMS.TXT"

BASENAME$= LENS_DIR$ + "\" + $LENSNAME() + "\" + $LENSNAME()

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
!This parameter must match the value set in the Zemax FFT Settings window
PSF_SIZE=128 # Keep this 128 because I hard-coded ISET for this 

!PSF GRID SPACING IN MM
GRID_SPACING=0.00025 

!NUMBER OF WAVELENGTHS
WL_NUM=3

!MINIMUM WAVELENGTH IN NANOMETERS                          
WL_MIN=400

!MAXIMUM WAVELENGTH IN NANOMETERS
WL_MAX=700                      

!NUMBER OF PARAXIAL IMAGE HEIGHTS
IMGHT_NUM=2

!Specify the path for the file with object distances
!And also specify the number of object locations in mm
OBJDIST_FILENAME$ = LENS_DIR$  + "\" + $LENSNAME() + “\objDist.txt"

N = 3	#is the number of object locations

!DECLARE VARIABLES
DECLARE OBJDIST, DOUBLE, 1, N 
OUTPUT SCREEN
PRINT "Reading the object distances in mm!"
OPEN OBJDIST_FILENAME$
FOR i1,1,N,1
	READNEXT x
	OBJDIST(i1)  = x
	PRINT OBJDIST(i1)
NEXT
PRINT "Object distances read in mm"
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

!May be not neccesary.
!Adjust focus by moving the image surface to minimize parameter 
!around centroid (SECOND ARGUMENT=1): 
!0 - RMS spot radius; 1 - spot x; 2 - spot y; 3 - wavefront OPD
!QUICKFOCUS 0, 1

!------------------------------------------------------------
!----CALCULATE maximum diagonal half field of view
!------------------------------------------------------------

PI=3.14159265
RAYTRACE 0, 1, 0, 0

!MAXIMUM FIELD OF VIEW IN DEGREES 
FOV=ACOS(RAYN(0))*180/PI

!Calculate Max Paraxial Image Height
IMGHT_MAX=EFL*TANG(ACOS(RAYN(0)))

!----------------------------------
!----WRITE Parameters file
!----------------------------------

OUTPUT PARAMETERS_FILE$

TEMPSTR$="%   " + LENS_FULL_PATH$
PRINT TEMPSTR$

TEMPSTR$="lensFile='" + LENS_FILE$
TEMPSTR$=TEMPSTR$ + "';     %Lens file name"
PRINT TEMPSTR$

TEMPSTR$="psfSize="
FORMAT .0
PRINT TEMPSTR$, PSF_SIZE, ";                 % PSF ROW AND COL SIZE"

TEMPSTR$="psfSpacing="
FORMAT .7
PRINT TEMPSTR$, GRID_SPACING, ";   % PSF GRID SPACING IN MM"

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
PRINT TEMPSTR$, IMGHT_NUM, ";                % Number of IMAGE HEIGHTS "

TEMPSTR$="imgHeightMax="
FORMAT .7
PRINT TEMPSTR$, IMGHT_MAX, ";                % Maximum IMAGE HEIGHT (mm)"

TEMPSTR$="objDist="
FORMAT .3 
PRINT TEMPSTR$, OBJ_DIST, ";                 % OBJECT DISTANCE (MM)"

TEMPSTR$="mag="
FORMAT .6 
PRINT TEMPSTR$, MAG, ";          % OPTICAL SYSTEM MAGNIFICATION"

TEMPSTR$="baseLensFileName='" + BASENAME$
TEMPSTR$=TEMPSTR$ + "';"
PRINT TEMPSTR$

TEMPSTR$="refWave="
FORMAT .3
PRINT TEMPSTR$, WL_REF, ";          % REFERENCE WAVELENGTH (NM)"

TEMPSTR$="fov="
FORMAT .6
PRINT TEMPSTR$, FOV, ";          % MAXIMUM DIAGONAL HALF FOV (DEGREE)"

TEMPSTR$="efl="
FORMAT .6 
PRINT TEMPSTR$, EFL, ";          % EFFECTIVE FOCAL LENGTH"

TEMPSTR$="fnumber_eff="
FORMAT .6 
PRINT TEMPSTR$, EFNUM, ";          % EFFECTIVE F-NUMBER"

TEMPSTR$="fnumber="
FORMAT .6 
PRINT TEMPSTR$, FNUM, ";          % F-NUMBER"

FOR i1,1,N,1
	TEMPSTR$="objDist("
	FORMAT .0
	PRINT TEMPSTR$, i1, ")=", OBJDIST(i1), ";          % Object Distance" 
NEXT
OUTPUT SCREEN

!----------------------------------
!----END WRITE Parameters file
!----------------------------------


!---------------------------------------
!CALCULATE THE IMAGE DISTORTION 
!---------------------------------------

!SET TOTAL NUMBER OF FIELDS
NUMFIELD 1

!SELECT FIELD TYPE:  0 FOR ANGLE IN DEGREES
!                    1 FOR OBJECT HEIGHT IN LENS UNITS
!                    2 FOR PARAXIAL IMAGE HEIGHT IN LENS UNITS
!                    3 FOR REAL IMAGE HEIGHT IN LENS UNITS
FTYP=2

!SET TOTAL NUMBER OF WAVELENGTHS
NUMWAVE 1

IMG_SURF_NUM=NSUR()

!SET UP THE DISTORTED IMAGE HEIGHT DATA OUTPUT FILE NAME
OUTPUT SCREEN
OUTPUT_DI_FILE$=BASENAME$ + "_DI_" + ".dat" #commented by Ginni Grover 2014/01/03
!OUTPUT_DI_FILE$=BASENAME$ + "_DI_" + ".xls" #added by Ginni Grover 2014/01/03
PRINT "OUTPUT DISTORTED IMAGE HEIGHT FILENAME:  ", OUTPUT_DI_FILE$
OUTPUT OUTPUT_DI_FILE$

FOR J = 1, IMGHT_NUM, 1
   IMGHT=IMGHT_MIN+(J-1)*(IMGHT_MAX-IMGHT_MIN)/(IMGHT_NUM-1)

   FOR I = 1, WL_NUM, 1
      WLT=WL_MIN+(I-1)*(WL_MAX-WL_MIN)/(WL_NUM-1)
      WAVL 1 = WLT/1000
      PWAV 1
      FLDX 1 = 0.0
      FLDY 1 = IMGHT
      !SET VIGNETTING FACTORS FOR GIVEN IMAGE HEIGHT AND WAVELENGTH
      SETVIG
      UPDATE                 
      RAYTRACE 0, 1, 0, 0
      DISTIMGHT=RAYY(IMG_SURF_NUM)
  
      !WRITE DISTORTED IMAGE HEIGHT DATA TO DI OUTPUT FILE
      FORMAT .6 EXP
      !IF (I == WL_NUM)
         PRINT DISTIMGHT
      !ELSE
      !  PRINT DISTIMGHT, " ",
      !ENDIF    
   NEXT
NEXT

OUTPUT SCREEN

!------------------------------------------------------------------------
!CALCULATE THE CRA = chief ray angle
!------------------------------------------------------------------------

!USE THE SAME PARAMETERS AS IN DISTORTION CALCULATIONS

!SET UP THE CRA DATA OUTPUT FILE NAME
OUTPUT SCREEN
OUTPUT_CRA_FILE$=BASENAME$ + "_CRA_" + ".dat" #commented by Ginni Grover 2014/01/03
!OUTPUT_CRA_FILE$=BASENAME$ + "_CRA_" + ".xls" #added by Ginni Grover 2014/01/03
PRINT "OUTPUT CRA FILENAME:  ", OUTPUT_CRA_FILE$
OUTPUT OUTPUT_CRA_FILE$

FOR J = 1, IMGHT_NUM, 1
   IMGHT=IMGHT_MIN+(J-1)*(IMGHT_MAX-IMGHT_MIN)/(IMGHT_NUM-1)

   FOR I = 1, WL_NUM, 1
      WLT=WL_MIN+(I-1)*(WL_MAX-WL_MIN)/(WL_NUM-1)
      WAVL 1 = WLT/1000
      PWAV 1
      FLDX 1 = 0.0
      FLDY 1 = IMGHT
      !SET VIGNETTING FACTORS FOR GIVEN IMAGE HEIGHT AND WAVELENGTH
      SETVIG
      UPDATE                 
      RAYTRACE 0, 1, 0, 0
      !CALCULATE CRA FOR THE CURRENT FOV (MEASURED IN RADIANS)
      CRA=ACOS(RAYN(IMG_SURF_NUM))
   
      !WRITE CRA DATA TO CRA OUTPUT FILE
      FORMAT .6 EXP
      !IF (I == WL_NUM)
         PRINT CRA
      !ELSE
      !   PRINT CRA, " ",
      !ENDIF    
   NEXT
NEXT

OUTPUT SCREEN
!---------------------------------------
!CALCULATE THE RELATIVE ILLUMINATION
!---------------------------------------

!SET TOTAL NUMBER OF FIELDS
NUMFIELD 2

!SELECT FIELD TYPE:  0 FOR ANGLE IN DEGREES
!                    1 FOR OBJECT HEIGHT IN LENS UNITS
!                    2 FOR PARAXIAL IMAGE HEIGHT IN LENS UNITS
!                    3 FOR REAL IMAGE HEIGHT IN LENS UNITS
FTYP=2

!SET TOTAL NUMBER OF WAVELENGTHS
NUMWAVE 1

!SET UP THE RELATIVE ILLUMINATION DATA OUTPUT FILE NAME
OUTPUT SCREEN
OUTPUT_RI_FILE$=BASENAME$ + "_RI_" + ".dat" #commented by Ginni Grover 2014/01/03
!OUTPUT_RI_FILE$=BASENAME$ + "_RI_" + ".xls" #added by Ginni Grover 2014/01/03
PRINT "OUTPUT RELATIVE ILLUMINATION FILENAME:  ", OUTPUT_RI_FILE$
OUTPUT OUTPUT_RI_FILE$

FOR J = 1, IMGHT_NUM, 1
   IMGHT=IMGHT_MIN+(J-1)*(IMGHT_MAX-IMGHT_MIN)/(IMGHT_NUM-1)

   FOR I = 1, WL_NUM, 1
      WLT=WL_MIN+(I-1)*(WL_MAX-WL_MIN)/(WL_NUM-1)
      WAVL 1 = WLT/1000
      PWAV 1
      FLDX 1 = 0.0
      FLDY 1 = 0.0
      FLDX 2 = 0.0
      FLDY 2 = IMGHT
      !SET VIGNETTING FACTORS FOR GIVEN IMAGE HEIGHT AND WAVELENGTH
      SETVIG
      UPDATE
      RELILLUM=RELI(2)

      !WRITE RELATIVE ILLUMINATION DATA TO RI OUTPUT FILE
      FORMAT .6 EXP
      !IF (I == WL_NUM)
         PRINT RELILLUM
      !ELSE
      !   PRINT RELILLUM, " ",
      !ENDIF   
   NEXT
NEXT

OUTPUT SCREEN

!-------------------------------------------------------------------
! CALCULATE THE PSF
!-------------------------------------------------------------------
FOR I1 = 1, N, 1
	!SET OBJECT DISTANCE
	SURP 0, THIC, OBJDIST(I1)
	
	!SET TOTAL NUMBER OF FIELDS
	NUMFIELD 1
	
	!SELECT FIELD TYPE:  0 FOR ANGLE IN DEGREES
	!                    1 FOR OBJECT HEIGHT IN LENS UNITS
	!                    2 FOR PARAXIAL IMAGE HEIGHT IN LENS UNITS
	!                    3 FOR REAL IMAGE HEIGHT IN LENS UNITS
	FTYP=2
	
	!SET TOTAL NUMBER OF WAVELENGTHS
	NUMWAVE 1
	
	!SET THE MAXIMUM SIZE OF THE VECn ARRAYS FOR THE PSF OUTPUT
	SETVECSIZE PSF_SIZE*PSF_SIZE+2
	
	FOR I = 1, WL_NUM, 1
	   WLT=WL_MIN+(I-1)*(WL_MAX-WL_MIN)/(WL_NUM-1)
	
	   FOR J = 1, IMGHT_NUM, 1
	      WAVL 1 = WLT/1000
	      PWAV 1
	      IMGHT=IMGHT_MIN+(J-1)*(IMGHT_MAX-IMGHT_MIN)/(IMGHT_NUM-1)
	      FLDX 1 = 0.0
	      FLDY 1 = -IMGHT
	      !SET VIGNETTING FACTORS FOR GIVEN IMAGE HEIGHT AND WAVELENGTH
	      SETVIG
	     
	      UPDATE              
	      
	      OUTPUT SCREEN
	
	      !SET UP THE PSF OUTPUT FILE NAME
	      FORMAT .0
	      !OUTPUT_PSF_FILE$=BASENAME$ + "_PSF_" + $STR(J) + "_" + $STR(I) + ".dat" #commented by Ginni Grover 2014/01/02
	      !OUTPUT_PSF_FILE$=BASENAME$ + "_PSF_" + $STR(J) + "_" + $STR(I) + ".xls" #added by Ginni Grover 2014/01/02
	      OUTPUT_PSF_FILE$=BASENAME$ + "_3D_PSF_Dept" + $STR(I1) + "_Fld" + $STR(J) + "_Wave" + $STR(I) + ".dat" #added by Ginni Grover 2014/01/02
	      PRINT "OUTPUT PSF FILENAME:  ", OUTPUT_PSF_FILE$
	
	      !CREATE PSF TEXT DATA AND WRITE TO FFT PSF OUTPUT FILE
	      !WE MODIFIED PSF.CFG WHICH IS A GLOBAL FILE IN THE ZEMAX DIR TO $LENSNAME().CFG WHICH IS A LOCAL FILE IN THE LENS DIR
	      CFG_FILENAME$ = $LENSNAME()+ ".CFG"
	      GETTEXTFILE OUTPUT_PSF_FILE$, Hps, CFG_FILENAME$, 1 
	   NEXT
	NEXT
NEXT

OUTPUT SCREEN
PRINT "-------------YOU ARE ALL DONE!!!---------------"
LABEL 1

!Load original lens file back in Zemax
LOADLENS LENS_FULL_PATH$

!Tell me if you heard the
BEEP
!because I didn't

!---------------------------END OF MACRO-------------------------------------

