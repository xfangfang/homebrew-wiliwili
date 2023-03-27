# modified from https://github.com/iina/homebrew-mpv-iina
# Last check with upstream: 356dc6f78059f1706bc8c6c44545c262dca43c3e
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mpv.rb

class MpvWiliwili < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/v0.35.1.tar.gz"
  sha256 "41df981b7b84e33a2ef4478aaf81d6f4f5c8b9cd2c0d337ac142fc20b387d1a9"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/mpv-wiliwili-0.35.0"
    rebuild 2
    sha256 cellar: :any, monterey: "bab047979f4e3a9321035820126721fadd7c6182737c0beb51c375d769fba687"
    sha256 cellar: :any, big_sur:  "80d6ace47bd8069c0ced7b8a78a8157157ae8e0a9a1ba6c8579b0f2988b4bfd3"
  end

  keg_only "it is intended to only be used for building wiliwili 1"

  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.10" => :build
  depends_on xcode: :build

  depends_on "ffmpeg-wiliwili"
  depends_on "libass"
  depends_on "luajit"

  on_linux do
    depends_on "alsa-lib"
  end

  fails_with gcc: "5" # ffmpeg is compiled with GCC

  def install
    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "C"

    # Avoid unreliable macOS SDK version detection
    if OS.mac?
      sdk = (MacOS.version == :big_sur) ? MacOS::Xcode.sdk : MacOS.sdk
      ENV["MACOS_SDK"] = sdk.path
      ENV["MACOS_SDK_VERSION"] = "#{sdk.version}.0"
    end

    args = %W[
      --prefix=#{prefix}
      --disable-debug-build
      --enable-libmpv-shared
      --disable-jpeg
      --disable-libavdevice
      --disable-swift
      --disable-javascript
      --disable-macos-touchbar
      --disable-macos-media-player
      --disable-cplayer
      --confdir=#{etc}/mpv
      --datadir=#{pkgshare}
      --mandir=#{man}
      --docdir=#{doc}
      --zshdir=#{zsh_completion}
    ]

    python3 = "python3.10"
    system python3, "bootstrap.py"
    system python3, "waf", "configure", *args
    system python3, "waf", "install"
  end

  test do
    fake_test = testpath/"a.log"
    touch fake_test
    assert_predicate fake_test, :exist?
  end
end
