# modified from https://github.com/iina/homebrew-mpv-iina
# Last check with upstream: 5ef3900b6178dee40629e3e058a587ef196b53b1
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/ffmpeg.rb

class FfmpegWiliwili < Formula
    desc "Play, record, convert, and stream audio and video"
    homepage "https://ffmpeg.org/"
    url "https://ffmpeg.org/releases/ffmpeg-5.1.2.tar.gz"
    sha256 "87fe8defa37ce5f7449e36047171fed5e4c3f4bb73eaccea8c954ee81393581c"
  
    keg_only <<EOS
it is intended to only be used for building wiliwili.
This formula is not recommended for daily use and has no binaraies (ffmpeg, ffplay etc.)
EOS
  
    on_intel do
      depends_on "nasm" => :build
    end
    depends_on "pkg-config" => :build
    uses_from_macos "bzip2"
    uses_from_macos "libxml2"
    uses_from_macos "zlib"
  
    def install
  
      args = %W[
        --prefix=#{prefix}
        --enable-shared
        --enable-pthreads
        --enable-version3
        --cc=#{ENV.cc}
        --host-cflags=#{ENV.cflags}
        --host-ldflags=#{ENV.ldflags}
        --enable-gpl
        --enable-libxml2
        --disable-libjack
        --disable-indev=jack
        --disable-programs
        --disable-avdevice
        --disable-doc
        --disable-debug
        --disable-protocols
	    --enable-protocol='file,http,tcp,udp,rtmp,hls,https,tls'
        --disable-encoders
      ]

      args << "--enable-neon" if Hardware::CPU.arm?
  
      system "./configure", *args
      system "make", "install"

    end
  
    test do
      # Create an example mp4 file
      mp4out = testpath/"video.mp4"
      system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
      assert_predicate mp4out, :exist?
    end
  end