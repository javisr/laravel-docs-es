# Despliegue

- [Introducción](#introduction)
- [Requisitos del Servidor](#server-requirements)
- [Configuración del Servidor](#server-configuration)
    - [Nginx](#nginx)
    - [FrankenPHP](#frankenphp)
    - [Permisos de Directorio](#directory-permissions)
- [Optimización](#optimization)
    - [Configuración de Caché](#optimizing-configuration-loading)
    - [Eventos de Caché](#caching-events)
    - [Rutas de Caché](#optimizing-route-loading)
    - [Vistas de Caché](#optimizing-view-loading)
- [Modo de Depuración](#debug-mode)
- [La Ruta de Salud](#the-health-route)
- [Despliegue Fácil con Forge / Vapor](#deploying-with-forge-or-vapor)

<a name="introduction"></a>
## Introducción

Cuando estés listo para desplegar tu aplicación Laravel en producción, hay algunas cosas importantes que puedes hacer para asegurarte de que tu aplicación esté funcionando de la manera más eficiente posible. En este documento, cubriremos algunos excelentes puntos de partida para asegurarte de que tu aplicación Laravel esté desplegada correctamente.

<a name="server-requirements"></a>
## Requisitos del Servidor

El framework Laravel tiene algunos requisitos del sistema. Debes asegurarte de que tu servidor web tenga la siguiente versión mínima de PHP y extensiones:

<div class="content-list" markdown="1">

- PHP >= 8.2
- Extensión PHP Ctype
- Extensión PHP cURL
- Extensión PHP DOM
- Extensión PHP Fileinfo
- Extensión PHP Filter
- Extensión PHP Hash
- Extensión PHP Mbstring
- Extensión PHP OpenSSL
- Extensión PHP PCRE
- Extensión PHP PDO
- Extensión PHP Session
- Extensión PHP Tokenizer
- Extensión PHP XML

</div>

<a name="server-configuration"></a>
## Configuración del Servidor

<a name="nginx"></a>
### Nginx

Si estás desplegando tu aplicación en un servidor que está ejecutando Nginx, puedes usar el siguiente archivo de configuración como punto de partida para configurar tu servidor web. Lo más probable es que este archivo necesite ser personalizado dependiendo de la configuración de tu servidor. **Si deseas asistencia en la gestión de tu servidor, considera usar un servicio de gestión y despliegue de servidores de Laravel de primera parte como [Laravel Forge](https://forge.laravel.com).**

Por favor, asegúrate, como en la configuración a continuación, de que tu servidor web dirija todas las solicitudes al archivo `public/index.php` de tu aplicación. Nunca debes intentar mover el archivo `index.php` a la raíz de tu proyecto, ya que servir la aplicación desde la raíz del proyecto expondrá muchos archivos de configuración sensibles a Internet público:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name example.com;
    root /srv/example.com/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

<a name="frankenphp"></a>
### FrankenPHP

[FrankenPHP](https://frankenphp.dev/) también puede ser utilizado para servir tus aplicaciones Laravel. FrankenPHP es un servidor de aplicaciones PHP moderno escrito en Go. Para servir una aplicación PHP Laravel usando FrankenPHP, simplemente puedes invocar su comando `php-server`:

```shell
frankenphp php-server -r public/
```

Para aprovechar características más poderosas soportadas por FrankenPHP, como su integración con [Laravel Octane](/docs/{{version}}/octane), HTTP/3, compresión moderna, o la capacidad de empaquetar aplicaciones Laravel como binarios independientes, consulta la [documentación de Laravel de FrankenPHP](https://frankenphp.dev/docs/laravel/).

<a name="directory-permissions"></a>
### Permisos de Directorio

Laravel necesitará escribir en los directorios `bootstrap/cache` y `storage`, por lo que debes asegurarte de que el propietario del proceso del servidor web tenga permiso para escribir en estos directorios.

<a name="optimization"></a>
## Optimización

Al desplegar tu aplicación en producción, hay una variedad de archivos que deben ser almacenados en caché, incluyendo tu configuración, eventos, rutas y vistas. Laravel proporciona un único y conveniente comando Artisan `optimize` que almacenará en caché todos estos archivos. Este comando debe ser invocado típicamente como parte del proceso de despliegue de tu aplicación:

```shell
php artisan optimize
```

El método `optimize:clear` puede ser utilizado para eliminar todos los archivos de caché generados por el comando `optimize`:

```shell
php artisan optimize:clear
```

En la siguiente documentación, discutiremos cada uno de los comandos de optimización granular que son ejecutados por el comando `optimize`.

<a name="optimizing-configuration-loading"></a>
### Configuración de Caché

Al desplegar tu aplicación en producción, debes asegurarte de ejecutar el comando Artisan `config:cache` durante tu proceso de despliegue:

```shell
php artisan config:cache
```

Este comando combinará todos los archivos de configuración de Laravel en un único archivo en caché, lo que reduce en gran medida el número de viajes que el framework debe hacer al sistema de archivos al cargar tus valores de configuración.

> [!WARNING]  
> Si ejecutas el comando `config:cache` durante tu proceso de despliegue, debes asegurarte de que solo estás llamando a la función `env` desde dentro de tus archivos de configuración. Una vez que la configuración ha sido almacenada en caché, el archivo `.env` no será cargado y todas las llamadas a la función `env` para variables de `.env` devolverán `null`.

<a name="caching-events"></a>
### Eventos de Caché

Debes almacenar en caché las asignaciones de eventos a oyentes auto-descubiertas de tu aplicación durante tu proceso de despliegue. Esto se puede lograr invocando el comando Artisan `event:cache` durante el despliegue:

```shell
php artisan event:cache
```

<a name="optimizing-route-loading"></a>
### Rutas de Caché

Si estás construyendo una gran aplicación con muchas rutas, debes asegurarte de que estás ejecutando el comando Artisan `route:cache` durante tu proceso de despliegue:

```shell
php artisan route:cache
```

Este comando reduce todas tus registraciones de rutas en una única llamada de método dentro de un archivo en caché, mejorando el rendimiento de la registración de rutas al registrar cientos de rutas.

<a name="optimizing-view-loading"></a>
### Vistas de Caché

Al desplegar tu aplicación en producción, debes asegurarte de ejecutar el comando Artisan `view:cache` durante tu proceso de despliegue:

```shell
php artisan view:cache
```

Este comando precompila todas tus vistas Blade para que no sean compiladas bajo demanda, mejorando el rendimiento de cada solicitud que devuelve una vista.

<a name="debug-mode"></a>
## Modo de Depuración

La opción de depuración en tu archivo de configuración `config/app.php` determina cuánta información sobre un error se muestra realmente al usuario. Por defecto, esta opción está configurada para respetar el valor de la variable de entorno `APP_DEBUG`, que se almacena en el archivo `.env` de tu aplicación.

> [!WARNING]  
> **En tu entorno de producción, este valor siempre debe ser `false`. Si la variable `APP_DEBUG` está configurada como `true` en producción, corres el riesgo de exponer valores de configuración sensibles a los usuarios finales de tu aplicación.**

<a name="the-health-route"></a>
## La Ruta de Salud

Laravel incluye una ruta de verificación de salud incorporada que puede ser utilizada para monitorear el estado de tu aplicación. En producción, esta ruta puede ser utilizada para informar el estado de tu aplicación a un monitor de tiempo de actividad, balanceador de carga, o sistema de orquestación como Kubernetes.

Por defecto, la ruta de verificación de salud se sirve en `/up` y devolverá una respuesta HTTP 200 si la aplicación se ha iniciado sin excepciones. De lo contrario, se devolverá una respuesta HTTP 500. Puedes configurar la URI para esta ruta en el archivo `bootstrap/app` de tu aplicación:

    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up', // [tl! remove]
        health: '/status', // [tl! add]
    )

Cuando se realizan solicitudes HTTP a esta ruta, Laravel también despachará un evento `Illuminate\Foundation\Events\DiagnosingHealth`, lo que te permitirá realizar verificaciones de salud adicionales relevantes para tu aplicación. Dentro de un [listener](/docs/{{version}}/events) para este evento, puedes verificar el estado de la base de datos o caché de tu aplicación. Si detectas un problema con tu aplicación, simplemente puedes lanzar una excepción desde el listener.

<a name="deploying-with-forge-or-vapor"></a>
## Despliegue Fácil con Forge / Vapor

<a name="laravel-forge"></a>
#### Laravel Forge

Si no estás del todo listo para gestionar la configuración de tu propio servidor o no te sientes cómodo configurando todos los diversos servicios necesarios para ejecutar una robusta aplicación Laravel, [Laravel Forge](https://forge.laravel.com) es una maravillosa alternativa.

Laravel Forge puede crear servidores en varios proveedores de infraestructura como DigitalOcean, Linode, AWS, y más. Además, Forge instala y gestiona todas las herramientas necesarias para construir aplicaciones Laravel robustas, como Nginx, MySQL, Redis, Memcached, Beanstalk, y más.

> [!NOTE]  
> ¿Quieres una guía completa para desplegar con Laravel Forge? Consulta el [Laravel Bootcamp](https://bootcamp.laravel.com/deploying) y la serie de [videos disponibles en Laracasts](https://laracasts.com/series/learn-laravel-forge-2022-edition).

<a name="laravel-vapor"></a>
#### Laravel Vapor

Si deseas una plataforma de despliegue totalmente sin servidor y autoescalable ajustada para Laravel, consulta [Laravel Vapor](https://vapor.laravel.com). Laravel Vapor es una plataforma de despliegue sin servidor para Laravel, impulsada por AWS. Lanza tu infraestructura Laravel en Vapor y enamórate de la simplicidad escalable de lo sin servidor. Laravel Vapor está afinado por los creadores de Laravel para funcionar sin problemas con el framework, para que puedas seguir escribiendo tus aplicaciones Laravel exactamente como estás acostumbrado.
