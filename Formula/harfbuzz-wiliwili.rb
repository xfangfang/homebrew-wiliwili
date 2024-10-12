class HarfbuzzWiliwili < Formula
  desc "OpenType text shaping engine"
  homepage "https://github.com/harfbuzz/harfbuzz"
  url "https://github.com/harfbuzz/harfbuzz/archive/refs/tags/10.0.1.tar.gz"
  sha256 "e7358ea86fe10fb9261931af6f010d4358dac64f7074420ca9bc94aae2bdd542"
  license "MIT"
  revision 1

  head "https://github.com/harfbuzz/harfbuzz.git", branch: "main"

  bottle do
    root_url "https://github.com/xfangfang/homebrew-wiliwili/releases/download/harfbuzz-wiliwili-10.0.1_1"
    sha256 cellar: :any, arm64_sequoia: "27fd1681947d3010bd62a02823c3b6ee0442242c6a38a11e2e217c43cc4627ef"
    sha256 cellar: :any, arm64_sonoma:  "c39b88bc2fcf6bb7f7c75a44c23c0a7a1dc49e2efa965d44f4452ba9f102be0d"
    sha256 cellar: :any, ventura:       "89958708362b1b00d54c7313def293380fb78c47bed11395ae9977b65dbfc0e7"
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
