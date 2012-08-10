package net.messagepack {
    public class MessagePackError extends Error {
        public function MessagePackError(message : * = "", id : * = 0) {
            super(message, id);
        }
    }
}
