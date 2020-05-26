/*

FREESTYLE MENUS v1.0 RC (c) 2001-2005 Angus Turnbull, http://www.twinhelix.com
Altering this notice or redistributing this file is prohibited.

*/
var isSafari = false;

var isDOM=document.getElementById?1:0,
    isIE=document.all?1:0,
    isNS4=navigator.appName=='Netscape'&&!isDOM?1:0,
    isOp=self.opera?1:0,
    isDyn=isDOM||isIE||isNS4;
function getRef(i,p)
{
 p=!p?document:p.navigator?p.document:p;
 return isIE?p.all[i]:isDOM?(p.getElementById?p:p.ownerDocument).getElementById(i):isNS4?p.layers[i]:null
}
function getSty(i,p)
{
 var r=getRef(i,p);return r?isNS4?r:r.style:null};if(!self.LayerObj)var LayerObj=new Function('i','p','this.ref=getRef(i,p);this.sty=getSty(i,p);return this');function getLyr(i,p){return new LayerObj(i,p)};function LyrFn(n,f){LayerObj.prototype[n]=new Function('var a=arguments,p=a[0],px=isNS4||isOp?0:"px";with(this){'+f+'}')};LyrFn('x','if(!isNaN(p))sty.left=p+px;else return parseInt(sty.left)');LyrFn('y','if(!isNaN(p))sty.top=p+px;else return parseInt(sty.top)');var aeOL=[];function addEvent(o,n,f,l){var a='addEventListener',h='on'+n,b='',s='';if(o[a]&&!l)return o[a](n,f,false);o._c|=0;if(o[h]){b='_f'+o._c++;o[b]=o[h]}s='_f'+o._c++;o[s]=f;o[h]=function(e){e=e||window.event;var r=true;if(b)r=o[b](e)!=false&&r;r=o[s](e)!=false&&r;return r};aeOL[aeOL.length]={o:o,h:h}};addEvent(window,'unload',function(){for(var i=0;i<aeOL.length;i++)with(aeOL[i]){o[h]=null;for(var c=0;o['_f'+c];c++)o['_f'+c]=null}});function FSMenu(myName,nested,cssProp,cssVis,cssHid){this.myName=myName;this.nested=nested;this.cssProp=cssProp;this.cssVis=cssVis;this.cssHid=cssHid;this.cssLitClass='';this.menus={root:new FSMenuNode('root',true,this)};this.menuToShow=[];this.mtsTimer=null;this.showDelay=0;this.switchDelay=125;this.hideDelay=500;this.showOnClick=0;this.animations=[];this.animSpeed=100;if(isIE&&!isOp)addEvent(window,'unload',new Function(myName+'=null'))};FSMenu.prototype.show=function(mN){with(this){menuToShow.length=arguments.length;for(var i=0;i<arguments.length;i++)menuToShow[i]=arguments[i];clearTimeout(mtsTimer);if(!nested)mtsTimer=setTimeout(myName+'.menus.root.over()',10)}};FSMenu.prototype.hide=function(mN){with(this){clearTimeout(mtsTimer);if(menus[mN])menus[mN].out()}};function FSMenuNode(id,isRoot,obj){this.id=id;this.isRoot=isRoot;this.obj=obj;this.lyr=this.child=this.par=this.timer=this.visible=null;this.args=[];var node=this;this.over=function(evt){with(node)with(obj){if(isNS4&&evt&&lyr.ref)lyr.ref.routeEvent(evt);clearTimeout(timer);clearTimeout(mtsTimer);if(!isRoot&&!visible)node.show();if(menuToShow.length){var a=menuToShow,m=a[0];if(!menus[m]||!menus[m].lyr.ref)menus[m]=new FSMenuNode(m,false,obj);var c=menus[m];if(c==node){menuToShow.length=0;return}clearTimeout(c.timer);if(c!=child&&c.lyr.ref){c.args.length=a.length;for(var i=0;i<a.length;i++)c.args[i]=a[i];var delay=child?switchDelay:showDelay;c.timer=setTimeout('with('+myName+'){menus["'+c.id+'"].par=menus["'+node.id+'"];menus["'+c.id+'"].show()}',delay?delay:1)}menuToShow.length=0}if(!nested&&par)par.over()}};this.out=function(evt){with(node)with(obj){if(isNS4&&evt&&lyr&&lyr.ref)lyr.ref.routeEvent(evt);clearTimeout(timer);if(!isRoot){timer=setTimeout(myName+'.menus["'+id+'"].hide()',hideDelay);if(!nested&&par)par.out()}}};if(this.id!='root')with(this)with(lyr=getLyr(id))if(ref){if(isNS4)ref.captureEvents(Event.MOUSEOVER|Event.MOUSEOUT);addEvent(ref,'mouseover',this.over);addEvent(ref,'mouseout',this.out);if(obj.nested){addEvent(ref,'focus',this.over);addEvent(ref,'click',this.over);addEvent(ref,'blur',this.out)}}};FSMenuNode.prototype.show=function(){with(this)with(obj){if(!lyr||!lyr.ref)return;if(par){if(par.child&&par.child!=this)par.child.hide();par.child=this}var offR=args[1],offX=args[2],offY=args[3],lX=0,lY=0,doX=''+offX!='undefined',doY=''+offY!='undefined';if(self.page&&offR&&(doX||doY)){with(page.elmPos(offR,par.lyr?par.lyr.ref:0))lX=x,lY=y;if(doX)lyr.x(lX+eval(offX));if(doY)lyr.y(lY+eval(offY))}if(offR)lightParent(offR,1);visible=1;if(obj.onshow)obj.onshow(id);setVis(1)}};FSMenuNode.prototype.hide=function(){with(this)with(obj){if(!lyr||!lyr.ref)return;if(isNS4&&self.isMouseIn&&isMouseIn(lyr.ref))return show();if(args[1])lightParent(args[1],0);if(child)child.hide();if(par&&par.child==this)par.child=null;if(lyr){visible=0;if(obj.onhide)obj.onhide(id);setVis(0)}}};FSMenuNode.prototype.lightParent=function(elm,lit){with(this)with(obj){if(!cssLitClass||isNS4)return;if(lit)elm.className+=(elm.className?' ':'')+cssLitClass;else elm.className=elm.className.replace(new RegExp('(\\s*'+cssLitClass+')+$'),'')}};FSMenuNode.prototype.setVis=function(sh){with(this)with(obj){lyr.timer|=0;lyr.counter|=0;with(lyr){clearTimeout(timer);if(sh&&!counter)sty[cssProp]=cssVis;if(isDOM&&animSpeed<100)for(var a=0;a<animations.length;a++)animations[a](ref,counter);counter+=animSpeed*(sh?1:-1);if(counter>100){counter=100}else if(counter<=0){counter=0;sty[cssProp]=cssHid}else if(isDOM)timer=setTimeout(myName+'.menus["'+id+'"].setVis('+sh+')',50)}}};FSMenu.prototype.activateMenu=function(id,subInd){sniffAll();with(this){if(!isDOM||!document.documentElement)return;var a,ul,li,parUL,mRoot=getRef(id),nodes,count=1;if(isIE){var aNodes=mRoot.getElementsByTagName('a');for(var i=0;i<aNodes.length;i++){addEvent(aNodes[i],'focus',new Function('e','var node=this.parentNode;while(node){if(node.onfocus)setTimeout(node.onfocus,1,e);node=node.parentNode}'));addEvent(aNodes[i],'blur',new Function('e','var node=this.parentNode;while(node){if(node.onblur)node.onblur(e);node=node.parentNode}'))}}var lists=mRoot.getElementsByTagName('ul');for(var i=0;i<lists.length;i++){li=ul=lists[i];while(li){if(li.nodeName.toLowerCase()=='li')break;li=li.parentNode}if(!li)continue;parUL=li;while(parUL){if(parUL.nodeName.toLowerCase()=='ul')break;parUL=parUL.parentNode}a=null;for(var j=0;j<li.childNodes.length;j++)if(li.childNodes[j].nodeName.toLowerCase()=='a')a=li.childNodes[j];if(!a)continue;var menuID=myName+'-id-'+count++;if(ul.id)menuID=ul.id;else ul.setAttribute('id',menuID);var sOC=(showOnClick==1&&li.parentNode==mRoot)||(showOnClick==2);var eShow=new Function('with('+myName+'){var m=menus["'+menuID+'"],pM=menus["'+parUL.id+'"];'+(sOC?'if((pM&&pM.child)||(m&&m.visible))':'')+' show("'+menuID+'",this)}');var eHide=new Function(myName+'.hide("'+menuID+'")');addEvent(a,'mouseover',eShow);addEvent(a,'focus',eShow);addEvent(a,'mouseout',eHide);addEvent(a,'blur',eHide);if(sOC)addEvent(a,'click',new Function('e',myName+'.show("'+menuID+'",this);if(e.cancelable&&e.preventDefault)e.preventDefault();e.returnValue=false;return false'));if(subInd)a.insertBefore(subInd.cloneNode(true),a.firstChild)}menus[id]=new FSMenuNode(id,true,this)}};if(!self.page)var page={win:self,minW:0,minH:0,MS:isIE&&!isOp};page.elmPos=function(e,p){var x=0,y=0,w=p?p:this.win;e=e?(e.substr?(isNS4?w.document.anchors[e]:getRef(e,w)):e):p;if(isNS4){if(e&&(e!=p)){x=e.x;y=e.y};if(p){x+=p.pageX;y+=p.pageY}}if(e&&this.MS&&navigator.platform.indexOf('Mac')>-1&&e.tagName=='A'){e.onfocus=new Function('with(event){self.tmpX=clientX-offsetX;self.tmpY=clientY-offsetY}');e.focus();x=tmpX;y=tmpY;e.blur()}else while(e){x+=e.offsetLeft;y+=e.offsetTop;e=e.offsetParent}return{x:x,y:y}};if(isNS4){var fsmMouseX,fsmMouseY,fsmOR=self.onresize,nsWinW=innerWidth,nsWinH=innerHeight;document.fsmMM=document.onmousemove;self.onresize=function(){if(fsmOR)fsmOR();if(nsWinW!=innerWidth||nsWinH!=innerHeight)location.reload()};document.captureEvents(Event.MOUSEMOVE);document.onmousemove=function(e){fsmMouseX=e.pageX;fsmMouseY=e.pageY;return document.fsmMM?document.fsmMM(e):document.routeEvent(e)};function isMouseIn(sty){with(sty)return((fsmMouseX>left)&&(fsmMouseX<left+clip.width)&&(fsmMouseY>top)&&(fsmMouseY<top+clip.height))}}
 
 function sniffAll()
{
    /* JavaScript Browser Sniffer
       Eric Krok, Andy King, Michel Plungjan Jan. 31, 2002
       see http://www.webreference.com/ for more information
       This program is free software */

    var agt=navigator.userAgent.toLowerCase();
    var appVer = navigator.appVersion.toLowerCase();

    var is_minor = parseFloat(appVer);
    var is_major = parseInt(is_minor);

    var is_opera = (agt.indexOf("opera") != -1);

    /*
    var is_opera6 = (agt.indexOf("opera 6") != -1 || agt.indexOf("opera/6") != -1);
    var is_opera7 = (agt.indexOf("opera 7") != -1 || agt.indexOf("opera/7") != -1);
    var is_opera6up = (is_opera && !is_opera2 && !is_opera3 && !is_opera4 && !is_opera5);
    var is_opera7up = (is_opera && !is_opera2 && !is_opera3 && !is_opera4 && !is_opera5 && !is_opera6);
    */

    var iePos  = appVer.indexOf('msie');
    if (iePos !=-1) {
       is_minor = parseFloat(appVer.substring(iePos+5,appVer.indexOf(';',iePos)));
       is_major = parseInt(is_minor);
    }

    var is_konq = false;
    var kqPos   = agt.indexOf('konqueror');
    if (kqPos !=-1) {                 
       is_konq  = true;
       is_minor = parseFloat(agt.substring(kqPos+10,agt.indexOf(';',kqPos)));
       is_major = parseInt(is_minor);
    }

    var is_getElementById   = (document.getElementById) ? "true" : "false";
    var is_getElementsByTagName = (document.getElementsByTagName) ? "true" : "false";
    var is_documentElement = (document.documentElement) ? "true" : "false";

    var is_safari = ((agt.indexOf('safari')!=-1)&&(agt.indexOf('mac')!=-1))?true:false;
    var is_khtml  = (is_safari || is_konq);

    var is_gecko = ((!is_khtml)&&(navigator.product)&&(navigator.product.toLowerCase()=="gecko"))?true:false;
    var is_gver  = 0;
    if (is_gecko) is_gver=navigator.productSub;

    var is_moz   = ((agt.indexOf('mozilla/5')!=-1) && (agt.indexOf('spoofer')==-1) &&
                    (agt.indexOf('compatible')==-1) && (agt.indexOf('opera')==-1)  &&
                    (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')==-1)     &&
                    (is_gecko) && 
                    ((navigator.vendor=="")||(navigator.vendor=="Mozilla")));


    if (is_moz) {
       var is_moz_ver = (navigator.vendorSub)?navigator.vendorSub:0;
       if(!(is_moz_ver)) {
           is_moz_ver = agt.indexOf('rv:');
           is_moz_ver = agt.substring(is_moz_ver+3);
           is_paren   = is_moz_ver.indexOf(')');
           is_moz_ver = is_moz_ver.substring(0,is_paren);
       }
       is_minor = is_moz_ver;
       is_major = parseInt(is_moz_ver);
    }

    var is_nav  = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')==-1)
                && (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')==-1)
                && (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')==-1)
                && (!is_khtml) && (!(is_moz)));

    if ((navigator.vendor)&&
        ((navigator.vendor=="Netscape6")||(navigator.vendor=="Netscape"))&&
        (is_nav)) {
       is_major = parseInt(navigator.vendorSub);
       is_minor = parseFloat(navigator.vendorSub);
    }

    var is_nav2 = (is_nav && (is_major == 2));
    var is_nav3 = (is_nav && (is_major == 3));
    var is_nav4 = (is_nav && (is_major == 4));
    var is_nav4up = (is_nav && is_minor >= 4); 
    var is_navonly  = (is_nav && ((agt.indexOf(";nav") != -1) ||
                          (agt.indexOf("; nav") != -1)) );

    var is_nav6   = (is_nav && is_major==6);
    var is_nav6up = (is_nav && is_minor >= 6);

    var is_nav5   = (is_nav && is_major == 5 && !is_nav6);
    var is_nav5up = (is_nav && is_minor >= 5);

    var is_nav7   = (is_nav && is_major == 7);
    var is_nav7up = (is_nav && is_minor >= 7);

    var is_ie   = ((iePos!=-1) && (!is_opera) && (!is_khtml));
    var is_ie3  = (is_ie && (is_major < 4));

    var is_ie4   = (is_ie && is_major == 4);
    var is_ie4up = (is_ie && is_minor >= 4);
    var is_ie5   = (is_ie && is_major == 5);
    var is_ie5up = (is_ie && is_minor >= 5);
    
    var is_ie5_5  = (is_ie && (agt.indexOf("msie 5.5") !=-1));
    var is_ie5_5up =(is_ie && is_minor >= 5.5);
    
    var is_ie6   = (is_ie && is_major == 6);
    var is_ie6up = (is_ie && is_minor >= 6);
	isSafari = is_safari;
}