* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
RECODE Sex ('female'=0) ('male'=1) INTO sexdummy.
VARIABLE LABELS  sexdummy '0 female 1 male'.
EXECUTE.

RECODE Embarked ('S'=1) ('C'=2) ('Q'=3) INTO Embarkeddummy.
VARIABLE LABELS  Embarkeddummy 'S=1 C=2 Q=3'.
EXECUTE.

FREQUENCIES VARIABLES=Survived
  /ORDER=ANALYSIS.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived MEAN(PassengerId)[name="MEAN_PassengerId"] 
    Pclass MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: MEAN_PassengerId=col(source(s), name("MEAN_PassengerId"))
  DATA: Pclass=col(source(s), name("Pclass"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Mean PassengerId"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Pclass"))
  GUIDE: text.title(label("Stacked Bar Mean of PassengerId by Survived by Pclass"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Survived*MEAN_PassengerId), color.interior(Pclass), 
    shape.interior(shape.square))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived COUNT()[name="COUNT"] Sex MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Sex=col(source(s), name("Sex"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Sex"))
  GUIDE: text.title(label("Stacked Bar Count of Survived by Sex"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Survived*COUNT), color.interior(Sex), 
    shape.interior(shape.square))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived COUNT()[name="COUNT"] Embarked 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Embarked=col(source(s), name("Embarked"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Embarked"))
  GUIDE: text.title(label("Stacked Bar Count of Survived by Embarked"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Survived*COUNT), color.interior(Embarked), 
    shape.interior(shape.square))
END GPL.

CROSSTABS
  /TABLES=Survived BY Embarked
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES=Sex BY Embarked
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.





CROSSTABS
  /TABLES=Pclass BY Embarked
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.

COMPUTE Travelalone=SibSp + Parch.
EXECUTE.

CROSSTABS
  /TABLES=Survived BY Travelalone
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.

FREQUENCIES VARIABLES=Age
  /NTILES=4
  /ORDER=ANALYSIS.

RECODE Age (SYSMIS=SYSMIS) (-1 thru 15=1) (15.1 thru 20=2) (20.1 thru 28=3) (28.1 thru 38=4) (38 
    thru 100=5) INTO Agecat.
VARIABLE LABELS  Agecat 'categories for age'.
EXECUTE.

RECODE if Agecat =1 AND sexdummy=0
INTO Womanchild. 
VARIABLE LABELS Womanchild 'a woman and child'.
EXECUTE. 

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Agecat MEAN(PassengerId)[name="MEAN_PassengerId"] 
    Survived MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Agecat=col(source(s), name("Agecat"), unit.category())
  DATA: MEAN_PassengerId=col(source(s), name("MEAN_PassengerId"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  COORD: rect(dim(1,2), cluster(3,0))
  GUIDE: axis(dim(3), label("categories for age"))
  GUIDE: axis(dim(2), label("Mean PassengerId"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Clustered Bar Mean of PassengerId by categories for age by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval(position(Survived*MEAN_PassengerId*Agecat), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

FREQUENCIES VARIABLES=Agecat
  /NTILES=4
  /ORDER=ANALYSIS.


IF  (sexdummy=0  & Agecat=1) womanchild=sexdummy + Agecat.
EXECUTE.


SPSSINC CREATE DUMMIES VARIABLE=Embarkeddummy 
ROOTNAME1=City 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO
MACRONAME1="Embarking cities ".

NOMREG Survived (BASE=LAST ORDER=ASCENDING) WITH Travelalone sexdummy City_2 City_3 Pclass Age
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI
  /SAVE PREDCAT.





COMPUTE interactiongenderalone=Travelalone * sexdummy.
EXECUTE.


* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Age Survived MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Age=col(source(s), name("Age"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  COORD: transpose(mirror(rect(dim(1,2))))
  GUIDE: axis(dim(1), label("Age"))
  GUIDE: axis(dim(1), opposite(), label("Age"))
  GUIDE: axis(dim(2), label(""))
  GUIDE: axis(dim(3), label("Survived"), opposite(), gap(0px))
  GUIDE: legend(aesthetic(aesthetic.color), null())
  GUIDE: text.title(label("Population Pyramid Frequency Age  by Survived"))
  ELEMENT: interval(position(summary.count(bin.rect(Age*1*Survived))), color.interior(Survived))
END GPL.

COMPUTE agegender=0.
if (sexdummy=0 AND Agecat=1) agegender=1.
if (sexdummy=0 AND Agecat=2) agegender=2.
if (sexdummy=0 AND Agecat=3) agegender=3. 
if (sexdummy=0 AND Agecat=4) agegender=4.
if (sexdummy=0 AND Agecat=5) agegender=5. 
if (sexdummy=1 AND Agecat=1) agegender=6.
if (sexdummy=1 AND Agecat=2) agegender=7. 
if (sexdummy=1 AND Agecat=3) agegender=8.
if (sexdummy=1 AND Agecat=4) agegender=9.
if (sexdummy=1 AND Agecat=5) agegender=10. 
if (sexdummy=. AND Agecat=.) agegender=. 
execute. 



DATASET ACTIVATE DataSet1.
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=agegender MEAN(PassengerId)[name="MEAN_PassengerId"] 
    Survived MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: agegender=col(source(s), name("agegender"), unit.category())
  DATA: MEAN_PassengerId=col(source(s), name("MEAN_PassengerId"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("agegender"))
  GUIDE: axis(dim(2), label("Mean PassengerId"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Mean of PassengerId by agegender by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(agegender*MEAN_PassengerId), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=agegender MEAN(PassengerId)[name="MEAN_PassengerId"] 
    Survived MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: agegender=col(source(s), name("agegender"), unit.category())
  DATA: MEAN_PassengerId=col(source(s), name("MEAN_PassengerId"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  COORD: rect(dim(1,2), cluster(3,0))
  GUIDE: axis(dim(3), label("agegender"))
  GUIDE: axis(dim(2), label("Mean PassengerId"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Clustered Bar Mean of PassengerId by agegender by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval(position(Survived*MEAN_PassengerId*agegender), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=COUNT()[name="COUNT"] agegender Survived 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: agegender=col(source(s), name("agegender"), unit.category())
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  COORD: transpose(mirror(rect(dim(1,2))))
  GUIDE: axis(dim(1), label("agegender"))
  GUIDE: axis(dim(1), opposite(), label("agegender"))
  GUIDE: axis(dim(2), label(""))
  GUIDE: axis(dim(3), label("Survived"), opposite(), gap(0px))
  GUIDE: legend(aesthetic(aesthetic.color), null())
  GUIDE: text.title(label("Population Pyramid Count agegender  by Survived"))
  ELEMENT: interval(position(agegender*COUNT*Survived), color.interior(Survived))
END GPL.

FREQUENCIES VARIABLES=agegender Survived
  /ORDER=ANALYSIS.




SPSSINC CREATE DUMMIES VARIABLE=agegender 
ROOTNAME1=agegender 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

COMPUTE VARIABLE 
female1bis= female1+female2
male1bis=male1+ male2
execute. 


NOMREG Survived (BASE=LAST ORDER=ASCENDING) WITH Pclass Age sexdummy City_1 City_2 City_3 
    interactiongenderalone agegender_2 agegender_3 agegender_4 agegender_5 agegender_6 agegender_7 
    agegender_8 agegender_9 agegender_10 agegender_11 Travelalone
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=PARAMETER SUMMARY LRT CPS STEP MFI.





* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Travelalone 
    MEAN(PassengerId)[name="MEAN_PassengerId"] Survived MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Travelalone=col(source(s), name("Travelalone"), unit.category())
  DATA: MEAN_PassengerId=col(source(s), name("MEAN_PassengerId"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Travelalone"))
  GUIDE: axis(dim(2), label("Mean PassengerId"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Mean of PassengerId by Travelalone by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Travelalone*MEAN_PassengerId), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.


SPSSINC CREATE DUMMIES VARIABLE=Travelalone 
ROOTNAME1=travelwith 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=YES.



NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Pclass Age female2 female3 female4  male1 
    male2 male3 male4  City_2 City_3 travelwith_1 travelwith_2 travelwith_4 travelwith_5 
    travelwith_6 travelwith_7
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC
  /SAVE PREDCAT.
