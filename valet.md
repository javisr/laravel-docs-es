# Laravel Valet

- [Introducción](#introduction)
- [Instalación](#installation)
  - [Actualizando Valet](#upgrading-valet)
- [Sirvir Sitios](#serving-sites)
  - [El comando "Park"](#the-park-command)
  - [El comando "Link"](#the-link-command)
  - [Seguridad de sitios con TLS](#securing-sites)
  - [Servir un sitio por defecto](#serving-a-default-site)
  - [Versiones PHP por sitio](#per-site-php-versions)
- [Compartir sitios](#sharing-sites)
  - [Compartir sitios con Ngrok](#sharing-sites-via-ngrok)
  - [Compartir sitios a través de Expose](#sharing-sites-via-expose)
  - [Compartiir sitios en su Red Local](#sharing-sites-on-your-local-network)
- [Variables de entorno específicas del sitio](#site-specific-environment-variables)
- [Servicios de proxy](#proxying-services)
- [Controladores Valet personalizados](#custom-valet-drivers)
  - [Controladores locales](#local-drivers)
- [Otros comandos de Valet](#other-valet-commands)
- [Directorios y archivos de Valet](#valet-directories-and-files)
  - [Acceso a disco](#disk-access)

<a name="introduction"></a>
## Introducción

[Laravel Valet](https://github.com/laravel/valet) es un entorno de desarrollo para los minimalistas de macOS. Laravel Valet configura tu Mac para ejecutar siempre [Nginx](https://www.nginx.com/) en segundo plano cuando se inicia la máquina. A continuación, utilizando [DnsMasq](https://en.wikipedia.org/wiki/Dnsmasq), Valet se apodera de todas las peticiones en el dominio `*.test` para apuntarlos a los sitios instalados en su máquina local.

En otras palabras, Valet es un entorno de desarrollo de Laravel rapidísimo que utiliza aproximadamente 7 MB de RAM. Valet no es un reemplazo completo para [Sail](/docs/{{version}}/sail) o [Homestead](/docs/{{version}}/homestead), pero proporciona una gran alternativa si quieres bases flexibles, prefieres velocidad extrema, o estás trabajando en una máquina con una cantidad limitada de RAM.

Valet incluye, entre otras, las siguientes funciones:

<style>
    #valet-support > ul {
        column-count: 3; -moz-column-count: 3; -webkit-column-count: 3;
        line-height: 1.9;
    }
</style>

<div id="valet-support" markdown="1">

- [Laravel](https://laravel.com)
- [Bedrock](https://roots.io/bedrock/)
- [CakePHP 3](https://cakephp.org)
- [ConcreteCMS](https://www.concretecms.com/)
- [Contao](https://contao.org/en/)
- [Craft](https://craftcms.com)
- [Drupal](https://www.drupal.org/)
- [ExpressionEngine](https://www.expressionengine.com/)
- [Jigsaw](https://jigsaw.tighten.co)
- [Joomla](https://www.joomla.org/)
- [Katana](https://github.com/themsaid/katana)
- [Kirby](https://getkirby.com/)
- [Magento](https://magento.com/)
- [OctoberCMS](https://octobercms.com/)
- [Sculpin](https://sculpin.io/)
- [Slim](https://www.slimframework.com)
- [Statamic](https://statamic.com)
- Static HTML
- [Symfony](https://symfony.com)
- [WordPress](https://wordpress.org)
- [Zend](https://framework.zend.com)

</div>

No obstante, puedes ampliar Valet con tus [propios drivers personalizados](#custom-valet-drivers).

<a name="installation"></a>
## Instalación

> **Advertencia**  
> Valet requiere macOS y [Homebrew](https://brew.sh/). Antes de la instalación, debes asegurarte de que ningún otro programa como Apache o Nginx esté enlazado al puerto 80 de tu máquina local.

Para empezar, primero necesitas asegurarte de que Homebrew está actualizado usando el comando `update`:

```shell
brew update
```

A continuación, debe utilizar Homebrew para instalar PHP:

```shell
brew install php
```

Después de instalar PHP, estás listo para instalar el [gestor de paquetes Composer](https://getcomposer.org). Además, te debes asegurar de que el directorio `~/.composer/vendor/bin` está en el "PATH" de su sistema. Una vez instalado Composer, puedes instalar Laravel Valet como un paquete global de Composer:

```shell
composer global require laravel/valet
```

Por último, puede ejecutar el comando `install` de Valet. Esto configurará e instalará Valet y DnsMasq. Además, los demonios de los que depende Valet se configurarán para ejecutarse cuando se inicie el sistema:

```shell
valet install
```

Una vez instalado Valet, intenta hacer ping a cualquier dominio `*.test` en tu terminal usando un comando como `ping foobar.test`. Si Valet está instalado correctamente, debería ver que este dominio responde en `127.0.0.1`.

Valet iniciará automáticamente los servicios necesarios cada vez que arranque su máquina.

<a name="php-versions"></a>
#### Versiones PHP

Valet te permite cambiar la versión de PHP usando el comando `valet use php@version`. Valet instalará la versión de PHP especificada a través de Homebrew si no está ya instalada:

```shell
valet use php@7.2

valet use php
```

También puede crear un archivo `.valetphprc` en la raíz de su proyecto. El archivo `.valetphprc` debe contener la versión de PHP que el sitio debe utilizar:

```shell
php@7.2
```

Una vez creado este archivo, sólo tiene que ejecutar el comando `valet use` y el comando determinará la versión de PHP preferida del sitio leyendo el archivo.

> **Advertencia**  
> Valet sólo sirve una versión de PHP a la vez, incluso si tiene varias versiones de PHP instaladas.

<a name="database"></a>
#### Base de datos

Si tu aplicación necesita una base de datos, echa un vistazo a [DBngin](https://dbngin.com). DBngin proporciona una herramienta gratuita de gestión de bases de datos todo en uno que incluye MySQL, PostgreSQL y Redis. Una vez instalado DBngin, puedes conectarte a tu base de datos en `127.0.0.1` utilizando el nombre de usuario `root` y una cadena vacía para la contraseña.

<a name="resetting-your-installation"></a>
#### Restablecimiento de la instalación

Si tienes problemas para que la instalación de Valet funcione correctamente, ejecuta el comando `composer global update` seguido de `valet install` para restablecer la instalación y solucionar diversos problemas. En casos excepcionales, puede ser necesario "reiniciar" Valet ejecutando `valet uninstall --force` seguido de `valet install`.

<a name="upgrading-valet"></a>
### Actualización de Valet

Puede actualizar su instalación de Valet ejecutando el comando `composer global update` en su terminal. Después de actualizar, es una buena práctica ejecutar el comando `valet install` para que Valet pueda hacer actualizaciones adicionales a tus archivos de configuración si es necesario.

<a name="serving-sites"></a>
## Servir sitios

Una vez que Valet está instalado, estás listo para empezar a servir tus aplicaciones Laravel. Valet proporciona dos comandos para ayudarte a servir tus aplicaciones: `park` y `link`.

<a name="the-park-command"></a>
### El comando `park`

El comando `park` registra un directorio en tu máquina que contiene tus aplicaciones. Una vez que el directorio ha sido "aparcado" con Valet, todos los directorios dentro de ese directorio serán accesibles en su navegador web en `http://<directory-name>.test`:

```shell
cd ~/Sites

valet park
```

Eso es todo. Ahora, cualquier aplicación que crees dentro de tu directorio "aparcado" se servirá automáticamente utilizando la convención `http://<nombre-directorio>.test`. Así, si tu directorio aparcado contiene un directorio llamado "laravel", la aplicación dentro de ese directorio será accesible en `http://laravel.test`. Además, Valet permite acceder automáticamente al sitio mediante subdominios comodín`(http://foo.laravel.test`).

<a name="the-link-command"></a>
### El comando `link`

El comando `link` también se puede utilizar para servir tus aplicaciones Laravel. Este comando es útil si quieres servir un único sitio en un directorio y no todo el directorio:

```shell
cd ~/Sites/laravel

valet link
```

Una vez que una aplicación ha sido enlazada a Valet usando el comando `link`, puedes acceder a la aplicación usando su nombre de directorio. Así, se puede acceder al sitio vinculado en el ejemplo anterior en `http://laravel.test`. Además, Valet permite acceder automáticamente al sitio utilizando subdominios comodín`(http://foo.laravel.test`).

Si desea servir la aplicación en un nombre de host diferente, puede pasar el nombre de host al comando `link`. Por ejemplo, puede ejecutar el siguiente comando para que una aplicación esté disponible en `http://application.test`:

```shell
cd ~/Sites/laravel

valet link application
```

Por supuesto, también puede servir aplicaciones en subdominios utilizando el comando `link`:

```shell
valet link api.application
```

Puede ejecutar el comando `links` para mostrar una lista de todos sus directorios enlazados:

```shell
valet links
```

El comando `unlink` puede utilizarse para destruir el enlace simbólico de un sitio:

```shell
cd ~/Sites/laravel

valet unlink
```

<a name="securing-sites"></a>
### Seguridad de sitios con TLS

Por defecto, Valet sirve sitios a través de HTTP. Sin embargo, si desea servir un sitio a través de TLS cifrado utilizando HTTP/2, puede utilizar el comando `secure`. Por ejemplo, si Valet sirve tu sitio en el dominio `laravel.test`, ejecuta el siguiente comando para protegerlo:

```shell
valet secure laravel
```

Para "desproteger" un sitio y volver a servir su tráfico a través de HTTP plano, utilice el comando `unsecure`. Al igual que el comando `secure`, este comando acepta el nombre de host que desea desproteger:

```shell
valet unsecure laravel
```

<a name="serving-a-default-site"></a>
### Servir un sitio por defecto

A veces, puede que desee configurar Valet para que sirva un sitio "predeterminado" en lugar de un `404` cuando visite un dominio `test` desconocido. Para ello, puede añadir una opción `default` a su archivo de configuración `~/.config/valet/config.json` que contenga la ruta al sitio que debe servir como sitio predeterminado:

    "default": "/Users/Sally/Sites/example-site",

<a name="per-site-php-versions"></a>
### Versiones PHP por sitio

Por defecto, Valet utiliza tu instalación global de PHP para servir tus sitios. Sin embargo, si necesita admitir varias versiones de PHP en varios sitios, puede utilizar el comando `isolate` para especificar qué versión de PHP debe utilizar un sitio concreto. El comando `isolate` configura Valet para que utilice la versión de PHP especificada para el sitio ubicado en el directorio de trabajo actual:

```shell
cd ~/Sites/example-site

valet isolate php@8.0
```

Si el nombre de su sitio no coincide con el nombre del directorio que lo contiene, puede especificar el nombre del sitio utilizando la opción `--site`:

```shell
valet isolate php@8.0 --site="site-name"
```

Por conveniencia, puede usar los comandos `valet php`, `valet composer`, y `valet which-php` para hacer llamadas a la CLI o herramienta PHP apropiada basada en la versión PHP configurada del sitio:

```shell
valet php
valet composer
valet which-php
```

Puede ejecutar el comando `isolated` para mostrar una lista de todos sus sitios aislados y sus versiones de PHP:

```shell
valet isolated
```

Para revertir un sitio a la versión de PHP instalada globalmente en Valet, puedes invocar el comando `unisolate` desde el directorio raíz del sitio:

```shell
valet unisolate
```

<a name="sharing-sites"></a>
## Compartir sitios

Valet incluye incluso un comando para compartir tus sitios locales con el mundo, proporcionando una manera fácil de testear tu sitio en dispositivos móviles o compartirlo con miembros del equipo y clientes.

<a name="sharing-sites-via-ngrok"></a>
### Compartir Sitios con Ngrok

Para compartir un sitio, navega hasta el directorio del sitio en tu terminal y ejecuta el comando `share` de Valet. Una URL de acceso público se insertará en tu portapapeles y estará lista para pegarla directamente en tu navegador o compartirla con tu equipo:

```shell
cd ~/Sites/laravel

valet share
```

Para dejar de compartir tu sitio, puedes pulsar `Control + C`. Compartir tu sitio usando Ngrok requiere que [crees una cuenta Ngrok](https://dashboard.ngrok.com/signup) y [configures un token de autenticación](https://dashboard.ngrok.com/get-started/your-authtoken).

> **Nota**  
> Puede pasar parámetros Ngrok adicionales al comando share, como `valet share --region=eu`. Para obtener más información, consulte la [documentación de ngrok](https://ngrok.com/docs).

<a name="sharing-sites-via-expose"></a>
### Compartir sitios a través de Expose

Si tiene instalado [Expose](https://expose.dev), puede compartir su sitio navegando hasta el directorio del sitio en su terminal y ejecutando el comando `expose`. Consulte la documentación de [Expose](https://expose.dev/docs) para obtener información sobre los parámetros adicionales de línea de comandos que admite. Después de compartir el sitio, Expose mostrará la URL compartible que podrá utilizar en sus otros dispositivos o entre los miembros de su equipo:

```shell
cd ~/Sites/laravel

expose
```

Para dejar de compartir su sitio, puede pulsar `Control + C`.

<a name="sharing-sites-on-your-local-network"></a>
### Compartir sitios en su red local

Valet restringe por defecto el tráfico entrante a la interfaz interna `127.0.0.1` para que tu máquina de desarrollo no esté expuesta a riesgos de seguridad procedentes de Internet.

Si deseas permitir que otros dispositivos de tu red local accedan a los sitios Valet de tu máquina a través de la dirección IP de tu máquina (p. ej.: `192.168.1.10/aplicación.test`), deberás editar manualmente el archivo de configuración Nginx correspondiente a ese sitio para eliminar la restricción de la directiva `listen`. Deberá eliminar el prefijo `127.0.0.1:` en la directiva `listen` para los puertos 80 y 443.

Si no ha ejecutado `valet secure` en el proyecto, puede abrir el acceso a la red para todos los sitios no HTTPS editando el archivo `/usr/local/etc/nginx/valet/valet.conf`. Sin embargo, si estás sirviendo el sitio del proyecto sobre HTTPS (has ejecutado `valet secure` para el sitio) entonces debes editar el archivo `~/.config/valet/Nginx/app-name.test`.

Una vez que hayas actualizado la configuración de Nginx, ejecuta el comando `valet restart` para aplicar los cambios de configuración.

<a name="site-specific-environment-variables"></a>
## Variables de entorno específicas del sitio

Algunas aplicaciones que utilizan otros frameworks pueden depender de variables de entorno del servidor pero no proporcionan una forma de configurar esas variables dentro de tu proyecto. Valet permite configurar variables de entorno específicas del sitio añadiendo un archivo `.valet-env.php` en la raíz del proyecto. Este archivo debe devolver un array de pares sitio / variable de entorno que se añadirán al array global `$_SERVER` para cada sitio especificado en el array:

    <?php

    return [
        // Set $_SERVER['key'] to "value" for the laravel.test site...
        'laravel' => [
            'key' => 'value',
        ],

        // Set $_SERVER['key'] to "value" for all sites...
        '*' => [
            'key' => 'value',
        ],
    ];

<a name="proxying-services"></a>
## Servicios de proxy

A veces puede que desee enviar un dominio Valet a otro servicio en su máquina local. Por ejemplo, puede que ocasionalmente necesites ejecutar Valet mientras también ejecutas un sitio separado en Docker; sin embargo, Valet y Docker no pueden enlazarse al puerto 80 al mismo tiempo.

Para resolver esto, puede utilizar el comando `proxy` para generar un proxy. Por ejemplo, puede enviar todo el tráfico de `http://elasticsearch.test` a `http://127.0.0.1:9200`:

```shell
# Proxy over HTTP...
valet proxy elasticsearch http://127.0.0.1:9200

# Proxy over TLS + HTTP/2...
valet proxy elasticsearch http://127.0.0.1:9200 --secure
```

Puede eliminar un proxy utilizando el comando `unproxy`:

```shell
valet unproxy elasticsearch
```

Puede usar el comando `proxies` para listar todas las configuraciones de sitios a los que se les esta aplicando un proxy:

```shell
valet proxies
```

<a name="custom-valet-drivers"></a>
## Controladores Valet personalizados

Puedes escribir tu propio "controlador" Valet para servir aplicaciones PHP que se ejecuten en un framework o CMS que no esté soportado de forma nativa por Valet. Al instalar Valet, se crea un directorio `~/.config/valet/Drivers` que contiene un archivo `SampleValetDriver.php`. Este archivo contiene una implementación de controlador de ejemplo para demostrar cómo escribir un controlador personalizado. Escribir un controlador sólo requiere implementar tres métodos: `serves`, `isStaticFile` y `frontControllerPath`.

Los tres métodos reciben los valores `$sitePath`, `$siteName` y `$uri` como argumentos. `$sitePath` es la ruta completa al sitio que se está sirviendo en su máquina, como `/Users/Lisa/Sites/my-project`. `$siteName` es la parte "host" / "nombre del sitio" del dominio(`my-project`). `$uri` es el URI de la petición entrante (`/foo/bar`).

Una vez que haya completado su controlador Valet personalizado, colóquelo en el directorio `~/.config/valet/Drivers` utilizando la convención de nomenclatura `FrameworkValetDriver.php`. Por ejemplo, si está escribiendo un controlador Valet personalizado para WordPress, el nombre del archivo debe ser `WordPressValetDriver.php`.

Veamos un ejemplo de implementación de cada uno de los métodos que debe implementar su controlador de valet personalizado.

<a name="the-serves-method"></a>
#### El método `serves`

El método `serves` debe devolver `true` si su controlador debe gestionar la petición entrante. De lo contrario, el método debe devolver `false`. Por lo tanto, dentro de este método, debe intentar determinar si el `$sitePath` dado contiene un proyecto del tipo que está intentando servir.

Por ejemplo, imaginemos que estamos escribiendo un `WordPressValetDriver`. Nuestro método `serves` podría ser algo parecido a esto:

    /**
     * Determine if the driver serves the request.
     *
     * @param  string  $sitePath
     * @param  string  $siteName
     * @param  string  $uri
     * @return bool
     */
    public function serves($sitePath, $siteName, $uri)
    {
        return is_dir($sitePath.'/wp-admin');
    }

<a name="the-isstaticfile-method"></a>
#### El método `isStaticFile`

`isStaticFile` debe determinar si la petición entrante es para un archivo "estático", como una imagen o una hoja de estilo. Si el archivo es estático, el método debe devolver la ruta completa del archivo estático en el disco. Si la petición entrante no es para un archivo estático, el método debe devolver `false`:

    /**
     * Determine if the incoming request is for a static file.
     *
     * @param  string  $sitePath
     * @param  string  $siteName
     * @param  string  $uri
     * @return string|false
     */
    public function isStaticFile($sitePath, $siteName, $uri)
    {
        if (file_exists($staticFilePath = $sitePath.'/public/'.$uri)) {
            return $staticFilePath;
        }

        return false;
    }

> **Advertencia**  
> El método `isStaticFile` sólo será llamado si el método `serves` devuelve `true` para la petición entrante y el URI de la petición no es `/`.

<a name="the-frontcontrollerpath-method"></a>
#### El método `frontControllerPath`

El método `frontControllerPath` debe devolver la ruta completa al "controlador frontal" de su aplicación, que normalmente es un archivo "index.php" o equivalente:

    /**
     * Get the fully resolved path to the application's front controller.
     *
     * @param  string  $sitePath
     * @param  string  $siteName
     * @param  string  $uri
     * @return string
     */
    public function frontControllerPath($sitePath, $siteName, $uri)
    {
        return $sitePath.'/public/index.php';
    }

<a name="local-drivers"></a>
### Controladores locales

Si desea definir un controlador Valet personalizado para una única aplicación, cree un archivo `LocalValetDriver.php` en el directorio raíz de la aplicación. El controlador personalizado puede extender la clase `ValetDriver` base o extender un controlador específico de la aplicación existente, como `LaravelValetDriver`:

    use Valet\Drivers\LaravelValetDriver;

    class LocalValetDriver extends LaravelValetDriver
    {
        /**
         * Determine if the driver serves the request.
         *
         * @param  string  $sitePath
         * @param  string  $siteName
         * @param  string  $uri
         * @return bool
         */
        public function serves($sitePath, $siteName, $uri)
        {
            return true;
        }

        /**
         * Get the fully resolved path to the application's front controller.
         *
         * @param  string  $sitePath
         * @param  string  $siteName
         * @param  string  $uri
         * @return string
         */
        public function frontControllerPath($sitePath, $siteName, $uri)
        {
            return $sitePath.'/public_html/index.php';
        }
    }

<a name="other-valet-commands"></a>
## Otros comandos de Valet

Command  | Description
------------- | -------------
`valet list` | Mostrar una lista de todos los comandos de Valet.
`valet forget` | Ejecute este comando desde un directorio "aparcado" para eliminarlo de la lista de directorios aparcados. .
`valet log` | Ver una lista de los registros escritos por los servicios de Valet.
`valet paths` | Vea todas sus rutas "aparcadas".
`valet restart` | Reiniciar los demonios de Valet. 
`valet start` | Iniciar los demonios de Valet.
`valet stop` | Detener los demonios de Valet.
`valet trust` | Agregar archivos sudoers para Brew y Valet para permitir que los comandos de Valet se ejecuten sin solicitar su contraseña.
`valet uninstall` | Desinstalar Valet: muestra instrucciones para la desinstalación manual. Pasa la `--force` para eliminar de forma agresiva todos los recursos de Valet.

<a name="valet-directories-and-files"></a>
## Directorios y archivos de Valet

La siguiente información sobre directorios y archivos puede resultarle útil para solucionar problemas con su entorno Valet:

#### `~/.config/valet`

Contiene toda la configuración de Valet. Puede que desee mantener una copia de seguridad de este directorio.

#### `~/.config/valet/dnsmasq.d/`

Este directorio contiene la configuración de DNSMasq.

#### `~/.config/valet/Drivers/`

Este directorio contiene los controladores de Valet. Los controladores determinan cómo se sirve un framework / CMS concreto.

#### `~/.config/valet/Extensions/`

Este directorio contiene extensiones / comandos personalizados de Valet.

#### `~/.config/valet/Nginx/`

Este directorio contiene todas las configuraciones del sitio Nginx de Valet. Estos archivos se reconstruyen al ejecutar los comandos `install` y `secure`.

#### `~/.config/valet/Sitios/`

Este directorio contiene todos los enlaces simbólicos de tus [proyectos vinculados](#the-link-command).

#### `~/.config/valet/config.json`

Este archivo es el archivo de configuración principal de Valet.

#### `~/.config/valet/valet.sock`

Este archivo es el socket PHP-FPM utilizado por la instalación Nginx de Valet. Sólo existirá si PHP se ejecuta correctamente.

#### `~/.config/valet/Log/fpm-php.www.log`

Este archivo es el registro de errores de PHP.

#### `~/.config/valet/Log/nginx-error.log`

Este archivo es el registro de usuario para errores de Nginx.

#### `/usr/local/var/log/php-fpm.log`

Este archivo es el registro del sistema para errores PHP-FPM.

#### `/usr/local/var/log/nginx`

Este directorio contiene los registros de acceso y errores de Nginx.

#### `/usr/local/etc/php/X.X/conf.d`

Este directorio contiene los archivos `*.ini` para varios ajustes de configuración de PHP.

#### `/usr/local/etc/php/X.X/php-fpm.d/valet-fpm.conf`

Este archivo es el archivo de configuración del pool PHP-FPM.

#### `~/.composer/vendor/laravel/valet/cli/stubs/secure.valet.conf`

Este archivo es la configuración predeterminada de Nginx utilizada para crear certificados SSL para sus sitios.

<a name="disk-access"></a>
### Acceso a disco

Desde macOS 10.14, el [acceso a algunos archivos y directorios está restringido por defecto](https://manuals.info.apple.com/MANUALS/1000/MA1902/en_US/apple-platform-security-guide.pdf). Estas restricciones incluyen los directorios Escritorio, Documentos y Descargas. Además, el acceso a volúmenes de red y a volúmenes extraíbles está restringido. Por lo tanto, Valet recomienda que las carpetas de su sitio se ubiquen fuera de estas ubicaciones protegidas.

Sin embargo, si desea servir sitios desde una de esas ubicaciones, deberá dar a Nginx "Acceso total al disco". De lo contrario, es posible que se produzcan errores de servidor u otros comportamientos impredecibles de Nginx, especialmente al servir activos estáticos. Normalmente, macOS te pedirá automáticamente que concedas a Nginx acceso completo a estas ubicaciones. También puedes hacerlo manualmente a través de `Preferencias del Sistema` > `Seguridad y privacidad` > `Privacidad` y seleccionando `Acceso total al disco`. A continuación, habilita cualquier entrada de `nginx` en el panel de la ventana principal.
