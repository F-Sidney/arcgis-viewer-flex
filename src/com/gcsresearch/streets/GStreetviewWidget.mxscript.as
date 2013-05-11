import mx.controls.Alert;

import flash.external.ExternalInterface;

import mx.collections.ArrayCollection;

import com.esri.ags.Graphic;
import com.esri.ags.SpatialReference;
import com.esri.ags.geometry.Geometry;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.layers.GraphicsLayer;
import com.esri.ags.symbols.Symbol;
import com.esri.ags.symbols.CompositeSymbol;
import com.esri.ags.symbols.MarkerSymbol;
import com.esri.ags.symbols.PictureMarkerSymbol;
import com.esri.ags.symbols.SimpleMarkerSymbol;
import com.esri.ags.events.DrawEvent;
import com.esri.ags.tools.DrawTool;
import com.esri.ags.utils.WebMercatorUtil;

private var isInitialized : Boolean = false;

private function configLoaded()
: void
{
    var iconUrl : String = trackerLayer.trackerSymbolIconUrl;
    var iconWidth : Number = trackerLayer.trackerSymbolIconWidth;
    var iconHeight : Number = trackerLayer.trackerSymbolIconHeight;
    
    if (configXML)
    {
        pointLabel = configXML.labels.pointlabel || pointLabel;
        iconUrl = configXML.icons.trackerIcon.@url || iconUrl;
        iconWidth = configXML.icons.trackerIcon.@width || iconWidth;
        iconHeight = configXML.icons.trackerIcon.@height || iconHeight;
        
        activateStreetviewImage.source = iconUrl;
        trackerLayer.trackerSymbolIconUrl = iconUrl;
        trackerLayer.trackerSymbolIconWidth = iconWidth;
        trackerLayer.trackerSymbolIconHeight = iconHeight;
    }
    
    init();    
}

private function init()
: void
{
    if (!isInitialized)
    {
        map.addLayer(trackerLayer);
        
        isInitialized = true;
    }
}

private function widgetOpenedHandler(event:Event)
: void
{
    trackerLayer.visible = true;
    setMapAction(DrawTool.MAPPOINT, pointLabel, null, pointClicked);;        
}

private function widgetClosedHandler(event:Event)
: void
{
    setMapNavigation(null, null);
}

private function activatePointerTool()
: void
{
    clickEffect.play();
    setMapAction(DrawTool.MAPPOINT, pointLabel, null, pointClicked);
}

private function pointClicked(event:DrawEvent)
: void
{
    var graphic : Graphic = event.graphic;
    var pointGeometry : Geometry = graphic.geometry;
    var point : MapPoint;
    
    point = WebMercatorUtil.webMercatorToGeographic( pointGeometry ) as MapPoint;
    if (point)
    {
        trackerLayer.executeMoveRequest(point);
    }
}

