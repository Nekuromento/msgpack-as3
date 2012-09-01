package test.messagepack {
    import net.messagepack.Packer;
    import net.messagepack.Unpacker;

    import com.adobe.utils.DictionaryUtil;

    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.collection.arrayWithSize;
    import org.hamcrest.core.allOf;
    import org.hamcrest.core.isA;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.nullValue;
    import org.hamcrest.object.strictlyEqualTo;

    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

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
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            packer.pack([], [0, null, "test", true, false]);
            packer.beginArray(17);
            for (var i : uint = 0; i < 17; ++i)
                packer.pack(i);

            bytes.position = 0;
            const unpacker : Unpacker = new Unpacker(bytes);
            assertThat(unpacker.unpack(), nullValue());
            assertThat(unpacker.unpack(), array(0, null, "test", true, false));
            assertThat(unpacker.unpack(), arrayWithSize(17));
        }

        [Test]
        public function testMap() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            const emptyDict : Dictionary = new Dictionary();
            const dict : Dictionary = new Dictionary();
            dict["foo"] = "bar";
            dict[1] = 2;
            packer.pack(emptyDict, dict);
            packer.beginMap(17);
            for (var i : uint = 0; i < 17; ++i) {
                packer.pack(i.toString());
                packer.pack(i);
            }

            bytes.position = 0;
            const unpacker : Unpacker = new Unpacker(bytes);

            assertThat(unpacker.unpack(), nullValue());

            const secondResult : * = unpacker.unpack();
            assertThat(secondResult, isA(Dictionary));
            assertThat(DictionaryUtil.getKeys(secondResult), array(1, "foo"));
            assertThat(DictionaryUtil.getValues(secondResult), array(2, "bar"));

            const thirdResult : * = unpacker.unpack();
            assertThat(thirdResult, isA(Dictionary));
            assertThat(DictionaryUtil.getKeys(thirdResult), arrayWithSize(17));
            assertThat(DictionaryUtil.getValues(thirdResult), arrayWithSize(17));
        }

        [Test]
        public function testRaw() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);
            const byteArray : ByteArray = new ByteArray();
            byteArray.writeDouble(3.14);
            byteArray.writeInt(314);
            byteArray.writeUTF("тест");
            packer.pack("test", byteArray);

            bytes.position = 0;
            const unpacker : Unpacker = new Unpacker(bytes);
            assertThat(unpacker.unpack(),
                       allOf(isA(ByteArray), equalTo("test")));
            assertThat(String(unpacker.unpack()), equalTo(String(byteArray)));
        }

        [Test]
        public function testObject() : void {
            const bytes : ByteArray = new ByteArray();
            const packer : Packer = new Packer(bytes);

            const p : Dummy = new Dummy();
            packer.pack(p);

            bytes.position = 0;
            const unpacker : Unpacker = new Unpacker(bytes);
            const o : Dummy = new Dummy();
            unpacker.unpackObject(o);

            assertThat(o.num, equalTo(p.num));
        }
    }
}
