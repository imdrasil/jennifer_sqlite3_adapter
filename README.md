# Jennifer SQLite3 adapter [![Build Status](https://travis-ci.org/imdrasil/jennifer_sqlite3_adapter.svg)](https://travis-ci.org/imdrasil/jennifer_sqlite3_adapter) [![Latest Release](https://img.shields.io/github/release/imdrasil/jennifer_sqlite3_adapter.svg)](https://github.com/imdrasil/jennifer_sqlite3_adapter/releases) [![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://imdrasil.github.io/jennifer_sqlite3_adapter/versions)

SQLite3 adapter for [Jennifer](https://github.com/imdrasil/jennifer.cr).

## Installation

1. Add the dependencies to your `shard.yml`:
```yaml
dependencies:
  sqlite3:
    github: crystal-lang/crystal-sqlite3
    version: "0.18.0"
  jennifer_sqlite3_adapter:
    github: imdrasil/jennifer_sqlite3_adapter
    version: "~> 0.4.0"
```

> Current adapter version is tested with `0.18.0` sqlite3 driver but other versions may also work

2. Run `shards install`

## Usage

This shard supports Jennifer `0.12.0` and above. It is tested with SQLite `3.36.0` version. Some of features may not work on older versions.

```crystal
require "jennifer"
require "jennifer_sqlite3_adapter"

Jennifer::Config.configure do |conf|
  conf.adapter = "sqlite3"
  conf.host = "."
  conf.db = "test.db"
end
```

`user` and `password` configurations are not required as SQLite doesn't provide user authentication and they are ignored. `host` options is used to specify database file folder path, `db` - file name.

### Supported data types

| Method | SQLite3 | Crystal type |
| --- | --- | --- |
| `#bool` | `INTEGER` | `Bool` |
| `#integer` | `INTEGER` | `Int32` |
| `#bigint` | `INTEGER` | `Int32` |
| `#short` | `INTEGER` | `Int32` |
| `#tinyint` | `INTEGER` | `Int32` |
| `#float`| `REAL` | `Float64` |
| `#double` | `REAL` | `Float64` |
| `#real` | `REAL` | `Float64` |
| `#text` | `TEXT` | `String` |
| `#string` | `TEXT` | `String` |
| `#varchar` | `TEXT` | `String` |
| `#time` | `TEXT` | `Time` |
| `#timestamp` | `TEXT` | `Time` |

### Altering table

SQLite has no mechanism to alter existing table (except renaming it). Therefore operations, listed below, do multiple steps to achieve altering table: coping table schema to new temp table, coping data to new table, extending new table with required options, dropping old table and renaming temp table to original name:

- dropping column
- changing column
- adding foreign key
- dropping foreign key

It is necessary to notice that all those operations keep all data and indexes.

#### Foreign key

At a startup adapter automatically enable foreign keys executing `PRAGMA foreign_keys = ON`.
But be aware using migrations - as described above, some table manipulations will recreate a table.
To avoid breaking of any foreign key, adapter will try to disable them until the end of a manipulation,
but this is possible only outside of a transaction. Therefore in a such kind of migrations add
`with_transaction false` at the class body to disable automatic transaction around migration methods.

## Contributing

1. Fork it (<https://github.com/imdrasil/jennifer_sqlite3_adapter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Roman Kalnytskyi](https://github.com/imdrasil) - creator and maintainer
