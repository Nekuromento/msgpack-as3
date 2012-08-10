package net {
    import flash.utils.ByteArray;

    public interface IConvertableToMessagePack {
        function toMessagePack(bytes : ByteArray) : void;
    }
}
