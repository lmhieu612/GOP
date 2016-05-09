#!/bin/sh
JOB_NUM=128
JOB_PARALLEL=16
JOB_MEM=30G
echo "Co len cac anh em oi"
rm cee.o
rm cee.e
qsub -l h=!detection -cwd -t 1-${JOB_NUM} -tc ${JOB_PARALLEL} -l mem_free=${JOB_MEM} -m ea -o ./cee.o -e ./cee.e ./chenjob.sh ${JOB_NUM}
exit 0;

