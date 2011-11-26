

FLV: class {

    AUDIO_SAMPLESSIZE_OFFSET  := static 1
    AUDIO_SAMPLERATE_OFFSET  := static 2
    AUDIO_CODECID_OFFSET     := static 4
    VIDEO_FRAMETYPE_OFFSET   := static 4

    AUDIO_CHANNEL_MASK     := static 0x01
    AUDIO_SAMPLESIZE_MASK  := static 0x02
    AUDIO_SAMPLERATE_MASK  := static 0x0c
    AUDIO_CODECID_MASK     := static 0xf0

    VIDEO_CODECID_MASK     := static 0x0f
    VIDEO_FRAMETYPE_MASK   := static 0xf0

    AMF_END_OF_OBJECT      := static 0x09

    HEADER_FLAG_HASAUDIO   := static 4
    HEADER_FLAG_HASVIDEO   := static 4

    TAG_TYPE_AUDIO   := static 0x08
    TAG_TYPE_VIDEO   := static 0x09
    TAG_TYPE_META    := static 0x12

    STREAM_TYPE_VIDEO := static 0
    STREAM_TYPE_AUDIO := static 1
    STREAM_TYPE_DATA  := static 2

    MONO   := static 0
    STEREO := static 1

    SAMPLESSIZE_8BIT  := static 0
    SAMPLESSIZE_16BIT := static 1 << AUDIO_SAMPLESSIZE_OFFSET

    SAMPLERATE_SPECIAL := static 0
    SAMPLERATE_11025HZ := static 1 << AUDIO_SAMPLERATE_OFFSET
    SAMPLERATE_22050HZ := static 2 << AUDIO_SAMPLERATE_OFFSET
    SAMPLERATE_44100HZ := static 3 << AUDIO_SAMPLERATE_OFFSET

    CODECID_PCM                   := static 0
    CODECID_ADPCM                 := static 1 << AUDIO_CODECID_OFFSET
    CODECID_MP3                   := static 2 << AUDIO_CODECID_OFFSET
    CODECID_PCM_LE                := static 3 << AUDIO_CODECID_OFFSET
    CODECID_NELLYMOSER_16KHZ_MONO := static 4 << AUDIO_CODECID_OFFSET
    CODECID_NELLYMOSER_8KHZ_MONO  := static 5 << AUDIO_CODECID_OFFSET
    CODECID_NELLYMOSER            := static 6 << AUDIO_CODECID_OFFSET
    CODECID_AAC                   := static 10<< AUDIO_CODECID_OFFSET
    CODECID_SPEEX                 := static 11<< AUDIO_CODECID_OFFSET

    CODECID_H263     := static 2
    CODECID_SCREEN   := static 3
    CODECID_VP6      := static 4
    CODECID_VP6A     := static 5
    CODECID_SCREEN2  := static 6
    CODECID_H264     := static 7
    CODECID_REALH263 := static 8
    CODECID_MPEG4    := static 9

    FRAME_KEY        := 1 << VIDEO_FRAMETYPE_OFFSET
    FRAME_INTER      := 2 << VIDEO_FRAMETYPE_OFFSET
    FRAME_DISP_INTER := 3 << VIDEO_FRAMETYPE_OFFSET

    AMF_DATA_TYPE_NUMBER      := 0x00
    AMF_DATA_TYPE_BOOL        := 0x01    
    AMF_DATA_TYPE_STRING      := 0x02
    AMF_DATA_TYPE_OBJECT      := 0x03
    AMF_DATA_TYPE_NULL        := 0x05
    AMF_DATA_TYPE_UNDEFINED   := 0x06
    AMF_DATA_TYPE_REFERENCE   := 0x07
    AMF_DATA_TYPE_MIXEDARRAY  := 0x08
    AMF_DATA_TYPE_OBJECT_END  := 0x09
    AMF_DATA_TYPE_ARRAY       := 0x0a
    AMF_DATA_TYPE_DATE        := 0x0b
    AMF_DATA_TYPE_LONG_STRING := 0x0c
    AMF_DATA_TYPE_UNSUPPORTED := 0x0d
}
