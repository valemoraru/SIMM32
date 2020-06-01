* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.

DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness 
    weight IQ household_income
  /STATISTICS=MEAN STDDEV MIN MAX.

FREQUENCIES VARIABLES=cortisol_serum cortisol_saliva mindfulness weight IQ household_income 
    hospital pain sex age STAI_trait pain_cat
  /ORDER=ANALYSIS.

if (sex= "Male") gender=1.
if (sex="male") gender=1.
if (sex="female") gender=0.
execute.



SPSSINC CREATE DUMMIES VARIABLE=hospital 
ROOTNAME1=hospital 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.


REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness
  /SAVE RESID.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ID pain hospital MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  DATA: pain=col(source(s), name("pain"), unit.category())
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("ID"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of pain by ID by hospital"))
  ELEMENT: point(position(ID*pain), color.interior(hospital))
END GPL.

*regression with hospital dummy 

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness hospital_2 hospital_3 hospital_4 
    hospital_5 hospital_6 hospital_7 hospital_8 hospital_9 hospital_10
  /SAVE RESID.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ID Residual_fullmodel hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  DATA: Residual_fullmodel=col(source(s), name("Residual_fullmodel"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("ID"))
  GUIDE: axis(dim(2), label("Unstandardized Residual"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of Unstandardized Residual by ID by hospital"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(ID*Residual_fullmodel), color.interior(hospital))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ID RES_1 hospital MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  DATA: RES_1=col(source(s), name("RES_1"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("ID"))
  GUIDE: axis(dim(2), label("Unstandardized Residual"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of Unstandardized Residual by ID by hospital"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(ID*RES_1), color.interior(hospital))
END GPL.

SORT CASES  BY hospital.
SPLIT FILE LAYERED BY hospital.


SPLIT FILE OFF.




MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness gender
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness gender | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=FIXPRED RESID.

DESCRIPTIVES VARIABLES=FXPRED_1
  /STATISTICS=MEAN STDDEV VARIANCE MIN MAX.

DATASET ACTIVATE DataSet3.
DESCRIPTIVES VARIABLES=pain
  /STATISTICS=MEAN STDDEV MIN MAX.

* explore data B

DATASET ACTIVATE DataSet4.
EXAMINE VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

Encoding: UTF-8.
* explore data B

DATASET ACTIVATE DataSet4.
EXAMINE VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness
  /STATISTICS=MEAN STDDEV MIN MAX.

*dummy 

RECODE sex ('female'=0) ('male'=1) (MISSING=SYSMIS) INTO gender.
EXECUTE.



COMPUTE TSS=5.21 * 5.21.
EXECUTE.



COMPUTE Predictedvalue=3.50-age * 0.05 + STAI_trait * 0.001 -pain_cat * 0.03 +cortisol_serum * 0.61 
    - mindfulness * 0.26 +gender * 0.29.
EXECUTE.

COMPUTE Residualssquared=(pain-Predictedvalue) * ( pain- Predictedvalue) .
EXECUTE.


DESCRIPTIVES VARIABLES = Residualssquared TSS 
/STATISTICS= MEAN STDDEV MIN MAX SUM. 


