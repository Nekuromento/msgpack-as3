package net.messagepack {
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
    }
}
