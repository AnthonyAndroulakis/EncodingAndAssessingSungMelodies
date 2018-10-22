%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS MATLAB PROGRAM WAS MADE PUBLICLY AVAILABLE BY ANTHONY ANDROULAKIS ON OCTOBER 7, 2018.
% aandroulakis@zoho.com
% BSD 3-Clause License
% Copyright (c) 2018, Anthony Androulakis
% All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SungMelodyToMatrix

[y,Fs] = audioread(filename);
song=y(:,1);
clear y

decibelsSong=mag2db(song); 
decibelsSong(decibelsSong==-Inf)=NaN;
decibelsSong(isnan(decibelsSong))=min(decibelsSong);
decibelsSong=decibelsSong-min(decibelsSong);

saveas(plot(1:length(decibelsSong),decibelsSong,'LineWidth',1),'MelodyTask.png')
saveas(plot(1:length(decibelsSong),decibelsSong,'w'),'MelodyTaskaxes.png')
imageDecibelsGraph=imread('MelodyTask.png');
imageAxes=imread('MelodyTaskaxes.png');
decibelsGraphNoAxis=imageAxes-imageDecibelsGraph;

grayImage = rgb2gray(decibelsGraphNoAxis);
motionBlurDecibels = imfilter(grayImage,fspecial('motion',30,-45));
binarizedMotionBlur = imbinarize(motionBlurDecibels);
fullyBlurred=conv2(binarizedMotionBlur,ones(50)/(50*50),'same');
newImage=fullyBlurred>0.5;
[contourData,~] = imcontour(newImage,1);
close

xContourCoord = contourData(1,2:contourData(2,1));
yContourCoord = contourData(2,2:contourData(2,1));
shiftedY=-yContourCoord-min(-yContourCoord);
findX=xContourCoord(find(shiftedY>30));
findY=shiftedY(find(shiftedY>30));
shiftedX=findX-min(findX);
[sortedX,sortingIndex] = sort(shiftedX);
sortedY=findY(sortingIndex);
hSong=reshape(song,[],1)';
silence=strfind(num2str(hSong==0,'%d'),'00');
removedSilenceSong=song(silence(1):(silence(end)+1));
scaleOfX=length(removedSilenceSong)/(max(sortedX)-min(sortedX));
decibelsSong=mag2db(removedSilenceSong);
decibelsSong(decibelsSong==-Inf)=NaN;
decibelsSong(isnan(decibelsSong))=min(decibelsSong);
decibelsSong=decibelsSong-min(decibelsSong);
scaleOfY=((max(decibelsSong)-min(decibelsSong))/(max(sortedY)-min(sortedY)+30));
scaledX=sortedX*scaleOfX;
scaledY=sortedY*scaleOfY;
nonRedundantX=scaledX(find(scaledX~=0));
nonRedundantY=scaledY(find(scaledX~=0));
[~,xIndex,~] = unique(nonRedundantX);
for n=1:length(xIndex)-1
loc=find(nonRedundantY==max(nonRedundantY(xIndex(n):xIndex(n+1)-1)));
x(1,n)=nonRedundantX(loc(find(loc >= xIndex(n) & loc <= (xIndex(n+1)-1))));
y(1,n)=nonRedundantY(loc(find(loc >= xIndex(n) & loc <= (xIndex(n+1)-1))));
clear LocationsofMaximums
end
clear n

[noteChangeBoolean,~]=islocalmin(y,'MinSeparation',50,'MinProminence',1);
frameWhenNoteChanges=x(noteChangeBoolean);

TimeMatrix=[1 round(frameWhenNoteChanges) length(song)];
for n=1:length(TimeMatrix)-1
    [f0,~] = pitch(song(TimeMatrix(n):TimeMatrix(n+1)),Fs, ...
    'Method','PEF', ...
    'Range',[50 800], ...
    'WindowLength',round(Fs*0.08), ...
    'OverlapLength',round(Fs*0.05));
    FrequencyMatrix(1,n)=median(f0);
    clear f0
end
clear n
PHz(1,:)=FrequencyMatrix;
PHz(2,:)=diff(TimeMatrix)/Fs;

