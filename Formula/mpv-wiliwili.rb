# modified from https://github.com/iina/homebrew-mpv-iina
# Last check with upstream: 356dc6f78059f1706bc8c6c44545c262dca43c3e
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mpv.rb

class MpvWiliwili < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/v0.36.0.tar.gz"
  sha256 "29abc44f8ebee013bb2f9fe14d80b30db19b534c679056e4851ceadf5a5e8bf6"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/mpv-wiliwili-0.36.0"
    sha256 cellar: :any, monterey: "2a786766e3f9ce1302a7854b080f10663b7df3cf1ad54741b204d0e99e43c6aa"
    sha256 cellar: :any, big_sur:  "b186bc67747447b131a11852b7656658ca545225a378b008c0c422cf5244012b"
  end

  keg_only "it is intended to only be used for building wiliwili 1"

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "pkg-config" => :build
  depends_on xcode: :build

  depends_on "ffmpeg-wiliwili@6"
  depends_on "libass"

  stable do
    # Fix cannot find macos sdk when swift-build is disabled.
    patch :DATA
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

__END__
diff --git a/meson.build b/meson.build
index f9fe4e7263..5eaea21968 100644
--- a/meson.build
+++ b/meson.build
@@ -1473,16 +1473,16 @@ endif
 
 
 # macOS features
-macos_sdk_version_py = find_program(join_paths(source_root, 'TOOLS', 'macos-sdk-version.py'),
-                                    required: get_option('swift-build').require(darwin))
-macos_sdk_path = ''
-macos_sdk_version = '0.0'
-if macos_sdk_version_py.found()
+macos_sdk_version_py = find_program(join_paths(source_root, 'TOOLS',
+                                    'macos-sdk-version.py'))
+macos_sdk_info = ['', '0.0']
+if darwin
     macos_sdk_info = run_command(macos_sdk_version_py, check: true).stdout().split(',')
-    macos_sdk_path = macos_sdk_info[0].strip()
-    macos_sdk_version = macos_sdk_info[1]
 endif
 
+macos_sdk_path = macos_sdk_info[0].strip()
+macos_sdk_version = macos_sdk_info[1]
+
 if macos_sdk_path != ''
     message('Detected macOS sdk path: ' + macos_sdk_path)
 endif