class LibassWiliwili < Formula
  desc "Subtitle renderer for the ASS/SSA subtitle format"
  homepage "https://github.com/libass/libass"
  url "https://github.com/libass/libass/releases/download/0.17.3/libass-0.17.3.tar.xz"
  sha256 "eae425da50f0015c21f7b3a9c7262a910f0218af469e22e2931462fed3c50959"
  license "ISC"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/libass-wiliwili-0.17.3"
    rebuild 1
    sha256 cellar: :any, arm64_sequoia: "49b6739981756bd117cb9b274f97f1a8cf4ca0eae5b41f1854bf360ed814457f"
    sha256 cellar: :any, arm64_sonoma:  "94dfc9a3b636c9307de02e2d1202cdd86ddcbd2bd34c7768a968c2499c8130ce"
    sha256 cellar: :any, ventura:       "4da7c3542e385acbac871218b518d42097714bdd5391a4c70c79c6b7f9cce1b2"
  end

  head do
    url "https://github.com/libass/libass.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only "it is intended to only be used for building wiliwili"

  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "fribidi"
  depends_on "harfbuzz-wiliwili"
  depends_on "libunibreak"

  on_linux do
    depends_on "fontconfig"
  end

  on_intel do
    depends_on "nasm" => :build
  end

  def install
    system "autoreconf", "-i" if build.head?
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]
    # libass uses coretext on macOS, fontconfig on Linux
    args << "--disable-fontconfig" if OS.mac?
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "ass/ass.h"
      int main() {
        ASS_Library *library;
        ASS_Renderer *renderer;
        library = ass_library_init();
        if (library) {
          renderer = ass_renderer_init(library);
          if (renderer) {
            ass_renderer_done(renderer);
            ass_library_done(library);
            return 0;
          }
          else {
            ass_library_done(library);
            return 1;
          }
        }
        else {
          return 1;
        }
      }
    EOS
    system ENV.cc, "test.cpp", "-I#{include}", "-L#{lib}", "-lass", "-o", "test"
    system "./test"
  end
end
