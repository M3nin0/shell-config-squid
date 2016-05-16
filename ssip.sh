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
echo "What do you want to do?"
echo "1 - Install/Config SQUID + Sarg"
echo "2 - Configure Firewall"
read menu

case $menu in 

1)
echo "Make Copies for your security"
mv /etc/squid3/squid.conf /etc/squid3/squid.old
echo "acl manager proto cache_object" >> /etc/squid3/squid.conf
echo "acl localhost src 127.0.0.1/32" >> /etc/squid3/squid.conf
echo "acl redelocal src 192.168.0.0/24" >> /etc/squid3/squid.conf
echo "acl SSL_ports port 443" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 80	 # http" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 81	 # http" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 88   # http" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 21	 # ftp" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 443	 # https" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 70	 # gopher" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 210	 # wais" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 1025-65535	# High_Ports" >> /etc/squid3/squid.conf

echo "acl CONNECT method CONNECT" >> /etc/squid3/squid.conf
echo "http_access allow localhost" >> /etc/squid3/squid.conf
echo "http_access allow redelocal" >> /etc/squid3/squid.conf
echo "http_access deny !Safe_ports" >> /etc/squid3/squid.conf
echo "http_access deny CONNECT !SSL_ports" >> /etc/squid3/squid.conf
echo "http_access allow localhost" >> /etc/squid3/squid.conf
echo "http_access allow redelocal" >> /etc/squid3/squid.conf
echo "http_port 3128" >> /etc/squid3/squid.conf

#Nome do Servidor#
echo "visible_hostname Squid_Server" >> /etc/squid3/squid.conf

# Erros em Pt-BR
echo "error_directory /usr/share/squid3/errors/pt-br" >> /etc/squid3/squid.conf


echo "cache_mgr efelipecarlos@outlook.com" >> /etc/squid3/squid.conf

# Logs de acesso

echo "access_log /var/log/squid3/access.log squid" >> /etc/squid3/squid.conf

### Sites Proibidos ####
touch /etc/squid3/sites_proibidos
echo "acl sites_proibidos url_regex -i "etc/squid3/regras/sites_proibidos"" >> /etc/squid3/squid.conf
echo "http_access deny sites_proibidos" >> /etc/squid3/squid.conf 

#Acesso a sites sem nenhuma regra

echo "http_access allow all !sites_proibidos" >> /etc/squid3/squid.conf  

### Configuracoes de cache e memória ####
echo "cache_dir AUFS /var/spool/squid3 3000 64 256" >> /etc/squid3/squid.conf 

echo "cache_mem 256 MB" >> /etc/squid3/squid.conf
echo "cache_swap_low 90" >> /etc/squid3/squid.conf
echo "cache_swap_high 95" >> /etc/squid3/squid.conf
echo "memory_pools on" >> /etc/squid3/squid.conf
echo "memory_pools_limit 64 MB" >> /etc/squid3/squid.conf
echo "maximum_object_size_in_memory 64 KB" >> /etc/squid3/squid.conf
echo "maximum_object_size 600 MB" >> /etc/squid3/squid.conf
echo "minimum_object_size 2 KB" >> /etc/squid3/squid.conf

######################################
#Compartilhando internet             #
######################################

modprobe iptables_nat
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE #ETH0 Representa a interface conectada a internet
iptables -A INPUT -p tcp --syn -s 192.168.0.0/255.255.255.0 -j ACCEPT

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
2)
echo "Config Firewall"

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

#######################################
#Fazendo proxy transparente com squid #
#######################################

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 3128 
echo "iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 3128 " >> /etc/init.d/firewall.sh

##########################
#Compartilhando internet #
##########################

echo "modprobe iptables_nat" >> /etc/init.d/firewall.sh
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> /etc/init.d/firewall.sh
echo "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> /etc/init.d/firewall.sh
echo "iptables -A INPUT -p tcp --syn -s 192.168.0.0/255.255.255.0 -j ACCEPT" >> /etc/init.d/firewall.sh

;;
*)
echo "Invalid!!!"
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
