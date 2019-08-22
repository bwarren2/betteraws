#!/bin/bash -x

hugo -t whiteplain
git add docs
git commit -m "rebuild"
