// <mx:Script src="GStreetviewLayer.as"/>

import com.esri.ags.Graphic;
import com.esri.ags.SpatialReference;
import com.esri.ags.layers.GraphicsLayer;
import com.esri.ags.geometry.Geometry;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.symbols.Symbol;
import com.esri.ags.symbols.MarkerSymbol;
import com.esri.ags.symbols.PictureMarkerSymbol;

private var gcsWKID : Number = 4326;

private var _moveExternalViewerFunctionName : String = "";
private var _moveTrackerSymbolFunctionName : String = "";
private var _trackerSymbolIconUrl : String = "";
private var _trackerSymbolIconWidth : Number = 0;
private var _trackerSymbolIconHeight : Number = 0;
private var _trackerYaw : Number = 0;

//private var graphicsLayer : GraphicsLayer;

private function get graphicsLayer()
: GraphicsLayer
{
    return this;
}

public function get moveExternalViewerFunctionName()
: String
{
    return _moveExternalViewerFunctionName;
}

public function set moveExternalViewerFunctionName(functionName : String)
: void
{
    _moveExternalViewerFunctionName = functionName;
}

public function get moveTrackerSymbolFunctionName()
: String
{
    return _moveTrackerSymbolFunctionName;
}

public function set moveTrackerSymbolFunctionName(functionName : String)
: void
{
    // register our private implementation of the moveTrackerSymbol function
    //  with the host application
    ExternalInterface.addCallback(
                functionName,
                setMapObservationPoint);
    _moveTrackerSymbolFunctionName = functionName;
}

public function get trackerSymbolIconUrl()
: String
{
    return _trackerSymbolIconUrl;
}

public function set trackerSymbolIconUrl(url : String)
: void
{
    _trackerSymbolIconUrl = url;
}

public function set trackerSymbolIconPixels(pixelCount : Number)
: void
{
    trackerSymbolIconWidth = pixelCount;
    trackerSymbolIconHeight = pixelCount;
}

public function get trackerSymbolIconWidth()
: Number
{
    return _trackerSymbolIconWidth;
}

public function set trackerSymbolIconWidth(pixelCount : Number)
: void
{
    _trackerSymbolIconWidth = pixelCount;
}

public function get trackerSymbolIconHeight()
: Number
{
    return _trackerSymbolIconHeight;
}

public function set trackerSymbolIconHeight(pixelCount : Number)
: void
{
    _trackerSymbolIconHeight = pixelCount;
}

public function get trackerYaw()
: Number
{
    return _trackerYaw;
}

public function executeMoveRequest(point : MapPoint)
: void
{
    var x : Number;
    var y : Number;
    var yaw : Number = trackerYaw;
    
    x = point.x;
    y = point.y;
    
    requestMoveExternalViewer(x, y, yaw);
}


private function setMapObservationPoint(x:Number, y:Number, yaw:Number)
: void
{
    var graphic : Graphic;
    
    graphic = createMapObservationPointGraphic(x,y,yaw);
    
    graphicsLayer.clear();
    graphicsLayer.add(graphic);
    _trackerYaw = yaw;
}

private function requestMoveExternalViewer(x:Number, y:Number, yaw:Number)
: void
{
    var functionName : String = moveExternalViewerFunctionName;
    
    if (functionName)
    {
        ExternalInterface.call(
             functionName
            ,x
            ,y
            ,yaw)
    }
}


private function createMapObservationPointGraphic(x:Number, y:Number, yaw:Number)
: Graphic
{
    var graphicSymbol : Symbol;
    var graphicGeometry : Geometry;
    var graphic : Graphic;
    
    graphicSymbol = createMapObservationPointSymbol(x, y, yaw);
    graphicGeometry = new MapPoint(x, y, 
                        new SpatialReference(gcsWKID));
    graphic = new Graphic(graphicGeometry, graphicSymbol);
    
    return graphic;
}

private function createMapObservationPointSymbol(x:Number, y:Number, yaw:Number)
: Symbol
{
    var pictureSymbol : PictureMarkerSymbol;
    var graphicSymbol : Symbol;
    var radianYaw : Number;
    var degreeYX : Number;  // clockwise from x-axis
    var radianXY : Number;  // counterclockwise from x-axis
    var ySize : Number = trackerSymbolIconWidth;
    var xSize : Number = trackerSymbolIconHeight;
    var pictureSymbolUrl : String = trackerSymbolIconUrl;
    
    if (!pictureSymbolUrl)
    {
        graphicSymbol = graphicsLayer.symbol;
    }
    else
    {
        degreeYX = (270 + yaw) % 360;
        radianXY = Math.PI * ((450 - yaw) % 360) / 180.0;
        
        // This is a messy algorithm to keep the icon centered on a point; 
        //  it could use some refinement
        pictureSymbol = new PictureMarkerSymbol(pictureSymbolUrl, xSize, ySize);
        // The PictureMarkerSymbol constructor will not determine the width/height,
        //  so we require the client to tell us the width and height in advance
        //xSize = graphicSymbol.width;
        //ySize = graphicSymbol.height;
        pictureSymbol.angle = degreeYX;
        pictureSymbol.xoffset = (xSize/2) - (xSize/2) * Math.cos(radianXY - Math.PI/4);
        pictureSymbol.yoffset = -(ySize/2) - (ySize/2) * Math.sin(radianXY - Math.PI/4);
        
        graphicSymbol = pictureSymbol;
    }
    
    return graphicSymbol;
}

