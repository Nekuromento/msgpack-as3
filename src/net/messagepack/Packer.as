package net.messagepack {
    import com.adobe.utils.DictionaryUtil;

    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    import flash.utils.IDataOutput;

    /**
     * MessagePack binary data format packer implementation
     * 
     * This version was ported from D code
     * 
     * Copyright: Copyright Masahiro Nakagawa 2010- and Max Klyga 2012-.
     * License:   Boost License 1.0. For details see http://www.boost.org/LICENSE_1_0.txt
     * Authors:   Masahiro Nakagawa and Max Klyga
     */
    public final class Packer {
        private var _sink : IDataOutput;

        public function Packer(buffer : IDataOutput) {
            _sink = buffer;
            _sink.endian = Endian.BIG_ENDIAN;
        }

        public function get buffer() : IDataOutput {
            return _sink;
        }

        public function pack(...args) : Packer {
            for each (var arg : * in args)
                packImpl(arg);
            return this;
        }

        private function packImpl(value : *) : void {
            if (value == null)
                packNull();
            else if (value is Boolean)
                packBool(value);
            else if (value is uint && value <= uint.MAX_VALUE && value >= uint.MIN_VALUE)
                packUInt(value);
            else if (value is int && value <= int.MAX_VALUE && value >= int.MIN_VALUE)
                packInt(value);
            else if (value is Number)
                packNumber(value);
            else if (value is String)
                packString(value);
            else if (value is Array)
                packArray(value);
            else if (value is Dictionary)
                packDict(value);
            else if (value is ByteArray)
                packRaw(value);
            else if (value is IConvertableToMessagePack)
                packObject(value);
            else
                throw MessagePackError("Unsupported type");
        }

        public function beginRaw(length : uint) : Packer {
            _sink.endian = Endian.BIG_ENDIAN;
            if (length < 32) {
                //fixraw
                _sink.writeByte(MessagePackTag.RAW | length);
            } else if (length < (1 << 16)) {
                //raw 16
                _sink.writeByte(MessagePackTag.RAW16);
                _sink.writeShort(length);
            } else {
                //raw 32
                _sink.writeByte(MessagePackTag.RAW32);
                _sink.writeUnsignedInt(length);
            }
            return this;
        }

        public function packRaw(value : ByteArray) : Packer {
            const length : uint = value.length;
            if (length == 0)
                return packNull();

            beginRaw(length);
            _sink.endian = Endian.BIG_ENDIAN;
            _sink.writeBytes(value);
            return this;
        }

        public function packString(value : String) : Packer {
            const utf : ByteArray = new ByteArray();
            utf.endian = Endian.BIG_ENDIAN;
            utf.writeUTFBytes(value);
            return packRaw(utf);
        }

        public function packObject(value : IConvertableToMessagePack) : Packer {
            value.toMessagePack(this);
            return this;
        }

        public function beginMap(length : uint) : Packer {
            _sink.endian = Endian.BIG_ENDIAN;
            if (length < 16) {
                //fixmap
                _sink.writeByte(MessagePackTag.MAP | length);
            } else if (length < (1 << 16)) {
                //map 16
                _sink.writeByte(MessagePackTag.MAP16);
                _sink.writeShort(length);
            } else {
                //map 32
                _sink.writeByte(MessagePackTag.MAP32);
                _sink.writeUnsignedInt(length);
            }
            return this;
        }

        public function packDict(value : Dictionary) : Packer {
            const keys : Array = DictionaryUtil.getKeys(value);
            const length : uint = keys.length;
            if (length == 0)
                return packNull();

            beginMap(length);
            for (var i : uint = 0; i < length; ++i) {
                packImpl(keys[i]);
                packImpl(value[keys[i]]);
            }
            return this;
        }

        public function beginArray(length : uint) : Packer {
            _sink.endian = Endian.BIG_ENDIAN;
            if (length < 16) {
                //fixarray
                _sink.writeByte(MessagePackTag.ARRAY | length);
            } else if (length < (1 << 16)) {
                //array 16
                _sink.writeByte(MessagePackTag.ARRAY16);
                _sink.writeShort(length);
            } else {
                //array 32
                _sink.writeByte(MessagePackTag.ARRAY32);
                _sink.writeUnsignedInt(length);
            }

            return this;
        }

        public function packArray(value : Array) : Packer {
            const length : uint = value.length;
            if (length == 0)
                return packNull();

            beginArray(length);
            for each (var element : * in value)
                packImpl(element);
            return this;
        }

        public function packNumber(value : Number) : Packer {
            _sink.endian = Endian.BIG_ENDIAN;
            _sink.writeByte(MessagePackTag.DOUBLE);
            _sink.writeDouble(value);
            return this;
        }

        public function packInt(value : int) : Packer {
            _sink.endian = Endian.BIG_ENDIAN;
            if (value < -(1 << 5)) {
                if (value < -(1 << 15)) {
                    //int 32
                    _sink.writeByte(MessagePackTag.INT32);
                    _sink.writeInt(value);
                } else if (value < -(1 << 7)) {
                    //int 16
                    _sink.writeByte(MessagePackTag.INT16);
                    _sink.writeShort(value);
                } else {
                    //uint 8
                    _sink.writeByte(MessagePackTag.INT8);
                    _sink.writeByte(value);
                }
            } else {
                packUInt(value);
            }
            return this;
        }

        public function packUInt(value : uint) : Packer {
            _sink.endian = Endian.BIG_ENDIAN;
            if (value < (1 << 8)) {
                if (value < (1 << 7)) {
                    //fixnum
                    _sink.writeByte(value);
                } else {
                    //uint 8
                    _sink.writeByte(MessagePackTag.UINT8);
                    _sink.writeByte(value);
                }
            } else {
                if (value < (1 << 16)) {
                    //uint 16
                    _sink.writeByte(MessagePackTag.UINT16);
                    _sink.writeShort(value);
                } else {
                    //uint 32
                    _sink.writeByte(MessagePackTag.UINT32);
                    _sink.writeUnsignedInt(value);
                }
            }
            return this;
        }

        public function packBool(value : Boolean) : Packer {
            _sink.writeByte(value ? MessagePackTag.TRUE : MessagePackTag.FALSE);
            return this;
        }

        public function packNull() : Packer {
            _sink.writeByte(MessagePackTag.NULL);
            return this;
        }    
    }
}
