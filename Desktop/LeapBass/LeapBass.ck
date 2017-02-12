OscRecv orec;
55555 => orec.port;
orec.listen();
orec.event("/active, i, i, i, i" ) @=> OscEvent myActiveOsc;
orec.event("/test, s") @=> OscEvent myTestOsc;
//orec.event("/RightPalmPosition, fff") @=> OscEvent myRightPalmPosition;
orec.event("/RightPalmPosition, s") @=> OscEvent myRightPalmPosition;
orec.event("/LeftPalmPosition, s") @=> OscEvent myLeftPalmPosition;

<<<"waiting">>>;
Gain g => dac;
.5 => g.gain;
6 => int x;
200 => float filterFreq;
100 => float oscFreq;
while (true)
{
    myRightPalmPosition => now;
    myRightPalmPosition.getString() => string str;
    myRightPalmPosition.getString() => string strR;
    <<<strR>>>;
   // myRightPalmPosition.getFloat() => float xR;
  // myRightPalmPosition.getFloat() => float yR;
   // myRightPalmPosition.getFloat() => float zR;
   // <<<xR, yR, zR>>>;
    myLeftPalmPosition => now;
    //myLeftPalmPosition.getFloat() => float xL;
   // myLeftPalmPosition.getFloat() => float yL;
   // myLeftPalmPosition.getFloat() => float zL;
 //   <<<xL, yL, zL>>>;
    //rh left/right -> freq
    //rh up/down -> timbre
    //rh back/forth -> timbre
    //rh fingers spread/together -> detune
    //rh fingers open/closed -> volume
    
    //lh left/right -> filter freq
    //lh up/down -> filter bump
    //lh back forth -> reverb
    //lh open/closed -> filter q
    //lh fingers spread/together -> delay? just get it cuz why not
    
    //myActiveOsc.getInt() => int activeHands;
    //myActiveOsc.getInt() => int activeFingers;
   // myActiveOsc.getInt() => int activeTools; 
   // myActiveOsc.getInt() => int activeOrigins;
   // <<<activeHands>>>;
   // <<<activeFingers>>>;
    //orec.getInt() => int i;
    //orec.getFloat() => float f;
   // orec.getString() => string s;
    LPF filt => g;
    filterFreq => filt.freq;
    
    
   // 0 => float sineGain;
   // SinOsc sine => filt;
   // sineGain => sine.gain;
   // oscFreq => sine.freq;
    
    .5 => float sqrGain;
    SqrOsc sqr => filt;
    oscFreq => sqr.freq;
    sqrGain => sqr.gain;
    
  //  .5 => float triGain;
   // TriOsc tri => filt;
   // oscFreq => tri.freq;
  //  sqrGain => tri.gain;
    
   // .5 => float sawGain;
   // SawOsc saw => filt;
   // oscFreq => saw.freq;
   // sqrGain => saw.gain;
    
    10::ms => now;
   
    
    1 -=> x;
    30 -=> filterFreq;
   // sine =< filt;
    sqr =< filt;
   // tri =< filt;
   // saw =< filt;
}
