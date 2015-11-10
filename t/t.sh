#!/bin/bash
cd t
diff <(../c abce < 01.in | xxd) <(xxd 01.out)
