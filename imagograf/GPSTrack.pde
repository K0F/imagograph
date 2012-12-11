
class GPSTrack {
  String filename;
  ArrayList <TrackPoint> pnts;
  float minlat, maxlat, minlon, maxlon, minele, maxele;


  PApplet parent;

  GPSTrack(PApplet _parent, String _filename) {
    parent = _parent;
    filename = _filename;

    pnts = new ArrayList();
    XMLElement tmp = new XMLElement(parent, filename);
    suckvals(tmp);
    minMax();
    scaleToCartesian();
  }

  void plot() {
    stroke(255);
    noFill();
    beginShape();
    for (int i = 0 ; i < pnts.size();i++) {
      TrackPoint tmp = (TrackPoint)pnts.get(i);
      tmp.plot();
    }
    endShape();
  }

  void minMax() {
    minlat = 10000;
    minlon = 10000;
    maxlat = -10000;
    maxlon = -10000;
    minele = 10000;
    maxele = -10000;

    for (int i = 0 ; i < pnts.size();i++) {
      TrackPoint tmp = (TrackPoint)pnts.get(i);
      minlat = min(tmp.lat, minlat);
      minlon = min(tmp.lon, minlon);

      maxlat = max(tmp.lat, maxlat);
      maxlon = max(tmp.lon, maxlon);
      
      minele = min(tmp.ele, minele);
      maxele = max(tmp.ele, maxele);
    
    }
  }

  void scaleToCartesian() {
    float x = (maxlat-minlat);
    float y = (maxlon-minlon);
    float z = (maxele-minele);

    if (debug)
      println("scaling from "+" x: "+x+" y: "+y+" z: "+z);


    for (int i = 0 ; i < pnts.size();i++) {
      TrackPoint tmp = (TrackPoint)pnts.get(i);
      float xx = map(tmp.lat, minlat, maxlat, 100, width-100);
      float yy = map(tmp.lon, minlon, maxlon, 100, height-100);
      float zz = map(tmp.ele, minele, maxele, -10, 10);
      
      tmp.pos = new PVector(xx, yy, zz);
    }
  }

  void suckvals(XMLElement _tmp) {


    int len = _tmp.getChildCount();

    for (int i = 0; i < len; i++) {
      XMLElement kid = _tmp.getChild(i);
      if (kid.getContent()==null) {

        if (kid.getName().equals("trkpt")) {

          _lat = kid.getStringAttribute("lat");
          _lon = kid.getStringAttribute("lon");

          if (debug)
            println("New point @ "+_lat+" "+_lon);
          pnts.add(new TrackPoint(_lon, _lat));
          suckvals(kid);
        }
        else {
          suckvals(kid);
        }
      }
      else {
        if (pnts.size()>0) {
          TrackPoint last = (TrackPoint)pnts.get(pnts.size()-1);

          // println(kid.getName()+" "+kid.getContent());
          if (kid.getName().equals("name"))
            last.setName(kid.getContent());

          if (kid.getName().equals("ele"))
            last.setEle(parseFloat(kid.getContent()));

          if (kid.getName().equals("time"))
            last.setTime(kid.getContent());
        }
      }//else
    }//for
  }//suckvals
}//class

