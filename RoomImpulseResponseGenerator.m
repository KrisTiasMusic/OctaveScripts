##Copyright (C) <2022> <KRIS TIAS>
##
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation, either version 3 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program.  If not, see <https://www.gnu.org/licenses/>.

pkg load signal;

clc;
close all;
clear;

t = 1;
fs = 48000;
sampleTime = 1 / (fs);
decayConstant = 15;
channels = 2;

thresholdPos = 0.60;
thresholdNeg = -thresholdPos;
thresholdReduction = t*4*sampleTime;

y = randn(t*fs, 1);
impulseResponse = zeros(length(y), channels);

yAbs = abs(y);
maxInY = max(yAbs);

y = y / maxInY;


for (idx = 1:length(yAbs))
  naturalDecayFactor = exp( -(sampleTime) / (t/(idx * decayConstant)));
  
  if ( y(idx, 1) > thresholdPos)
    impulseResponse(idx, 1) = y(idx, 1);
    thresholdPos = thresholdPos - thresholdReduction;
    if (thresholdPos < 0)
      thresholdPos = 0;      
    endif
  endif
  
  if ( y(idx, 1) < thresholdNeg)
    impulseResponse(idx, 2) = y(idx, 1);
    thresholdNeg = thresholdNeg + thresholdReduction;
    if (thresholdNeg > 0)
      thresholdNeg = 0;      
    endif
  endif
  
  impulseResponse(idx, 1) = impulseResponse(idx, 1) * naturalDecayFactor;
  impulseResponse(idx, 2) = abs(impulseResponse(idx, 2)) * naturalDecayFactor;
endfor

fadeOut = linspace(1, 0, t*fs);
impulseResponse(:,1) = impulseResponse(:,1) .* fadeOut';
impulseResponse(:,2) = impulseResponse(:,2) .* fadeOut';

figure

plot(impulseResponse(1:20000, :));
h = get(gcf, "currentaxes");
set (h, "fontsize", 22);
xlabel("Samples")
ylabel("Amplitude")
h = legend('Left', 'Right')
set (h, "fontsize", 22);


mkdir(["impulse_response_" num2str(t) "s"]);

dateAndTime = strftime ("%Y%m%d_%H%M%S", localtime (time ()));

audiowrite( [pwd "\\impulse_response_" num2str(t) "s\\" dateAndTime "_impulse_response_" num2str(t) "s.wav"], impulseResponse, fs);
'done.'
