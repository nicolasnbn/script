#!/bin/bash

output_file="privesc.txt"

echo "Gathering system info...⚙️"

{
    echo "=== User Info ==="
    id
    echo

    echo "=== Groups info ==="
    groups
    echo

    echo "=== List of Users ==="
    cat /etc/passwd | cut -d: -f1
    echo

    echo "=== System Info ==="
    uname -a
    echo

    echo "=== Hostname ==="
    hostname
    echo

    echo "=== OS Release ==="
    cat /etc/*release
    echo

    echo "=== PATH ==="
    echo $PATH
    echo $PATH | tr ':' '\n' | while read dir; do test -w "$dir" && echo "$dir is writable"; done
    echo

    echo "=== Environment Variables ==="
    env
    echo

    echo "=== Sudo Version ==="
    sudo -V
    echo

    echo "=== Sudo Permissions ==="
    sudo -l
    journalctl -e | grep sudo
    echo

    echo "=== SUID Files ==="
    find / -perm -4000 -type f 2>/dev/null
    echo

    echo "=== Capabilities ==="
    getcap -r /usr/bin
    echo

    echo "=== Software ==="
    which nmap aws nc ncat netcat nc.traditional wget curl ping gcc g++ make gdb base64 socat python python2 python3 python2.7 python2.6 python3.6 python3.7 perl php ruby xterm doas sudo fetch docker lxc ctr runc rkt kubectl 2>/dev/null
    echo
     
} > "$output_file"

echo "Done!✨ Output saved to $output_file 🎯"
