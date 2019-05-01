%% Read data Experiment 1
MultiSubDir='Experiment1Data';
[Files] =  findfiles('.csv',MultiSubDir);
NumSubjects = numel(Files);

for SubNum = 1:NumSubjects
    [Conf(:,SubNum) RT(:,SubNum) Side(:,SubNum) Reward(:,SubNum) Pl(:,SubNum) Pr(:,SubNum) Vl(:,SubNum) Vr(:,SubNum) Pos(:,SubNum) Time(:,SubNum)]=csvimport( Files{SubNum}, 'columns', [1,2, 3, 4,5,6,7,8,9,10],'noHeader', true);
    
    
    AbsConf(:,SubNum) = abs(Conf(:,SubNum));
    Choices(:,SubNum) = sign(Conf(:,SubNum));
    
    
    NumTrials = length(AbsConf(:,SubNum));
    
    Stability(1,SubNum) =Choices(1,SubNum);
    Stability(2,SubNum) =sum(Choices(1:2,SubNum));
    Stability(3,SubNum) = sum(Choices(1:3,SubNum));
    Stability(4,SubNum) = sum(Choices(1:4,SubNum));
    Stability(5,SubNum) = sum(Choices(1:5,SubNum));
    
    for i = 6:NumTrials
        Stability(i,SubNum) = sum(Choices(i-4:i,SubNum));
    end;
end;


