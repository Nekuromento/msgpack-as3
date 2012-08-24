package util.debug {
    import util.errors.Exception;

    public function warning(text : String, cause : Error = null) : void {
        trace(new Date().toUTCString() + " Warning: " + text);
        if (cause != null)
            trace("    cause : " + (cause is Exception
                                        ? String(cause)
                                        : cause.getStackTrace()));
    }
}
