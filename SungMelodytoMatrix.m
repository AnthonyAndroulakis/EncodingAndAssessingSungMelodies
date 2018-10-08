% ProDAS = Program for the Detection of Aphasic Singing
% note that this program works best when the input audio files have no
% background noise, but this program still works very well even with
% background noise (just make sure the Aphasic voice is louder than the
% background noise

[y,Fs] = audioread(filename);
song=y(:,1);
% convert amplitude to decibels
clear y
newsong=mag2db(song); 
% remove any NaN & -Inf values and make the y axis have positive values
newsong(newsong==-Inf)=NaN;
minimumOfnewsong=min(newsong);
newsong(isnan(newsong))=minimumOfnewsong;
newsong=newsong-minimumOfnewsong;

saveas(plot(1:length(newsong),newsong,'LineWidth',1),'MelodyTask.png')
saveas(plot(1:length(newsong),newsong,'w'),'MelodyTaskaxes.png')
I=imread('MelodyTask.png');
Iaxes=imread('MelodyTaskaxes.png');
JustPlot=Iaxes-I;
W = rgb2gray(JustPlot);

blurredImage = imfilter(W,fspecial('motion',30,-45));
BW = imbinarize(blurredImage);
blurredImage2=conv2(BW,ones(50)/(50*50),'same');
newImage=blurredImage2>0.5;

[C,h] = imcontour(newImage,1);
scaledX = C(1,2:C(2,1));
scaledY = C(2,2:C(2,1));
newscaledY=-scaledY-min(-scaledY);

newnewscaledX=scaledX(find(newscaledY>30));
newnewscaledY=newscaledY(find(newscaledY>30));
movednewnewscaledX=newnewscaledX-min(newnewscaledX);
[sortednewnewscaledX,idx] = sort(movednewnewscaledX);
sortednewnewscaledY=newnewscaledY(idx);


hsong=reshape(song,[],1)';
hsongsound=strfind(num2str(hsong==0,'%d'),'00');
RemovedSilenceSong=song(hsongsound(1):(hsongsound(end)+1));
scalingX=length(RemovedSilenceSong)/(max(sortednewnewscaledX)-min(sortednewnewscaledX));
newsong=mag2db(RemovedSilenceSong);
newsong(newsong==-Inf)=NaN;
minimumOfnewsong=min(newsong);
newsong(isnan(newsong))=minimumOfnewsong;
newsong=newsong-min(minimumOfnewsong);
scalingY=((max(newsong)-min(newsong))/(max(sortednewnewscaledY)-min(sortednewnewscaledY)+30));

testsortednewnewscaledX=sortednewnewscaledX*scalingX;
testsortednewnewscaledY=sortednewnewscaledY*scalingY;
correcttestsortednewnewscaledX=testsortednewnewscaledX(find(testsortednewnewscaledX~=0));
correcttestsortednewnewscaledY=testsortednewnewscaledY(find(testsortednewnewscaledX~=0));

[uniquex, ia, ~] = unique(correcttestsortednewnewscaledX);

for n=1:length(ia)-1
LocationsofMaximums=find(correcttestsortednewnewscaledY==max(correcttestsortednewnewscaledY(ia(n):ia(n+1)-1)));
x(1,n)=correcttestsortednewnewscaledX(LocationsofMaximums(find(LocationsofMaximums >= ia(n) & LocationsofMaximums <= (ia(n+1)-1))));
y(1,n)=correcttestsortednewnewscaledY(LocationsofMaximums(find(LocationsofMaximums >= ia(n) & LocationsofMaximums <= (ia(n+1)-1))));
clear LocationsofMaximums
end
clear n

[TF,~]=islocalmin(y,'MinSeparation',50,'MinProminence',1); % the 50 stands for 50 frames, which is 0.0011 seconds  % this one works!

results=x(TF);
close

TimeMatrix=[1 round(results) length(song)];
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