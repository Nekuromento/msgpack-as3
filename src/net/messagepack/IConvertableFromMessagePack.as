package net.messagepack {
    public interface IConvertableFromMessagePack {
        function fromMessagePack(unpacker : Unpacker) : void;
    }
}
