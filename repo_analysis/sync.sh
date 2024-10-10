#!/bin/sh
set -e

github-to-sqlite pull-requests github.db chicago-tool-library/circulate
github-to-sqlite contributors github.db chicago-tool-library/circulate