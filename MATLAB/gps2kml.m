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



for datacounter = 1 : 50 : size(LatLnt, 2)
  PlacemarkNode = docNode.createElement('Placemark');
  
    PMNameNode = docNode.createElement('name');
    PMNameNode.appendChild(docNode.createTextNode(...
              sprintf('name for point')));
    PMDesNode = docNode.createElement('description');
    PMDesNode.appendChild(docNode.createTextNode(...
              sprintf('description for point')));
  
    PointNode = docNode.createElement('Point');
    
      extrudeModeNode = docNode.createElement('extrude');
      extrudeModeNode.appendChild(docNode.createTextNode(...
              sprintf('1')));
      PointNode.appendChild(extrudeModeNode);
      
      altitudeModeNode = docNode.createElement('altitudeMode');
      altitudeModeNode.appendChild(docNode.createTextNode(...
              sprintf('relativeToGround')));
      PointNode.appendChild(altitudeModeNode);
      
      CoordinatesNode = docNode.createElement('coordinates');
      [lat, lnt] = nmea2degree(LatLnt{datacounter}{3}, LatLnt{datacounter}{4},...
                                LatLnt{datacounter}{5}, LatLnt{datacounter}{6});
      CoordinatesNode.appendChild(docNode.createTextNode(...
              sprintf('%f,%f,%f', lnt, lat, 0)));
    PointNode.appendChild(CoordinatesNode);
  
  PlacemarkNode.appendChild(PMNameNode);
  PlacemarkNode.appendChild(PMDesNode);
  PlacemarkNode.appendChild(PointNode);

  DocumentElement.appendChild(PlacemarkNode);
end

dateStamp = '20121221route42r1';
docNode.appendChild(docNode.createComment('this is a comment'));
xmlFileName = [kmlpath, 'gpsdata', dateStamp,'.kml'];
xmlwrite(xmlFileName,docNode);
%type(xmlFileName);
