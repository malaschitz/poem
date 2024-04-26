#!/bin/sh

flutter clean 

flutter build web  --release

flutter build ios --release 

flutter build apk --release
