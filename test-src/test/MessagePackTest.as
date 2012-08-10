package test {
    import flexunit.framework.Assert;

    import net.messagepack.MessagePack;
    import net.messagepack.MessagePackTag;

    import flash.utils.ByteArray;

    public class MessagePackTest {
        [Test]
        public function testUniqueValues() : void {
            const result : Array =
                [MessagePackTag.NULL, MessagePackTag.TRUE, MessagePackTag.FALSE];
            const bytes : ByteArray = MessagePack.pack(null, true, false);
            Assert.assertEquals(bytes.length, result.length);
            for (var i : uint = 0; i < bytes.length; ++i)
                Assert.assertEquals(bytes[i], result[i]);
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
                    const bytes : ByteArray = MessagePack.pack(value[1] & masks[i]);

                    Assert.assertEquals(bytes[0], value[0]);

                    var result : uint;
                    switch (j) {
                    case 0:
                        Assert.assertEquals(bytes.length, 2);
                        Assert.assertEquals(bytes[1], value[1] & masks[i]);
                        break;
                    case 1:
                        Assert.assertEquals(bytes.length, 3);
                        result = bytes[1] << 8 | bytes[2];
                        Assert.assertEquals(result, value[1] & masks[i]);
                        break;
                    default:
                        Assert.assertEquals(bytes.length, 5);
                        result = bytes[1] << 24 | bytes[2] << 16 | bytes[3] << 8 | bytes[4];
                        Assert.assertEquals(result, uint(value[1] & masks[i]));
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
                    const bytes : ByteArray = MessagePack.pack(value[1]);

                    Assert.assertEquals(bytes[0], value[0]);

                    var result : int = 0;
                    switch (j) {
                    case 0:
                        Assert.assertEquals(bytes.length, 2);
                        Assert.assertEquals(0xFFFFFF00 | bytes[1], value[1]);
                        break;
                    case 1:
                        Assert.assertEquals(bytes.length, 3);
                        result = 0xFFFF0000 | bytes[1] << 8 | bytes[2];
                        Assert.assertEquals(result, value[1]);
                        break;
                    default:
                        Assert.assertEquals(bytes.length, 5);
                        result = bytes[1] << 24 | bytes[2] << 16 | bytes[3] << 8 | bytes[4];
                        Assert.assertEquals(result, value[1]);
                    }
                }
            }
        }

        [Test]
        public function testNumber() : void {
            const bytes : ByteArray = MessagePack.pack(Number.MAX_VALUE);
            Assert.assertEquals(bytes.length, 9);
            Assert.assertEquals(bytes[0], MessagePackTag.DOUBLE);
            bytes.position = 1;
            Assert.assertEquals(bytes.readDouble(), Number.MAX_VALUE);
        }
        
        [Test]
        public function testArray() : void {
            Assert.fail("Test not implemented");
        }
    }
}
