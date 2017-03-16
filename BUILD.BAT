::usage notation: https://en.wikipedia.org/wiki/Usage_message
::Basic Compiler (bc.exe) command-line options: https://support.microsoft.com/en-us/kb/43090

QB_HOME=c:\qb4.5

%QB_HOME%\qb /l %QB_HOME%\qb.qlb /run modules\test\utilityt.bas

del qcumber.lib

:: creates object file(s)
::    source-filename [object-filename] [;]
::    use of semi-colon (;) uses passed args and end prompting of any further optional args
%QB_HOME%\bc qcumber.bas qcumber.obj;
%QB_HOME%\bc modules\arrange.bas;
%QB_HOME%\bc modules\graphic.bas;
:: 'user' causes errors
%QB_HOME%\bc modules\u$er.bas;
%QB_HOME%\bc modules\utility.bas;

:: creates LIB for compiling dependent programs
%QB_HOME%\lib qcumber.lib + qcumber.obj + arrange.obj + graphic.obj + u$er.obj + utility.obj;

:: creates QLB for running dependent programs in IDE
%QB_HOME%\link /Q qcumber.lib, qcumber.qlb,, %QB_HOME%\bqlb45.lib + %QB_HOME%\brun45.lib + %QB_HOME%\qb.lib

%QB_HOME%\qb /run bin\genfat