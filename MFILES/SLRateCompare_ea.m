function [fslopeavg,sdslopeavg,fslopeavgdiff,sdslopeavgdiff,diffplus,diffless,fmean,fsds,fGIAmean]=SLRateCompare_ea(wf,wV,testsites,testreg,testts,GIA,firstyears,lastyears,wsdFs)

% Last updated by Robert Kopp, robert-dot-kopp-at-rutgers-dot-edu, Wed Nov 05 22:41:45 EST 2014

defval('firstyears',[0 1000]);
defval('lastyears',[1800 1800]);
dodiff=((nargout>2)*(length(firstyears)>1));

for kk=1:size(testsites,1)
    
    sub=find((testreg==testsites(kk,1)));
    M=zeros(length(firstyears),length(sub));
    L=zeros(length(firstyears),length(sub));
    for pp=1:length(firstyears)

        sub1=find((testts(sub)==firstyears(pp)));
        sub2=find((testts(sub)==lastyears(pp)));
        if (length(sub1)==1)&&(length(sub2)==1)
            M(pp,sub1(1))=-1; M(pp,sub2(1))=1;
            M(pp,:)=M(pp,:)/(lastyears(pp)-firstyears(pp));
            L(pp,sub1(1))=1; L(pp,sub2(1))=1;
            L(pp,:)=L(pp,:)/2;
        end
    end

    fslope=M*wf(sub,1);
    favg=L*wf(sub,1);
    fGIA=L*GIA(sub,1);
    fsd=L*wsdFs(sub,1);
    Vslope=M*wV(sub,sub,1)*M';
    sdslope=sqrt(diag(Vslope));
    notgood=find(sum(abs(M),2)==0);
    modifier=0*sdslope; modifier(notgood)=1e6;
    sdslope=sdslope+modifier; Vslope=Vslope+diag(modifier.^2);
    
    if dodiff
        counter=1;
        for pp=1:length(firstyears)
            for qq=(pp+1):length(firstyears)
                Mdiff(counter,pp)=-1;
                Mdiff(counter,qq)=1;
                diffplus(counter)=qq; diffless(counter)=pp;
                counter=counter+1;
            end
        end
        fslopediff = Mdiff*fslope;
        Vslopediff = Mdiff*Vslope*Mdiff';
        sdslopediff = sqrt(diag(Vslopediff));

        fslopediff(find(sdslopediff>1e4))=NaN;
        sdslopediff(find(sdslopediff>1e4))=NaN;
        
        fslopeavgdiff(kk,:) = fslopediff(:)';
        sdslopeavgdiff(kk,:)= sdslopediff(:)';
    end
    
    fslope(find(sdslope>1e4))=NaN;
    sdslope(find(sdslope>1e4))=NaN;
    
    fslopeavg(kk,:) = fslope(:)';
    sdslopeavg(kk,:) = sdslope(:)';
    fmean(kk,:)=favg(:)';
    fsds(kk,:)=fsd(:)';
    fGIAmean(kk,:)=fGIA(:)';
end

fslope(find(sdslope>1e4))=NaN;
sdslope(find(sdslope>1e4))=NaN;

if dodiff
    fslopediff(find(sdslopediff>1e4))=NaN;
    sdslopediff(find(sdslopediff>1e4))=NaN;
else
    fslopeavgdiff=[];
    sdslopeavgdiff=[];
    diffplus=[];
    diffless=[];
end