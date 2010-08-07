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
		
		jQuery.each(stat_data.entries, function(num, chart_info){
			
			var data = new google.visualization.DataTable();
			
			if (chart_info.chart_type == "Pie chart"){
			
				data.addColumn('string', chart_info.column_label);
				data.addColumn('number', chart_info.numeric_label);
			
				data.addRows(chart_info.stats.length);
			
				for (var i=0; i < chart_info.stats.length; i++){
					for(var j=0; j < chart_info.stats[i].length; j++){
						data.setValue(i, j, chart_info.stats[i][j])
					}
				}
			
				var chart = new google.visualization.PieChart(document.getElementById(chart_info.chart_div));
				chart.draw(data, {width: 850, height: 500, title: chart_info.chart_title});
			}
			else{
				
				data.addColumn('string', 'Sectors');
			  for (var i = 0; i  < chart_info.stats.length; ++i) {
			    data.addColumn('number', chart_info.stats[i][0]);    
			  }


			  data.addRows(chart_info.axis_labels.length);

			  for (var j = 0; j < chart_info.axis_labels.length; ++j) {    
			    data.setValue(j, 0, chart_info.axis_labels[j]);    
			  }
			
			  for (var i = 0; i  < chart_info.stats.length; ++i) {
			    for (var j = 1; j  < chart_info.stats[i].length; ++j) {
			      data.setValue(j-1, i+1, chart_info.stats[i][j]);    
			    }
			  }
			
				
				if (chart_info.chart_type == "Vertical bar chart"){
					var chart = new google.visualization.ColumnChart(document.getElementById(chart_info.chart_div));
					chart.draw(data,{width: "100%", height: 700, title: chart_info.chart_title, vAxis: {title: "NGOs"}, hAxis: {title: "Sectors"}});
				}
				else{
					var chart = new google.visualization.BarChart(document.getElementById(chart_info.chart_div));
					chart.draw(data,{width: "100%", height: 700, title: chart_info.chart_title, vAxis: {title: "Sectors"}, hAxis: {title: "NGOs"}});
				}
			
			}
	
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