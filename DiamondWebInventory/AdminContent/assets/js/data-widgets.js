$(function() {
    "use strict";

	
    $('#widget-chart1').sparkline([5,8,7,10,9,10,8,6,4,6,8,7,6,8], {
            type: 'bar',
            height: '35',
            barWidth: '3',
            resize: true,
            barSpacing: '3',
            barColor: '#008cff '
        });

     
     $("#widget-chart2").sparkline([2,3,4,5,4,3,2,3,4,5,6,5,4,3,4,5], {
        type: 'discrete',
        width: '75',
        height: '40',
        lineColor: '#fd3550',
        lineHeight: 22

     });
    

    $("#widget-chart3").sparkline([0,5,3,7,5,10,3,6,5,10], {
            type: 'line',
            width: '80',
            height: '40',
            lineWidth: '2',
            lineColor: '#15ca20',
            fillColor: 'transparent',
            spotColor: '#15ca20',
        })

		
		$("#widget-chart4").sparkline([5,6,7,9,9,5,3,2,2,4,6,7], {
			type: 'line',
			width: '100',
			height: '25',
			lineWidth: '2',
			lineColor: '#ff9700',
			fillColor: 'transparent'
			
		});
	

	
	$('#widget-chart5').sparkline([5,8,7,10,9,10,8,6,4,6,8,7,6,8], {
            type: 'bar',
            height: '35',
            barWidth: '3',
            resize: true,
            barSpacing: '3',
            barColor: '#008cff '
        });

     
     $("#widget-chart6").sparkline([2,3,4,5,4,3,2,3,4,5,6,5,4,3,4,5], {
        type: 'discrete',
        width: '75',
        height: '40',
        lineColor: '#fd3550',
        lineHeight: 22

     });
    

    $("#widget-chart7").sparkline([0,5,3,7,5,10,3,6,5,10], {
            type: 'line',
            width: '80',
            height: '40',
            lineWidth: '2',
            lineColor: '#15ca20',
            fillColor: 'transparent',
            spotColor: '#fff',
        })

		
		$("#widget-chart8").sparkline([5,6,7,9,9,5,3,2,2,4,6,7], {
			type: 'line',
			width: '100',
			height: '25',
			lineWidth: '2',
			lineColor: '#ff9700',
			fillColor: 'transparent'
			
		});
	
	

        //peity pie

            $("span.pie").peity("pie",{
                width: 65,
                height: 65 
            });

         //peity donut

          $("span.donut").peity("donut",{
                width: 65,
                height: 65 
            }); 


$('#widget-chart9').easyPieChart({
            easing: 'easeOutBounce',
            barColor : '#008cff ',
            lineWidth: 3,
            animate: 1000,
            size:80,
            lineCap: 'square',
            trackColor: '#e5e5e5',
            onStep: function(from, to, percent) {
                $(this.el).find('.w_percent').text(Math.round(percent));
            }
        }); 



        $('#widget-chart10').easyPieChart({
            easing: 'easeOutBounce',
            barColor : '#15ca20',
            lineWidth: 3,
            animate: 1000,
            size:80,
            lineCap: 'square',
            trackColor: '#e5e5e5',
            onStep: function(from, to, percent) {
                $(this.el).find('.w_percent').text(Math.round(percent));
            }
        }); 



        $('#widget-chart11').easyPieChart({
            easing: 'easeOutBounce',
            barColor : '#fd3550',
            lineWidth: 3,
            animate: 1000,
            size:80,
            scaleColor: false,
            lineCap: 'square',
            trackColor: '#e5e5e5',
            onStep: function(from, to, percent) {
                $(this.el).find('.w_percent').text(Math.round(percent));
            }

        }); 


        $('#widget-chart12').easyPieChart({
            easing: 'easeOutBounce',
            barColor : '#ff9700',
            lineWidth: 3,
            animate: 1000,
            size:80,
            scaleColor: false,
            lineCap: 'square',
            trackColor: '#e5e5e5',
            onStep: function(from, to, percent) {
                $(this.el).find('.w_percent').text(Math.round(percent));
            }

        }); 
		
		

/*color data widgets*/

    $('#widget-chart13').sparkline([5,8,7,10,9,10,8,6,4,6,8,7,6,8], {
            type: 'bar',
            height: '35',
            barWidth: '3',
            resize: true,
            barSpacing: '3',
            barColor: '#fff'
        });

     
     $("#widget-chart14").sparkline([2,3,4,5,4,3,2,3,4,5,6,5,4,3,4,5], {
        type: 'discrete',
        width: '75',
        height: '40',
        lineColor: '#fff',
        lineHeight: 22

     });
    

    $("#widget-chart15").sparkline([0,5,3,7,5,10,3,6,5,10], {
            type: 'line',
            width: '80',
            height: '40',
            lineWidth: '2',
            lineColor: '#fff',
            fillColor: 'transparent',
            spotColor: '#fff',
        })

		
		$("#widget-chart16").sparkline([5,6,7,9,9,5,3,2,2,4,6,7], {
			type: 'line',
			width: '100',
			height: '25',
			lineWidth: '2',
			lineColor: '#ffffff',
			fillColor: 'transparent'
			
		});
	

	
	$('#widget-chart17').sparkline([5,8,7,10,9,10,8,6,4,6,8,7,6,8], {
            type: 'bar',
            height: '35',
            barWidth: '3',
            resize: true,
            barSpacing: '3',
            barColor: '#fff'
        });

     
     $("#widget-chart18").sparkline([2,3,4,5,4,3,2,3,4,5,6,5,4,3,4,5], {
        type: 'discrete',
        width: '75',
        height: '40',
        lineColor: '#fff',
        lineHeight: 22

     });
    

    $("#widget-chart19").sparkline([0,5,3,7,5,10,3,6,5,10], {
            type: 'line',
            width: '80',
            height: '40',
            lineWidth: '2',
            lineColor: '#fff',
            fillColor: 'transparent',
            spotColor: '#fff',
        })

		
		$("#widget-chart20").sparkline([5,6,7,9,9,5,3,2,2,4,6,7], {
			type: 'line',
			width: '100',
			height: '25',
			lineWidth: '2',
			lineColor: '#ffffff',
			fillColor: 'transparent'
			
		});

      $('#widget-chart21').easyPieChart({
            easing: 'easeOutBounce',
            barColor : '#0eb318',
            lineWidth: 3,
            animate: 1000,
            size:80,
            lineCap: 'square',
            trackColor: '#e5e5e5',
            onStep: function(from, to, percent) {
                $(this.el).find('.w_percent').text(Math.round(percent));
            }
        }); 


        $('#widget-chart22').easyPieChart({
            easing: 'easeOutBounce',
            barColor : '#d4051a',
            lineWidth: 3,
            animate: 1000,
            size:80,
            scaleColor: false,
            lineCap: 'square',
            trackColor: '#e5e5e5',
            onStep: function(from, to, percent) {
                $(this.el).find('.w_percent').text(Math.round(percent));
            }

        });


/*gradient color data widgets*/


$('#widget-chart23').sparkline([5,8,7,10,9,10,8,6,4,6,8,7,6,8], {
            type: 'bar',
            height: '35',
            barWidth: '3',
            resize: true,
            barSpacing: '3',
            barColor: '#fff'
        });

     
     $("#widget-chart24").sparkline([2,3,4,5,4,3,2,3,4,5,6,5,4,3,4,5], {
        type: 'discrete',
        width: '75',
        height: '40',
        lineColor: '#fff',
        lineHeight: 22

     });
    

    $("#widget-chart25").sparkline([0,5,3,7,5,10,3,6,5,10], {
            type: 'line',
            width: '80',
            height: '40',
            lineWidth: '2',
            lineColor: '#fff',
            fillColor: 'transparent',
            spotColor: '#fff',
        })

		
		$("#widget-chart26").sparkline([5,6,7,9,9,5,3,2,2,4,6,7], {
			type: 'line',
			width: '100',
			height: '25',
			lineWidth: '2',
			lineColor: '#ffffff',
			fillColor: 'transparent'
			
		});
	

	
	$('#widget-chart27').sparkline([5,8,7,10,9,10,8,6,4,6,8,7,6,8], {
            type: 'bar',
            height: '35',
            barWidth: '3',
            resize: true,
            barSpacing: '3',
            barColor: '#fff'
        });

     
     $("#widget-chart28").sparkline([2,3,4,5,4,3,2,3,4,5,6,5,4,3,4,5], {
        type: 'discrete',
        width: '75',
        height: '40',
        lineColor: '#fff',
        lineHeight: 22

     });
    

    $("#widget-chart29").sparkline([0,5,3,7,5,10,3,6,5,10], {
            type: 'line',
            width: '80',
            height: '40',
            lineWidth: '2',
            lineColor: '#fff',
            fillColor: 'transparent',
            spotColor: '#fff',
        })

		
		$("#widget-chart30").sparkline([5,6,7,9,9,5,3,2,2,4,6,7], {
			type: 'line',
			width: '100',
			height: '25',
			lineWidth: '2',
			lineColor: '#ffffff',
			fillColor: 'transparent'
			
		});

$('#widget-chart31').easyPieChart({
            easing: 'easeOutBounce',
            barColor : '#19d243',
            lineWidth: 3,
            animate: 1000,
            size:80,
            lineCap: 'square',
            trackColor: '#e5e5e5',
            onStep: function(from, to, percent) {
                $(this.el).find('.w_percent').text(Math.round(percent));
            }
        }); 


        $('#widget-chart32').easyPieChart({
            easing: 'easeOutBounce',
            barColor : '#ff717f',
            lineWidth: 3,
            animate: 1000,
            size:80,
            scaleColor: false,
            lineCap: 'square',
            trackColor: '#e5e5e5',
            onStep: function(from, to, percent) {
                $(this.el).find('.w_percent').text(Math.round(percent));
            }

        });
		
		
	
		
		
	});