# Almacenamiento de Archivos

- [Introducción](#introduction)
- [Configuración](#configuration)
    - [El Controlador Local](#the-local-driver)
    - [El Disco Público](#the-public-disk)
    - [Requisitos Previos del Controlador](#driver-prerequisites)
    - [Sistemas de Archivos con Alcance y Solo Lectura](#scoped-and-read-only-filesystems)
    - [Sistemas de Archivos Compatibles con Amazon S3](#amazon-s3-compatible-filesystems)
- [Obteniendo Instancias de Disco](#obtaining-disk-instances)
    - [Discos Bajo Demanda](#on-demand-disks)
- [Recuperando Archivos](#retrieving-files)
    - [Descargando Archivos](#downloading-files)
    - [URLs de Archivos](#file-urls)
    - [URLs Temporales](#temporary-urls)
    - [Metadatos de Archivos](#file-metadata)
- [Almacenando Archivos](#storing-files)
    - [Prependiendo y Añadiendo a Archivos](#prepending-appending-to-files)
    - [Copiando y Moviendo Archivos](#copying-moving-files)
    - [Transmisión Automática](#automatic-streaming)
    - [Subidas de Archivos](#file-uploads)
    - [Visibilidad de Archivos](#file-visibility)
- [Eliminando Archivos](#deleting-files)
- [Directorios](#directories)
- [Pruebas](#testing)
- [Sistemas de Archivos Personalizados](#custom-filesystems)

<a name="introduction"></a>
## Introducción

Laravel proporciona una poderosa abstracción de sistema de archivos gracias al maravilloso paquete PHP [Flysystem](https://github.com/thephpleague/flysystem) de Frank de Jonge. La integración de Laravel con Flysystem proporciona controladores simples para trabajar con sistemas de archivos locales, SFTP y Amazon S3. Aún mejor, es increíblemente simple cambiar entre estas opciones de almacenamiento entre tu máquina de desarrollo local y el servidor de producción, ya que la API permanece igual para cada sistema.

<a name="configuration"></a>
## Configuración

El archivo de configuración del sistema de archivos de Laravel se encuentra en `config/filesystems.php`. Dentro de este archivo, puedes configurar todos tus "discos" de sistema de archivos. Cada disco representa un controlador de almacenamiento particular y una ubicación de almacenamiento. Ejemplos de configuraciones para cada controlador soportado están incluidos en el archivo de configuración para que puedas modificar la configuración para reflejar tus preferencias de almacenamiento y credenciales.

El controlador `local` interactúa con archivos almacenados localmente en el servidor que ejecuta la aplicación Laravel, mientras que el controlador `s3` se utiliza para escribir en el servicio de almacenamiento en la nube S3 de Amazon.

> [!NOTE]  
> Puedes configurar tantos discos como desees y incluso puedes tener múltiples discos que utilicen el mismo controlador.

<a name="the-local-driver"></a>
### El Controlador Local

Al usar el controlador `local`, todas las operaciones de archivo son relativas al directorio `root` definido en tu archivo de configuración `filesystems`. Por defecto, este valor se establece en el directorio `storage/app`. Por lo tanto, el siguiente método escribiría en `storage/app/example.txt`:

    use Illuminate\Support\Facades\Storage;

    Storage::disk('local')->put('example.txt', 'Contents');

<a name="the-public-disk"></a>
### El Disco Público

El disco `public` incluido en el archivo de configuración `filesystems` de tu aplicación está destinado a archivos que van a ser accesibles públicamente. Por defecto, el disco `public` utiliza el controlador `local` y almacena sus archivos en `storage/app/public`.

Para hacer que estos archivos sean accesibles desde la web, debes crear un enlace simbólico de `public/storage` a `storage/app/public`. Utilizar esta convención de carpeta mantendrá tus archivos accesibles públicamente en un directorio que puede ser fácilmente compartido a través de implementaciones cuando se utilizan sistemas de implementación sin tiempo de inactividad como [Envoyer](https://envoyer.io).

Para crear el enlace simbólico, puedes usar el comando Artisan `storage:link`:

```shell
php artisan storage:link
```

Una vez que un archivo ha sido almacenado y el enlace simbólico ha sido creado, puedes crear una URL para los archivos usando el helper `asset`:

    echo asset('storage/file.txt');

Puedes configurar enlaces simbólicos adicionales en tu archivo de configuración `filesystems`. Cada uno de los enlaces configurados se creará cuando ejecutes el comando `storage:link`:

    'links' => [
        public_path('storage') => storage_path('app/public'),
        public_path('images') => storage_path('app/images'),
    ],

El comando `storage:unlink` puede ser utilizado para destruir tus enlaces simbólicos configurados:

```shell
php artisan storage:unlink
```

<a name="driver-prerequisites"></a>
### Requisitos Previos del Controlador

<a name="s3-driver-configuration"></a>
#### Configuración del Controlador S3

Antes de usar el controlador S3, necesitarás instalar el paquete Flysystem S3 a través del gestor de paquetes Composer:

```shell
composer require league/flysystem-aws-s3-v3 "^3.0" --with-all-dependencies
```

Un arreglo de configuración de disco S3 se encuentra en tu archivo de configuración `config/filesystems.php`. Típicamente, deberías configurar tu información y credenciales de S3 usando las siguientes variables de entorno que son referenciadas por el archivo de configuración `config/filesystems.php`:

```
AWS_ACCESS_KEY_ID=<your-key-id>
AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=<your-bucket-name>
AWS_USE_PATH_STYLE_ENDPOINT=false
```

Para conveniencia, estas variables de entorno coinciden con la convención de nombres utilizada por la AWS CLI.

<a name="ftp-driver-configuration"></a>
#### Configuración del Controlador FTP

Antes de usar el controlador FTP, necesitarás instalar el paquete Flysystem FTP a través del gestor de paquetes Composer:

```shell
composer require league/flysystem-ftp "^3.0"
```

Las integraciones de Flysystem de Laravel funcionan muy bien con FTP; sin embargo, una configuración de ejemplo no está incluida en el archivo de configuración `config/filesystems.php` por defecto del framework. Si necesitas configurar un sistema de archivos FTP, puedes usar el ejemplo de configuración a continuación:

    'ftp' => [
        'driver' => 'ftp',
        'host' => env('FTP_HOST'),
        'username' => env('FTP_USERNAME'),
        'password' => env('FTP_PASSWORD'),

        // Opcional Configuraciones FTP...
        // 'port' => env('FTP_PORT', 21),
        // 'root' => env('FTP_ROOT'),
        // 'passive' => true,
        // 'ssl' => true,
        // 'timeout' => 30,
    ],

<a name="sftp-driver-configuration"></a>
#### Configuración del Controlador SFTP

Antes de usar el controlador SFTP, necesitarás instalar el paquete Flysystem SFTP a través del gestor de paquetes Composer:

```shell
composer require league/flysystem-sftp-v3 "^3.0"
```

Las integraciones de Flysystem de Laravel funcionan muy bien con SFTP; sin embargo, una configuración de ejemplo no está incluida en el archivo de configuración `config/filesystems.php` por defecto del framework. Si necesitas configurar un sistema de archivos SFTP, puedes usar el ejemplo de configuración a continuación:

    'sftp' => [
        'driver' => 'sftp',
        'host' => env('SFTP_HOST'),

        // Configuraciones para autenticación básica...
        'username' => env('SFTP_USERNAME'),
        'password' => env('SFTP_PASSWORD'),

        // Configuraciones para autenticación basada en clave SSH con contraseña de cifrado...
        'privateKey' => env('SFTP_PRIVATE_KEY'),
        'passphrase' => env('SFTP_PASSPHRASE'),

        // Configuraciones para permisos de archivo / directorio...
        'visibility' => 'private', // `private` = 0600, `public` = 0644
        'directory_visibility' => 'private', // `private` = 0700, `public` = 0755

        // Opcional Configuraciones SFTP...
        // 'hostFingerprint' => env('SFTP_HOST_FINGERPRINT'),
        // 'maxTries' => 4,
        // 'passphrase' => env('SFTP_PASSPHRASE'),
        // 'port' => env('SFTP_PORT', 22),
        // 'root' => env('SFTP_ROOT', ''),
        // 'timeout' => 30,
        // 'useAgent' => true,
    ],

<a name="scoped-and-read-only-filesystems"></a>
### Sistemas de Archivos con Alcance y Solo Lectura

Los discos con alcance te permiten definir un sistema de archivos donde todas las rutas están automáticamente prefijadas con un prefijo de ruta dado. Antes de crear un disco de sistema de archivos con alcance, necesitarás instalar un paquete adicional de Flysystem a través del gestor de paquetes Composer:

```shell
composer require league/flysystem-path-prefixing "^3.0"
```

Puedes crear una instancia de disco con alcance de cualquier disco de sistema de archivos existente definiendo un disco que utilice el controlador `scoped`. Por ejemplo, puedes crear un disco que limite tu disco `s3` existente a un prefijo de ruta específico, y luego cada operación de archivo utilizando tu disco con alcance utilizará el prefijo especificado:

```php
's3-videos' => [
    'driver' => 'scoped',
    'disk' => 's3',
    'prefix' => 'path/to/videos',
],
```

Los discos "solo lectura" te permiten crear discos de sistema de archivos que no permiten operaciones de escritura. Antes de usar la opción de configuración `read-only`, necesitarás instalar un paquete adicional de Flysystem a través del gestor de paquetes Composer:

```shell
composer require league/flysystem-read-only "^3.0"
```

A continuación, puedes incluir la opción de configuración `read-only` en uno o más de los arreglos de configuración de tu disco:

```php
's3-videos' => [
    'driver' => 's3',
    // ...
    'read-only' => true,
],
```

<a name="amazon-s3-compatible-filesystems"></a>
### Sistemas de Archivos Compatibles con Amazon S3

Por defecto, el archivo de configuración `filesystems` de tu aplicación contiene una configuración de disco para el disco `s3`. Además de usar este disco para interactuar con Amazon S3, puedes usarlo para interactuar con cualquier servicio de almacenamiento de archivos compatible con S3, como [MinIO](https://github.com/minio/minio) o [DigitalOcean Spaces](https://www.digitalocean.com/products/spaces/).

Típicamente, después de actualizar las credenciales del disco para que coincidan con las credenciales del servicio que planeas usar, solo necesitas actualizar el valor de la opción de configuración `endpoint`. El valor de esta opción se define típicamente a través de la variable de entorno `AWS_ENDPOINT`:

    'endpoint' => env('AWS_ENDPOINT', 'https://minio:9000'),

<a name="minio"></a>
#### MinIO

Para que la integración de Flysystem de Laravel genere URLs adecuadas al usar MinIO, debes definir la variable de entorno `AWS_URL` para que coincida con la URL local de tu aplicación e incluya el nombre del bucket en la ruta de la URL:

```ini
AWS_URL=http://localhost:9000/local
```

> [!WARNING]  
> Generar URLs de almacenamiento temporales a través del método `temporaryUrl` no es compatible al usar MinIO.

<a name="obtaining-disk-instances"></a>
## Obteniendo Instancias de Disco

El facade `Storage` puede ser utilizado para interactuar con cualquiera de tus discos configurados. Por ejemplo, puedes usar el método `put` en el facade para almacenar un avatar en el disco por defecto. Si llamas a métodos en el facade `Storage` sin primero llamar al método `disk`, el método se pasará automáticamente al disco por defecto:

    use Illuminate\Support\Facades\Storage;

    Storage::put('avatars/1', $content);

Si tu aplicación interactúa con múltiples discos, puedes usar el método `disk` en el facade `Storage` para trabajar con archivos en un disco particular:

    Storage::disk('s3')->put('avatars/1', $content);

<a name="on-demand-disks"></a>
### Discos Bajo Demanda

A veces puedes desear crear un disco en tiempo de ejecución utilizando una configuración dada sin que esa configuración esté realmente presente en el archivo de configuración `filesystems` de tu aplicación. Para lograr esto, puedes pasar un arreglo de configuración al método `build` del facade `Storage`:

```php
use Illuminate\Support\Facades\Storage;

$disk = Storage::build([
    'driver' => 'local',
    'root' => '/path/to/root',
]);

$disk->put('image.jpg', $content);
```

<a name="retrieving-files"></a>
## Recuperando Archivos

El método `get` puede ser utilizado para recuperar el contenido de un archivo. El contenido en forma de cadena cruda del archivo será devuelto por el método. Recuerda, todas las rutas de archivo deben ser especificadas en relación con la ubicación "root" del disco:

    $contents = Storage::get('file.jpg');

Si el archivo que estás recuperando contiene JSON, puedes usar el método `json` para recuperar el archivo y decodificar su contenido:

    $orders = Storage::json('orders.json');

El método `exists` puede ser utilizado para determinar si un archivo existe en el disco:

    if (Storage::disk('s3')->exists('file.jpg')) {
        // ...
    }

El método `missing` puede ser utilizado para determinar si un archivo falta en el disco:

    if (Storage::disk('s3')->missing('file.jpg')) {
        // ...
    }

<a name="downloading-files"></a>
### Descargando Archivos

El método `download` puede ser utilizado para generar una respuesta que fuerce al navegador del usuario a descargar el archivo en la ruta dada. El método `download` acepta un nombre de archivo como segundo argumento del método, que determinará el nombre de archivo que verá el usuario al descargar el archivo. Finalmente, puedes pasar un arreglo de encabezados HTTP como tercer argumento al método:

    return Storage::download('file.jpg');

    return Storage::download('file.jpg', $name, $headers);

<a name="file-urls"></a>
### URLs de Archivos

Puedes usar el método `url` para obtener la URL de un archivo dado. Si estás usando el controlador `local`, esto típicamente solo añadirá `/storage` a la ruta dada y devolverá una URL relativa al archivo. Si estás usando el controlador `s3`, se devolverá la URL remota completamente calificada:

    use Illuminate\Support\Facades\Storage;

    $url = Storage::url('file.jpg');

Al usar el controlador `local`, todos los archivos que deberían ser accesibles públicamente deben ser colocados en el directorio `storage/app/public`. Además, debes [crear un enlace simbólico](#the-public-disk) en `public/storage` que apunte al directorio `storage/app/public`.

> [!WARNING]  
> Al usar el controlador `local`, el valor de retorno de `url` no está codificado en URL. Por esta razón, recomendamos siempre almacenar tus archivos usando nombres que generen URLs válidas.

<a name="url-host-customization"></a>
#### Personalización del Host de URL

Si deseas modificar el host para las URLs generadas usando el facade `Storage`, puedes agregar o cambiar la opción `url` en el arreglo de configuración del disco:

    'public' => [
        'driver' => 'local',
        'root' => storage_path('app/public'),
        'url' => env('APP_URL').'/storage',
        'visibility' => 'public',
        'throw' => false,
    ],

<a name="temporary-urls"></a>
### URLs Temporales

Usando el método `temporaryUrl`, puedes crear URLs temporales para archivos almacenados usando el controlador `s3`. Este método acepta una ruta y una instancia de `DateTime` que especifica cuándo debe expirar la URL:

    use Illuminate\Support\Facades\Storage;

    $url = Storage::temporaryUrl(
        'file.jpg', now()->addMinutes(5)
    );

Si necesitas especificar parámetros adicionales de [solicitud S3](https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGET.html#RESTObjectGET-requests), puedes pasar el arreglo de parámetros de solicitud como tercer argumento al método `temporaryUrl`:

    $url = Storage::temporaryUrl(
        'file.jpg',
        now()->addMinutes(5),
        [
            'ResponseContentType' => 'application/octet-stream',
            'ResponseContentDisposition' => 'attachment; filename=file2.jpg',
        ]
    );

Si necesitas personalizar cómo se crean las URLs temporales para un disco de almacenamiento específico, puedes usar el método `buildTemporaryUrlsUsing`. Por ejemplo, esto puede ser útil si tienes un controlador que permite descargar archivos almacenados a través de un disco que no soporta típicamente URLs temporales. Usualmente, este método debería ser llamado desde el método `boot` de un proveedor de servicios:

    <?php

    namespace App\Providers;

    use DateTime;
    use Illuminate\Support\Facades\Storage;
    use Illuminate\Support\Facades\URL;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Bootstrap any application services.
         */
        public function boot(): void
        {
            Storage::disk('local')->buildTemporaryUrlsUsing(
                function (string $path, DateTime $expiration, array $options) {
                    return URL::temporarySignedRoute(
                        'files.download',
                        $expiration,
                        array_merge($options, ['path' => $path])
                    );
                }
            );
        }
    }

<a name="temporary-upload-urls"></a>
#### URLs de Subida Temporales

> [!WARNING]  
> La capacidad de generar URLs de carga temporales solo es compatible con el controlador `s3`.

Si necesitas generar una URL temporal que se pueda usar para cargar un archivo directamente desde tu aplicación del lado del cliente, puedes usar el método `temporaryUploadUrl`. Este método acepta una ruta y una instancia de `DateTime` que especifica cuándo debe expirar la URL. El método `temporaryUploadUrl` devuelve un array asociativo que puede ser desestructurado en la URL de carga y los encabezados que deben incluirse con la solicitud de carga:

    use Illuminate\Support\Facades\Storage;

    ['url' => $url, 'headers' => $headers] = Storage::temporaryUploadUrl(
        'file.jpg', now()->addMinutes(5)
    );

Este método es principalmente útil en entornos sin servidor que requieren que la aplicación del lado del cliente cargue archivos directamente a un sistema de almacenamiento en la nube como Amazon S3.

<a name="file-metadata"></a>
### Metadatos del Archivo

Además de leer y escribir archivos, Laravel también puede proporcionar información sobre los propios archivos. Por ejemplo, el método `size` se puede usar para obtener el tamaño de un archivo en bytes:

    use Illuminate\Support\Facades\Storage;

    $size = Storage::size('file.jpg');

El método `lastModified` devuelve la marca de tiempo UNIX de la última vez que se modificó el archivo:

    $time = Storage::lastModified('file.jpg');

El tipo MIME de un archivo dado se puede obtener a través del método `mimeType`:

    $mime = Storage::mimeType('file.jpg');

<a name="file-paths"></a>
#### Rutas de Archivos

Puedes usar el método `path` para obtener la ruta de un archivo dado. Si estás usando el controlador `local`, esto devolverá la ruta absoluta al archivo. Si estás usando el controlador `s3`, este método devolverá la ruta relativa al archivo en el bucket de S3:

    use Illuminate\Support\Facades\Storage;

    $path = Storage::path('file.jpg');

<a name="storing-files"></a>
## Almacenamiento de Archivos

El método `put` se puede usar para almacenar el contenido de un archivo en un disco. También puedes pasar un `resource` de PHP al método `put`, que utilizará el soporte de flujo subyacente de Flysystem. Recuerda, todas las rutas de archivos deben especificarse en relación con la ubicación "raíz" configurada para el disco:

    use Illuminate\Support\Facades\Storage;

    Storage::put('file.jpg', $contents);

    Storage::put('file.jpg', $resource);

<a name="failed-writes"></a>
#### Escrituras Fallidas

Si el método `put` (u otras operaciones de "escritura") no puede escribir el archivo en el disco, se devolverá `false`:

    if (! Storage::put('file.jpg', $contents)) {
        // El archivo no se pudo escribir en el disco...
    }

Si lo deseas, puedes definir la opción `throw` dentro del array de configuración del disco de tu sistema de archivos. Cuando esta opción se define como `true`, métodos de "escritura" como `put` lanzarán una instancia de `League\Flysystem\UnableToWriteFile` cuando las operaciones de escritura fallen:

    'public' => [
        'driver' => 'local',
        // ...
        'throw' => true,
    ],

<a name="prepending-appending-to-files"></a>
### Prependiendo y Agregando a Archivos

Los métodos `prepend` y `append` te permiten escribir al principio o al final de un archivo:

    Storage::prepend('file.log', 'Texto Prependido');

    Storage::append('file.log', 'Texto Agregado');

<a name="copying-moving-files"></a>
### Copiando y Moviendo Archivos

El método `copy` se puede usar para copiar un archivo existente a una nueva ubicación en el disco, mientras que el método `move` se puede usar para renombrar o mover un archivo existente a una nueva ubicación:

    Storage::copy('old/file.jpg', 'new/file.jpg');

    Storage::move('old/file.jpg', 'new/file.jpg');

<a name="automatic-streaming"></a>
### Transmisión Automática

Transmitir archivos a almacenamiento ofrece un uso de memoria significativamente reducido. Si deseas que Laravel gestione automáticamente la transmisión de un archivo dado a tu ubicación de almacenamiento, puedes usar el método `putFile` o `putFileAs`. Este método acepta una instancia de `Illuminate\Http\File` o `Illuminate\Http\UploadedFile` y transmitirá automáticamente el archivo a tu ubicación deseada:

    use Illuminate\Http\File;
    use Illuminate\Support\Facades\Storage;

    // Generar automáticamente un ID único para el nombre del archivo...
    $path = Storage::putFile('photos', new File('/path/to/photo'));

    // Especificar manualmente un nombre de archivo...
    $path = Storage::putFileAs('photos', new File('/path/to/photo'), 'photo.jpg');

Hay algunas cosas importantes a tener en cuenta sobre el método `putFile`. Ten en cuenta que solo especificamos un nombre de directorio y no un nombre de archivo. Por defecto, el método `putFile` generará un ID único para servir como el nombre del archivo. La extensión del archivo se determinará examinando el tipo MIME del archivo. La ruta al archivo será devuelta por el método `putFile` para que puedas almacenar la ruta, incluyendo el nombre de archivo generado, en tu base de datos.

Los métodos `putFile` y `putFileAs` también aceptan un argumento para especificar la "visibilidad" del archivo almacenado. Esto es particularmente útil si estás almacenando el archivo en un disco en la nube como Amazon S3 y deseas que el archivo sea accesible públicamente a través de URLs generadas:

    Storage::putFile('photos', new File('/path/to/photo'), 'public');

<a name="file-uploads"></a>
### Cargas de Archivos

En aplicaciones web, uno de los casos de uso más comunes para almacenar archivos es almacenar archivos subidos por el usuario, como fotos y documentos. Laravel facilita mucho el almacenamiento de archivos subidos utilizando el método `store` en una instancia de archivo subido. Llama al método `store` con la ruta en la que deseas almacenar el archivo subido:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Http\Request;

    class UserAvatarController extends Controller
    {
        /**
         * Actualizar el avatar del usuario.
         */
        public function update(Request $request): string
        {
            $path = $request->file('avatar')->store('avatars');

            return $path;
        }
    }

Hay algunas cosas importantes a tener en cuenta sobre este ejemplo. Ten en cuenta que solo especificamos un nombre de directorio, no un nombre de archivo. Por defecto, el método `store` generará un ID único para servir como el nombre del archivo. La extensión del archivo se determinará examinando el tipo MIME del archivo. La ruta al archivo será devuelta por el método `store` para que puedas almacenar la ruta, incluyendo el nombre de archivo generado, en tu base de datos.

También puedes llamar al método `putFile` en la fachada `Storage` para realizar la misma operación de almacenamiento de archivos que el ejemplo anterior:

    $path = Storage::putFile('avatars', $request->file('avatar'));

<a name="specifying-a-file-name"></a>
#### Especificando un Nombre de Archivo

Si no deseas que se asigne automáticamente un nombre de archivo a tu archivo almacenado, puedes usar el método `storeAs`, que recibe la ruta, el nombre del archivo y el disco (opcional) como sus argumentos:

    $path = $request->file('avatar')->storeAs(
        'avatars', $request->user()->id
    );

También puedes usar el método `putFileAs` en la fachada `Storage`, que realizará la misma operación de almacenamiento de archivos que el ejemplo anterior:

    $path = Storage::putFileAs(
        'avatars', $request->file('avatar'), $request->user()->id
    );

> [!WARNING]  
> Los caracteres unicode no imprimibles e inválidos se eliminarán automáticamente de las rutas de archivos. Por lo tanto, es posible que desees sanitizar tus rutas de archivos antes de pasarlas a los métodos de almacenamiento de archivos de Laravel. Las rutas de archivos se normalizan utilizando el método `League\Flysystem\WhitespacePathNormalizer::normalizePath`.

<a name="specifying-a-disk"></a>
#### Especificando un Disco

Por defecto, el método `store` de este archivo subido utilizará tu disco predeterminado. Si deseas especificar otro disco, pasa el nombre del disco como el segundo argumento al método `store`:

    $path = $request->file('avatar')->store(
        'avatars/'.$request->user()->id, 's3'
    );

Si estás usando el método `storeAs`, puedes pasar el nombre del disco como el tercer argumento al método:

    $path = $request->file('avatar')->storeAs(
        'avatars',
        $request->user()->id,
        's3'
    );

<a name="other-uploaded-file-information"></a>
#### Otra Información del Archivo Subido

Si deseas obtener el nombre original y la extensión del archivo subido, puedes hacerlo utilizando los métodos `getClientOriginalName` y `getClientOriginalExtension`:

    $file = $request->file('avatar');

    $name = $file->getClientOriginalName();
    $extension = $file->getClientOriginalExtension();

Sin embargo, ten en cuenta que los métodos `getClientOriginalName` y `getClientOriginalExtension` se consideran inseguros, ya que el nombre y la extensión del archivo pueden ser manipulados por un usuario malicioso. Por esta razón, generalmente deberías preferir los métodos `hashName` y `extension` para obtener un nombre y una extensión para la carga de archivo dada:

    $file = $request->file('avatar');

    $name = $file->hashName(); // Generar un nombre único y aleatorio...
    $extension = $file->extension(); // Determinar la extensión del archivo según el tipo MIME del archivo...

<a name="file-visibility"></a>
### Visibilidad del Archivo

En la integración de Flysystem de Laravel, la "visibilidad" es una abstracción de los permisos de archivo en múltiples plataformas. Los archivos pueden declararse `public` o `private`. Cuando un archivo se declara `public`, estás indicando que el archivo debería ser accesible generalmente para otros. Por ejemplo, al usar el controlador S3, puedes recuperar URLs para archivos `public`.

Puedes establecer la visibilidad al escribir el archivo a través del método `put`:

    use Illuminate\Support\Facades\Storage;

    Storage::put('file.jpg', $contents, 'public');

Si el archivo ya ha sido almacenado, su visibilidad se puede recuperar y establecer a través de los métodos `getVisibility` y `setVisibility`:

    $visibility = Storage::getVisibility('file.jpg');

    Storage::setVisibility('file.jpg', 'public');

Al interactuar con archivos subidos, puedes usar los métodos `storePublicly` y `storePubliclyAs` para almacenar el archivo subido con visibilidad `public`:

    $path = $request->file('avatar')->storePublicly('avatars', 's3');

    $path = $request->file('avatar')->storePubliclyAs(
        'avatars',
        $request->user()->id,
        's3'
    );

<a name="local-files-and-visibility"></a>
#### Archivos Locales y Visibilidad

Al usar el controlador `local`, la [visibilidad](#file-visibility) `public` se traduce en permisos `0755` para directorios y `0644` para archivos. Puedes modificar las asignaciones de permisos en el archivo de configuración `filesystems` de tu aplicación:

    'local' => [
        'driver' => 'local',
        'root' => storage_path('app'),
        'permissions' => [
            'file' => [
                'public' => 0644,
                'private' => 0600,
            ],
            'dir' => [
                'public' => 0755,
                'private' => 0700,
            ],
        ],
        'throw' => false,
    ],

<a name="deleting-files"></a>
## Eliminando Archivos

El método `delete` acepta un solo nombre de archivo o un array de archivos para eliminar:

    use Illuminate\Support\Facades\Storage;

    Storage::delete('file.jpg');

    Storage::delete(['file.jpg', 'file2.jpg']);

Si es necesario, puedes especificar el disco del que se debe eliminar el archivo:

    use Illuminate\Support\Facades\Storage;

    Storage::disk('s3')->delete('path/file.jpg');

<a name="directories"></a>
## Directorios

<a name="get-all-files-within-a-directory"></a>
#### Obtener Todos los Archivos Dentro de un Directorio

El método `files` devuelve un array de todos los archivos en un directorio dado. Si deseas recuperar una lista de todos los archivos dentro de un directorio dado, incluyendo todos los subdirectorios, puedes usar el método `allFiles`:

    use Illuminate\Support\Facades\Storage;

    $files = Storage::files($directory);

    $files = Storage::allFiles($directory);

<a name="get-all-directories-within-a-directory"></a>
#### Obtener Todos los Directorios Dentro de un Directorio

El método `directories` devuelve un array de todos los directorios dentro de un directorio dado. Además, puedes usar el método `allDirectories` para obtener una lista de todos los directorios dentro de un directorio dado y todos sus subdirectorios:

    $directories = Storage::directories($directory);

    $directories = Storage::allDirectories($directory);

<a name="create-a-directory"></a>
#### Crear un Directorio

El método `makeDirectory` creará el directorio dado, incluyendo cualquier subdirectorio necesario:

    Storage::makeDirectory($directory);

<a name="delete-a-directory"></a>
#### Eliminar un Directorio

Finalmente, el método `deleteDirectory` se puede usar para eliminar un directorio y todos sus archivos:

    Storage::deleteDirectory($directory);

<a name="testing"></a>
## Pruebas

El método `fake` de la fachada `Storage` te permite generar fácilmente un disco falso que, combinado con las utilidades de generación de archivos de la clase `Illuminate\Http\UploadedFile`, simplifica enormemente la prueba de cargas de archivos. Por ejemplo:

```php tab=Pest
<?php

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

test('albums can be uploaded', function () {
    Storage::fake('photos');

    $response = $this->json('POST', '/photos', [
        UploadedFile::fake()->image('photo1.jpg'),
        UploadedFile::fake()->image('photo2.jpg')
    ]);

    // Assert one or more files were stored...
    Storage::disk('photos')->assertExists('photo1.jpg');
    Storage::disk('photos')->assertExists(['photo1.jpg', 'photo2.jpg']);

    // Assert one or more files were not stored...
    Storage::disk('photos')->assertMissing('missing.jpg');
    Storage::disk('photos')->assertMissing(['missing.jpg', 'non-existing.jpg']);

    // Assert that a given directory is empty...
    Storage::disk('photos')->assertDirectoryEmpty('/wallpapers');
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_albums_can_be_uploaded(): void
    {
        Storage::fake('photos');

        $response = $this->json('POST', '/photos', [
            UploadedFile::fake()->image('photo1.jpg'),
            UploadedFile::fake()->image('photo2.jpg')
        ]);

        // Assert one or more files were stored...
        Storage::disk('photos')->assertExists('photo1.jpg');
        Storage::disk('photos')->assertExists(['photo1.jpg', 'photo2.jpg']);

        // Assert one or more files were not stored...
        Storage::disk('photos')->assertMissing('missing.jpg');
        Storage::disk('photos')->assertMissing(['missing.jpg', 'non-existing.jpg']);

        // Assert that a given directory is empty...
        Storage::disk('photos')->assertDirectoryEmpty('/wallpapers');
    }
}
```

Por defecto, el método `fake` eliminará todos los archivos en su directorio temporal. Si deseas conservar estos archivos, puedes usar el método "persistentFake" en su lugar. Para obtener más información sobre la prueba de cargas de archivos, puedes consultar la [documentación de pruebas HTTP sobre cargas de archivos](/docs/{{version}}/http-tests#testing-file-uploads).

> [!WARNING]  
> El método `image` requiere la [extensión GD](https://www.php.net/manual/en/book.image.php).

<a name="custom-filesystems"></a>
## Sistemas de Archivos Personalizados

La integración de Flysystem de Laravel proporciona soporte para varios "controladores" de forma predeterminada; sin embargo, Flysystem no se limita a estos y tiene adaptadores para muchos otros sistemas de almacenamiento. Puedes crear un controlador personalizado si deseas usar uno de estos adaptadores adicionales en tu aplicación Laravel.

Para definir un sistema de archivos personalizado necesitarás un adaptador de Flysystem. Agreguemos un adaptador de Dropbox mantenido por la comunidad a nuestro proyecto:

```shell
composer require spatie/flysystem-dropbox
```

A continuación, puedes registrar el controlador dentro del método `boot` de uno de los [proveedores de servicios](https://laravel.com/docs/{{version}}/providers) de tu aplicación. Para lograr esto, debes usar el método `extend` de la fachada `Storage`:

    <?php

    namespace App\Providers;

    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Filesystem\FilesystemAdapter;
    use Illuminate\Support\Facades\Storage;
    use Illuminate\Support\ServiceProvider;
    use League\Flysystem\Filesystem;
    use Spatie\Dropbox\Client as DropboxClient;
    use Spatie\FlysystemDropbox\DropboxAdapter;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Registrar cualquier servicio de la aplicación.
         */
        public function register(): void
        {
            // ...
        }

        /**
         * Inicializar cualquier servicio de la aplicación.
         */
        public function boot(): void
        {
            Storage::extend('dropbox', function (Application $app, array $config) {
                $adapter = new DropboxAdapter(new DropboxClient(
                    $config['authorization_token']
                ));

                return new FilesystemAdapter(
                    new Filesystem($adapter, $config),
                    $adapter,
                    $config
                );
            });
        }
    }

El primer argumento del método `extend` es el nombre del controlador y el segundo es una función anónima que recibe las variables `$app` y `$config`. La función anónima debe devolver una instancia de `Illuminate\Filesystem\FilesystemAdapter`. La variable `$config` contiene los valores definidos en `config/filesystems.php` para el disco especificado.

Una vez que hayas creado y registrado el proveedor de servicios de la extensión, puedes usar el controlador `dropbox` en tu archivo de configuración `config/filesystems.php`.
