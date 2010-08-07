
function initialize() {
	
	function place_marker(lat, lng, country, province, district, count){

		content_link = "<a href = \"#\" onclick=\"jQuery.ajax({ url: \"/search/search\", context: document.body, success: function(){jQuery('#results-panel-contents').html('Hello World');}});\">Dummy link</a>"

		var infowindow = new google.maps.InfoWindow({
			content: district + ", " + province + ", " + country + "<br />" + count + " NGOs"
    });
		
		var marker = new google.maps.Marker({  
		  position: new google.maps.LatLng(lat,lng),  
		  map: map,  
		  title: district + ", " + province + ", " + country,  
		  clickable: true,  
		  icon: "/images/icons/group.png" 
		});
		
		google.maps.event.addListener(marker, 'click', function() {
      infowindow.open(map,marker);
    });
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
			console.log(this.lat);
			place_marker(this.lat, this.lng, this.country, this.province, this.district, this.count);
		});

	});
		
};

//when the site has finished loading, start up the init() function
window.onload = initialize;

//start garbage collection when the user browses away
//window.onunload = GUnload;

