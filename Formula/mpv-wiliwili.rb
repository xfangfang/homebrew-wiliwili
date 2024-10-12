# modified from https://github.com/iina/homebrew-mpv-iina
# Last check with upstream: 356dc6f78059f1706bc8c6c44545c262dca43c3e
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mpv.rb

class MpvWiliwili < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.39.0.tar.gz"
  sha256 "2ca92437affb62c2b559b4419ea4785c70d023590500e8a52e95ea3ab4554683"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/mpv-wiliwili-0.39.0"
    rebuild 1
    sha256 cellar: :any, arm64_sequoia: "46f8d04b0e670264e1078fa3bfd8228bfa806d16375948ad1ec011e242452976"
    sha256 cellar: :any, arm64_sonoma:  "9d03bc0345f3809d0f013074c2ae26c4630a6de3f023dcbfd0e86e7ea02d2fbc"
    sha256 cellar: :any, ventura:       "aef0ceabbb1688e2dead86f4cc59ad570d707ade6d979ff22864de584a6bf1dd"
  end

  keg_only "it is intended to only be used for building wiliwili"

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "pkg-config" => :build
  depends_on xcode: :build

  depends_on "ffmpeg-wiliwili"
  depends_on "libass-wiliwili"
  depends_on "libplacebo-wiliwili"
  depends_on "luajit"

  def install
    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "C"

    # force meson find ninja from homebrew
    ENV["NINJA"] = Formula["ninja"].opt_bin/"ninja"

    args = %W[
      -Dlibmpv=true
      -Dcplayer=false
      -Dlua=luajit

      -Dswift-build=disabled
      -Dmacos-cocoa-cb=disabled
      -Dmacos-media-player=disabled
      -Dmacos-touchbar=disabled
      -Dcocoa=disabled

      -Dlcms2=disabled
      -Djpeg=disabled
      -Dvulkan=disabled
      -Dmanpage-build=disabled
      -Dhtml-build=disabled

      --sysconfdir=#{pkgetc}
      --datadir=#{pkgshare}
    ]

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    fake_test = testpath/"a.log"
    touch fake_test
    assert_predicate fake_test, :exist?
  end
end
