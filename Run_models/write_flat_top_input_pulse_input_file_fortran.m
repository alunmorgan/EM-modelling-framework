function write_flat_top_input_pulse_input_file_fortran(risetime, decaytime, holdtime, amplitude, outputfilename)

fs = {''};
fs = cat(1,fs,' PROGRAM SignalCommand');
fs = cat(1,fs,' IMPLICIT NONE');
fs = cat(1,fs,'');
fs = cat(1,fs,' DOUBLE PRECISION :: TRise, TDecay, THold');
fs = cat(1,fs,' DOUBLE PRECISION :: TimeStep, Beta, Alpha, DeltaZ');
fs = cat(1,fs,' DOUBLE PRECISION :: Pi, ActualTime, Phi, Factor');
fs = cat(1,fs,' INTEGER :: iTime, iTime1, iTime2');
fs = cat(1,fs,'');
fs = cat(1,fs,'    Pi= 4*ATAN(1d0)');
fs = cat(1,fs,'');
fs = cat(1,fs,['    TRise = ', num2str(risetime)]);
fs = cat(1,fs,['    TDecay= ', num2str(decaytime)]);
fs = cat(1,fs,['    THold = ', num2str(holdtime)]);
fs = cat(1,fs,'');
fs = cat(1,fs,'    READ (*,*) iTime1, iTime2, TimeStep');
fs = cat(1,fs,'    READ (*,*) Beta, Alpha, DeltaZ');
fs = cat(1,fs,'');
fs = cat(1,fs,'    DO iTime= iTime1, iTime2');
fs = cat(1,fs,'       ActualTime= iTime*TimeStep');
fs = cat(1,fs,'       IF (ActualTime <= TRise) THEN');
fs = cat(1,fs,'          Phi= ActualTime * Pi / TRise');
fs = cat(1,fs,'          Factor= (1-COS(Phi))/2');
fs = cat(1,fs,'       ELSE IF (ActualTime <= TRise+THold) THEN');
fs = cat(1,fs,'          Factor= 1');
fs = cat(1,fs,'       ELSE IF (ActualTime <= TRise+THold+TDecay) THEN');
fs = cat(1,fs,'          Phi= (ActualTime - (TRise+THold)) * Pi / TDecay');
fs = cat(1,fs,'          Factor= (1+COS(Phi))/2');
fs = cat(1,fs,'       ELSE');
fs = cat(1,fs,'          Factor= 0');
fs = cat(1,fs,'       ENDIF');
fs = cat(1,fs,'!!       Factor= Factor * TimeStep / DeltaZ');
fs = cat(1,fs,'       WRITE (*,*) Factor');
fs = cat(1,fs,'    END DO');
fs = cat(1,fs,'');
fs = cat(1,fs,' END PROGRAM SignalCommand');

write_out_data(fs, 'signal-command.f90')
system( ['gfortran signal-command.f90 -o ./',outputfilename] )
system(['chmod +x ',outputfilename])