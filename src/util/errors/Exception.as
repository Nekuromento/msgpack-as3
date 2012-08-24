package util.errors {
    public class Exception extends Error {
        private var _cause : Error;

        public function Exception(message : * = "", cause : Error = null, id : * = 0) {
            super(message, id);
            _cause = cause;
            name = "Exception";
        }

        public function get cause() : Error {
            return _cause;
        }

        public function toString() : String {
            var buf : String = getStackTrace();
            if (_cause != null)
                buf += "caused by: " + (cause is Exception
                                            ? String(cause)
                                            : cause.getStackTrace());
            return buf;
        }
    }
}
