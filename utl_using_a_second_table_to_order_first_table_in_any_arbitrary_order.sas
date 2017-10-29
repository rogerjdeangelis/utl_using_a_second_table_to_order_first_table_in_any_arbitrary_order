Using a second table to order first table in any arbitrary order

  Gross oversimplification of  useful index lookup.

  WORKING CODE
  WPS/PROC-R  IML/R(just as easy)
  ================================

   INPUT           INDEX TABLE

    3 6 9          3 6 9  ==> 9 is an index, 9th item in first table becomes 9
    2 5 8          2 5 8      7 becomes 9 in the first table
    1 4 7(->9)     1 4 7

   PROCESS (This is just one ordering)

     A[]<-A[B]
     * gave up on non array SAS/WPS without R see end of post;

   OUTPUT

     1 4 7
     2 5 8
     3 6 9

 SAS/WPS

  GAVE up on the non array datastep solution
  see attempt on end?


HAVE
====

SD1.HAVDAT total obs=3

  x1    x2    x3

   3     6     9
   2     5     8
   1     4     7

INDEX TABLE

SD1.HAVINDEX total obs=3

 IDX1    IDX2    IDX3

   3       6       9
   2       5       8
   1       4       7



WANT
====

WORK.WANT total obs=3

 V1    V2    V3

  1     4     7
  2     5     8
  3     6     9

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

libname sd1 "d:/sd1";

* this is a matrix of indexes to be used with sd1.Dat;
data sd1.havDat;
input x1 x2 x3;
cards4;
3 6 9
2 5 8
1 4 7
;;;;
run;quit;


* this is a matrix of indexes to be used with sd1.Dat;
data sd1.havIndex;
input idx1 idx2 idx3;
cards4;
3 6 9
2 5 8
1 4 7
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_wps64('
libname sd1 sas7bdat "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
A<-as.matrix(read_sas("d:/sd1/havdat.sas7bdat"));
B<-as.matrix(read_sas("d:/sd1/havindex.sas7bdat"));
A[]<-A[B];
endsubmit;
import r=A data=wrk.WANT;
run;quit;
');

*
  __ _  __ ___   _____   _   _ _ __
 / _` |/ _` \ \ / / _ \ | | | | '_ \
| (_| | (_| |\ V /  __/ | |_| | |_) |
 \__, |\__,_| \_/ \___|  \__,_| .__/
 |___/                        |_|
;

%utl_gather(sd1.havDat,var,val,,havXpoDat,valformat=3.);
%utl_gather(sd1.havIndex,var,val,,havXpoIdx,valformat=3.);

p to 40 obs WORK.HAVXPOIDX total obs=9

bs    var     val

1     idx1     3
2     idx2     6
3     idx3     9
4     idx1     2
5     idx2     5
6     idx3     8
7     idx1     1
8     idx2     4
9     idx3     7

data havcmb;
  set havXpoDat(in=dat) havXpoIdx end=dne;
  if dat then key=cats('D',put(mod(_n_-1,9),2.));
  else key=cats('I',put(mod(_n_-1,9),2.));
  if dne then call symputx('obs',_n_/2,'G');
  keep key val;
run;quit;

Up to 40 obs WORK.HAVCMB total obs=18

Obs    val    key

  1     3     D0
  2     6     D1
  3     9     D2
  4     2     D3
  5     5     D4
  6     8     D5
  7     1     D6
  8     4     D7
  9     7     D8
 10     3     I0
 11     6     I1


%put &=obs;

proc transpose data=havcmb out=havFat;
id key;
run;quit;


 D0    D1    D2    D3    D4    D5    D6    D7    D8    I0    I1    I2    I3

  3     6     9     2     5     8     1     4     7     3     6     9     2

data want;
   set havFat;
   array ds d:;
   array is i:;
   array os[&obs] o1-o&obs;
   do ij=1 to dim(ds);
     os[ij]=ds[is[ij]];
   end;
   * just one odering - not the general solution;
   call sortn(of os[*]);
   keep o:;
run;quit;

Up to 40 obs WORK.WANT total obs=1

Obs    o1    o2    o3    o4    o5    o6    o7    o8    o9

 1      1     2     3     4     5     6     7     8     9
