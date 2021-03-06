Map {
  background-color: transparent;
}

#addresses[zoom<=18] {
  marker-width: 3;
  marker-fill: #00FF00;
  marker-line-color: #FFFFFF;
  marker-allow-overlap: true;
}
#addresses[zoom>=19] {
  text-name: [housenumber];
  text-face-name: 'Noto Sans CJK TC Regular';
  text-fill: #BBBBBB;
  text-size: 10;
  text-allow-overlap: true;
}
#addresses[zoom>=20] {
  text-size: 12;
}

#streets-poly {
  polygon-fill: #FAFFFF;
  polygon-opacity: 0.3;
  polygon-smooth: 0.3;
  line-color: #CCCCCC;
  text-name: [street];
  text-face-name: 'Noto Sans CJK TC Regular';
  text-size: 12;
  text-fill: #CCCCCC;
}
#streets-poly[zoom>=17] {
  text-placement-type: simple;
  text-placements: "N,S,E,W,NE,SE,NW,SW,16,14,12,10";
  text-size: 18;
  text-allow-overlap: true;
}
#streets-axis {
  line-width: 1;
  line-color: #333333;
  text-name: [street];
  text-face-name: 'Noto Sans CJK TC Regular';
  text-size: 14;
  text-fill: #222222;
  text-placement: line;
  text-allow-overlap: true;
}
