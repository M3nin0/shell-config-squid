#!/bin/bash

#Script para configuração do Squid


install_squid() {

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
echo "2 - Add user"
echo "3 - Configure Firewall"
read menu

case $menu in 

1)
echo "Make Copies for your security"
mv /etc/squid3/squid.conf /etc/squid3/squid.old
# Define em qual porta o Squid vai atuar, a porta default é a 3128, mas podemos definir qualquer outra porta.
echo "http_port 3128 transparent" >> /etc/squid3/squid.conf 
# Define o nome do servidor
echo "visible_hostname SegInfo" >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
#Esta linha cria uma ACL, uma política de acesso com nome "all" contendo qualquer IP.
echo "acl all src 0.0.0.0/0.0.0.0" >> /etc/squid3/squid.conf
#Iniciando politicas de acesso
echo "acl localhost src 127.0.0.1/255.255.255.255" >> /etc/squid3/squid.conf
# Aqui criamos uma ACL para localhost

##########################################
#Definindo espaços utilizados            #
##########################################

# Memoria utilizada pelo squid 
echo "cache_mem 128 MB" >> /etc/squid3/squid.conf
# Limitando arquivos 
echo "maximum_object_size_in_memory 64 KB" >> /etc/squid3/squid.conf

echo "maximum_object_size 512 MB" >> /etc/squid3/squid.conf

echo "minimum_object_size 0 KB" >> /etc/squid3/squid.conf

echo "cache_swap_low 90" >> /etc/squid3/squid.conf

echo "cache_swap_high 95" >> /etc/squid3/squid.conf

echo "cache_dir ufs /var/spool/squid3 2048 16 256" >> /etc/squid3/squid.conf
#Local onde fica salvo os Logs do Squid 
echo "cache_access_log /var/log/squid/access.log" >> /etc/squid3/squid.conf

echo "refresh_pattern ^ftp: 15 20% 2200" >> /etc/squid3/squid.conf
echo "refresh_pattern ^gopher: 15 0% 2280" >> /etc/squid3/squid.conf
echo "refresh_pattern . 15 20% 2280" >> /etc/squid3/squid.conf 

#Definido ACL de portas HTTPS
echo "acl SSL_ports port 443 563" >> /etc/squid3/squid.conf
#Definindo ACL de portas utilizadas na internet
echo "acl Safe_ports port 80 #HTTP" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 21 #FTP" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 443 563 #HTTPS, SNEWS" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 210 #WAIS" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 70 #GOPHER" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 280 #HTTP-MGMT" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 488 #GSS-HTTP" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 591 #FILEMAKER" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 777 #multing HTTP" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 901 #swat" >> /etc/squid3/squid.conf
echo "acl Safe_ports port 1025-65535 #HIGH PORTS" >> /etc/squid3/squid.conf


##################################
#Permissoes                      #
##################################

#Cria a ACL manager do tipo proto.
echo "acl manager proto cache_object" >> /etc/squid3/squid.conf
# Cria a ACL manager do tipo method.
echo "acl purge method PURGE" >> /etc/squid3/squid.conf
# Cria a ACL CONNECT também do tipo method.
echo "acl CONNECT method CONNECT" >> /etc/squid3/squid.conf
#Libera a ACL manager e localhost.
echo "http_access allow manager localhost" >> /etc/squid3/squid.conf
#Libera a ACL manager.
echo "http_access allow manager" >> /etc/squid3/squid.conf
# Libera a ACL purge e localhost
echo "http_access allow purge localhost" >> /etc/squid3/squid.conf
# Libera a ACL purge.
echo "http_access allow purge" >> /etc/squid3/squid.conf
# Esta linha se torna bastante interessante pelo uso da "!", 
#pois ela bloqueia qualquer conexão que não contenha o conteúdo da ACL Safe_Ports.
echo "http_access deny !Safe_ports" >> /etc/squid3/squid.conf
#Bloquia todas as conexões que estão fora das regras de bloqueio
# Bloqueia qualquer conexão que não esteja no conteúdo da ACL SSL_ports.
echo "http_access deny CONNECT !SSL_ports" >> /etc/squid3/squid.conf
#Permite acesso a tudo
echo "http_access allow all" >> /etc/squid3/squid.conf
echo "icp_access allow all" >> /etc/squid3/squid.conf

######################################
#Bloqueio                            #
######################################

touch /etc/squid3/sites_proibidos
touch /etc/squid3/palavras_proibidas

# Cria a ACL redelocal contendo a faixa de endereço da rede.
echo "acl redelocal src 192.168.0.0/24" >> /etc/squid3/squid.conf
#Iniciando bloqueio de sites
echo "acl sites_proibidos url_regex -i "/etc/squid3/sites_proibidos"" >> /etc/squid3/squid.conf
echo "http_access deny sites_proibidos" >> /etc/squid3/squid.conf
#Libera a ACL localhost.
echo "http_access allow localhost" >> /etc/squid3/squid.conf
#Libera a ACL redelocal.
echo "http_access allow redelocal" >> /etc/squid3/squid.conf

######################################
#Compartilhando internet             #
######################################

modprobe iptables_nat
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE #ETH0 Representa a interface conectada a internet
iptables -A INPUT -p tcp --syn -s 192.168.0.0/255.255.255.0 -j ACCEPT

#Criando arquivo de usuario
touch /etc/squid3/squid_passwd
/etc/init.d/squid3 restart 

#Usuario que gerencia o squid
#Neste caso o usuario proxy
echo "cache_effective_user proxy" >> /etc/squid3/squid.conf
echo "cache_effective_group proxy" >> /etc/squid3/squid.conf
useradd proxy 
chown proxy.proxy /var/log/squid3/
chown proxy.proxy /var/log/squid3/ 
echo "http_access deny all" >> /etc/squid3/squid.conf
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
echo "Add User"
echo "Insert the user name"
read user
htpasswd /etc/squid3/squid_passwd $user
/etc/init.d/squid3 restart 
echo "Success!!!"
exit
;;

3)
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
