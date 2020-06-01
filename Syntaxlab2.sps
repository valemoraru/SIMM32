* Encoding: UTF-8.



*descriptives 

DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness 
  /STATISTICS=MEAN STDDEV MIN MAX.

PPLOT
  /VARIABLES=pain age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
  /NOLOG
  /NOSTANDARDIZE
  /TYPE=Q-Q
  /FRACTION=BLOM
  /TIES=MEAN
  /DIST=NORMAL.

*filter out missing case

DATASET ACTIVATE DataSet1.
USE ALL.
COMPUTE filter_$=(pain <= 10).
VARIABLE LABELS filter_$ 'pain <= 10 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

RECODE sex ('woman'=0) ('female'=0) ('male'=1) INTO gender.
VARIABLE LABELS  gender 'dummy for sex (female=0)'.
EXECUTE.


if (sex="woman") gender=0.
execute.

if (pain=50) pain=5.
execute. 

*bivariate correlations 

CORRELATIONS
  /VARIABLES=pain age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness  
    household_income
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.


DATASET ACTIVATE DataSet1.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness gender
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /SAVE PRED COOK RESID.


DATASET ACTIVATE DataSet1.
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ZPR_1 ZRE_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ZPR_1=col(source(s), name("ZPR_1"))
  DATA: ZRE_1=col(source(s), name("ZRE_1"))
  GUIDE: axis(dim(1), label("Standardized Predicted Value"))
  GUIDE: axis(dim(2), label("Standardized Residual"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of Standardized Residual by Standardized ",
    "Predicted Value"))
  ELEMENT: point(position(ZPR_1*ZRE_1))
END GPL.

* regression without cortisolsaliva

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER gender age STAI_trait pain_cat cortisol_serum mindfulness
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN NORMPROB(ZRESID)
  /SAVE ZPRED ZRESID.

* normality  
  
  DESCRIPTIVES VARIABLES=RES_1
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

* Homoskedastizitat

COMPUTE Residualssquared=RES_1*RES_1.
EXECUTE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Residualssquared
  /METHOD=ENTER gender age STAI_trait pain_cat cortisol_serum mindfulness
  /SCATTERPLOT=(*ZRESID ,*ZPRED).
* normality 
  
  PPLOT
  /VARIABLES=RES_1
  /NOLOG
  /NOSTANDARDIZE
  /TYPE=P-P
  /FRACTION=BLOM
  /TIES=MEAN
  /DIST=NORMAL.

* Chart Builder

* linearity 
.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by age"))
  ELEMENT: point(position(age*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by STAI_trait"))
  ELEMENT: point(position(STAI_trait*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by pain_cat"))
  ELEMENT: point(position(pain_cat*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum pain MISSING=LISTWISE REPORTMISSING=NO    
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_saliva=col(source(s), name("cortisol_serum"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by cortisol_serum"))
  ELEMENT: point(position(cortisol_serum*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by mindfulness"))
  ELEMENT: point(position(mindfulness*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=gender pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: gender=col(source(s), name("gender"), unit.category())
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("dummy for sex (female=0)"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by dummy for sex (female=0)"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(gender*pain))
END GPL.

* final model and AIC


DATASET ACTIVATE DataSet2.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age gender
  /METHOD=ENTER STAI_trait pain_cat cortisol_serum.
