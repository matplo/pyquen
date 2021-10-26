*------------------------------------------------------------------------------
*
* Filename             : TEST_PYQUEN.F
*
*==============================================================================
*
* Description : Example program to simulate partonic rescattering and energy
*               loss in quark-gluon plasma in AA collisions with PYQUEN-code   
*               (should be compiled with pyquen1_5.f and latest pythia 
*               (pythia6401.f or later versions)
*                
*==============================================================================
 
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      IMPLICIT INTEGER(I-N)
      INTEGER PYK,Av,Bv,Cv
      external pydata  
      external pyp,pyr,pyk
      external PYQVER
      common /pyjets/ n,npad,k(4000,5),p(4000,5),v(4000,5)
      common /pydat1/ mstu(200),paru(200),mstj(200),parj(200)         
      common /pysubs/ msel,mselpd,msub(500),kfin(2,-40:40),ckin(200)
      common /pypars/ mstp(200),parp(200),msti(200),pari(200)
      common /pyqpar/ T0,tau0,nf,ienglu,ianglu  
      common /plfpar/ bgen
     
      open(12,FILE='PyInput',STATUS='OLD',IOSTAT=ios,ACTION='READ')

      IF( ios/=0) THEN
       WRITE(6,*) 'Error opening input file PyInput.'
       STOP
      ENDIF

* printout of PYQUEN version
* input: 1 - printout, 0 - no printout
* output: first (Av), second (Bv) and third (Cv) digits of version
      call PYQVER(1,Av,Bv,Cv)
c      WRITE(6,3) INT(Av),INT(Bv),INT(Cv)
c3     FORMAT('PYQUEN version=',I1.1,'.',I1.1,'.',I1.1)


* set initial beam parameters 

      energy=5500.d0                 ! c.m.s energy per nucleon pair 
      A=207.d0                       ! atomic weigth         
      ifb=0                          ! flag for fixed impact parameter
      bfix=0.d0                      ! fixed impact parameter in [fm] 
c      ifb=1                          ! flag for distribution of impact parameter between bmin and bmax 
      bmin=0.d0                      ! minimum impact parameter in [fm]
      bmax=30.d0                     ! maximum impact parameter in [fm]

      READ (12,*) 
      READ (12,*) ntot
      READ (12,*) energy
      READ (12,*) A
      READ (12,*) ifb
      READ (12,*) bfix
      READ (12,*) bmin
      READ (12,*) bmax

c      write(6,*) 'Energy = ',energy
c      write(6,*) 'A = ',A
c      write(6,*) 'ifb = ',ifb
c      write(6,*) 'bfix = ',bfix
c      write(6,*) 'bmin = ',bmin
c      write(6,*) 'bmax = ',bmax

* set of input PYQUEN parameters: 
* ienglu=0 - radiative and collisional loss, ienglu=1 - only radiative loss, 
* ienglu=2 - only collisional loss;  
* ianglu=0 - small-angular radiation, ianglu=1 - wide angular radiation, 
* inanglu=2 - collinear radiation 

      ienglu=0                       ! set type of partonic energy loss
      ianglu=0                       ! set angular spectrum of gluon radiation    
      T0=1.d0                        ! initial QGP temperature 
      tau0=0.1d0                     ! proper time of QGP formation 
      nf=0                           ! number of active quark flavours in QGP 

      READ (12,*) 
      READ (12,*) ienglu
      READ (12,*) ianglu
      READ (12,*) T0
      READ (12,*) tau0
      READ (12,*) nf

c      write(6,*) 'ienglu = ',ienglu
c      write(6,*) 'ianglu = ',ianglu
c      write(6,*) 'T0 = ',T0
c      write(6,*) 'tau0 = ',tau0
c      write(6,*) 'nf = ',nf

* set of input PYTHIA parameters 

      msel=1                        ! QCD-dijet production 
      paru(14)=1.d0                 ! tolerance parameter to adjust fragmentation 
      mstu(21)=1                    ! avoid stopping run 
      ckin(3)=50.d0                 ! minimum pt in initial hard sub-process 
      mstp(52)=1                    ! LAPDF - 2 
      mstp(51)=7                    ! CTEQ5M pdf 
      mstp(81)=0                    ! pp multiple scattering off 
      mstp(111)=0                   ! hadronization off 

      READ (12,*) 
      READ (12,*) msel
      READ (12,*) paru(14)
      READ (12,*) mstu(21)
      READ (12,*) ckin(3)
      READ (12,*) mstp(52)
      READ (12,*) mstp(51)
      READ (12,*) mstp(81)
      READ (12,*) mstp(111)

c      write(6,*) 'msel = ',msel
c      write(6,*) 'paru(14) = ',paru(14)
c      write(6,*) 'mstu(21) = ',mstu(21)
c      write(6,*) 'ckin(3) = ',ckin(3)
c      write(6,*) 'mstp(52) = ',mstp(52)
c      write(6,*) 'mstp(51) = ',mstp(51)
c      write(6,*) 'mstp(81) = ',mstp(81)
c      write(6,*) 'mstp(111) = ',mstp(111)



* set original test values for mean pt and event multiplicity 

      pta0=0.77d0 
      dna0=207.d0 

      READ (12,*) 
      READ (12,*) pta0
      READ (12,*) dna0
 
c      write(6,*) 'pta0 = ',pta0
c      write(6,*) 'dna0 = ',dna0
 
* set initial test values and its rms 

      ptam=0.d0 
      ptrms=0.d0        
      dnam=0.d0  
      dnrms=0.d0 

      READ (12,*) 
      READ (12,*) ptam
      READ (12,*) ptrms
      READ (12,*) dnam
      READ (12,*) dnrms

c      write(6,*) 'ptam = ',ptam
c      write(6,*) 'ptrms = ',ptrms
c      write(6,*) 'dnam = ',dnam
c      write(6,*) 'dnrms = ',dnrms

* initialization of pythia configuration 
      call pyinit('CMS','p','p',energy)     

* set number of generated events 
c      ntot=10000
       
      do ne=1,ntot                  ! cycle on events 
c       mstj(41)=0                   ! vacuum showering off 
       call pyevnt                  ! generate single partonic jet event         
       call pyquen(A,ifb,bfix,bmin,bmax)      ! set parton rescattering and energy loss        
c       call pylist(1)
       call pyexec                  ! hadronization done 
                   
c       call pyedit(2)               ! remove unstable particles and partons 
	 
       do ip=1,n                    ! cycle on n particles        
        pt=pyp(ip,10)               ! transverse momentum pt 
* add current test value of pt and its rms 
	ptam=ptam+pt  
	ptrms=ptrms+(pt-pta0)**2
       end do 
       
       write(6,*) 'START Event #',ne,'    Impact parameter',bgen,'fm'
c       write(6,*) 'pyhepc called.'
c       call pyhepc(1)
c       call pylist(1)
       write(6,*) 'END Event #',ne
* add current test value of event multiplicity and its rms 
       dnam=dnam+n          
       dnrms=dnrms+(n-dna0)**2 
      end do 

* test calculating and printing of original "true" numbers 
* and generated one's (with statistical errors) 
      ptam=ptam/dnam 
      ptrms=dsqrt(ptrms)/dnam
      dnam=dnam/ntot
      dnrms=dsqrt(dnrms)/ntot 
      write(6,1) dna0
1     format(2x,'True mean multiplicity =',d10.3) 
      write(6,2) dnam, dnrms 
2     format(2x,'Generated mean multiplicity      =',d10.3,3x,
     > '+-  ',d9.2) 
      write(6,5) pta0
5     format(2x,'True mean transverse momentum =',d9.2)   
      write(6,6) ptam, ptrms 
6     format(2x,'Generated mean transverse momentum      =',d9.2,3x,
     > '+-  ',d9.2)    
               
      end
*******************************************************************************
