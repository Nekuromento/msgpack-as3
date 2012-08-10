package util.debug {
    public function warning(text : String) : void {
        trace(new Date().toUTCString() + " Warning: " + text);
    }
}
