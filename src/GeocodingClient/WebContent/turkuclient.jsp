<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/ol3/3.15.1/ol.css" type="text/css"/>
<style >
		.map
		{
		margin:10px;
		}
</style>
<title>GeosmartCity Test Client</title>
  <script src="https://code.jquery.com/jquery-1.10.2.js"></script>
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/ol3/3.15.1/ol-debug.js"></script>
  <script src="http://cdnjs.cloudflare.com/ajax/libs/proj4js/2.3.14/proj4.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
</head>
<body>
   <div class="container">
      <div class="starter-template">
<h1>This is a test client for the Turku address REST Service</h1>
<form class="form-horizontal" role="form">
  <div class="form-group">
    <label class="control-label col-sm-2"  for="address">address:</label>
    <div class="col-sm-10">
    <input type="text" class="form-control" id="address" placeholder="Kannuskatu">
    </div>
  </div>
  <div class="form-group"> 
    <div class="col-sm-offset-2 col-sm-10">
  <button type="submit" class="btn btn-default" id="submit">Submit</button>
   </div>
  </div>
  
</form>
<div id="data"></div>

<div id="map" class="map"><div id="popup"></div></div>
</div>
</div>	

</body>
 <script type="text/javascript">
 $(document).ready(function(){
	 var map = new ol.Map({
	        layers: [new ol.layer.Tile({ source: new ol.source.OSM() })],
	        target: 'map',
	        view: new ol.View({
	          center: [0, 0],
	          zoom: 2
	        })
	      });
	 
	 
     var val = "";
     $("#submit").click(function(event){
	 
         event.preventDefault();
         var address = $('#address').val();

         $.ajax({
             type: "GET",
             data: {address:address},
             dataType:"json",
             url:  "http://hub.geosmartcity.eu/TurkuGeocoderServer/geo/RestService/getaddress",
             //url: "http://localhost:8080/TurkuGeocoderServer/geo/RestService/getaddress",
             success: function(results) {
                 //console.log("response:" + results);
                 $("#data").html('');
                 var items = [];
                var pointFeatures =[];
                 
                 $.each( results, function( object, value ) {
                	 
                	 var point;
                	 var name;
                	 var coor;
                	 var lon;
                	 var lat;
                	 $.each(value, function(key, val)
                       {  
                		if(key=='geometry')
                			 {
                			 	var json = $.parseJSON(val); 
                			 	lon = json.coordinates[0];
           			         	lat = json.coordinates[1];
                			 	items.push([lon,lat]);
                			 }
                		if(key=='address')
                			{
                				name = val;
                			}
                       });
                	pointFeatures.push([[lon,lat], name]);
                 });
                 var iconFeatures=[];
                 for(var i=0; i<pointFeatures.length; i++)
				 {
					var iconFeature = new ol.Feature({
					   geometry: new ol.geom.Point(ol.proj.transform(pointFeatures[i][0], 'EPSG:4326',     
					   'EPSG:3857')),
					   address: pointFeatures[i][1]
					 });
					 iconFeatures.push(iconFeature);
				 }
				 
				 
				 
				 var vectorSource = new ol.source.Vector({
				   features: iconFeatures //add an array of features
				 });

				 var iconStyle = new ol.style.Style({
				   image: new ol.style.Icon(/** @type {olx.style.IconOptions} */ ({
					 anchor: [0.5, 46],
					 anchorXUnits: 'fraction',
					 anchorYUnits: 'pixels',
					 opacity: 0.75,
					 src: 'http://findicons.com/files/icons/1030/windows_7/32/pin.png'
				   }))
				 });


				 var vectorLayer = new ol.layer.Vector({
				   source: vectorSource,
				   style: iconStyle
				 });
                 
                 
                 map.addLayer(vectorLayer);
                 var lon = items[0];
                 var lat = items[1];
                 var test = ol.proj.transform([items[0][0], items[0][1]],'EPSG:4326', 'EPSG:3857');
                 map.getView().setCenter(test);
                 map.getView().setZoom(14);
                 
                 
                 var element = document.getElementById('popup');

                 var popup = new ol.Overlay({
                   element: element,
                   positioning: 'bottom-center',
                   stopEvent: false
                 });
                 map.addOverlay(popup);

                 // display popup on click
                 map.on('click', function(evt) {
                   var feature = map.forEachFeatureAtPixel(evt.pixel,
                       function(feature) {
                         return feature;
                       });
                   if (feature) {
                     popup.setPosition(evt.coordinate);
                     $(element).popover({
                       'placement': 'top',
                       'html': true,
                       'content': feature.get('address')
                     });
                     $(element).popover('show');
                   } else {
                     $(element).popover('destroy');
                   }
                 });

                 
                 
             },
             error: function(jqXHR, textStatus, errorThrown) {
                 alert(' Error in processing! '+textStatus);
             }
         });
     });
 });

    </script>

</html>