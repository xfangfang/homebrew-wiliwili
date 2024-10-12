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
    rebuild 2
    sha256 cellar: :any, arm64_sequoia: "9cc882b78a0dd91853e1098c263d17077b9c8d4d9f5ed0ce76785e98ddc8d8fa"
    sha256 cellar: :any, arm64_sonoma:  "03265219b8a26c0ad7dd3c12e7e757a1a64e182a481aa08ac8972a0253964f0e"
    sha256 cellar: :any, ventura:       "7e4bc04351809c4104dbd98a818c7ea245472813f98f4a1292ae78c2fe67b2b0"
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
      -Dcocoa=enabled

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
index a02597cb68..b5d5b4e54c 100644
--- a/meson.build
+++ b/meson.build
@@ -405,9 +405,7 @@ if features['cocoa']
     dependencies += cocoa
     sources += files('osdep/language-mac.c',
                      'osdep/path-mac.m',
-                     'osdep/utils-mac.c',
-                     'osdep/mac/app_bridge.m')
-    main_fn_source = files('osdep/main-fn-mac.c')
+                     'osdep/utils-mac.c')
 endif
 
 if posix
