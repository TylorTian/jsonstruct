class Jsonstruct < Formula
  include Language::Python::Virtualenv

  desc "CLI tool to pretty-print JSON and decode JWTs"
  homepage "https://github.com/TylorTian/jsonstruct"
  url "https://files.pythonhosted.org/packages/source/j/jsonstruct-cli/jsonstruct_cli-0.1.11.tar.gz"
  sha256 "c550397bef77e0cd6f51a969228acd91084ec6dc2be54004c9a3cfe46e4a4258"
  license "MIT"

  depends_on "python@3.11"

  resource "pyjwt" do
    url "https://files.pythonhosted.org/packages/source/p/pyjwt/pyjwt-2.10.1.tar.gz"
    sha256 "c550397bef77e0cd6f51a969228acd91084ec6dc2be54004c9a3cfe46e4a4258"
  end


  def install
    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install resources
    venv.pip_install_and_link buildpath
  end

  test do
    system "#{bin}/jsonstruct", "--help"
  end
end
