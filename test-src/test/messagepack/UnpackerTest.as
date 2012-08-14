package test.messagepack {
    import net.messagepack.Packer;
    import net.messagepack.Unpacker;

    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.nullValue;
    import org.hamcrest.object.strictlyEqualTo;

    import flash.utils.ByteArray;

    public class UnpackerTest {
        [Test]
        public function testUniqueValues() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            packer.pack(null, true, false);

            bytes.position = 0;
            const unpacker : Unpacker = new Unpacker(bytes);
            assertThat(unpacker.unpack(), nullValue());
            assertThat(unpacker.unpack(), strictlyEqualTo(true));
            assertThat(unpacker.unpack(), strictlyEqualTo(false));
        }

        [Test]
        public function testUInt() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            packer.pack(0xFF, 0xFFFF, 0xFFFFFFFF);

            bytes.position = 0;
            const unpacker : Unpacker = new Unpacker(bytes);
            assertThat(unpacker.unpack(), equalTo(0xFF));
            assertThat(unpacker.unpack(), equalTo(0xFFFF));
            assertThat(unpacker.unpack(), equalTo(0xFFFFFFFF));
        }

        [Test]
        public function testInt() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            packer.pack(-128, -32768, int.MIN_VALUE);

            bytes.position = 0;
            const unpacker : Unpacker = new Unpacker(bytes);
            assertThat(unpacker.unpack(), equalTo(-128));
            assertThat(unpacker.unpack(), equalTo(-32768));
            assertThat(unpacker.unpack(), equalTo(int.MIN_VALUE));
        }

        [Test]
        public function testNumber() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            packer.pack(Number.MAX_VALUE, Number.MIN_VALUE);

            bytes.position = 0;
            const unpacker : Unpacker = new Unpacker(bytes);
            assertThat(unpacker.unpack(), equalTo(Number.MAX_VALUE));
            assertThat(unpacker.unpack(), equalTo(Number.MIN_VALUE));
        }

        [Test]
        public function testArray() : void {
        }

        [Test]
        public function testMap() : void {
        }

        [Test]
        public function testRaw() : void {
        }

        [Test]
        public function testObject() : void {
        }
    }
}
