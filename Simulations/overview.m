function position=overview(I,position);
% USAGE    : position=overview(I,position);
% FUNCTION : Adds a zoom of the image I at the indicated position. Returns the
%            rectangle defining the zoom position.
%
% DEFAULTS : * If only the input image is given, the function plots this image and
%              allows to draw a rectangle for zooming.
%            * If only the position is given, the function chooses the current image as input and
%              zooms this image at the indicated position.
%            * If no input is given, the function chooses the current image as input and
%              allows to draw a rectangle for zooming.
%
% The zoomed rectangle can be moved over the picture.
%
% DATE     : 23 November 2014
% AUTHOR   : Thierry Blu, mailto:thierry.blu@m4x.org


showscalevalue=1;       % if True, shows the scale factor (e.g. 3x)
zoomcolor=0.999*[1 1 1];      % color used to draw the zoom rectangles
zoomsize=0.4;
loc=1;

switch nargin
    case 0,noinputimage=1;position=[];
    case 1,if isvector(I),noinputimage=1;position=I;else noinputimage=0;position=[];end
    case 2,noinputimage=0;
end

if noinputimage
    h=findobj(gcf,'type','image');
    if isempty(h)
        error('No image to zoom in!')
    else
        sizeh=0;
        for k=1:length(h)
            I0=get(h(k),'CData');
            if sizeh<prod(size(I0))
                I=I0;
                sizeh=prod(size(I0));
                set(gcf,'CurrentAxes',get(h(k),'Parent'))
                cmap=colormap;
                ttl=get(get(gca,'Title'),'string');
            end
        end
    end
else
    cmap=colormap(gray(256));
    ttl=get(get(gca,'Title'),'string');
end
clf
[sy,sx,sc]=size(I);
hh=image(I);
if sc==1
    colormap(cmap)
end
axis image,axis off,title(ttl)
a=get(gcf,'position');
r=get(gca,'plotboxaspectratio');
if r(2)/r(1)*a(3)/a(4)<1
    a(4)=r(2)/r(1)*a(3);
else
    a(3)=r(1)/r(2)*a(4);
end
set(gca, 'Position',[0 0 1 1]);
set(gcf,'position',a,'PaperPositionMode','auto');

set(gca,'Position',[0 0 0.91 0.91]);
currentaxis=gca;
hold on

if isempty(position)
    waitforbuttonpress;
    point1=get(gca,'CurrentPoint');
    a=rbbox;
    point2=get(gca,'CurrentPoint');
    point=[(point1(1,2:-1:1));(point2(1,2:-1:1))];
    point1=min(point);
    point2=max(point);
    position=[round(point1) ceil(point2-point1)];
    pause(0)
end
position([1 2 3 4])=position([2 1 4 3]);
if max(position(3:4))==0
    position(3:4)=[1 1];
end
J=I(position(2)+(1:position(4))-1,position(1)+(1:position(3))-1,:);
alpha=0.5;
a(1)=position(1)-alpha;
a(2)=position(1)+position(3)-1+alpha;
a(3)=position(2)-alpha;
a(4)=position(2)+position(4)-1+alpha;

plot([a(1) a(2) a(2) a(1) a(1)],[a(3) a(3) a(4) a(4) a(3)],'color',zoomcolor);

area=position(3)*0.92/sx*position(4)*0.92/sy;
m=zoomsize*(position(3:4)./[sx sy])/(max((position(3:4)./[sx sy])));
zoomfactor=round(10*sqrt(prod(m)/area))/10;
axes('Position',[0.99-m m]);
h=image(J);
if sc==1
    colormap(cmap)
end
axis off,hold on,a=axis;
set(h,'ButtonDownFcn',@moveit)
alpha=0;a(1)=a(1)+alpha;a(3)=a(3)+alpha;a(2)=a(2)-alpha;a(4)=a(4)-alpha;
plot([a(1) a(2) a(2) a(1) a(1)],[a(3) a(3) a(4) a(4) a(3)],'color',zoomcolor,'LineWidth',4)

set(hh,'ButtonDownFcn',{@movesel,h})

if showscalevalue
    ret=0.1*min(size(J(:,:,1)));
    text((length(J(1,:,1))-ret),(length(J(:,1,1))-ret),[num2str(zoomfactor) 'x'],'color',zoomcolor,...
        'fontsize',16,'HorizontalAlignment','right','verticalalignment','bottom')
end
position([1 2 3 4])=position([2 1 4 3]);
if nargout==0
    clear position
end
set(gcf,'CurrentAxes',currentaxis)
hold off

function movesel(src,evt,h)
I=get(gco,'CData');
[sy,sx,sc]=size(I);
h0=findobj(get(gco,'parent'),'type','line');
point=get(gca,'CurrentPoint');
point=point(1,1:2);
x0=get(h0,'xdata');x=[min(x0) max(x0)];
y0=get(h0,'ydata');y=[min(y0) max(y0)];
if prod(x-point(1))<=0&prod(y-point(2))<=0
    imx=max(get(gco,'xdata'));
    imy=max(get(gco,'ydata'));
    rect=[x(1) imy-y(1) x(2)-x(1) -y(2)+y(1)];
    figpos=get(gcf,'position');
    ax=figpos(3)-1;
    ay=figpos(4)-1;
    rect([1 3])=rect([1 3])*ax/imx*0.92;
    rect([2 4])=rect([2 4])*ay/imy*0.92;
    rect([1 2])=rect([1 2])+1;
    newpos=dragrect(rect);
    shift=newpos(1:2)-rect(1:2);
    shift=shift.*[imx/ax/0.92 -imy/ay/0.92];
    
    x0=x0+shift(1);
    y0=y0+shift(2);
    set(h0,'xdata',x0)
    set(h0,'ydata',y0)
    a=[x0(1:2) y0(2:3)];
    alpha=0.5;
    position(1)=a(1)-alpha;
    position(3)=a(2)-position(1)+1-alpha;
    position(2)=a(3)+alpha;
    position(4)=a(4)-position(2)+1-alpha;
    position=round(position);

    k0=position(2);k1=position(2)+position(4)-1;
    k=max(k0,1):min(k1,length(I(:,1)));
    l0=position(1);l1=position(1)+position(3)-1;
    l=max(l0,1):min(l1,length(I(1,:)));    
    J=uint8(zeros(position(4),position(3),sc));
    J(k-min(k)+1,l-min(l)+1,:)=I(k,l,:);
    set(h,'CData',J);
end

function moveit(src,evt)
rect=get(gca,'position');
figpos=get(gcf,'position');
ax=figpos(3)-1;
ay=figpos(4)-1;
rect([1 3])=rect([1 3])*ax;
rect([2 4])=rect([2 4])*ay;
rect([1 2])=rect([1 2])+1;
newpos=dragrect(rect);
set(gca,'position',[(newpos(1)-1)/ax (newpos(2)-1)/ay newpos(3)/ax newpos(4)/ay])
