class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.1.136",
      revision: "256d72f9da2557c08327a1c05e32666b8b18e080"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  # Upstream tags versions like `v0.1.92` and `v2023.9.8` but, as of writing,
  # they only create releases for the former and those are the versions we use
  # in this formula. We could omit the date-based versions using a regex but
  # this uses the `GithubLatest` strategy, as the upstream repository also
  # contains over a thousand tags (and growing).
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "afc02d4c68241830d233b1eb85996f960db43befd63273df964ab68018e4d7c3"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "afc02d4c68241830d233b1eb85996f960db43befd63273df964ab68018e4d7c3"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "afc02d4c68241830d233b1eb85996f960db43befd63273df964ab68018e4d7c3"
    sha256 cellar: :any_skip_relocation, sonoma:         "cdfb1bd631e9331d3c78de39fb862e99c35ed2b1080cf4ef5736f08b773f14f4"
    sha256 cellar: :any_skip_relocation, ventura:        "cdfb1bd631e9331d3c78de39fb862e99c35ed2b1080cf4ef5736f08b773f14f4"
    sha256 cellar: :any_skip_relocation, monterey:       "cdfb1bd631e9331d3c78de39fb862e99c35ed2b1080cf4ef5736f08b773f14f4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "04f88085abf636c1c15774ac752fb6deb7953a7cf184319771f37aae4d3915dd"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.buildVersion=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags), "-tags", "production"

    bin.install_symlink "flyctl" => "fly"

    generate_completions_from_executable(bin/"flyctl", "completion")
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("#{bin}/flyctl status 2>&1", 1)
    assert_match "Error: No access token available. Please login with 'flyctl auth login'", flyctl_status
  end
end
