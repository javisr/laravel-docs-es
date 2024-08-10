# Configuración

- [Introducción](#introduction)
- [Configuración del Entorno](#environment-configuration)
    - [Tipos de Variables de Entorno](#environment-variable-types)
    - [Recuperando la Configuración del Entorno](#retrieving-environment-configuration)
    - [Determinando el Entorno Actual](#determining-the-current-environment)
    - [Encriptando Archivos de Entorno](#encrypting-environment-files)
- [Accediendo a Valores de Configuración](#accessing-configuration-values)
- [Caché de Configuración](#configuration-caching)
- [Publicación de Configuración](#configuration-publishing)
- [Modo de Depuración](#debug-mode)
- [Modo de Mantenimiento](#maintenance-mode)

<a name="introduction"></a>
## Introducción

Todos los archivos de configuración para el framework Laravel se almacenan en el directorio `config`. Cada opción está documentada, así que siéntete libre de revisar los archivos y familiarizarte con las opciones disponibles para ti.

Estos archivos de configuración te permiten configurar cosas como la información de conexión a tu base de datos, la información de tu servidor de correo, así como varios otros valores de configuración central como la zona horaria de tu aplicación y la clave de encriptación.

<a name="the-about-command"></a>
#### El Comando `about`

Laravel puede mostrar una visión general de la configuración, controladores y entorno de tu aplicación a través del comando Artisan `about`.

```shell
php artisan about
```

Si solo estás interesado en una sección particular de la salida de la visión general de la aplicación, puedes filtrar esa sección usando la opción `--only`:

```shell
php artisan about --only=environment
```

O, para explorar los valores de un archivo de configuración específico en detalle, puedes usar el comando Artisan `config:show`:

```shell
php artisan config:show database
```

<a name="environment-configuration"></a>
## Configuración del Entorno

A menudo es útil tener diferentes valores de configuración según el entorno en el que se esté ejecutando la aplicación. Por ejemplo, es posible que desees usar un controlador de caché diferente localmente que el que usas en tu servidor de producción.

Para facilitar esto, Laravel utiliza la biblioteca PHP [DotEnv](https://github.com/vlucas/phpdotenv). En una instalación nueva de Laravel, el directorio raíz de tu aplicación contendrá un archivo `.env.example` que define muchas variables de entorno comunes. Durante el proceso de instalación de Laravel, este archivo se copiará automáticamente a `.env`.

El archivo `.env` predeterminado de Laravel contiene algunos valores de configuración comunes que pueden diferir según si tu aplicación se está ejecutando localmente o en un servidor web de producción. Estos valores se leen luego por los archivos de configuración dentro del directorio `config` utilizando la función `env` de Laravel.

Si estás desarrollando con un equipo, es posible que desees seguir incluyendo y actualizando el archivo `.env.example` con tu aplicación. Al poner valores de marcador de posición en el archivo de configuración de ejemplo, otros desarrolladores en tu equipo pueden ver claramente qué variables de entorno son necesarias para ejecutar tu aplicación.

> [!NOTE]  
> Cualquier variable en tu archivo `.env` puede ser sobrescrita por variables de entorno externas, como variables de entorno a nivel de servidor o de sistema.

<a name="environment-file-security"></a>
#### Seguridad del Archivo de Entorno

Tu archivo `.env` no debe ser comprometido en el control de versiones de tu aplicación, ya que cada desarrollador / servidor que utiliza tu aplicación podría requerir una configuración de entorno diferente. Además, esto sería un riesgo de seguridad en caso de que un intruso obtenga acceso a tu repositorio de control de versiones, ya que cualquier credencial sensible quedaría expuesta.

Sin embargo, es posible encriptar tu archivo de entorno utilizando la [encriptación de entorno](#encrypting-environment-files) incorporada de Laravel. Los archivos de entorno encriptados pueden ser colocados en el control de versiones de manera segura.

<a name="additional-environment-files"></a>
#### Archivos de Entorno Adicionales

Antes de cargar las variables de entorno de tu aplicación, Laravel determina si se ha proporcionado externamente una variable de entorno `APP_ENV` o si se ha especificado el argumento CLI `--env`. Si es así, Laravel intentará cargar un archivo `.env.[APP_ENV]` si existe. Si no existe, se cargará el archivo `.env` predeterminado.

<a name="environment-variable-types"></a>
### Tipos de Variables de Entorno

Todas las variables en tus archivos `.env` se analizan típicamente como cadenas, por lo que se han creado algunos valores reservados para permitirte devolver una gama más amplia de tipos desde la función `env()`:

| Valor `.env` | Valor `env()` |
| ------------ | ------------- |
| true         | (bool) true   |
| (true)       | (bool) true   |
| false        | (bool) false  |
| (false)      | (bool) false  |
| empty        | (string) ''   |
| (empty)      | (string) ''   |
| null         | (null) null   |
| (null)       | (null) null   |

Si necesitas definir una variable de entorno con un valor que contenga espacios, puedes hacerlo encerrando el valor entre comillas dobles:

```ini
APP_NAME="My Application"
```

<a name="retrieving-environment-configuration"></a>
### Recuperando la Configuración del Entorno

Todas las variables listadas en el archivo `.env` se cargarán en el superglobal PHP `$_ENV` cuando tu aplicación reciba una solicitud. Sin embargo, puedes usar la función `env` para recuperar valores de estas variables en tus archivos de configuración. De hecho, si revisas los archivos de configuración de Laravel, notarás que muchas de las opciones ya están utilizando esta función:

    'debug' => env('APP_DEBUG', false),

El segundo valor pasado a la función `env` es el "valor predeterminado". Este valor se devolverá si no existe una variable de entorno para la clave dada.

<a name="determining-the-current-environment"></a>
### Determinando el Entorno Actual

El entorno actual de la aplicación se determina a través de la variable `APP_ENV` de tu archivo `.env`. Puedes acceder a este valor a través del método `environment` en el [facade](/docs/{{version}}/facades) `App`:

    use Illuminate\Support\Facades\App;

    $environment = App::environment();

También puedes pasar argumentos al método `environment` para determinar si el entorno coincide con un valor dado. El método devolverá `true` si el entorno coincide con cualquiera de los valores dados:

    if (App::environment('local')) {
        // El entorno es local
    }

    if (App::environment(['local', 'staging'])) {
        // El entorno es local O staging...
    }

> [!NOTE]  
> La detección del entorno actual de la aplicación puede ser sobrescrita definiendo una variable de entorno a nivel de servidor `APP_ENV`.

<a name="encrypting-environment-files"></a>
### Encriptando Archivos de Entorno

Los archivos de entorno no encriptados nunca deben ser almacenados en el control de versiones. Sin embargo, Laravel te permite encriptar tus archivos de entorno para que puedan ser añadidos de manera segura al control de versiones junto con el resto de tu aplicación.

<a name="encryption"></a>
#### Encriptación

Para encriptar un archivo de entorno, puedes usar el comando `env:encrypt`:

```shell
php artisan env:encrypt
```

Ejecutar el comando `env:encrypt` encriptará tu archivo `.env` y colocará el contenido encriptado en un archivo `.env.encrypted`. La clave de desencriptación se presenta en la salida del comando y debe ser almacenada en un gestor de contraseñas seguro. Si deseas proporcionar tu propia clave de encriptación, puedes usar la opción `--key` al invocar el comando:

```shell
php artisan env:encrypt --key=3UVsEgGVK36XN82KKeyLFMhvosbZN1aF
```

> [!NOTE]  
> La longitud de la clave proporcionada debe coincidir con la longitud de clave requerida por el cifrado que se está utilizando. Por defecto, Laravel utilizará el cifrado `AES-256-CBC` que requiere una clave de 32 caracteres. Eres libre de usar cualquier cifrado soportado por el [encriptador](/docs/{{version}}/encryption) de Laravel pasando la opción `--cipher` al invocar el comando.

Si tu aplicación tiene múltiples archivos de entorno, como `.env` y `.env.staging`, puedes especificar el archivo de entorno que debe ser encriptado proporcionando el nombre del entorno a través de la opción `--env`:

```shell
php artisan env:encrypt --env=staging
```

<a name="decryption"></a>
#### Desencriptación

Para desencriptar un archivo de entorno, puedes usar el comando `env:decrypt`. Este comando requiere una clave de desencriptación, que Laravel recuperará de la variable de entorno `LARAVEL_ENV_ENCRYPTION_KEY`:

```shell
php artisan env:decrypt
```

O, la clave puede ser proporcionada directamente al comando a través de la opción `--key`:

```shell
php artisan env:decrypt --key=3UVsEgGVK36XN82KKeyLFMhvosbZN1aF
```

Cuando se invoca el comando `env:decrypt`, Laravel desencriptará el contenido del archivo `.env.encrypted` y colocará el contenido desencriptado en el archivo `.env`.

La opción `--cipher` puede ser proporcionada al comando `env:decrypt` para usar un cifrado personalizado:

```shell
php artisan env:decrypt --key=qUWuNRdfuImXcKxZ --cipher=AES-128-CBC
```

Si tu aplicación tiene múltiples archivos de entorno, como `.env` y `.env.staging`, puedes especificar el archivo de entorno que debe ser desencriptado proporcionando el nombre del entorno a través de la opción `--env`:

```shell
php artisan env:decrypt --env=staging
```

Para sobrescribir un archivo de entorno existente, puedes proporcionar la opción `--force` al comando `env:decrypt`:

```shell
php artisan env:decrypt --force
```

<a name="accessing-configuration-values"></a>
## Accediendo a Valores de Configuración

Puedes acceder fácilmente a tus valores de configuración utilizando el facade `Config` o la función global `config` desde cualquier lugar de tu aplicación. Los valores de configuración pueden ser accedidos utilizando la sintaxis de "punto", que incluye el nombre del archivo y la opción que deseas acceder. También se puede especificar un valor predeterminado que se devolverá si la opción de configuración no existe:

    use Illuminate\Support\Facades\Config;

    $value = Config::get('app.timezone');

    $value = config('app.timezone');

    // Recuperar un valor predeterminado si el valor de configuración no existe...
    $value = config('app.timezone', 'Asia/Seoul');

Para establecer valores de configuración en tiempo de ejecución, puedes invocar el método `set` del facade `Config` o pasar un array a la función `config`:

    Config::set('app.timezone', 'America/Chicago');

    config(['app.timezone' => 'America/Chicago']);

Para ayudar con el análisis estático, el facade `Config` también proporciona métodos de recuperación de configuración tipados. Si el valor de configuración recuperado no coincide con el tipo esperado, se lanzará una excepción:

    Config::string('config-key');
    Config::integer('config-key');
    Config::float('config-key');
    Config::boolean('config-key');
    Config::array('config-key');

<a name="configuration-caching"></a>
## Caché de Configuración

Para darle un impulso de velocidad a tu aplicación, deberías almacenar en caché todos tus archivos de configuración en un solo archivo utilizando el comando Artisan `config:cache`. Esto combinará todas las opciones de configuración para tu aplicación en un solo archivo que puede ser cargado rápidamente por el framework.

Normalmente deberías ejecutar el comando `php artisan config:cache` como parte de tu proceso de despliegue en producción. El comando no debe ser ejecutado durante el desarrollo local, ya que las opciones de configuración necesitarán ser cambiadas frecuentemente durante el desarrollo de tu aplicación.

Una vez que la configuración ha sido almacenada en caché, el archivo `.env` de tu aplicación no será cargado por el framework durante las solicitudes o comandos Artisan; por lo tanto, la función `env` solo devolverá variables de entorno externas, a nivel de sistema.

Por esta razón, debes asegurarte de que solo estás llamando a la función `env` desde los archivos de configuración de tu aplicación (`config`). Puedes ver muchos ejemplos de esto al examinar los archivos de configuración predeterminados de Laravel. Los valores de configuración pueden ser accedidos desde cualquier lugar de tu aplicación utilizando la función `config` [descrita arriba](#accessing-configuration-values).

El comando `config:clear` puede ser utilizado para purgar la configuración almacenada en caché:

```shell
php artisan config:clear
```

> [!WARNING]  
> Si ejecutas el comando `config:cache` durante tu proceso de despliegue, debes asegurarte de que solo estás llamando a la función `env` desde dentro de tus archivos de configuración. Una vez que la configuración ha sido almacenada en caché, el archivo `.env` no será cargado; por lo tanto, la función `env` solo devolverá variables de entorno externas, a nivel de sistema.

<a name="configuration-publishing"></a>
## Publicación de Configuración

La mayoría de los archivos de configuración de Laravel ya están publicados en el directorio `config` de tu aplicación; sin embargo, ciertos archivos de configuración como `cors.php` y `view.php` no se publican por defecto, ya que la mayoría de las aplicaciones nunca necesitarán modificarlos.

Sin embargo, puedes usar el comando Artisan `config:publish` para publicar cualquier archivo de configuración que no esté publicado por defecto:

```shell
php artisan config:publish

php artisan config:publish --all
```

<a name="debug-mode"></a>
## Modo de Depuración

La opción `debug` en tu archivo de configuración `config/app.php` determina cuánta información sobre un error se muestra realmente al usuario. Por defecto, esta opción está configurada para respetar el valor de la variable de entorno `APP_DEBUG`, que se almacena en tu archivo `.env`.

> [!WARNING]  
> Para el desarrollo local, debes establecer la variable de entorno `APP_DEBUG` en `true`. **En tu entorno de producción, este valor siempre debe ser `false`. Si la variable se establece en `true` en producción, corres el riesgo de exponer valores de configuración sensibles a los usuarios finales de tu aplicación.**

<a name="maintenance-mode"></a>
## Modo de Mantenimiento

Cuando tu aplicación está en modo de mantenimiento, se mostrará una vista personalizada para todas las solicitudes a tu aplicación. Esto facilita "desactivar" tu aplicación mientras se actualiza o cuando estás realizando mantenimiento. Una verificación de modo de mantenimiento está incluida en la pila de middleware predeterminada para tu aplicación. Si la aplicación está en modo de mantenimiento, se lanzará una instancia de `Symfony\Component\HttpKernel\Exception\HttpException` con un código de estado de 503.

Para habilitar el modo de mantenimiento, ejecuta el comando Artisan `down`:

```shell
php artisan down
```

Si deseas que el encabezado HTTP `Refresh` se envíe con todas las respuestas en modo de mantenimiento, puedes proporcionar la opción `refresh` al invocar el comando `down`. El encabezado `Refresh` indicará al navegador que actualice automáticamente la página después del número especificado de segundos:

```shell
php artisan down --refresh=15
```

También puedes proporcionar una opción `retry` al comando `down`, que se establecerá como el valor del encabezado HTTP `Retry-After`, aunque los navegadores generalmente ignoran este encabezado:

```shell
php artisan down --retry=60
```

<a name="bypassing-maintenance-mode"></a>
#### Evitando el Modo de Mantenimiento

Para permitir que el modo de mantenimiento sea evitado usando un token secreto, puedes usar la opción `secret` para especificar un token de bypass del modo de mantenimiento:

```shell
php artisan down --secret="1630542a-246b-4b66-afa1-dd72a4c43515"
```

Después de colocar la aplicación en modo de mantenimiento, puedes navegar a la URL de la aplicación que coincide con este token y Laravel emitirá una cookie de bypass del modo de mantenimiento a tu navegador:

```shell
https://example.com/1630542a-246b-4b66-afa1-dd72a4c43515
```

Si deseas que Laravel genere el token secreto por ti, puedes usar la opción `with-secret`. El secreto se mostrará una vez que la aplicación esté en modo de mantenimiento:

```shell
php artisan down --with-secret
```

Al acceder a esta ruta oculta, serás redirigido a la ruta `/` de la aplicación. Una vez que la cookie ha sido emitida a tu navegador, podrás navegar por la aplicación normalmente como si no estuviera en modo de mantenimiento.

> [!NOTE]  
> Su secreto de modo de mantenimiento debe consistir típicamente en caracteres alfanuméricos y, opcionalmente, guiones. Debe evitar usar caracteres que tengan un significado especial en las URL, como `?` o `&`.

<a name="maintenance-mode-on-multiple-servers"></a>
#### Modo de Mantenimiento en Múltiples Servidores

Por defecto, Laravel determina si su aplicación está en modo de mantenimiento utilizando un sistema basado en archivos. Esto significa que para activar el modo de mantenimiento, el comando `php artisan down` debe ejecutarse en cada servidor que aloje su aplicación.

Alternativamente, Laravel ofrece un método basado en caché para manejar el modo de mantenimiento. Este método requiere ejecutar el comando `php artisan down` en solo un servidor. Para usar este enfoque, modifique la configuración "driver" en el archivo `config/app.php` de su aplicación a `cache`. Luego, seleccione un `store` de caché que sea accesible por todos sus servidores. Esto asegura que el estado del modo de mantenimiento se mantenga consistentemente en cada servidor:

```php
'maintenance' => [
    'driver' => 'cache',
    'store' => 'database',
],
```

<a name="pre-rendering-the-maintenance-mode-view"></a>
#### Pre-renderizando la Vista de Modo de Mantenimiento

Si utiliza el comando `php artisan down` durante el despliegue, sus usuarios pueden aún ocasionalmente encontrar errores si acceden a la aplicación mientras sus dependencias de Composer u otros componentes de infraestructura se están actualizando. Esto ocurre porque una parte significativa del marco de Laravel debe iniciarse para determinar que su aplicación está en modo de mantenimiento y renderizar la vista de modo de mantenimiento utilizando el motor de plantillas.

Por esta razón, Laravel le permite pre-renderizar una vista de modo de mantenimiento que se devolverá al principio del ciclo de solicitud. Esta vista se renderiza antes de que se hayan cargado las dependencias de su aplicación. Puede pre-renderizar una plantilla de su elección utilizando la opción `render` del comando `down`:

```shell
php artisan down --render="errors::503"
```

<a name="redirecting-maintenance-mode-requests"></a>
#### Redirigiendo Solicitudes de Modo de Mantenimiento

Mientras esté en modo de mantenimiento, Laravel mostrará la vista de modo de mantenimiento para todas las URL de la aplicación que el usuario intente acceder. Si lo desea, puede instruir a Laravel para redirigir todas las solicitudes a una URL específica. Esto se puede lograr utilizando la opción `redirect`. Por ejemplo, puede desear redirigir todas las solicitudes a la URI `/`:

```shell
php artisan down --redirect=/
```

<a name="disabling-maintenance-mode"></a>
#### Deshabilitando el Modo de Mantenimiento

Para deshabilitar el modo de mantenimiento, use el comando `up`:

```shell
php artisan up
```

> [!NOTE]  
> Puede personalizar la plantilla de modo de mantenimiento predeterminada definiendo su propia plantilla en `resources/views/errors/503.blade.php`.

<a name="maintenance-mode-queues"></a>
#### Modo de Mantenimiento y Colas

Mientras su aplicación esté en modo de mantenimiento, no se manejarán [trabajos en cola](/docs/{{version}}/queues). Los trabajos continuarán siendo manejados normalmente una vez que la aplicación salga del modo de mantenimiento.

<a name="alternatives-to-maintenance-mode"></a>
#### Alternativas al Modo de Mantenimiento

Dado que el modo de mantenimiento requiere que su aplicación tenga varios segundos de inactividad, considere alternativas como [Laravel Vapor](https://vapor.laravel.com) y [Envoyer](https://envoyer.io) para lograr un despliegue sin tiempo de inactividad con Laravel.
