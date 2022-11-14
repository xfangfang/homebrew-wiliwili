# modified from https://github.com/iina/homebrew-mpv-iina
# Last check with upstream: 356dc6f78059f1706bc8c6c44545c262dca43c3e
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mpv.rb

class MpvWiliwili < Formula
    desc "Media player based on MPlayer and mplayer2"
    homepage "https://mpv.io"
    url "https://github.com/mpv-player/mpv/archive/v0.34.1.tar.gz"
    sha256 "32ded8c13b6398310fa27767378193dc1db6d78b006b70dbcbd3123a1445e746"
    head "https://github.com/mpv-player/mpv.git", branch: "master"
  
    keg_only "it is intended to only be used for building wiliwili. This formula is not recommended for daily use"
  
    depends_on "docutils" => :build
    depends_on "pkg-config" => :build
    depends_on "python@3.9" => :build
    depends_on xcode: :build
  
    depends_on "ffmpeg-wiliwili"
    depends_on "libass"
  
    def install
      # LANG is unset by default on macOS and causes issues when calling getlocale
      # or getdefaultlocale in docutils. Force the default c/posix locale since
      # that's good enough for building the manpage.
      ENV["LC_ALL"] = "C"
  
      args = %W[
        --prefix=#{prefix}
        --disable-debug-build
        --confdir=#{etc}/mpv
        --datadir=#{pkgshare}
        --mandir=#{man}
        --docdir=#{doc}
        --zshdir=#{zsh_completion}
      ]
  
      system Formula["python@3.9"].opt_bin/"python3", "bootstrap.py"
      system Formula["python@3.9"].opt_bin/"python3", "waf", "configure", *args
      system Formula["python@3.9"].opt_bin/"python3", "waf", "install"
    end
  
    test do
      system bin/"mpv", "--ao=null", test_fixtures("test.wav")
    end
  end