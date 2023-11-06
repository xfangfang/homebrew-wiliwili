# modified from https://github.com/iina/homebrew-mpv-iina
# Last check with upstream: 356dc6f78059f1706bc8c6c44545c262dca43c3e
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mpv.rb

class MpvWiliwili < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.36.0.tar.gz"
  sha256 "29abc44f8ebee013bb2f9fe14d80b30db19b534c679056e4851ceadf5a5e8bf6"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/mpv-wiliwili-0.36.0"
    rebuild 2
    sha256 cellar: :any, monterey: "8fdeb5024fa74bf51be6d3109eb2135bb819175f623cc5d7abde029bdbb4e6f4"
  end

  keg_only "it is intended to only be used for building wiliwili 1"

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "pkg-config" => :build
  depends_on xcode: :build

  depends_on "ffmpeg-wiliwili@6"
  depends_on "libass"

  patch do
    # Fix cannot find macos sdk when swift-build is disabled.
    url "https://raw.githubusercontent.com/xfangfang/homebrew-wiliwili/ca41653396be315cefdc8942f0232366f7ff39b3/mpv_swift_patch.patch"
    sha256 "f203408d7f3c9898c24b07ec7ba16aaaa8192c466abebb4623032f506792b2de"
  end

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
      -Dlua=disabled

      -Dswift-build=disabled
      -Dmacos-cocoa-cb=disabled
      -Dmacos-media-player=disabled
      -Dmacos-touchbar=disabled

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
