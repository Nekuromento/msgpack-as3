package test.messagepack {
    import net.messagepack.MessagePackTag;
    import net.messagepack.Packer;

    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;

    import flash.utils.ByteArray;

    public class PackerTest {
        [Test]
        public function testUniqueValues() : void {
            const result : Array =
                [MessagePackTag.NIL, MessagePackTag.TRUE, MessagePackTag.FALSE];
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            packer.pack(null, true, false);
            assertThat(bytes.length , equalTo(result.length));
            for (var i : uint = 0; i < bytes.length; ++i)
                assertThat(bytes[i], equalTo(result[i]));
        }

        [Test]
        public function testUInt() : void {
            const masks : Array = [0xFF, 0xFFFF, 0xFFFFFFFF];
            const tests : Array = [[[MessagePackTag.UINT8, uint.MAX_VALUE & 0xFF]],
                                   [[MessagePackTag.UINT8, uint.MAX_VALUE & 0xFF],
                                    [MessagePackTag.UINT16, uint.MAX_VALUE & 0xFFFF]],
                                   [[MessagePackTag.UINT8, uint.MAX_VALUE & 0xFF],
                                    [MessagePackTag.UINT16, uint.MAX_VALUE & 0xFFFF],
                                    [MessagePackTag.UINT32, uint.MAX_VALUE]]];
            for (var i : uint = 0; i < tests.length; ++i) {
                const testValues : Array = tests[i];
                for (var j : uint = 0; j < testValues.length; ++j) {
                    const value : Array = testValues[j];
                    const bytes : ByteArray = new ByteArray();
                    const packer : Packer = new Packer(bytes);
                    packer.pack(value[1] & masks[i]);

                    assertThat(bytes[0], equalTo(value[0]));

                    var result : uint;
                    switch (j) {
                    case 0:
                        assertThat(bytes.length, equalTo(2));
                        assertThat(bytes[1], equalTo(value[1] & masks[i]));
                        break;
                    case 1:
                        assertThat(bytes.length, equalTo(3));
                        result = bytes[1] << 8 | bytes[2];
                        assertThat(result, equalTo(value[1] & masks[i]));
                        break;
                    default:
                        assertThat(bytes.length, equalTo(5));
                        result = bytes[1] << 24 | bytes[2] << 16 | bytes[3] << 8 | bytes[4];
                        assertThat(result, equalTo(uint(value[1] & masks[i])));
                    }
                }
            }
        }

        [Test]
        public function testInt() : void {
            const tests : Array = [[[MessagePackTag.INT8, -128]],
                                   [[MessagePackTag.INT8, -128],
                                    [MessagePackTag.INT16, -32768]],
                                   [[MessagePackTag.INT8, -128],
                                    [MessagePackTag.INT16, -32768],
                                    [MessagePackTag.INT32, int.MIN_VALUE]]];
            for (var i : uint = 0; i < tests.length; ++i) {
                const testValues : Array = tests[i];
                for (var j : uint = 0; j < testValues.length; ++j) {
                    const value : Array = testValues[j];
                    const bytes : ByteArray = new ByteArray();
                    const packer : Packer = new Packer(bytes);
                    packer.pack(value[1]);

                    assertThat(bytes[0], equalTo(value[0]));

                    var result : int = 0;
                    switch (j) {
                    case 0:
                        assertThat(bytes.length, equalTo(2));
                        assertThat(0xFFFFFF00 | bytes[1], equalTo(value[1]));
                        break;
                    case 1:
                        assertThat(bytes.length, equalTo(3));
                        result = 0xFFFF0000 | bytes[1] << 8 | bytes[2];
                        assertThat(result, equalTo(value[1]));
                        break;
                    default:
                        assertThat(bytes.length, equalTo(5));
                        result = bytes[1] << 24 | bytes[2] << 16 | bytes[3] << 8 | bytes[4];
                        assertThat(result, equalTo(value[1]));
                    }
                }
            }
        }

        [Test]
        public function testNumber() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            packer.pack(Number.MAX_VALUE);
            assertThat(bytes.length, equalTo(9));
            assertThat(bytes[0], equalTo(MessagePackTag.DOUBLE));
            bytes.position = 1;
            assertThat(bytes.readDouble(), equalTo(Number.MAX_VALUE));
        }
        
        [Test]
        public function testArray() : void {
            const testValues : Array = [[MessagePackTag.ARRAY | 8, MessagePackTag.ARRAY | 8],
                                        [MessagePackTag.ARRAY16, 65535],
                                        [MessagePackTag.ARRAY32, uint.MAX_VALUE]];
            for (var i : uint = 0; i < testValues.length; ++i) {
                const value : Array = testValues[i];
                const bytes : ByteArray = new ByteArray();
                const packer : Packer = new Packer(bytes);
                packer.beginArray(i ? value[1] : 8);

                assertThat(bytes[0], equalTo(value[0]));

                var result : uint = 0;
                switch (i) {
                case 0:
                    assertThat(bytes.length, equalTo(1));
                    assertThat(bytes[0], equalTo(value[1]));
                    break;
                case 1:
                    assertThat(bytes.length, equalTo(3));
                    result = bytes[1] << 8 | bytes[2];
                    assertThat(result, equalTo(value[1]));
                    break;
                default:
                    assertThat(bytes.length, equalTo(5));
                    result = bytes[1] << 24 | bytes[2] << 16 | bytes[3] << 8 | bytes[4];
                    assertThat(result, equalTo(value[1]));
                }
            }
        }

        [Test]
        public function testMap() : void {
            const testValues : Array = [[MessagePackTag.MAP | 8, MessagePackTag.MAP | 8],
                                        [MessagePackTag.MAP16, 65535],
                                        [MessagePackTag.MAP32, uint.MAX_VALUE]];
            for (var i : uint = 0; i < testValues.length; ++i) {
                const value : Array = testValues[i];
                const bytes : ByteArray = new ByteArray();
                const packer : Packer = new Packer(bytes);
                packer.beginMap(i ? value[1] : 8);

                assertThat(bytes[0], equalTo(value[0]));

                var result : uint = 0;
                switch (i) {
                case 0:
                    assertThat(bytes.length, equalTo(1));
                    assertThat(bytes[0], equalTo(value[1]));
                    break;
                case 1:
                    assertThat(bytes.length, equalTo(3));
                    result = bytes[1] << 8 | bytes[2];
                    assertThat(result, equalTo(value[1]));
                    break;
                default:
                    assertThat(bytes.length, equalTo(5));
                    result = bytes[1] << 24 | bytes[2] << 16 | bytes[3] << 8 | bytes[4];
                    assertThat(result, equalTo(value[1]));
                }
            }
        }

        [Test]
        public function testRaw() : void {
            const testValues : Array = [[MessagePackTag.RAW | 8, MessagePackTag.RAW | 8],
                                        [MessagePackTag.RAW16, 65535],
                                        [MessagePackTag.RAW32, uint.MAX_VALUE]];
            for (var i : uint = 0; i < testValues.length; ++i) {
                const value : Array = testValues[i];
                const bytes : ByteArray = new ByteArray();
                const packer : Packer = new Packer(bytes);
                packer.beginRaw(i ? value[1] : 8);

                assertThat(bytes[0], equalTo(value[0]));

                var result : uint = 0;
                switch (i) {
                case 0:
                    assertThat(bytes.length, equalTo(1));
                    assertThat(bytes[0], equalTo(value[1]));
                    break;
                case 1:
                    assertThat(bytes.length, equalTo(3));
                    result = bytes[1] << 8 | bytes[2];
                    assertThat(result, equalTo(value[1]));
                    break;
                default:
                    assertThat(bytes.length, equalTo(5));
                    result = bytes[1] << 24 | bytes[2] << 16 | bytes[3] << 8 | bytes[4];
                    assertThat(result, equalTo(value[1]));
                }
            }
        }

        [Test]
        public function testObject() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);

            const object : PackableDummy = new PackableDummy();
            packer.pack(object);

            assertThat(bytes.length, equalTo(6));
            assertThat(bytes[0], equalTo(MessagePackTag.ARRAY | 1));
            assertThat(bytes[1], equalTo(MessagePackTag.UINT32));
            const result : uint = bytes[2] << 24 | bytes[3] << 16 | bytes[4] << 8 | bytes[5];
            assertThat(result, equalTo(object.num));
        }
    }
}
