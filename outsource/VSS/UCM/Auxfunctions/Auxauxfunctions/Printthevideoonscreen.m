function thevideo=Printthevideoonscreen(thevideo, printonscreen, nofigure, toscramble, showcolorbar, writethevideo,treatoutliers,outputfile,printthetext)
% thevideo=labelledvideo;
% thevideo(100:150,100:150,10)=-10;
% Printthevideoonscreen(thevideo, true, 6, true, [], [], true)
% Related functions: Writepictureseries, Readpictureseries

if ( (~exist('printthetext','var')) || (isempty(printthetext)) )
    printthetext=true;
end
if ( (~exist('outputfile','var')) || (isempty(outputfile)) )
    outputfile='Therequestedvideo.avi';
end
if ( (~exist('treatoutliers','var')) || (isempty(treatoutliers)) )
    treatoutliers=false;
end
if ( (~exist('writethevideo','var')) || (isempty(writethevideo)) )
    writethevideo=false;
end
if ( (~exist('showcolorbar','var')) || (isempty(showcolorbar)) )
    showcolorbar=false;
end
if ( (~exist('toscramble','var')) || (isempty(toscramble)) )
    toscramble=false;
end
if ( (~exist('printonscreen','var')) || (isempty(printonscreen)) )
    printonscreen=false;
end
if ( (~exist('nofigure','var')) || (isempty(nofigure)) )
    nofigure=1;
end



if (treatoutliers) %check necessity of treatoutliers
    %outliervalue <0
    outlierspresent=false;
    if (iscell(thevideo))
        noFrames=numel(thevideo);
        for f=1:noFrames
            if (any(thevideo{f}(:)<0))
                outlierspresent=true;
            end
        end
    else
        outlierspresent=any(thevideo(:)<0);
    end
    treatoutliers = ( treatoutliers & outlierspresent );
end



if (iscell(thevideo))
    noFrames=numel(thevideo);
    themax=-Inf;
    themin=Inf;
    for f=1:noFrames
        if (isempty(thevideo{f}))
            continue;
        end
        if (treatoutliers)
            themax=max(themax,max(  double( thevideo{f}(thevideo{f}>0) )  ));
            themin=min(themin,min(  double( thevideo{f}(thevideo{f}>0) )  ));
        else
            themax=max(themax,max(  double( thevideo{f}(:) )  ));
            themin=min(themin,min(  double( thevideo{f}(:) )  ));
        end
    end
else
    noFrames=size(thevideo,3);
    if (treatoutliers)
        themin=min(thevideo(thevideo>0));
        themax=max(thevideo(thevideo>0));
    else
        themin=min(thevideo(:));
        themax=max(thevideo(:));
    end
end



if (toscramble)
    themin=round(themin);
    themax=round(themax);
    if (iscell(thevideo))
        for f=1:noFrames
            thevideo{f}(:)=round(thevideo{f}(:));
        end
        if (themin<1)
            for f=1:noFrames
                thevideo{f}(:)=thevideo{f}(:)+(1-themin);
            end
            themax=themax+(1-themin);
            themin=1;
        end
        permvalues=randperm(themax);
        for f=1:noFrames
            if (treatoutliers)
                thevideo{f}(thevideo{f}>0)=permvalues(thevideo{f}(thevideo{f}>0));
            else
                thevideo{f}(:)=permvalues(thevideo{f}(:));
            end
        end
    else
        thevideo(:)=round(thevideo(:));
        if (themin<1)
            thevideo(:)=thevideo(:)+(1-themin);
            themax=themax+(1-themin);
            themin=1;
        end
        permvalues=randperm(themax);
        if (treatoutliers)
            thevideo(thevideo>0)=permvalues(thevideo(thevideo>0));
        else
            thevideo(:)=permvalues(thevideo(:));
        end
    end
end



if (treatoutliers)
    themin=themin-1;
    if (iscell(thevideo))
        for f=1:noFrames
            thevideo{f}(thevideo{f}<0)=themin;
        end
    else
        thevideo(thevideo<0)=themin;
    end
end



if (printonscreen)
    Init_figure_no(nofigure);
    for f=1:noFrames
        if (iscell(thevideo))
            theframe=thevideo{f};
            pause(0.3);
        else
            theframe=thevideo(:,:,f);
        end
%         theframe(1,1)=themax;
%         theframe(1,2)=themin;
%         figure(nofigure), imshow(theframe)
        if (themin~=themax)
            figure(nofigure), imagesc(theframe,[themin,themax]);
        else
            figure(nofigure), imagesc(theframe);
        end
        title(['Frame ',num2str(f)]);
        if (showcolorbar)
            colorbar;
        end
        pause(0.1);
    end
end

if (printthetext)
    fprintf('Min %.10f, max %.10f\n',themin,themax);
end

if (writethevideo)
%     clear themovie
    Init_figure_no(nofigure);
    count=0;
    for f=1:noFrames %1:70, 39:98, 1:98
        count=count+1;
        if (iscell(thevideo))
            theframe=thevideo{f};
        else
            theframe=thevideo(:,:,f);
        end
%         theframe(1,1)=themax;
%         theframe(1,2)=themin;
%         figure(nofigure), imshow(theframe)
        if (themin~=themax)
            figure(nofigure), imagesc(theframe,[themin,themax]);
        else
            figure(nofigure), imagesc(theframe);
        end
        title (['Frame ',num2str(f)]);
        set(gca,'xtick',[],'ytick',[]);
        if (showcolorbar)
            colorbar;
        end
        themovie(count) = getframe(gca); %#ok<AGROW>
    end
    movie2avi(themovie, outputfile,'compression','None','fps',5);
    fprintf('Movie written to %s\n',outputfile);
    %Other instructions are in Getclusteringmenu.m
end



function Printthevideoonscreen_previousversion_justlabels(thevideo, printonscreen, nofigure, toscramble) %#ok<DEFNU>

if ( (~exist('toscramble','var')) || (isempty(toscramble)) )
    toscramble=false;
end
if ( (~exist('printonscreen','var')) || (isempty(printonscreen)) )
    printonscreen=false;
end
if ( (~exist('nofigure','var')) || (isempty(nofigure)) )
    nofigure=1;
end

if (toscramble)
    themax=max(thevideo(:));
    permvalues=randperm(themax);
    thevideo(:)=permvalues(thevideo(:));
end

if (printonscreen)
    noFrames=size(thevideo,3);
    Init_figure_no(nofigure);
    themax=max(thevideo(:));
    themin=min(thevideo(:));
    for f=1:noFrames
        theframe=thevideo(:,:,f);
        theframe(1,1)=themax;
        theframe(1,2)=themin;
        figure(nofigure), imagesc(theframe)
        title(['Frame ',num2str(f)]);
        pause(0.1);
    end
end


