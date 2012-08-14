package net.messagepack {
    import com.adobe.utils.IntUtil;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    import flash.utils.IDataInput;

    /**
     * MessagePack binary data format packer implementation
     * 
     * This version was ported from D code
     * 
     * Copyright: Copyright Masahiro Nakagawa 2010- and Max Klyga 2012-.
     * License:   Boost License 1.0. For details see http://www.boost.org/LICENSE_1_0.txt
     * Authors:   Masahiro Nakagawa and Max Klyga
     */
    public final class Unpacker {
        private var _source : IDataInput;

        public function Unpacker(buffer : IDataInput) {
            _source = buffer;
            _source.endian = Endian.BIG_ENDIAN;
        }

        public function get buffer() : IDataInput {
            return _source;
        }

        public function unpack() : * {
            const header : uint = readHeader();
            switch (header) {
            case MessagePackTag.NIL:
                return null;
            case MessagePackTag.TRUE:
                return true;
            case MessagePackTag.FALSE:
                return false;
            case MessagePackTag.FLOAT:
            case MessagePackTag.DOUBLE:
                return unpackNumberImpl(header);
            case MessagePackTag.INT8:
            case MessagePackTag.INT16:
            case MessagePackTag.INT32:
            case MessagePackTag.INT64:
                return unpackIntImpl(header);
            case MessagePackTag.UINT8:
            case MessagePackTag.UINT16:
            case MessagePackTag.UINT32:
            case MessagePackTag.UINT64:
                return unpackUIntImpl(header);
            case MessagePackTag.ARRAY16:
            case MessagePackTag.ARRAY32:
                return unpackArrayImpl(header);
            case MessagePackTag.MAP16:
            case MessagePackTag.MAP32:
                return unpackDictImpl(header);
            case MessagePackTag.RAW16:
            case MessagePackTag.RAW32:
                return unpackRawImpl(header);
            }
            if ((header & 0x80) == 0)
                return header;
            if ((header & 0xE0) == 0xE0)
                return header & 0x1F;
            if ((header & 0xE0) == 0xA0)
                return unpackRawImpl(header);
            if ((header & 0xF0) == 0x90)
                return unpackArrayImpl(header);
            if ((header & 0xF0) == 0x80)
                return unpackDictImpl(header);
        }

        public function unpackString() : String {
            const header : uint = readHeader();
            if (header == MessagePackTag.NIL)
                return null;

            const length : uint = beginRawImpl(header);
            return _source.readUTFBytes(length);
        }

        public function beginRaw() : uint {
            const header : uint = readHeader();
            return beginRawImpl(header);
        }

        public function beginRawImpl(header : uint) : uint {
            _source.endian = Endian.BIG_ENDIAN;
            if (0xA0 <= header && header <= 0xBF) {
                return header & 0x1F;
            } else {
                switch (header) {
                case MessagePackTag.RAW16:
                    checkBytesAvaliable(2);
                    return _source.readUnsignedShort();
                case MessagePackTag.RAW32:
                    checkBytesAvaliable(4);
                    return _source.readUnsignedInt();
                case MessagePackTag.NIL:
                    break;
                default:
                    unexpectedHeader(header);
                }
            }
            return 0;
        }

        private function unpackRawImpl(header : uint, bytes : ByteArray = null) : ByteArray {
            if (header == MessagePackTag.NIL)
                return null;

            if (bytes == null)
                bytes = new ByteArray();

            const length : uint = beginRawImpl(header);
            for (var i : uint = 0; i < length; ++i)
                bytes.writeByte(_source.readByte());

            return bytes;
        }

        public function unpackRaw(bytes : ByteArray = null) : ByteArray {
            const header : uint = readHeader();
            return unpackRawImpl(header, bytes);
        }

        public function unpackObject(object : IConvertableFromMessagePack) : void {
            object.fromMessagePack(this);
        }

        public function unpackNull() : * {
            const header : uint = readHeader();
            if (header == MessagePackTag.NIL)
                return null;
            unexpectedHeader(header);
        }

        public function unpackBool() : Boolean {
            const header : uint = readHeader();
            switch (header) {
            case MessagePackTag.TRUE:
                return true;
            case MessagePackTag.FALSE:
                return false;
            default:
                unexpectedHeader(header);
            }
            return false;
        }
 
        private function unpackUIntImpl(header : uint) : uint {
            _source.endian = Endian.BIG_ENDIAN;
            if (header <= 0x7F) {
                return header;
            } else {
                switch (header) {
                case MessagePackTag.UINT8:
                    checkBytesAvaliable(1);
                    return _source.readUnsignedByte();
                case MessagePackTag.UINT16:
                    checkBytesAvaliable(2);
                    return _source.readUnsignedShort();
                case MessagePackTag.UINT32:
                    checkBytesAvaliable(4);
                    return _source.readUnsignedInt();
                case MessagePackTag.UINT64:
                    unsupportedType("unsigned int 64-bit");
                default:
                    unexpectedHeader(header);
                }
            }
            return 0;
        }

        public function unpackUInt() : uint {
            const header : uint = readHeader();
            return unpackUIntImpl(header);
        }

        private function unpackIntImpl(header : uint) : int {
            _source.endian = Endian.BIG_ENDIAN;
            if (header <= 0x7F) {
                return header;
            } else if (0xE0 <= header && header <= 0xFF) {
                return 0xFFFFFF00 & header;
            } else {
                switch (header) {
                case MessagePackTag.UINT8:
                    checkBytesAvaliable(1);
                    return _source.readUnsignedByte();
                case MessagePackTag.UINT16:
                    checkBytesAvaliable(2);
                    return _source.readUnsignedShort();
                case MessagePackTag.UINT32:
                    checkBytesAvaliable(4);
                    return _source.readUnsignedInt();
                case MessagePackTag.UINT64:
                    unsupportedType("unsigned int 64-bit");
                case MessagePackTag.INT8:
                    checkBytesAvaliable(1);
                    return _source.readByte();
                case MessagePackTag.INT16:
                    checkBytesAvaliable(2);
                    return _source.readShort();
                case MessagePackTag.INT32:
                    checkBytesAvaliable(4);
                    return _source.readInt();
                case MessagePackTag.INT64:
                    unsupportedType("int 64-bit");
                default:
                    unexpectedHeader(header);
                }
            }
            return 0;
        }

        public function unpackInt() : int {
            const header : uint = readHeader();
            return unpackIntImpl(header);
        }

        private function unpackNumberImpl(header : uint) : Number {
            _source.endian = Endian.BIG_ENDIAN;
            switch (header) {
            case MessagePackTag.FLOAT:
                checkBytesAvaliable(4);
                return _source.readFloat();
            case MessagePackTag.DOUBLE:
                checkBytesAvaliable(8);
                return _source.readDouble();
            default:
                unexpectedHeader(header);
            }
            return 0;
        }

        public function unpackNumber() : Number {
            const header : uint = readHeader();
            return unpackNumberImpl(header);
        }

        public function beginArray() : uint {
            const header : uint = readHeader();
            return beginArrayImpl(header);
        }

        private function beginArrayImpl(header : uint) : uint {
            _source.endian = Endian.BIG_ENDIAN;
            if (0x90 <= header && header <= 0x9F) {
                return header & 0xF;
            } else {
                switch (header) {
                case MessagePackTag.ARRAY16:
                    checkBytesAvaliable(2);
                    return _source.readUnsignedShort();
                case MessagePackTag.ARRAY32:
                    checkBytesAvaliable(4);
                    return _source.readUnsignedInt();
                case MessagePackTag.NIL:
                    break;
                default:
                    unexpectedHeader(header);
                }
            }
            return 0;
        }

        private function unpackArrayImpl(header : uint, array : Array = null) : Array {
            if (header == MessagePackTag.NIL)
                return null;

            if (array == null)
                array = new Array();

            const length : uint = beginArrayImpl(header);
            array.length = length;
            for (var i : uint = 0; i < length; ++i)
                array[i] = unpack();

            return array;
        }

        public function unpackArray(array : Array = null) : Array {
            const header : uint = readHeader();
            return unpackArrayImpl(header, array);
        }

        public function beginMap() : uint {
            const header : uint = readHeader();
            return beginMapImpl(header);
        }

        private function beginMapImpl(header : uint) : uint {
            _source.endian = Endian.BIG_ENDIAN;
            if (0x80 <= header && header <= 0x8F) {
                return header & 0xF;
            } else {
                switch (header) {
                case MessagePackTag.MAP16:
                    checkBytesAvaliable(2);
                    return _source.readUnsignedShort();
                case MessagePackTag.MAP32:
                    checkBytesAvaliable(4);
                    return _source.readUnsignedInt();
                case MessagePackTag.NIL:
                    break;
                default:
                    unexpectedHeader(header);
                }
            }
            return 0;
        }

        private function unpackDictImpl(header : uint, dictionary : Dictionary = null) : Dictionary {
            if (header == MessagePackTag.NIL)
                return null;

            if (dictionary == null)
                dictionary = new Dictionary();

            const length : uint = beginMapImpl(header);
            for (var i : uint = 0; i < length; ++i) {
                const key : * = unpack();
                const value : * = unpack();
                dictionary[key] = value;
            }

            return dictionary;
        }

        public function unpackDict(dictionary : Dictionary = null) : Dictionary {
            const header : uint = readHeader();
            return unpackDictImpl(header, dictionary);
        }

        private function readHeader() : uint {
            checkBytesAvaliable(1);
            return _source.readUnsignedByte();
        }

        private function unsupportedType(type : String) : void {
            throw new MessagePackError("Unsupported data type: " + type);
        }

        private function checkBytesAvaliable(length : int) : void {
            if (_source.bytesAvailable < length)
                throw new MessagePackError("Insufficient buffer: was " + _source.bytesAvailable + " expected " + length);
        }

        private function unexpectedHeader(header : uint) : void {
            throw new MessagePackError("Unexpected header: " + IntUtil.toHex(header, true));
        }
    }
}
