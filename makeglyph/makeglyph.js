// arguments ...  0:target_char_name 1:related_parts 2:shotai 3:weight
// shotai ... mincho or gothic
// weight ... 1 3 5 7

load("engine/2d.js");
load("engine/curve.js");
load("engine/polygon.js");
load("engine/polygons.js");
load("engine/buhin.js");
load("engine/kage.js");
load("engine/kagecd.js");
load("engine/kagedf.js");

kage = new Kage();

if (arguments === undefined) {
  if (scriptArgs !== undefined) { // workaround for newer mozjs
    var arguments = scriptArgs;
  }
}

if(arguments[2] == "socho"){
  kage.kShotai = kage.kSocho;
}else if(arguments[2] == "gothic"){
  kage.kShotai = kage.kGothic;
} else {
  kage.kShotai = kage.kMincho;
}

if(arguments[3] == 1){
  kage.kMinWidthY = 1;
  kage.kMinWidthU = 1;
  kage.kMinWidthT = 4;
  kage.kWidth = 3;
  kage.kKakato = 4;
} else if(arguments[3] == 4){
  kage.kMinWidthY = 2.5;
  kage.kMinWidthU = 2.5;
  kage.kMinWidthT = 7;
  kage.kWidth = 6;
  kage.kKakato = 2.5;
  kage.kMage = 11.5;
} else if(arguments[3] == 5){
  kage.kMinWidthY = 3;
  kage.kMinWidthU = 3;
  kage.kMinWidthT = 8;
  kage.kWidth = 7;
  kage.kKakato = 2;
  kage.kMage = 13;
  kage.kAdjustTateStep = 5;
  kage.kAdjustMageStep = 6;
} else if(arguments[3] == 7){
  kage.kMinWidthY = 4;
  kage.kMinWidthU = 4;
  kage.kMinWidthT = 10;
  kage.kWidth = 9;
  kage.kKakato = 1;
  kage.kMage = 17;
  kage.kAdjustTateStep = 6;
  kage.kAdjustMageStep = 7;
} else {
  kage.kMinWidthY = 2;
  kage.kMinWidthU = 2;
  kage.kMinWidthT = 6;
  kage.kWidth = 5;
  kage.kKakato = 3;
}

polygons = new Polygons();

target = (unescape(arguments[0]));
buhin = (unescape(arguments[1])).replace(/\r\n|\n/g, "\r").replace(/\+|\t/g, " ");

temp = buhin.split("\r");
for(i = 0; i < temp.length; i++){
  temp2 = temp[i].split(" ");
  kage.kBuhin.push(temp2[0], temp2[1]);
}

kage.makeGlyph(polygons, target);
print(polygons.generateSVG());
