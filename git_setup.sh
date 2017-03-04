#!/usr/bin/env bash

git remote rm origin
git remote rm upstream
git remote rm stefan-scherer
git remote rm github
git remote rm appheads

set -e

git remote add stefan-scherer https://github.com/StefanScherer/packer-windows.git
git remote add github git@github.com:mxl/packer-windows.git
git remote add appheads ssh://git@gitlab.appheads.ru:2022/packer/packer-windows.git
git fetch --all

git branch -u stefan-scherer/master master
git branch -u stefan-scherer/my stefan-scherer
git branch -u appheads/michael-ledin michael-ledin

