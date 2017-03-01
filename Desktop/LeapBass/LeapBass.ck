OscRecv orec;
55555 => orec.port;
orec.listen();
//orec.event("/active, i, i, i, i" ) @=> OscEvent myActiveOsc;
//orec.event("/test, s") @=> OscEvent myTestOsc;
//orec.event("/RightPalmPosition, fff") @=> OscEvent myRightPalmPosition;
orec.event("/RightPalmPosition, f, f, f") @=> OscEvent myRightPalmPosition;
orec.event("/LeftPalmPosition, f, f, f") @=> OscEvent myLeftPalmPosition;

<<<"waiting">>>;
Gain g => dac;
.5 => g.gain;
6 => int x;
200 => float filterFreq;
LPF filt => g;
filterFreq => filt.freq;
    
 

100 => float oscFreq;
.5 => float sqrGain;
SqrOsc sqr => filt;
sqrGain => sqr.gain;

.5 => float sineGain;
SinOsc sine => filt;
sineGain => sine.gain;
oscFreq => sine.freq;

.5 => float sawGain;
SawOsc saw => filt;
oscFreq => saw.freq;
sawGain => saw.gain;

fun void RightPalmPos(OscEvent myRightPalmPosition, SinOsc sine, SqrOsc sqr, SawOsc saw)
{
    myRightPalmPosition => now;
    while(myRightPalmPosition.nextMsg() != 0){
        myRightPalmPosition.getFloat() => float xR;
        myRightPalmPosition.getFloat() => float yR;
        myRightPalmPosition.getFloat() => float zR;
        <<<xR, yR, zR>>>; 
        (Std.fabs(xR) + .1) * 400 => oscFreq;
        oscFreq => sqr.freq;
        oscFreq => sine.freq;
        oscFreq => saw.freq;
        <<<oscFreq>>>;
        yR + .5 => float gain;
        gain => sine.gain;
        
        (.25 - zR) * 2 => sqrGain;
        if (sqrGain < 0)
        {
            0 => sqrGain;
        }
        sqrGain => sqr.gain;
        (zR - .25) * 2 => sawGain;
        if (sawGain < 0)
        {
            0 => sawGain;
        }
        sawGain => saw.gain;
       

    } 
}

fun void LeftPalmPos(OscEvent myLeftPalmPosition, LPF filt)
{
    myLeftPalmPosition => now;
    while(myLeftPalmPosition.nextMsg() != 0){
        myLeftPalmPosition.getFloat() => float xL;
        myLeftPalmPosition.getFloat() => float yL;
        myLeftPalmPosition.getFloat() => float zL;
        (.5 - (Std.fabs(xL))) * 1000 => filterFreq;
        <<<filterFreq>>>;
        filterFreq => filt.freq;
        Math.pow(10, 5 * yL) => float q;
        <<<q>>>;
        q => filt.Q;
        
    }    
}

while (true)
{
    spork ~ RightPalmPos(myRightPalmPosition, sine, sqr, saw);
    spork ~ LeftPalmPos(myLeftPalmPosition, filt);
    
  //  myRightPalmPosition.getFloat() => float xR;
   // myRightPalmPosition.getFloat() => float yR;
   
    //myLeftPalmPosition => now;
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
    //lh fingers spread/together -> delay? filter shape?
    
    //myActiveOsc.getInt() => int activeHands;
    //myActiveOsc.getInt() => int activeFingers;
   // myActiveOsc.getInt() => int activeTools; 
   // myActiveOsc.getInt() => int activeOrigins;
   // <<<activeHands>>>;
   // <<<activeFingers>>>;
    //orec.getInt() => int i;
    //orec.getFloat() => float f;
   // orec.getString() => string s;

    
   // 0 => float sineGain;
   // SinOsc sine => filt;
   // sineGain => sine.gain;
   // oscFreq => sine.freq;
    
    
    
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
  //  30 -=> filterFreq;
   // sine =< filt;
   // tri =< filt;
   // saw =< filt;
}
