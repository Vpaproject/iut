#!/bin/bash
       
               
			   

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -O /etc/apt/sources.list "http://jackspiner.000webhostapp.com/sources.list.debian7.sh"
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# update
apt-get update; apt-get -y upgrade;

# install webserver
apt-get -y install nginx php5-fpm php5-cli

# install essential package
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update

# setting vnstat
vnstat -u -i venet0
service vnstat restart

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "http://jackspiner.000webhostapp.com/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by Choirul Anam</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "http://jackspiner.000webhostapp.com/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.tar "http://jackspiner.000webhostapp.com/openvpn.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "http://jackspiner.000webhostapp.com/1194-debian.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
wget -O /etc/iptables.up.rules "http://jackspiner.000webhostapp.com/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | grep -v '192.168'`;
MYIP2="s/xxxxxxxxx/$MYIP/g";
sed -i 's/port 1194/port 1194/g' /etc/openvpn/1194.conf
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
service openvpn restart

# configure openvpn client config
cd /etc/openvpn/
wget -O /etc/openvpn/1194-client.ovpn "http://jackspiner.000webhostapp.com/1194-client"
sed -i $MYIP2 /etc/openvpn/1194-client.ovpn;
PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -M -s /bin/false jackV
echo "jackV:$PASS" | chpasswd
echo "jackV" > pass.txt
echo "$PASS" >> pass.txt
tar cf client.tar 1194-client.ovpn pass.txt
cp client.tar /home/vps/public_html/
cd

#mrtg
 wget -q -O /etc/snmp/snmpd.conf $source/null/snmpd.conf
wget -q -O /root/mrtg-mem.sh $source/null/mrtg-mem.sh
chmod +x /root/mrtg-mem.sh
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/fns/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/fns/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl $source/null/mrtg.conf >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/fns/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd



# setting port ssh
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 110"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
service ssh restart
service dropbear restart

# install vnstat gui
cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i 's/eth0/venet0/g' config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array('venet0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# Update and install necessary packages
apt-get update
apt-get install linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,') linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,')
 
# Download some extra packages, that do the trick for "wl module not found"
wget http://http.kali.org/kali/pool/main/l/linux-tools/linux-kbuild-4.3_4.3.1-2kali1_amd64.deb
wget http://http.kali.org/kali/pool/main/l/linux/linux-headers-4.3.0-kali1-common_4.3.3-5kali4_amd64.deb
wget http://http.kali.org/kali/pool/main/l/linux/linux-headers-4.3.0-kali1-amd64_4.3.3-5kali4_amd64.deb
 
# Install with correct order
dpkg -i linux-kbuild-4.3_4.3.1-2kali1_amd64.deb
dpkg -i linux-headers-4.3.0-kali1-common_4.3.3-5kali4_amd64.deb
dpkg -i linux-headers-4.3.0-kali1-amd64_4.3.3-5kali4_amd64.deb
 
# Install broadcom drivers
apt-get install broadcom-sta-dkms
 
# Enable modules and disabled unnecessary ones 
modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
modprobe wl
 
# Done :)
echo "Should work now! :)"


#autoban user DDos
while read count ip
do
     test $count -gt 100 && echo " ipfw add deny all from $ip to me"
done...

# install fail2ban
apt-get -y install fail2ban;service fail2ban restart

# install squid3
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "http://jackspiner.000webhostapp.com/squid3.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install webmin
cd
wget "http://prdownloads.sourceforge.net/webadmin/webmin_1.670_all.deb"
dpkg --install webmin_1.670_all.deb;
apt-get -y -f install;
rm /root/webmin_1.670_all.deb
service webmin restart
service vnstat restart

wget -O speedtest_cli.py "http://jackspiner.000webhostapp.com/speedtest_cli.py"
wget -O benchnetwork "http://jackspiner.000webhostapp.com/benchnetwork"
wget -O ps_mem.py "http://jackspiner.000webhostapp.com/ps_mem.py"
wget -O limit.sh "http://jackspiner.000webhostapp.com/limit.sh"
echo "*/10 * * * * root /usr/bin/userexpiredfns" > /etc/cron.d/userexpiredfns
echo "0 */12 * * * root /sbin/reboot" > /etc/cron.d/reboot
echo "0 */8 * * * root service dropbear restart" > /etc/cron.d/dropbear


#extra
wget http://jackspiner.000webhostapp.com/pentmenu
chmod +x ./pentmenu
echo "Install (D)DoS Deflate"
sleep 3
wget -O- http://jackspiner.000webhostapp.com/install.sh | sh

#Menu
wget http://jackspiner.000webhostapp.com/menu
mv ./menu /usr/local/bin/menu
chmod +x /usr/local/bin/menu
wget -O /etc/motd "http://jackspiner.000webhostapp.com/motd"

# finalisasi
service cron restart
service nginx start
service openvpn restart
service ssh restart
service dropbear restart
service squid3 restart
service webmin restart
service php-fpm start
service vnstat restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart


# info
echo -e "\e[0;35m---------------------info ByJack-------------------------"
echo " "
echo -e "\e[0;35m    >>>>> Login Panel By Your IP Only <<<<<\e[0;0m"
echo ""
echo "            Database Host: Jack localhost"
echo ""
echo "            Database Name: Jack"
echo ""
echo "            Database User: JackComunity"
echo ""
echo "            Database Pass: xxxXxxx"
echo ""
echo -e "\e[0;35m---------------------info ByJack-------------------------"
echo "Service Autoscript Created By jack"  | tee -a log-install.txt
echo "-----------------------------------------"  | tee -a log-install.txt
echo "Telegram Channel : http://telegram.me/TICGH "  | tee -a log-install.txt
echo "SySteM CreaTeD bY Jack Freemiumm OpLovers " | tee -a log-install.txt
echo "Download client at http://$myip/client.tar"  | tee -a log-install.txt
echo "Webmin     : http://$myip:10000 " | tee -a log-install.txt
echo "Squid3     : 80, 8000, 8080, 3128"  | tee -a log-install.txt
echo "OpenSSH    : 22, 143"  | tee -a log-install.txt
echo "Dropbear   : 109, 110, 443"  | tee -a log-install.txt
echo "Timezone   : Asia/Kuala_Lumpur"  | tee -a log-install.txt
echo "Fail2Ban :          [on]"   | tee -a log-install.txt
echo "Anti Doss :         [on]"   | tee -a log-install.txt
echo "Anti Retorrent :    [on]"   | tee -a log-install.txt
echo "Root Hunter :       [on]"  | tee -a log-install.txt
echo "VPS AutoRestart: 12.00am"   | tee -a log-install.txt
echo " [ Unsupported Operating System ]" | tee -a log-install.txt
echo "[ A   U   T   O  -  E   X   I   T ]" | tee -a log-install.txt
echo "   [ SMS/Telegram/freemiumm ]" | tee -a log-install.txt
echo "----------------------------------------"
echo "------Thank you for choice us--------"
echo "========================================"  | tee -a log-install.txt
echo "      PLEASE REBOOT TAKE EFFECT !"
echo "========================================"  | tee -a log-install.txt
cat /dev/null > ~/.bash_history && history -c
rm -f /root/iplist.txt

rm -f /root/update

rm -f /root/debian7latest.sh

rm -f /root/debian7latest.sh.x

rm -f /root/ddos-deflate-master.zip

rm -f /root/.bash_history && history -c
