class Libcoap < Formula
  desc "Lightweight application-protocol for resource-constrained devices"
  homepage "https://github.com/obgm/libcoap"
  url "https://github.com/obgm/libcoap/archive/v4.3.0.tar.gz"
  sha256 "1a195adacd6188d3b71c476e7b21706fef7f3663ab1fb138652e8da49a9ec556"
  license "BSD-2-Clause"

  bottle do
    sha256 cellar: :any, arm64_big_sur: "d8f66e021f0ed8d227696e8e37d97085a77624aaa391fdd63f4f00326a101289"
    sha256 cellar: :any, big_sur:       "f57bd53021361886f6928bbb0156dd642bd39dbdd459e5a69951560e4cc47050"
    sha256 cellar: :any, catalina:      "344f2a098d9f1767d50135fbf4ae3bdf893a079ebf8a54f248811673fa437e39"
    sha256 cellar: :any, mojave:        "012f1efcb1655479c531df4db98eb481d83971751edffb99b4ca8c50592cd27c"
    sha256 cellar: :any, high_sierra:   "a68df19a4ca87c677173c14b534848592bb35e46a715ca066bcd114f8c735236"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "doxygen" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "openssl@1.1"

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}",
                          "--disable-examples",
                          "--disable-manpages"
    system "make"
    system "make", "install"
  end

  test do
    %w[coap-client coap-server].each do |src|
      system ENV.cc, pkgshare/"examples/#{src}.c",
        "-I#{Formula["openssl@1.1"].opt_include}", "-I#{include}",
        "-L#{Formula["openssl@1.1"].opt_lib}", "-L#{lib}",
        "-lcrypto", "-lssl", "-lcoap-3-openssl", "-o", src
    end

    port = free_port
    fork do
      exec testpath/"coap-server", "-p", port.to_s
    end

    sleep 1
    output = shell_output(testpath/"coap-client -B 5 -m get coap://localhost:#{port}")
    assert_match "This is a test server made with libcoap", output
  end
end
