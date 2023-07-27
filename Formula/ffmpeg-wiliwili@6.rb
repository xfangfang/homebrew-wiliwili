# modified from https://github.com/iina/homebrew-mpv-iina
# Last check with upstream: 5ef3900b6178dee40629e3e058a587ef196b53b1
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/ffmpeg.rb

class FfmpegWiliwiliAT6 < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-6.0.tar.xz"
  sha256 "57be87c22d9b49c112b6d24bc67d42508660e6b718b3db89c44e47e289137082"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/ffmpeg-wiliwili-5.1.2_1"
    sha256 cellar: :any, monterey: "4e7a6c2c0551bb3bce8e26ca584cadd8b11167651b4740d1fbd04476b404631c"
    sha256 cellar: :any, big_sur:  "93564be17e69cfc025a0f3f79935a7ce9e2d522e7a068d9eab1f2e67bd0f9add"
  end

  keg_only <<~EOS
    it is intended to only be used for building wiliwili.
    This formula is not recommended for daily use and has no binaraies (ffmpeg, ffplay etc.)
  EOS

  depends_on "pkg-config" => :build
  depends_on "dav1d"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "libass"
  depends_on "mbedtls"

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
      --enable-mbedtls
      --enable-libdav1d
      --enable-libass
      --enable-libfreetype
      --enable-libfontconfig
      --enable-libxml2
      --disable-autodetect
      --disable-libjack
      --disable-indev=jack
      --disable-programs
      --disable-postproc
      --disable-doc
      --disable-debug
      --enable-network
      --enable-zlib
      --enable-bzlib
      --disable-encoders
    ]

    args << "--enable-videotoolbox" if OS.mac?
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
