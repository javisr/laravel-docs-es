# Solicitudes HTTP

- [Introducción](#introduction)
- [Interacción con la Solicitud](#interacting-with-the-request)
  - [Accediendo a la Solicitud](#accessing-the-request)
  - [Ruta de Solicitud, Host y Método](#request-path-and-method)
  - [Encabezados de Solicitud](#request-headers)
  - [Dirección IP de Solicitud](#request-ip-address)
  - [Negociación de Contenido](#content-negotiation)
  - [Solicitudes PSR-7](#psr7-requests)
- [Entrada](#input)
  - [Recuperar Entrada](#retrieving-input)
  - [Presencia de Entrada](#input-presence)
  - [Fusionar Entrada Adicional](#merging-additional-input)
  - [Entrada Antiguo](#old-input)
  - [Cookies](#cookies)
  - [Recorte y Normalización de Entrada](#input-trimming-and-normalization)
- [Archivos](#files)
  - [Recuperar Archivos Subidos](#retrieving-uploaded-files)
  - [Almacenar Archivos Subidos](#storing-uploaded-files)
- [Configurando Proxies de Confianza](#configuring-trusted-proxies)
- [Configurando Hosts de Confianza](#configuring-trusted-hosts)

<a name="introduction"></a>
## Introducción

La clase `Illuminate\Http\Request` de Laravel proporciona una forma orientada a objetos de interactuar con la solicitud HTTP actual que está siendo manejada por tu aplicación, así como de recuperar la entrada, las cookies y los archivos que se enviaron con la solicitud.

<a name="interacting-with-the-request"></a>
## Interactuando Con La Solicitud


<a name="accessing-the-request"></a>
### Accediendo a la Solicitud

Para obtener una instancia de la solicitud HTTP actual a través de la inyección de dependencias, debes indicar la clase `Illuminate\Http\Request` en tu cierre de ruta o método del controlador. La instancia de la solicitud entrante será inyectada automáticamente por el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel:


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * Store a new user.
     */
    public function store(Request $request): RedirectResponse
    {
        $name = $request->input('name');

        // Store the user...

        return redirect('/users');
    }
}
```
Como se mencionó, también puedes indicar el tipo de la clase `Illuminate\Http\Request` en una función anónima de ruta. El contenedor de servicios inyectará automáticamente la solicitud entrante en la función anónima cuando se ejecute:


```php
use Illuminate\Http\Request;

Route::get('/', function (Request $request) {
    // ...
});
```

<a name="dependency-injection-route-parameters"></a>
#### Inyección de Dependencias y Parámetros de Ruta

Si el método de tu controlador también está esperando input de un parámetro de ruta, debes listar tus parámetros de ruta después de tus otras dependencias. Por ejemplo, si tu ruta está definida así:


```php
use App\Http\Controllers\UserController;

Route::put('/user/{id}', [UserController::class, 'update']);
```
Puedes seguir utilizando tipado en `Illuminate\Http\Request` y acceder a tu parámetro de ruta `id` definiendo tu método de controlador de la siguiente manera:


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * Update the specified user.
     */
    public function update(Request $request, string $id): RedirectResponse
    {
        // Update the user...

        return redirect('/users');
    }
}
```

<a name="request-path-and-method"></a>
### Ruta de Solicitud, Host y Método

La instancia `Illuminate\Http\Request` ofrece una variedad de métodos para examinar la solicitud HTTP entrante y extiende la clase `Symfony\Component\HttpFoundation\Request`. Discutiremos algunos de los métodos más importantes a continuación.

<a name="retrieving-the-request-path"></a>
#### Recuperando la Ruta de la Solicitud

El método `path` devuelve la información de la ruta de la solicitud. Así que, si la solicitud entrante está dirigida a `http://example.com/foo/bar`, el método `path` devolverá `foo/bar`:


```php
$uri = $request->path();
```

<a name="inspecting-the-request-path"></a>
#### Inspeccionando la Ruta / Camino de Solicitud

El método `is` te permite verificar que la ruta de solicitud entrante coincide con un patrón dado. Puedes usar el carácter `*` como un comodín al utilizar este método:


```php
if ($request->is('admin/*')) {
    // ...
}
```
Usando el método `routeIs`, puedes determinar si la solicitud entrante ha coincidido con una [ruta nombrada](/docs/%7B%7Bversion%7D%7D/routing#named-routes):


```php
if ($request->routeIs('admin.*')) {
    // ...
}
```

<a name="retrieving-the-request-url"></a>
#### Recuperando la URL de la Solicitud

Para recuperar la URL completa de la solicitud entrante, puedes usar los métodos `url` o `fullUrl`. El método `url` devolverá la URL sin la cadena de consulta, mientras que el método `fullUrl` incluye la cadena de consulta:


```php
$url = $request->url();

$urlWithQueryString = $request->fullUrl();
```
Si deseas añadir datos de cadena de consulta a la URL actual, puedes llamar al método `fullUrlWithQuery`. Este método combina el array dado de variables de cadena de consulta con la cadena de consulta actual:


```php
$request->fullUrlWithQuery(['type' => 'phone']);
```
Si deseas obtener la URL actual sin un parámetro de cadena de consulta dado, puedes utilizar el método `fullUrlWithoutQuery`:


```php
$request->fullUrlWithoutQuery(['type']);

```

<a name="retrieving-the-request-host"></a>
#### Recuperando el Host de la Solicitud

Puedes recuperar el "host" de la solicitud entrante a través de los métodos `host`, `httpHost` y `schemeAndHttpHost`:


```php
$request->host();
$request->httpHost();
$request->schemeAndHttpHost();
```

<a name="retrieving-the-request-method"></a>
#### Recuperando el Método de Solicitud

El método `method` devolverá el verbo HTTP para la solicitud. Puedes usar el método `isMethod` para verificar que el verbo HTTP coincida con una cadena dada:


```php
$method = $request->method();

if ($request->isMethod('post')) {
    // ...
}
```

<a name="request-headers"></a>
### Encabezados de Solicitud

Puedes recuperar un encabezado de solicitud de la instancia `Illuminate\Http\Request` utilizando el método `header`. Si el encabezado no está presente en la solicitud, se devolverá `null`. Sin embargo, el método `header` acepta un segundo argumento opcional que se devolverá si el encabezado no está presente en la solicitud:


```php
$value = $request->header('X-Header-Name');

$value = $request->header('X-Header-Name', 'default');
```
El método `hasHeader` se puede utilizar para determinar si la solicitud contiene un encabezado dado:


```php
if ($request->hasHeader('X-Header-Name')) {
    // ...
}
```
Para conveniencia, se puede usar el método `bearerToken` para recuperar un token de portador del encabezado `Authorization`. Si no se presenta tal encabezado, se devolverá una cadena vacía:


```php
$token = $request->bearerToken();
```

<a name="request-ip-address"></a>
### Solicitar Dirección IP

El método `ip` se puede usar para recuperar la dirección IP del cliente que realizó la solicitud a su aplicación:


```php
$ipAddress = $request->ip();
```
Si desea recuperar un array de direcciones IP, incluyendo todas las direcciones IP del cliente que fueron enviadas por proxies, puede usar el método `ips`. La dirección IP del cliente "original" estará al final del array:


```php
$ipAddresses = $request->ips();
```
En general, las direcciones IP deben considerarse como entradas no confiables y controladas por el usuario, y utilizarse solo con fines informativos.

<a name="content-negotiation"></a>
### Negociación de Contenido

Laravel ofrece varios métodos para inspeccionar los tipos de contenido solicitados de la solicitud entrante a través del encabezado `Accept`. Primero, el método `getAcceptableContentTypes` devolverá un array que contiene todos los tipos de contenido aceptados por la solicitud:


```php
$contentTypes = $request->getAcceptableContentTypes();
```
El método `accepts` acepta un array de tipos de contenido y devuelve `true` si cualquiera de los tipos de contenido es aceptado por la solicitud. De lo contrario, se devolverá `false`:


```php
if ($request->accepts(['text/html', 'application/json'])) {
    // ...
}
```
Puedes usar el método `prefers` para determinar qué tipo de contenido de un array dado de tipos de contenido es el más preferido por la solicitud. Si ninguno de los tipos de contenido proporcionados es aceptado por la solicitud, se devolverá `null`:


```php
$preferred = $request->prefers(['text/html', 'application/json']);
```
Dado que muchas aplicaciones solo sirven HTML o JSON, puedes usar el método `expectsJson` para determinar rápidamente si la solicitud entrante espera una respuesta JSON:


```php
if ($request->expectsJson()) {
    // ...
}
```

<a name="psr7-requests"></a>
### Solicitudes PSR-7

El [estándar PSR-7](https://www.php-fig.org/psr/psr-7/) especifica interfaces para mensajes HTTP, incluidas solicitudes y respuestas. Si deseas obtener una instancia de una solicitud PSR-7 en lugar de una solicitud de Laravel, primero necesitarás instalar algunas bibliotecas. Laravel utiliza el componente *Symfony HTTP Message Bridge* para convertir solicitudes y respuestas típicas de Laravel en implementaciones compatibles con PSR-7:


```shell
composer require symfony/psr-http-message-bridge
composer require nyholm/psr7

```
Una vez que hayas instalado estas bibliotecas, puedes obtener una solicitud PSR-7 haciendo referencia a la interfaz de solicitud en tu cierre de ruta o método de controlador:


```php
use Psr\Http\Message\ServerRequestInterface;

Route::get('/', function (ServerRequestInterface $request) {
    // ...
});
```
> [!NOTA]
Si devuelves una instancia de respuesta PSR-7 desde una ruta o un controlador, se convertirá automáticamente de nuevo en una instancia de respuesta de Laravel y será mostrada por el framework.

<a name="input"></a>
Okay, input the Markdown.\nI will only return the translated text.

<a name="retrieving-input"></a>
### Recuperando Entrada


<a name="retrieving-all-input-data"></a>
#### Recuperando Todos los Datos de Entrada

Puedes recuperar todos los datos de entrada de la solicitud entrante como un `array` utilizando el método `all`. Este método se puede usar independientemente de si la solicitud entrante proviene de un formulario HTML o es una solicitud XHR:


```php
$input = $request->all();
```
Usando el método `collect`, puedes recuperar todos los datos de entrada de la solicitud entrante como una [colección](/docs/%7B%7Bversion%7D%7D/collections):


```php
$input = $request->collect();
```
El método `collect` también te permite recuperar un subconjunto de la entrada de la solicitud entrante como una colección:


```php
$request->collect('users')->each(function (string $user) {
    // ...
});
```

<a name="retrieving-an-input-value"></a>
#### Recuperando un Valor de Entrada

Usando algunos métodos simples, puedes acceder a toda la entrada del usuario desde tu instancia de `Illuminate\Http\Request` sin preocuparte por qué verbo HTTP se utilizó para la solicitud. Independientemente del verbo HTTP, se puede usar el método `input` para obtener la entrada del usuario:


```php
$name = $request->input('name');
```
Puedes pasar un valor por defecto como segundo argumento al método `input`. Este valor se devolverá si el valor de entrada solicitado no está presente en la solicitud:


```php
$name = $request->input('name', 'Sally');
```
Al trabajar con formularios que contienen inputs de array, utiliza la notación de "punto" para acceder a los arrays:


```php
$name = $request->input('products.0.name');

$names = $request->input('products.*.name');
```
Puedes llamar al método `input` sin argumentos para recuperar todos los valores de entrada como un array asociativo:


```php
$input = $request->input();
```

<a name="retrieving-input-from-the-query-string"></a>
#### Recuperando Entrada Desde la Cadena de Consulta

Mientras que el método `input` recupera valores de toda la carga útil de la solicitud (incluando la cadena de consulta), el método `query` solo recuperará valores de la cadena de consulta:


```php
$name = $request->query('name');
```
Si el valor de la cadena de consulta solicitada no está presente, se devolverá el segundo argumento a este método:


```php
$name = $request->query('name', 'Helen');
```
Puedes llamar al método `query` sin argumentos para recuperar todos los valores de la cadena de consulta como un array asociativo:


```php
$query = $request->query();
```

<a name="retrieving-json-input-values"></a>
#### Recuperando Valores de Entrada JSON

Al enviar solicitudes JSON a su aplicación, puede acceder a los datos JSON a través del método `input` siempre que el encabezado `Content-Type` de la solicitud esté configurado correctamente en `application/json`. Incluso puede usar la sintaxis de "punto" para recuperar valores que están anidados dentro de arreglos / objetos JSON:


```php
$name = $request->input('user.name');
```

<a name="retrieving-stringable-input-values"></a>
#### Recuperando Valores de Entrada Stringable

En lugar de recuperar los datos de entrada de la solicitud como una `string` primitiva, puedes usar el método `string` para recuperar los datos de la solicitud como una instancia de [`Illuminate\Support\Stringable`](/docs/%7B%7Bversion%7D%7D/strings):


```php
$name = $request->string('name')->trim();
```

<a name="retrieving-boolean-input-values"></a>
#### Recuperando Valores de Entrada Booleanos

Al tratar con elementos HTML como casillas de verificación, tu aplicación puede recibir valores "truthy" que son en realidad cadenas. Por ejemplo, "true" o "on". Para mayor comodidad, puedes usar el método `boolean` para recuperar estos valores como booleanos. El método `boolean` devuelve `true` para 1, "1", true, "true", "on" y "yes". Todos los demás valores devolverán `false`:


```php
$archived = $request->boolean('archived');
```

<a name="retrieving-date-input-values"></a>
#### Recuperando Valores de Entrada de Fecha

Para mayor comodidad, los valores de entrada que contienen fechas / horas se pueden recuperar como instancias de Carbon utilizando el método `date`. Si la solicitud no contiene un valor de entrada con el nombre dado, se devolverá `null`:


```php
$birthday = $request->date('birthday');
```
Los segundo y tercer argumentos aceptados por el método `date` pueden usarse para especificar el formato y la zona horaria de la fecha, respectivamente:


```php
$elapsed = $request->date('elapsed', '!H:i', 'Europe/Madrid');
```
Si el valor de entrada está presente pero tiene un formato inválido, se lanzará una `InvalidArgumentException`; por lo tanto, se recomienda que valides la entrada antes de invocar el método `date`.

<a name="retrieving-enum-input-values"></a>
#### Recuperando Valores de Entrada de Enum

Los valores de entrada que corresponden a [enums de PHP](https://www.php.net/manual/en/language.types.enumerations.php) también se pueden recuperar de la solicitud. Si la solicitud no contiene un valor de entrada con el nombre dado o el enum no tiene un valor de respaldo que coincida con el valor de entrada, se devolverá `null`. El método `enum` acepta el nombre del valor de entrada y la clase del enum como sus primer y segundo argumentos:


```php
use App\Enums\Status;

$status = $request->enum('status', Status::class);
```

<a name="retrieving-input-via-dynamic-properties"></a>
#### Recuperando Entrada a través de Propiedades Dinámicas

También puedes acceder a la entrada del usuario utilizando propiedades dinámicas en la instancia de `Illuminate\Http\Request`. Por ejemplo, si uno de los formularios de tu aplicación contiene un campo `name`, puedes acceder al valor del campo de la siguiente manera:


```php
$name = $request->name;
```
Al utilizar propiedades dinámicas, Laravel primero buscará el valor del parámetro en la carga útil de la solicitud. Si no está presente, Laravel buscará el campo en los parámetros de la ruta coincidente.

<a name="retrieving-a-portion-of-the-input-data"></a>
#### Recuperando una Porción de los Datos de Entrada

Si necesitas recuperar un subconjunto de los datos de entrada, puedes usar los métodos `only` y `except`. Ambos métodos aceptan un solo `array` o una lista dinámica de argumentos:


```php
$input = $request->only(['username', 'password']);

$input = $request->only('username', 'password');

$input = $request->except(['credit_card']);

$input = $request->except('credit_card');
```
> [!WARNING]
El método `only` devuelve todos los pares clave / valor que solicitas; sin embargo, no devolverá pares clave / valor que no están presentes en la solicitud.

<a name="input-presence"></a>
### Presencia de Entrada

Puedes usar el método `has` para determinar si un valor está presente en la solicitud. El método `has` devuelve `true` si el valor está presente en la solicitud:


```php
if ($request->has('name')) {
    // ...
}
```
Cuando se le proporciona un array, el método `has` determinará si todos los valores especificados están presentes:


```php
if ($request->has(['name', 'email'])) {
    // ...
}
```
El método `hasAny` devuelve `true` si cualquiera de los valores especificados está presente:


```php
if ($request->hasAny(['name', 'email'])) {
    // ...
}
```
El método `whenHas` ejecutará la `función anónima` dada si un valor está presente en la solicitud:


```php
$request->whenHas('name', function (string $input) {
    // ...
});
```
Se puede pasar una segunda `función anónima` al método `whenHas` que se ejecutará si el valor especificado no está presente en la solicitud:


```php
$request->whenHas('name', function (string $input) {
    // The "name" value is present...
}, function () {
    // The "name" value is not present...
});
```
Si deseas determinar si un valor está presente en la solicitud y no es una cadena vacía, puedes usar el método `filled`:


```php
if ($request->filled('name')) {
    // ...
}
```
El método `anyFilled` devuelve `true` si cualquiera de los valores especificados no es una cadena vacía:


```php
if ($request->anyFilled(['name', 'email'])) {
    // ...
}
```
El método `whenFilled` ejecutará la `función anónima` dada si hay un valor presente en la solicitud y no es una cadena vacía:


```php
$request->whenFilled('name', function (string $input) {
    // ...
});
```
Se puede pasar una segunda `función anónima` al método `whenFilled` que se ejecutará si el valor especificado no está "completado":


```php
$request->whenFilled('name', function (string $input) {
    // The "name" value is filled...
}, function () {
    // The "name" value is not filled...
});
```
Para determinar si una clave dada está ausente de la solicitud, puedes usar los métodos `missing` y `whenMissing`:


```php
if ($request->missing('name')) {
    // ...
}

$request->whenMissing('name', function () {
    // The "name" value is missing...
}, function () {
    // The "name" value is present...
});
```

<a name="merging-additional-input"></a>
### Fusionando Entrada Adicional

A veces es posible que necesites fusionar manualmente datos adicionales de entrada en los datos de entrada existentes de la solicitud. Para lograr esto, puedes usar el método `merge`. Si una clave de entrada dada ya existe en la solicitud, será sobrescrita por los datos proporcionados al método `merge`:


```php
$request->merge(['votes' => 0]);
```
El método `mergeIfMissing` se puede utilizar para fusionar la entrada en la solicitud si las claves correspondientes no existen ya dentro de los datos de entrada de la solicitud:


```php
$request->mergeIfMissing(['votes' => 0]);
```

<a name="old-input"></a>
Okay, input the Markdown.\nI will only return the translated text.
Laravel te permite mantener la entrada de una solicitud durante la siguiente solicitud. Esta función es especialmente útil para volver a rellenar formularios después de detectar errores de validación. Sin embargo, si estás utilizando las [funciones de validación](/docs/%7B%7Bversion%7D%7D/validation) incluidas en Laravel, es posible que no necesites usar manualmente estos métodos de almacenamiento de entrada de sesión, ya que algunas de las facilidades de validación integradas de Laravel los llamarán automáticamente.

<a name="flashing-input-to-the-session"></a>
#### Flasheando Entrada a la Sesión

El método `flash` en la clase `Illuminate\Http\Request` hará un "flash" de la entrada actual a la [sesión](/docs/%7B%7Bversion%7D%7D/session) para que esté disponible durante la siguiente solicitud del usuario a la aplicación:


```php
$request->flash();
```
También puedes usar los métodos `flashOnly` y `flashExcept` para almacenar un subconjunto de los datos de la solicitud en la sesión. Estos métodos son útiles para mantener información sensible, como contraseñas, fuera de la sesión:


```php
$request->flashOnly(['username', 'email']);

$request->flashExcept('password');
```

<a name="flashing-input-then-redirecting"></a>
#### Introduciendo Flash y Luego Redirigiendo

Dado que a menudo querrás guardar la entrada en la sesión y luego redirigir a la página anterior, puedes encadenar fácilmente el almacenamiento de la entrada utilizando el método `withInput`:


```php
return redirect('/form')->withInput();

return redirect()->route('user.create')->withInput();

return redirect('/form')->withInput(
    $request->except('password')
);
```

<a name="retrieving-old-input"></a>
#### Recuperando Entrada Anterior

Para recuperar la entrada flash de la solicitud anterior, invoca el método `old` en una instancia de `Illuminate\Http\Request`. El método `old` extraerá los datos de entrada flash previamente almacenados en la [sesión](/docs/%7B%7Bversion%7D%7D/session):


```php
$username = $request->old('username');
```
Laravel también ofrece un helper global `old`. Si estás mostrando entradas antiguas dentro de una [plantilla Blade](/docs/%7B%7Bversion%7D%7D/blade), es más conveniente usar el helper `old` para rellenar de nuevo el formulario. Si no existen entradas antiguas para el campo dado, se devolverá `null`:


```php
<input type="text" name="username" value="{{ old('username') }}">
```

<a name="cookies"></a>
### Cookies


<a name="retrieving-cookies-from-requests"></a>
#### Recuperando Cookies de Solicitudes

Todas las cookies creadas por el framework Laravel están encriptadas y firmadas con un código de autenticación, lo que significa que se considerarán inválidas si han sido modificadas por el cliente. Para recuperar un valor de cookie de la solicitud, utiliza el método `cookie` en una instancia de `Illuminate\Http\Request`:


```php
$value = $request->cookie('name');
```

<a name="input-trimming-and-normalization"></a>
## Recorte y Normalización de Entrada

Por defecto, Laravel incluye el middleware `Illuminate\Foundation\Http\Middleware\TrimStrings` y `Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull` en la pila de middleware global de tu aplicación. Este middleware recortará automáticamente todos los campos de cadena entrantes en la solicitud, así como convertirá cualquier campo de cadena vacío a `null`. Esto te permite no tener que preocuparte por estas preocupaciones de normalización en tus rutas y controladores.
#### Desactivando la Normalización de Entrada

Si deseas deshabilitar este comportamiento para todas las solicitudes, puedes eliminar los dos middleware del stack de middleware de tu aplicación invocando el método `$middleware->remove` en el archivo `bootstrap/app.php` de tu aplicación:


```php
use Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull;
use Illuminate\Foundation\Http\Middleware\TrimStrings;

->withMiddleware(function (Middleware $middleware) {
    $middleware->remove([
        ConvertEmptyStringsToNull::class,
        TrimStrings::class,
    ]);
})
```
Si deseas deshabilitar la eliminación de espacios en blanco y la conversión de cadenas vacías para un subconjunto de solicitudes a tu aplicación, puedes usar los métodos `trimStrings` y `convertEmptyStringsToNull` dentro del archivo `bootstrap/app.php` de tu aplicación. Ambos métodos aceptan un array de funciones anónimas, que deben devolver `true` o `false` para indicar si se debe omitir la normalización de la entrada:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->convertEmptyStringsToNull(except: [
        fn (Request $request) => $request->is('admin/*'),
    ]);

    $middleware->trimStrings(except: [
        fn (Request $request) => $request->is('admin/*'),
    ]);
})
```

<a name="files"></a>
## Archivos


<a name="retrieving-uploaded-files"></a>
### Recuperando Archivos Subidos

Puedes recuperar archivos subidos desde una instancia de `Illuminate\Http\Request` utilizando el método `file` o utilizando propiedades dinámicas. El método `file` devuelve una instancia de la clase `Illuminate\Http\UploadedFile`, que extiende la clase `SplFileInfo` de PHP y proporciona una variedad de métodos para interactuar con el archivo:


```php
$file = $request->file('photo');

$file = $request->photo;
```
Puedes determinar si un archivo está presente en la solicitud utilizando el método `hasFile`:


```php
if ($request->hasFile('photo')) {
    // ...
}
```

<a name="validating-successful-uploads"></a>
#### Validando Cargas Exitosas

Además de verificar si el archivo está presente, también puedes verificar que no hubo problemas al subir el archivo a través del método `isValid`:


```php
if ($request->file('photo')->isValid()) {
    // ...
}
```

<a name="file-paths-extensions"></a>
#### Rutas de Archivos y Extensiones

La clase `UploadedFile` también contiene métodos para acceder a la ruta completamente calificada del archivo y su extensión. El método `extension` intentará adivinar la extensión del archivo en función de su contenido. Esta extensión puede ser diferente de la extensión que fue proporcionada por el cliente:


```php
$path = $request->photo->path();

$extension = $request->photo->extension();
```

<a name="other-file-methods"></a>
#### Otros Métodos de Archivo

Hay una variedad de otros métodos disponibles en las instancias de `UploadedFile`. Consulta la [documentación de la API para la clase](https://github.com/symfony/symfony/blob/6.0/src/Symfony/Component/HttpFoundation/File/UploadedFile.php) para obtener más información sobre estos métodos.

<a name="storing-uploaded-files"></a>
### Almacenando Archivos Subidos

Para almacenar un archivo subido, normalmente usarás uno de tus [sistemas de archivos](/docs/%7B%7Bversion%7D%7D/filesystem) configurados. La clase `UploadedFile` tiene un método `store` que moverá un archivo subido a uno de tus discos, que puede ser una ubicación en tu sistema de archivos local o una ubicación de almacenamiento en la nube como Amazon S3.
El método `store` acepta la ruta donde se debe almacenar el archivo en relación con el directorio raíz configurado del sistema de archivos. Esta ruta no debe contener un nombre de archivo, ya que se generará un ID único automáticamente para servir como el nombre de archivo.
El método `store` también acepta un segundo argumento opcional para el nombre del disco que se debe usar para almacenar el archivo. El método devolverá la ruta del archivo en relación con la raíz del disco:


```php
$path = $request->photo->store('images');

$path = $request->photo->store('images', 's3');
```
Si no deseas que se genere un nombre de archivo automáticamente, puedes usar el método `storeAs`, que acepta la ruta, el nombre de archivo y el nombre del disco como sus argumentos:


```php
$path = $request->photo->storeAs('images', 'filename.jpg');

$path = $request->photo->storeAs('images', 'filename.jpg', 's3');
```
> [!NOTA]
Para obtener más información sobre el almacenamiento de archivos en Laravel, consulta la [documentación completa sobre el almacenamiento de archivos](/docs/%7B%7Bversion%7D%7D/filesystem).

<a name="configuring-trusted-proxies"></a>
## Configurando Proxies de Confianza

Al ejecutar tus aplicaciones detrás de un equilibrador de carga que termina certificados TLS / SSL, es posible que notes que tu aplicación a veces no genera enlaces HTTPS al usar el helper `url`. Típicamente, esto se debe a que tu aplicación está recibiendo tráfico de tu equilibrador de carga en el puerto 80 y no sabe que debe generar enlaces seguros.
Para solucionar esto, puedes habilitar el middleware `Illuminate\Http\Middleware\TrustProxies` que está incluido en tu aplicación Laravel, lo que te permite personalizar rápidamente los balanceadores de carga o proxies que debe confiar tu aplicación. Tus proxies de confianza deben ser especificados utilizando el método `trustProxies` en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->trustProxies(at: [
        '192.168.1.1',
        '10.0.0.0/8',
    ]);
})
```
Además de configurar los proxies de confianza, también puedes configurar los encabezados de proxy que deben ser de confianza:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->trustProxies(headers: Request::HEADER_X_FORWARDED_FOR |
        Request::HEADER_X_FORWARDED_HOST |
        Request::HEADER_X_FORWARDED_PORT |
        Request::HEADER_X_FORWARDED_PROTO |
        Request::HEADER_X_FORWARDED_AWS_ELB
    );
})
```
> [!NOTA]
Si estás utilizando AWS Elastic Load Balancing, el valor de `headers` debe ser `Request::HEADER_X_FORWARDED_AWS_ELB`. Si tu balanceador de carga utiliza el encabezado `Forwarded` estándar de [RFC 7239](https://www.rfc-editor.org/rfc/rfc7239#section-4), el valor de `headers` debe ser `Request::HEADER_FORWARDED`. Para obtener más información sobre las constantes que se pueden usar en el valor de `headers`, consulta la documentación de Symfony sobre [confiar en proxies](https://symfony.com/doc/7.0/deployment/proxies.html).

<a name="trusting-all-proxies"></a>
#### Confiando en Todos los Proxies

Si estás utilizando Amazon AWS u otro proveedor de balanceador de carga "en la nube", es posible que no conozcas las direcciones IP de tus balanceadores reales. En este caso, puedes usar `*` para confiar en todos los proxies:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->trustProxies(at: '*');
})
```

<a name="configuring-trusted-hosts"></a>
## Configuración de Hosts Confiables

Por defecto, Laravel responderá a todas las solicitudes que reciba, independientemente del contenido del encabezado `Host` de la solicitud HTTP. Además, el valor del encabezado `Host` se utilizará al generar URL absolutas a tu aplicación durante una solicitud web.
Normalmente, deberías configurar tu servidor web, como Nginx o Apache, para que solo envíe solicitudes a tu aplicación que coincidan con un hostname dado. Sin embargo, si no tienes la capacidad de personalizar tu servidor web directamente y necesitas instruir a Laravel para que solo responda a ciertos hostnames, puedes hacerlo habilitando el middleware `Illuminate\Http\Middleware\TrustHosts` para tu aplicación.
Para habilitar el middleware `TrustHosts`, debes invocar el método `trustHosts` del middleware en el archivo `bootstrap/app.php` de tu aplicación. Usando el argumento `at` de este método, puedes especificar los nombres de host a los que tu aplicación debe responder. Las solicitudes entrantes con otros encabezados `Host` serán rechazadas:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->trustHosts(at: ['laravel.test']);
})
```
Por defecto, las solicitudes que provienen de subdominios de la URL de la aplicación también son automáticamente confiables. Si deseas desactivar este comportamiento, puedes usar el argumento `subdomains`:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->trustHosts(at: ['laravel.test'], subdomains: false);
})
```
Si necesitas acceder a los archivos de configuración de tu aplicación o a la base de datos para determinar tus hosts de confianza, puedes proporcionar una función anónima al argumento `at`:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->trustHosts(at: fn () => config('app.trusted_hosts'));
})
```