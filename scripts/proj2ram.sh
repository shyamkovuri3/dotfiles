#!/bin/sh

if [ -z "$1" ];then
    echo "Usage:"
    echo "  proj2ram proj-name"
    echo "  proj2ram restore proj-name"
    exit 1
fi


if [ "$1" != "restore" ];then
    backup=$1-backup
    link=$1
    volatile=/dev/shm/$1-$USER

    IFS=
    set -efu

    cd ~/

    if [ ! -r $volatile ]; then
        mkdir -m0700 $volatile
    fi

    # link -> volatie does not exist
    if [ "$(readlink $link)" != "$volatile" ]; then
        # backup project at first
        mv $link $backup
        # create the link
        ln -s $volatile $link
    fi

    if [ -e $link/.unpacked ]; then
        echo "Sync project from memory to backup ..."
        rsync -avq --delete --exclude .unpacked ./$link/ ./$backup/
        echo "DONE!"
    else
        echo "Sync project from disk to memory ..."
        rsync -avq ./$backup/ ./$link/
        touch $link/.unpacked
        echo "DONE!"
    fi
else
    if [ -z "$2" ]; then
        echo "Usage:"
        echo "  proj2ram restore proj-name"
    else
        echo "Moving project back to disk ..."
        backup=$2-backup
        link=$2
        volatile=/dev/shm/$2-$USER
        cd ~/
        rm $link && mv $backup $link && rm -rf $volatile
        echo "DONE!"
    fi
fi
