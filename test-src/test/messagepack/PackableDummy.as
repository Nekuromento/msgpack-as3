package test.messagepack {
    import net.messagepack.IConvertableToMessagePack;
    import net.messagepack.Packer;

    public class PackableDummy implements IConvertableToMessagePack {
        public const num : uint = uint.MAX_VALUE;

        public function toMessagePack(packer : Packer) : void {
            packer.packArray([num]);
        }
    }
}
