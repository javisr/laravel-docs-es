# Laravel Homestead

- [Introducción](#introduction)
- [Instalación y Configuración](#installation-and-setup)
    - [Primeros Pasos](#first-steps)
    - [Configurando Homestead](#configuring-homestead)
    - [Configurando Sitios de Nginx](#configuring-nginx-sites)
    - [Configurando Servicios](#configuring-services)
    - [Lanzando la Caja de Vagrant](#launching-the-vagrant-box)
    - [Instalación por Proyecto](#per-project-installation)
    - [Instalando Características Opcionales](#installing-optional-features)
    - [Alias](#aliases)
- [Actualizando Homestead](#updating-homestead)
- [Uso Diario](#daily-usage)
    - [Conectando vía SSH](#connecting-via-ssh)
    - [Agregando Sitios Adicionales](#adding-additional-sites)
    - [Variables de Entorno](#environment-variables)
    - [Puertos](#ports)
    - [Versiones de PHP](#php-versions)
    - [Conectando a Bases de Datos](#connecting-to-databases)
    - [Copias de Seguridad de Bases de Datos](#database-backups)
    - [Configurando Programaciones de Cron](#configuring-cron-schedules)
    - [Configurando Mailpit](#configuring-mailpit)
    - [Configurando Minio](#configuring-minio)
    - [Laravel Dusk](#laravel-dusk)
    - [Compartiendo Tu Entorno](#sharing-your-environment)
- [Depuración y Perfilado](#debugging-and-profiling)
    - [Depurando Solicitudes Web Con Xdebug](#debugging-web-requests)
    - [Depurando Aplicaciones CLI](#debugging-cli-applications)
    - [Perfilando Aplicaciones Con Blackfire](#profiling-applications-with-blackfire)
- [Interfaces de Red](#network-interfaces)
- [Extendiendo Homestead](#extending-homestead)
- [Configuraciones Específicas del Proveedor](#provider-specific-settings)
    - [VirtualBox](#provider-specific-virtualbox)

<a name="introduction"></a>
## Introducción

Laravel se esfuerza por hacer que toda la experiencia de desarrollo en PHP sea placentera, incluyendo tu entorno de desarrollo local. [Laravel Homestead](https://github.com/laravel/homestead) es una caja de Vagrant oficial y preempaquetada que te proporciona un maravilloso entorno de desarrollo sin requerir que instales PHP, un servidor web, o cualquier otro software de servidor en tu máquina local.

[Vagrant](https://www.vagrantup.com) proporciona una forma simple y elegante de gestionar y aprovisionar Máquinas Virtuales. Las cajas de Vagrant son completamente desechables. Si algo sale mal, puedes destruir y recrear la caja en minutos.

Homestead funciona en cualquier sistema Windows, macOS o Linux e incluye Nginx, PHP, MySQL, PostgreSQL, Redis, Memcached, Node, y todo el otro software que necesitas para desarrollar increíbles aplicaciones Laravel.

> [!WARNING]  
> Si estás usando Windows, es posible que necesites habilitar la virtualización de hardware (VT-x). Generalmente se puede habilitar a través de tu BIOS. Si estás usando Hyper-V en un sistema UEFI, es posible que también necesites deshabilitar Hyper-V para acceder a VT-x.

<a name="included-software"></a>
### Software Incluido

<style>
    #software-list > ul {
        column-count: 2; -moz-column-count: 2; -webkit-column-count: 2;
        column-gap: 5em; -moz-column-gap: 5em; -webkit-column-gap: 5em;
        line-height: 1.9;
    }
</style>

<div id="software-list" markdown="1">

- Ubuntu 22.04
- Git
- PHP 8.3
- PHP 8.2
- PHP 8.1
- PHP 8.0
- PHP 7.4
- PHP 7.3
- PHP 7.2
- PHP 7.1
- PHP 7.0
- PHP 5.6
- Nginx
- MySQL 8.0
- lmm
- Sqlite3
- PostgreSQL 15
- Composer
- Docker
- Node (Con Yarn, Bower, Grunt y Gulp)
- Redis
- Memcached
- Beanstalkd
- Mailpit
- avahi
- ngrok
- Xdebug
- XHProf / Tideways / XHGui
- wp-cli

</div>

<a name="optional-software"></a>
### Software Opcional

<style>
    #software-list > ul {
        column-count: 2; -moz-column-count: 2; -webkit-column-count: 2;
        column-gap: 5em; -moz-column-gap: 5em; -webkit-column-gap: 5em;
        line-height: 1.9;
    }
</style>

<div id="software-list" markdown="1">

- Apache
- Blackfire
- Cassandra
- Chronograf
- CouchDB
- Crystal & Lucky Framework
- Elasticsearch
- EventStoreDB
- Flyway
- Gearman
- Go
- Grafana
- InfluxDB
- Logstash
- MariaDB
- Meilisearch
- MinIO
- MongoDB
- Neo4j
- Oh My Zsh
- Open Resty
- PM2
- Python
- R
- RabbitMQ
- Rust
- RVM (Ruby Version Manager)
- Solr
- TimescaleDB
- Trader <small>(extensión de PHP)</small>
- Webdriver & Utilidades de Laravel Dusk

</div>

<a name="installation-and-setup"></a>
## Instalación y Configuración

<a name="first-steps"></a>
### Primeros Pasos

Antes de lanzar tu entorno Homestead, debes instalar [Vagrant](https://developer.hashicorp.com/vagrant/downloads) así como uno de los siguientes proveedores soportados:

- [VirtualBox 6.1.x](https://www.virtualbox.org/wiki/Download_Old_Builds_6_1)
- [Parallels](https://www.parallels.com/products/desktop/)

Todos estos paquetes de software proporcionan instaladores visuales fáciles de usar para todos los sistemas operativos populares.

Para usar el proveedor Parallels, necesitarás instalar el [complemento de Vagrant para Parallels](https://github.com/Parallels/vagrant-parallels). Es gratuito.

<a name="installing-homestead"></a>
#### Instalando Homestead

Puedes instalar Homestead clonando el repositorio de Homestead en tu máquina host. Considera clonar el repositorio en una carpeta `Homestead` dentro de tu directorio "home", ya que la máquina virtual de Homestead servirá como el host para todas tus aplicaciones Laravel. A lo largo de esta documentación, nos referiremos a este directorio como tu "directorio Homestead":

```shell
git clone https://github.com/laravel/homestead.git ~/Homestead
```

Después de clonar el repositorio de Laravel Homestead, debes cambiar a la rama `release`. Esta rama siempre contiene la última versión estable de Homestead:

```shell
cd ~/Homestead

git checkout release
```

A continuación, ejecuta el comando `bash init.sh` desde el directorio Homestead para crear el archivo de configuración `Homestead.yaml`. El archivo `Homestead.yaml` es donde configurarás todos los ajustes para tu instalación de Homestead. Este archivo se colocará en el directorio Homestead:

```shell
# macOS / Linux...
bash init.sh

# Windows...
init.bat
```

<a name="configuring-homestead"></a>
### Configurando Homestead

<a name="setting-your-provider"></a>
#### Configurando Tu Proveedor

La clave `provider` en tu archivo `Homestead.yaml` indica qué proveedor de Vagrant debe ser utilizado: `virtualbox` o `parallels`:

    provider: virtualbox

> [!WARNING]  
> Si estás usando Apple Silicon, se requiere el proveedor Parallels.

<a name="configuring-shared-folders"></a>
#### Configurando Carpetas Compartidas

La propiedad `folders` del archivo `Homestead.yaml` lista todas las carpetas que deseas compartir con tu entorno Homestead. A medida que los archivos dentro de estas carpetas cambian, se mantendrán sincronizados entre tu máquina local y el entorno virtual de Homestead. Puedes configurar tantas carpetas compartidas como sea necesario:

```yaml
folders:
    - map: ~/code/project1
      to: /home/vagrant/project1
```

> [!WARNING]  
> Los usuarios de Windows no deben usar la sintaxis de ruta `~/` y en su lugar deben usar la ruta completa a su proyecto, como `C:\Users\user\Code\project1`.

Siempre debes mapear aplicaciones individuales a su propio mapeo de carpeta en lugar de mapear un solo directorio grande que contenga todas tus aplicaciones. Cuando mapeas una carpeta, la máquina virtual debe hacer un seguimiento de todas las operaciones de disco para *cada* archivo en la carpeta. Puedes experimentar una reducción en el rendimiento si tienes un gran número de archivos en una carpeta:

```yaml
folders:
    - map: ~/code/project1
      to: /home/vagrant/project1
    - map: ~/code/project2
      to: /home/vagrant/project2
```

> [!WARNING]  
> Nunca debes montar `.` (el directorio actual) al usar Homestead. Esto provoca que Vagrant no mapee la carpeta actual a `/vagrant` y romperá características opcionales y causará resultados inesperados durante el aprovisionamiento.

Para habilitar [NFS](https://developer.hashicorp.com/vagrant/docs/synced-folders/nfs), puedes agregar una opción `type` a tu mapeo de carpeta:

```yaml
folders:
    - map: ~/code/project1
      to: /home/vagrant/project1
      type: "nfs"
```

> [!WARNING]  
> Al usar NFS en Windows, deberías considerar instalar el complemento [vagrant-winnfsd](https://github.com/winnfsd/vagrant-winnfsd). Este complemento mantendrá los permisos de usuario / grupo correctos para archivos y directorios dentro de la máquina virtual de Homestead.

También puedes pasar cualquier opción soportada por las [Carpetas Sincronizadas](https://developer.hashicorp.com/vagrant/docs/synced-folders/basic_usage) de Vagrant listándolas bajo la clave `options`:

```yaml
folders:
    - map: ~/code/project1
      to: /home/vagrant/project1
      type: "rsync"
      options:
          rsync__args: ["--verbose", "--archive", "--delete", "-zz"]
          rsync__exclude: ["node_modules"]
```

<a name="configuring-nginx-sites"></a>
### Configurando Sitios de Nginx

¿No estás familiarizado con Nginx? No hay problema. La propiedad `sites` de tu archivo `Homestead.yaml` te permite mapear fácilmente un "dominio" a una carpeta en tu entorno Homestead. Una configuración de sitio de muestra está incluida en el archivo `Homestead.yaml`. Nuevamente, puedes agregar tantos sitios a tu entorno Homestead como sea necesario. Homestead puede servir como un entorno virtualizado conveniente para cada aplicación Laravel en la que estés trabajando:

```yaml
sites:
    - map: homestead.test
      to: /home/vagrant/project1/public
```

Si cambias la propiedad `sites` después de aprovisionar la máquina virtual de Homestead, debes ejecutar el comando `vagrant reload --provision` en tu terminal para actualizar la configuración de Nginx en la máquina virtual.

> [!WARNING]  
> Los scripts de Homestead están diseñados para ser lo más idempotentes posible. Sin embargo, si estás experimentando problemas durante el aprovisionamiento, deberías destruir y reconstruir la máquina ejecutando el comando `vagrant destroy && vagrant up`.

<a name="hostname-resolution"></a>
#### Resolución de Nombres de Host

Homestead publica nombres de host utilizando `mDNS` para la resolución automática de hosts. Si estableces `hostname: homestead` en tu archivo `Homestead.yaml`, el host estará disponible en `homestead.local`. macOS, iOS y las distribuciones de escritorio de Linux incluyen soporte para `mDNS` por defecto. Si estás usando Windows, debes instalar [Bonjour Print Services for Windows](https://support.apple.com/kb/DL999?viewlocale=en_US&locale=en_US).

Usar nombres de host automáticos funciona mejor para [instalaciones por proyecto](#per-project-installation) de Homestead. Si alojas múltiples sitios en una sola instancia de Homestead, puedes agregar los "dominios" de tus sitios web al archivo `hosts` en tu máquina. El archivo `hosts` redirigirá las solicitudes para tus sitios de Homestead a tu máquina virtual de Homestead. En macOS y Linux, este archivo se encuentra en `/etc/hosts`. En Windows, se encuentra en `C:\Windows\System32\drivers\etc\hosts`. Las líneas que agregues a este archivo se verán como las siguientes:

    192.168.56.56  homestead.test

Asegúrate de que la dirección IP listada sea la que está configurada en tu archivo `Homestead.yaml`. Una vez que hayas agregado el dominio a tu archivo `hosts` y lanzado la caja de Vagrant, podrás acceder al sitio a través de tu navegador web:

```shell
http://homestead.test
```

<a name="configuring-services"></a>
### Configurando Servicios

Homestead inicia varios servicios por defecto; sin embargo, puedes personalizar qué servicios están habilitados o deshabilitados durante el aprovisionamiento. Por ejemplo, puedes habilitar PostgreSQL y deshabilitar MySQL modificando la opción `services` dentro de tu archivo `Homestead.yaml`:

```yaml
services:
    - enabled:
        - "postgresql"
    - disabled:
        - "mysql"
```

Los servicios especificados se iniciarán o detendrán según su orden en las directivas `enabled` y `disabled`.

<a name="launching-the-vagrant-box"></a>
### Lanzando la Caja de Vagrant

Una vez que hayas editado el `Homestead.yaml` a tu gusto, ejecuta el comando `vagrant up` desde tu directorio Homestead. Vagrant iniciará la máquina virtual y configurará automáticamente tus carpetas compartidas y sitios de Nginx.

Para destruir la máquina, puedes usar el comando `vagrant destroy`.

<a name="per-project-installation"></a>
### Instalación por Proyecto

En lugar de instalar Homestead globalmente y compartir la misma máquina virtual de Homestead entre todos tus proyectos, puedes configurar una instancia de Homestead para cada proyecto que gestiones. Instalar Homestead por proyecto puede ser beneficioso si deseas enviar un `Vagrantfile` con tu proyecto, permitiendo que otros que trabajen en el proyecto hagan `vagrant up` inmediatamente después de clonar el repositorio del proyecto.

Puedes instalar Homestead en tu proyecto usando el gestor de paquetes Composer:

```shell
composer require laravel/homestead --dev
```

Una vez que Homestead ha sido instalado, invoca el comando `make` de Homestead para generar el `Vagrantfile` y el archivo `Homestead.yaml` para tu proyecto. Estos archivos se colocarán en la raíz de tu proyecto. El comando `make` configurará automáticamente las directivas `sites` y `folders` en el archivo `Homestead.yaml`:

```shell
# macOS / Linux...
php vendor/bin/homestead make

# Windows...
vendor\\bin\\homestead make
```

A continuación, ejecuta el comando `vagrant up` en tu terminal y accede a tu proyecto en `http://homestead.test` en tu navegador. Recuerda, aún necesitarás agregar una entrada en el archivo `/etc/hosts` para `homestead.test` o el dominio de tu elección si no estás usando la [resolución automática de nombres de host](#hostname-resolution).

<a name="installing-optional-features"></a>
### Instalando Características Opcionales

El software opcional se instala utilizando la opción `features` dentro de tu archivo `Homestead.yaml`. La mayoría de las características pueden ser habilitadas o deshabilitadas con un valor booleano, mientras que algunas características permiten múltiples opciones de configuración:

```yaml
features:
    - blackfire:
        server_id: "server_id"
        server_token: "server_value"
        client_id: "client_id"
        client_token: "client_value"
    - cassandra: true
    - chronograf: true
    - couchdb: true
    - crystal: true
    - dragonflydb: true
    - elasticsearch:
        version: 7.9.0
    - eventstore: true
        version: 21.2.0
    - flyway: true
    - gearman: true
    - golang: true
    - grafana: true
    - influxdb: true
    - logstash: true
    - mariadb: true
    - meilisearch: true
    - minio: true
    - mongodb: true
    - neo4j: true
    - ohmyzsh: true
    - openresty: true
    - pm2: true
    - python: true
    - r-base: true
    - rabbitmq: true
    - rustc: true
    - rvm: true
    - solr: true
    - timescaledb: true
    - trader: true
    - webdriver: true
```

<a name="elasticsearch"></a>
#### Elasticsearch

Puedes especificar una versión soportada de Elasticsearch, que debe ser un número de versión exacto (mayor.menor.parche). La instalación predeterminada creará un clúster llamado 'homestead'. Nunca debes darle a Elasticsearch más de la mitad de la memoria del sistema operativo, así que asegúrate de que tu máquina virtual de Homestead tenga al menos el doble de la asignación de Elasticsearch.

> [!NOTE]  
> Consulta la [documentación de Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current) para aprender cómo personalizar tu configuración.

<a name="mariadb"></a>
#### MariaDB

Habilitar MariaDB eliminará MySQL e instalará MariaDB. MariaDB generalmente sirve como un reemplazo directo para MySQL, por lo que aún debes usar el controlador de base de datos `mysql` en la configuración de la base de datos de tu aplicación.

<a name="mongodb"></a>
#### MongoDB

La instalación predeterminada de MongoDB establecerá el nombre de usuario de la base de datos en `homestead` y la contraseña correspondiente en `secret`.

<a name="neo4j"></a>
#### Neo4j

La instalación predeterminada de Neo4j establecerá el nombre de usuario de la base de datos en `homestead` y la contraseña correspondiente en `secret`. Para acceder al navegador de Neo4j, visita `http://homestead.test:7474` a través de tu navegador web. Los puertos `7687` (Bolt), `7474` (HTTP) y `7473` (HTTPS) están listos para atender solicitudes del cliente de Neo4j.

<a name="aliases"></a>
### Alias

Puedes agregar alias de Bash a tu máquina virtual de Homestead modificando el archivo `aliases` dentro de tu directorio Homestead:

```shell
alias c='clear'
alias ..='cd ..'
```

Después de haber actualizado el archivo `aliases`, deberías reprovisionar la máquina virtual de Homestead usando el comando `vagrant reload --provision`. Esto asegurará que tus nuevos alias estén disponibles en la máquina.

<a name="updating-homestead"></a>
## Actualizando Homestead

Antes de comenzar a actualizar Homestead, debes asegurarte de haber eliminado tu máquina virtual actual ejecutando el siguiente comando en tu directorio Homestead:

```shell
vagrant destroy
```

A continuación, necesitas actualizar el código fuente de Homestead. Si clonaste el repositorio, puedes ejecutar los siguientes comandos en la ubicación donde originalmente clonaste el repositorio:

```shell
git fetch

git pull origin release
```

Estos comandos obtienen el último código de Homestead del repositorio de GitHub, obtienen las últimas etiquetas y luego cambian a la última versión etiquetada. Puedes encontrar la última versión estable en la [página de lanzamientos de GitHub de Homestead](https://github.com/laravel/homestead/releases).

Si has instalado Homestead a través del archivo `composer.json` de tu proyecto, debes asegurarte de que tu archivo `composer.json` contenga `"laravel/homestead": "^12"` y actualizar tus dependencias:

```shell
composer update
```

A continuación, debes actualizar la caja de Vagrant utilizando el comando `vagrant box update`:

```shell
vagrant box update
```

Después de actualizar la caja de Vagrant, debes ejecutar el comando `bash init.sh` desde el directorio de Homestead para actualizar los archivos de configuración adicionales de Homestead. Se te preguntará si deseas sobrescribir tus archivos existentes `Homestead.yaml`, `after.sh` y `aliases`:

```shell
# macOS / Linux...
bash init.sh

# Windows...
init.bat
```

Finalmente, necesitarás regenerar tu máquina virtual de Homestead para utilizar la última instalación de Vagrant:

```shell
vagrant up
```

<a name="daily-usage"></a>
## Uso Diario

<a name="connecting-via-ssh"></a>
### Conexión a través de SSH

Puedes acceder a tu máquina virtual mediante SSH ejecutando el comando de terminal `vagrant ssh` desde tu directorio de Homestead.

<a name="adding-additional-sites"></a>
### Agregar Sitios Adicionales

Una vez que tu entorno de Homestead esté provisionado y en funcionamiento, es posible que desees agregar sitios Nginx adicionales para tus otros proyectos de Laravel. Puedes ejecutar tantos proyectos de Laravel como desees en un solo entorno de Homestead. Para agregar un sitio adicional, añade el sitio a tu archivo `Homestead.yaml`.

```yaml
sites:
    - map: homestead.test
      to: /home/vagrant/project1/public
    - map: another.test
      to: /home/vagrant/project2/public
```

> [!WARNING]  
> Debes asegurarte de que has configurado un [mapeo de carpetas](#configuring-shared-folders) para el directorio del proyecto antes de agregar el sitio.

Si Vagrant no está gestionando automáticamente tu archivo "hosts", es posible que debas agregar el nuevo sitio a ese archivo también. En macOS y Linux, este archivo se encuentra en `/etc/hosts`. En Windows, se encuentra en `C:\Windows\System32\drivers\etc\hosts`:

    192.168.56.56  homestead.test
    192.168.56.56  another.test

Una vez que se haya agregado el sitio, ejecuta el comando de terminal `vagrant reload --provision` desde tu directorio de Homestead.

<a name="site-types"></a>
#### Tipos de Sitios

Homestead admite varios "tipos" de sitios que te permiten ejecutar fácilmente proyectos que no están basados en Laravel. Por ejemplo, podemos agregar fácilmente una aplicación Statamic a Homestead utilizando el tipo de sitio `statamic`:

```yaml
sites:
    - map: statamic.test
      to: /home/vagrant/my-symfony-project/web
      type: "statamic"
```

Los tipos de sitios disponibles son: `apache`, `apache-proxy`, `apigility`, `expressive`, `laravel` (el predeterminado), `proxy` (para nginx), `silverstripe`, `statamic`, `symfony2`, `symfony4`, y `zf`.

<a name="site-parameters"></a>
#### Parámetros del Sitio

Puedes agregar valores adicionales de `fastcgi_param` de Nginx a tu sitio a través de la directiva del sitio `params`:

```yaml
sites:
    - map: homestead.test
      to: /home/vagrant/project1/public
      params:
          - key: FOO
            value: BAR
```

<a name="environment-variables"></a>
### Variables de Entorno

Puedes definir variables de entorno globales agregándolas a tu archivo `Homestead.yaml`:

```yaml
variables:
    - key: APP_ENV
      value: local
    - key: FOO
      value: bar
```

Después de actualizar el archivo `Homestead.yaml`, asegúrate de reprovisionar la máquina ejecutando el comando `vagrant reload --provision`. Esto actualizará la configuración de PHP-FPM para todas las versiones de PHP instaladas y también actualizará el entorno para el usuario `vagrant`.

<a name="ports"></a>
### Puertos

Por defecto, los siguientes puertos están redirigidos a tu entorno de Homestead:

<div class="content-list" markdown="1">

- **HTTP:** 8000 &rarr; Redirige a 80
- **HTTPS:** 44300 &rarr; Redirige a 443

</div>

<a name="forwarding-additional-ports"></a>
#### Redirigiendo Puertos Adicionales

Si lo deseas, puedes redirigir puertos adicionales a la caja de Vagrant definiendo una entrada de configuración `ports` dentro de tu archivo `Homestead.yaml`. Después de actualizar el archivo `Homestead.yaml`, asegúrate de reprovisionar la máquina ejecutando el comando `vagrant reload --provision`:

```yaml
ports:
    - send: 50000
      to: 5000
    - send: 7777
      to: 777
      protocol: udp
```

A continuación, se muestra una lista de puertos de servicio adicionales de Homestead que puedes mapear desde tu máquina host a tu caja de Vagrant:

<div class="content-list" markdown="1">

- **SSH:** 2222 &rarr; A 22
- **ngrok UI:** 4040 &rarr; A 4040
- **MySQL:** 33060 &rarr; A 3306
- **PostgreSQL:** 54320 &rarr; A 5432
- **MongoDB:** 27017 &rarr; A 27017
- **Mailpit:** 8025 &rarr; A 8025
- **Minio:** 9600 &rarr; A 9600

</div>

<a name="php-versions"></a>
### Versiones de PHP

Homestead admite ejecutar múltiples versiones de PHP en la misma máquina virtual. Puedes especificar qué versión de PHP usar para un sitio dado dentro de tu archivo `Homestead.yaml`. Las versiones de PHP disponibles son: "5.6", "7.0", "7.1", "7.2", "7.3", "7.4", "8.0", "8.1", "8.2", y "8.3" (el predeterminado):

```yaml
sites:
    - map: homestead.test
      to: /home/vagrant/project1/public
      php: "7.1"
```

[Dentro de tu máquina virtual de Homestead](#connecting-via-ssh), puedes usar cualquiera de las versiones de PHP admitidas a través de la CLI:

```shell
php5.6 artisan list
php7.0 artisan list
php7.1 artisan list
php7.2 artisan list
php7.3 artisan list
php7.4 artisan list
php8.0 artisan list
php8.1 artisan list
php8.2 artisan list
php8.3 artisan list
```

Puedes cambiar la versión predeterminada de PHP utilizada por la CLI emitiendo los siguientes comandos desde tu máquina virtual de Homestead:

```shell
php56
php70
php71
php72
php73
php74
php80
php81
php82
php83
```

<a name="connecting-to-databases"></a>
### Conexión a Bases de Datos

Una base de datos `homestead` está configurada para MySQL y PostgreSQL de forma predeterminada. Para conectarte a tu base de datos MySQL o PostgreSQL desde el cliente de base de datos de tu máquina host, debes conectarte a `127.0.0.1` en el puerto `33060` (MySQL) o `54320` (PostgreSQL). El nombre de usuario y la contraseña para ambas bases de datos son `homestead` / `secret`.

> [!WARNING]  
> Solo debes usar estos puertos no estándar al conectarte a las bases de datos desde tu máquina host. Utilizarás los puertos predeterminados 3306 y 5432 en el archivo de configuración `database` de tu aplicación Laravel, ya que Laravel se está ejecutando _dentro_ de la máquina virtual.

<a name="database-backups"></a>
### Copias de Seguridad de Bases de Datos

Homestead puede hacer copias de seguridad automáticamente de tu base de datos cuando tu máquina virtual de Homestead es destruida. Para utilizar esta función, debes estar usando Vagrant 2.1.0 o superior. O, si estás usando una versión anterior de Vagrant, debes instalar el complemento `vagrant-triggers`. Para habilitar las copias de seguridad automáticas de bases de datos, agrega la siguiente línea a tu archivo `Homestead.yaml`:

    backup: true

Una vez configurado, Homestead exportará tus bases de datos a los directorios `.backup/mysql_backup` y `.backup/postgres_backup` cuando se ejecute el comando `vagrant destroy`. Estos directorios se pueden encontrar en la carpeta donde instalaste Homestead o en la raíz de tu proyecto si estás utilizando el método de [instalación por proyecto](#per-project-installation).

<a name="configuring-cron-schedules"></a>
### Configuración de Programaciones de Cron

Laravel proporciona una forma conveniente de [programar trabajos cron](/docs/{{version}}/scheduling) programando un solo comando Artisan `schedule:run` para que se ejecute cada minuto. El comando `schedule:run` examinará la programación de trabajos definida en tu archivo `routes/console.php` para determinar qué tareas programadas ejecutar.

Si deseas que el comando `schedule:run` se ejecute para un sitio de Homestead, puedes establecer la opción `schedule` en `true` al definir el sitio:

```yaml
sites:
    - map: homestead.test
      to: /home/vagrant/project1/public
      schedule: true
```

El trabajo cron para el sitio se definirá en el directorio `/etc/cron.d` de la máquina virtual de Homestead.

<a name="configuring-mailpit"></a>
### Configuración de Mailpit

[Mailpit](https://github.com/axllent/mailpit) te permite interceptar tu correo electrónico saliente y examinarlo sin enviar realmente el correo a sus destinatarios. Para comenzar, actualiza el archivo `.env` de tu aplicación para usar la siguiente configuración de correo:

```ini
MAIL_MAILER=smtp
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

Una vez que Mailpit ha sido configurado, puedes acceder al panel de control de Mailpit en `http://localhost:8025`.

<a name="configuring-minio"></a>
### Configuración de Minio

[Minio](https://github.com/minio/minio) es un servidor de almacenamiento de objetos de código abierto con una API compatible con Amazon S3. Para instalar Minio, actualiza tu archivo `Homestead.yaml` con la siguiente opción de configuración en la sección de [características](#installing-optional-features):

    minio: true

Por defecto, Minio está disponible en el puerto 9600. Puedes acceder al panel de control de Minio visitando `http://localhost:9600`. La clave de acceso predeterminada es `homestead`, mientras que la clave secreta predeterminada es `secretkey`. Al acceder a Minio, siempre debes usar la región `us-east-1`.

Para utilizar Minio, asegúrate de que tu archivo `.env` tenga las siguientes opciones:

```ini
AWS_USE_PATH_STYLE_ENDPOINT=true
AWS_ENDPOINT=http://localhost:9600
AWS_ACCESS_KEY_ID=homestead
AWS_SECRET_ACCESS_KEY=secretkey
AWS_DEFAULT_REGION=us-east-1
```

Para provisionar "buckets" S3 impulsados por Minio, agrega una directiva `buckets` a tu archivo `Homestead.yaml`. Después de definir tus buckets, debes ejecutar el comando `vagrant reload --provision` en tu terminal:

```yaml
buckets:
    - name: your-bucket
      policy: public
    - name: your-private-bucket
      policy: none
```

Los valores de `policy` admitidos incluyen: `none`, `download`, `upload`, y `public`.

<a name="laravel-dusk"></a>
### Laravel Dusk

Para ejecutar pruebas de [Laravel Dusk](/docs/{{version}}/dusk) dentro de Homestead, debes habilitar la [característica `webdriver`](#installing-optional-features) en tu configuración de Homestead:

```yaml
features:
    - webdriver: true
```

Después de habilitar la característica `webdriver`, debes ejecutar el comando `vagrant reload --provision` en tu terminal.

<a name="sharing-your-environment"></a>
### Compartiendo Tu Entorno

A veces, es posible que desees compartir en qué estás trabajando actualmente con compañeros de trabajo o un cliente. Vagrant tiene soporte integrado para esto a través del comando `vagrant share`; sin embargo, esto no funcionará si tienes múltiples sitios configurados en tu archivo `Homestead.yaml`.

Para resolver este problema, Homestead incluye su propio comando `share`. Para comenzar, [SSH en tu máquina virtual de Homestead](#connecting-via-ssh) a través de `vagrant ssh` y ejecuta el comando `share homestead.test`. Este comando compartirá el sitio `homestead.test` de tu archivo de configuración `Homestead.yaml`. Puedes sustituir cualquiera de tus otros sitios configurados por `homestead.test`:

```shell
share homestead.test
```

Después de ejecutar el comando, verás aparecer una pantalla de Ngrok que contiene el registro de actividad y las URL accesibles públicamente para el sitio compartido. Si deseas especificar una región personalizada, subdominio u otra opción de tiempo de ejecución de Ngrok, puedes agregarlas a tu comando `share`:

```shell
share homestead.test -region=eu -subdomain=laravel
```

Si necesitas compartir contenido a través de HTTPS en lugar de HTTP, usar el comando `sshare` en lugar de `share` te permitirá hacerlo.

> [!WARNING]  
> Recuerda, Vagrant es inherentemente inseguro y estás exponiendo tu máquina virtual a Internet al ejecutar el comando `share`.

<a name="debugging-and-profiling"></a>
## Depuración y Perfilado

<a name="debugging-web-requests"></a>
### Depuración de Solicitudes Web con Xdebug

Homestead incluye soporte para depuración paso a paso utilizando [Xdebug](https://xdebug.org). Por ejemplo, puedes acceder a una página en tu navegador y PHP se conectará a tu IDE para permitir la inspección y modificación del código en ejecución.

Por defecto, Xdebug ya está en funcionamiento y listo para aceptar conexiones. Si necesitas habilitar Xdebug en la CLI, ejecuta el comando `sudo phpenmod xdebug` dentro de tu máquina virtual de Homestead. A continuación, sigue las instrucciones de tu IDE para habilitar la depuración. Finalmente, configura tu navegador para activar Xdebug con una extensión o [bookmarklet](https://www.jetbrains.com/phpstorm/marklets/).

> [!WARNING]  
> Xdebug hace que PHP se ejecute significativamente más lento. Para deshabilitar Xdebug, ejecuta `sudo phpdismod xdebug` dentro de tu máquina virtual de Homestead y reinicia el servicio FPM.

<a name="autostarting-xdebug"></a>
#### Inicio Automático de Xdebug

Al depurar pruebas funcionales que realizan solicitudes al servidor web, es más fácil iniciar la depuración automáticamente en lugar de modificar las pruebas para pasar a través de un encabezado o cookie personalizada para activar la depuración. Para forzar a Xdebug a que se inicie automáticamente, modifica el archivo `/etc/php/7.x/fpm/conf.d/20-xdebug.ini` dentro de tu máquina virtual de Homestead y agrega la siguiente configuración:

```ini
; If Homestead.yaml contains a different subnet for the IP address, this address may be different...
xdebug.client_host = 192.168.10.1
xdebug.mode = debug
xdebug.start_with_request = yes
```

<a name="debugging-cli-applications"></a>
### Depuración de Aplicaciones CLI

Para depurar una aplicación PHP CLI, utiliza el alias de shell `xphp` dentro de tu máquina virtual de Homestead:

    xphp /path/to/script

<a name="profiling-applications-with-blackfire"></a>
### Perfilado de Aplicaciones con Blackfire

[Blackfire](https://blackfire.io/docs/introduction) es un servicio para perfilar solicitudes web y aplicaciones CLI. Ofrece una interfaz de usuario interactiva que muestra datos de perfil en gráficos de llamadas y líneas de tiempo. Está diseñado para su uso en desarrollo, pruebas y producción, sin sobrecarga para los usuarios finales. Además, Blackfire proporciona verificaciones de rendimiento, calidad y seguridad en el código y configuraciones de `php.ini`.

El [Blackfire Player](https://blackfire.io/docs/player/index) es una aplicación de código abierto para rastreo web, pruebas web y scraping web que puede trabajar conjuntamente con Blackfire para guiar escenarios de perfilado.

Para habilitar Blackfire, utiliza la configuración "features" en tu archivo de configuración de Homestead:

```yaml
features:
    - blackfire:
        server_id: "server_id"
        server_token: "server_value"
        client_id: "client_id"
        client_token: "client_value"
```

Las credenciales del servidor Blackfire y las credenciales del cliente [requieren una cuenta de Blackfire](https://blackfire.io/signup). Blackfire ofrece varias opciones para perfilar una aplicación, incluyendo una herramienta CLI y una extensión de navegador. Por favor, [revisa la documentación de Blackfire para más detalles](https://blackfire.io/docs/php/integrations/laravel/index).

<a name="network-interfaces"></a>
## Interfaces de Red

La propiedad `networks` del archivo `Homestead.yaml` configura interfaces de red para tu máquina virtual de Homestead. Puedes configurar tantas interfaces como sea necesario:

```yaml
networks:
    - type: "private_network"
      ip: "192.168.10.20"
```

Para habilitar una interfaz [puenteada](https://developer.hashicorp.com/vagrant/docs/networking/public_network), configura una opción `bridge` para la red y cambia el tipo de red a `public_network`:

```yaml
networks:
    - type: "public_network"
      ip: "192.168.10.20"
      bridge: "en1: Wi-Fi (AirPort)"
```

Para habilitar [DHCP](https://developer.hashicorp.com/vagrant/docs/networking/public_network#dhcp), simplemente elimina la opción `ip` de tu configuración:

```yaml
networks:
    - type: "public_network"
      bridge: "en1: Wi-Fi (AirPort)"
```

Para actualizar qué dispositivo está utilizando la red, puedes agregar una opción `dev` a la configuración de la red. El valor predeterminado de `dev` es `eth0`:

```yaml
networks:
    - type: "public_network"
      ip: "192.168.10.20"
      bridge: "en1: Wi-Fi (AirPort)"
      dev: "enp2s0"
```

<a name="extending-homestead"></a>
## Extendiendo Homestead

Puedes extender Homestead utilizando el script `after.sh` en la raíz de tu directorio de Homestead. Dentro de este archivo, puedes agregar cualquier comando de shell que sea necesario para configurar y personalizar adecuadamente tu máquina virtual.

Al personalizar Homestead, Ubuntu puede preguntarte si deseas mantener la configuración original de un paquete o sobrescribirla con un nuevo archivo de configuración. Para evitar esto, debes usar el siguiente comando al instalar paquetes para evitar sobrescribir cualquier configuración previamente escrita por Homestead:

```shell
sudo apt-get -y \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    install package-name
```

<a name="user-customizations"></a>
### Personalizaciones del Usuario

Al usar Homestead con tu equipo, es posible que desees ajustar Homestead para que se adapte mejor a tu estilo de desarrollo personal. Para lograr esto, puedes crear un archivo `user-customizations.sh` en la raíz de tu directorio de Homestead (el mismo directorio que contiene tu archivo `Homestead.yaml`). Dentro de este archivo, puedes hacer cualquier personalización que desees; sin embargo, el `user-customizations.sh` no debe estar bajo control de versiones.

<a name="provider-specific-settings"></a>
## Configuraciones Específicas del Proveedor

<a name="provider-specific-virtualbox"></a>
### VirtualBox

<a name="natdnshostresolver"></a>
#### `natdnshostresolver`

Por defecto, Homestead configura la opción `natdnshostresolver` en `on`. Esto permite que Homestead utilice la configuración DNS de su sistema operativo host. Si desea anular este comportamiento, agregue las siguientes opciones de configuración a su archivo `Homestead.yaml`:

```yaml
provider: virtualbox
natdnshostresolver: 'off'
```
