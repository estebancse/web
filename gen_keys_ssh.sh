#! /bin/bash
# https://estebancse.es
# sistemas operativos basados en debian
# generador de claves ssh; crea par de claves ssh por cada valor pasado al ejecutar el script 
#
# USO: ./gen_keys_ssh.sh usuario1 usario2 ...
#################################################################################

# Ruta donde van a quedar el par de keys comprimidas
destino="/home/descargas"
# Instalamos los paquetes putty-tools y zip para compativilidad con windows y el cliente putty.
apt-get install -y zip putty-tools

# Bucle for repetimos las mismas acciones por cada valor pasado en el script
for key in $*
do
	# Solicita contraseña para el par de keys, 
	read -p "Dime una contraseña para la autenticacion por clave publica  para ${key} o pulsa Enter si quieres acceder sin contraseña: " contra 

	# Pide usuario al que debe añadir la clave privada
	read -p "Dime a que USUARIO del SERVIDOR vas a conectar por esta key ${key}: " usuario_objetivo

	# Comprobamos si el usuario_objetivo existe en el servidor
	cat /etc/passwd | grep "${usuario_objetivo}" > /dev/null && existe=0 || existe=1

	# Si existe 
	if [ $existe -eq 0 ]
	then
		# Genera par de keys y las deja en /home/descargas  
		ssh-keygen -C "${key}" -P "${contra}" -o -t rsa -b 4096 -f "${destino}"/id_rsa
		# Generamos claves compatibles con putty
		puttygen "${destino}"/id_rsa -o "${destino}"/id_rsa.ppk

		# Se comprueba que exista el archivo authorized_keys si no se crea
		if [ ! -f /home/"${usuario_objetivo}"/.ssh/authorized_keys ]
		then	
			mkdir /home/"${usuario_objetivo}"/.ssh
			touch /home/"$usuario_objetivo"/.ssh/authorized_keys
		        chown -R "${usuario_objetivo}":"${usuario_objetivo}" /home/"${usuario_objetivo}"/.ssh
		fi	

		# Se añade la clave publica
	       	cat "${destino}"/id_rsa.pub >> /home/"${usuario_objetivo}"/.ssh/authorized_keys

		# nos posicionamos en /home/descargas
		cd "${destino}"

		# comprimimos en zip el par de keys
		zip "${key}" id_rsa*

		# Elimina los archivos id_rsa*
		rm -fr "${destino}"/id_rsa*
	# Si no existe
	else
		echo "No existe el usario ${usuario_objetivo} en el servidor intentalo de nuevo"
	       	exit 1
	fi
done
exit 0

