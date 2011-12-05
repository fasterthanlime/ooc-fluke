
use math
include math

import io/[File, FileWriter, Writer, BufferWriter]

frexp: extern func(Double, Int*) -> Double
fabs: extern func(Double) -> Double

// av_dbl2int: extern func (d: Double) -> Int64
av_dbl2int: extern func (d: Double, i: Int64*)

Utils: class {

    double2Int: static func(val: Double) -> Int64 {
        e: Int
        if ( !val) {
            return 0
        } else if (val-val) { // overflow?
            return (0x7FF0000000000000 as LLong) + (((val<0)<<63 as UInt64 )) + (val !=val);
        }
        val= frexp(val, e&);
        return ((val<0) as UInt64 <<63 | (e+(1022 as LLong))<<52 | ((fabs(val)-0.5) as UInt64)*((1 as LLong)<<53));
    }
}

BinaryWriter: class {

    target: Writer
    w: BufferWriter
    init: func(=target) {
        w = BufferWriter new()
    }

    
    w8: func (val: UInt) {
        w write(val as Char) 
    }

    wl16: func (val: UInt) {
        w8(val)
        w8(val >> 8)
    }

    wb16: func (val: UInt) {
        w8(val >> 8)
        w8(val)
    }

    wl24: func (val: UInt) {
        wl16(val & 0xffff)
        w8(val >> 16)
    }

    wb24: func (val: UInt) {
        wb16(val >> 8)
        w8(val)
    }

    
    wl32: func(val: UInt) {
        w8(val)
        w8(val >> 8)
        w8(val >> 16)
        w8(val >> 24)
    }

    wb32: func (val: UInt) {
        w8(val >> 24)
        w8(val >> 16)
        w8(val >> 8)
        w8(val)
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
    }

    skip: func (l: Long) {
        seek(tell() + l)
    }

    tell: func -> Long {
        w mark()
    }

    seek: func (l: Long) {
        // kids, don't do this at home: rely on an interface,
        // not an implementation. Except on a deadline, of course.
        w _makeRoom(l). seek(l)
    }

    flush: func {
        target write(w buffer())
    }
}

AVMEDIA: enum {

    TYPE_UNKNOWN = -1
    TYPE_VIDEO = 0
    TYPE_AUDIO
    TYPE_DATA
    TYPE_SUBTITLE
    TYPE_ATTACHMENT
    TYPE_NB
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

    putString: static func(writer: BinaryWriter, val: String) {
        "Writing string %s" printfln(val)
        writer wb16(val length() as UInt)
        writer write(val)
    }

    putDouble: static func(writer: BinaryWriter, val: Double) {
        "Writing double %f" printfln(val)
        writer w8(DATA_TYPE_NUMBER)
        // zint := av_dbl2int(val)
        zint: Int64
        av_dbl2int(val, zint&)
        writer wb64(zint)
        fprintf(stdout, "It gives int %lld\n", zint)
    }

    putBool: static func(writer: BinaryWriter, val: Bool) {
        "Writing bool %d" printfln(val)
        writer w8(DATA_TYPE_BOOL);
        writer w8(val ? 0 : 1);
    }

}

Packet: class {

    pts: Int64
    dts: Int64
    data: UInt8* data
    size: Int
    streamIndex: Int
    flags: Int
    duration: Int
    
    //void(*  destruct )(struct AVPacket *)
    priv: Pointer
    pos: Int64

    convergenceDuration: Int64

    init: func {}
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
    HEADER_FLAG_HASVIDEO   := static 1

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
    avio: BinaryWriter
    fWriter: FileWriter
    output := "test.flv"

    channels := 2
    codec_tag := CODECID_MP3
    bit_rate := 320000
    sample_rate := 44100

    init: func(=fileName) {
        //read that audio file
        fWriter := FileWriter new(output, "wb")
        avio = BinaryWriter new(fWriter)
    }

    writeHeader: func { 
        avio write("FLV") // each FLV file starts like that
        avio w8(1) // All FLVs have version 1
        avio w8(HEADER_FLAG_HASAUDIO) // flag that we only have audio
        
        avio wb32(9) // header size
        avio wb32(0) // not sure if neccessary

        // TODO: check if we have to include the ==5 loop-part

        // write meta_tag
        avio w8(0x12) // metadata tag type
        metadataSizePos := avio tell()
        avio wb24(0) // size of data part, yet unknown, will have to write here later
        avio wb24(0) // time stamp
        avio wb32(0) // reserved

        // now data of data_size size

        // first event name as a string
        avio w8(AMF DATA_TYPE_STRING)
        AMF putString(avio, "onMetaData")

        // mixed array (hash) with size and string/type/data tuples
        avio w8(AMF DATA_TYPE_MIXEDARRAY)
        metadataCountPos := avio tell()
        metadataCount := 5 + 2 // 5 for audio, 2 for duration and file size
        avio wb32(metadataCount)

        AMF putString(avio, "duration")
        AMF putDouble(avio, 0.0) // dummy, needs to be filled with actual duration
       
        // audio specific tags
        {
            AMF putString(avio, "audiodatarate");
            AMF putDouble(avio, bit_rate / 1024.0);

            AMF putString(avio, "audiosamplerate");
            AMF putDouble(avio, sample_rate);

            AMF putString(avio, "audiosamplesize");
            AMF putDouble(avio, 16);

            AMF putString(avio, "stereo");
            AMF putBool(avio, channels == 2);

            AMF putString(avio, "audiocodecid");
            // AMF putDouble(avio, codec_tag);
            AMF putDouble(avio, 2.0); // FIXME don't understand why but ffmpeg says 2
        }

        AMF putString(avio, "filesize")
        AMF putDouble(avio, 0.0) // dummy

        AMF putString(avio, "")
        avio w8(AMF_END_OF_OBJECT)

        // write total size of tag
        dataSize := avio tell()
        "dataSize = %d" printfln(dataSize)
        "metadataCountPos = %d" printfln(metadataCountPos)
        "metadataCount = %d" printfln(metadataCount)
        "metadataSizePos = %d" printfln(metadataSizePos)

        avio seek(metadataCountPos)
        avio wb32(metadataCount)

        avio seek(metadataSizePos)
        avio wb24(dataSize)
        avio skip(dataSize + 10 - 3) // magic numbers from ffmpeg - yay!
        avio wb32(dataSize + 11) // moar magic numbers from ffmpeg

        avio flush()
    }

    writePacket(packet: Packet): func {
        // ts = pkt->dts + flv->delay
        ts: UInt = 1 // dummy

        flagsSize = 1
        // flags = get_audio_flags(enc);
        flags = 0
        // type is AVMEDIA_TYPE_AUDIO
        avio w8(FLV TAG_TYPE_AUDIO)

        // TODO: check ts stuff - are we concerned at all?

        avio wb24(1000) // packet size, dummy val
        avio wb24(ts)
        avio w8((ts >>24) & 0x7F) // time stamps are 32bits signed
        avio wb24(10) // flv reserved

        ts = packet dts // + flv delay
        avio w8(flags)
        
        avio write(data, size)
        avio wb32(size + flagsSize + 11) // prev tag size
        
        //flv->duration = FFMAX(flv->duration, pkt->pts + flv->delay + pkt->duration);
        avio flush()
}

