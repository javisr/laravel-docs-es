# Configuración

- [Introducción](#introduction)
- [Configuración del Entorno](#environment-configuration)
  - [Tipos de Variables de Entorno](#environment-variable-types)
  - [Recuperar Configuración del Entorno](#retrieving-environment-configuration)
  - [Determinar el Entorno Actual](#determining-the-current-environment)
  - [Cifrar Archivos de Entorno](#encrypting-environment-files)
- [Acceder a Valores de Configuración](#accessing-configuration-values)
- [Caché de Configuración](#configuration-caching)
- [Publicación de Configuración](#configuration-publishing)
- [Modo de Depuración](#debug-mode)
- [Modo de Mantenimiento](#maintenance-mode)

<a name="introduction"></a>
## Introducción

Todos los archivos de configuración para el framework Laravel se almacenan en el directorio `config`. Cada opción está documentada, así que siéntete libre de revisar los archivos y familiarizarte con las opciones disponibles para ti.
Estos archivos de configuración te permiten configurar cosas como la información de conexión a tu base de datos, la información de tu servidor de correo, así como varios otros valores de configuración básicos como la zona horaria de tu aplicación y la clave de cifrado.

<a name="the-about-command"></a>
#### El comando `about`

Laravel puede mostrar una visión general de la configuración, los drivers y el entorno de tu aplicación a través del comando Artisan `about`.


```shell
php artisan about

```
Si solo te interesa una sección particular de la salida del resumen de la aplicación, puedes filtrar esa sección utilizando la opción `--only`:


```shell
php artisan about --only=environment

```
O, para explorar en detalle los valores de un archivo de configuración específico, puedes usar el comando Artisan `config:show`:


```shell
php artisan config:show database

```

<a name="environment-configuration"></a>
## Configuración del Entorno

A menudo es útil tener diferentes valores de configuración según el entorno en el que se ejecuta la aplicación. Por ejemplo, es posible que desees usar un driver de caché diferente localmente que el que utilizas en tu servidor de producción.
Para hacer esto sencillo, Laravel utiliza la biblioteca PHP [DotEnv](https://github.com/vlucas/phpdotenv). En una instalación nueva de Laravel, el directorio raíz de tu aplicación contendrá un archivo `.env.example` que define muchas variables de entorno comunes. Durante el proceso de instalación de Laravel, este archivo se copiará automáticamente a `.env`.
El archivo `.env` por defecto de Laravel contiene algunos valores de configuración comunes que pueden diferir según si tu aplicación se está ejecutando localmente o en un servidor web de producción. Estos valores son leídos luego por los archivos de configuración dentro del directorio `config` utilizando la función `env` de Laravel.
Si estás desarrollando con un equipo, es posible que desees seguir incluyendo y actualizando el archivo `.env.example` con tu aplicación. Al poner valores de marcador de posición en el archivo de configuración de ejemplo, otros desarrolladores de tu equipo pueden ver claramente qué variables de entorno se necesitan para ejecutar tu aplicación.
> [!NOTA]
Cualquiera de las variables en tu archivo `.env` puede ser sobrescrita por variables de entorno externas, como variables de entorno a nivel de servidor o de sistema.

<a name="environment-file-security"></a>
#### Seguridad del archivo de entorno

Tu archivo `.env` no debe ser comprometido en el control de versiones de la fuente de tu aplicación, ya que cada desarrollador / servidor que utilice tu aplicación podría requerir una configuración de entorno diferente. Además, esto supondría un riesgo de seguridad en caso de que un intruso obtenga acceso a tu repositorio de control de versiones, ya que cualquier credencial sensible quedaría expuesta.
Sin embargo, es posible encriptar tu archivo de entorno utilizando la [encriptación de entorno](#encrypting-environment-files) integrada de Laravel. Los archivos de entorno encriptados pueden colocarse en el control de versiones de manera segura.

<a name="additional-environment-files"></a>
#### Archivos de Entorno Adicionales

Antes de cargar las variables de entorno de tu aplicación, Laravel determina si se ha proporcionado externamente una variable de entorno `APP_ENV` o si se ha especificado el argumento CLI `--env`. Si es así, Laravel intentará cargar un archivo `.env.[APP_ENV]` si existe. Si no existe, se cargará el archivo `.env` por defecto.

<a name="environment-variable-types"></a>
### Tipos de Variables de Entorno

Todas las variables en tus archivos `.env` se analizan típicamente como cadenas, por lo que se han creado algunos valores reservados para permitirte devolver una gama más amplia de tipos desde la función `env()`:
<div class="overflow-auto">

| Valor de `.env` | Valor de `env()` |
| --------------- | ----------------- |
| true           | (bool) true       |
| (true)         | (bool) true       |
| false          | (bool) false      |
| (false)        | (bool) false      |
| vacío          | (string) ''       |
| (vacío)        | (string) ''       |
| null           | (null) null       |
| (null)         | (null) null       |
</div>
Si necesitas definir una variable de entorno con un valor que contiene espacios, puedes hacerlo encerrando el valor entre comillas dobles:


```ini
APP_NAME="My Application"

```

<a name="retrieving-environment-configuration"></a>
### Recuperando la Configuración del Entorno

Todas las variables listadas en el archivo `.env` se cargarán en el superglobal `$_ENV` de PHP cuando tu aplicación reciba una solicitud. Sin embargo, puedes usar la función `env` para recuperar valores de estas variables en tus archivos de configuración. De hecho, si revisas los archivos de configuración de Laravel, notarás que muchas de las opciones ya están utilizando esta función:


```php
'debug' => env('APP_DEBUG', false),
```
El segundo valor pasado a la función `env` es el "valor predeterminado". Este valor se devolverá si no existe ninguna variable de entorno para la clave dada.

<a name="determining-the-current-environment"></a>
### Determinando el Entorno Actual

El entorno de la aplicación actual se determina a través de la variable `APP_ENV` de tu archivo `.env`. Puedes acceder a este valor mediante el método `environment` en la [facade](/docs/%7B%7Bversion%7D%7D/facades) `App`:


```php
use Illuminate\Support\Facades\App;

$environment = App::environment();
```
También puedes pasar argumentos al método `environment` para determinar si el entorno coincide con un valor dado. El método devolverá `true` si el entorno coincide con cualquiera de los valores dados:


```php
if (App::environment('local')) {
    // The environment is local
}

if (App::environment(['local', 'staging'])) {
    // The environment is either local OR staging...
}
```
> [!NOTA]
La detección del entorno de la aplicación actual se puede anular definiendo una variable de entorno `APP_ENV` a nivel de servidor.

<a name="encrypting-environment-files"></a>
### Encriptando Archivos de Entorno

Los archivos de entorno no encriptados nunca deben almacenarse en el control de versiones. Sin embargo, Laravel te permite encriptar tus archivos de entorno para que puedan añadirse de forma segura al control de versiones junto con el resto de tu aplicación.

<a name="encryption"></a>
#### Encriptación

Para encriptar un archivo de entorno, puedes usar el comando `env:encrypt`:


```shell
php artisan env:encrypt

```
Ejecutar el comando `env:encrypt` encriptará tu archivo `.env` y colocará el contenido encriptado en un archivo `.env.encrypted`. La clave de desencriptación se presenta en la salida del comando y debe almacenarse en un gestor de contraseñas seguro. Si deseas proporcionar tu propia clave de encriptación, puedes usar la opción `--key` al invocar el comando:


```shell
php artisan env:encrypt --key=3UVsEgGVK36XN82KKeyLFMhvosbZN1aF

```
> [!NOTE]
La longitud de la clave proporcionada debe coincidir con la longitud de clave requerida por el cifrador de encripción que se está utilizando. Por defecto, Laravel utilizará el cifrador `AES-256-CBC` que requiere una clave de 32 caracteres. Puedes usar cualquier cifrador soportado por el [encriptador](/docs/%7B%7Bversion%7D%7D/encryption) de Laravel pasando la opción `--cipher` al invocar el comando.
Si tu aplicación tiene múltiples archivos de entorno, como `.env` y `.env.staging`, puedes especificar el archivo de entorno que debe ser cifrado proporcionando el nombre del entorno a través de la opción `--env`:


```shell
php artisan env:encrypt --env=staging

```

<a name="decryption"></a>
#### Desencriptación

Para descifrar un archivo de entorno, puedes usar el comando `env:decrypt`. Este comando requiere una clave de descifrado, que Laravel recuperará de la variable de entorno `LARAVEL_ENV_ENCRYPTION_KEY`:


```shell
php artisan env:decrypt

```
O bien, la clave puede proporcionarse directamente al comando a través de la opción `--key`:


```shell
php artisan env:decrypt --key=3UVsEgGVK36XN82KKeyLFMhvosbZN1aF

```
Cuando se invoca el comando `env:decrypt`, Laravel descifrará el contenido del archivo `.env.encrypted` y colocará el contenido descifrado en el archivo `.env`.
La opción `--cipher` puede ser proporcionada al comando `env:decrypt` para usar un cifrado de encriptación personalizado:


```shell
php artisan env:decrypt --key=qUWuNRdfuImXcKxZ --cipher=AES-128-CBC

```
Si tu aplicación tiene múltiples archivos de entorno, como `.env` y `.env.staging`, puedes especificar el archivo de entorno que debe ser descifrado proporcionando el nombre del entorno a través de la opción `--env`:


```shell
php artisan env:decrypt --env=staging

```
Para sobrescribir un archivo de entorno existente, puedes proporcionar la opción `--force` al comando `env:decrypt`:


```shell
php artisan env:decrypt --force

```

<a name="accessing-configuration-values"></a>
## Accediendo a Valores de Configuración

Puedes acceder fácilmente a tus valores de configuración utilizando la fachada `Config` o la función global `config` desde cualquier parte de tu aplicación. Los valores de configuración se pueden acceder utilizando la sintaxis de "punto", que incluye el nombre del archivo y la opción que deseas acceder. También se puede especificar un valor predeterminado, que se devolverá si la opción de configuración no existe:


```php
use Illuminate\Support\Facades\Config;

$value = Config::get('app.timezone');

$value = config('app.timezone');

// Retrieve a default value if the configuration value does not exist...
$value = config('app.timezone', 'Asia/Seoul');
```
Para establecer valores de configuración en tiempo de ejecución, puedes invocar el método `set` de la facade `Config` o pasar un array a la función `config`:


```php
Config::set('app.timezone', 'America/Chicago');

config(['app.timezone' => 'America/Chicago']);
```
Para ayudar con el análisis estático, la facade `Config` también proporciona métodos de recuperación de configuración tipados. Si el valor de configuración recuperado no coincide con el tipo esperado, se lanzará una excepción:


```php
Config::string('config-key');
Config::integer('config-key');
Config::float('config-key');
Config::boolean('config-key');
Config::array('config-key');
```

<a name="configuration-caching"></a>
## Caché de Configuración

Para darle un impulso de velocidad a tu aplicación, deberías almacenar en caché todos tus archivos de configuración en un solo archivo utilizando el comando Artisan `config:cache`. Esto combinará todas las opciones de configuración para tu aplicación en un solo archivo que puede ser cargado rápidamente por el framework.
Normalmente, debes ejecutar el comando `php artisan config:cache` como parte de tu proceso de implementación en producción. El comando no debe ejecutarse durante el desarrollo local, ya que las opciones de configuración deberán cambiar con frecuencia a lo largo del desarrollo de tu aplicación.
Una vez que la configuración ha sido almacenada en caché, el archivo `.env` de tu aplicación no será cargado por el framework durante las solicitudes o comandos Artisan; por lo tanto, la función `env` solo devolverá variables de entorno externas a nivel del sistema.
Por esta razón, debes asegurarte de que solo estás llamando a la función `env` desde los archivos de configuración (`config`) de tu aplicación. Puedes ver muchos ejemplos de esto al examinar los archivos de configuración predeterminados de Laravel. Los valores de configuración se pueden acceder desde cualquier lugar en tu aplicación utilizando la función `config` [descrita arriba](#accessing-configuration-values).
El comando `config:clear` se puede usar para purgar la configuración en caché:


```shell
php artisan config:clear

```
> [!WARNING]
Si ejecutas el comando `config:cache` durante tu proceso de despliegue, debes asegurarte de que solo estés llamando a la función `env` desde dentro de tus archivos de configuración. Una vez que la configuración ha sido almacenada en caché, el archivo `.env` no se cargará; por lo tanto, la función `env` solo devolverá variables de entorno externas de nivel del sistema.

<a name="configuration-publishing"></a>
## Publicación de Configuración

La mayoría de los archivos de configuración de Laravel ya están publicados en el directorio `config` de tu aplicación; sin embargo, ciertos archivos de configuración como `cors.php` y `view.php` no se publican por defecto, ya que la mayoría de las aplicaciones nunca necesitarán modificarlos.
Sin embargo, puedes usar el comando Artisan `config:publish` para publicar cualquier archivo de configuración que no se publique por defecto:


```shell
php artisan config:publish

php artisan config:publish --all

```

<a name="debug-mode"></a>
## Modo de Depuración

La opción `debug` en tu archivo de configuración `config/app.php` determina cuánta información sobre un error se muestra realmente al usuario. Por defecto, esta opción está configurada para respetar el valor de la variable de entorno `APP_DEBUG`, que se almacena en tu archivo `.env`.
> [!WARNING]
Para el desarrollo local, debes configurar la variable de entorno `APP_DEBUG` en `true`. **En tu entorno de producción, este valor siempre debe ser `false`. Si la variable se establece en `true` en producción, corres el riesgo de exponer valores de configuración sensibles a los usuarios finales de tu aplicación.**

<a name="maintenance-mode"></a>
## Modo de Mantenimiento

Cuando tu aplicación está en modo de mantenimiento, se mostrará una vista personalizada para todas las solicitudes a tu aplicación. Esto facilita "desactivar" tu aplicación mientras se está actualizando o cuando estás realizando mantenimiento. Se incluye una verificación de modo de mantenimiento en la pila de middleware predeterminada para tu aplicación. Si la aplicación está en modo de mantenimiento, se lanzará una instancia de `Symfony\Component\HttpKernel\Exception\HttpException` con un código de estado 503.
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
#### Eludir el Modo de Mantenimiento

Para permitir que el modo de mantenimiento se omita utilizando un token secreto, puedes usar la opción `secret` para especificar un token de omisión del modo de mantenimiento:


```shell
php artisan down --secret="1630542a-246b-4b66-afa1-dd72a4c43515"

```
Después de poner la aplicación en modo de mantenimiento, puedes navegar a la URL de la aplicación que coincide con este token y Laravel emitirá una cookie de bypass de modo de mantenimiento a tu navegador:


```shell
https://example.com/1630542a-246b-4b66-afa1-dd72a4c43515

```
Si deseas que Laravel genere el token secreto por ti, puedes usar la opción `with-secret`. El secreto se te mostrará una vez que la aplicación esté en modo de mantenimiento:


```shell
php artisan down --with-secret

```
Al acceder a esta ruta oculta, serás redirigido a la ruta `/` de la aplicación. Una vez que la cookie haya sido emitida a tu navegador, podrás navegar por la aplicación de manera normal como si no estuviera en modo de mantenimiento.
> [!NOTA]
Tu secreto de modo de mantenimiento debería consistir típicamente en caracteres alfanuméricos y, opcionalmente, guiones. Debes evitar usar caracteres que tengan un significado especial en URLs como `?` o `&`.

<a name="maintenance-mode-on-multiple-servers"></a>
#### Modo de Mantenimiento en Múltiples Servidores

Por defecto, Laravel determina si tu aplicación está en modo de mantenimiento utilizando un sistema basado en archivos. Esto significa que para activar el modo de mantenimiento, se tiene que ejecutar el comando `php artisan down` en cada servidor que aloje tu aplicación.
Alternativamente, Laravel ofrece un método basado en caché para manejar el modo de mantenimiento. Este método requiere ejecutar el comando `php artisan down` en un solo servidor. Para usar este enfoque, modifica la configuración "driver" en el archivo `config/app.php` de tu aplicación a `cache`. Luego, selecciona un `store` de caché que sea accesible por todos tus servidores. Esto asegura que el estado del modo de mantenimiento se mantenga de manera consistente en cada servidor:


```php
'maintenance' => [
    'driver' => 'cache',
    'store' => 'database',
],

```

<a name="pre-rendering-the-maintenance-mode-view"></a>
#### Pre-renderizando la vista del modo de mantenimiento

Si utilizas el comando `php artisan down` durante el despliegue, tus usuarios pueden encontrar errores ocasionales si acceden a la aplicación mientras se están actualizando tus dependencias de Composer u otros componentes de infraestructura. Esto ocurre porque una parte significativa del framework Laravel debe iniciarse para determinar que tu aplicación está en modo de mantenimiento y renderizar la vista de modo de mantenimiento utilizando el motor de plantillas.
Por esta razón, Laravel te permite pre-renderizar una vista de modo de mantenimiento que se devolverá al comienzo del ciclo de solicitud. Esta vista se renderiza antes de que se carguen cualquiera de las dependencias de tu aplicación. Puedes pre-renderizar una plantilla de tu elección utilizando la opción `render` del comando `down`:


```shell
php artisan down --render="errors::503"

```

<a name="redirecting-maintenance-mode-requests"></a>
#### Redirigiendo Solicitudes en Modo de Mantenimiento

Mientras está en modo de mantenimiento, Laravel mostrará la vista de modo de mantenimiento para todas las URL de la aplicación a las que el usuario intente acceder. Si lo desea, puede instruir a Laravel para que redirija todas las solicitudes a una URL específica. Esto se puede lograr utilizando la opción `redirect`. Por ejemplo, es posible que desee redirigir todas las solicitudes a la URI `/`:


```shell
php artisan down --redirect=/

```

<a name="disabling-maintenance-mode"></a>
#### Desactivando el Modo de Mantenimiento

Para desactivar el modo de mantenimiento, utiliza el comando `up`:


```shell
php artisan up

```
> [!NOTE]
Puedes personalizar la plantilla de modo de mantenimiento predeterminada definiendo tu propia plantilla en `resources/views/errors/503.blade.php`.

<a name="maintenance-mode-queues"></a>
#### Modo de Mantenimiento y Colas

Mientras tu aplicación esté en modo de mantenimiento, no se manejarán [tareas en cola](/docs/%7B%7Bversion%7D%7D/queues). Las tareas se seguirán manejando con normalidad una vez que la aplicación salga del modo de mantenimiento.

<a name="alternatives-to-maintenance-mode"></a>
#### Alternativas al Modo de Mantenimiento

Dado que el modo de mantenimiento requiere que tu aplicación tenga varios segundos de inactividad, considera alternativas como [Laravel Vapor](https://vapor.laravel.com) y [Envoyer](https://envoyer.io) para lograr despliegue sin tiempo de inactividad con Laravel.