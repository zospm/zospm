#!/bin/sh
. zospmsetenv 

zospmdeploy "$1" zospmbin.bom
exit $? 
