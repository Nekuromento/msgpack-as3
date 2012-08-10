package net.messagepack {
    import flash.utils.ByteArray;

    public interface IConvertableToMessagePack {
        function toMessagePack(bytes : ByteArray) : void;
    }
}
