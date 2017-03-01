/******************************************************************************\
* Copyright (C) Leap Motion, Inc. 2011-2016.                                   *
* Leap Motion proprietary. Licensed under Apache 2.0                           *
* Available at http://www.apache.org/licenses/LICENSE-2.0.html                 *
\******************************************************************************/

using UnityEngine;
using System.Collections;
using Leap;

namespace Leap.Unity{
  /** A physics finger model for our rigid hand made out of various cube Unity Colliders. */
  public class RigidFinger : SkeletalFinger {
  
    public float filtering = 0.5f;
  
    void Start() {
      for (int i = 0; i < bones.Length; ++i) {
        if (bones[i] != null) {
          bones[i].GetComponent<Rigidbody>().maxAngularVelocity = Mathf.Infinity;
        }
      }
    }
  
    public override void UpdateFinger(Chirality h, int f) {
       var sender = new SharpOSC.UDPSender("127.0.0.1", 55555);
       for (int i = 0; i < bones.Length; ++i) {
        if (bones[i] != null) {
          // Set bone dimensions.
          CapsuleCollider capsule = bones[i].GetComponent<CapsuleCollider>();
          if (capsule != null) {
            // Initialization
            capsule.direction = 2;
            bones[i].localScale = new Vector3(1f/transform.lossyScale.x, 1f/transform.lossyScale.y, 1f/transform.lossyScale.z);
  
            // Update
            capsule.radius = GetBoneWidth(i) / 2f;
            capsule.height = GetBoneLength(i) + GetBoneWidth(i);
          }
           
          Rigidbody boneBody = bones[i].GetComponent<Rigidbody>();
          Vector3 bonePos = GetBoneCenter(i);
          Quaternion boneRot = GetBoneRotation(i);
          if (boneBody) {
            boneBody.MovePosition(bonePos);
            boneBody.MoveRotation(boneRot);
          } else {
            bones[i].position = bonePos;
            bones[i].rotation = boneRot;
           
            }
            string msg = "/";
            if (h == Chirality.Right)
                msg += "Right";
            else
                msg += "Left";
            msg += f.ToString();
            msg += "Bone" + i.ToString();

            string msgPos = msg + "Pos";
            var oscPos = new SharpOSC.OscMessage(msgPos, bonePos.x, bonePos.y, bonePos.z);
            sender.Send(oscPos);
                    
            
            string msgRot = msg + "Rot";
            var oscRot = new SharpOSC.OscMessage(msgRot, boneRot.x, boneRot.y, boneRot.z, boneRot.w);
            var senderRot = new SharpOSC.UDPSender("127.0.0.1", 55555);
            sender.Send(oscRot);
            
        }
      }
    }
  }
}
