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
http_port 3128 >> /etc/squid3/squid.conf 
# Define o nome do servidor
visible_hostname SegInfo >> /etc/squid3/squid.conf
echo "" >> /etc/squid3/squid.conf
#Esta linha cria uma ACL, uma política de acesso com nome "all" contendo qualquer IP.
acl all src 0.0.0.0/0.0.0.0 >> /etc/squid3/squid.conf
# Aqui criamos uma ACL para localhost
acl redelocal src 127.0.0.1/255.255.255.255
#Definido ACL de portas HTTPS
echo "acl SSL_ports port 443 563" >> /etc/squid3/squid.conf
#Definindo ACL de portas utilizadas na interent
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

#Cria a ACL manager do tipo proto.
acl manager proto cache_object >> /etc/squid3/squid.conf
# Cria a ACL manager do tipo method.
acl purge method PURGE >> /etc/squid3/squid.conf
# Cria a ACL CONNECT também do tipo method.
acl CONNECT method CONNECT >> /etc/squid3/squid.conf
#Libera a ACL manager e localhost.
http_access allow manager localhost >> /etc/squid3/squid.conf
#Bloqueia a ACL manager.
http_access deny manager >> /etc/squid3/squid.conf
# Libera a ACL purge e localhost
http_access allow purge localhost >> /etc/squid3/squid.conf
# Bloqueia a ACL purge.
http_access deny purge >> /etc/squid3/squid.conf
# Esta linha se torna bastante interessante pelo uso da "!", 
#pois ela bloqueia qualquer conexão que não contenha o conteúdo da ACL Safe_Ports.
http_access deny !Safe_ports >> /etc/squid3/squid.conf
#Bloquia todas as conexões que estão fora das regras de bloqueio
 # Bloqueia qualquer conexão que não esteja no conteúdo da ACL SSL_ports.
http_access deny CONNECT !SSL_ports >> /etc/squid3/squid.conf
 # Cria a ACL redelocal contendo a faixa de endereço da rede.
acl redelocal src 192.168.0.0/24 >> /etc/squid3/squid.conf
 #Libera a ACL localhost.
http_access allow localhost >> /etc/squid3/squid.conf
#Libera a ACL redelocal.
http_access allow redelocal >> /etc/squid3/squid.conf
#Bloqueia a ACL all
http_access deny all >> /etc/squid3/squid.conf
# Memoria utilizada pelo squid
cache_mem 256 MB >> /etc/squid3/squid.conf
#Limitando arquivos 
maximum_object_size_in_memory 256 KB >> /etc/squid3/squid.conf
#Local onde fica salvo os Logs do Squid 
cache_access_log /var/log/squid/access.log >> /etc/squid3/squid.conf
#Iniciando bloqueio de sites
echo "#### Blocked ####" >> /etc/squid3/squid.conf
#Criando arquivos de bloqueio
touch /etc/squid3/sites_proibidos
touch /etc/squid3/palavras_proibidas
#Criando bloqueio de sites
echo "acl sites_proibidos url_regex -i "/etc/squid3/sites_proibidos"" >> /etc/squid3/squid.conf
echo "http_access deny sites_proibidos" >> /etc/squid3/squid.conf
echo "acl palavras_proibidas dstdom_regex "/etc/squid3/palavras_proibidas"" >> /etc/squid3/squid.conf
echo "http_access deny palavras_proibidas" >> /etc/squid3/squid.conf
echo "### Finish Blocked  ###" >> /etc/squid3/squid.conf
#Terminando bloqueio

#Criando arquivo de usuario
touch /etc/squid3/squid_passwd
/etc/init.d/squid3 restart 

#Iniciando instalação/configuração do Sarg

apt-get install apache2 
apt-get install sarg 
#Entrando na pasta do Sarg 
cd /etc/sarg

#Realizando copia de segurança
cp sarg.conf sarg.conf.backup 

#Configurando Log do Sarg
access_log /var/log/squid/access.log >> sarg.conf
output_dir /var/www/html/
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
chmod +x /etc/init.d/firewall 
#Gerando link na pasta rc2.d para script inicializar junto com o sistema
ln -s /etc/init.d/firewall.sh /etc/rc2.d/S99firewall 
#Liberando acesso a algumas portas
echo "#!/bin/bash" >> /etc/init.d/firewall.sh
#Zerando configurações anteriores
iptables -F 
iptables -F >> /etc/init.d/firewall.sh
#SSH port - 22
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT >> /etc/init.d/firewall.sh
#HTTP port - 80
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT >> /etc/init.d/firewall.sh 
#HTTPS port - 443
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT >> /etc/init.d/firewall.sh
#Squid port - 3128
iptables -A INPUT -p tcp --dport 3128 -j ACCEPT
iptables -A INPUT -p tcp --dport 3128 -j ACCEPT >> /etc/init.d/firewall.sh
#Skype port 81
iptables -A INPUT -p tcp --dport 81 -j ACCEPT
iptables -A INPUT -p tcp --dport 81 -j ACCEPT >> /etc/init.d/firewall.sh
#VNC port 5900
iptables -A INPUT -p tcp --dport 5900 -j ACCEPT
iptables -A INPUT -p tcp --dport 5900 -j ACCEPT >> /etc/init.d/firewall.sh
#Bloqueando as demais portas
iptables -A INPUT -p tcp --syn -j DROP
iptables -A INPUT -p tcp --syn -j DROP >> /etc/init.d/firewall.sh
#Bloqueio de portas UDP de 0 - 65535
iptables -A INPUT -p udp --dport 0:65535 -j DROP
iptables -A INPUT -p udp --dport 0:65535 -j DROP >> /etc/init.d/firewall.sh
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
