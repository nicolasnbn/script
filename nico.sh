#NICO
alias nico='wget -O /tmp/nico.sh https://raw.githubusercontent.com/nicolasnbn/script/refs/heads/main/nico.sh && tail -10 /tmp/nico.sh | cut -c 3-';

#####################################################
#POUR PYTHON

ve(){
    if [ -d "./venv/" ]; then
        echo "le virtual env existe deja.";
    else
        echo "creation du virtual env.";
        python -m venv venv;
    fi
    src;
    if [ -f requirements.txt ]; then
        echo "installation des modules du fichier de requirements.";
        pip install -r requirements.txt;
    fi
}
alias rmve='rm -r venv';
alias src='source ./venv/bin/activate';
alias srcd='deactivate';

#####################################################
export PATH="$HOME/tools:$PATH";

#####################################################
alias l='ls -lart';
alias rz='. ~/tools/rezetnet.sh';
alias cl="clear";
alias hi="history | grep ";
alias his="history";

#####################################################
# POUR SNORT
alias snorts='sudo snort -A console -c /etc/snort/snort.conf';
alias snorte='sudo vi /etc/snort/rules/local.rules';
alias snortk='sudo ps auxww | grep -E "etc/snort" | grep -v grep | grep -E "etc/snort" | awk '"'"'{print $2}'"'"' | xargs kill -9';

#####################################################
# POUR WAZUH
alias waz="systemctl list-units | grep wazuh ";

#####################################################
# POUR FLAMESHOT
alias fs="flameshot gui ";


#####################################################
# POUR JEDHA CLI

alias js='jedha-cli start ';
alias jss='jedha-cli status';
alias jsstatus='jedha-cli status | tail -n1 | cut -d ":" -f2|cut -d"." -f1';
alias jst='jedha-cli stop $(jsstatus)';
alias jsrefresh='pipx uninstall jedha-cli && pipx install jedha-cli';

##############################
## EXECUTE
#
# if ! declare -f | grep -q "cln" ; then 
#     cln(){
# #        awk '/#NICO/{print NR}' ~/.bashrc | (read THEVALUE && sed -i "${THEVALUE},\$d" ~/.bashrc);
#         awk '/#NICO/{print NR}' ~/.zshrc | (read THEVALUE && sed -i "${THEVALUE},\$d" ~/.zshrc);
#     }
# fi;
# cln;
# #cat /tmp/nico.sh >> ~/.bashrc 
# cat /tmp/nico.sh >> ~/.zshrc ;
# . ~/.zshrc;