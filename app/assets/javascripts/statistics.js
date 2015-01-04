/***************************
**** API Data Functions ****
****************************/
function _apiStatisticsData(action, callback) {
    $.getJSON("statistics/api/"+action, function(data) {
        callback(data['response']);
    });
}

function apiActiveHosts(callback) {
    _apiStatisticsData('active_hosts', callback);
}

function apiHostsByCity(callback) {
    _apiStatisticsData('hosts_by_city', callback);
}


function apiTeatimesByCity(callback) {
    _apiStatisticsData('teatimes_by_city', callback);
}

/*******************************
**** Create Chart Functions ****
*******************************/
function createChart(chartType, chartSelector, chartOptions, chartDataCallback) {

    // Require valid data source for chart
    if(typeof(chartDataCallback) !== typeof(Function)) {
        return null;
    }

    var chartObject = null;
    var chart = null;
    var chartData = chartDataCallback(function(chartData) {
        // Require valid data for chart
        if(chartData === null) {
            return null;
        }

        // Pre-Apply Options Where Applicable
        if('title' in chartOptions) {
            $(chartSelector + " > .chartTitle").text(chartOptions['title']);
        }

        if('width' in chartOptions && 'height' in chartOptions) {
            $(chartSelector + " > .chart").attr({
                'width': chartOptions['width'],
                'height': chartOptions['height'],
            });
        }

        // Create the Chart
        if(chartType != 'scalar') {
            chartObject = new Chart($(chartSelector + " > .chart").get(0).getContext("2d"));
        }

        switch(chartType) {
            case 'scalar':
                createScalarChart(chartSelector, chartData);
                break;
            case 'doughnut':
                chart = createDoughnutChart(chartObject, chartData,
                {
                    scaleShowValues: true,
                    showScale: true,
                    legendTemplate : '<ul class="doughnut-legend"><% for (var i=0; i<segments.length; i++){%><li><span class="indicator" style="background-color:<%=segments[i].fillColor%>"></span><span class="label"><%if(segments[i].label){%><%=segments[i].label%> (<%=segments[i].value%>)<%}%></span></li><%}%></ul>'
                });
                break;

            case 'line':
                chart = createLineChart(chartObject, chartData,
                {
                    scaleShowValues: true,
                    showScale: true,
                    pointHitDetectionRadius : 50,
                    multiTooltipTemplate: "<%= value %> <%= datasetLabel %>",
                    legendTemplate : '<ul class="line-legend"><% for (var i=0; i<datasets.length; i++){%><li><span class="indicator" style="background-color:<%=datasets[i].fillColor%>"></span><span class="label"><%if(datasets[i].label){%><%=datasets[i].label%><%}%></span></li><%}%></ul>'
                });
                break;

            case 'bar':
                chart = createBarChart(chartObject, chartData,
                {
                    scaleShowValues: true,
                    showScale: true,
                    multiTooltipTemplate: "<%= value %> <%= datasetLabel %>",
                    legendTemplate : '<ul class="line-legend"><% for (var i=0; i<datasets.length; i++){%><li><span class="indicator" style="background-color:<%=datasets[i].fillColor%>"></span><span class="label"><%if(datasets[i].label){%><%=datasets[i].label%><%}%></span></li><%}%></ul>'
                });
                break;
            default:
                return null;
        }

        // Post-Apply Options Where Applicable
        if('showLegend' in chartOptions && chartOptions['showLegend'] === true) {
            $(chartSelector + " > .chartLegend").html(chart.generateLegend());
        }
    });
}

function createDoughnutChart(chartObject, chartData, chartOptions) {
    return chartObject.Doughnut(chartData, chartOptions);
}

function createLineChart(chartObject, chartData, chartOptions) {
    //TODO: Implement
}

function createBarChart(chartObject, chartData, chartOptions) {
    //TODO: Implement
}

function createScalarChart(scalarStatisticsSelector, scalarData) {
    var $chart = $(scalarStatisticsSelector + " > .statistics");

    $.each(scalarData, function(i, statistic) {
        var $row = $([
            '<div class="statContainer">',
                '<span class="statTitle">', statistic['stat'], '</span>',
                '<span class="statValue">', statistic['value'] , '</span>',
            '</div>'
        ].join(''));
        $chart.append($row);
    });
}

$(document).ready(function() {

    createChart('scalar', '#scalarStatistics', {
        'title': "Active Hosts by City (past 2 weeks)",
        'height': 450,
        'width': 300
    }, apiActiveHosts);

    createChart('doughnut', '#hostsByCityDoughnut', {
        'title': "Hosts by City",
        'height': 300,
        'width': 300,
        'showLegend': true
    }, apiHostsByCity);

    createChart('doughnut', '#teatimesByCityDoughnut', {
        'title': "Tea-Times by City",
        'height': 300,
        'width': 300,
        'showLegend': true
    }, apiTeatimesByCity);
});
