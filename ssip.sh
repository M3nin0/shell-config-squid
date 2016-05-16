#!/bin/bash


install_squid(){
	
echo "Check Squid3 Install"
way=$(which squid3)

if [ "$way" != "/usr/sbin/squid3" ];then

	apt-get install squid3
	apt-get install apache2-utils

else
	echo "Installed"
fi

clear
echo "O que você quer fazer?"
echo "1 - Install/Config SQUID"
echo "2 - Install/Config Sarg"
echo "3 - Compartilhar internet - NAT"
echo "4 - Configure Firewall"
read menu

case $menu in

1)

echo "Squid Config"

#Porta padrão
echo "http_port 3128" >> /etc/squid3/squid.conf

#Nome do Servidor#
echo "visible_hostname SquidTest" >> /etc/squid3/squid.conf

#######
#Cache#
#######

echo "cache_dir ufs /var/spool/squid3 3000 16 256" >> /etc/squid3/squid.conf

###############
#Log de acesso#
###############

echo "access_log /var/log/squid3/acces.log squid" >> /etc/squid3/squid.conf

###########################
#Bloqueio de sites por URL#
###########################

echo "acl sites_proibidos url_regex -i "etc/squid3/regras/sites_proibidos"" >> /etc/squid3/squid.conf
echo "http_access deny sites_proibidos" >> /etc/squid3/squid.conf

cache_mgr efelipecarlos@outlook.com

############################
#Regras de acesso em portas#
############################

#Portas seguras
acl SSL_ports port 443

#HTTP
echo "acl Safe_ports port 80" >> /etc/squid3/squid.conf 
#HTTP
echo "acl Safe_ports port 82" >> /etc/squid3/squid.conf
#FTP
echo "acl Safe_ports port 21" >> /etc/squid3/squid.conf
#HTTPS
echo  "acl Safe_ports port 443" >> /etc/squid3/squid.conf
#GOPHER
echo "acl Safe_ports port 70" >> /etc/squid3/squid.conf
#HTTP-MGMT
echo "acl Safe_ports port 280" >> /etc/squid3/squid.conf
#GSS-HTTP
echo "acl Safe_ports port 488" >> /etc/squid3/squid.conf
#FILEMAKER
echo "acl Safe_ports port 591" >> /etc/squid3/squid.conf
#SSH
echo "acl Safe_ports port 22" >> /etc/squid3/squid.conf
#Portas Altas
echo "acl Safe_ports port 1025-65535" >> /etc/squid3/squid.conf

echo "acl CONNECT method CONNECT" >> /etc/squid3/squid.conf

############################
#Redes com conexão ao Squid#
############################

echo "acl manger proto cache_object" >> /etc/squid3/squid.conf
echo "acl localhost src 127.0.0.1/32" >> /etc/squid3/squid.conf
echo "acl redelocal src 192.168.0.0/24" >> /etc/squid3/squid.conf

###########
#Bloqueios#
###########

echo "http_access allow localhost" >> /etc/squid3/squid.conf
echo "http_access allow redelocal" >> /etc/squid3/squid.conf
echo "http_access deny !Safe_ports" >> /etc/squid3/squid.conf
echo "http_access deny CONNECT !SSL_ports" >> /etc/squid3/squid.conf
echo "http_access deny all" >> /etc/squid3/squid.conf

;;

2)

echo "Config Sarg"

#Iniciando instalação/configuração do Sarg
apt-get install apache2 
apt-get install sarg 
#Entrando na pasta do Sarg 
cd /etc/sarg

#Realizando copia de segurança
cp sarg.conf sarg.conf.backup 

#Configurando Log do Sarg
echo "access_log /var/log/squid3/access.log" >> sarg.conf
echo "output_dir /var/www/html/" >> sarg.conf
;;

3)

echo "######################################" 
echo "#Compartilhando internet             #"
echo "######################################"

modprobe iptables_nat
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE #ETH0 Representa a interface conectada a internet
iptables -A INPUT -p tcp --syn -s 192.168.0.0/255.255.255.0 -j ACCEPT

;;

4)

echo "Firewall Config"

#Gerando arquivo de inicialização
touch /etc/init.d/firewall.sh
#Permitindo execução do programa
chmod +x /etc/init.d/firewall.sh
#Gerando link na pasta rc2.d para script inicializar junto com o sistema
ln -s /etc/init.d/firewall.sh /etc/rc2.d/firewall.sh
update-rc.d firewall.sh defaults
#Liberando acesso a algumas portas
echo "#!/bin/bash" >> /etc/init.d/firewall.sh
#Zerando configurações anteriores
iptables -F 
echo "iptables -F" >> /etc/init.d/firewall.sh
#SSH port - 22
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
echo "iptables -A INPUT -p tcp --dport 22 -j ACCEPT" >> /etc/init.d/firewall.sh
#HTTP port - 80
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
echo "iptables -A INPUT -p tcp --dport 80 -j ACCEPT" >> /etc/init.d/firewall.sh 
#HTTPS port - 443
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
echo "iptables -A INPUT -p tcp --dport 443 -j ACCEPT" >> /etc/init.d/firewall.sh
#Squid port - 3128
iptables -A INPUT -p tcp --dport 3128 -j ACCEPT
echo "iptables -A INPUT -p tcp --dport 3128 -j ACCEPT" >> /etc/init.d/firewall.sh
#Skype port 81
iptables -A INPUT -p tcp --dport 81 -j ACCEPT
echo "iptables -A INPUT -p tcp --dport 81 -j ACCEPT" >> /etc/init.d/firewall.sh
#VNC port 5900
iptables -A INPUT -p tcp --dport 5900 -j ACCEPT
echo "iptables -A INPUT -p tcp --dport 5900 -j ACCEPT" >> /etc/init.d/firewall.sh
#Bloqueando as demais portas
iptables -A INPUT -p tcp --syn -j DROP
echo "iptables -A INPUT -p tcp --syn -j DROP" >> /etc/init.d/firewall.sh
#Bloqueio de portas UDP de 0 - 65535
iptables -A INPUT -p udp --dport 0:65535 -j DROP
echo "iptables -A INPUT -p udp --dport 0:65535 -j DROP" >> /etc/init.d/firewall.sh

##########################
#Compartilhando internet #
##########################

echo "modprobe iptables_nat" >> /etc/init.d/firewall.sh
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> /etc/init.d/firewall.sh
echo "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> /etc/init.d/firewall.sh
echo "iptables -A INPUT -p tcp --syn -s 192.168.0.0/255.255.255.0 -j ACCEPT" >> /etc/init.d/firewall.sh
;;

*)
echo "Invalido!!!"
exit
esac
}

ROT=$(id -u)

if [ "$ROT" == "0" ];then
	install_squid
else
echo "Root access only"
exit
fi
