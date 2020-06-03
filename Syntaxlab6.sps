* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 
    ar18 ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28 sex party liberal
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

FREQUENCIES VARIABLES=ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 
    ar18 ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28 sex party liberal
  /ORDER=ANALYSIS.



FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /PRINT INITIAL KMO EXTRACTION
  /PLOT EIGEN
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /ROTATION NOROTATE
  /METHOD=CORRELATION.



set mxloops=9000 printback=off width=80  seed = 1953125.
matrix.

GET raw / FILE = * / missing=omit / VAR = ar1 to ar28.

* Enter the desired number of parallel data sets here.
compute ndatsets = 1000.

* Enter the desired percentile here.
compute percent  = 95.

* Enter either
  1 for principal components analysis, or
  2 for principal axis/common factor analysis.
compute kind = 2 .

* Enter either
  1 for normally distributed random data generation parallel analysis, or
  2 for permutations of the raw data set.
compute randtype = 2.



compute ncases   = nrow(raw). 
compute nvars    = ncol(raw).

* principal components analysis & random normal data generation.

do if (kind = 1 and randtype = 1).
compute nm1 = 1 / (ncases-1).
compute vcv = nm1 * (sscp(raw) - ((t(csum(raw))*csum(raw))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute realeval = eval(d * vcv * d).
compute evals = make(nvars,ndatsets,-9999).
loop #nds = 1 to ndatsets.
compute x = sqrt(2 * (ln(uniform(ncases,nvars)) * -1) ) &*
            cos(6.283185 * uniform(ncases,nvars) ).
compute vcv = nm1 * (sscp(x) - ((t(csum(x))*csum(x))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute evals(:,#nds) = eval(d * vcv * d).
end loop.
end if.

* principal components analysis & raw data permutation.
do if (kind = 1 and randtype = 2).
compute nm1 = 1 / (ncases-1).
compute vcv = nm1 * (sscp(raw) - ((t(csum(raw))*csum(raw))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute realeval = eval(d * vcv * d).
compute evals = make(nvars,ndatsets,-9999).
loop #nds = 1 to ndatsets.
compute x = raw.
loop #c = 1 to nvars.
loop #r = 1 to (ncases -1).
compute k = trunc( (ncases - #r + 1) * uniform(1,1) + 1 )  + #r - 1.
compute d = x(#r,#c).
compute x(#r,#c) = x(k,#c).
compute x(k,#c) = d.
end loop.
end loop.
compute vcv = nm1 * (sscp(x) - ((t(csum(x))*csum(x))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute evals(:,#nds) = eval(d * vcv * d).
end loop.
end if.

* PAF/common factor analysis & random normal data generation.

do if (kind = 2 and randtype = 1).
compute nm1 = 1 / (ncases-1).
compute vcv = nm1 * (sscp(raw) - ((t(csum(raw))*csum(raw))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute cr = (d * vcv * d).
compute smc = 1 - (1 &/ diag(inv(cr)) ).
call setdiag(cr,smc).
compute realeval = eval(cr).
compute evals = make(nvars,ndatsets,-9999).
compute nm1 = 1 / (ncases-1).
loop #nds = 1 to ndatsets.
compute x = sqrt(2 * (ln(uniform(ncases,nvars)) * -1) ) &*
            cos(6.283185 * uniform(ncases,nvars) ).
compute vcv = nm1 * (sscp(x) - ((t(csum(x))*csum(x))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute r = d * vcv * d.
compute smc = 1 - (1 &/ diag(inv(r)) ).
call setdiag(r,smc).
compute evals(:,#nds) = eval(r).
end loop.
end if.

* PAF/common factor analysis & raw data permutation.
do if (kind = 2 and randtype = 2).
compute nm1 = 1 / (ncases-1).
compute vcv = nm1 * (sscp(raw) - ((t(csum(raw))*csum(raw))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute cr = (d * vcv * d).
compute smc = 1 - (1 &/ diag(inv(cr)) ).
call setdiag(cr,smc).
compute realeval = eval(cr).
compute evals = make(nvars,ndatsets,-9999).
compute nm1 = 1 / (ncases-1).
loop #nds = 1 to ndatsets.
compute x = raw.
loop #c = 1 to nvars.
loop #r = 1 to (ncases -1).
compute k = trunc( (ncases - #r + 1) * uniform(1,1) + 1 )  + #r - 1.
compute d = x(#r,#c).
compute x(#r,#c) = x(k,#c).
compute x(k,#c) = d.
end loop.
end loop.
compute vcv = nm1 * (sscp(x) - ((t(csum(x))*csum(x))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute r = d * vcv * d.
compute smc = 1 - (1 &/ diag(inv(r)) ).
call setdiag(r,smc).
compute evals(:,#nds) = eval(r).
end loop.
end if.

* identifying the eigenvalues corresponding to the desired percentile.
compute num = rnd((percent*ndatsets)/100).
compute results = { t(1:nvars), realeval, t(1:nvars), t(1:nvars) }.
loop #root = 1 to nvars.
compute ranks = rnkorder(evals(#root,:)).
loop #col = 1 to ndatsets.
do if (ranks(1,#col) = num).
compute results(#root,4) = evals(#root,#col).
break.
end if.
end loop.
end loop.
compute results(:,3) = rsum(evals) / ndatsets.

print /title="PARALLEL ANALYSIS:".
do if (kind = 1 and randtype = 1).
print /title="Principal Components & Random Normal Data Generation".
else if (kind = 1 and randtype = 2).
print /title="Principal Components & Raw Data Permutation".
else if (kind = 2 and randtype = 1).
print /title="PAF/Common Factor Analysis & Random Normal Data Generation".
else if (kind = 2 and randtype = 2).
print /title="PAF/Common Factor Analysis & Raw Data Permutation".
end if.
compute specifs = {ncases; nvars; ndatsets; percent}.
print specifs /title="Specifications for this Run:"
 /rlabels="Ncases" "Nvars" "Ndatsets" "Percent".
print results 
 /title="Raw Data Eigenvalues, & Mean & Percentile Random Data Eigenvalues"
 /clabels="Root" "Raw Data" "Means" "Prcntyle"  /format "f12.6".

do if   (kind = 2).
print / space = 1.
print /title="Warning: Parallel analyses of adjusted correlation matrices".
print /title="eg, with SMCs on the diagonal, tend to indicate more factors".
print /title="than warranted (Buja, A., & Eyuboglu, N., 1992, Remarks on parallel".
print /title="analysis. Multivariate Behavioral Research, 27, 509-540.).".
print /title="The eigenvalues for trivial, negligible factors in the real".
print /title="data commonly surpass corresponding random data eigenvalues".
print /title="for the same roots. The eigenvalues from parallel analyses".
print /title="can be used to determine the real data eigenvalues that are".
print /title="beyond chance, but additional procedures should then be used".
print /title="to trim trivial factors.".
print / space = 2.
print /title="Principal components eigenvalues are often used to determine".
print /title="the number of common factors. This is the default in most".
print /title="statistical software packages, and it is the primary practice".
print /title="in the literature. It is also the method used by many factor".
print /title="analysis experts, including Cattell, who often examined".
print /title="principal components eigenvalues in his scree plots to determine".
print /title="the number of common factors. But others believe this common".
print /title="practice is wrong. Principal components eigenvalues are based".
print /title="on all of the variance in correlation matrices, including both".
print /title="the variance that is shared among variables and the variances".
print /title="that are unique to the variables. In contrast, principal".
print /title="axis eigenvalues are based solely on the shared variance".
print /title="among the variables. The two procedures are qualitatively".
print /title="different. Some therefore claim that the eigenvalues from one".
print /title="extraction method should not be used to determine".
print /title="the number of factors for the other extraction method.".
print /title="The issue remains neglected and unsettled.".
end if.

compute root      = results(:,1).
compute rawdata = results(:,2).
compute percntyl = results(:,4).

save results /outfile= 'C:\Users\40749\Desktop\facultate\Master\Advanced statistics\screedata.sav' / var=root rawdata means percntyl .

end matrix.

* plots the eigenvalues, by root, for the real/raw data and for the random data.

GET file= 'C:\Users\40749\Desktop\facultate\Master\Advanced statistics\screedata.sav'.
TSPLOT VARIABLES= rawdata means percntyl /ID= root /NOLOG.



FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /PLOT EIGEN
  /CRITERIA FACTORS(5) ITERATE(25)
  /EXTRACTION PAF
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /METHOD=CORRELATION.

*mahalanobis 

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT liberal
  /METHOD=ENTER ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 
    ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /SAVE MAHAL.



SORT CASES  BY mahalanobis.
SPLIT FILE LAYERED BY mahalanobis.

COMPUTE pvalue=($CASENUM-0.5)/149.
EXECUTE.

COMPUTE chisqrd=IDF.CHISQ(pvalue,28).
EXECUTE.

SPLIT FILE OFF. 
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mahalanobis chisqrd MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mahalanobis=col(source(s), name("mahalanobis"))
  DATA: chisqrd=col(source(s), name("chisqrd"))
  GUIDE: axis(dim(1), label("Mahalanobis Distance"))
  GUIDE: axis(dim(2), label("chisqrd"))
  GUIDE: text.title(label("Simple Scatter of chisqrd by Mahalanobis Distance"))
  ELEMENT: point(position(mahalanobis*chisqrd))
END GPL.

FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /PRINT UNIVARIATE INITIAL EXTRACTION ROTATION
  /FORMAT SORT
  /PLOT EIGEN
  /CRITERIA FACTORS(5) ITERATE(25)
  /EXTRACTION PAF
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.



* first round of extraction ar25 ar16 ar 14 ar11 ar3 

FACTOR
  /VARIABLES ar1 ar2 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar12 ar13 ar15  ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar4 ar5 ar6 ar7 ar8 ar9 ar10  ar12 ar13 ar15 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar26 ar27 ar28
  /PRINT UNIVARIATE INITIAL EXTRACTION ROTATION
  /FORMAT SORT
  /PLOT EIGEN
  /CRITERIA FACTORS(5) ITERATE(25)
  /EXTRACTION PAF
  /CRITERIA ITERATE(25)
  /ROTATION PROMAX(4)
  /SAVE REG(ALL)
  /METHOD=CORRELATION.


*exclude factor 5 

FACTOR
  /VARIABLES ar1 ar2 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar12 ar13 ar15  ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar4 ar5 ar6 ar7 ar8 ar9 ar10  ar12 ar13 ar15 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar26 ar27 ar28
  /PRINT UNIVARIATE INITIAL EXTRACTION ROTATION
  /FORMAT SORT
  /PLOT EIGEN
  /CRITERIA FACTORS(4) ITERATE(25)
  /EXTRACTION PAF
  /CRITERIA ITERATE(25)
  /ROTATION PROMAX(4)
  /SAVE REG(ALL)
  /METHOD=CORRELATION.

* exclude factor 4

FACTOR
  /VARIABLES ar1 ar2 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar12 ar13 ar15  ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar4 ar5 ar6 ar7 ar8 ar9 ar10  ar12 ar13 ar15 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar26 ar27 ar28
  /PRINT UNIVARIATE INITIAL EXTRACTION ROTATION
  /FORMAT SORT
  /PLOT EIGEN
  /CRITERIA FACTORS(3) ITERATE(25)
  /EXTRACTION PAF
  /CRITERIA ITERATE(25)
  /ROTATION PROMAX(4)
  /SAVE REG(ALL)
  /METHOD=CORRELATION.

*EXCLUDE ITEM 8 

FACTOR
  /VARIABLES ar1 ar2 ar4 ar5 ar6 ar7 ar9 ar10 ar12 ar13 ar15  ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar4 ar5 ar6 ar7 ar9 ar10  ar12 ar13 ar15 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar26 ar27 ar28
  /PRINT UNIVARIATE INITIAL EXTRACTION ROTATION
  /FORMAT SORT
  /PLOT EIGEN
  /CRITERIA FACTORS(3) ITERATE(25)
  /EXTRACTION PAF
  /CRITERIA ITERATE(25)
  /ROTATION PROMAX(4)
  /SAVE REG(ALL)
  /METHOD=CORRELATION.



*regression with three factors 



SPSSINC CREATE DUMMIES VARIABLE=party 
ROOTNAME1=party_ 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.


RECODE sex (1=0) (2=1) (SYSMIS=SYSMIS).
EXECUTE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT liberal
  /METHOD=ENTER sex AnimalResearchRights Morality Wildlifehunting party__2 party__3 party__4.


