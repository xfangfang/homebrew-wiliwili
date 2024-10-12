class LibassWiliwili < Formula
  desc "Subtitle renderer for the ASS/SSA subtitle format"
  homepage "https://github.com/libass/libass"
  url "https://github.com/libass/libass/releases/download/0.17.3/libass-0.17.3.tar.xz"
  sha256 "eae425da50f0015c21f7b3a9c7262a910f0218af469e22e2931462fed3c50959"
  license "ISC"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/libass-wiliwili-0.17.3"
    sha256 cellar: :any, arm64_sequoia: "190cd2617b45b49914bbf8132b89372868ace919ec366add22a3d58951dcc028"
    sha256 cellar: :any, arm64_sonoma:  "b3e0eba022d5e4f1fc39d363e1504a9edc30839a27322bbdd5a3a3aa91ed9b52"
    sha256 cellar: :any, ventura:       "337b25538c48757879f1815e83fde4427ee451499cab8b9e444e397bdf30945c"
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
