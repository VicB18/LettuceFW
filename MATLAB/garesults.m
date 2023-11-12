function garesults(gaDat)
% Optional user task executed when the algorithm ends

% For instance, final result
disp('------------------------------------------------')
disp('######   RESULT   #########')
disp(['   Objective function for xmin: ' num2str(gaDat.fxmin,5)])
disp(['   xmin: ' mat2str(gaDat.xmin,3)])
disp('------------------------------------------------')