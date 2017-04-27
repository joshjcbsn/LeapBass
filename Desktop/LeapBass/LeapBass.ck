OscRecv orec;
55555 => orec.port;  
orec.listen();

orec.event("/RightHand, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f") @=> OscEvent myRightHand;
orec.event("/LeftHand, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f") @=> OscEvent myLeftHand;
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

fun float[] getHand(OscEvent myHand)
{
    float hand[147];
    while (myHand.nextMsg() != 0)
    {
        for (0 => int i; i < 147; i++)
        {
            myHand.getFloat() => hand[i];
        }
    }
    return hand;
}

fun float[] getPalmPos(float hand[])
{
    float palmPos[3];
    hand[0] => palmPos[0];
    hand[1] => palmPos[1];
    hand[2] => palmPos[2];
    return palmPos;
}

fun float[] getPalmRot(float hand[])
{
    float palmRot[4];
    hand[3] => palmRot[0];
    hand[4] => palmRot[1];
    hand[5] => palmRot[2];
    hand[6] => palmRot[3];
    return palmRot;
}

fun float[] getJointPos(float hand[], int finger, int bone)
{
    
    7 + (finger * 28) + (bone * 7) => int start;
    <<<start>>>;
    float jointPos[3];
    hand[start] => jointPos[0];
    hand[start + 1] => jointPos[1];
    hand[start + 2] => jointPos[2];
    return jointPos;
}

fun float[] getJointRot(float hand[], int finger, int bone)
{
    10 + (finger * 28) + (bone * 7) => int start;
    float jointRot[4];
    hand[start] => jointRot[0];
    hand[start + 1] => jointRot[1];
    hand[start + 2] => jointRot[2];
    hand[start + 3] => jointRot[3];
    return jointRot;
}

fun float getDistance(float p1[], float p2[])
{
  //  <<<"p1", p1[0], p1[1], p1[2]>>>;
  //  <<<"p2", p2[0], p2[1], p2[2]>>>;
    p1[0] - p2[0] => float x;
    p1[1] - p2[1] => float y;
    p1[2] - p2[2] => float z;
    <<<x, y, z>>>;
    Math.pow(x, 2) + Math.pow(y, 2) + Math.pow(z, 2) => float c;
    <<<c>>>;
    
    Math.sqrt(c) => float d;
    <<<d>>>;
    return d;
}

fun float getAngle(float p1[], float p2[])
{
    p1[0] => float x1;
    p1[1] => float y1;
    p1[2] => float z1;
    p1[3] => float w1;
    p2[0] => float x2;
    p2[1] => float y2;
    p2[2] => float z2;
    p2[3] => float w2;
  //  <<<"p1 rot", x1, y1, z1, w1>>>;
  //  <<<"p2 rot", x2, y2, z2, w2>>>; 
    p1[0] - p2[0] => float x;
    p1[1] - p2[1] => float y;
    p1[2] - p2[2] => float z;
    Math.pow(x, 2) + Math.pow(y, 2) + Math.pow(z, 2) => float c;
    Math.sqrt(c) => float d;

    <<<d>>>;
    return d;
}


fun void RightHand(OscEvent myRightHand)
{
    myRightHand => now;
    getHand(myRightHand) @=> float rightHand[];
    getPalmPos(rightHand) @=> float rightPalmPos[];
   // <<< rightPalmPos[0], rightPalmPos[1], rightPalmPos[2]>>>;
    rightPalmPos[0] => float xR;
    rightPalmPos[1] => float yR;
    rightPalmPos[2] => float zR;
    getPalmRot(rightHand) @=> float rightRot[];
    (Std.fabs(xR) + .1) * 400 * (1 / (1 + rightRot[2])) => oscFreq;
    oscFreq => sqr.freq;
    oscFreq => sine.freq;
    oscFreq => saw.freq;
    //<<<oscFreq>>>;
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
   // getJointPos(rightHand, 0, 3) @=> float p[];
  //  <<<p[0], p[1], p[2]>>>;
    getDistance(getJointPos(rightHand, 0, 3), getJointPos(rightHand, 1, 3)) => float d1;
    getDistance(getJointPos(rightHand, 0, 3), getJointPos(rightHand, 2, 3)) => float d2;
    getDistance(getJointPos(rightHand, 0, 3), getJointPos(rightHand, 3, 3)) => float d3;
    getDistance(getJointPos(rightHand, 0, 3), getJointPos(rightHand, 4, 3)) => float d4;
    <<<d1, d2, d3, d4>>>;
    getDistance(getJointPos(rightHand, 1, 3), getJointPos(rightHand, 2, 3)) => float d5;
    if (d5 < .05)
    {
        0 => d5;
    }
    <<<"d5", d5>>>;
    getAngle(getPalmRot(rightHand), getJointRot(rightHand, 2, 3)) => float a;
    <<<a>>>;
    if (1-a < .1)
    {
        1 => a;
    }
    

}

fun void LeftHand(OscEvent myLeftHand, LPF filt)
{
    myLeftHand => now;
    getHand(myLeftHand) @=> float leftHand[];
    getPalmPos(leftHand) @=> float leftPalmPos[];
    leftPalmPos[0] => float xL;
    leftPalmPos[1] => float yL;
    leftPalmPos[2] => float zL;
    (.5 - (Std.fabs(xL))) * 10000 => filterFreq;
  //  <<<filterFreq>>>;
    filterFreq => filt.freq;
   
    Math.pow(10, 5 * Std.fabs(yL)) => float q;
 //   <<<q>>>;
    q => filt.Q;
}


fun void RightHand(OscEvent myRightHand)
{
    myRightHand => now;
    getHand(myRightHand) @=> float rightHand[];
    getPalmPos(rightHand) @=> float rightPalmPos[];      
    rightPalmPos[0] => float xR;
    rightPalmPos[1] => float yR;
    rightPalmPos[2] => float zR;
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


while (true)
{
    spork ~ RightHand(myRightHand, sine, sqr, saw);
    spork ~ LeftHand(myLeftHand, filt);
   // spork ~ RightPalmPos(myRightPalmPosition, sine, sqr, saw);
   // spork ~ LeftPalmPos(myLeftPalmPosition, filt);
   // spork ~ getRightPalmRot(myRightPalmRotation) @=> float rightRot[3];
   // <<<"right rot", rightRot[0], rightRot[1], rightRot[2]>>>;
   // spork ~ getLeftPalmRot(myLeftPalmRotation) @=> float leftRot[3];
   // <<<"left rot", leftRot[0], leftRot[1], leftRot[2]>>>;

    
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
    
    20::ms => now;
   
    
    1 -=> x;
  //  30 -=> filterFreq;
   // sine =< filt;
   // tri =< filt;
   // saw =< filt;
}
