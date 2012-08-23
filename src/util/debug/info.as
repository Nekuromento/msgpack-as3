package util.debug {
    public function info(text : String) : void {
        trace(new Date().toUTCString() + " Info: " + text);
    }
}
