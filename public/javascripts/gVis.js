 google.load('visualization', '1', {'packages': ['geomap']});
 google.setOnLoadCallback(drawMap);

function drawMap() {

		// Create our data table.
		jQuery.getJSON('/data/vis.json', function(vis_data) {
			
			jQuery.each(vis_data.maps, function(num, map_data){

				var data = new google.visualization.DataTable();

				data.addColumn('string', map_data.column_label);
			  data.addColumn('number', "NGOs");

				jQuery.each(map_data.locations, function(index, value){
					data.addRows(1);
				  data.setValue(index, 0, value.map_label);
				  data.setValue(index, 1, value.map_number);
				});

				var options = {};
		    options['dataMode'] = 'regions';
				options['region'] = map_data.region_id;

		    var container = document.getElementById(map_data.map_div);
		    var geomap = new google.visualization.GeoMap(container);
		    geomap.draw(data, options);

			});


		});


};


