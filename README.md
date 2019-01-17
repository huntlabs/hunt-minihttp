[![Build Status](https://travis-ci.org/huntlabs/hunt-minihttp.svg?branch=master)](https://travis-ci.org/huntlabs/hunt-minihttp)

# hunt-minihttp
A mini http server based on Hunt.

### Build http-parser on Linux

```sh
$ cd http-parser
$ ./build.sh
```

### Benchmark
```sh
$ ./bench.sh Hunt-minihttp plaintext 127.0.0.1 8080
$ ./bench.sh Hunt-minihttp json 127.0.0.1 8080
```

### TODO
- [ ] Support for http-parser on Windows.
