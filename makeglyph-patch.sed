/load("engine\/polygon.js");/i \
load("engine/2d.js");
/kage = new Kage();/ a \
\
if (arguments === undefined) {\
  if (scriptArgs !== undefined) { // workaround for newer mozjs\
    var arguments = scriptArgs;\
  }\
}
/if(arguments\[2\] == "gothic"){/c \
if(arguments[2] == "socho"){\
  kage.kShotai = kage.kSocho;\
}else if(arguments[2] == "gothic"){
/if(arguments\[3\] == 1){/ {
n
a \
  kage.kMinWidthU = 1;
}
/} else if(arguments\[3\] == 5){/ {
i \
} else if(arguments[3] == 4){\
  kage.kMinWidthY = 2.5;\
  kage.kMinWidthU = 2.5;\
  kage.kMinWidthT = 7;\
  kage.kWidth = 6;\
  kage.kKakato = 2.5;\
  kage.kMage = 11.5;
n
a \
  kage.kMinWidthU = 3;
}
/} else if(arguments\[3\] == 7){/ {
i \
  kage.kMage = 13;\
  kage.kAdjustTateStep = 5;\
  kage.kAdjustMageStep = 6;
n
a \
  kage.kMinWidthU = 4;
}
/  kage.kKakato = 1;/ {
a \
  kage.kMage = 17;\
  kage.kAdjustTateStep = 6;\
  kage.kAdjustMageStep = 7;
n
n
a \
  kage.kMinWidthU = 2;
}
