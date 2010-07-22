//jQuery.noConflict();

// Load the Visualization API and the piechart package.
google.load("visualization", "1", {packages:["corechart"]});

// Set a callback to run when the Google Visualization API is loaded.
google.setOnLoadCallback(drawChart);

// Callback that creates and populates a data table, 
// instantiates the pie chart, passes in the data and
// draws it.
function drawChart() {
	
	// Create our data table.
	jQuery.getJSON('/data/stats.json', function(stat_data) {
		
		jQuery.each(stat_data.entries, function(num, chart_data){

			var data = new google.visualization.DataTable();

			data.addColumn('string', chart_data.column_label);
		  data.addColumn('number', chart_data.numeric_label);

			jQuery.each(chart_data.stats, function(index, value){
				data.addRows(1);
			  data.setValue(index, 0, value.chart_label);
			  data.setValue(index, 1, value.chart_number);
			});


			// Instantiate and draw our chart, passing in some options.
			var chart = new google.visualization.PieChart(document.getElementById(chart_data.chart_div));
			chart.draw(data, {width: "100%", height: 300, title: chart_data.chart_title});
			
		});
		
		
	});
	
}

/*
stats
	[chart label
	 chart number]
	chart title
	chart div
	column label
	numeric column*/