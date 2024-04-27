/*Log analyzer*/
/* (c) Karol Przanowski */
/* kprzan@sgh.waw.pl */
%let dir_hat=c:\karol\skn_ba\nowe_SAS_Viya\log_analyzer\PROCSS_SIMULATION\codes\;
options mprint details msglevel=i mlogic nosymbolgen FULLSTIMER ;

%macro run_log_analyzer;
%include "&dir_hat.example1.sas" / source2;
%mend;
%run_log_analyzer;

