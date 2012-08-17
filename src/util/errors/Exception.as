package util.errors {
    public class Exception extends Error {
        private var _cause : Error;

        public function Exception(message : * = "", cause : Error = null, id : * = 0) {
            super(message, id);
            _cause = cause;
        }

        public function get cause() : Error {
            return _cause;
        }
    }
}
