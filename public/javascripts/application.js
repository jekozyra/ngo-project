// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/* used in about and help (obtrusive javascript FTL) */
function jumpToSection(){
	var pageIndex = document.form.select.selectedIndex;
	var newIndex = document.form.select.options[pageIndex].value;
	if (newIndex)
		window.location = newIndex;
}
