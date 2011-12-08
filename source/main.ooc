import fluke

main: func {
    flv := Encoder new("abcde.mp3")
    flv writeHeader()
}
