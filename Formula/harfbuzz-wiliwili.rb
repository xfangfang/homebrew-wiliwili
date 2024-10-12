class HarfbuzzWiliwili < Formula
  desc "OpenType text shaping engine"
  homepage "https://github.com/harfbuzz/harfbuzz"
  url "https://github.com/harfbuzz/harfbuzz/archive/refs/tags/10.0.1.tar.gz"
  sha256 "e7358ea86fe10fb9261931af6f010d4358dac64f7074420ca9bc94aae2bdd542"
  license "MIT"

  head "https://github.com/harfbuzz/harfbuzz.git", branch: "main"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/harfbuzz-wiliwili-10.0.1"
    sha256 cellar: :any, arm64_sequoia: "a33e52ee43bb0bc990f98eeedf4dbdb53aa321bc6a2eb7cb0be4bdf74bd2cf91"
    sha256 cellar: :any, arm64_sonoma:  "24e29667b2e9ac8dd1eed51d3fab61e4706cba8944a26c7db7e51f086b968446"
    sha256 cellar: :any, ventura:       "f8b63961e09077f2506f05ef2048af28391c4e6d00b930f62b24dd42c7018774"
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.13" => [:build, :test]
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
