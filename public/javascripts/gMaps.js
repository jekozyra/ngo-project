jQuery.noConflict();

function initialize() {
	
	function place_marker(lat, lng, group, district, country, district_id, country_id){
		
		//searchUrl = "/search/specify?district[name]=" + district_id + "&country[name]=" + country_id + "&display_option=table"
		//content_link = "<a href = \"#\" onclick=\"jQuery('#results-panel-contents').html('Hello World');\">Dummy link</a>"
		content_link = "<a href = \"#\" onclick=\"jQuery.ajax({ url: \"/search/search\", context: document.body, success: function(){jQuery('#results-panel-contents').html('Hello World');}});\">Dummy link</a>"
// 		content: "<a href=\"#\" id=\"more_link\" 
// onclick=\"try {
	// $(&quot;details&quot;).visualEffect(&quot;toggle_blind&quot;);
	// $(&quot;more_link&quot;).update(&quot;Show me less&quot;);} 
	// catch (e) { alert('RJS error:\n\n' + e.toString()); alert('$(\&quot;details\&quot;).visualEffect(\&quot;toggle_blind\&quot;); \n$(\&quot;more_link\&quot;).update(\&quot;Show me less\&quot;);'); throw e}; return false;\">Show me more</a>"
		
		
	//	var infowindow = new google.maps.InfoWindow({
        //content: "<a href=\"" + searchUrl + "\" >View results for " + district + ", " + country + "</a>"
	//		content: content_link
  //  });
		
		var marker = new google.maps.Marker({  
		  position: new google.maps.LatLng(lat,lng),  
		  map: map,  
		  title: group,  
		  //clickable: true,  
		  icon: "/images/icons/group" + group + ".png" 
		});
		
	//	google.maps.event.addListener(marker, 'click', function() {
  //    infowindow.open(map,marker);
  //  });
	}
	
  var latlng = new google.maps.LatLng(31.203405,67.807617);
  var myOptions = {
    zoom: 5,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    navigationControl: true,
    navigationControlOptions: {
        style: google.maps.NavigationControlStyle.ZOOM_PAN,
        position: google.maps.ControlPosition.TOP_RIGHT
    }
  };
  var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	place_marker(map);
	
	jQuery.getJSON("/data/map.json",function(json){
		var markers = json.markers
		jQuery.each(markers, function(){
			place_marker(this.lat, this.lng, this.group, this.district, this.country, this.district_id, this.country_id)
		});

	});
		
};

//when the site has finished loading, start up the init() function
window.onload = initialize;

//start garbage collection when the user browses away
//window.onunload = GUnload;


//set up behavior for legend button
jQuery(document).ready(function() {

	jQuery('#legend-container').hide
	
	jQuery('#legend-btn').click(function(){
		jQuery('#legend-contents').toggle(70);
	});
	
	jQuery.getJSON("/data/map.json",function(json){
		var legend_info = json.legend_info
		jQuery.each(legend_info, function(){
			jQuery('<p>').html('<img src="/images/icons/group' + this.group + '.png\" />' + this.group + " - " + this.count).appendTo('#legend-contents');
		});
						
		jQuery('#legend-container').show();
		jQuery('#legend-contents').show();
		
		jQuery('#results-panel-btn').click(function(){
			jQuery('#results-panel-contents').toggle(70);
			//jQuery('#results-panel-h3').toggle(70);
			jQuery('#results-panel-btn').text(jQuery('#results-panel-btn').text() == '(Show)' ? '(Hide)' : '(Show)');
		});
		
	});
});