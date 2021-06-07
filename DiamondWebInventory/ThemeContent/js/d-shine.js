jQuery(document).ready(function(){
jQuery("#testiTab li").each(function(){
    jQuery(this).on("mouseover", function(){
         jQuery(this).children().trigger("click");    
    });
});


    
    (function($) {
        "use strict"; 
    /*------------------------------    
    Go Top
    ------------------------------*/
        jQuery('a[href="#top"]').on('click', function () {
            jQuery('html, body').animate({ scrollTop: 0 }, 800);
            return false
        });
        
    /*------------------------------    
    Shortcodes
    ------------------------------*/
       jQuery('span[data-toggle="tooltip"]').tooltip();
        jQuery('span[data-toggle="tooltip"][data-placement="top"]').tooltip('show');
        
    /*------------------------------    
    Search Filter
    ------------------------------*/
        jQuery('.searchFilters .dropdown-menu').find('a').on("click", function(e)
            {
                e.preventDefault();
                var param = $(this).attr("href").replace("#","");
                var concept = $(this).text();
                jQuery('.searchFilters span#searchFilterValue').text(concept);
                jQuery('.input-group #search_param').val(param);
            });


    /*------------------------------    
    Partner And Testimonial
    ------------------------------*/
        jQuery('.ptTabNavs').on('click','.prevTab', function(){
          jQuery('.ptTab_nav > .active').prev('li').find('a').trigger('click')
        });

        jQuery('.ptTabNavs').on('click','.nextTab', function(){
          jQuery('.ptTab_nav > .active').next('li').find('a').trigger('click')
        });
        
    /*------------------------------    
    Gallery Slider
    ------------------------------*/
        jQuery('.featureCats').owlCarousel({
            loop:true,
            margin:0,
            responsiveClass:true,
            nav: true,
            navText: [ '<i class="fas fa-angle-left"></i>','<i class="fas fa-angle-right"></i>' ],
            autoplay: false,
            responsive:{
                0:{
                    items:1,
                    nav:true
                },
                600:{
                    items:2,
                    nav:true
                },
                1000:{
                    items:4,
                    nav:true
                }
            }
        }); 
        jQuery('.d-carousel-cener').owlCarousel({
            center: true,
            items:5,
            loop:true,
            nav: true,
            margin:10,
            responsive:{
                0:{
                    items:1,
                    nav:true
                },
                600:{
                    items:3,
                    nav:true
                },
                1000:{
                    items:4,
                    nav:true
                }
            }
        });
    

       //jQuery(function () { // wait for document ready
       //                     // init controller
       //                     var controller = new ScrollMagic.Controller();

       //                     // show pin state
       //                     function updateBox (e) {
       //                         if (e.type == "enter") {
       //                             jQuery("#pin p").text("Pinned.");
       //                         } else {
       //                             jQuery("#pin p").text("Unpinned.");
       //                         }
       //                     }

       //                     // build scenes
       //                     new ScrollMagic.Scene({triggerElement: "#trigger", duration: 150})
       //                         .setPin("#pin")
       //                         .setClassToggle("#pin", "one")
       //                         .on("enter leave", updateBox)
       //                         .addIndicators() // add indicators (requires plugin)
       //                         .addTo(controller);

       //                          new ScrollMagic.Scene({triggerElement: "#trigger", duration: 150})
       //                         .setPin("#pin-2")
       //                         .setClassToggle("#pin", "green")
       //                         .on("enter leave", updateBox)
       //                         .addIndicators() // add indicators (requires plugin)
       //                         .addTo(controller);
                           
       //                 });
    /*----------------------------------------------------*/
    /*  Count Up
    /*----------------------------------------------------*/
    jQuery('.counter').counterUp({
        delay: 15,
        time: 1500
    });    
    
    /*----------------------------------------------------*/
    /*  Spinner
    /*----------------------------------------------------*/
    jQuery('.spinner .btn:first-of-type').on('click', function() {
        jQuery('.spinner input').val( parseInt($('.spinner input').val(), 10) + 1);
    });
    jQuery('.spinner .btn:last-of-type').on('click', function() {
        jQuery('.spinner input').val( parseInt($('.spinner input').val(), 10) - 1);
    });
    
    /*----------------------------------------------------*/
    /*  Shipping Address
    /*----------------------------------------------------*/
    jQuery('#shippingAddressEscape').on('click',function() {
        var isChecked = $('#shippingAddressEscape').is(':checked');
        if(isChecked)
            jQuery("#shippingAddress").find(':input').attr('disabled', 'disabled');
        else 
            jQuery("#shippingAddress").find(':input').removeAttr('disabled', 'disabled')
    });
        
    /*------------------------------    
    Team Member Slider
    ------------------------------*/
        jQuery('.ourTeamSlide').owlCarousel({
            loop:true,
            margin:0,
            responsiveClass:true,
            nav: true,
            navText: [ '<i class="fas fa-angle-left"></i>','<i class="fas fa-angle-right"></i>' ],
            autoplay: true,
            responsive:{
                0:{
                    items:1,
                    nav:true
                },
                600:{
                    items:1,
                    nav:true
                },
                1000:{
                    items:2,
                    nav:true
                }
            }
        })
        
    })(jQuery)
});

jQuery(window).load(function() {
        
    /*------------------------------    
    Sinlge Prodcut Slider
    ------------------------------*/
    jQuery('#productImageSliderNav').flexslider({
        animation: "slide",
        controlNav: false,
        animationLoop: false,
        directionNav: true,
        slideshow: false,
        itemWidth: 130,
        itemMargin: 10,
        asNavFor: '#productImageSlider',
        prevText: '<i class="fas fa-angle-left"></i>',
        nextText: '<i class="fas fa-angle-right"></i>', 
    });

    jQuery('#productImageSlider').flexslider({
        animation: "slide",
        controlNav: false,
        animationLoop: false,
        directionNav: false,
        slideshow: false,
        sync: "#productImageSliderNav"
    });
        
    /*------------------------------    
    Main Slider
    ------------------------------*/
    jQuery('.sliderCont').flexslider({
        animation: "fade",
        // Primary Controls
        controlNav: false,               //Boolean: Create navigation for paging control of each clide? Note: Leave true for manualControls usage
        directionNav: true,             //Boolean: Create navigation for previous/next navigation? (true/false)
        prevText: '<i class="fas fa-angle-left"></i>',           //String: Set the text for the "previous" directionNav item
        nextText: '<i class="fas fa-angle-right"></i>',               //String: Set the text for the "next" directionNav item
    });
    jQuery('.sliderCont3').flexslider({
        animation: "fade",
        // Primary Controls
        controlNav: false,       //Boolean: Create navigation for paging control of each clide? Note: Leave true for manualControls usage
        directionNav: true,             //Boolean: Create navigation for previous/next navigation? (true/false)
        prevText: '<i class="fas fa-angle-left"></i>',           //String: Set the text for the "previous" directionNav item
        nextText: '<i class="fas fa-angle-right"></i>',               //String: Set the text for the "next" directionNav item
    })
});

/*---------------------arjun start--------------------------*/
// var scrollNum = 0;
// var currntTopPos = 150;
// $(window).scroll(function(){
//   $('#trigger').each(function(){
//     if(isScrolledIntoView($(this))){
//           $("#ring_sec").addClass("ab_visible");
//           $("#ring_sec").removeClass("ab_invisible");
//            var TopPosNew = currntTopPos - scrollNum++;
//           $("#ring_sec .diamond_j").css("top",-TopPosNew);
//     }
//     else
//     {
//                   $("#ring_sec").addClass("ab_invisible");
//                   $("#ring_sec").removeClass("ab_visible");
//     }
//   });
// });

// function isScrolledIntoView(elem){ 
//     var $elem = $(elem);
//     var $window = $(window);

//     var docViewTop = $window.scrollTop();
//     var docViewBottom = docViewTop + $window.height();

//     var elemTop = $elem.offset().top;
//     var elemBottom = elemTop + $elem.height();

//     return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));
// }

/*---------------------arjun end--------------------------*/

// var scrollNum = 0;
// var currntTopPos = 150;
// $(window).scroll(function(){
//   $('#trigger').each(function(){
//     if(isScrolledIntoView($(this))){
//           $("#ring_sec").addClass("ab_visible");
//           $("#ring_sec").removeClass("ab_invisible");
           
//     }
//     else
//     {
//                   $("#ring_sec").addClass("ab_invisible");
//                   $("#ring_sec").removeClass("ab_visible");
//     }
//   });
// });

// function isScrolledIntoView(elem){ 
//     var $elem = $(elem);
//     var $window = $(window);

//     var docViewTop = $window.scrollTop();
//     var docViewBottom = docViewTop + $window.height();

//     var elemTop = $elem.offset().top;
//     var elemBottom = elemTop + $elem.height();

//     return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));
// }



// $(document).scroll(function() {
//   var span = $('.diamond_j'),
//     div = $('.diamond_j_cont'),
//     spanHeight = span.outerHeight(),
//     divHeight = div.height(),
//     spanOffset = span.offset().top + spanHeight,
//     divOffset = div.offset().top + divHeight;

//   if (spanOffset >= divOffset) {
//     span.addClass('bottom-new');
//     var windowScroll = $(window).scrollTop() + $(window).height() - 50;
//     if (spanOffset > windowScroll) {
//       span.removeClass('bottom-new');
//     }
//   }
// });

if ($('#back-to-top').length) {
    var scrollTrigger = 100, // px
        backToTop = function () {
            var scrollTop = $(window).scrollTop();
            if (scrollTop > scrollTrigger) {
                $('#back-to-top').addClass('show');
            } else {
                $('#back-to-top').removeClass('show');
            }
        };
    backToTop();
    $(window).on('scroll', function () {
        backToTop();
    });
    $('#back-to-top').on('click', function (e) {
        e.preventDefault();
        $('html,body').animate({
            scrollTop: 0
        }, 700);
    });
}