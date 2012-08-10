package net.messagepack {
    import flash.utils.ByteArray;

    public interface IConvertableFromMessagePack {
        function fromMessagePack(bytes : ByteArray) : void;
    }
}
