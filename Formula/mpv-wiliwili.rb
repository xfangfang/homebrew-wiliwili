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
    rebuild 4
    sha256 cellar: :any, arm64_sequoia: "398b2e7f8abbbdec22e0371f9e936a8222164dcd5586c5ee2a6e1bc049d1ea67"
    sha256 cellar: :any, arm64_sonoma:  "c8c553ef8f4c697ad3aa1aee1d0e465baf7d9e741b209e790c64e2417fbb2151"
    sha256 cellar: :any, ventura:       "3a5f271fbd8d45611fe0f5f1c46767a6fd7a8362bb400fcf4141e1361b2d7792"
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

  # Fix missing symbol when cocoa is disabled
  patch :DATA

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

__END__
diff --git a/meson.build b/meson.build
index a02597cb68..cc4b161b7c 100644
--- a/meson.build
+++ b/meson.build
@@ -836,6 +836,7 @@ coreaudio = dependency('appleframeworks', modules: ['CoreFoundation', 'CoreAudio
 features += {'coreaudio': coreaudio.found()}
 if features['coreaudio']
     dependencies += coreaudio
+    sources += files('osdep/utils-mac.c')
     sources += files('audio/out/ao_coreaudio.c',
                      'audio/out/ao_coreaudio_exclusive.c',
                      'audio/out/ao_coreaudio_properties.c')
