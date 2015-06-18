#!/bin/bash

TARGET=TagImg.tgz
OUTPUT_FOLDER=cov-int

rm -f ${TARGET}
rm -rf ${OUTPUT_FOLDER}
make distclean
/opt/Qt/5.3/gcc_64/bin/qmake
/opt/cov-analysis-linux64-7.6.0/bin/cov-build --dir ${OUTPUT_FOLDER} make -j 4
tar czvf ${TARGET} ${OUTPUT_FOLDER}
