function ThisData = GetData25(Data)

I = find(Data==1);
if ~isempty(I)
    
    ThisData=I(1:25);
    
else
    ThisData = NaN*ones(1,25);
    
end;
end