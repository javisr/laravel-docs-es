# Laravel Sail

- [Introducción](#introduction)
- [Instalación y Configuración](#installation)
  - [Instalar Sail en Aplicaciones Existentes](#installing-sail-into-existing-applications)
  - [Reconstruir Imágenes de Sail](#rebuilding-sail-images)
  - [Configurar un Alias de Shell](#configuring-a-shell-alias)
- [Iniciar y Detener Sail](#starting-and-stopping-sail)
- [Ejecutar Comandos](#executing-sail-commands)
  - [Ejecutar Comandos PHP](#executing-php-commands)
  - [Ejecutar Comandos de Composer](#executing-composer-commands)
  - [Ejecutar Comandos Artisan](#executing-artisan-commands)
  - [Ejecutar Comandos de Node / NPM](#executing-node-npm-commands)
- [Interactuar con Bases de Datos](#interacting-with-sail-databases)
  - [MySQL](#mysql)
  - [Redis](#redis)
  - [Meilisearch](#meilisearch)
  - [Typesense](#typesense)
- [Almacenamiento de Archivos](#file-storage)
- [Ejecutar Pruebas](#running-tests)
  - [Laravel Dusk](#laravel-dusk)
- [Previsualizar Correos Electrónicos](#previewing-emails)
- [Container CLI](#sail-container-cli)
- [Versiones de PHP](#sail-php-versions)
- [Versiones de Node](#sail-node-versions)
- [Compartir tu Sitio](#sharing-your-site)
- [Depuración con Xdebug](#debugging-with-xdebug)
  - [Uso de Xdebug en la CLI](#xdebug-cli-usage)
  - [Uso de Xdebug en el Navegador](#xdebug-browser-usage)
- [Personalización](#sail-customization)

<a name="introduction"></a>
## Introducción

[Laravel Sail](https://github.com/laravel/sail) es una interfaz de línea de comandos ligera para interactuar con el entorno de desarrollo Docker predeterminado de Laravel. Sail ofrece un excelente punto de partida para construir una aplicación Laravel utilizando PHP, MySQL y Redis sin requerir experiencia previa con Docker.
En su esencia, Sail es el archivo `docker-compose.yml` y el script `sail` que se almacena en la raíz de tu proyecto. El script `sail` proporciona una interfaz de línea de comandos (CLI) con métodos convenientes para interactuar con los contenedores Docker definidos por el archivo `docker-compose.yml`.
Laravel Sail es compatible con macOS, Linux y Windows (a través de [WSL2](https://docs.microsoft.com/en-us/windows/wsl/about)).

<a name="installation"></a>
## Instalación y Configuración

Laravel Sail se instala automáticamente con todas las nuevas aplicaciones Laravel, por lo que puedes comenzar a usarlo de inmediato. Para aprender a crear una nueva aplicación Laravel, consulta la [documentación de instalación](/docs/%7B%7Bversion%7D%7D/installation#docker-installation-using-sail) de Laravel para tu sistema operativo. Durante la instalación, se te pedirá que elijas con qué servicios soportados por Sail interactuará tu aplicación.

<a name="installing-sail-into-existing-applications"></a>
### Instalando Sail en Aplicaciones Existentes

Si estás interesado en usar Sail con una aplicación Laravel existente, puedes instalar Sail simplemente utilizando el gestor de paquetes Composer. Por supuesto, estos pasos suponen que tu entorno de desarrollo local existente te permite instalar dependencias de Composer:


```shell
composer require laravel/sail --dev

```
Después de haber instalado Sail, puedes ejecutar el comando Artisan `sail:install`. Este comando publicará el archivo `docker-compose.yml` de Sail en la raíz de tu aplicación y modificará tu archivo `.env` con las variables de entorno necesarias para conectarte a los servicios de Docker:


```shell
php artisan sail:install

```
Finalmente, puedes iniciar Sail. Para seguir aprendiendo cómo usar Sail, por favor continúa leyendo el resto de esta documentación:
> [!WARNING]
Si estás utilizando Docker Desktop para Linux, debes usar el contexto de Docker `default` ejecutando el siguiente comando: `docker context use default`.

<a name="adding-additional-services"></a>
#### Agregar Servicios Adicionales

Si deseas añadir un servicio adicional a tu instalación existente de Sail, puedes ejecutar el comando Artisan `sail:add`:


```shell
php artisan sail:add

```

<a name="using-devcontainers"></a>
#### Usando Devcontainers

Si deseas desarrollar dentro de un [Devcontainer](https://code.visualstudio.com/docs/remote/containers), puedes proporcionar la opción `--devcontainer` al comando `sail:install`. La opción `--devcontainer` indicará al comando `sail:install` que publique un archivo `.devcontainer/devcontainer.json` predeterminado en la raíz de tu aplicación:


```shell
php artisan sail:install --devcontainer

```

<a name="rebuilding-sail-images"></a>
### Reconstruyendo Imágenes de Sail

A veces es posible que desees reconstruir completamente tus imágenes de Sail para asegurar que todos los paquetes y software de la imagen estén actualizados. Puedes lograr esto utilizando el comando `build`:


```shell
docker compose down -v

sail build --no-cache

sail up

```

<a name="configuring-a-shell-alias"></a>
### Configurando un Alias de Shell

Por defecto, los comandos de Sail se invocan utilizando el script `vendor/bin/sail` que se incluye con todas las nuevas aplicaciones Laravel:


```shell
./vendor/bin/sail up

```
Sin embargo, en lugar de escribir repetidamente `vendor/bin/sail` para ejecutar comandos de Sail, es posible que desees configurar un alias de shell que te permita ejecutar los comandos de Sail de manera más fácil:


```shell
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'

```
Para asegurarte de que esto esté siempre disponible, puedes añadirlo a tu archivo de configuración de shell en tu directorio home, como `~/.zshrc` o `~/.bashrc`, y luego reiniciar tu shell.
Una vez que se ha configurado el alias de shell, puedes ejecutar comandos de Sail simplemente escribiendo `sail`. El resto de los ejemplos de esta documentación asumirán que has configurado este alias:

<a name="starting-and-stopping-sail"></a>
## Iniciando y Deteniendo Sail

El archivo `docker-compose.yml` de Laravel Sail define una variedad de contenedores Docker que trabajan juntos para ayudarte a construir aplicaciones Laravel. Cada uno de estos contenedores es una entrada dentro de la configuración `services` de tu archivo `docker-compose.yml`. El contenedor `laravel.test` es el contenedor principal de la aplicación que estará sirviendo tu aplicación.
Antes de iniciar Sail, debes asegurarte de que no haya otros servidores web o bases de datos en funcionamiento en tu computadora local. Para iniciar todos los contenedores de Docker definidos en el archivo `docker-compose.yml` de tu aplicación, debes ejecutar el comando `up`:


```shell
sail up

```
Para iniciar todos los contenedores de Docker en segundo plano, puedes iniciar Sail en modo "desprendido":


```shell
sail up -d

```
Una vez que se hayan iniciado los contenedores de la aplicación, puedes acceder al proyecto en tu navegador web en: http://localhost.
Para detener todos los contenedores, simplemente puedes presionar Control + C para detener la ejecución del contenedor. O, si los contenedores se están ejecutando en segundo plano, puedes usar el comando `stop`:


```shell
sail stop

```

<a name="executing-sail-commands"></a>
## Ejecutando Comandos

Al usar Laravel Sail, tu aplicación se está ejecutando dentro de un contenedor Docker y está aislada de tu computadora local. Sin embargo, Sail proporciona una forma conveniente de ejecutar varios comandos contra tu aplicación, como comandos PHP arbitrarios, comandos Artisan, comandos Composer y comandos de Node / NPM.
**Al leer la documentación de Laravel, a menudo verás referencias a comandos de Composer, Artisan y Node / NPM que no hacen referencia a Sail.** Esos ejemplos asumen que estas herramientas están instaladas en tu computadora local. Si estás utilizando Sail para tu entorno de desarrollo local de Laravel, debes ejecutar esos comandos utilizando Sail:


```shell
# Running Artisan commands locally...
php artisan queue:work

# Running Artisan commands within Laravel Sail...
sail artisan queue:work

```

<a name="executing-php-commands"></a>
### Ejecutando Comandos PHP

Los comandos de PHP se pueden ejecutar utilizando el comando `php`. Por supuesto, estos comandos se ejecutarán utilizando la versión de PHP que está configurada para tu aplicación. Para obtener más información sobre las versiones de PHP disponibles para Laravel Sail, consulta la [documentación de versiones de PHP](#sail-php-versions):


```shell
sail php --version

sail php script.php

```

<a name="executing-composer-commands"></a>
### Ejecutando Comandos de Composer

Los comandos de Composer pueden ejecutarse utilizando el comando `composer`. El contenedor de la aplicación de Laravel Sail incluye una instalación de Composer:


```nothing
sail composer require laravel/sanctum

```

<a name="installing-composer-dependencies-for-existing-projects"></a>
#### Instalando Dependencias de Composer para Aplicaciones Existentes

Si estás desarrollando una aplicación con un equipo, es posible que no seas quien inicialmente crea la aplicación Laravel. Por lo tanto, ninguna de las dependencias de Composer de la aplicación, incluyendo Sail, se instalará después de que clones el repositorio de la aplicación en tu computadora local.
Puedes instalar las dependencias de la aplicación navegando al directorio de la aplicación y ejecutando el siguiente comando. Este comando utiliza un pequeño contenedor de Docker que contiene PHP y Composer para instalar las dependencias de la aplicación:


```shell
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):/var/www/html" \
    -w /var/www/html \
    laravelsail/php83-composer:latest \
    composer install --ignore-platform-reqs

```
Al usar la imagen `laravelsail/phpXX-composer`, debes usar la misma versión de PHP que planeas usar para tu aplicación (`80`, `81`, `82` o `83`).

<a name="executing-artisan-commands"></a>
### Ejecución de Comandos Artisan

Los comandos de Laravel Artisan pueden ejecutarse utilizando el comando `artisan`:


```shell
sail artisan queue:work

```

<a name="executing-node-npm-commands"></a>
### Ejecutando Comandos de Node / NPM

Los comandos de Node pueden ejecutarse utilizando el comando `node`, mientras que los comandos de NPM pueden ejecutarse utilizando el comando `npm`:


```shell
sail node --version

sail npm run dev

```
Si lo deseas, puedes usar Yarn en lugar de NPM:


```shell
sail yarn

```

<a name="interacting-with-sail-databases"></a>
## Interacción con Bases de Datos


<a name="mysql"></a>
### MySQL

Como habrás notado, el archivo `docker-compose.yml` de tu aplicación contiene una entrada para un contenedor MySQL. Este contenedor utiliza un [volumen de Docker](https://docs.docker.com/storage/volumes/) para que los datos almacenados en tu base de datos se conserven incluso al detener y reiniciar tus contenedores.
Además, la primera vez que se inicia el contenedor MySQL, creará dos bases de datos para ti. La primera base de datos se nombra utilizando el valor de tu variable de entorno `DB_DATABASE` y es para tu desarrollo local. La segunda es una base de datos de prueba dedicada llamada `testing` y asegurará que tus pruebas no interfieran con tus datos de desarrollo.
Una vez que hayas iniciado tus contenedores, puedes conectarte a la instancia de MySQL dentro de tu aplicación configurando tu variable de entorno `DB_HOST` dentro del archivo `.env` de tu aplicación a `mysql`.
Para conectarte a la base de datos MySQL de tu aplicación desde tu máquina local, puedes usar una aplicación gráfica de gestión de bases de datos como [TablePlus](https://tableplus.com). Por defecto, la base de datos MySQL es accesible en `localhost` puerto 3306 y las credenciales de acceso corresponden a los valores de tus variables de entorno `DB_USERNAME` y `DB_PASSWORD`. O bien, puedes conectarte como el usuario `root`, que también utiliza el valor de tu variable de entorno `DB_PASSWORD` como su contraseña.

<a name="redis"></a>
### Redis

El archivo `docker-compose.yml` de tu aplicación también contiene una entrada para un contenedor de [Redis](https://redis.io). Este contenedor utiliza un [volumen de Docker](https://docs.docker.com/storage/volumes/) para que los datos almacenados en tu datos de Redis se persistan incluso al detener y reiniciar tus contenedores. Una vez que hayas iniciado tus contenedores, puedes conectarte a la instancia de Redis dentro de tu aplicación configurando tu variable de entorno `REDIS_HOST` en el archivo `.env` de tu aplicación a `redis`.
Para conectarte a la base de datos Redis de tu aplicación desde tu máquina local, puedes usar una aplicación de gestión de bases de datos gráfica como [TablePlus](https://tableplus.com). Por defecto, la base de datos Redis es accesible en `localhost` puerto 6379.

<a name="meilisearch"></a>
### Meilisearch

Si elegiste instalar el servicio [Meilisearch](https://www.meilisearch.com) al instalar Sail, el archivo `docker-compose.yml` de tu aplicación contendrá una entrada para este potente motor de búsqueda que está integrado con [Laravel Scout](/docs/%7B%7Bversion%7D%7D/scout). Una vez que hayas iniciado tus contenedores, puedes conectarte a la instancia de Meilisearch dentro de tu aplicación configurando tu variable de entorno `MEILISEARCH_HOST` en `http://meilisearch:7700`.
Desde tu máquina local, puedes acceder al panel de administración basado en la web de Meilisearch navegando a `http://localhost:7700` en tu navegador web.

<a name="typesense"></a>
### Typesense

Si elegiste instalar el servicio [Typesense](https://typesense.org) al instalar Sail, el archivo `docker-compose.yml` de tu aplicación contendrá una entrada para este motor de búsqueda de código abierto, extremadamente rápido, que está integrado de forma nativa con [Laravel Scout](/docs/%7B%7Bversion%7D%7D/scout#typesense). Una vez que hayas iniciado tus contenedores, puedes conectarte a la instancia de Typesense dentro de tu aplicación configurando las siguientes variables de entorno:


```ini
TYPESENSE_HOST=typesense
TYPESENSE_PORT=8108
TYPESENSE_PROTOCOL=http
TYPESENSE_API_KEY=xyz

```
Desde tu máquina local, puedes acceder a la API de Typesense a través de `http://localhost:8108`.

<a name="file-storage"></a>
## Almacenamiento de Archivos

Si planeas usar Amazon S3 para almacenar archivos mientras ejecutas tu aplicación en su entorno de producción, es posible que desees instalar el servicio [MinIO](https://min.io) al instalar Sail. MinIO proporciona una API compatible con S3 que puedes usar para desarrollar localmente utilizando el driver de almacenamiento de archivos `s3` de Laravel sin crear cubos de almacenamiento "de prueba" en tu entorno S3 de producción. Si eliges instalar MinIO mientras instalas Sail, se añadirá una sección de configuración de MinIO al archivo `docker-compose.yml` de tu aplicación.
Por defecto, el archivo de configuración `filesystems` de tu aplicación ya contiene una configuración de disco para el disco `s3`. Además de usar este disco para interactuar con Amazon S3, puedes usarlo para interactuar con cualquier servicio de almacenamiento de archivos compatible con S3, como MinIO, simplemente modificando las variables de entorno asociadas que controlan su configuración. Por ejemplo, al usar MinIO, la configuración de tus variables de entorno del sistema de archivos debe definirse de la siguiente manera:


```ini
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=sail
AWS_SECRET_ACCESS_KEY=password
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=local
AWS_ENDPOINT=http://minio:9000
AWS_USE_PATH_STYLE_ENDPOINT=true

```
Para que la integración de Flysystem de Laravel genere URL adecuadas al usar MinIO, debes definir la variable de entorno `AWS_URL` para que coincida con la URL local de tu aplicación e incluya el nombre del bucket en la ruta de la URL:


```ini
AWS_URL=http://localhost:9000/local

```
Puedes crear depósitos a través de la consola de MinIO, que está disponible en `http://localhost:8900`. El nombre de usuario predeterminado para la consola de MinIO es `sail`, mientras que la contraseña predeterminada es `password`.
> [!WARNING]
Generar URL de almacenamiento temporal a través del método `temporaryUrl` no es compatible cuando se usa MinIO.

<a name="running-tests"></a>
## Ejecución de Pruebas

Laravel ofrece un soporte de prueba increíble desde el principio, y puedes usar el comando `test` de Sail para ejecutar las [pruebas de características y unitarias](/docs/%7B%7Bversion%7D%7D/testing) de tus aplicaciones. Cualquier opción de línea de comandos que sea aceptada por Pest / PHPUnit también puede ser pasada al comando `test`:


```shell
sail test

sail test --group orders

```
El comando `test` de Sail equivale a ejecutar el comando `test` de Artisan:


```shell
sail artisan test

```
Por defecto, Sail creará una base de datos dedicada `testing` para que tus pruebas no interfieran con el estado actual de tu base de datos. En una instalación predeterminada de Laravel, Sail también configurará tu archivo `phpunit.xml` para usar esta base de datos al ejecutar tus pruebas:


```xml
<env name="DB_DATABASE" value="testing"/>

```

<a name="laravel-dusk"></a>
### Laravel Dusk

[Laravel Dusk](/docs/%7B%7Bversion%7D%7D/dusk) proporciona una API de automatización y pruebas de navegador expresiva y fácil de usar. Gracias a Sail, puedes ejecutar estas pruebas sin necesidad de instalar Selenium u otras herramientas en tu computadora local. Para comenzar, descomenta el servicio de Selenium en el archivo `docker-compose.yml` de tu aplicación:


```yaml
selenium:
    image: 'selenium/standalone-chrome'
    extra_hosts:
      - 'host.docker.internal:host-gateway'
    volumes:
        - '/dev/shm:/dev/shm'
    networks:
        - sail

```
A continuación, asegúrate de que el servicio `laravel.test` en el archivo `docker-compose.yml` de tu aplicación tenga una entrada `depends_on` para `selenium`:


```yaml
depends_on:
    - mysql
    - redis
    - selenium

```
Finalmente, puedes ejecutar tu suite de pruebas Dusk iniciando Sail y ejecutando el comando `dusk`:


```shell
sail dusk

```

<a name="selenium-on-apple-silicon"></a>
#### Selenium en Apple Silicon

Si tu máquina local contiene un chip Apple Silicon, tu servicio `selenium` debe usar la imagen `seleniarm/standalone-chromium`:


```yaml
selenium:
    image: 'seleniarm/standalone-chromium'
    extra_hosts:
        - 'host.docker.internal:host-gateway'
    volumes:
        - '/dev/shm:/dev/shm'
    networks:
        - sail

```

<a name="previewing-emails"></a>
## Previsualizando Correos Electrónicos

El archivo `docker-compose.yml` predeterminado de Laravel Sail contiene una entrada de servicio para [Mailpit](https://github.com/axllent/mailpit). Mailpit intercepta los correos electrónicos enviados por tu aplicación durante el desarrollo local y proporciona una interfaz web conveniente para que puedas previsualizar tus mensajes de correo electrónico en tu navegador. Al usar Sail, el host predeterminado de Mailpit es `mailpit` y está disponible a través del puerto 1025:


```ini
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_ENCRYPTION=null

```
Cuando Sail está en funcionamiento, puedes acceder a la interfaz web de Mailpit en: http://localhost:8025

<a name="sail-container-cli"></a>
## CLI de Container

A veces es posible que desees iniciar una sesión de Bash dentro del contenedor de tu aplicación. Puedes usar el comando `shell` para conectarte al contenedor de tu aplicación, lo que te permite inspeccionar sus archivos y servicios instalados, así como ejecutar comandos de shell arbitrarios dentro del contenedor:


```shell
sail shell

sail root-shell

```
Para iniciar una nueva sesión de [Laravel Tinker](https://github.com/laravel/tinker), puedes ejecutar el comando `tinker`:


```shell
sail tinker

```

<a name="sail-php-versions"></a>
## Versiones de PHP

Sail actualmente admite servir tu aplicación a través de PHP 8.3, 8.2, 8.1 o PHP 8.0. La versión predeterminada de PHP utilizada por Sail es actualmente PHP 8.3. Para cambiar la versión de PHP que se utiliza para servir tu aplicación, debes actualizar la definición `build` del contenedor `laravel.test` en el archivo `docker-compose.yml` de tu aplicación:


```yaml
# PHP 8.3
context: ./vendor/laravel/sail/runtimes/8.3

# PHP 8.2
context: ./vendor/laravel/sail/runtimes/8.2

# PHP 8.1
context: ./vendor/laravel/sail/runtimes/8.1

# PHP 8.0
context: ./vendor/laravel/sail/runtimes/8.0

```
Además, es posible que desees actualizar el nombre de tu `image` para reflejar la versión de PHP que está utilizando tu aplicación. Esta opción también se define en el archivo `docker-compose.yml` de tu aplicación:


```yaml
image: sail-8.2/app

```

<a name="sail-node-versions"></a>
## Versiones de Node

Sail instala Node 20 por defecto. Para cambiar la versión de Node que se instala al construir tus imágenes, puedes actualizar la definición de `build.args` del servicio `laravel.test` en el archivo `docker-compose.yml` de tu aplicación:


```yaml
build:
    args:
        WWWGROUP: '${WWWGROUP}'
        NODE_VERSION: '18'

```
Después de actualizar el archivo `docker-compose.yml` de tu aplicación, deberías reconstruir las imágenes de tus contenedores:


```shell
sail build --no-cache

sail up

```

<a name="sharing-your-site"></a>
## Compartiendo Tu Sitio

A veces es posible que necesites compartir tu sitio públicamente para poder previsualizar tu sitio para un colega o para probar integraciones de webhook con tu aplicación. Para compartir tu sitio, puedes usar el comando `share`. Después de ejecutar este comando, se te emitirá una URL aleatoria de `laravel-sail.site` que puedes usar para acceder a tu aplicación:


```shell
sail share

```
Al compartir tu sitio a través del comando `share`, debes configurar los proxies de confianza de tu aplicación utilizando el método `trustProxies` del middleware en el archivo `bootstrap/app.php` de tu aplicación. De lo contrario, los ayudantes de generación de URL como `url` y `route` no podrán determinar el host HTTP correcto que se debe usar durante la generación de URL:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->trustProxies(at: '*');
})
```
Si deseas elegir el subdominio para tu sitio compartido, puedes proporcionar la opción `subdomain` al ejecutar el comando `share`:


```shell
sail share --subdomain=my-sail-site

```
> [!NOTA]
El comando `share` está impulsado por [Expose](https://github.com/beyondcode/expose), un servicio de túnel de código abierto de [BeyondCode](https://beyondco.de).

<a name="debugging-with-xdebug"></a>
## Depurando con Xdebug

La configuración de Docker de Laravel Sail incluye soporte para [Xdebug](https://xdebug.org/), un depurador popular y poderoso para PHP. Para habilitar Xdebug, necesitarás añadir algunas variables al archivo `.env` de tu aplicación para [configurar Xdebug](https://xdebug.org/docs/step_debug#mode). Para habilitar Xdebug, debes establecer el(los) modo(s) apropiado(s) antes de iniciar Sail:


```ini
SAIL_XDEBUG_MODE=develop,debug,coverage

```
#### Configuración de IP de Host Linux

Internamente, la variable de entorno `XDEBUG_CONFIG` se define como `client_host=host.docker.internal` para que Xdebug se configure correctamente para Mac y Windows (WSL2). Si tu máquina local está ejecutando Linux, debes asegurarte de que estás ejecutando Docker Engine 17.06.0+ y Compose 1.16.0+. De lo contrario, necesitarás definir manualmente esta variable de entorno como se muestra a continuación.
Primero, debes determinar la dirección IP del host correcta que agregar a la variable de entorno ejecutando el siguiente comando. Típicamente, `<container-name>` debería ser el nombre del contenedor que sirve tu aplicación y a menudo termina con `_laravel.test_1`:


```shell
docker inspect -f {{range.NetworkSettings.Networks}}{{.Gateway}}{{end}} <container-name>

```
Una vez que hayas obtenido la dirección IP del host correcta, deberías definir la variable `SAIL_XDEBUG_CONFIG` dentro del archivo `.env` de tu aplicación:


```ini
SAIL_XDEBUG_CONFIG="client_host=<host-ip-address>"

```

<a name="xdebug-cli-usage"></a>
### Uso de Xdebug en la CLI

Se puede usar un comando `sail debug` para iniciar una sesión de depuración al ejecutar un comando Artisan:


```shell
# Run an Artisan command without Xdebug...
sail artisan migrate

# Run an Artisan command with Xdebug...
sail debug migrate

```

<a name="xdebug-browser-usage"></a>
### Uso del Navegador de Xdebug

Para depurar tu aplicación mientras interactúas con la aplicación a través de un navegador web, sigue las [instrucciones proporcionadas por Xdebug](https://xdebug.org/docs/step_debug#web-application) para iniciar una sesión de Xdebug desde el navegador web.
Si estás utilizando PhpStorm, por favor revisa la documentación de JetBrains sobre la [depuración sin configuración](https://www.jetbrains.com/help/phpstorm/zero-configuration-debugging.html).
> [!WARNING]
Laravel Sail depende de `artisan serve` para servir tu aplicación. El comando `artisan serve` solo acepta las variables `XDEBUG_CONFIG` y `XDEBUG_MODE` a partir de la versión 8.53.0 de Laravel. Las versiones anteriores de Laravel (8.52.0 y inferiores) no admiten estas variables y no aceptarán conexiones de depuración.

<a name="sail-customization"></a>
## Personalización

Dado que Sail es solo Docker, puedes personalizar casi todo sobre él. Para publicar los Dockerfiles de Sail, puedes ejecutar el comando `sail:publish`:


```shell
sail artisan sail:publish

```
Después de ejecutar este comando, los Dockerfiles y otros archivos de configuración utilizados por Laravel Sail se colocarán dentro de un directorio `docker` en el directorio raíz de tu aplicación. Después de personalizar tu instalación de Sail, es posible que desees cambiar el nombre de la imagen para el contenedor de la aplicación en el archivo `docker-compose.yml` de tu aplicación. Después de hacerlo, reconstruye los contenedores de tu aplicación utilizando el comando `build`. Asignar un nombre único a la imagen de la aplicación es particularmente importante si estás utilizando Sail para desarrollar múltiples aplicaciones Laravel en una sola máquina:


```shell
sail build --no-cache

```