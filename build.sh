#!/bin/bash

cd build

meson compile

cd ..

mv build/lists ./
