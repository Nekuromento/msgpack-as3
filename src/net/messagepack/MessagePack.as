package net.messagepack {
    import com.adobe.utils.DictionaryUtil;

    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;

    /**
     * MessagePack binary data format implementation
     * 
     * This version was ported from D code
     * 
     * Copyright: Copyright Masahiro Nakagawa 2010- and Max Klyga 2012-.
     * License:   Boost License 1.0. For details see http://www.boost.org/LICENSE_1_0.txt
     * Authors:   Masahiro Nakagawa and Max Klyga
     */
    public final class MessagePack {
        public static function pack(...args) : ByteArray {
            const bytes : ByteArray = new ByteArray();
            bytes.endian = Endian.BIG_ENDIAN;
            for each (var arg : * in args)
                packImpl(arg, bytes);
            bytes.position = 0;
            return bytes;
        }

        private static function packImpl(value : *, bytes : ByteArray) : void {
            if (value == null)
                packNull(bytes);
            else if (value is Boolean)
                packBool(value, bytes);
            else if (value is uint && value <= uint.MAX_VALUE && value >= uint.MIN_VALUE)
                packUInt(value, bytes);
            else if (value is int && value <= int.MAX_VALUE && value >= int.MIN_VALUE)
                packInt(value, bytes);
            else if (value is Number)
                packNumber(value, bytes);
            else if (value is String)
                packString(value, bytes);
            else if (value is Array)
                packArray(value, bytes);
            else if (value is Dictionary)
                packDict(value, bytes);
            else if (value is ByteArray)
                packRaw(value, bytes);
            else if (value is IConvertableToMessagePack)
                packObject(value, bytes);
            else
                throw MessagePackError("Unsupported type");
        }

        public static function beginRaw(length : uint, bytes : ByteArray) : void {
            bytes.endian = Endian.BIG_ENDIAN;
            if (length < 32) {
                //fixraw
                bytes.writeByte(MessagePackTag.RAW | length);
            } else if (length < (1 << 16)) {
                //raw 16
                bytes.writeByte(MessagePackTag.RAW16);
                bytes.writeByte(length >> 8);
                bytes.writeByte(length);
            } else {
                //raw 32
                bytes.writeByte(MessagePackTag.RAW32);
                bytes.writeUnsignedInt(length);
            }
        }

        public static function packRaw(value : ByteArray, bytes : ByteArray) : void {
            const length : uint = value.length;
            if (length == 0) {
                packNull(bytes);
                return;
            }

            beginRaw(length, bytes);
            bytes.endian = Endian.BIG_ENDIAN;
            bytes.writeBytes(value);
        }

        public static function packString(value : String, bytes : ByteArray) : void {
            const utf : ByteArray = new ByteArray();
            utf.writeUTFBytes(value);
            packRaw(utf, bytes);
        }

        public static function packObject(value : IConvertableToMessagePack, bytes : ByteArray) : void {
            value.toMessagePack(bytes);
        }

        public static function beginMap(length : uint, bytes : ByteArray) : void {
            bytes.endian = Endian.BIG_ENDIAN;
            if (length < 16) {
                //fixmap
                bytes.writeByte(MessagePackTag.MAP | length);
            } else if (length < (1 << 16)) {
                //map 16
                bytes.writeByte(MessagePackTag.MAP16);
                bytes.writeByte(length >> 8);
                bytes.writeByte(length);
            } else {
                //map 32
                bytes.writeByte(MessagePackTag.MAP32);
                bytes.writeUnsignedInt(length);
            }
        }

        public static function packDict(value : Dictionary, bytes : ByteArray) : void {
            const keys : Array = DictionaryUtil.getKeys(value);
            const length : uint = keys.length;
            if (length == 0) {
                packNull(bytes);
                return;
            }

            beginMap(length, bytes);
            for (var i : uint = 0; i < length; ++i) {
                packImpl(keys[i], bytes);
                packImpl(value[keys[i]], bytes);
            }
        }

        public static function beginArray(length : uint, bytes : ByteArray) : void {
            bytes.endian = Endian.BIG_ENDIAN;
            if (length < 16) {
                //fixarray
                bytes.writeByte(MessagePackTag.ARRAY | length);
            } else if (length < (1 << 16)) {
                //array 16
                bytes.writeByte(MessagePackTag.ARRAY16);
                bytes.writeByte(length >> 8);
                bytes.writeByte(length);
            } else {
                //array 32
                bytes.writeByte(MessagePackTag.ARRAY32);
                bytes.writeUnsignedInt(length);
            }
        }

        public static function packArray(value : Array, bytes : ByteArray) : void {
            const length : uint = value.length;
            if (length == 0) {
                packNull(bytes);
                return;
            }

            beginArray(length, bytes);
            for each (var element : * in value)
                packImpl(element, bytes);
        }

        public static function packNumber(value : Number, bytes : ByteArray) : void {
            bytes.endian = Endian.BIG_ENDIAN;
            bytes.writeByte(MessagePackTag.DOUBLE);
            bytes.writeDouble(value);
        }

        public static function packInt(value : int, bytes : ByteArray) : void {
            bytes.endian = Endian.BIG_ENDIAN;
            if (value < -(1 << 5)) {
                if (value < -(1 << 15)) {
                    //int 32
                    bytes.writeByte(MessagePackTag.INT32);
                    bytes.writeInt(value);
                } else if (value < -(1 << 7)) {
                    //int 16
                    bytes.writeByte(MessagePackTag.INT16);
                    bytes.writeByte(value >> 8);
                    bytes.writeByte(value);
                } else {
                    //uint 8
                    bytes.writeByte(MessagePackTag.INT8);
                    bytes.writeByte(value);
                }
            } else {
                packUInt(value, bytes);
            }
        }

        public static function packUInt(value : uint, bytes : ByteArray) : void {
            bytes.endian = Endian.BIG_ENDIAN;
            if (value < (1 << 8)) {
                if (value < (1 << 7)) {
                    //fixnum
                    bytes.writeByte(value);
                } else {
                    //uint 8
                    bytes.writeByte(MessagePackTag.UINT8);
                    bytes.writeByte(value);
                }
            } else {
                if (value < (1 << 16)) {
                    //uint 16
                    bytes.writeByte(MessagePackTag.UINT16);
                    bytes.writeByte(value >> 8);
                    bytes.writeByte(value);
                } else {
                    //uint 32
                    bytes.writeByte(MessagePackTag.UINT32);
                    bytes.writeUnsignedInt(value);
                }
            }
        }

        public static function packBool(value : Boolean, bytes : ByteArray) : void {
            bytes.writeByte(value ? MessagePackTag.TRUE : MessagePackTag.FALSE);
        }

        public static function packNull(bytes : ByteArray) : void {
            bytes.writeByte(MessagePackTag.NULL);
        }    
    }
}
