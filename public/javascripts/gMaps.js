/**
 * @author Jillian Kozyra
 * @copyright 2008-2009
 */

//adds a marker, by latitude and longitude and gives it a country title
//that will be displayed by clicking on the marker, also adds a group
//to determine which icon will be used.

jQuery.noConflict();

function init(){
	if (GBrowserIsCompatible()) {
	
		//draw the map, add the map controls			
		var map = new GMap2(document.getElementById("map_canvas"));
		map.addControl(new GLargeMapControl());
		map.addControl(new GMapTypeControl());
		
		//center map on Africa
		map.setCenter(new GLatLng(31.203405,67.807617), 5);
		
		//set up custom icon
		var baseIcon = new GIcon();
		baseIcon.image = "/images/icons/group.png";
		//baseIcon.shadow = "http://www.google.com/mapfiles/shadow50.png";
		baseIcon.iconSize = new GSize(20, 34);
		//baseIcon.shadowSize = new GSize(37, 34);
		baseIcon.iconAnchor = new GPoint(9, 34);
		baseIcon.infoWindowAnchor = new GPoint(10, 0);
		
		//add markers to the map
		function addMarker(lat, lng, country, group){
			var point = new GLatLng(lat, lng);
			var icon = new GIcon(baseIcon);
			icon.image = "/images/icons/group" + group + ".png";
			var marker = new GMarker(point, icon);
			//click on icons to get info window
			//GEvent.addListener(marker, "click", function(){
				//marker.openInfoWindowHtml(language);
			//});
			map.addOverlay(marker);
		}
		//define the function thats going to process the json
		process_it = function(doc){
			//parse the json file 
			var jsonData = eval('(' + doc + ')');
			//add the markers to the map
			for (var i = 0; i < jsonData.markers.length; i++) {
				addMarker(jsonData.markers[i].lat, jsonData.markers[i].lng, jsonData.markers[i].language, jsonData.markers[i].group);
			}
		}
		//fetch the json
		var url = "/data/map.json"
		var randomNum = Math.round(Math.random()*(9999999-1));
		var versioned = url + "?v=" + randomNum;
		GDownloadUrl(versioned, process_it);
		
	};
};
//when the site has finished loading, start up the init() function
window.onload = init;

//start garbage collection when the user browses away
window.onunload = GUnload;

//set up behavior for legend button
jQuery(document).ready(function() {

	jQuery('#legend-container').hide
	
	jQuery('#legend-btn').click(function(){
		jQuery('#legend').toggle(70);
	});
	
	jQuery.getJSON("/data/map.json",function(json){
			var markers = json.markers
			var uniqueGroups = {};
			var groupCount = {};
			//iterate thru the json collecting unique affiliation values
			jQuery.each(markers, function() {
  			//uniqueGroups[this.group] = this.SSWLValue.replace(/\|/, " \| ");
				uniqueGroups[this.group] = this.group;
				if(groupCount[this.group] == null){
					groupCount[this.group] = 1;
				}
				else{
					groupCount[this.group] += 1;
				}
			});
			//add an icon for each unique group
			jQuery.each(uniqueGroups, function(g){
				jQuery('<p>').html('<img src="/images/icons/group' + g + '.png\" />' + this + " - " + groupCount[g]).appendTo('#legend-contents');
			});
			//add the country to the legend
			//var country = json.markers[0].country //.replace(/\|/, "\t\|\t")
			//jQuery('#legend-contents').prepend('<strong>'+country+'</strong>');
						
			jQuery('#legend-container').show();
			jQuery('#legend').show();
			jQuery('#legend-contents').show();
		});
});