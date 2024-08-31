# Laravel Reverb

- [Introducción](#introduction)
- [Instalación](#installation)
- [Configuración](#configuration)
  - [Credenciales de la Aplicación](#application-credentials)
  - [Orígenes Permitidos](#allowed-origins)
  - [Aplicaciones Adicionales](#additional-applications)
  - [SSL](#ssl)
- [Ejecutando el Servidor](#running-server)
  - [Depuración](#debugging)
  - [Reiniciar](#restarting)
- [Monitoreo](#monitoring)
- [Ejecutando Reverb en Producción](#production)
  - [Archivos Abiertos](#open-files)
  - [Bucle de Eventos](#event-loop)
  - [Servidor Web](#web-server)
  - [Puertos](#ports)
  - [Gestión de Procesos](#process-management)
  - [Escalado](#scaling)

<a name="introduction"></a>
## Introducción

[Laravel Reverb](https://github.com/laravel/reverb) trae comunicación WebSocket en tiempo real, rápida y escalable, directamente a tu aplicación Laravel, y proporciona una integración fluida con la suite existente de [herramientas de difusión de eventos](/docs/%7B%7Bversion%7D%7D/broadcasting) de Laravel.

<a name="installation"></a>
## Instalación

Puedes instalar Reverb utilizando el comando Artisan `install:broadcasting`:


```
php artisan install:broadcasting

```

<a name="configuration"></a>
## Configuración

Detrás de escena, el comando Artisan `install:broadcasting` ejecutará el comando `reverb:install`, que instalará Reverb con un conjunto razonable de opciones de configuración predeterminadas. Si deseas realizar cambios en la configuración, puedes hacerlo actualizando las variables de entorno de Reverb o actualizando el archivo de configuración `config/reverb.php`.

<a name="application-credentials"></a>
### Credenciales de la Aplicación

Para establecer una conexión con Reverb, se debe intercambiar un conjunto de credenciales "de aplicación" de Reverb entre el cliente y el servidor. Estas credenciales se configuran en el servidor y se utilizan para verificar la solicitud del cliente. Puedes definir estas credenciales utilizando las siguientes variables de entorno:


```ini
REVERB_APP_ID=my-app-id
REVERB_APP_KEY=my-app-key
REVERB_APP_SECRET=my-app-secret

```

<a name="allowed-origins"></a>
### Orígenes Permitidos

También puedes definir los orígenes de los cuales pueden provenir las solicitudes del cliente actualizando el valor de la configuración `allowed_origins` dentro de la sección `apps` del archivo de configuración `config/reverb.php`. Cualquier solicitud de un origen no listado en tus orígenes permitidos será rechazada. Puedes permitir todos los orígenes usando `*`:


```php
'apps' => [
    [
        'id' => 'my-app-id',
        'allowed_origins' => ['laravel.com'],
        // ...
    ]
]

```

<a name="additional-applications"></a>
### Aplicaciones Adicionales

Típicamente, Reverb proporciona un servidor WebSocket para la aplicación en la que está instalado. Sin embargo, es posible servir más de una aplicación utilizando una sola instalación de Reverb.
Por ejemplo, es posible que desees mantener una sola aplicación Laravel que, a través de Reverb, proporcione conectividad WebSocket para múltiples aplicaciones. Esto se puede lograr definiendo múltiples `apps` en el archivo de configuración `config/reverb.php` de tu aplicación:


```php
'apps' => [
    [
        'app_id' => 'my-app-one',
        // ...
    ],
    [
        'app_id' => 'my-app-two',
        // ...
    ],
],

```

<a name="ssl"></a>
### SSL

En la mayoría de los casos, las conexiones WebSocket seguras son manejadas por el servidor web ascendente (Nginx, etc.) antes de que la solicitud sea proxy a tu servidor Reverb.
Sin embargo, a veces puede ser útil, como durante el desarrollo local, que el servidor Reverb maneje conexiones seguras directamente. Si estás usando la función de sitio seguro de [Laravel Herd](https://herd.laravel.com) o estás utilizando [Laravel Valet](/docs/%7B%7Bversion%7D%7D/valet) y has ejecutado el [comando seguro](/docs/%7B%7Bversion%7D%7D/valet#securing-sites) en tu aplicación, puedes usar el certificado de Herd / Valet generado para tu sitio para asegurar tus conexiones Reverb. Para hacerlo, establece la variable de entorno `REVERB_HOST` en el nombre de host de tu sitio o pasa explícitamente la opción de nombre de host al iniciar el servidor Reverb:


```sh
php artisan reverb:start --host="0.0.0.0" --port=8080 --hostname="laravel.test"

```
Dado que los dominios de Herd y Valet se resuelven en `localhost`, ejecutar el comando anterior resultará en que tu servidor Reverb sea accesible a través del protocolo WebSocket seguro (`wss`) en `wss://laravel.test:8080`.
También puedes elegir un certificado manualmente definiendo las opciones `tls` en el archivo de configuración `config/reverb.php` de tu aplicación. Dentro del array de opciones `tls`, puedes proporcionar cualquiera de las opciones soportadas por [las opciones de contexto SSL de PHP](https://www.php.net/manual/en/context.ssl.php):


```php
'options' => [
    'tls' => [
        'local_cert' => '/path/to/cert.pem'
    ],
],

```

<a name="running-server"></a>
## Ejecutando el Servidor

El servidor Reverb se puede iniciar utilizando el comando Artisan `reverb:start`:


```sh
php artisan reverb:start

```
Por defecto, el servidor de Reverb se iniciará en `0.0.0.0:8080`, lo que lo hará accesible desde todas las interfaces de red.
Si necesitas especificar un host o puerto personalizado, puedes hacerlo a través de las opciones `--host` y `--port` al iniciar el servidor:


```sh
php artisan reverb:start --host=127.0.0.1 --port=9000

```
Alternativamente, puedes definir las variables de entorno `REVERB_SERVER_HOST` y `REVERB_SERVER_PORT` en el archivo de configuración `.env` de tu aplicación.
Las variables de entorno `REVERB_SERVER_HOST` y `REVERB_SERVER_PORT` no deben confundirse con `REVERB_HOST` y `REVERB_PORT`. Las primeras especifican el host y el puerto en los que se debe ejecutar el servidor Reverb, mientras que el segundo par instruye a Laravel sobre dónde enviar los mensajes de difusión. Por ejemplo, en un entorno de producción, es posible que desees enrutar las solicitudes desde tu nombre de host público de Reverb en el puerto `443` a un servidor Reverb que opere en `0.0.0.0:8080`. En este escenario, tus variables de entorno se definirían de la siguiente manera:


```ini
REVERB_SERVER_HOST=0.0.0.0
REVERB_SERVER_PORT=8080

REVERB_HOST=ws.laravel.com
REVERB_PORT=443

```

<a name="debugging"></a>
### Depuración

Para mejorar el rendimiento, Reverb no output ningún información de depuración por defecto. Si deseas ver el flujo de datos que pasa a través de tu servidor Reverb, puedes proporcionar la opción `--debug` al comando `reverb:start`:


```sh
php artisan reverb:start --debug

```

<a name="restarting"></a>
### Reiniciando

Dado que Reverb es un proceso de larga duración, los cambios en tu código no se reflejarán sin reiniciar el servidor a través del comando Artisan `reverb:restart`.
El comando `reverb:restart` asegura que todas las conexiones se terminen de manera ordenada antes de detener el servidor. Si estás ejecutando Reverb con un gestor de procesos como Supervisor, el servidor se reiniciará automáticamente por el gestor de procesos una vez que se hayan terminado todas las conexiones:


```sh
php artisan reverb:restart

```

<a name="monitoring"></a>
## Monitoreo

Reverb se puede monitorear a través de una integración con [Laravel Pulse](/docs/%7B%7Bversion%7D%7D/pulse). Al habilitar la integración de Pulse de Reverb, puedes rastrear el número de conexiones y mensajes que está manejando tu servidor.
Para habilitar la integración, primero debes asegurarte de que hayas [instalado Pulse](/docs/%7B%7Bversion%7D%7D/pulse#installation). Luego, añade cualquiera de los grabadores de Reverb al archivo de configuración `config/pulse.php` de tu aplicación:


```php
use Laravel\Reverb\Pulse\Recorders\ReverbConnections;
use Laravel\Reverb\Pulse\Recorders\ReverbMessages;

'recorders' => [
    ReverbConnections::class => [
        'sample_rate' => 1,
    ],

    ReverbMessages::class => [
        'sample_rate' => 1,
    ],

    ...
],

```
A continuación, añade las tarjetas de Pulse para cada grabador a tu [tablero de Pulse](/docs/%7B%7Bversion%7D%7D/pulse#dashboard-customization):


```blade
<x-pulse>
    <livewire:reverb.connections cols="full" />
    <livewire:reverb.messages cols="full" />
    ...
</x-pulse>

```

<a name="production"></a>
## Ejecutando Reverb en Producción

Debido a la naturaleza de larga duración de los servidores WebSocket, es posible que necesites hacer algunas optimizaciones en tu servidor y entorno de hosting para garantizar que tu servidor Reverb pueda manejar eficazmente el número óptimo de conexiones para los recursos disponibles en tu servidor.
> [!NOTA]
Si tu sitio es gestionado por [Laravel Forge](https://forge.laravel.com), puedes optimizar automáticamente tu servidor para Reverb directamente desde el panel de "Aplicación". Al habilitar la integración de Reverb, Forge se asegurará de que tu servidor esté listo para producción, incluyendo la instalación de cualquier extensión requerida y el aumento del número permitido de conexiones.

<a name="open-files"></a>
### Abrir Archivos

Cada conexión WebSocket se mantiene en memoria hasta que el cliente o el servidor se desconectan. En entornos Unix y similares a Unix, cada conexión está representada por un archivo. Sin embargo, a menudo hay límites en el número de archivos abiertos permitidos tanto a nivel del sistema operativo como a nivel de aplicación.

<a name="operating-system"></a>
#### Sistema Operativo

En un sistema operativo basado en Unix, puedes determinar el número permitido de archivos abiertos utilizando el comando `ulimit`:


```sh
ulimit -n

```
Este comando mostrará los límites de archivos abiertos permitidos para diferentes usuarios. Puedes actualizar estos valores editando el archivo `/etc/security/limits.conf`. Por ejemplo, actualizar el número máximo de archivos abiertos a 10,000 para el usuario `forge` se vería así:


```ini
# /etc/security/limits.conf
forge        soft  nofile  10000
forge        hard  nofile  10000

```

<a name="event-loop"></a>
### Bucle de Eventos

Bajo el capó, Reverb utiliza un bucle de eventos de ReactPHP para gestionar las conexiones WebSocket en el servidor. Por defecto, este bucle de eventos es impulsado por `stream_select`, que no requiere extensiones adicionales. Sin embargo, `stream_select` suele estar limitado a 1,024 archivos abiertos. Como tal, si planeas manejar más de 1,000 conexiones concurrentes, necesitarás usar un bucle de eventos alternativo que no esté sujeto a las mismas restricciones.
Reverb cambiará automáticamente a un bucle alimentado por `ext-uv` cuando esté disponible. Esta extensión de PHP se puede instalar a través de PECL:


```sh
pecl install uv

```

<a name="web-server"></a>
### Servidor Web

En la mayoría de los casos, Reverb se ejecuta en un puerto no expuesto a la web en tu servidor. Así que, para enrutar el tráfico a Reverb, debes configurar un proxy inverso. Suponiendo que Reverb esté ejecutándose en el host `0.0.0.0` y el puerto `8080`, y que tu servidor utilice el servidor web Nginx, se puede definir un proxy inverso para tu servidor Reverb utilizando la siguiente configuración del sitio Nginx:


```nginx
server {
    ...

    location / {
        proxy_http_version 1.1;
        proxy_set_header Host $http_host;
        proxy_set_header Scheme $scheme;
        proxy_set_header SERVER_PORT $server_port;
        proxy_set_header REMOTE_ADDR $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";

        proxy_pass http://0.0.0.0:8080;
    }

    ...
}

```
> [!WARNING]
Reverb escucha conexiones WebSocket en `/app` y maneja solicitudes API en `/apps`. Debes asegurarte de que el servidor web que maneja las solicitudes de Reverb pueda servir ambas URI. Si estás utilizando [Laravel Forge](https://forge.laravel.com) para gestionar tus servidores, tu servidor Reverb estará configurado correctamente por defecto.
Típicamente, los servidores web están configurados para limitar el número de conexiones permitidas con el fin de evitar la sobrecarga del servidor. Para aumentar el número de conexiones permitidas en un servidor web Nginx a 10,000, los valores `worker_rlimit_nofile` y `worker_connections` del archivo `nginx.conf` deben actualizarse:


```nginx
user forge;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
worker_rlimit_nofile 10000;

events {
  worker_connections 10000;
  multi_accept on;
}

```
La configuración anterior permitirá que se generen hasta 10,000 trabajadores de Nginx por proceso. Además, esta configuración establece el límite de archivos abiertos de Nginx en 10,000.

<a name="ports"></a>
### Puertos

Los sistemas operativos basados en Unix típicamente limitan el número de puertos que se pueden abrir en el servidor. Puedes ver el rango permitido actual a través del siguiente comando:
 ```sh
 cat /proc/sys/net/ipv4/ip_local_port_range
# 32768	60999

 ```
La salida anterior muestra que el servidor puede manejar un máximo de 28,231 (60,999 - 32,768) conexiones, ya que cada conexión requiere un puerto libre. Aunque recomendamos [escalado horizontal](#scaling) para aumentar el número de conexiones permitidas, puedes aumentar el número de puertos abiertos disponibles actualizando el rango de puertos permitidos en el archivo de configuración `/etc/sysctl.conf` de tu servidor.

<a name="process-management"></a>
### Gestión de Procesos

En la mayoría de los casos, debes usar un gestor de procesos como Supervisor para asegurarte de que el servidor Reverb esté en funcionamiento continuamente. Si estás utilizando Supervisor para ejecutar Reverb, debes actualizar el ajuste `minfds` del archivo `supervisor.conf` de tu servidor para asegurar que Supervisor pueda abrir los archivos necesarios para manejar las conexiones a tu servidor Reverb:


```ini
[supervisord]
...
minfds=10000

```

<a name="scaling"></a>
### Escalado

Si necesitas manejar más conexiones de las que permitirá un solo servidor, puedes escalar tu servidor Reverb horizontalmente. Utilizando las capacidades de publicación / suscripción de Redis, Reverb puede gestionar conexiones a través de múltiples servidores. Cuando un mensaje es recibido por uno de los servidores Reverb de tu aplicación, el servidor utilizará Redis para publicar el mensaje entrante a todos los demás servidores.
Para habilitar el escalado horizontal, debes establecer la variable de entorno `REVERB_SCALING_ENABLED` en `true` en el archivo de configuración `.env` de tu aplicación:


```env
REVERB_SCALING_ENABLED=true

```
A continuación, deberías tener un servidor Redis central dedicado al que se comunicarán todos los servidores de Reverb. Reverb utilizará la [conexión Redis predeterminada configurada para tu aplicación](/docs/%7B%7Bversion%7D%7D/redis#configuration) para publicar mensajes a todos tus servidores de Reverb.
Una vez que hayas habilitado la opción de escalado de Reverb y configurado un servidor Redis, simplemente puedes invocar el comando `reverb:start` en múltiples servidores que puedan comunicarse con tu servidor Redis. Estos servidores de Reverb deben estar detrás de un balanceador de carga que distribuya las solicitudes entrantes de manera uniforme entre los servidores.