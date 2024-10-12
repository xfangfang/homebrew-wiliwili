# modified from https://github.com/iina/homebrew-mpv-iina
# Last check with upstream: 5ef3900b6178dee40629e3e058a587ef196b53b1
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/ffmpeg.rb

class FfmpegWiliwili < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-7.1.tar.xz"
  sha256 "40973d44970dbc83ef302b0609f2e74982be2d85916dd2ee7472d30678a7abe6"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/ffmpeg-wiliwili@7-7.1"
    sha256 cellar: :any, arm64_sequoia: "f8bca04becd0d86adc2980e0d4003f999201208916fdcc78fabef5a2a8eb8a41"
    sha256 cellar: :any, arm64_sonoma:  "810a04100e3a9592d5eae3c568a46e8dd8d5d53c126a96f05de110a459d5353c"
    sha256 cellar: :any, ventura:       "c252d5cf6683c4cb5d483869811b0840eda3ad395bb1fe23e0aac91ff61eb6d4"
  end

  keg_only <<~EOS
    it is intended to only be used for building wiliwili.
    This formula is not recommended for daily use and has no binaraies (ffmpeg, ffplay etc.)
  EOS

  depends_on "pkg-config" => :build
  depends_on "dav1d"
  depends_on "freetype"
  depends_on "libass-wiliwili"
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
    # The new linker leads to duplicate symbol issue https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.clang_build_version >= 1500

    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --extra-ldflags="-lmbedtls -lmbedx509 -lmbedcrypto"
      --enable-gpl
      --enable-mbedtls
      --enable-libdav1d
      --enable-libass
      --enable-libfreetype
      --enable-libxml2
      --disable-libfontconfig
      --disable-autodetect
      --disable-libjack
      --disable-indev=jack
      --disable-programs
      --disable-postproc
      --disable-avdevice
      --disable-doc
      --disable-debug
      --enable-network
      --enable-zlib
      --enable-bzlib
      --disable-encoders
      --disable-muxers
    ]

    args += %w[--enable-videotoolbox --enable-audiotoolbox] if OS.mac?
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
