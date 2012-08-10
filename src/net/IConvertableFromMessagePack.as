package net {
    import flash.utils.ByteArray;

    public interface IConvertableFromMessagePack {
        function fromMessagePack(bytes : ByteArray) : void;
    }
}
