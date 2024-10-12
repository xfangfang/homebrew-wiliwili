class HarfbuzzWiliwili < Formula
  desc "OpenType text shaping engine"
  homepage "https://github.com/harfbuzz/harfbuzz"
  url "https://github.com/harfbuzz/harfbuzz/archive/refs/tags/10.0.1.tar.gz"
  sha256 "e7358ea86fe10fb9261931af6f010d4358dac64f7074420ca9bc94aae2bdd542"
  license "MIT"

  head "https://github.com/harfbuzz/harfbuzz.git", branch: "main"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/harfbuzz-wiliwili-10.0.1"
    rebuild 1
    sha256 cellar: :any, arm64_sequoia: "22680a54375c8e9e949261174445c941549bf62473244d1950a1048b597270b6"
    sha256 cellar: :any, arm64_sonoma:  "ad554aec11499504f817bb23922ce78343edb25ffe540a9e7a1c4358fc211485"
    sha256 cellar: :any, ventura:       "2f076457495c39d9853d0a6067a87d518c6631f1702e558828e146d061fa02f5"
  end

  keg_only "it is intended to only be used for building wiliwili"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "freetype"

  def install
    args = %w[
      --default-library=both
      -Dcairo=disabled
      -Dcoretext=disabled
      -Dfreetype=enabled
      -Dglib=disabled
      -Dgobject=disabled
      -Dgraphite=disabled
      -Dicu=disabled
      -Dintrospection=disabled
      -Dtests=disabled
    ]

    system "meson", "setup", "build", *std_meson_args, *args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    fake_test = testpath/"a.log"
    touch fake_test
    assert_predicate fake_test, :exist?
  end
end
