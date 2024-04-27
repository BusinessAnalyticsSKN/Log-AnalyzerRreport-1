/*Log analyzer*/
/*Initial version 2024-01-09 19:00*/
/* (c) Karol Przanowski */
/* kprzan@sgh.waw.pl */

%let dir_log=c:\karol\skn_ba\nowe_SAS_Viya\log_analyzer\PROCSS_SIMULATION\codes\;
%let log=process_runing.log;

/*
*** MPRINT(
*** MLOGIC( and Beginning execution.
*** MLOGIC( and Ending execution.
*** 
*** MLOGIC( and 
*** %DO loop beginning; index variable V; start value is 1; stop value is 6; by value 
***       is 1.  
*** 
*** MLOGIC( and 
*** %DO loop index variable I is now 11; loop will iterate again.
*** 
*** MLOGIC( and %DO loop index variable I is now 13; loop will not iterate again
*** 
*** (Total process time):
*** 
*/


data data_log;
length line$ 32767 code $2000 real_time cpu_time system_time memory os_memory 8 macro_name $100 step $1 loop $1 level 8;
retain macro_name;
retain level 0;
infile "&dir_log.&log" LRECL=32767 
obs=300000
;
input;
line=_infile_;

if index(line,'MPRINT(')>0 or index(line,'MLOGIC(')>0 then
	macro_name=scan(line,2,'()');

if index(line,'MPRINT(')>0 then do; 
	code=substr(line,index(line,':')+1);
	do i=1 to 200 while(index(line,'NOTE:')=0 and index(line,'MLOGIC(')=0 and index(line,'MPRINT(')>0);
		input;
		line=_infile_;
		code=trim(code)||' '||trim(substr(line,index(line,':')+1));
	end;
	output;
end;

if index(line,'NOTE:')>0 and index(line,'(Total process time):')>0 then do;
	code=line;
	input;	line=_infile_; real_time=input(scan(line,3,' '),best12.);
	input;	line=_infile_; cpu_time=input(scan(line,4,' '),best12.);
	input;	line=_infile_; system_time=input(scan(line,4,' '),best12.);
	input;	line=_infile_; memory=input(scan(line,2,' k'),best12.);
	input;	line=_infile_; os_memory=input(scan(line,3,' k'),best12.);
	output;
end;

if index(line,'MLOGIC(')>0 and index(line,'Beginning execution.')>0 then do; step='B'; code=line; level=level+1; output; end;
if index(line,'MLOGIC(')>0 and index(line,'Ending execution.')>0 then do; step='E'; code=line; level=level-1; output; end;
if index(line,'MLOGIC(')>0 and index(line,'%DO loop beginning;')>0 then do; loop='S'; code=line; level=level+1; macro_name=scan(line,3,':;'); output; end;
if index(line,'MLOGIC(')>0 and index(line,'%DO loop index variable')>0 
	and index(line,'loop will iterate')>0 then do; loop='C'; code=line; macro_name=scan(line,2,':;'); output; end;
if index(line,'MLOGIC(')>0 and index(line,'%DO loop index variable')>0 
	and index(line,'loop will not')>0 then do; loop='E'; code=line; level=level-1; output; end;

drop line i;
run;

proc sql noprint;
select max(level) into :max_level from Data_log;
quit;
%let max_level=&max_level;
%put &max_level;

data Data_log2;
length level1-level&max_level $100 codes $32767;
retain codes;
retain level1-level&max_level;
array levels(&max_level)$ level1-level&max_level;
set Data_log;
if _n_=1 then do;
	codes='';
	level1=macro_name;
end;
if level>0 then levels(level)=macro_name;
do i=level+1 to &max_level;
	levels(i)='';
end;
if missing(real_time) and missing(step) and missing(loop) then codes=trim(codes)||' '||trim(code);
if not missing(real_time) then do;
	output;
	codes='';
end;
keep real_time cpu_time system_time memory os_memory
level1-level&max_level codes level
;
run;

ods listing close;
ods html path="&dir_log" body='Log_analyzer_report.html' style=statistical;
title "First 2 levels";
proc tabulate data=Data_log2;
class level1-level2 / missing;
var real_time cpu_time system_time memory os_memory;
table level1=''*level2='' all,
(real_time cpu_time system_time)*sum=''*f=12.2 
(memory os_memory)*max=''*f=12.2 / box='Levels';
run;
title "First 3 levels";
proc tabulate data=Data_log2;
class level1-level3 / missing;
var real_time cpu_time system_time memory os_memory;
table level1=''*level2=''*level3='' all,
(real_time cpu_time system_time)*sum=''*f=12.2 
(memory os_memory)*max=''*f=12.2 / box='Levels';
run;
title "First 4 levels";
proc tabulate data=Data_log2;
class level1-level4 / missing;
var real_time cpu_time system_time memory os_memory;
table level1=''*level2=''*level3=''*level4='' all,
(real_time cpu_time system_time)*sum=''*f=12.2 
(memory os_memory)*max=''*f=12.2 / box='Levels';
run;
title 'Levels with codes';
proc tabulate data=Data_log2;
class level1-level3 codes / missing;
var real_time cpu_time system_time memory os_memory;
table 
level1=''*level2=''*level3=''*codes='' all,
(real_time cpu_time system_time)*sum=''*f=12.2 
(memory os_memory)*max=''*f=12.1 / box='Levels';
run;
ods html close;
ods listing;


