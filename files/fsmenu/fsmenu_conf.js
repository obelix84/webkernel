// JavaScript Document
var listMenu = new FSMenu('listMenu', true, 'visibility', 'visible', 'hidden');
//listMenu.showDelay = 0;
//listMenu.switchDelay = 125;
//listMenu.hideDelay = 500;
listMenu.cssLitClass = 'highlighted';
//listMenu.showOnClick = 1;
function animClipDown(ref, counter)
{
 var cP = Math.pow(Math.sin(Math.PI*counter/200),0.75);
 ref.style.clip = (counter==100 ?
  ((window.opera || navigator.userAgent.indexOf('KHTML') > -1) ? '':
   'rect(auto, auto, auto, auto)') :
    'rect(0, ' + ref.offsetWidth + 'px, '+(ref.offsetHeight*cP)+'px, 0)');
};

function animFade(ref, counter)
{
 var f = ref.filters, done = (counter==100);
 if (f)
 {
  if (!done && ref.style.filter.indexOf("alpha") == -1)
   ref.style.filter += ' alpha(opacity=' + counter + ')';
  else if (f.length && f.alpha) with (f.alpha)
  {
   if (done) enabled = false;
   else { opacity = counter; enabled=true }
  }
 }
 else ref.style.opacity = ref.style.MozOpacity = counter/100.1;
};

// I'm applying them both to this menu and setting the speed to 20%. Delete this to disable.
if( !isOp )
{
    var agt=navigator.userAgent.toLowerCase();
    if( !((agt.indexOf('safari')!=-1)&&(agt.indexOf('mac')!=-1)) ) {
    //alert( isSafari );
    listMenu.animations[listMenu.animations.length] = animFade;
listMenu.animations[listMenu.animations.length] = animClipDown;
listMenu.animSpeed = 20;}}
var arrow = null;
//if (document.createElement && document.documentElement)
//{
// arrow = document.createElement('img');
// arrow.src = 'images/g_arr.gif';
// arrow.style.borderWidth = '0';
 // Feel free to replace the above two lines with these for a small arrow image...
 //arrow = document.createElement('img');
 //arrow.src = 'arrow.gif';
 //arrow.style.borderWidth = '0';

// arrow.className = 'subind';
//}

addEvent(window, 'load', new Function('listMenu.activateMenu("listMenuRoot216540", arrow)'));
