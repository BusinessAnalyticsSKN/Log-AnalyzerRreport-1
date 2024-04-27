proc print data=sashelp.class(obs=2);
run;

%macro level4;
proc print data=sashelp.class(obs=2);
run;
%mend;

%macro level3;
proc print data=sashelp.class(obs=2);
run;
%mend;

%macro level2;
proc print data=sashelp.class(obs=2);
var age;
var sex;
var name;
run;

%level3;
%level4;
%mend;

%macro level1;
proc print data=sashelp.class(obs=2);
var age;
var sex;
var name;
run;

%level2;

%mend;

%level1;
