kmlpath = '../vis/';


docNode = com.mathworks.xml.XMLUtils.createDocument('kml')
docRootNode = docNode.getDocumentElement;
docRootNode.setAttribute('xmlns','http://www.opengis.net/kml/2.2');

DocumentElement = docNode.createElement('Document');
docRootNode.appendChild(DocumentElement);

DocNameNode = docNode.createElement('name');
DocNameNode.appendChild(docNode.createTextNode(sprintf('Data Set 1')));
DocumentElement.appendChild(DocNameNode);

DocDesNode = docNode.createElement('description');
DocDesNode.appendChild(docNode.createTextNode(sprintf('GPS Data visualization for Data set 1')));
DocumentElement.appendChild(DocDesNode);

PlacemarkNode = docNode.createElement('Placemark');
DocumentElement.appendChild(PlacemarkNode);

PointNode = docNode.createElement('Point');
PlacemarkNode.appendChild(PointNode);

altitudeModeNode = docNode.createElement('altitudeMode');
altitudeModeNode.appendChild(docNode.createTextNode(...
        sprintf('relativeToGround')));
PointNode.appendChild(altitudeModeNode);

CoordinatesNode = docNode.createElement('coordinates');
datacounter = 345;
[lat, lnt] = nmea2degree(LatLnt{datacounter}{3}, LatLnt{datacounter}{4},...
                          LatLnt{datacounter}{5}, LatLnt{datacounter}{6});
CoordinatesNode.appendChild(docNode.createTextNode(...
        sprintf('%f,%f,%f', lnt, lat, 0)));
PointNode.appendChild(CoordinatesNode);

docNode.appendChild(docNode.createComment('this is a comment'));

xmlFileName = [kmlpath, 'gpsdata','.xml'];
xmlwrite(xmlFileName,docNode);
%type(xmlFileName);
