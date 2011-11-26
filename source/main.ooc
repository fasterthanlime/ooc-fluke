import fluke

main: func {
    flv := FLV new("abcde.mp3")
    flv writeHeader()
}
