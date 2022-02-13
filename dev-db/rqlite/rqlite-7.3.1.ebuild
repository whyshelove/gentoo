# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit go-module
EGIT_COMMIT=0a866e2e2fb735c1baad2a0296b0a22902d0158c

DESCRIPTION="Replicated SQLite using the Raft consensus protocol"
HOMEPAGE="https://github.com/rqlite/rqlite https://www.philipotoole.com/tag/rqlite/"

EGO_SUM=(
"cloud.google.com/go v0.26.0/go.mod"
"cloud.google.com/go v0.34.0/go.mod"
"github.com/Bowery/prompt v0.0.0-20190916142128-fa8279994f75"
"github.com/Bowery/prompt v0.0.0-20190916142128-fa8279994f75/go.mod"
"github.com/BurntSushi/toml v0.3.1/go.mod"
"github.com/DataDog/datadog-go v2.2.0+incompatible/go.mod"
"github.com/DataDog/datadog-go v3.2.0+incompatible/go.mod"
"github.com/OneOfOne/xxhash v1.2.2/go.mod"
"github.com/alecthomas/template v0.0.0-20160405071501-a0175ee3bccc/go.mod"
"github.com/alecthomas/template v0.0.0-20190718012654-fb15b899a751/go.mod"
"github.com/alecthomas/units v0.0.0-20151022065526-2efee857e7cf/go.mod"
"github.com/alecthomas/units v0.0.0-20190717042225-c3de453c63f4/go.mod"
"github.com/alecthomas/units v0.0.0-20190924025748-f65c72e2690d/go.mod"
"github.com/antihax/optional v1.0.0/go.mod"
"github.com/armon/circbuf v0.0.0-20150827004946-bbbad097214e/go.mod"
"github.com/armon/go-metrics v0.0.0-20180917152333-f0300d1749da/go.mod"
"github.com/armon/go-metrics v0.0.0-20190430140413-ec5e00d3c878/go.mod"
"github.com/armon/go-metrics v0.3.10"
"github.com/armon/go-metrics v0.3.10/go.mod"
"github.com/armon/go-radix v0.0.0-20180808171621-7fddfc383310/go.mod"
"github.com/armon/go-radix v1.0.0/go.mod"
"github.com/benbjohnson/clock v1.1.0"
"github.com/benbjohnson/clock v1.1.0/go.mod"
"github.com/beorn7/perks v0.0.0-20180321164747-3a771d992973/go.mod"
"github.com/beorn7/perks v1.0.0/go.mod"
"github.com/beorn7/perks v1.0.1/go.mod"
"github.com/bgentry/speakeasy v0.1.0/go.mod"
"github.com/boltdb/bolt v1.3.1"
"github.com/boltdb/bolt v1.3.1/go.mod"
"github.com/census-instrumentation/opencensus-proto v0.2.1/go.mod"
"github.com/cespare/xxhash v1.1.0/go.mod"
"github.com/cespare/xxhash/v2 v2.1.1/go.mod"
"github.com/circonus-labs/circonus-gometrics v2.3.1+incompatible/go.mod"
"github.com/circonus-labs/circonusllhist v0.1.3/go.mod"
"github.com/client9/misspell v0.3.4/go.mod"
"github.com/cncf/udpa/go v0.0.0-20191209042840-269d4d468f6f/go.mod"
"github.com/cncf/udpa/go v0.0.0-20201120205902-5459f2c99403/go.mod"
"github.com/cncf/udpa/go v0.0.0-20210930031921-04548b0d99d4/go.mod"
"github.com/cncf/xds/go v0.0.0-20210312221358-fbca930ec8ed/go.mod"
"github.com/cncf/xds/go v0.0.0-20210805033703-aa0b78936158/go.mod"
"github.com/cncf/xds/go v0.0.0-20210922020428-25de7278fc84/go.mod"
"github.com/cncf/xds/go v0.0.0-20211011173535-cb28da3451f1/go.mod"
"github.com/coreos/go-semver v0.3.0"
"github.com/coreos/go-semver v0.3.0/go.mod"
"github.com/coreos/go-systemd/v22 v22.3.2"
"github.com/coreos/go-systemd/v22 v22.3.2/go.mod"
"github.com/davecgh/go-spew v1.1.0/go.mod"
"github.com/davecgh/go-spew v1.1.1"
"github.com/davecgh/go-spew v1.1.1/go.mod"
"github.com/dustin/go-humanize v1.0.0/go.mod"
"github.com/envoyproxy/go-control-plane v0.9.0/go.mod"
"github.com/envoyproxy/go-control-plane v0.9.1-0.20191026205805-5f8ba28d4473/go.mod"
"github.com/envoyproxy/go-control-plane v0.9.4/go.mod"
"github.com/envoyproxy/go-control-plane v0.9.9-0.20201210154907-fd9021fe5dad/go.mod"
"github.com/envoyproxy/go-control-plane v0.9.9-0.20210217033140-668b12f5399d/go.mod"
"github.com/envoyproxy/go-control-plane v0.9.9-0.20210512163311-63b5d3c536b0/go.mod"
"github.com/envoyproxy/go-control-plane v0.9.10-0.20210907150352-cf90f659a021/go.mod"
"github.com/envoyproxy/protoc-gen-validate v0.1.0/go.mod"
"github.com/fatih/color v1.7.0/go.mod"
"github.com/fatih/color v1.9.0/go.mod"
"github.com/fatih/color v1.13.0"
"github.com/fatih/color v1.13.0/go.mod"
"github.com/ghodss/yaml v1.0.0/go.mod"
"github.com/go-kit/kit v0.8.0/go.mod"
"github.com/go-kit/kit v0.9.0/go.mod"
"github.com/go-kit/log v0.1.0/go.mod"
"github.com/go-logfmt/logfmt v0.3.0/go.mod"
"github.com/go-logfmt/logfmt v0.4.0/go.mod"
"github.com/go-logfmt/logfmt v0.5.0/go.mod"
"github.com/go-stack/stack v1.8.0/go.mod"
"github.com/godbus/dbus/v5 v5.0.4/go.mod"
"github.com/gogo/protobuf v1.1.1/go.mod"
"github.com/gogo/protobuf v1.3.2"
"github.com/gogo/protobuf v1.3.2/go.mod"
"github.com/golang/glog v0.0.0-20160126235308-23def4e6c14b/go.mod"
"github.com/golang/mock v1.1.1/go.mod"
"github.com/golang/protobuf v1.2.0/go.mod"
"github.com/golang/protobuf v1.3.1/go.mod"
"github.com/golang/protobuf v1.3.2/go.mod"
"github.com/golang/protobuf v1.3.3/go.mod"
"github.com/golang/protobuf v1.4.0-rc.1/go.mod"
"github.com/golang/protobuf v1.4.0-rc.1.0.20200221234624-67d41d38c208/go.mod"
"github.com/golang/protobuf v1.4.0-rc.2/go.mod"
"github.com/golang/protobuf v1.4.0-rc.4.0.20200313231945-b860323f09d0/go.mod"
"github.com/golang/protobuf v1.4.0/go.mod"
"github.com/golang/protobuf v1.4.1/go.mod"
"github.com/golang/protobuf v1.4.2/go.mod"
"github.com/golang/protobuf v1.4.3/go.mod"
"github.com/golang/protobuf v1.5.0/go.mod"
"github.com/golang/protobuf v1.5.2"
"github.com/golang/protobuf v1.5.2/go.mod"
"github.com/google/btree v0.0.0-20180813153112-4030bb1f1f0c"
"github.com/google/btree v0.0.0-20180813153112-4030bb1f1f0c/go.mod"
"github.com/google/go-cmp v0.2.0/go.mod"
"github.com/google/go-cmp v0.3.0/go.mod"
"github.com/google/go-cmp v0.3.1/go.mod"
"github.com/google/go-cmp v0.4.0/go.mod"
"github.com/google/go-cmp v0.5.0/go.mod"
"github.com/google/go-cmp v0.5.4/go.mod"
"github.com/google/go-cmp v0.5.5"
"github.com/google/go-cmp v0.5.5/go.mod"
"github.com/google/gofuzz v1.0.0/go.mod"
"github.com/google/uuid v1.1.2/go.mod"
"github.com/grpc-ecosystem/go-grpc-prometheus v1.2.0/go.mod"
"github.com/grpc-ecosystem/grpc-gateway v1.16.0/go.mod"
"github.com/hashicorp/consul/api v1.12.0"
"github.com/hashicorp/consul/api v1.12.0/go.mod"
"github.com/hashicorp/consul/sdk v0.8.0"
"github.com/hashicorp/consul/sdk v0.8.0/go.mod"
"github.com/hashicorp/errwrap v1.0.0"
"github.com/hashicorp/errwrap v1.0.0/go.mod"
"github.com/hashicorp/go-cleanhttp v0.5.0/go.mod"
"github.com/hashicorp/go-cleanhttp v0.5.1/go.mod"
"github.com/hashicorp/go-cleanhttp v0.5.2"
"github.com/hashicorp/go-cleanhttp v0.5.2/go.mod"
"github.com/hashicorp/go-hclog v0.9.1/go.mod"
"github.com/hashicorp/go-hclog v0.12.0/go.mod"
"github.com/hashicorp/go-hclog v1.1.0"
"github.com/hashicorp/go-hclog v1.1.0/go.mod"
"github.com/hashicorp/go-immutable-radix v1.0.0/go.mod"
"github.com/hashicorp/go-immutable-radix v1.3.1"
"github.com/hashicorp/go-immutable-radix v1.3.1/go.mod"
"github.com/hashicorp/go-msgpack v0.5.3/go.mod"
"github.com/hashicorp/go-msgpack v0.5.5/go.mod"
"github.com/hashicorp/go-msgpack v1.1.5"
"github.com/hashicorp/go-msgpack v1.1.5/go.mod"
"github.com/hashicorp/go-multierror v1.0.0/go.mod"
"github.com/hashicorp/go-multierror v1.1.0"
"github.com/hashicorp/go-multierror v1.1.0/go.mod"
"github.com/hashicorp/go-retryablehttp v0.5.3/go.mod"
"github.com/hashicorp/go-rootcerts v1.0.2"
"github.com/hashicorp/go-rootcerts v1.0.2/go.mod"
"github.com/hashicorp/go-sockaddr v1.0.0"
"github.com/hashicorp/go-sockaddr v1.0.0/go.mod"
"github.com/hashicorp/go-syslog v1.0.0/go.mod"
"github.com/hashicorp/go-uuid v1.0.0/go.mod"
"github.com/hashicorp/go-uuid v1.0.1"
"github.com/hashicorp/go-uuid v1.0.1/go.mod"
"github.com/hashicorp/golang-lru v0.5.0/go.mod"
"github.com/hashicorp/golang-lru v0.5.4"
"github.com/hashicorp/golang-lru v0.5.4/go.mod"
"github.com/hashicorp/logutils v1.0.0/go.mod"
"github.com/hashicorp/mdns v1.0.4/go.mod"
"github.com/hashicorp/memberlist v0.3.0"
"github.com/hashicorp/memberlist v0.3.0/go.mod"
"github.com/hashicorp/raft v1.1.0/go.mod"
"github.com/hashicorp/raft v1.3.3"
"github.com/hashicorp/raft v1.3.3/go.mod"
"github.com/hashicorp/raft-boltdb v0.0.0-20210409134258-03c10cc3d4ea"
"github.com/hashicorp/raft-boltdb v0.0.0-20210409134258-03c10cc3d4ea/go.mod"
"github.com/hashicorp/raft-boltdb/v2 v2.2.1"
"github.com/hashicorp/raft-boltdb/v2 v2.2.1/go.mod"
"github.com/hashicorp/serf v0.9.6/go.mod"
"github.com/hashicorp/serf v0.9.7"
"github.com/hashicorp/serf v0.9.7/go.mod"
"github.com/jpillora/backoff v1.0.0/go.mod"
"github.com/json-iterator/go v1.1.6/go.mod"
"github.com/json-iterator/go v1.1.9/go.mod"
"github.com/json-iterator/go v1.1.10/go.mod"
"github.com/json-iterator/go v1.1.11/go.mod"
"github.com/julienschmidt/httprouter v1.2.0/go.mod"
"github.com/julienschmidt/httprouter v1.3.0/go.mod"
"github.com/kisielk/errcheck v1.5.0/go.mod"
"github.com/kisielk/gotool v1.0.0/go.mod"
"github.com/konsorten/go-windows-terminal-sequences v1.0.1/go.mod"
"github.com/konsorten/go-windows-terminal-sequences v1.0.3/go.mod"
"github.com/kr/logfmt v0.0.0-20140226030751-b84e30acd515/go.mod"
"github.com/kr/pretty v0.1.0/go.mod"
"github.com/kr/pretty v0.2.0/go.mod"
"github.com/kr/pty v1.1.1/go.mod"
"github.com/kr/text v0.1.0/go.mod"
"github.com/labstack/gommon v0.3.0/go.mod"
"github.com/labstack/gommon v0.3.1"
"github.com/labstack/gommon v0.3.1/go.mod"
"github.com/mattn/go-colorable v0.0.9/go.mod"
"github.com/mattn/go-colorable v0.1.2/go.mod"
"github.com/mattn/go-colorable v0.1.4/go.mod"
"github.com/mattn/go-colorable v0.1.6/go.mod"
"github.com/mattn/go-colorable v0.1.7/go.mod"
"github.com/mattn/go-colorable v0.1.9/go.mod"
"github.com/mattn/go-colorable v0.1.11/go.mod"
"github.com/mattn/go-colorable v0.1.12"
"github.com/mattn/go-colorable v0.1.12/go.mod"
"github.com/mattn/go-isatty v0.0.3/go.mod"
"github.com/mattn/go-isatty v0.0.8/go.mod"
"github.com/mattn/go-isatty v0.0.9/go.mod"
"github.com/mattn/go-isatty v0.0.10/go.mod"
"github.com/mattn/go-isatty v0.0.11/go.mod"
"github.com/mattn/go-isatty v0.0.12/go.mod"
"github.com/mattn/go-isatty v0.0.14"
"github.com/mattn/go-isatty v0.0.14/go.mod"
"github.com/matttproud/golang_protobuf_extensions v1.0.1/go.mod"
"github.com/miekg/dns v1.1.26/go.mod"
"github.com/miekg/dns v1.1.41"
"github.com/miekg/dns v1.1.41/go.mod"
"github.com/mitchellh/cli v1.1.0/go.mod"
"github.com/mitchellh/go-homedir v1.1.0"
"github.com/mitchellh/go-homedir v1.1.0/go.mod"
"github.com/mitchellh/go-testing-interface v1.0.0"
"github.com/mitchellh/go-testing-interface v1.0.0/go.mod"
"github.com/mitchellh/mapstructure v0.0.0-20160808181253-ca63d7c062ee/go.mod"
"github.com/mitchellh/mapstructure v1.1.2/go.mod"
"github.com/mitchellh/mapstructure v1.4.3"
"github.com/mitchellh/mapstructure v1.4.3/go.mod"
"github.com/mkideal/cli v0.2.7"
"github.com/mkideal/cli v0.2.7/go.mod"
"github.com/mkideal/expr v0.1.0"
"github.com/mkideal/expr v0.1.0/go.mod"
"github.com/mkideal/pkg v0.1.3"
"github.com/mkideal/pkg v0.1.3/go.mod"
"github.com/modern-go/concurrent v0.0.0-20180228061459-e0a39a4cb421/go.mod"
"github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd/go.mod"
"github.com/modern-go/reflect2 v0.0.0-20180701023420-4b7aa43c6742/go.mod"
"github.com/modern-go/reflect2 v1.0.1/go.mod"
"github.com/mwitkow/go-conntrack v0.0.0-20161129095857-cc309e4a2223/go.mod"
"github.com/mwitkow/go-conntrack v0.0.0-20190716064945-2f068394615f/go.mod"
"github.com/pascaldekloe/goe v0.0.0-20180627143212-57f6aae5913c/go.mod"
"github.com/pascaldekloe/goe v0.1.0"
"github.com/pascaldekloe/goe v0.1.0/go.mod"
"github.com/pkg/errors v0.8.0/go.mod"
"github.com/pkg/errors v0.8.1/go.mod"
"github.com/pkg/errors v0.9.1"
"github.com/pkg/errors v0.9.1/go.mod"
"github.com/pmezard/go-difflib v1.0.0"
"github.com/pmezard/go-difflib v1.0.0/go.mod"
"github.com/posener/complete v1.1.1/go.mod"
"github.com/posener/complete v1.2.3/go.mod"
"github.com/prometheus/client_golang v0.9.1/go.mod"
"github.com/prometheus/client_golang v0.9.2/go.mod"
"github.com/prometheus/client_golang v1.0.0/go.mod"
"github.com/prometheus/client_golang v1.4.0/go.mod"
"github.com/prometheus/client_golang v1.7.1/go.mod"
"github.com/prometheus/client_golang v1.11.0/go.mod"
"github.com/prometheus/client_model v0.0.0-20180712105110-5c3871d89910/go.mod"
"github.com/prometheus/client_model v0.0.0-20190129233127-fd36f4220a90/go.mod"
"github.com/prometheus/client_model v0.0.0-20190812154241-14fe0d1b01d4/go.mod"
"github.com/prometheus/client_model v0.2.0/go.mod"
"github.com/prometheus/common v0.0.0-20181126121408-4724e9255275/go.mod"
"github.com/prometheus/common v0.4.1/go.mod"
"github.com/prometheus/common v0.9.1/go.mod"
"github.com/prometheus/common v0.10.0/go.mod"
"github.com/prometheus/common v0.26.0/go.mod"
"github.com/prometheus/procfs v0.0.0-20181005140218-185b4288413d/go.mod"
"github.com/prometheus/procfs v0.0.0-20181204211112-1dc9a6cbc91a/go.mod"
"github.com/prometheus/procfs v0.0.2/go.mod"
"github.com/prometheus/procfs v0.0.8/go.mod"
"github.com/prometheus/procfs v0.1.3/go.mod"
"github.com/prometheus/procfs v0.6.0/go.mod"
"github.com/rogpeppe/fastuuid v1.2.0/go.mod"
"github.com/rqlite/go-sqlite3 v1.23.0"
"github.com/rqlite/go-sqlite3 v1.23.0/go.mod"
"github.com/rqlite/raft-boltdb v0.0.0-20211018013422-771de01086ce"
"github.com/rqlite/raft-boltdb v0.0.0-20211018013422-771de01086ce/go.mod"
"github.com/rqlite/rqlite-disco-clients v0.0.0-20220131060406-a38fe9412050"
"github.com/rqlite/rqlite-disco-clients v0.0.0-20220131060406-a38fe9412050/go.mod"
"github.com/rqlite/rqlite-disco-clients v0.0.0-20220131224204-89526395d510"
"github.com/rqlite/rqlite-disco-clients v0.0.0-20220131224204-89526395d510/go.mod"
"github.com/ryanuber/columnize v0.0.0-20160712163229-9b3edd62028f/go.mod"
"github.com/sean-/seed v0.0.0-20170313163322-e2103e2c3529"
"github.com/sean-/seed v0.0.0-20170313163322-e2103e2c3529/go.mod"
"github.com/sirupsen/logrus v1.2.0/go.mod"
"github.com/sirupsen/logrus v1.4.2/go.mod"
"github.com/sirupsen/logrus v1.6.0/go.mod"
"github.com/spaolacci/murmur3 v0.0.0-20180118202830-f09979ecbc72/go.mod"
"github.com/stretchr/objx v0.1.0/go.mod"
"github.com/stretchr/objx v0.1.1"
"github.com/stretchr/objx v0.1.1/go.mod"
"github.com/stretchr/testify v1.2.2/go.mod"
"github.com/stretchr/testify v1.3.0/go.mod"
"github.com/stretchr/testify v1.4.0/go.mod"
"github.com/stretchr/testify v1.5.1/go.mod"
"github.com/stretchr/testify v1.7.0"
"github.com/stretchr/testify v1.7.0/go.mod"
"github.com/tv42/httpunix v0.0.0-20150427012821-b75d8614f926/go.mod"
"github.com/valyala/bytebufferpool v1.0.0/go.mod"
"github.com/valyala/fasttemplate v1.0.1/go.mod"
"github.com/valyala/fasttemplate v1.2.1/go.mod"
"github.com/yuin/goldmark v1.1.27/go.mod"
"github.com/yuin/goldmark v1.2.1/go.mod"
"github.com/yuin/goldmark v1.3.5/go.mod"
"go.etcd.io/bbolt v1.3.5/go.mod"
"go.etcd.io/bbolt v1.3.6"
"go.etcd.io/bbolt v1.3.6/go.mod"
"go.etcd.io/etcd/api/v3 v3.5.1"
"go.etcd.io/etcd/api/v3 v3.5.1/go.mod"
"go.etcd.io/etcd/client/pkg/v3 v3.5.1"
"go.etcd.io/etcd/client/pkg/v3 v3.5.1/go.mod"
"go.etcd.io/etcd/client/v3 v3.5.1"
"go.etcd.io/etcd/client/v3 v3.5.1/go.mod"
"go.opentelemetry.io/proto/otlp v0.7.0/go.mod"
"go.uber.org/atomic v1.7.0/go.mod"
"go.uber.org/atomic v1.9.0"
"go.uber.org/atomic v1.9.0/go.mod"
"go.uber.org/goleak v1.1.11"
"go.uber.org/goleak v1.1.11/go.mod"
"go.uber.org/multierr v1.6.0/go.mod"
"go.uber.org/multierr v1.7.0"
"go.uber.org/multierr v1.7.0/go.mod"
"go.uber.org/zap v1.17.0/go.mod"
"go.uber.org/zap v1.20.0"
"go.uber.org/zap v1.20.0/go.mod"
"golang.org/x/crypto v0.0.0-20180904163835-0709b304e793/go.mod"
"golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2/go.mod"
"golang.org/x/crypto v0.0.0-20190923035154-9ee001bba392/go.mod"
"golang.org/x/crypto v0.0.0-20191011191535-87dc89f01550/go.mod"
"golang.org/x/crypto v0.0.0-20200622213623-75b288015ac9/go.mod"
"golang.org/x/crypto v0.0.0-20201221181555-eec23a3978ad/go.mod"
"golang.org/x/crypto v0.0.0-20220128200615-198e4374d7ed"
"golang.org/x/crypto v0.0.0-20220128200615-198e4374d7ed/go.mod"
"golang.org/x/crypto v0.0.0-20220131195533-30dcbda58838"
"golang.org/x/crypto v0.0.0-20220131195533-30dcbda58838/go.mod"
"golang.org/x/exp v0.0.0-20190121172915-509febef88a4/go.mod"
"golang.org/x/lint v0.0.0-20181026193005-c67002cb31c3/go.mod"
"golang.org/x/lint v0.0.0-20190227174305-5b3e6a55c961/go.mod"
"golang.org/x/lint v0.0.0-20190313153728-d0100b6bd8b3/go.mod"
"golang.org/x/lint v0.0.0-20190930215403-16217165b5de/go.mod"
"golang.org/x/lint v0.0.0-20210508222113-6edffad5e616/go.mod"
"golang.org/x/mod v0.1.1-0.20191105210325-c90efee705ee/go.mod"
"golang.org/x/mod v0.2.0/go.mod"
"golang.org/x/mod v0.3.0/go.mod"
"golang.org/x/mod v0.4.2/go.mod"
"golang.org/x/net v0.0.0-20180724234803-3673e40ba225/go.mod"
"golang.org/x/net v0.0.0-20180826012351-8a410e7b638d/go.mod"
"golang.org/x/net v0.0.0-20181114220301-adae6a3d119a/go.mod"
"golang.org/x/net v0.0.0-20181201002055-351d144fa1fc/go.mod"
"golang.org/x/net v0.0.0-20190108225652-1e06a53dbb7e/go.mod"
"golang.org/x/net v0.0.0-20190213061140-3a22650c66bd/go.mod"
"golang.org/x/net v0.0.0-20190311183353-d8887717615a/go.mod"
"golang.org/x/net v0.0.0-20190404232315-eb5bcb51f2a3/go.mod"
"golang.org/x/net v0.0.0-20190613194153-d28f0bde5980/go.mod"
"golang.org/x/net v0.0.0-20190620200207-3b0461eec859/go.mod"
"golang.org/x/net v0.0.0-20190923162816-aa69164e4478/go.mod"
"golang.org/x/net v0.0.0-20200226121028-0de0cce0169b/go.mod"
"golang.org/x/net v0.0.0-20200625001655-4c5254603344/go.mod"
"golang.org/x/net v0.0.0-20200707034311-ab3426394381/go.mod"
"golang.org/x/net v0.0.0-20200822124328-c89045814202/go.mod"
"golang.org/x/net v0.0.0-20201021035429-f5854403a974/go.mod"
"golang.org/x/net v0.0.0-20210226172049-e18ecbb05110/go.mod"
"golang.org/x/net v0.0.0-20210405180319-a5a99cb37ef4/go.mod"
"golang.org/x/net v0.0.0-20210410081132-afb366fc7cd1/go.mod"
"golang.org/x/net v0.0.0-20211112202133-69e39bad7dc2/go.mod"
"golang.org/x/net v0.0.0-20220127200216-cd36cc0744dd"
"golang.org/x/net v0.0.0-20220127200216-cd36cc0744dd/go.mod"
"golang.org/x/oauth2 v0.0.0-20180821212333-d2e6202438be/go.mod"
"golang.org/x/oauth2 v0.0.0-20190226205417-e64efc72b421/go.mod"
"golang.org/x/oauth2 v0.0.0-20200107190931-bf48bf16ab8d/go.mod"
"golang.org/x/sync v0.0.0-20180314180146-1d60e4601c6f/go.mod"
"golang.org/x/sync v0.0.0-20181108010431-42b317875d0f/go.mod"
"golang.org/x/sync v0.0.0-20181221193216-37e7f081c4d4/go.mod"
"golang.org/x/sync v0.0.0-20190423024810-112230192c58/go.mod"
"golang.org/x/sync v0.0.0-20190911185100-cd5d95a43a6e/go.mod"
"golang.org/x/sync v0.0.0-20201020160332-67f06af15bc9/go.mod"
"golang.org/x/sync v0.0.0-20201207232520-09787c993a3a/go.mod"
"golang.org/x/sync v0.0.0-20210220032951-036812b2e83c/go.mod"
"golang.org/x/sys v0.0.0-20180823144017-11551d06cbcc/go.mod"
"golang.org/x/sys v0.0.0-20180830151530-49385e6e1522/go.mod"
"golang.org/x/sys v0.0.0-20180905080454-ebe1bf3edb33/go.mod"
"golang.org/x/sys v0.0.0-20181116152217-5ac8a444bdc5/go.mod"
"golang.org/x/sys v0.0.0-20190215142949-d0b11bdaac8a/go.mod"
"golang.org/x/sys v0.0.0-20190222072716-a9d3bda3a223/go.mod"
"golang.org/x/sys v0.0.0-20190412213103-97732733099d/go.mod"
"golang.org/x/sys v0.0.0-20190422165155-953cdadca894/go.mod"
"golang.org/x/sys v0.0.0-20190813064441-fde4db37ae7a/go.mod"
"golang.org/x/sys v0.0.0-20190922100055-0a153f010e69/go.mod"
"golang.org/x/sys v0.0.0-20190924154521-2837fb4f24fe/go.mod"
"golang.org/x/sys v0.0.0-20191008105621-543471e840be/go.mod"
"golang.org/x/sys v0.0.0-20191026070338-33540a1f6037/go.mod"
"golang.org/x/sys v0.0.0-20200106162015-b016eb3dc98e/go.mod"
"golang.org/x/sys v0.0.0-20200116001909-b77594299b42/go.mod"
"golang.org/x/sys v0.0.0-20200122134326-e047566fdf82/go.mod"
"golang.org/x/sys v0.0.0-20200124204421-9fbb57f87de9/go.mod"
"golang.org/x/sys v0.0.0-20200202164722-d101bd2416d5/go.mod"
"golang.org/x/sys v0.0.0-20200223170610-d5e6a3e2c0ae/go.mod"
"golang.org/x/sys v0.0.0-20200323222414-85ca7c5b95cd/go.mod"
"golang.org/x/sys v0.0.0-20200615200032-f1bc736245b1/go.mod"
"golang.org/x/sys v0.0.0-20200625212154-ddb9806d33ae/go.mod"
"golang.org/x/sys v0.0.0-20200923182605-d9f96fdee20d/go.mod"
"golang.org/x/sys v0.0.0-20200930185726-fdedc70b468f/go.mod"
"golang.org/x/sys v0.0.0-20201119102817-f84b799fce68/go.mod"
"golang.org/x/sys v0.0.0-20210124154548-22da62e12c0c/go.mod"
"golang.org/x/sys v0.0.0-20210303074136-134d130e1a04/go.mod"
"golang.org/x/sys v0.0.0-20210330210617-4fbd30eecc44/go.mod"
"golang.org/x/sys v0.0.0-20210403161142-5e06dd20ab57/go.mod"
"golang.org/x/sys v0.0.0-20210423082822-04245dca01da/go.mod"
"golang.org/x/sys v0.0.0-20210510120138-977fb7262007/go.mod"
"golang.org/x/sys v0.0.0-20210603081109-ebe580a85c40/go.mod"
"golang.org/x/sys v0.0.0-20210615035016-665e8c7367d1/go.mod"
"golang.org/x/sys v0.0.0-20210630005230-0f9fa26af87c/go.mod"
"golang.org/x/sys v0.0.0-20210927094055-39ccf1dd6fa6/go.mod"
"golang.org/x/sys v0.0.0-20211103235746-7861aae1554b/go.mod"
"golang.org/x/sys v0.0.0-20211216021012-1d35b9e2eb4e/go.mod"
"golang.org/x/sys v0.0.0-20220128215802-99c3d69c2c27"
"golang.org/x/sys v0.0.0-20220128215802-99c3d69c2c27/go.mod"
"golang.org/x/term v0.0.0-20201117132131-f5c789dd3221/go.mod"
"golang.org/x/term v0.0.0-20201126162022-7de9c90e9dd1/go.mod"
"golang.org/x/term v0.0.0-20210927222741-03fcf44c2211"
"golang.org/x/term v0.0.0-20210927222741-03fcf44c2211/go.mod"
"golang.org/x/text v0.3.0/go.mod"
"golang.org/x/text v0.3.2/go.mod"
"golang.org/x/text v0.3.3/go.mod"
"golang.org/x/text v0.3.5/go.mod"
"golang.org/x/text v0.3.6/go.mod"
"golang.org/x/text v0.3.7"
"golang.org/x/text v0.3.7/go.mod"
"golang.org/x/tools v0.0.0-20180917221912-90fa682c2a6e/go.mod"
"golang.org/x/tools v0.0.0-20190114222345-bf090417da8b/go.mod"
"golang.org/x/tools v0.0.0-20190226205152-f727befe758c/go.mod"
"golang.org/x/tools v0.0.0-20190311212946-11955173bddd/go.mod"
"golang.org/x/tools v0.0.0-20190424220101-1e8e1cfdf96b/go.mod"
"golang.org/x/tools v0.0.0-20190524140312-2c0ae7006135/go.mod"
"golang.org/x/tools v0.0.0-20190907020128-2ca718005c18/go.mod"
"golang.org/x/tools v0.0.0-20191119224855-298f0cb1881e/go.mod"
"golang.org/x/tools v0.0.0-20200130002326-2f3ba24bd6e7/go.mod"
"golang.org/x/tools v0.0.0-20200619180055-7c47624df98f/go.mod"
"golang.org/x/tools v0.0.0-20210106214847-113979e3529a/go.mod"
"golang.org/x/tools v0.1.2/go.mod"
"golang.org/x/tools v0.1.5/go.mod"
"golang.org/x/xerrors v0.0.0-20190717185122-a985d3407aa7/go.mod"
"golang.org/x/xerrors v0.0.0-20191011141410-1b5146add898/go.mod"
"golang.org/x/xerrors v0.0.0-20191204190536-9bdfabe68543/go.mod"
"golang.org/x/xerrors v0.0.0-20200804184101-5ec99f83aff1"
"golang.org/x/xerrors v0.0.0-20200804184101-5ec99f83aff1/go.mod"
"google.golang.org/appengine v1.1.0/go.mod"
"google.golang.org/appengine v1.4.0/go.mod"
"google.golang.org/genproto v0.0.0-20180817151627-c66870c02cf8/go.mod"
"google.golang.org/genproto v0.0.0-20190819201941-24fa4b261c55/go.mod"
"google.golang.org/genproto v0.0.0-20200513103714-09dca8ec2884/go.mod"
"google.golang.org/genproto v0.0.0-20200526211855-cb27e3aa2013/go.mod"
"google.golang.org/genproto v0.0.0-20210602131652-f16073e35f0c/go.mod"
"google.golang.org/genproto v0.0.0-20220126215142-9970aeb2e350"
"google.golang.org/genproto v0.0.0-20220126215142-9970aeb2e350/go.mod"
"google.golang.org/grpc v1.19.0/go.mod"
"google.golang.org/grpc v1.23.0/go.mod"
"google.golang.org/grpc v1.25.1/go.mod"
"google.golang.org/grpc v1.27.0/go.mod"
"google.golang.org/grpc v1.33.1/go.mod"
"google.golang.org/grpc v1.36.0/go.mod"
"google.golang.org/grpc v1.38.0/go.mod"
"google.golang.org/grpc v1.40.0/go.mod"
"google.golang.org/grpc v1.44.0"
"google.golang.org/grpc v1.44.0/go.mod"
"google.golang.org/protobuf v0.0.0-20200109180630-ec00e32a8dfd/go.mod"
"google.golang.org/protobuf v0.0.0-20200221191635-4d8936d0db64/go.mod"
"google.golang.org/protobuf v0.0.0-20200228230310-ab0ca4ff8a60/go.mod"
"google.golang.org/protobuf v1.20.1-0.20200309200217-e05f789c0967/go.mod"
"google.golang.org/protobuf v1.21.0/go.mod"
"google.golang.org/protobuf v1.22.0/go.mod"
"google.golang.org/protobuf v1.23.0/go.mod"
"google.golang.org/protobuf v1.23.1-0.20200526195155-81db48ad09cc/go.mod"
"google.golang.org/protobuf v1.25.0/go.mod"
"google.golang.org/protobuf v1.26.0-rc.1/go.mod"
"google.golang.org/protobuf v1.26.0/go.mod"
"google.golang.org/protobuf v1.27.1"
"google.golang.org/protobuf v1.27.1/go.mod"
"gopkg.in/alecthomas/kingpin.v2 v2.2.6/go.mod"
"gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod"
"gopkg.in/check.v1 v1.0.0-20180628173108-788fd7840127/go.mod"
"gopkg.in/check.v1 v1.0.0-20190902080502-41f04d3bba15/go.mod"
"gopkg.in/yaml.v2 v2.2.1/go.mod"
"gopkg.in/yaml.v2 v2.2.2/go.mod"
"gopkg.in/yaml.v2 v2.2.3/go.mod"
"gopkg.in/yaml.v2 v2.2.4/go.mod"
"gopkg.in/yaml.v2 v2.2.5/go.mod"
"gopkg.in/yaml.v2 v2.2.8/go.mod"
"gopkg.in/yaml.v2 v2.3.0"
"gopkg.in/yaml.v2 v2.3.0/go.mod"
"gopkg.in/yaml.v3 v3.0.0-20200313102051-9f266ea9e77c/go.mod"
"gopkg.in/yaml.v3 v3.0.0-20210107192922-496545a6307b"
"gopkg.in/yaml.v3 v3.0.0-20210107192922-496545a6307b/go.mod"
"honnef.co/go/tools v0.0.0-20190102054323-c2f93a96b099/go.mod"
"honnef.co/go/tools v0.0.0-20190523083050-ea95bdfd59fc/go.mod"
"sigs.k8s.io/yaml v1.2.0/go.mod"
)
go-module_set_globals
SRC_URI="https://github.com/rqlite/rqlite/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_SUM_SRC_URI}"

LICENSE="MIT Apache-2.0 BSD CC0-1.0 MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_compile() {
	GOBIN="${S}/bin" \
		go install \
			-ldflags="-X main.version=v${PV}
				-X main.branch=master
				-X main.commit=${EGIT_COMMIT}
				-X main.buildtime=$(date +%Y-%m-%dT%T%z)" \
			./cmd/... || die
}

src_test() {
	GOBIN="${S}/bin" \
		go test ./... || die
}

src_install() {
	dobin bin/*
	dodoc -r *.md DOC
}
