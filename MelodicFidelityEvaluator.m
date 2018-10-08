%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS PROGRAM WAS CREATED BY ANTHONY ANDROULAKIS ON AUGUST 14, 2017.
% aandroulakis@zoho.com
% Unauthorized Use of this Program is Prohibited.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MusicFidelityEvaluator

% This computer program compares two matrices, each of which have two rows.
% The first row %displays the frequencies of notes in Hz.
% The second row %displays the durations of the corresponding notes in seconds.
% The inputs are: OHz for Original melody and PHz for Patient repeat. 
% The outputs are the time error and the note interval error.




    
%%disp('                Music Fidelity Evaluator')
%%disp('--------------created by Anthony Androulakis-----------------')    

for i=1:size(OHz,2)   % OHz is the matrix that you insert that contains frequencies in
                      % hertz in the first row and corresponding time durations in seconds in the
                      % second row for the original tune. 
    O(1,i)=floor((24*(log(OHz(1,i)/440)/log(2))+1)/2); % O contains integer value semitones (A4=0) in the first row.
    O(2,i)=OHz(2,i);                                   % O contains time durations in seconds in the seconds row.
end
  

for i=1:size(PHz,2)   % PHz is the matrix that you insert that contains frequencies in
                      % hertz in the first row and corresponding time durations in seconds in the
                      % second row for the patient tune.
    P(1,i)=floor((24*(log(PHz(1,i)/440)/log(2))+1)/2); % P contains integer value semitones (A4=0) in the first row.
    P(2,i)=PHz(2,i);                                   % P contains time durations in seconds in the seconds row.
end


%%disp('The Original Melody Matrix (in semitones (A4=0) and seconds) is:')
%%disp(O)
%%disp('The Patient Repeated Melody Matrix (in semitones (A4=0) and seconds) is:')
%%disp(P)


%----------------------------------------------------------------------------------------------------------------------%
%-----------------------------------------------------CASE 1-----------------------------------------------------------%
%----------------------------------------------------------------------------------------------------------------------%

if size(P,2)==size(O,2)
%%disp('-----')      
%%disp('The patient reproduced matrix P has the same number of notes as the original matrix O.')
disp(['notes added (positive) or deleted (negative): ' num2str(size(P,2)-size(O,2)) ''])
NotesAddedOrDeleted=size(P,2)-size(O,2);
%%disp('-----')             
%%disp('In order to evaluate the time error of the patient fairly,')
%%disp('this program rescales all the times that the original matrix has by the same factor.')
%%disp('This factor minimizes the time error between the the patient matrix')
%%disp('and the original matrix.')
              
             numerator=0;
            for i=1:size(P,2)
                numerator=numerator+P(2,i)*O(2,i);
            end
            
            denominator=0;
            for i=1:size(P,2)
                denominator=denominator+P(2,i)^2;
            end
            
            x=numerator/denominator;
            
%%disp('The factor to scale the P is:')
%%disp(x)

            SCALEDP(1,:)=P(1,:); % SCALEDP is the scaled matrix P where we scale the second row of P to 
                                 % minimize the time error between P and the scaled P.
            SCALEDP(2,:)=P(2,:)*x;
%%disp('The patient matrix P scaled by the above factor is:')
%%disp(SCALEDP)
            
            TE=0; % TE = time error
                for i=1:size(P,2)
                    TE=TE+(O(2,i)-SCALEDP(2,i))^2;               
                end
                TTE=sqrt(TE);
               
%%disp('The time error (Eucledean distance) between the original matrix and the')
%%disp('time scaled patient matrix is:')
%fprintf('%d seconds', TTE) 
%%disp('                        ')

            JE=0;
                for i=1:size(P,2)-1
                    JE=JE+((O(1,i+1)-O(1,i))-(P(1,i+1)-P(1,i)))^2;
                end
                
             TJE=sqrt(JE);
             
%%disp('The note interval error (Euclidean distance) between the original matrix and')
%%disp('the time scaled patient matrix is')
%fprintf('%d semitones', TJE)
%%disp('                        ')

BR=[TTE, TJE];

    disp('The results are:')
    disp('Time error (sec)    Note Interval error (semitones)')
    disp(BR) 
end
%----------------------------------------------------------------------------------------------------------------------%
%-----------------------------------------------------CASE 2-----------------------------------------------------------%
%----------------------------------------------------------------------------------------------------------------------%

if size(P,2)>size(O,2)
%%disp('-----')
%%disp(['The patient reproduced matrix ,P, has ' num2str(size(P,2)-size(O,2)) ' more note(s) than the original matrix O.'])
disp(['notes added (positive) or deleted (negative): ' num2str(size(P,2)-size(O,2)) ''])
NotesAddedOrDeleted=size(P,2)-size(O,2);
%%disp('-----')
%%disp('Why did the patient add the extra notes?')
%%disp('Unfortunately, no one really knows this except the patient.')
%%disp('Which notes that the patient said were intended to be a reproduction of the original?')
%%disp('The note intervals are a better indicator than the length of the notes for guessing the answer.')
%%disp('Therefore, this program examines all subsets of the patient matrix P that have the same number of')
%%disp('notes as the number of notes of the original matrix O.')
  
%%disp('For each such subset, the program computes the Euclidean distance of its note intervals')
%%disp('from those note intervals of the original matrix O.')

    C=nchoosek(1:size(P,2),size(O,2));

    for k=1:size(C,1)

        Sk=P(:,C(k,:));

        
        if size(Sk,2)==1
            SQJE = 0; % we compute the square of the jump error SQJE between Sk and P for every row of C
        else
    
            SQJE = 0;
            for L = 1:(size(Sk,2)-1)
                SQJE = SQJE+((O(1,L+1)-O(1,L))-(Sk(1,L+1)-Sk(1,L)))^2;
            end
        end

        JEMATRIX(k,1)=SQJE; % In the JEMATRIX we keep track of the squares of the jump errors.
    end
    
    
    MINJE=min(JEMATRIX); % MINJE = minimum of matrix JEMATRIX
    
    
%%disp('The program takes the subset with the smallest note interval error.')
%%disp('If there are more than one subsets of P with the smallest note interval')
%%disp('difference from the original, then the program %displays all of the subsets.')
    
    r=1;
    for k=1:size(C,1)
        if JEMATRIX(k,1)==MINJE
            
            Sk=P(:,C(k,:));
            
%%disp('A subset of P with the minimum note interval distance from O is:')
%%disp(Sk)
              
%%disp('In order to evaluate the time error of the patient fairly,')
%%disp('this program rescales all the times that the original matrix has by the same factor.')
%%disp('This factor minimizes the time error between the selection above')
%%disp('and the original matrix.')
              
            numerator=0;
            for i=1:size(O,2)
                numerator=numerator+Sk(2,i)*O(2,i);
            end
            
            denominator=0;
            for i=1:size(O,2)
                denominator=denominator+Sk(2,i)^2;
            end
            
            x=numerator/denominator;
            
%%disp('The factor to scale the O is:')
%%disp(x)
            
            SCALEDO(1,:)=O(1,:); % SCALEDO is the scaled matrix O where we scale the second row of O to 
                                 % minimize the time error between Sk and the scaled O.
            SCALEDO(2,:)=O(2,:)*x;
%%disp('The original matrix O scaled by the above factor is:')
%%disp(SCALEDO)
            
                
            % Imagine that the Scaled Original matrix SCALEDO is enlarged by
            % adding auxiliary columns whereever the corresponding column
            % of P is missing (because it is not included in the selection
            % Sk). The bottom entry of this auxilliary column must be 0
            % since it corresponds to time. The top value of this
            % auxilliary column will currently be ignored in order to make
            % all possible error counts fair.
            TE=0; % TE = time error
                for i=1:size(P,2)
                    if 1==ismember(i,C(k,:))
                        TE=TE+(P(2,i)-SCALEDO(2,find(C(k,:)==i)))^2;
                    else TE=TE+P(2,i)^2;
                    end
                end
                TTE=sqrt(TE);
               
%%disp('The time error (Eucledean distance) between the selection above and the')
%%disp('time scaled original matrix is:')
%fprintf('%d seconds', TTE)
%%disp('                        ')

            JE=MINJE;
                for i=1:size(P,2)-1
                    if 2 ~= ismember(i,C(k,:)) + ismember(i+1,C(k,:))
                        JE=JE+(P(1,i+1)-P(1,i))^2;
                    end
                end
                
             TJE=sqrt(JE);
             
%%disp('The note interval error (Euclidean distance) between the selection above and')
%%disp('the time scaled original matrix is')
%fprintf('%d semitones', TJE)
%%disp('                        ')
             
                R(r,1)=TTE; % The matrix R contains the results, the total time error
                            % and the total jump error, for every row of C
                            % that the jump error becomes MINJE.
                R(r,2)=TJE;
                
                r=r+1;
    
        end
    end
    
    if size(R,1)==1
        BR=R;
        %disp('The results are:')
        %disp('Time error (sec)    Note Interval error (semitones) ')
        %disp(BR)
    else BR=min(R); % BR = Best Results
        
        %%disp('Several subsets of P give the same minimum note interval error for the patient.')
        %%disp('One of these subsets gives the smallest time error of the patient.')
    
        disp('The results are:')
        disp('Time error (sec)    Note Interval error (semitones)')
        disp(BR)
        
    end
end  
%----------------------------------------------------------------------------------------------------------------------%
%-----------------------------------------------------CASE 3-----------------------------------------------------------%
%----------------------------------------------------------------------------------------------------------------------%
if size(P,2)<size(O,2)
%%disp('-----')
%%disp(['The original matrix , O, has ' num2str(size(O,2)-size(P,2)) ' more notes than the patient reproduced matrix P.'])
disp(['notes added (positive) or deleted (negative): ' num2str(size(P,2)-size(O,2)) ''])
NotesAddedOrDeleted=size(P,2)-size(O,2);
%%disp('-----')    
%%disp('Which notes of the original melody did the patient try to reproduce?')
%%disp('Unfortunately, no one really knows this except the patient.')
%%disp('The note intervals are a better indicator than the length of the notes for guessing which notes')
%%disp('the patient tried to reproduce.')
%%disp('Therefore, this program examines all subsets of the original matrix O that have the same number of')
%%disp('notes as the number of notes the patient reproduced.')
  
%%disp('For each such subset, the program computes the Euclidean distance of its note intervals')
%%disp('from the note intervals that the patient used.')

    C=nchoosek(1:size(O,2),size(P,2));

    for k=1:size(C,1)

        Sk=O(:,C(k,:));

        
        if size(Sk,2)==1
            SQJE = 0; % we compute the square of the jump error SQJE between Sk and P for every row of C
        else
    
            SQJE = 0;
            for L = 1:(size(Sk,2)-1)
                SQJE = SQJE+((P(1,L+1)-P(1,L))-(Sk(1,L+1)-Sk(1,L)))^2;
            end
        end

        JEMATRIX(k,1)=SQJE; % In the JEMATRIX we keep track of the squares of the jump errors.
    end
    
    
    MINJE=min(JEMATRIX); % MINJE = minimum of matrix JEMATRIX
    
    
%%disp('The program takes the subset with the smallest note interval error.')
%%disp('If there are more than one subsets of O with the smallest note interval')
%%disp('difference from the patient, then the program %displays all of the subsets.')
    
    r=1;
    for k=1:size(C,1)
        if JEMATRIX(k,1)==MINJE
            
            Sk=O(:,C(k,:));
            
%%disp('A subset of O with the minimum note interval distance from P is:')
%%disp(Sk)
              
%%disp('In order to evaluate the time error of the patient fairly,')
%%disp('we rescale all the times that the patient uses by the same factor.')
%%disp('This factor minimizes the time error between the selection above')
%%disp('and the matrix of the patient.')
              
            numerator=0;
            for i=1:size(P,2)
                numerator=numerator+Sk(2,i)*P(2,i);
            end
            
            denominator=0;
            for i=1:size(P,2)
                denominator=denominator+Sk(2,i)^2;
            end
            
            x=numerator/denominator;
            
%%disp('The factor to scale the P is:')
%%disp(x)
            
            SCALEDP(1,:)=P(1,:); % SCALEDP is the scaled matrix P where we scale the second row of P to 
                                 % minimize the time error between Sk and the scaled P.
            SCALEDP(2,:)=P(2,:)*x;
%%disp('The matrix of the patient P scaled by the above factor is:')
%%disp(SCALEDP)
            
                
            % Imagine that the Scaled Patient matrix SCALEDP is enlarged by
            % adding auxiliary columns whereever the corresponding column
            % of O is missing (because it is not included in the selection
            % Sk). The bottom entry of this auxilliary column must be 0
            % since it corresponds to time. The top value of this
            % auxilliary column will currently be ignored in order to make
            % all possible error counts fair.
            TE=0; % TE = time error
                for i=1:size(O,2)
                    if 1==ismember(i,C(k,:))
                        TE=TE+(O(2,i)-SCALEDP(2,find(C(k,:)==i)))^2;
                    else TE=TE+O(2,i)^2;
                    end
                end
                TTE=sqrt(TE);
               
%%disp('The time error (Eucledean distance) between the selection above and the')
%%disp('time scaled matrix of the patient is:')
%fprintf('%d seconds', TTE)
%%disp('                        ')

            JE=MINJE;
                for i=1:size(O,2)-1
                    if 2 ~= ismember(i,C(k,:)) + ismember(i+1,C(k,:))
                        JE=JE+(O(1,i+1)-O(1,i))^2;
                    end
                end
                
             TJE=sqrt(JE);
             
%%disp('The note interval error (Euclidean distance) between the selection above and')
%%disp('the time scaled matrix of the patient is')
%fprintf('%d semitones', TJE)
%%disp('                        ')
             
                R(r,1)=TTE; % The matrix R contains the results, the total time error
                            % and the total jump error, for every row of C
                            % that the jump error becomes MINJE.
                R(r,2)=TJE;
                
                r=r+1;
    
        end
    end
    
    if size(R,1)==1
        BR=R;
        %disp('The results are:')
        %disp('Time error (sec)    Note Interval error (semitones)')
        %disp(BR)
    else BR=min(R); % BR = Best Results
        
        %%disp('Several subsets of O give the same minimum note interval error for the patient.')
        %%disp('One of these subsets gives the smallest time error of the patient.')
    
        disp('The results are:')
        disp('Time error (sec)    Note Interval error (semitones)')
        disp(BR)
    end
end
