// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


var timeout    = 500;
var closetimer = 0;
var ddmenuitem = 0;

function jsddm_open()
{  jsddm_canceltimer();
   jsddm_close();
   ddmenuitem = jQuery(this).find('ul').css('visibility', 'visible');}

function jsddm_close()
{  if(ddmenuitem) ddmenuitem.css('visibility', 'hidden');}

function jsddm_timer()
{  closetimer = window.setTimeout(jsddm_close, timeout);}

function jsddm_canceltimer()
{  if(closetimer)
   {  window.clearTimeout(closetimer);
      closetimer = null;}}

jQuery(document).ready(function()
{  jQuery('#jsddm-left > li').bind('mouseover', jsddm_open)
   jQuery('#jsddm-left > li').bind('mouseout',  jsddm_timer)
	 jQuery('#jsddm-right > li').bind('mouseover', jsddm_open)
	 jQuery('#jsddm-right > li').bind('mouseout',  jsddm_timer)});

document.onclick = jsddm_close;


/* used in about and help (obtrusive javascript FTL) */
function jumpToSection(){
	var pageIndex = document.form.select.selectedIndex;
	var newIndex = document.form.select.options[pageIndex].value;
	if (newIndex)
		window.location = newIndex;
}
