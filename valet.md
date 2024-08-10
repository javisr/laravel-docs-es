# Laravel Valet

- [Introducción](#introduction)
- [Instalación](#installation)
    - [Actualizando Valet](#upgrading-valet)
- [Sirviendo Sitios](#serving-sites)
    - [El Comando "Park"]( #the-park-command)
    - [El Comando "Link"]( #the-link-command)
    - [Asegurando Sitios Con TLS](#securing-sites)
    - [Sirviendo un Sitio Predeterminado](#serving-a-default-site)
    - [Versiones de PHP por Sitio](#per-site-php-versions)
- [Compartiendo Sitios](#sharing-sites)
    - [Compartiendo Sitios en Tu Red Local](#sharing-sites-on-your-local-network)
- [Variables de Entorno Específicas del Sitio](#site-specific-environment-variables)
- [Servicios de Proxy](#proxying-services)
- [Controladores Personalizados de Valet](#custom-valet-drivers)
    - [Controladores Locales](#local-drivers)
- [Otros Comandos de Valet](#other-valet-commands)
- [Directorios y Archivos de Valet](#valet-directories-and-files)
    - [Acceso al Disco](#disk-access)

<a name="introduction"></a>
## Introducción

> [!NOTE]  
> ¿Buscas una manera aún más fácil de desarrollar aplicaciones Laravel en macOS o Windows? Consulta [Laravel Herd](https://herd.laravel.com). Herd incluye todo lo que necesitas para comenzar con el desarrollo de Laravel, incluyendo Valet, PHP y Composer.

[Laravel Valet](https://github.com/laravel/valet) es un entorno de desarrollo para minimalistas de macOS. Laravel Valet configura tu Mac para ejecutar siempre [Nginx](https://www.nginx.com/) en segundo plano cuando tu máquina arranca. Luego, usando [DnsMasq](https://en.wikipedia.org/wiki/Dnsmasq), Valet proxy todas las solicitudes en el dominio `*.test` para apuntar a los sitios instalados en tu máquina local.

En otras palabras, Valet es un entorno de desarrollo Laravel extremadamente rápido que utiliza aproximadamente 7 MB de RAM. Valet no es un reemplazo completo para [Sail](/docs/{{version}}/sail) o [Homestead](/docs/{{version}}/homestead), pero proporciona una gran alternativa si deseas fundamentos flexibles, prefieres una velocidad extrema, o estás trabajando en una máquina con una cantidad limitada de RAM.

Fuera de la caja, el soporte de Valet incluye, pero no se limita a:

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
- HTML estático
- [Symfony](https://symfony.com)
- [WordPress](https://wordpress.org)
- [Zend](https://framework.zend.com)

</div>

Sin embargo, puedes extender Valet con tus propios [controladores personalizados](#custom-valet-drivers).

<a name="installation"></a>
## Instalación

> [!WARNING]  
> Valet requiere macOS y [Homebrew](https://brew.sh/). Antes de la instalación, debes asegurarte de que no haya otros programas como Apache o Nginx vinculados al puerto 80 de tu máquina local.

Para comenzar, primero necesitas asegurarte de que Homebrew esté actualizado usando el comando `update`:

```shell
brew update
```

A continuación, debes usar Homebrew para instalar PHP:

```shell
brew install php
```

Después de instalar PHP, estás listo para instalar el [gestor de paquetes Composer](https://getcomposer.org). Además, debes asegurarte de que el directorio `$HOME/.composer/vendor/bin` esté en el "PATH" de tu sistema. Después de que Composer haya sido instalado, puedes instalar Laravel Valet como un paquete global de Composer:

```shell
composer global require laravel/valet
```

Finalmente, puedes ejecutar el comando `install` de Valet. Esto configurará e instalará Valet y DnsMasq. Además, los demonios de los que depende Valet se configurarán para iniciarse cuando tu sistema arranque:

```shell
valet install
```

Una vez que Valet esté instalado, intenta hacer ping a cualquier dominio `*.test` en tu terminal usando un comando como `ping foobar.test`. Si Valet está instalado correctamente, deberías ver este dominio respondiendo en `127.0.0.1`.

Valet iniciará automáticamente sus servicios requeridos cada vez que tu máquina arranque.

<a name="php-versions"></a>
#### Versiones de PHP

> [!NOTE]  
> En lugar de modificar tu versión global de PHP, puedes instruir a Valet para que use versiones de PHP por sitio a través del comando `isolate` [command](#per-site-php-versions).

Valet te permite cambiar las versiones de PHP usando el comando `valet use php@version`. Valet instalará la versión de PHP especificada a través de Homebrew si no está ya instalada:

```shell
valet use php@8.2

valet use php
```

También puedes crear un archivo `.valetrc` en la raíz de tu proyecto. El archivo `.valetrc` debe contener la versión de PHP que el sitio debe usar:

```shell
php=php@8.2
```

Una vez que este archivo ha sido creado, puedes simplemente ejecutar el comando `valet use` y el comando determinará la versión de PHP preferida del sitio leyendo el archivo.

> [!WARNING]  
> Valet solo sirve una versión de PHP a la vez, incluso si tienes múltiples versiones de PHP instaladas.

<a name="database"></a>
#### Base de Datos

Si tu aplicación necesita una base de datos, consulta [DBngin](https://dbngin.com), que proporciona una herramienta de gestión de bases de datos todo en uno gratuita que incluye MySQL, PostgreSQL y Redis. Después de que DBngin haya sido instalado, puedes conectarte a tu base de datos en `127.0.0.1` usando el nombre de usuario `root` y una cadena vacía para la contraseña.

<a name="resetting-your-installation"></a>
#### Reiniciando Tu Instalación

Si tienes problemas para hacer que tu instalación de Valet funcione correctamente, ejecutar el comando `composer global require laravel/valet` seguido de `valet install` restablecerá tu instalación y puede resolver una variedad de problemas. En raras ocasiones, puede ser necesario "reiniciar forzosamente" Valet ejecutando `valet uninstall --force` seguido de `valet install`.

<a name="upgrading-valet"></a>
### Actualizando Valet

Puedes actualizar tu instalación de Valet ejecutando el comando `composer global require laravel/valet` en tu terminal. Después de actualizar, es una buena práctica ejecutar el comando `valet install` para que Valet pueda realizar actualizaciones adicionales a tus archivos de configuración si es necesario.

<a name="upgrading-to-valet-4"></a>
#### Actualizando a Valet 4

Si estás actualizando de Valet 3 a Valet 4, sigue los siguientes pasos para actualizar correctamente tu instalación de Valet:

<div class="content-list" markdown="1">

- Si has agregado archivos `.valetphprc` para personalizar la versión de PHP de tu sitio, renombra cada archivo `.valetphprc` a `.valetrc`. Luego, antepone `php=` al contenido existente del archivo `.valetrc`.
- Actualiza cualquier controlador personalizado para que coincida con el espacio de nombres, extensión, tipos de hint y tipos de retorno del nuevo sistema de controladores. Puedes consultar el [SampleValetDriver](https://github.com/laravel/valet/blob/d7787c025e60abc24a5195dc7d4c5c6f2d984339/cli/stubs/SampleValetDriver.php) de Valet como ejemplo.
- Si usas PHP 7.1 - 7.4 para servir tus sitios, asegúrate de seguir usando Homebrew para instalar una versión de PHP que sea 8.0 o superior, ya que Valet usará esta versión, incluso si no es tu versión vinculada principal, para ejecutar algunos de sus scripts.

</div>

<a name="serving-sites"></a>
## Sirviendo Sitios

Una vez que Valet esté instalado, estás listo para comenzar a servir tus aplicaciones Laravel. Valet proporciona dos comandos para ayudarte a servir tus aplicaciones: `park` y `link`.

<a name="the-park-command"></a>
### El Comando `park`

El comando `park` registra un directorio en tu máquina que contiene tus aplicaciones. Una vez que el directorio ha sido "estacionado" con Valet, todos los directorios dentro de ese directorio serán accesibles en tu navegador web en `http://<nombre-del-directorio>.test`:

```shell
cd ~/Sites

valet park
```

Eso es todo. Ahora, cualquier aplicación que crees dentro de tu directorio "estacionado" será servida automáticamente usando la convención `http://<nombre-del-directorio>.test`. Así que, si tu directorio estacionado contiene un directorio llamado "laravel", la aplicación dentro de ese directorio será accesible en `http://laravel.test`. Además, Valet te permite automáticamente acceder al sitio usando subdominios comodín (`http://foo.laravel.test`).

<a name="the-link-command"></a>
### El Comando `link`

El comando `link` también se puede usar para servir tus aplicaciones Laravel. Este comando es útil si deseas servir un solo sitio en un directorio y no todo el directorio:

```shell
cd ~/Sites/laravel

valet link
```

Una vez que una aplicación ha sido vinculada a Valet usando el comando `link`, puedes acceder a la aplicación usando su nombre de directorio. Así que, el sitio que fue vinculado en el ejemplo anterior puede ser accedido en `http://laravel.test`. Además, Valet te permite automáticamente acceder al sitio usando subdominios comodín (`http://foo.laravel.test`).

Si deseas servir la aplicación en un nombre de host diferente, puedes pasar el nombre de host al comando `link`. Por ejemplo, puedes ejecutar el siguiente comando para hacer que una aplicación esté disponible en `http://application.test`:

```shell
cd ~/Sites/laravel

valet link application
```

Por supuesto, también puedes servir aplicaciones en subdominios usando el comando `link`:

```shell
valet link api.application
```

Puedes ejecutar el comando `links` para mostrar una lista de todos tus directorios vinculados:

```shell
valet links
```

El comando `unlink` se puede usar para destruir el enlace simbólico para un sitio:

```shell
cd ~/Sites/laravel

valet unlink
```

<a name="securing-sites"></a>
### Asegurando Sitios Con TLS

Por defecto, Valet sirve sitios a través de HTTP. Sin embargo, si deseas servir un sitio a través de TLS encriptado usando HTTP/2, puedes usar el comando `secure`. Por ejemplo, si tu sitio está siendo servido por Valet en el dominio `laravel.test`, deberías ejecutar el siguiente comando para asegurarla:

```shell
valet secure laravel
```

Para "desasegurar" un sitio y volver a servir su tráfico a través de HTTP sin encriptar, usa el comando `unsecure`. Al igual que el comando `secure`, este comando acepta el nombre de host que deseas desasegurar:

```shell
valet unsecure laravel
```

<a name="serving-a-default-site"></a>
### Sirviendo un Sitio Predeterminado

A veces, puedes desear configurar Valet para servir un sitio "predeterminado" en lugar de un `404` al visitar un dominio `test` desconocido. Para lograr esto, puedes agregar una opción `default` a tu archivo de configuración `~/.config/valet/config.json` que contenga la ruta al sitio que debería servir como tu sitio predeterminado:

    "default": "/Users/Sally/Sites/example-site",

<a name="per-site-php-versions"></a>
### Versiones de PHP por Sitio

Por defecto, Valet utiliza tu instalación global de PHP para servir tus sitios. Sin embargo, si necesitas soportar múltiples versiones de PHP en varios sitios, puedes usar el comando `isolate` para especificar qué versión de PHP debe usar un sitio en particular. El comando `isolate` configura Valet para usar la versión de PHP especificada para el sitio ubicado en tu directorio de trabajo actual:

```shell
cd ~/Sites/example-site

valet isolate php@8.0
```

Si el nombre de tu sitio no coincide con el nombre del directorio que lo contiene, puedes especificar el nombre del sitio usando la opción `--site`:

```shell
valet isolate php@8.0 --site="nombre-del-sitio"
```

Para conveniencia, puedes usar los comandos `valet php`, `composer` y `which-php` para proxy las llamadas al CLI de PHP o herramienta apropiada según la versión de PHP configurada del sitio:

```shell
valet php
valet composer
valet which-php
```

Puedes ejecutar el comando `isolated` para mostrar una lista de todos tus sitios aislados y sus versiones de PHP:

```shell
valet isolated
```

Para revertir un sitio a la versión de PHP instalada globalmente por Valet, puedes invocar el comando `unisolate` desde el directorio raíz del sitio:

```shell
valet unisolate
```

<a name="sharing-sites"></a>
## Compartiendo Sitios

Valet incluye un comando para compartir tus sitios locales con el mundo, proporcionando una manera fácil de probar tu sitio en dispositivos móviles o compartirlo con miembros del equipo y clientes.

Fuera de la caja, Valet soporta compartir tus sitios a través de ngrok o Expose. Antes de compartir un sitio, debes actualizar tu configuración de Valet usando el comando `share-tool`, especificando ya sea `ngrok` o `expose`:

```shell
valet share-tool ngrok
```

Si eliges una herramienta y no la tienes instalada a través de Homebrew (para ngrok) o Composer (para Expose), Valet te pedirá automáticamente que la instales. Por supuesto, ambas herramientas requieren que autentiques tu cuenta de ngrok o Expose antes de que puedas comenzar a compartir sitios.

Para compartir un sitio, navega al directorio del sitio en tu terminal y ejecuta el comando `share` de Valet. Una URL accesible públicamente se colocará en tu portapapeles y está lista para pegar directamente en tu navegador o ser compartida con tu equipo:

```shell
cd ~/Sites/laravel

valet share
```

Para dejar de compartir tu sitio, puedes presionar `Control + C`.

> [!WARNING]  
> Si estás usando un servidor DNS personalizado (como `1.1.1.1`), el uso compartido de ngrok puede no funcionar correctamente. Si este es el caso en tu máquina, abre la configuración del sistema de tu Mac, ve a la configuración de Red, abre la configuración Avanzada, luego ve a la pestaña DNS y agrega `127.0.0.1` como tu primer servidor DNS.

<a name="sharing-sites-via-ngrok"></a>
#### Compartiendo Sitios a través de Ngrok

Compartir tu sitio usando ngrok requiere que [crees una cuenta de ngrok](https://dashboard.ngrok.com/signup) y [configures un token de autenticación](https://dashboard.ngrok.com/get-started/your-authtoken). Una vez que tengas un token de autenticación, puedes actualizar tu configuración de Valet con ese token:

```shell
valet set-ngrok-token YOUR_TOKEN_HERE
```

> [!NOTE]  
> Puedes pasar parámetros adicionales de ngrok al comando share, como `valet share --region=eu`. Para más información, consulta la [documentación de ngrok](https://ngrok.com/docs).

<a name="sharing-sites-via-expose"></a>
#### Compartiendo Sitios a través de Expose

Compartir tu sitio usando Expose requiere que [crees una cuenta de Expose](https://expose.dev/register) y [autenticarse con Expose a través de tu token de autenticación](https://expose.dev/docs/getting-started/getting-your-token).

Puedes consultar la [documentación de Expose](https://expose.dev/docs) para información sobre los parámetros adicionales de línea de comandos que soporta.

<a name="sharing-sites-on-your-local-network"></a>
### Compartiendo Sitios en Tu Red Local

Valet restringe el tráfico entrante a la interfaz interna `127.0.0.1` por defecto para que tu máquina de desarrollo no esté expuesta a riesgos de seguridad desde Internet.

Si deseas permitir que otros dispositivos en tu red local accedan a los sitios de Valet en tu máquina a través de la dirección IP de tu máquina (por ejemplo: `192.168.1.10/application.test`), necesitarás editar manualmente el archivo de configuración de Nginx apropiado para ese sitio para eliminar la restricción en la directiva `listen`. Debes eliminar el prefijo `127.0.0.1:` en la directiva `listen` para los puertos 80 y 443.

Si no has ejecutado `valet secure` en el proyecto, puedes abrir el acceso a la red para todos los sitios no HTTPS editando el archivo `/usr/local/etc/nginx/valet/valet.conf`. Sin embargo, si estás sirviendo el sitio del proyecto a través de HTTPS (has ejecutado `valet secure` para el sitio), entonces debes editar el archivo `~/.config/valet/Nginx/app-name.test`.

Una vez que hayas actualizado tu configuración de Nginx, ejecuta el comando `valet restart` para aplicar los cambios de configuración.

<a name="site-specific-environment-variables"></a>
## Variables de Entorno Específicas del Sitio

Algunas aplicaciones que utilizan otros frameworks pueden depender de variables de entorno del servidor, pero no proporcionan una forma de que esas variables se configuren dentro de tu proyecto. Valet te permite configurar variables de entorno específicas del sitio agregando un archivo `.valet-env.php` dentro de la raíz de tu proyecto. Este archivo debe devolver un array de pares de variables de sitio / entorno que se agregarán al array global `$_SERVER` para cada sitio especificado en el array:

    <?php

    return [
        // Establecer $_SERVER['key'] en "value" para el sitio laravel.test...
        'laravel' => [
            'key' => 'value',
        ],

        // Establecer $_SERVER['key'] en "value" para todos los sitios...
        '*' => [
            'key' => 'value',
        ],
    ];

<a name="proxying-services"></a>
## Servicios de Proxy

A veces, es posible que desees hacer proxy a un dominio de Valet hacia otro servicio en tu máquina local. Por ejemplo, es posible que ocasionalmente necesites ejecutar Valet mientras también ejecutas un sitio separado en Docker; sin embargo, Valet y Docker no pueden enlazarse al puerto 80 al mismo tiempo.

Para resolver esto, puedes usar el comando `proxy` para generar un proxy. Por ejemplo, puedes hacer proxy a todo el tráfico de `http://elasticsearch.test` a `http://127.0.0.1:9200`:

```shell
# Proxy over HTTP...
valet proxy elasticsearch http://127.0.0.1:9200

# Proxy over TLS + HTTP/2...
valet proxy elasticsearch http://127.0.0.1:9200 --secure
```

Puedes eliminar un proxy usando el comando `unproxy`:

```shell
valet unproxy elasticsearch
```

Puedes usar el comando `proxies` para listar todas las configuraciones de sitios que están proxied:

```shell
valet proxies
```

<a name="custom-valet-drivers"></a>
## Controladores Personalizados de Valet

Puedes escribir tu propio "controlador" de Valet para servir aplicaciones PHP que se ejecutan en un framework o CMS que no es compatible de forma nativa con Valet. Cuando instalas Valet, se crea un directorio `~/.config/valet/Drivers` que contiene un archivo `SampleValetDriver.php`. Este archivo contiene una implementación de controlador de muestra para demostrar cómo escribir un controlador personalizado. Escribir un controlador solo requiere que implementes tres métodos: `serves`, `isStaticFile` y `frontControllerPath`.

Los tres métodos reciben los valores `$sitePath`, `$siteName` y `$uri` como sus argumentos. El `$sitePath` es la ruta completamente calificada al sitio que se está sirviendo en tu máquina, como `/Users/Lisa/Sites/my-project`. El `$siteName` es la parte "host" / "nombre del sitio" del dominio (`my-project`). El `$uri` es la URI de la solicitud entrante (`/foo/bar`).

Una vez que hayas completado tu controlador personalizado de Valet, colócalo en el directorio `~/.config/valet/Drivers` utilizando la convención de nomenclatura `FrameworkValetDriver.php`. Por ejemplo, si estás escribiendo un controlador personalizado de valet para WordPress, tu nombre de archivo debería ser `WordPressValetDriver.php`.

Veamos una implementación de muestra de cada método que tu controlador personalizado de Valet debería implementar.

<a name="the-serves-method"></a>
#### El Método `serves`

El método `serves` debe devolver `true` si tu controlador debe manejar la solicitud entrante. De lo contrario, el método debe devolver `false`. Así que, dentro de este método, debes intentar determinar si el `$sitePath` dado contiene un proyecto del tipo que estás tratando de servir.

Por ejemplo, imaginemos que estamos escribiendo un `WordPressValetDriver`. Nuestro método `serves` podría verse algo así:

    /**
     * Determinar si el controlador sirve la solicitud.
     */
    public function serves(string $sitePath, string $siteName, string $uri): bool
    {
        return is_dir($sitePath.'/wp-admin');
    }

<a name="the-isstaticfile-method"></a>
#### El Método `isStaticFile`

El `isStaticFile` debe determinar si la solicitud entrante es para un archivo que es "estático", como una imagen o una hoja de estilo. Si el archivo es estático, el método debe devolver la ruta completamente calificada al archivo estático en el disco. Si la solicitud entrante no es para un archivo estático, el método debe devolver `false`:

    /**
     * Determinar si la solicitud entrante es para un archivo estático.
     *
     * @return string|false
     */
    public function isStaticFile(string $sitePath, string $siteName, string $uri)
    {
        if (file_exists($staticFilePath = $sitePath.'/public/'.$uri)) {
            return $staticFilePath;
        }

        return false;
    }

> [!WARNING]  
> El método `isStaticFile` solo se llamará si el método `serves` devuelve `true` para la solicitud entrante y la URI de la solicitud no es `/`.

<a name="the-frontcontrollerpath-method"></a>
#### El Método `frontControllerPath`

El método `frontControllerPath` debe devolver la ruta completamente calificada al "controlador frontal" de tu aplicación, que típicamente es un archivo "index.php" o equivalente:

    /**
     * Obtener la ruta completamente resuelta al controlador frontal de la aplicación.
     */
    public function frontControllerPath(string $sitePath, string $siteName, string $uri): string
    {
        return $sitePath.'/public/index.php';
    }

<a name="local-drivers"></a>
### Controladores Locales

Si deseas definir un controlador personalizado de Valet para una sola aplicación, crea un archivo `LocalValetDriver.php` en el directorio raíz de la aplicación. Tu controlador personalizado puede extender la clase base `ValetDriver` o extender un controlador específico de la aplicación existente, como el `LaravelValetDriver`:

    use Valet\Drivers\LaravelValetDriver;

    class LocalValetDriver extends LaravelValetDriver
    {
        /**
         * Determinar si el controlador sirve la solicitud.
         */
        public function serves(string $sitePath, string $siteName, string $uri): bool
        {
            return true;
        }

        /**
         * Obtener la ruta completamente resuelta al controlador frontal de la aplicación.
         */
        public function frontControllerPath(string $sitePath, string $siteName, string $uri): string
        {
            return $sitePath.'/public_html/index.php';
        }
    }

<a name="other-valet-commands"></a>
## Otros Comandos de Valet

<div class="overflow-auto">

| Comando | Descripción |
| --- | --- |
| `valet list` | Mostrar una lista de todos los comandos de Valet. |
| `valet diagnose` | Salida de diagnósticos para ayudar en la depuración de Valet. |
| `valet directory-listing` | Determinar el comportamiento de listado de directorios. El valor predeterminado es "off", lo que renderiza una página 404 para directorios. |
| `valet forget` | Ejecuta este comando desde un directorio "estacionado" para eliminarlo de la lista de directorios estacionados. |
| `valet log` | Ver una lista de registros que son escritos por los servicios de Valet. |
| `valet paths` | Ver todos tus "rutas estacionadas". |
| `valet restart` | Reiniciar los demonios de Valet. |
| `valet start` | Iniciar los demonios de Valet. |
| `valet stop` | Detener los demonios de Valet. |
| `valet trust` | Agregar archivos sudoers para Brew y Valet para permitir que los comandos de Valet se ejecuten sin solicitar tu contraseña. |
| `valet uninstall` | Desinstalar Valet: muestra instrucciones para la desinstalación manual. Pasa la opción `--force` para eliminar agresivamente todos los recursos de Valet. |

</div>

<a name="valet-directories-and-files"></a>
## Directorios y Archivos de Valet

Puedes encontrar la siguiente información sobre directorios y archivos útil mientras solucionas problemas con tu entorno de Valet:

#### `~/.config/valet`

Contiene toda la configuración de Valet. Puede que desees mantener una copia de seguridad de este directorio.

#### `~/.config/valet/dnsmasq.d/`

Este directorio contiene la configuración de DNSMasq.

#### `~/.config/valet/Drivers/`

Este directorio contiene los controladores de Valet. Los controladores determinan cómo se sirve un framework / CMS particular.

#### `~/.config/valet/Nginx/`

Este directorio contiene todas las configuraciones de sitios de Nginx de Valet. Estos archivos se reconstruyen al ejecutar los comandos `install` y `secure`.

#### `~/.config/valet/Sites/`

Este directorio contiene todos los enlaces simbólicos para tus [proyectos vinculados](#the-link-command).

#### `~/.config/valet/config.json`

Este archivo es el archivo de configuración maestro de Valet.

#### `~/.config/valet/valet.sock`

Este archivo es el socket de PHP-FPM utilizado por la instalación de Nginx de Valet. Esto solo existirá si PHP se está ejecutando correctamente.

#### `~/.config/valet/Log/fpm-php.www.log`

Este archivo es el registro de usuario para errores de PHP.

#### `~/.config/valet/Log/nginx-error.log`

Este archivo es el registro de usuario para errores de Nginx.

#### `/usr/local/var/log/php-fpm.log`

Este archivo es el registro del sistema para errores de PHP-FPM.

#### `/usr/local/var/log/nginx`

Este directorio contiene los registros de acceso y error de Nginx.

#### `/usr/local/etc/php/X.X/conf.d`

Este directorio contiene los archivos `*.ini` para varias configuraciones de PHP.

#### `/usr/local/etc/php/X.X/php-fpm.d/valet-fpm.conf`

Este archivo es el archivo de configuración del pool de PHP-FPM.

#### `~/.composer/vendor/laravel/valet/cli/stubs/secure.valet.conf`

Este archivo es la configuración predeterminada de Nginx utilizada para construir certificados SSL para tus sitios.

<a name="disk-access"></a>
### Acceso al Disco

Desde macOS 10.14, [el acceso a algunos archivos y directorios está restringido por defecto](https://manuals.info.apple.com/MANUALS/1000/MA1902/en_US/apple-platform-security-guide.pdf). Estas restricciones incluyen los directorios de Escritorio, Documentos y Descargas. Además, el acceso a volúmenes de red y volúmenes extraíbles está restringido. Por lo tanto, Valet recomienda que tus carpetas de sitios se ubiquen fuera de estas ubicaciones protegidas.

Sin embargo, si deseas servir sitios desde dentro de una de esas ubicaciones, necesitarás otorgar a Nginx "Acceso Completo al Disco". De lo contrario, puedes encontrar errores de servidor u otro comportamiento impredecible de Nginx, especialmente al servir activos estáticos. Típicamente, macOS te pedirá automáticamente que otorgues a Nginx acceso completo a estas ubicaciones. O, puedes hacerlo manualmente a través de `Preferencias del Sistema` > `Seguridad y Privacidad` > `Privacidad` y seleccionando `Acceso Completo al Disco`. A continuación, habilita cualquier entrada de `nginx` en el panel de la ventana principal.
