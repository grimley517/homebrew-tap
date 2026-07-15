# frozen_string_literal: true

class Notetaker < Formula
  include Language::Python::Virtualenv

  desc "AI-powered terminal meeting note taker for MacBook (transcription + summary via Ollama)"
  homepage "https://github.com/grimley517/Notetaker"
  url "https://github.com/grimley517/homebrew-tap/releases/download/v0.2.3/notetaker-0.2.3.tar.gz"
  sha256 "e8dac039661d70bb8282bdb0052ac51e3db66e4d93ca38f628f3a025ad21abb6"
  head "https://github.com/grimley517/Notetaker.git", branch: "main"

  # Runtime dependencies provided by Homebrew
  depends_on "portaudio"           # required by sounddevice
  depends_on "ffmpeg"              # used by faster-whisper for audio decoding
  depends_on "python@3.14"
  depends_on "ollama"              # local AI – users must also run: ollama pull llama3.2

  # BlackHole is required for capturing system audio (Teams / Google Meet / speakers)
  # Installed automatically as part of the formula install step below.

  resource "click" do
    url "https://files.pythonhosted.org/packages/source/c/click/click-8.1.7.tar.gz"
    sha256 "ca9853ad459e787e2192211578cc907e7594e294c7ccc834310722b41b9ca6de"
  end

  resource "sounddevice" do
    url "https://files.pythonhosted.org/packages/source/s/sounddevice/sounddevice-0.4.6.tar.gz"
    sha256 "3236b78f15f0415bdf006a620cef073d0c0522851d66f4a961ed6d8eb1482fe9"
  end

  resource "numpy" do
    url "https://files.pythonhosted.org/packages/source/n/numpy/numpy-1.26.4.tar.gz"
    sha256 "2a02aba9ed12e4ac4eb3ea9421c420301a0c6460d9830d74a9df87efa4912010"
  end

  resource "faster-whisper" do
    url "https://files.pythonhosted.org/packages/source/f/faster-whisper/faster-whisper-1.0.3.tar.gz"
    sha256 "1a145db86450b56aaa623c8df7d4ef86e8a1159900f60533e2890e98e8453a17"
  end

  resource "ollama" do
    url "https://files.pythonhosted.org/packages/source/o/ollama/ollama-0.3.3.tar.gz"
    sha256 "f90a6d61803117f40b0e8ff17465cab5e1eb24758a473cfe8101aff38bc13b51"
  end

  resource "readchar" do
    url "https://files.pythonhosted.org/packages/source/r/readchar/readchar-4.0.5.tar.gz"
    sha256 "08a456c2d7c1888cde3f4688b542621b676eb38cd6cfed7eb6cb2e2905ddc826"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/source/r/rich/rich-13.7.1.tar.gz"
    sha256 "9be308cb1fe2f1f57d67ce99e95af38a1e2bc71ad9813b0e247cf7ffbcc3a432"
  end

  def install
    virtualenv_install_with_resources

    # Ensure BlackHole 2ch is installed – required for capturing system/speaker audio.
    unless File.directory?("/Library/Audio/Plug-Ins/HAL/BlackHole2ch.driver")
      ohai "Installing BlackHole 2ch (required for system-audio capture)…"
      system "brew", "install", "--cask", "blackhole-2ch"
    end
  end

  def post_install
    ohai "Notetaker installed!"
    ohai "Next steps:"
    ohai "  1. Start Ollama:          brew services start ollama"
    ohai "  2. Pull the default model: ollama pull llama3.2"
    ohai "  3. Create an Aggregate Device in macOS Audio MIDI Setup"
    ohai "     combining BlackHole 2ch with your microphone for full"
    ohai "     call capture (your mic + remote participants' audio)."
    ohai "  4. Start a meeting:       note start \"my-meeting\""
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/note --help")
    assert_match "start", shell_output("#{bin}/note --help")
    assert_match "summarize", shell_output("#{bin}/note --help")
    assert_match "devices", shell_output("#{bin}/note --help")
  end
end
