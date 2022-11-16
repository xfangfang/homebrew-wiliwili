# modified from https://github.com/iina/homebrew-mpv-iina
# Last check with upstream: 5ef3900b6178dee40629e3e058a587ef196b53b1
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/ffmpeg.rb

class FfmpegWiliwili < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-5.1.2.tar.gz"
  sha256 "87fe8defa37ce5f7449e36047171fed5e4c3f4bb73eaccea8c954ee81393581c"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/ffmpeg-wiliwili-5.1.2"
    rebuild 1
    sha256 cellar: :any, monterey: "5ded3bd536214d1a3b5508af6b5923fec50d14fa97da3e26269dbddb351c59a6"
  end

  keg_only <<~EOS
    it is intended to only be used for building wiliwili.
    This formula is not recommended for daily use and has no binaraies (ffmpeg, ffplay etc.)
  EOS

  depends_on "pkg-config" => :build
  depends_on "dav1d"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "openssl"
  depends_on "libass"

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_linux do
    depends_on "alsa-lib"
    depends_on "libxv"
  end

  on_intel do
    depends_on "nasm" => :build
  end

  fails_with gcc: "5"

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
      --enable-openssl
      --enable-libdav1d
      --enable-libass
      --enable-libfreetype
      --enable-libfontconfig
      --enable-libxml2
      --disable-autodetect
      --disable-libjack
      --disable-indev=jack
      --disable-programs
      --enable-videotoolbox
      --disable-avdevice
      --disable-postproc
      --disable-doc
      --disable-debug
      --enable-network
      --enable-zlib
      --enable-bzlib
      --enable-protocols
      --disable-encoders
    ]

    args << "--enable-neon" if Hardware::CPU.arm?

    system "./configure", *args
    system "make", "install"
  end

  test do
    fake_test = testpath/"a.log"
    touch fake_test
    assert_predicate fake_test, :exist?
  end
end
