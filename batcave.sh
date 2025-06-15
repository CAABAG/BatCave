#!/bin/bash

number_regex=[0-9]+

function usage
{
    echo "$basename $0 [args]"
    echo
    echo "Args:"
    echo " -h | --help    - display this message"
    echo " -d | --device  - device to return the battery level of"
    echo " -s | --support - display a list of supported devices"
    echo
}

function list_supported_devices
{
    echo "G502 G633 G635 G915 G933 G935"
}

function get_level_solaar
{
    local device=$1
    local -n battery_level_ref=$2
    battery_level=$(solaar show $device | grep 'Battery:' | awk '{print $4}' | head -1 | cut -d'.' -f1)
}

function get_level_headsetcontrol
{
    local -n battery_level_ref=$1
    battery_level=$(headsetcontrol -b 2> /dev/null | grep 'Battery:' | cut -d' ' -f2 2> /dev/null)
}

function print_battery_level
{
    local device=$1
    local battery_level=""

    case $device in
        G502) get_level_solaar $device battery_level ;;
        G915) get_level_solaar $device battery_level ;;
        G633|G635|G933|G935) get_level_headsetcontrol battery_level ;;
    esac

    if [[ ! $battery_level =~ $number_regex ]]
    then
        battery_level="N/A"
    fi

    echo $battery_level
}

while :
do
    case $1 in
        -h|--help) usage && exit ;;
        -d|--device)
            shift
            print_battery_level $1
            ;;
        -s|--support) list_supported_devices && exit ;;
        *?)
            echo "Unrecognized arg: $1"
            exit 1
            ;;
        *) break ;;
    esac
    shift
done
