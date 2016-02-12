#!/bin/bash
clear
echo "Squid Config"
echo "Scripted by M3nin0"
sleep 5
config_SQUID(){
clear
echo "Check Squid3 Install"
way=$(which squid3)

if [ "$way" != "/usr/sbin/squid3" ];then

	apt-get install squid3
	apt-get install apache2-utils

else
echo "Installed"
fi
sleep 3
clear
echo "What do you want to do?"
echo "1 - Config SQUID"
echo "2 - Add user"
read menu

case $menu in 

1)
clear
echo "Make Copies for your security"
echo "......."
cp /etc/squid3/squid.conf /etc/squid3/squid.ori
echo ".........."
sleep 3
echo "Remove old version"
echo "......"
rm /etc/squid3/squid.conf
echo "........."
sleep 3
echo "Done"
sleep 3
clear
echo "Init the install"
sleep 3
echo "http_port 3128" >> /etc/squid3/squid.conf
echo "visible_hostname Servidor" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "acl all src 0.0.0.0/0.0.0.0" >> /etc/squid3/squid.conf
echo "acl manager proto cache_object" >> /etc/squid3/squid.conf
echo "acl localhost src 127.0.0.1/255.255.255.255" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "### CACHE ###" >> /etc/squid3/squid.conf
echo "cache_mem 128 MB" >> /etc/squid3/squid.conf
echo "maximum_object_size_in_memory 64 KB" >> /etc/squid3/squid.conf
echo "maximum_object_size 512 MB" >> /etc/squid3/squid.conf
echo "minimum_object_size 0 KB" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "cache_swap_low 90" >> /etc/squid3/squid.conf
echo "cache_swap_high 95" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "cache_dir ufs /var/spool/squid3 2048 16 256" >> /etc/squid3/squid.conf
echo "cache_access_log /var/log/squid3/access.log" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "refresh_pattern ^ftp: 15 20% 2280" >> /etc/squid3/squid.conf
echo "refresh_pattern ^gopher: 15 0% 2280" >> /etc/squid3/squid.conf
echo "refresh_pattern . 15 20% 2280" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "### CACHE END ###" >> /etc/squid3/squid.conf
echo "acl SSL_ports port 443 563" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 80 #HTTP" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 21 #FTP" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 443 563 #HTTPS, SNEWS" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 70 #GOPHER" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 210 #WAIS" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 280 #HTTP-MGMT" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 488 #GSS-HTTP" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 591 #FILEMAKER" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 777 #multing HTTP" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 901 #swat" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 1025-65535 #HIGH PORTS" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "#Autenticação" >> /etc/squid3/squid.conf
echo "auth_param basic realm Servidor_Proxy( User / Password)" >> /etc/squid3/squid.conf
echo "auth_param basic program /usr/lib/squid3/ncsa_auth /etc/squid3/squid_passwd" >> /etc/squid3/squid.conf
echo "acl autenticados proxy_auth REQUIRED" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "#### Blocked ####" >> /etc/squid3/squid.conf
echo "acl listabloqueada url_regex -i "/etc/squid3/listabloqueada"" >> /etc/squid3/squid.conf
echo "http_access deny listabloqueada" >> /etc/squid3/squid.conf
echo "acl palavrasproibidas dstdom_regex "/etc/squid3/palavrasproibidas"" >> /etc/squid3/squid.conf
echo "http_access deny palavrasproibidas" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "### Finish Blocked  ###" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "http_access allow autenticados" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "acl purge method PURGE" >> /etc/squid3/squid.conf
echo "acl CONNECT method CONNECT" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "http_access allow manager localhost" >> /etc/squid3/squid.conf
echo "http_access deny manager" >> /etc/squid3/squid.conf
echo "htpp_acess allow purge localhost" >> /etc/squid3/squid.conf
echo "http_acess deny purge" >> /etc/squid3/squid.conf
echo "http_acess deny !Safe_ports" >> /etc/squid3/squid.conf
echo "http_acess deny CONNECT !SSL_ports" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "acl redelocal src 192.168.0.0/24" >> /etc/squid3/squid.conf
echo "http_access allow localhost" >> /etc/squid3/squid.conf
echo "http_acess allow redelocal" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "### speed control ###" >> /etc/squid3/squid.conf
echo "acl limite_20k src /etc/squid3/limite_20k" >> /etc/squid3/squid.conf
echo "delay_pools 2" >> /etc/squid3/squid.conf
echo "delay_class 1 2 " >> /etc/squid3/squid.conf
echo "delay_acess 1 allow limite_20k" >> /etc/squid3/squid.conf
echo "delay_acess 2 allow redelocal" >> /etc/squid3/squid.conf
echo "delay_acess 2 2" >> /etc/squid3/squid.conf
echo "delay_parameters 1 -1/-1 20000/20000" >> /etc/squid3/squid.conf
echo "delay_parameters 2 -1/-1 32000/32000" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
echo "http_acess deny all" >> /etc/squid3/squid.conf
touch /etc/squid3/squid_passwd
echo "Concluido"
sleep 2
clear
echo "Definindo usuario SQUID:"
echo "Insira o nome do usuario: "
read usuario
htpasswd /etc/squid3/squid_passwd $usuario
echo "Success!!!"
echo "To LOCK or UNLOCK some content just follow the following folders"
echo "/etc/squid3/palavrasproibidas -> It makes the contents of blocking words"
echo "/etc/squid3/listabloqueada -> Block URL Sites"
echo "/etc/squid3/limite_20k -> reduces the speed of the Internet for selected IP´s"
;;
2)
echo "Add User"
echo "Insert the user name"
read user
htpasswd /etc/squid3/squid_passwd $user
echo "Success!!!"
sleep 2
exit
;;
*)
echo "Invalid!!!"
exit
esac
}
ROT=$(id -u)

if [ "$ROT" == "0" ];then
	config_SQUID
else
echo "Root access only"
exit
fi
