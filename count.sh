#!/bin/sh
nasm one.asm -o one.com && ndisasm one.com && wc -c one.com

