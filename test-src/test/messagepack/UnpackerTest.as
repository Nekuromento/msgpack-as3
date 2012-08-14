package test.messagepack {
    import flexunit.framework.Assert;

    import net.messagepack.Packer;
    import net.messagepack.Unpacker;

    import flash.utils.ByteArray;

    public class UnpackerTest {
        [Test]
        public function testUniqueValues() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            packer.pack(null, true, false);

            bytes.position = 0;
            const unpacker : Unpacker = new Unpacker(bytes);
            Assert.assertEquals(unpacker.unpack(), null);
            Assert.assertEquals(unpacker.unpack(), true);
            Assert.assertEquals(unpacker.unpack(), false);
        }

        [Test]
        public function testUInt() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            packer.pack(0xFF, 0xFFFF, 0xFFFFFFFF);

            bytes.position = 0;
            const unpacker : Unpacker = new Unpacker(bytes);
            Assert.assertEquals(unpacker.unpack(), 0xFF);
            Assert.assertEquals(unpacker.unpack(), 0xFFFF);
            Assert.assertEquals(unpacker.unpack(), 0xFFFFFFFF);
        }

        [Test]
        public function testInt() : void {
            Assert.fail("Test unimplemented");
        }

        [Test]
        public function testNumber() : void {
            Assert.fail("Test unimplemented");
        }

        [Test]
        public function testArray() : void {
            Assert.fail("Test unimplemented");
        }

        [Test]
        public function testMap() : void {
            Assert.fail("Test unimplemented");
        }

        [Test]
        public function testRaw() : void {
            Assert.fail("Test unimplemented");
        }

        [Test]
        public function testObject() : void {
            Assert.fail("Test unimplemented");
        }
    }
}
