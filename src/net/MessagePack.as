package net {
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
        private static const UINT8 : uint = 0xCC;
        private static const UINT16 : uint = 0xCD;
        private static const UINT32 : uint = 0xCE;
        private static const UINT64 : uint = 0xCF;

        private static const INT8 : uint = 0xD0;
        private static const INT16 : uint = 0xD1;
        private static const INT32 : uint = 0xD2;
        private static const INT64 : uint = 0xD3;

        private static const FLOAT : uint = 0xCA;
        private static const DOUBLE : uint = 0xCB;

        private static const RAW : uint = 0xA0;
        private static const RAW16 : uint = 0xDA;
        private static const RAW32 : uint = 0xDB;

        private static const ARRAY : uint = 0x90;
        private static const ARRAY16 : uint = 0xDC;
        private static const ARRAY32 : uint = 0xDD;

        private static const MAP : uint = 0xA0;
        private static const MAP16 : uint = 0xDE;
        private static const MAP32 : uint = 0xDF;

		private static const NULL : uint = 0xC0;
		private static const TRUE : uint = 0xC3;
		private static const FALSE : uint = 0xC2;

        public static function pack(...args) : ByteArray {
            const bytes : ByteArray = new ByteArray();
            bytes.endian = Endian.BIG_ENDIAN;
            for each (var arg : * in args)
                packImpl(arg, bytes);
            return bytes;
        }

		private static function packImpl(value : *, bytes : ByteArray) : void {
            if (value == null)
            	packNull(bytes);
            else if (value is Boolean)
            	packBool(value, bytes);
            else if (value is uint)
            	packUInt(value, bytes);
            else if (value is int)
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

        private static function packRaw(value : ByteArray, bytes : ByteArray) : void {
            const length : uint = value.length;
            if (length == 0) {
            	packNull(bytes);
                return;
            }

            bytes.endian = Endian.BIG_ENDIAN;
            if (length < 32) {
                //fixraw
                bytes.writeByte(RAW | length);
            } else if (length < (1 << 16)) {
                //raw 16
                bytes.writeByte(RAW16);
                bytes.writeByte(length >> 8);
                bytes.writeByte(length);
            } else {
                //raw 32
                bytes.writeByte(RAW32);
                bytes.writeByte(length >> 24);
                bytes.writeByte(length >> 16);
                bytes.writeByte(length >> 8);
                bytes.writeByte(length);
            }
            bytes.writeBytes(value);
        }

        private static function packString(value : String, bytes : ByteArray) : void {
			const utf : ByteArray = new ByteArray();
            utf.writeUTFBytes(value);
			packRaw(utf, bytes);
        }

        public static function packObject(value : IConvertableToMessagePack, bytes : ByteArray) : void {
            value.toMessagePack(bytes);
        }

        public static function packDict(value : Dictionary, bytes : ByteArray) : void {
            const keys : Array = DictionaryUtil.getKeys(value);
            const length : uint = keys.length;
            if (length == 0) {
            	packNull(bytes);
                return;
            }

			if (length < 16) {
                //fixmap
                bytes.writeByte(MAP | length);
            } else if (length < (1 << 16)) {
                //map 16
                bytes.writeByte(MAP16);
                bytes.writeByte(length >> 8);
                bytes.writeByte(length);
            } else {
                //map 32
                bytes.writeByte(MAP32);
                bytes.writeByte(length >> 24);
                bytes.writeByte(length >> 16);
                bytes.writeByte(length >> 8);
                bytes.writeByte(length);
            }

			for (var i : uint = 0; i < length; ++i) {
                packImpl(keys[i], bytes);
                packImpl(value[keys[i]], bytes);
            }
        }

        public static function packArray(value : Array, bytes : ByteArray) : void {
            const length : uint = value.length;
            if (length == 0) {
            	packNull(bytes);
                return;
            }

			if (length < 16) {
                //fixarray
                bytes.writeByte(ARRAY | length);
            } else if (length < (1 << 16)) {
                //array 16
                bytes.writeByte(ARRAY16);
                bytes.writeByte(length >> 8);
                bytes.writeByte(length);
            } else {
                //array 32
                bytes.writeByte(ARRAY32);
                bytes.writeByte(length >> 24);
                bytes.writeByte(length >> 16);
                bytes.writeByte(length >> 8);
                bytes.writeByte(length);
            }

			for each (var element : * in value)
            	packImpl(element, bytes);
        }

        public static function packNumber(value : Number, bytes : ByteArray) : void {
            bytes.endian = Endian.BIG_ENDIAN;
            bytes.writeByte(DOUBLE);
            bytes.writeDouble(value);
        }

        public static function packInt(value : int, bytes : ByteArray) : void {
            if (value < -(1 << 5)) {
                if (value < -(1 << 15)) {
                    //int 32
                    bytes.writeByte(INT32);
                    bytes.writeByte(value >> 24);
                    bytes.writeByte(value >> 16);
                    bytes.writeByte(value >> 8);
                    bytes.writeByte(value);
                } else if (value < -(1 << 7)) {
                    //int 16
                    bytes.writeByte(INT16);
                    bytes.writeByte(value >> 8);
                    bytes.writeByte(value);
                } else {
                    //uint 8
                    bytes.writeByte(INT8);
                    bytes.writeByte(value);
                }
            } else {
                packUInt(value, bytes);
            }
        }

        public static function packUInt(value : uint, bytes : ByteArray) : void {
            if (value < (1 << 8)) {
                if (value < (1 << 7)) {
                    //fixnum
                    bytes.writeByte(value);
                } else {
                    //uint 8
                    bytes.writeByte(UINT8);
                    bytes.writeByte(value);
                }
            } else {
                if (value < (1 << 16)) {
                    //uint 16
                    bytes.writeByte(UINT16);
                    bytes.writeByte(value >> 8);
                    bytes.writeByte(value);
                } else {
                    //uint 32
                    bytes.writeByte(UINT32);
                    bytes.writeByte(value >> 24);
                    bytes.writeByte(value >> 16);
                    bytes.writeByte(value >> 8);
                    bytes.writeByte(value);
                }
            }
        }

        public static function packBool(value : Boolean, bytes : ByteArray) : void {
            bytes.writeByte(value ? TRUE : FALSE);
        }

        public static function packNull(bytes : ByteArray) : void {
            bytes.writeByte(NULL);
        }	
    }
}
