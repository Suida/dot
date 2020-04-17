#! /usr/bin/env python
import os, sys


ALL_FILES = {
    "ack.vim",
    "YouCompleteMe",
    "ctrlsf.vim",
    "indentLine",
    "tagbar",
    "vim-unimpaired",
}


def get_src_file(fn):
    return 'pack/plugins/start/' + fn


def get_dst_file(fn):
    return 'tmp/' + fn


def main():
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        print('Error: args required.')
        return 1

    if len(sys.argv) == 2:
        if sys.argv[1] == 'u':
            for f in ALL_FILES:
                if os.path.exists(get_dst_file(f)):
                    os.rename(get_dst_file(f), get_src_file(f))
            return 0
        elif sys.argv[1] == 'd':
            for f in ALL_FILES:
                if os.path.exists(get_src_file(f)):
                    os.rename(get_src_file(f), get_dst_file(f))
            return 0
        else:
            print('Error: "d" or "u" is required.')
            return 1

    if sys.argv[1] == 'u':
        fn = sys.argv[2]
        if not os.path.exists(get_dst_file(fn)):
            print('Error: file %s does not exist.' % fn)
            return 1
        os.rename(get_dst_file(fn), get_src_file(fn))
        return 0

    if sys.argv[1] == 'd':
        fn = sys.argv[2]
        if not os.path.exists(get_src_file(fn)):
            print('Error: file %s does not exist.' % fn)
            return 1
        os.rename(get_src_file(fn), get_dst_file(fn))
        return 0

    print('Error: "d" or "u" is required.')
    return 1


if __name__ == '__main__':
    main()
