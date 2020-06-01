* Encoding: UTF-8.

 
DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=pain1 pain2 pain3 pain4 age STAI_trait pain_cat cortisol_serum mindfulness
  /STATISTICS=MEAN STDDEV MIN MAX.

  
  * what kind of correlation exists between the four time points? 
   
   CORRELATIONS
  /VARIABLES= pain1 pain2 pain3 pain4
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE. 
  
VARSTOCASES 
  /MAKE pain_rating_time FROM pain1 pain2 pain3 pain4 
  /INDEX=pain(4)
  /KEEP= ID sex age mindfulness pain_cat cortisol_serum STAI_trait
  /NULL=KEEP.



RECODE sex ('female'=0) ('male'=1) INTO gender.
EXECUTE.


SORT CASES  BY day.
SPLIT FILE LAYERED BY day.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness pain_rating_time MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: pain_rating_time=col(source(s), name("pain_rating_time"), unit.category())
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("pain_rating_time"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain_rating_time by mindfulness"))
  ELEMENT: point(position(mindfulness*pain_rating_time))
END GPL.



SPLIT FILE OFF.



MIXED pain_rating_time WITH age mindfulness pain_cat cortisol_serum STAI_trait day gender
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age mindfulness pain_cat cortisol_serum STAI_trait day gender | SSTYPE(3)
  /METHOD=REML
  /PRINT=CPS CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED.
  
MIXED pain_rating_time WITH age mindfulness pain_cat cortisol_serum STAI_trait day gender
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age mindfulness pain_cat cortisol_serum STAI_trait day gender | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT day | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED.

  

.

VARSTOCASES 
  /MAKE pain_rating_time FROM pain_rating_time intercept_prediction slope_prediction
  /INDEX=obs_or_pred(pain_rating_time) 
  /KEEP= ID gender age mindfulness pain_cat cortisol_serum STAI_trait day
  /NULL=KEEP.





* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=day pain_rating_time obs_or_pred MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: day=col(source(s), name("day"))
  DATA: pain_rating_time=col(source(s), name("pain_rating_time"))
  DATA: obs_or_pred=col(source(s), name("obs_or_pred"), unit.category())
  GUIDE: axis(dim(1), label("day"))
  GUIDE: axis(dim(2), label("pain_rating_time"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obs_or_pred"))
  GUIDE: text.title(label("Multiple Line of pain_rating_time by day by obs_or_pred"))
  ELEMENT: line(position(day*pain_rating_time), color.interior(obs_or_pred), missing.wings())
END GPL.

SORT CASES  BY ID. 
SPLIT FILE SEPARATE BY ID.


* Chart Builder.
DATASET ACTIVATE DataSet1.
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=day 
    MEAN(pain_rating_time)[name="MEAN_pain_rating_time"] obs_or_pred MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: day=col(source(s), name("day"))
  DATA: MEAN_pain_rating_time=col(source(s), name("MEAN_pain_rating_time"))
  DATA: obs_or_pred=col(source(s), name("obs_or_pred"), unit.category())
  GUIDE: axis(dim(1), label("day"))
  GUIDE: axis(dim(2), label("Mean pain_rating_time"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obs_or_pred"))
  GUIDE: text.title(label("Multiple Line Mean of pain_rating_time by day by obs_or_pred"))
  ELEMENT: line(position(day*MEAN_pain_rating_time), color.interior(obs_or_pred), missing.wings())
END GPL.

SPLIT FILE OFF. 


*assumptions 

EXAMINE VARIABLES=pain_rating_time BY ID
  /PLOT BOXPLOT STEMLEAF HISTOGRAM
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES EXTREME
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


CORRELATIONS
  /VARIABLES=age mindfulness pain_cat cortisol_serum STAI_trait day pain_rating_time gender
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

MIXED pain_rating_time WITH age mindfulness pain_cat cortisol_serum STAI_trait day gender
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age mindfulness pain_cat cortisol_serum STAI_trait day gender | SSTYPE(3)
  /METHOD=REML
  /RANDOM=INTERCEPT day | SUBJECT(ID) COVTYPE(UN) 
  /SAVE=FIXPRED PRED RESID.



* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=residual_prediction prediction_slope MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: residual_prediction=col(source(s), name("residual_prediction"))
  DATA: prediction_slope=col(source(s), name("prediction_slope"))
  GUIDE: axis(dim(1), label("Residuals"))
  GUIDE: axis(dim(2), label("Predicted Values"))
  GUIDE: text.title(label("Simple Scatter of Predicted Values by Residuals"))
  ELEMENT: point(position(residual_prediction*prediction_slope))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=residual_prediction fix_predicted_slope 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: residual_prediction=col(source(s), name("residual_prediction"))
  DATA: fix_predicted_slope=col(source(s), name("fix_predicted_slope"))
  GUIDE: axis(dim(1), label("Residuals"))
  GUIDE: axis(dim(2), label("Fixed Predicted Values"))
  GUIDE: text.title(label("Simple Scatter of Fixed Predicted Values by Residuals"))
  ELEMENT: point(position(residual_prediction*fix_predicted_slope))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=residual_prediction ID MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: residual_prediction=col(source(s), name("residual_prediction"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  GUIDE: axis(dim(1), label("Residuals"))
  GUIDE: axis(dim(2), label("ID"))
  GUIDE: text.title(label("Simple Histogram of ID by Residuals"))
  ELEMENT: interval(position(residual_prediction*ID), shape.interior(shape.square))
END GPL.

PPLOT
  /VARIABLES=residual_prediction
  /NOLOG
  /NOSTANDARDIZE
  /TYPE=Q-Q
  /FRACTION=BLOM
  /TIES=MEAN
  /DIST=NORMAL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age residual_prediction MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: residual_prediction=col(source(s), name("residual_prediction"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by age"))
  ELEMENT: point(position(age*residual_prediction))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness residual_prediction MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: residual_prediction=col(source(s), name("residual_prediction"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by mindfulness"))
  ELEMENT: point(position(mindfulness*residual_prediction))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat residual_prediction MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: residual_prediction=col(source(s), name("residual_prediction"))
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by pain catastrophizing"))
  ELEMENT: point(position(pain_cat*residual_prediction))
END GPL.


* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum residual_prediction MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: residual_prediction=col(source(s), name("residual_prediction"))
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by cortisol_serum"))
  ELEMENT: point(position(cortisol_serum*residual_prediction))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait residual_prediction MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: residual_prediction=col(source(s), name("residual_prediction"))
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by STAI_trait"))
  ELEMENT: point(position(STAI_trait*residual_prediction))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=day residual_prediction MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: day=col(source(s), name("day"))
  DATA: residual_prediction=col(source(s), name("residual_prediction"))
  GUIDE: axis(dim(1), label("day"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by day"))
  ELEMENT: point(position(day*residual_prediction))
END GPL.

COMPUTE residualssquared=residual_prediction * residual_prediction.
EXECUTE.



SPSSINC CREATE DUMMIES VARIABLE=ID 
ROOTNAME1=IDdummy 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT residualssquared
  /METHOD=ENTER IDdummy_2 IDdummy_3 IDdummy_4 IDdummy_5 IDdummy_6 IDdummy_7 IDdummy_8 IDdummy_9 
    IDdummy_10 IDdummy_11 IDdummy_12 IDdummy_13 IDdummy_14 IDdummy_15 IDdummy_16 IDdummy_17 IDdummy_18 
    IDdummy_19 IDdummy_20.


MIXED pain_rating_time WITH age mindfulness pain_cat cortisol_serum STAI_trait day gender
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age mindfulness pain_cat cortisol_serum STAI_trait day gender | SSTYPE(3)
  /METHOD=REML
  /RANDOM=INTERCEPT day | SUBJECT(ID) COVTYPE(UN) SOLUTION
  /SAVE=FIXPRED PRED RESID.


PPLOT
  /VARIABLES=random_effect_prediction
  /NOLOG
  /NOSTANDARDIZE
  /TYPE=Q-Q
  /FRACTION=BLOM
  /TIES=MEAN
  /DIST=NORMAL.


DESCRIPTIVES VARIABLES=random_effect_prediction
  /STATISTICS=MEAN SUM STDDEV MIN MAX KURTOSIS SKEWNESS.



COMPUTE daysquaredcenterede=(day-2.5)* (day-2.5).
EXECUTE.

MIXED pain_rating_time WITH age mindfulness pain_cat cortisol_serum STAI_trait day gender 
    daysquaredcenterede
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age mindfulness pain_cat cortisol_serum STAI_trait day gender daysquaredcenterede | 
    SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT day  | SUBJECT(ID) COVTYPE(UN)
  /SAVE=FIXPRED.

VARSTOCASES 
  /MAKE pain_rating_time FROM pain_rating_time predicted
  /INDEX=obsorpred(pain_rating_time)
  /KEEP= ID gender age mindfulness pain_cat cortisol_serum STAI_trait daysquaredcenterede day
  /NULL=KEEP.



DATASET ACTIVATE DataSet1.
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=day pain_rating_time obsorpred MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: day=col(source(s), name("day"))
  DATA: pain_rating_time=col(source(s), name("pain_rating_time"))
  DATA: obsorpred=col(source(s), name("obsorpred"), unit.category())
  GUIDE: axis(dim(1), label("day"))
  GUIDE: axis(dim(2), label("pain_rating_time"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obsorpred"))
  GUIDE: text.title(label("Multiple Line of pain_rating_time by day by obsorpred"))
  ELEMENT: line(position(day*pain_rating_time), color.interior(obsorpred), missing.wings())
END GPL.

SORT CASES  BY ID. 
SPLIT FILE SEPARATE BY ID.


* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=day pain_rating_time obsorpred MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: day=col(source(s), name("day"))
  DATA: pain_rating_time=col(source(s), name("pain_rating_time"))
  DATA: obsorpred=col(source(s), name("obsorpred"), unit.category())
  GUIDE: axis(dim(1), label("day"))
  GUIDE: axis(dim(2), label("pain_rating_time"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obsorpred"))
  GUIDE: text.title(label("Multiple Line of pain_rating_time by day by obsorpred"))
  ELEMENT: line(position(day*pain_rating_time), color.interior(obsorpred), missing.wings())
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=day pain_rating_time obsorpred MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: day=col(source(s), name("day"))
  DATA: pain_rating_time=col(source(s), name("pain_rating_time"))
  DATA: obsorpred=col(source(s), name("obsorpred"), unit.category())
  GUIDE: axis(dim(1), label("day"))
  GUIDE: axis(dim(2), label("pain_rating_time"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obsorpred"))
  GUIDE: text.title(label("Grouped Scatter of pain_rating_time by day by obsorpred"))
  ELEMENT: point(position(day*pain_rating_time), color.interior(obsorpred))
END GPL.

SPLIT FILE OFF. 






