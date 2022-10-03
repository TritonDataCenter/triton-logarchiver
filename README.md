<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2019 Joyent, Inc.
    Copyright 2022 MNX Cloud, Inc.
-->

# triton-logarchiver

This repository is part of the Triton Data Center project. See the [contribution
guidelines](https://github.com/TritonDataCenter/triton/blob/master/CONTRIBUTING.md)
and general documentation at the main
[Triton project](https://github.com/TritonDataCenter/triton) page.

# Overview

This repo is used to build the image for the Log Archiver Triton core service.

This image uses the code from `sdc-hermes.git` as a git submodule in order to
setup Hermes into a zone different than the one created from `sdc-sdc.git`.

## Development & Testing

This repository is used only to build Log Archiver service images, for
development and testing refer to `sdc-hermes.git`.

## License

"Triton Log Archiver" is licensed under the
[Mozilla Public License version 2.0](http://mozilla.org/MPL/2.0/).
See the file LICENSE.
