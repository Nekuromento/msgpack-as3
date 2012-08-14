package test.messagepack {
    import net.messagepack.IConvertableFromMessagePack;
    import net.messagepack.IConvertableToMessagePack;
    import net.messagepack.Packer;
    import net.messagepack.Unpacker;

    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;

    public class Dummy implements IConvertableToMessagePack, IConvertableFromMessagePack {
        public var num : uint = uint.MAX_VALUE;

        public function toMessagePack(packer : Packer) : void {
            packer.packArray([num]);
        }

        public function fromMessagePack(unpacker : Unpacker) : void {
            assertThat(unpacker.beginArray(), equalTo(1));
            num = unpacker.unpack();
        }
    }
}
