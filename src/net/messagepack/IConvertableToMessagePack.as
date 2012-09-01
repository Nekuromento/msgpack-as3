package net.messagepack {
    public interface IConvertableToMessagePack {
        function toMessagePack(packer : Packer) : void;
    }
}
