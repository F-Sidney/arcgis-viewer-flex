function map_loadStreetClient(mapContext)
{
    var streetviewElement = document.getElementById(mapContext.streetviewElementId);
    var panorama;
    var streetClient;
    
    streetClient = new GStreetviewClient();
    mapContext.streetClient = streetClient;
    
    panorama = new GStreetviewPanorama(streetviewElement);
    mapContext.panorama = panorama;

    GEvent.addListener(panorama, "error", 
        function(errorCode)
        {
            map_panorama_error(errorCode, mapContext);
        });
    
    GEvent.addListener(panorama, "initialized",
        function(location)
        {
            map_panorama_initialized(location, mapContext);
        });
    
    GEvent.addListener(panorama, "yawchanged",
        function(newYaw)
        {
            map_panorama_yawchanged(newYaw, mapContext);
        });    

    if (mapContext.window)
    {
        GEvent.addListener(mapContext.window, "resize",
            function()
            {
                if (mapContext.panorama)
                {
                    mapContext.panorama.checkResize();
                }
            });
    }

    return streetClient;
}

function map_panorama_error(errorCode, mapContext)
{
    if (errorCode == GStreetviewPanorama.ErrorValues.FLASH_UNAVAILABLE)
    {
        alert("Your Flash player doesn't appear to support Google Streetview"); 
    }
    else if (errorCode == GStreetviewPanorama.ErrorValues.NO_NEARBY_PANO)
    {
        // maybe do something here?
    }
}

function map_panorama_yawchanged(yaw, mapContext)
{
    var gPoint;
    
    if (mapContext.panoramaLocation)
    {
        gPoint = mapContext.panoramaLocation.latlng;
        map_setMapObservationPoint(mapContext, gPoint, yaw);
    }
}

function map_panorama_initialized(location, mapContext)
{
    var gPoint = location.latlng;
    var yaw = location.pov.yaw;
    
    map_setMapObservationPoint(mapContext, gPoint, yaw);
    
    // remember location in case the POV changes
    mapContext.panoramaLocation = location;
}

function map_setMapObservationPoint(mapContext, gPoint, yaw)
{
    var x;
    var y;

    // The host page is reponsible for defining the setMapObservationPoint() method
    if (mapContext.setMapObservationPoint)
    {
        x = gPoint.x;
        y = gPoint.y;
        
        mapContext.setMapObservationPoint(x, y, yaw);
    }
}

function map_streetClient_gotNearestPanorama(streetviewData, mapContext)
{
    var gPoint;
    var gPov;
    var yaw;
    var panorama = mapContext.panorama;
    
    if (streetviewData.code != 200)
    {
        // error setting panorma observation point
    }
    else
    {
        gPoint = streetviewData.location.latlng;
        gPov = streetviewData.location.pov;
        yaw = gPov.yaw;
        panorama.setLocationAndPOV(gPoint, gPov);
        mapContext.panoramaLocation = streetviewData.location;
        
        // adjust the map to show the panorama point
        map_setMapObservationPoint(mapContext, gPoint, yaw);
    }
}

function map_setStreetviewObservationPoint(mapContext, streetClient, x, y, yaw)
{
    var gPoint = new GLatLng(y, x);
    
    if (streetClient)
    {
        streetClient.getNearestPanorama(gPoint, 
            function(streetviewData)
            {
                map_streetClient_gotNearestPanorama(streetviewData, mapContext);
            });
    }
}
