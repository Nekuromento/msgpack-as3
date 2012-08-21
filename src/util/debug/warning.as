package util.debug {
    public function warning(text : String, cause : Error = null) : void {
        trace(new Date().toUTCString() + " Warning: " + text);
        if (cause != null)
            trace("    cause : " + cause.message);
    }
}
