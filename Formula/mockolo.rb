class Mockolo < Formula
  desc "Efficient Mock Generator for Swift"
  homepage "https://github.com/uber/mockolo"
  url "https://github.com/uber/mockolo/archive/1.2.5.tar.gz"
  sha256 "19ce43eab69b67b7b7d3d2f084c311bf2e04a5809965535dba48861e301257b7"
  license "Apache-2.0"

  bottle do
    cellar :any_skip_relocation
    sha256 "bdd3e1e7f25173c2d7c8a3c924a29c6528d804a3a6eaa54a4a50d8de50ce0b86" => :catalina
  end

  depends_on xcode: ["11.4", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/mockolo"
  end

  test do
    (testpath/"testfile.swift").write("
    /// @mockable
    public protocol Foo {
        var num: Int { get set }
        func bar(arg: Float) -> String
    }")
    system "#{bin}/mockolo", "-srcs", testpath/"testfile.swift", "-d", testpath/"GeneratedMocks.swift"
    assert_predicate testpath/"GeneratedMocks.swift", :exist?
    assert_equal "
    ///
    /// @Generated by Mockolo
    ///
    public class FooMock: Foo {
      public init() { }
      public init(num: Int = 0) {
          self.num = num
      }

      public var numSetCallCount = 0
      public var num: Int = 0 { didSet { numSetCallCount += 1 } }

      public var barCallCount = 0
      public var barHandler: ((Float) -> (String))?
      public func bar(arg: Float) -> String {
          barCallCount += 1
          if let barHandler = barHandler {
              return barHandler(arg)
          }
          return \"\"
      }
    }".gsub(/\s+/, "").strip, shell_output("cat #{testpath/"GeneratedMocks.swift"}").gsub(/\s+/, "").strip
  end
end