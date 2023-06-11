#!/bin/bash

function hex2bin() {
    # hex -> bin
    # e.g.
    # "0x000000ff" -> "0000 0000 0000 0000 0000 0000 1111 1111"
    hex=$1
    binary=$(echo "obase=2; ibase=16; ${hex:2}" | bc)

    while [ ${#binary} -lt 32 ]; do
        binary="0${binary}"
    done

    result=""

    for (( i=0; i<${#binary}; i+=4 )); do
        result="${result} ${binary:$i:4}"
    done

    echo ${result:1}
}

# $1=phyaddr
# $2=number of detect edge event
# width = word(32bit) access only

if [ "$1" = "" ]; then
    echo "set 1st arg=phy_addr"
    exit 1
else
    readaddr=$1
fi

if [ "$2" = "" ]; then
    event_detect_num=1
else
    event_detect_num=$2
fi

printf "paddr= 0x%08X\n" "${readaddr}"
echo "total_detections= ${event_detect_num}"
echo "Wait reg value change event..."
echo ""

start_ms=$(date +'%s.%4N')
before_time=${start_ms}

data_tmp_old=$(./devmem2 ${readaddr} word |sed -n '/Value/p'|awk '{print $6 }')
data_tmp=$data_tmp_old

i=${event_detect_num}
count=1

while [ ${i} -ne 0 ]
do
    while [ ${data_tmp_old} = ${data_tmp} ]
    do
        data_tmp_old=$data_tmp
        data_tmp=$(./devmem2 ${readaddr} word |sed -n '/Value/p'|awk '{print $6 }')
        #echo $data_tmp
    done

    # time stamp
    now_time=$(date +'%s.%4N')
    timestamp=$(echo "scale=4; ${now_time} - ${start_ms}"|bc)
    echo "event= ${count}"
    diff_time=$(echo "scale=4; ${now_time} - ${before_time}"|bc)
    before_time=${now_time}
    echo "elapsed_time[sec]= ${timestamp}  event[${count}-$(echo "${count} - 1"|bc)]diff_time[sec]= ${diff_time}"

    # echo values
    bin_data_tmp_old=$(hex2bin ${data_tmp_old})
    bin_data_tmp=$(hex2bin ${data_tmp})
    printf "before= 0x%08X    0b" "${data_tmp_old}"
    echo "${bin_data_tmp_old}"
    printf "after=  0x%08X    0b" "${data_tmp}"
    echo "${bin_data_tmp}"
    echo ""

    data_tmp_old=$data_tmp
    i=$(expr $i - 1)
    count=$(expr ${count} + 1)
done

exit 0