package net.messagepack {
    public final class MessagePackTag {
        public static const UINT8 : uint = 0xCC;
        public static const UINT16 : uint = 0xCD;
        public static const UINT32 : uint = 0xCE;
        public static const UINT64 : uint = 0xCF;

        public static const INT8 : uint = 0xD0;
        public static const INT16 : uint = 0xD1;
        public static const INT32 : uint = 0xD2;
        public static const INT64 : uint = 0xD3;

        public static const FLOAT : uint = 0xCA;
        public static const DOUBLE : uint = 0xCB;

        public static const RAW : uint = 0xA0;
        public static const RAW16 : uint = 0xDA;
        public static const RAW32 : uint = 0xDB;

        public static const ARRAY : uint = 0x90;
        public static const ARRAY16 : uint = 0xDC;
        public static const ARRAY32 : uint = 0xDD;

        public static const MAP : uint = 0xA0;
        public static const MAP16 : uint = 0xDE;
        public static const MAP32 : uint = 0xDF;

        public static const NIL : uint = 0xC0;
        public static const TRUE : uint = 0xC3;
        public static const FALSE : uint = 0xC2;
    }
}
