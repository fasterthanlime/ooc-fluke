
use math
import io/[File, FileWriter, Writer]

frexp: extern func(Double, Int*) -> Double
fabs: extern func(Double) -> Double

Utils: class {

    double2Int: static func(val: Double) -> Int64 {
        e: Int
        if ( !val) {
            return 0
        } else if (val-val) { // overflow?
            return (0x7FF0000000000000 as LLong) + (((val<0)<<63) as UInt64) + (val !=val);
        }
        val= frexp(val, e&);
        return ((val<0) as UInt64 <<63 | (e+(1022 as LLong))<<52 | ((fabs(val)-0.5) as UInt64)*((1 as LLong)<<53));
    }
}

BinaryWriter: class {

    w: Writer
    offset := 0 // what's yet been written in bytes
    init: func(=w)

    
    w8: func (val: UInt) {
        w write(val as Char) 
        offset += 1
    }

    wl16: func (val: UInt) {
        w8(val)
        w8(val >> 8)
        offset += 2
    }

    wb16: func (val: UInt) {
        w8(val >> 8)
        w8(val)
        offset += 2
    }

    wl24: func (val: UInt) {
        wl16(val & 0xffff)
        w8(val >> 16)
        offset += 3
    }

    wb24: func (val: UInt) {
        wb16(val >> 8)
        w8(val)
        offset += 3
    }

    
    wl32: func(val: UInt) {
        w8(val)
        w8(val >> 8)
        w8(val >> 16)
        w8(val >> 24)
        offset += 4
    }

    wb32: func (val: UInt) {
        w8(val >> 24)
        w8(val >> 16)
        w8(val >> 8)
        w8(val)
        offset += 4
    }

    wl64: func (val: UInt64) {
        wl32((val & 0xffffffff) as UInt32)
        wl32((val >> 32) as UInt32)
    }

    wb64: func(val: UInt64) {
        wb32((val >> 32) as UInt32)
        wb32((val & 0xffffffff) as UInt32)
    }

    write: func (val: String) {
        w write(val)
        offset += val length()
    }
}

AMF: class {

    DATA_TYPE_NUMBER      := static 0x00
    DATA_TYPE_BOOL        := static 0x01    
    DATA_TYPE_STRING      := static 0x02
    DATA_TYPE_OBJECT      := static 0x03
    DATA_TYPE_NULL        := static 0x05
    DATA_TYPE_UNDEFINED   := static 0x06
    DATA_TYPE_REFERENCE   := static 0x07
    DATA_TYPE_MIXEDARRAY  := static 0x08
    DATA_TYPE_OBJECT_END  := static 0x09
    DATA_TYPE_ARRAY       := static 0x0a
    DATA_TYPE_DATE        := static 0x0b
    DATA_TYPE_LONG_STRING := static 0x0c
    DATA_TYPE_UNSUPPORTED := static 0x0d

    putString: static func(writer: BinaryWriter, str: String) {
        writer wb16(str length() as UInt)
        writer write(str)
    }

    putDouble: static func(writer: BinaryWriter, val: Double) {
        writer w8(DATA_TYPE_NUMBER)
        writer wb64(Utils double2Int(val))
    }

}

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

    FRAME_KEY        := static 1 << VIDEO_FRAMETYPE_OFFSET
    FRAME_INTER      := static 2 << VIDEO_FRAMETYPE_OFFSET
    FRAME_DISP_INTER := static 3 << VIDEO_FRAMETYPE_OFFSET

    // the non-static part
    audioFile: File
    fileName: String
    binWriter: BinaryWriter
    fWriter: FileWriter
    output := "test.flv"

    init: func(=fileName) {
        //read that audio file
        fWriter := FileWriter new(output, "wb")
        binWriter = BinaryWriter new(fWriter)
    }

    writeHeader: func { 
        binWriter write("FLV") // each FLV file starts like that
        binWriter w8(1) // version '1'
        binWriter w8(4) // flag that we only have audio
        
        binWriter wb32(9) // header size
        binWriter wb32(0) // not sure if neccessary

        // TODO: check if we have to include the ==5 loop-part
        binWriter w8(18) // META tag type
        binWriter wb24(0) // size of data part
        binWriter wb24(0) // time stamp
        binWriter wb32(0) // reserved

        binWriter w8(AMF DATA_TYPE_STRING)
        AMF putString(binWriter, "onMetaData")
        binWriter w8(AMF DATA_TYPE_MIXEDARRAY)
        binWriter wb32(7) // size for audio + 2 (metadata_count) - seems somewhat small though

        AMF putString(binWriter, "duration")
        AMF putDouble(binWriter, 47.47) // dummy, needs to be filled with actual duration

        
    }

}

