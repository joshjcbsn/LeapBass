OscRecv orec;
55555 => orec.port;  
orec.listen();

orec.event("/RightHand, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f") @=> OscEvent myRightHand;
orec.event("/LeftHand, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f, f, f, f, f, f, f, f,f, f, f, f, f, f, f,f, f, f, f, f, f, f") @=> OscEvent myLeftHand;
<<<"waiting">>>;

15000 => float filterFreq;


// the patch
SndBuf buf => Envelope e => LPF filt => dac;
filterFreq => filt.freq;

// set up what to read
//me.arg( 0 )
me.sourceDir() + me.arg(0) => buf.read;

// variables and initial values
80 => float grain_duration; 
5.0 => float rand_grain_duration;
1 => float position; 
1.0 => float pitch;
0 => int rand_position;
0.0 => float rand_pitch;
0.0 => float pause;
.5 => float envelope_length;

// targets for ramping
float position_target;
1.0 => float pitch_target;
0 => float gain_target => buf.gain;

// number of samples in the buffer
int samples;
buf.samples() => samples;
grain_duration*0.5::ms => e.duration;

fun void grain()
{ 
    // can be changed to acheive a more varying
    // asynchronous envelope for each grain duration
    0.0 => float grain_length;

    // go!
    while( true )
    {
        // compute grain length
        Std.rand2f( Math.max(1.0,grain_duration-rand_grain_duration),
                    grain_duration + rand_grain_duration) => grain_length;
        // compute grain duration for envelope
        grain_length*envelope_length::ms => e.duration;
        // set buffer playback rate
        Std.rand2f( Math.max(0.0625, pitch-rand_pitch), pitch+rand_pitch ) => buf.rate;
        // set buffer position
        Std.rand2( Math.max(1,position-rand_position) $ int,
                   Math.min(samples,position+rand_position) $ int ) => buf.pos;

        // enable envelope
        e.keyOn();
        // wait for rise
        grain_length*envelope_length::ms => now;
        // close envelope
        e.keyOff();
        // wait
        grain_length*(1-envelope_length)::ms => now;

        // until next grain
        pause::ms => now;
    }
}

// position interpolation
fun void ramp_position()
{
    // compute rough threshold
    2.0 * (samples) $ float / 10.0 => float thresh;
    // choose slew
    0.005 => float slew;

    // go
    while( true )
    {
        // really far away from target?
        if( Std.fabs(position - position_target) > samples / 5 )
        {
            1.0 => slew;
        }
        else
        {
            0.005 => slew;
        }

        // slew towards position
        ( (position_target - position) * slew + position ) $ int => position;

        // wait time
        1::ms => now;
    }
}

// pitch interpolation
fun void ramp_pitch()
{
    // the slew
    0.005 => float slew;
    // go
    while( true )
    {
        // slew
        ((pitch_target - pitch) * slew + pitch) => pitch;
        // wait
        5::ms => now;
    }
}

// volume interpolation
fun void ramp_gain()
{   
    // the slew
    0.05 => float slew;
    // go
    while( true )
    {
        // slew
        ( (gain_target - buf.gain()) * slew + buf.gain() ) => buf.gain;
        // wait
        10::ms => now;
    }
}

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
    (Std.fabs(xR) + .1) * (1 / (1 + rightRot[2])) => pitch;
    //<<<oscFreq>>>;
    Std.fabs(yR) * 3 => float g;// => buf.gain();
    if (g > 1)
    {  
        1 => g;
    }
    (Std.fabs(zR) + .25) * samples => position_target; 
   
   // getJointPos(rightHand, 0, 3) @=> float p[];
  //  <<<p[0], p[1], p[2]>>>;
   // getDistance(getJointPos(rightHand, 0, 3), getJointPos(rightHand, 1, 3)) => float d1;
   // getDistance(getJointPos(rightHand, 0, 3), getJointPos(rightHand, 2, 3)) => float d2;
   // getDistance(getJointPos(rightHand, 0, 3), getJointPos(rightHand, 3, 3)) => float d3;
    getDistance(getJointPos(rightHand, 0, 3), getJointPos(rightHand, 4, 3)) => float d4;
    //<<<d1, d2, d3, d4>>>;
    d4 * 1000 => grain_duration;
    
    getAngle(getPalmRot(rightHand), getJointRot(rightHand, 1, 3)) => float a;
    if (1-a < .1)
    {
        1 => a;
    }
    Std.fabs(1-a) * g => buf.gain;

}

fun void LeftHand(OscEvent myLeftHand)
{
    myLeftHand => now;
    getHand(myLeftHand) @=> float leftHand[];
    getPalmPos(leftHand) @=> float leftPalmPos[];
    leftPalmPos[0] => float xL;
    leftPalmPos[1] => float yL;
    leftPalmPos[2] => float zL;
    (.5 - (Std.fabs(xL))) => float mult;
    if (mult < 0)
    {
      .00001 => mult;  
    }
    getPalmRot(leftHand) @=> float leftRot[];
    mult * 15000 * (1 / (1 + leftRot[2])) => filterFreq;
  //  <<<filterFreq>>>;
    filterFreq => filt.freq;
    getAngle(getPalmRot(leftHand), getJointRot(leftHand, 1, 3)) => float a;
    if (a > 1)
    {
        1 => a; 
    }
    a => envelope_length;
    Math.pow(10, 5 * Std.fabs(yL)) => float q;
 //   <<<q>>>;
    q => filt.Q;
}


spork ~ grain();
spork ~ ramp_position();
spork ~ ramp_pitch();
spork ~ ramp_gain();
while (true)
{
   if (myRightHand.nextMsg() == 0)
   {
       0 => buf.gain;
   }
   else 
   {
      spork ~ RightHand(myRightHand);
      spork ~ LeftHand(myLeftHand);
       
   }
  // if (myLeftHand.nextMsg() == 0)
  // {
  //     15000 => filt.freq;
  //     .5 => filt.Q;
  // }
  // else
  // {
  //     spork ~ LeftHand(myLeftHand);
  // }
  // position_target + .01 => position_target;
  //  gain_target + .01 => gain_target;
   
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
    
    40::ms => now;
   
    
  //  30 -=> filterFreq;
   // sine =< filt;
   // tri =< filt;
   // saw =< filt;
}
