# modified from https://github.com/iina/homebrew-mpv-iina
# Last check with upstream: 356dc6f78059f1706bc8c6c44545c262dca43c3e
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mpv.rb

class MpvWiliwili < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/v0.35.0.tar.gz"
  sha256 "dc411c899a64548250c142bf1fa1aa7528f1b4398a24c86b816093999049ec00"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/mpv-wiliwili-0.35.0"
    rebuild 1
    sha256 cellar: :any, monterey: "f8af4bf3ae3d05c44be89d6be07d54bdf57c62d1867d3f62b4705a313584693d"
  end

  keg_only "it is intended to only be used for building wiliwili. This formula is not recommended for daily use"

  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.10" => :build
  depends_on xcode: :build

  depends_on "ffmpeg-wiliwili"
  depends_on "libass"

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
    # See https://github.com/mpv-player/mpv/pull/8939
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
      --disable-lua
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
