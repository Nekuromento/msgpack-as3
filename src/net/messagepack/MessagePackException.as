package net.messagepack {
    import util.errors.Exception;

    public class MessagePackException extends Exception {
        public function MessagePackException(message : * = "", cause : Error = null, id : * = 0) {
            super(message, cause, id);
        }
    }
}
