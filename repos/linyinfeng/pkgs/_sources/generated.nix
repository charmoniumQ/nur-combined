# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  aws-sigv4-proxy = {
    pname = "aws-sigv4-proxy";
    version = "645ae6a38d7f244d041f7b35374cc3a1ecdf59d1";
    src = fetchgit {
      url = "https://github.com/awslabs/aws-sigv4-proxy.git";
      rev = "645ae6a38d7f244d041f7b35374cc3a1ecdf59d1";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-OdKmweKULSZLgYMx26iw1mEvBDSCVRpA0+g8jFTiECY=";
    };
    date = "2023-03-02";
  };
  clash-for-windows = {
    pname = "clash-for-windows";
    version = "0.20.17";
    src = fetchurl {
      url = "https://github.com/Fndroid/clash_for_windows_pkg/releases/download/0.20.17/Clash.for.Windows-0.20.17-x64-linux.tar.gz";
      sha256 = "sha256-Ya7umEaEGL6ZyJNDGYFXvjMTB3yYKXNFFce/EJKx4ek=";
    };
  };
  clash-premium-aarch64-linux = {
    pname = "clash-premium-aarch64-linux";
    version = "2023.03.03";
    src = fetchurl {
      url = "https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-arm64-2023.03.03.gz";
      sha256 = "sha256-8kNNG1fUn4i7mwzMzSkW3/lrw/9vO5xpxVeV1ZK7WaY=";
    };
  };
  clash-premium-i686-linux = {
    pname = "clash-premium-i686-linux";
    version = "2023.03.03";
    src = fetchurl {
      url = "https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-386-2023.03.03.gz";
      sha256 = "sha256-i3vGzpw309czrNEc9Zg5kbloCGAI9apHgHSN8uMdatY=";
    };
  };
  clash-premium-x86_64-darwin = {
    pname = "clash-premium-x86_64-darwin";
    version = "2023.03.03";
    src = fetchurl {
      url = "https://github.com/Dreamacro/clash/releases/download/premium/clash-darwin-amd64-2023.03.03.gz";
      sha256 = "sha256-xexCmzrhk7th/EnySDO3I1KBHHRxsL9W3MRwRa7U4zQ=";
    };
  };
  clash-premium-x86_64-linux = {
    pname = "clash-premium-x86_64-linux";
    version = "2023.03.03";
    src = fetchurl {
      url = "https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-2023.03.03.gz";
      sha256 = "sha256-utvuXEv3hqUSnzHjBVNMCTxGSk8ck5w0dpyR6k9j/w0=";
    };
  };
  commit-notifier = {
    pname = "commit-notifier";
    version = "fdd7b1beb928ae2a778dd024a8cbd7b5fd6883f5";
    src = fetchgit {
      url = "https://github.com/linyinfeng/commit-notifier.git";
      rev = "fdd7b1beb928ae2a778dd024a8cbd7b5fd6883f5";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-YFzsodASfQzucrgPV3n48Wbu/yWXP7323dSkoVuKYJE=";
    };
    cargoLock."Cargo.lock" = {
      lockFile = ./commit-notifier-fdd7b1beb928ae2a778dd024a8cbd7b5fd6883f5/Cargo.lock;
      outputHashes = { };
    };
    date = "2023-03-01";
  };
  dot-tar = {
    pname = "dot-tar";
    version = "d8da4cbb76bd697c1daaef0bae52c74eb0c9831d";
    src = fetchgit {
      url = "https://github.com/linyinfeng/dot-tar.git";
      rev = "d8da4cbb76bd697c1daaef0bae52c74eb0c9831d";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-jBsV9H7ednBF+NkfZMRh16F+/7l/Ku5pjAa/CY4X7So=";
    };
    cargoLock."Cargo.lock" = {
      lockFile = ./dot-tar-d8da4cbb76bd697c1daaef0bae52c74eb0c9831d/Cargo.lock;
      outputHashes = { };
    };
    date = "2023-03-01";
  };
  dpt-rp1-py = {
    pname = "dpt-rp1-py";
    version = "v0.1.16";
    src = fetchFromGitHub ({
      owner = "janten";
      repo = "dpt-rp1-py";
      rev = "v0.1.16";
      fetchSubmodules = false;
      sha256 = "sha256-cq9yHBQyqzlEb1Dvpx90MIixT8PxB8TBKv3+nFYCbn8=";
    });
  };
  icalingua-plus-plus = {
    pname = "icalingua-plus-plus";
    version = "v2.9.1";
    src = fetchurl {
      url = "https://github.com/icalingua-plus-plus/icalingua-plus-plus/releases/download/v2.9.1/app-x86_64.asar";
      sha256 = "sha256-0LmWNcYN7RRn7fnFx56w8Umz+RvsgidbS/XBHeZwj8k=";
    };
  };
  mstickereditor = {
    pname = "mstickereditor";
    version = "v0.3.1";
    src = fetchFromGitHub ({
      owner = "LuckyTurtleDev";
      repo = "mstickereditor";
      rev = "v0.3.1";
      fetchSubmodules = false;
      sha256 = "sha256-pcdyfltDnU6I6cIGc1Gw6Y9b7oyAN/GLgtBbPq1pRfE=";
    });
    cargoLock."Cargo.lock" = {
      lockFile = ./mstickereditor-v0.3.1/Cargo.lock;
      outputHashes = { };
    };
  };
  plugin-bang-bang = {
    pname = "plugin-bang-bang";
    version = "816c66df34e1cb94a476fa6418d46206ef84e8d3";
    src = fetchgit {
      url = "https://github.com/oh-my-fish/plugin-bang-bang";
      rev = "816c66df34e1cb94a476fa6418d46206ef84e8d3";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-35xXBWCciXl4jJrFUUN5NhnHdzk6+gAxetPxXCv4pDc=";
    };
    date = "2022-11-27";
  };
  plugin-git = {
    pname = "plugin-git";
    version = "1c1d7730edd700ad8c8ddb0dac69ac419265f767";
    src = fetchgit {
      url = "https://github.com/jhillyerd/plugin-git";
      rev = "1c1d7730edd700ad8c8ddb0dac69ac419265f767";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-CCIrcR2y3Qdw0TpUO03WfxpgDnJDipg9Vl/FEjZa6vY=";
    };
    date = "2023-02-28";
  };
  replay-fish = {
    pname = "replay-fish";
    version = "1.2.1";
    src = fetchFromGitHub ({
      owner = "jorgebucaran";
      repo = "replay.fish";
      rev = "1.2.1";
      fetchSubmodules = false;
      sha256 = "sha256-bM6+oAd/HXaVgpJMut8bwqO54Le33hwO9qet9paK1kY=";
    });
  };
  rime-bopomofo = {
    pname = "rime-bopomofo";
    version = "c7618f4f5728e1634417e9d02ea50d82b71956ab";
    src = fetchgit {
      url = "https://github.com/rime/rime-bopomofo.git";
      rev = "c7618f4f5728e1634417e9d02ea50d82b71956ab";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-BoX0ueVymXaMt4nAKQz9hRrP8AQrAmUxXhbzLMG25zw=";
    };
    date = "2021-01-31";
  };
  rime-cangjie = {
    pname = "rime-cangjie";
    version = "8dfad9e537f18821b71ba28773315d9c670ae245";
    src = fetchgit {
      url = "https://github.com/rime/rime-cangjie.git";
      rev = "8dfad9e537f18821b71ba28773315d9c670ae245";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-fmWGgYqWndCpDUV6nzx0zjkcf5AcVeDIYwp0023iMwk=";
    };
    date = "2021-02-23";
  };
  rime-essay = {
    pname = "rime-essay";
    version = "e0519d0579722a0871efb68189272cba61a7350b";
    src = fetchgit {
      url = "https://github.com/rime/rime-essay.git";
      rev = "e0519d0579722a0871efb68189272cba61a7350b";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-/GLyb3pVm5YzhuBWWJs75JtKZVnFXFN3s7HT+TZC4bw=";
    };
    date = "2023-02-04";
  };
  rime-ice = {
    pname = "rime-ice";
    version = "787a7840e9a0d679143f49ae191514ef0631d713";
    src = fetchgit {
      url = "https://github.com/iDvel/rime-ice.git";
      rev = "787a7840e9a0d679143f49ae191514ef0631d713";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-gdhDRZaunQI3NbGjVBK0K9GavjmzuiFVmXycmHAZhRk=";
    };
    date = "2023-03-03";
  };
  rime-luna-pinyin = {
    pname = "rime-luna-pinyin";
    version = "79aeae200a7370720be98232844c0715f277e1c0";
    src = fetchgit {
      url = "https://github.com/rime/rime-luna-pinyin.git";
      rev = "79aeae200a7370720be98232844c0715f277e1c0";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-+pqjpYfXTdou8EofFsjUyArOs+CjJchwXbMVhGFxbhs=";
    };
    date = "2023-02-04";
  };
  rime-prelude = {
    pname = "rime-prelude";
    version = "dd84abecc33f0b05469f1d744e32d2b60b3529e3";
    src = fetchgit {
      url = "https://github.com/rime/rime-prelude.git";
      rev = "dd84abecc33f0b05469f1d744e32d2b60b3529e3";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-r3jx/iCUOxBFLYhmHEuSFxzmHg8l6vnuONmsjbtBlpM=";
    };
    date = "2022-04-10";
  };
  rime-stroke = {
    pname = "rime-stroke";
    version = "c8bc4050d4d667be8f3f4892ab96e4d0881865a4";
    src = fetchgit {
      url = "https://github.com/rime/rime-stroke.git";
      rev = "c8bc4050d4d667be8f3f4892ab96e4d0881865a4";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-XJMbmJK6CDYYgxPUMnULm5uJEgU6UF2WzrRlGKQf4yg=";
    };
    date = "2023-02-04";
  };
  rime-terra-pinyin = {
    pname = "rime-terra-pinyin";
    version = "9427853de91d645d9aca9ceace8fe9e9d8bc5b50";
    src = fetchgit {
      url = "https://github.com/rime/rime-terra-pinyin.git";
      rev = "9427853de91d645d9aca9ceace8fe9e9d8bc5b50";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-93Kzph4q8LCNYTMk3rjO7mXwzfyF4cHnuDAQrxWOPDg=";
    };
    date = "2023-02-06";
  };
  synapse-s3-storage-provider = {
    pname = "synapse-s3-storage-provider";
    version = "v1.2.0+ci-fix";
    src = fetchFromGitHub ({
      owner = "matrix-org";
      repo = "synapse-s3-storage-provider";
      rev = "v1.2.0+ci-fix";
      fetchSubmodules = false;
      sha256 = "sha256-1IKigzsbwToKZJ7/Ek9dTptZ4bDEWpLL1fVzWGC+6RU=";
    });
  };
  telegram-send = {
    pname = "telegram-send";
    version = "34d7703754d441a6f4c4a7b5b3210759d36078e2";
    src = fetchgit {
      url = "https://github.com/rahiel/telegram-send.git";
      rev = "34d7703754d441a6f4c4a7b5b3210759d36078e2";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-/+hNnUT7kA19wpiHGNPVMQGostjoaDzHd91WYruJq0w=";
    };
    date = "2022-05-13";
  };
  tg-send = {
    pname = "tg-send";
    version = "2e1372c895bc113d4e69325d583355c1a855060f";
    src = fetchgit {
      url = "https://github.com/linyinfeng/tg-send.git";
      rev = "2e1372c895bc113d4e69325d583355c1a855060f";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-qokMKkb/p0vJmvCn1TABlVYOPqP6n3VJ9UB5+CfYw9U=";
    };
    cargoLock."Cargo.lock" = {
      lockFile = ./tg-send-2e1372c895bc113d4e69325d583355c1a855060f/Cargo.lock;
      outputHashes = { };
    };
    date = "2023-01-20";
  };
  trojan = {
    pname = "trojan";
    version = "v1.16.0";
    src = fetchFromGitHub ({
      owner = "trojan-gfw";
      repo = "trojan";
      rev = "v1.16.0";
      fetchSubmodules = false;
      sha256 = "sha256-fCoZEXQ6SL++QXP6GlNYIyFaVhQ8EWelJ33VbYiHRGw=";
    });
  };
  vlmcsd = {
    pname = "vlmcsd";
    version = "svn1113";
    src = fetchFromGitHub ({
      owner = "Wind4";
      repo = "vlmcsd";
      rev = "svn1113";
      fetchSubmodules = false;
      sha256 = "sha256-OKysOm44T9wrAaopp9HfLlox5InlpV33AHGXRSjhDqc=";
    });
  };
  wemeet = {
    pname = "wemeet";
    version = "3.12.0.400";
    src = fetchurl {
      url = "https://updatecdn.meeting.qq.com/cos/e078bf97365540d9f0ff063f93372a9c/TencentMeeting_0300000000_3.12.0.400_x86_64_default.publish.deb";
      sha256 = "sha256-NN09Sm8IepV0tkosqC3pSor4/db4iF11XcGAuN/iOpM=";
    };
  };
  yacd = {
    pname = "yacd";
    version = "v0.3.8";
    src = fetchurl {
      url = "https://github.com/haishanh/yacd/releases/download/v0.3.8/yacd.tar.xz";
      sha256 = "sha256-1dfs3pGnCKeThhFnU+MqWfMsjLjuyA3tVsOrlOURulA=";
    };
  };
  zeronsd = {
    pname = "zeronsd";
    version = "v0.5.2";
    src = fetchFromGitHub ({
      owner = "zerotier";
      repo = "zeronsd";
      rev = "v0.5.2";
      fetchSubmodules = false;
      sha256 = "sha256-TL0bgzQgge6j1SpZCdxv/s4pBMSg4/3U5QisjkVE6BE=";
    });
    cargoLock."Cargo.lock" = {
      lockFile = ./zeronsd-v0.5.2/Cargo.lock;
      outputHashes = { };
    };
  };
}
