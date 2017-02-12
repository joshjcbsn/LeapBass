/******************************************************************************\
* Copyright (C) 2012-2016 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/
namespace Leap
{
    using LeapInternal;
    using System;
    using System.Runtime.InteropServices;

    /**
     * An enumeration defining the types of Leap Motion events.
     * @since 3.0
     */
    public enum LeapEvent
    {
        EVENT_CONNECTION,        //!< A connection event has occurred
        EVENT_CONNECTION_LOST,   //!< The connection with the service has been lost
        EVENT_DEVICE,            //!<  A device event has occurred
        EVENT_DEVICE_FAILURE,    //!< A device failure event has occurred
        EVENT_DEVICE_LOST,       //!< Event asserted when the underlying device object has been lost
        EVENT_POLICY_CHANGE,     //!< A change in policy occurred
        EVENT_CONFIG_RESPONSE,   //!< Response to a Config value request
        EVENT_CONFIG_CHANGE,     //!< Success response to a Config value change
        EVENT_FRAME,             //!< A tracking frame has been received
        EVENT_INTERNAL_FRAME,    //!< An internal tracking frame has been received
        EVENT_IMAGE,             //!< A requested image is available
        EVENT_IMAGE_REQUEST_FAILED, //!< A requested image could not be provided
        EVENT_DISTORTION_CHANGE, //!< The distortion matrix used for image correction has changed
        EVENT_LOG_EVENT,         //!< A diagnostic event has occured
        EVENT_INIT,
        EVENT_DROPPED_FRAME,
    };
    /**
     * A generic object with no arguments beyond the event type.
     * @since 3.0
     */
    public class LeapEventArgs : EventArgs
    {
        public LeapEventArgs(LeapEvent type)
        {
            this.type = type;
        }
        public LeapEvent type { get; set; }
    }

    /**
     * Dispatched when a tracking frame is ready.
     *
     * Provides the Frame object as an argument.
     * @since 3.0
     */
    public class FrameEventArgs : LeapEventArgs
    {
        public FrameEventArgs(Frame frame) : base(LeapEvent.EVENT_FRAME)
        {
            this.frame = frame;
        }

        public Frame frame { get; set; }
    }

    public class InternalFrameEventArgs : LeapEventArgs
    {
        public InternalFrameEventArgs(ref LEAP_TRACKING_EVENT frame) : base(LeapEvent.EVENT_INTERNAL_FRAME)
        {
            this.frame = frame;
        }

        public LEAP_TRACKING_EVENT frame { get; set; }
    }

    /**
     * Dispatched when a requested Image is ready.
     *
     * Provides the Image object as an argument.
     * @since 3.0
     */
    public class ImageEventArgs : LeapEventArgs
    {
        public ImageEventArgs(Image image) : base(LeapEvent.EVENT_IMAGE)
        {
            this.image = image;
        }

        public Image image { get; set; }
    }
    /**
     * Dispatched when a image request cannot be fulfilled.
     *
     * Provides the requested frame id and image type of the request that failed.
     * @since 3.0
     */
    public class ImageRequestFailedEventArgs : LeapEventArgs
    {
        public ImageRequestFailedEventArgs(Int64 frameId, Image.ImageType imageType) : base(LeapEvent.EVENT_IMAGE_REQUEST_FAILED)
        {
            this.frameId = frameId;
            this.imageType = imageType;
        }

        /**
         * Dispatched when a image request cannot be fulfilled.
         *
         * Provides the requested frame id and image type of the request that failed,
         * as well as the reason for the failure, and in the case of an insufficient
         * buffer, the required size of the image buffer.
         *
         * @since 3.0
         */
        public ImageRequestFailedEventArgs(Int64 frameId, Image.ImageType imageType,
                                              Image.RequestFailureReason reason,
                                              string message,
                                              Int64 requiredBufferSize
           ) : base(LeapEvent.EVENT_IMAGE_REQUEST_FAILED)
        {
            this.frameId = frameId;
            this.imageType = imageType;
            this.reason = reason;
            this.message = message;
            this.requiredBufferSize = requiredBufferSize;
        }

        public Int64 frameId { get; set; }
        public Image.ImageType imageType { get; set; }
        public Image.RequestFailureReason reason { get; set; }
        public string message { get; set; }
        public Int64 requiredBufferSize { get; set; }

    }

    /**
     * Dispatched when loggable events are generated by the service and the
     * service connection code.
     *
     * Provides the severity rating, log text, and timestamp as arguments.
     * @since 3.0
     */
    public class LogEventArgs : LeapEventArgs
    {
        public LogEventArgs(MessageSeverity severity, Int64 timestamp, string message) : base(LeapEvent.EVENT_LOG_EVENT)
        {
            this.severity = severity;
            this.message = message;
            this.timestamp = timestamp;
        }

        public MessageSeverity severity { get; set; }
        public Int64 timestamp { get; set; }
        public string message { get; set; }
    }

    /**
     * Dispatched when a policy change is complete.
     *
     * Provides the current and previous policies as arguments.
     *
     * @since 3.0
     */
    public class PolicyEventArgs : LeapEventArgs
    {
        public PolicyEventArgs(UInt64 currentPolicies, UInt64 oldPolicies) : base(LeapEvent.EVENT_POLICY_CHANGE)
        {
            this.currentPolicies = currentPolicies;
            this.oldPolicies = oldPolicies;
        }

        public UInt64 currentPolicies { get; set; }
        public UInt64 oldPolicies { get; set; }
    }

    /**
     * Dispatched when the image distortion map changes.
     *
     * Provides the new distortion map as an argument.
     * @since 3.0
     */
    public class DistortionEventArgs : LeapEventArgs
    {
        public DistortionEventArgs(DistortionData distortion) : base(LeapEvent.EVENT_DISTORTION_CHANGE)
        {
            this.distortion = distortion;
        }
        public DistortionData distortion { get; set; }
    }

    /**
     * Dispatched when a configuration change is completed.
     *
     * Provides the configuration key, whether the change was successful, and the id of the original change request.
     * @since 3.0
     */
    public class ConfigChangeEventArgs : LeapEventArgs
    {
        public ConfigChangeEventArgs(string config_key, bool succeeded, uint requestId) : base(LeapEvent.EVENT_CONFIG_CHANGE)
        {
            this.ConfigKey = config_key;
            this.Succeeded = succeeded;
            this.RequestId = requestId;
        }
        public string ConfigKey { get; set; }
        public bool Succeeded { get; set; }
        public uint RequestId { get; set; }

    }

    /**
     * Dispatched when a configuration change is completed.
     *
     * Provides the configuration key, whether the change was successful, and the id of the original change request.
     * @since 3.0
     */
    public class SetConfigResponseEventArgs : LeapEventArgs
    {
        public SetConfigResponseEventArgs(string config_key, Config.ValueType dataType, object value, uint requestId) : base(LeapEvent.EVENT_CONFIG_RESPONSE)
        {
            this.ConfigKey = config_key;
            this.DataType = dataType;
            this.Value = value;
            this.RequestId = requestId;
        }
        public string ConfigKey { get; set; }
        public Config.ValueType DataType { get; set; }
        public object Value { get; set; }
        public uint RequestId { get; set; }
    }

    /**
     * Dispatched when the connection is established.
     * @since 3.0
     */
    public class ConnectionEventArgs : LeapEventArgs
    {
        public ConnectionEventArgs() : base(LeapEvent.EVENT_CONNECTION) { }
    }

    /**
     * Dispatched when the connection is lost.
     * @since 3.0
     */
    public class ConnectionLostEventArgs : LeapEventArgs
    {
        public ConnectionLostEventArgs() : base(LeapEvent.EVENT_CONNECTION_LOST) { }
    }

    /**
     * Dispatched when a device is plugged in.
     *
     * Provides the device as an argument.
     * @since 3.0
     */
    public class DeviceEventArgs : LeapEventArgs
    {
        public DeviceEventArgs(Device device) : base(LeapEvent.EVENT_DEVICE)
        {
            this.Device = device;
        }
        public Device Device { get; set; }
    }

    /**
     * Dispatched when a device is plugged in, but fails to initialize or when
     * a working device fails in use.
     *
     * Provides the failure reason and, if available, the serial number.
     * @since 3.0
     */
    public class DeviceFailureEventArgs : LeapEventArgs
    {
        public DeviceFailureEventArgs(uint code, string message, string serial) : base(LeapEvent.EVENT_DEVICE_FAILURE)
        {
            ErrorCode = code;
            ErrorMessage = message;
            DeviceSerialNumber = serial;
        }

        public uint ErrorCode { get; set; }
        public string ErrorMessage { get; set; }
        public string DeviceSerialNumber { get; set; }
    }

    public class DroppedFrameEventArgs : LeapEventArgs
    {
        public DroppedFrameEventArgs(Int64 frame_id, eLeapDroppedFrameType type) : base(LeapEvent.EVENT_DROPPED_FRAME)
        {
            frameID = frame_id;
            reason = type;
        }

        public Int64 frameID { get; set; }
        public eLeapDroppedFrameType reason { get; set; }
    }
}
