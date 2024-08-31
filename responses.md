# Respuestas HTTP

- [Creando Respuestas](#creating-responses)
  - [Adjuntando Encabezados a las Respuestas](#attaching-headers-to-responses)
  - [Adjuntando Cookies a las Respuestas](#attaching-cookies-to-responses)
  - [Cookies y Encriptación](#cookies-and-encryption)
- [Redirecciones](#redirects)
  - [Redirigiendo a Rutas Nombradas](#redirecting-named-routes)
  - [Redirigiendo a Acciones de Controlador](#redirecting-controller-actions)
  - [Redirigiendo a Dominios Externos](#redirecting-external-domains)
  - [Redirigiendo con Datos de Sesión Flasheados](#redirecting-with-flashed-session-data)
- [Otros Tipos de Respuesta](#other-response-types)
  - [Respuestas de Vista](#view-responses)
  - [Respuestas JSON](#json-responses)
  - [Descargas de Archivos](#file-downloads)
  - [Respuestas de Archivos](#file-responses)
- [Macros de Respuesta](#response-macros)

<a name="creating-responses"></a>
## Creando Respuestas


<a name="strings-arrays"></a>
#### Cadenas y Arreglos

Todas las rutas y controladores deben devolver una respuesta que se envíe de vuelta al navegador del usuario. Laravel ofrece varias formas diferentes de devolver respuestas. La respuesta más básica es devolver una cadena desde una ruta o controlador. El framework convertirá automáticamente la cadena en una respuesta HTTP completa:


```php
Route::get('/', function () {
    return 'Hello World';
});
```
Además de devolver cadenas desde tus rutas y controladores, también puedes devolver arrays. El framework convertirá automáticamente el array en una respuesta JSON:


```php
Route::get('/', function () {
    return [1, 2, 3];
});
```
> [!NOTA]
¿Sabías que también puedes devolver [colecciones Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent-collections) desde tus rutas o controladores? Se convertirán automáticamente a JSON. ¡Inténtalo!

<a name="response-objects"></a>
#### Objetos de Respuesta

Normalmente, no estarás devolviendo solo cadenas simples o arrays desde las acciones de tu ruta. En su lugar, estarás devolviendo instancias completas de `Illuminate\Http\Response` o [vistas](/docs/%7B%7Bversion%7D%7D/views).
Devolver una instancia completa de `Response` te permite personalizar el código de estado HTTP y los encabezados de la respuesta. Una instancia de `Response` hereda de la clase `Symfony\Component\HttpFoundation\Response`, que proporciona una variedad de métodos para construir respuestas HTTP:


```php
Route::get('/home', function () {
    return response('Hello World', 200)
                  ->header('Content-Type', 'text/plain');
});
```

<a name="eloquent-models-and-collections"></a>
#### Modelos y Colecciones Eloquent

También puedes devolver modelos y colecciones de [Eloquent ORM](/docs/%7B%7Bversion%7D%7D/eloquent) directamente desde tus rutas y controladores. Cuando lo haces, Laravel convertirá automáticamente los modelos y colecciones en respuestas JSON mientras respeta los [atributos ocultos](/docs/%7B%7Bversion%7D%7D/eloquent-serialization#hiding-attributes-from-json) del modelo:


```php
use App\Models\User;

Route::get('/user/{user}', function (User $user) {
    return $user;
});
```

<a name="attaching-headers-to-responses"></a>
### Adjuntando Encabezados a Respuestas

Ten en cuenta que la mayoría de los métodos de respuesta son encadenables, lo que permite la construcción fluida de instancias de respuesta. Por ejemplo, puedes usar el método `header` para agregar una serie de encabezados a la respuesta antes de enviarla de vuelta al usuario:


```php
return response($content)
            ->header('Content-Type', $type)
            ->header('X-Header-One', 'Header Value')
            ->header('X-Header-Two', 'Header Value');
```
O bien, puedes usar el método `withHeaders` para especificar un array de encabezados que se añadirán a la respuesta:


```php
return response($content)
            ->withHeaders([
                'Content-Type' => $type,
                'X-Header-One' => 'Header Value',
                'X-Header-Two' => 'Header Value',
            ]);
```

<a name="cache-control-middleware"></a>
#### Middleware de Control de Caché

Laravel incluye un middleware `cache.headers`, que se puede usar para establecer rápidamente el encabezado `Cache-Control` para un grupo de rutas. Las directivas deben proporcionarse utilizando el equivalente en "snake case" de la directiva de control de caché correspondiente y deben estar separadas por un punto y coma. Si `etag` se especifica en la lista de directivas, un hash MD5 del contenido de la respuesta se establecerá automáticamente como el identificador ETag:


```php
Route::middleware('cache.headers:public;max_age=2628000;etag')->group(function () {
    Route::get('/privacy', function () {
        // ...
    });

    Route::get('/terms', function () {
        // ...
    });
});
```

<a name="attaching-cookies-to-responses"></a>
### Adjuntando Cookies a las Respuestas

Puedes adjuntar una cookie a una instancia saliente de `Illuminate\Http\Response` utilizando el método `cookie`. Debes pasar el nombre, el valor y el número de minutos que la cookie debe considerarse válida a este método:


```php
return response('Hello World')->cookie(
    'name', 'value', $minutes
);
```
El método `cookie` también acepta algunos argumentos más que se utilizan con menos frecuencia. En general, estos argumentos tienen el mismo propósito y significado que los argumentos que se darían al método nativo [setcookie](https://secure.php.net/manual/en/function.setcookie.php) de PHP:


```php
return response('Hello World')->cookie(
    'name', 'value', $minutes, $path, $domain, $secure, $httpOnly
);
```
Si deseas asegurarte de que se envíe una cookie con la respuesta saliente pero aún no tienes una instancia de esa respuesta, puedes usar la facade `Cookie` para "enviar en cola" cookies que se adjuntarán a la respuesta cuando se envíe. El método `queue` acepta los argumentos necesarios para crear una instancia de cookie. Estas cookies se adjuntarán a la respuesta saliente antes de enviarse al navegador:


```php
use Illuminate\Support\Facades\Cookie;

Cookie::queue('name', 'value', $minutes);
```

<a name="generating-cookie-instances"></a>
#### Generando Instancias de Cookie

Si deseas generar una instancia de `Symfony\Component\HttpFoundation\Cookie` que se pueda adjuntar a una instancia de respuesta en un momento posterior, puedes usar el helper global `cookie`. Esta cookie no será enviada de vuelta al cliente a menos que esté adjunta a una instancia de respuesta:


```php
$cookie = cookie('name', 'value', $minutes);

return response('Hello World')->cookie($cookie);
```

<a name="expiring-cookies-early"></a>
#### Expirando Cookies Anticipadamente

Puedes eliminar una cookie expirándola a través del método `withoutCookie` de una respuesta saliente:


```php
return response('Hello World')->withoutCookie('name');
```
Si aún no tienes una instancia de la respuesta saliente, puedes usar el método `expire` de la facade `Cookie` para hacer que una cookie expire:


```php
Cookie::expire('name');
```

<a name="cookies-and-encryption"></a>
### Cookies y Cifrado

Por defecto, gracias al middleware `Illuminate\Cookie\Middleware\EncryptCookies`, todas las cookies generadas por Laravel están encriptadas y firmadas para que no puedan ser modificadas o leídas por el cliente. Si deseas desactivar la encriptación para un subconjunto de cookies generadas por tu aplicación, puedes usar el método `encryptCookies` en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->encryptCookies(except: [
        'cookie_name',
    ]);
})
```

<a name="redirects"></a>
## Redirecciones

Las respuestas de redireccionamiento son instancias de la clase `Illuminate\Http\RedirectResponse`, y contienen los encabezados adecuados necesarios para redirigir al usuario a otra URL. Hay varias formas de generar una instancia de `RedirectResponse`. El método más simple es usar el helper global `redirect`:


```php
Route::get('/dashboard', function () {
    return redirect('/home/dashboard');
});
```
A veces es posible que desees redirigir al usuario a su ubicación anterior, como cuando un formulario enviado no es válido. Puedes hacerlo utilizando la función auxiliar global `back`. Dado que esta función utiliza la [sesión](/docs/%7B%7Bversion%7D%7D/session), asegúrate de que la ruta que llama a la función `back` esté utilizando el grupo de middleware `web`:


```php
Route::post('/user/profile', function () {
    // Validate the request...

    return back()->withInput();
});
```

<a name="redirecting-named-routes"></a>
### Redirigiendo a Rutas Nombradas

Cuando llamas al helper `redirect` sin parámetros, se devuelve una instancia de `Illuminate\Routing\Redirector`, lo que te permite llamar a cualquier método en la instancia del `Redirector`. Por ejemplo, para generar un `RedirectResponse` a una ruta nombrada, puedes usar el método `route`:


```php
return redirect()->route('login');
```
Si tu ruta tiene parámetros, puedes pasarlos como segundo argumento al método `route`:


```php
// For a route with the following URI: /profile/{id}

return redirect()->route('profile', ['id' => 1]);
```

<a name="populating-parameters-via-eloquent-models"></a>
#### Poblando Parámetros a través de Modelos Eloquent

Si estás redirigiendo a una ruta con un parámetro "ID" que se está poblando desde un modelo Eloquent, puedes pasar el modelo en sí. El ID se extraerá automáticamente:


```php
// For a route with the following URI: /profile/{id}

return redirect()->route('profile', [$user]);
```
Si deseas personalizar el valor que se coloca en el parámetro de la ruta, puedes especificar la columna en la definición del parámetro de ruta (`/profile/{id:slug}`) o puedes sobrescribir el método `getRouteKey` en tu modelo Eloquent:


```php
/**
 * Get the value of the model's route key.
 */
public function getRouteKey(): mixed
{
    return $this->slug;
}
```

<a name="redirecting-controller-actions"></a>
### Redirigiendo a Acciones del Controlador

También puedes generar redireccionamientos a [acciones del controlador](/docs/%7B%7Bversion%7D%7D/controllers). Para hacerlo, pasa el nombre del controlador y de la acción al método `action`:


```php
use App\Http\Controllers\UserController;

return redirect()->action([UserController::class, 'index']);
```
Si la ruta de tu controlador requiere parámetros, puedes pasarlos como segundo argumento al método `action`:


```php
return redirect()->action(
    [UserController::class, 'profile'], ['id' => 1]
);
```

<a name="redirecting-external-domains"></a>
### Redirigiendo a Dominios Externos

A veces es posible que necesites redirigir a un dominio fuera de tu aplicación. Puedes hacerlo llamando al método `away`, que crea una `RedirectResponse` sin ninguna codificación de URL adicional, validación o verificación:


```php
return redirect()->away('https://www.google.com');
```

<a name="redirecting-with-flashed-session-data"></a>
### Redireccionando con Datos de Sesión Flasheados

Redirigir a una nueva URL y [flashear datos a la sesión](/docs/%7B%7Bversion%7D%7D/session#flash-data) suelen hacerse al mismo tiempo. Típicamente, esto se hace después de realizar exitosamente una acción cuando flasheas un mensaje de éxito a la sesión. Para mayor comodidad, puedes crear una instancia de `RedirectResponse` y flashear datos a la sesión en una sola cadena de métodos fluentes:


```php
Route::post('/user/profile', function () {
    // ...

    return redirect('/dashboard')->with('status', 'Profile updated!');
});
```
Después de que el usuario sea redirigido, puedes mostrar el mensaje de flash de la [sesión](/docs/%7B%7Bversion%7D%7D/session). Por ejemplo, utilizando [sintaxis de Blade](/docs/%7B%7Bversion%7D%7D/blade):


```php
@if (session('status'))
    <div class="alert alert-success">
        {{ session('status') }}
    </div>
@endif
```

<a name="redirecting-with-input"></a>
#### Redirigiendo Con Entrada

Puedes usar el método `withInput` proporcionado por la instancia `RedirectResponse` para almacenar los datos de entrada de la solicitud actual en la sesión antes de redirigir al usuario a una nueva ubicación. Esto se hace típicamente si el usuario ha encontrado un error de validación. Una vez que los datos de entrada se han almacenado en la sesión, puedes [recuperarlos](/docs/%7B%7Bversion%7D%7D/requests#retrieving-old-input) durante la siguiente solicitud para repoblar el formulario:


```php
return back()->withInput();
```

<a name="other-response-types"></a>
## Otros Tipos de Respuesta

El helper `response` se puede utilizar para generar otros tipos de instancias de respuesta. Cuando se llama al helper `response` sin argumentos, se devuelve una implementación del contrato `Illuminate\Contracts\Routing\ResponseFactory` [contract](/docs/%7B%7Bversion%7D%7D/contracts). Este contrato proporciona varios métodos útiles para generar respuestas.

<a name="view-responses"></a>
### Ver Respuestas

Si necesitas controlar el estado y los encabezados de la respuesta pero también necesitas devolver una [vista](/docs/%7B%7Bversion%7D%7D/views) como el contenido de la respuesta, debes usar el método `view`:


```php
return response()
            ->view('hello', $data, 200)
            ->header('Content-Type', $type);
```
Por supuesto, si no necesitas pasar un código de estado HTTP personalizado o encabezados personalizados, puedes usar la función auxiliar global `view`.

<a name="json-responses"></a>
### Respuestas JSON

El método `json` establecerá automáticamente el encabezado `Content-Type` en `application/json`, así como convertir el array dado a JSON utilizando la función `json_encode` de PHP:


```php
return response()->json([
    'name' => 'Abigail',
    'state' => 'CA',
]);
```
Si deseas crear una respuesta JSONP, puedes usar el método `json` en combinación con el método `withCallback`:


```php
return response()
            ->json(['name' => 'Abigail', 'state' => 'CA'])
            ->withCallback($request->input('callback'));
```

<a name="file-downloads"></a>
### Descargas de Archivos

El método `download` se puede utilizar para generar una respuesta que obligue al navegador del usuario a descargar el archivo en la ruta dada. El método `download` acepta un nombre de archivo como segundo argumento del método, que determinará el nombre de archivo que verá el usuario al descargar el archivo. Finalmente, puedes pasar un array de encabezados HTTP como tercer argumento al método:


```php
return response()->download($pathToFile);

return response()->download($pathToFile, $name, $headers);
```
> [!WARNING]
Symfony HttpFoundation, que gestiona las descargas de archivos, requiere que el archivo que se está descargando tenga un nombre de archivo ASCII.

<a name="streamed-downloads"></a>
#### Descargas en Streaming

A veces es posible que desees convertir la respuesta de cadena de una operación dada en una respuesta descargable sin tener que escribir el contenido de la operación en el disco. Puedes usar el método `streamDownload` en este escenario. Este método acepta un callback, un nombre de archivo y un array opcional de encabezados como sus argumentos:


```php
use App\Services\GitHub;

return response()->streamDownload(function () {
    echo GitHub::api('repo')
                ->contents()
                ->readme('laravel', 'laravel')['contents'];
}, 'laravel-readme.md');
```

<a name="file-responses"></a>
### Respuestas de Archivo

El método `file` puede utilizarse para mostrar un archivo, como una imagen o un PDF, directamente en el navegador del usuario en lugar de iniciar una descarga. Este método acepta la ruta absoluta al archivo como su primer argumento y un array de encabezados como su segundo argumento:


```php
return response()->file($pathToFile);

return response()->file($pathToFile, $headers);
```

<a name="response-macros"></a>
## Macros de Respuesta

Si deseas definir una respuesta personalizada que puedas reutilizar en varias de tus rutas y controladores, puedes usar el método `macro` en la fachada `Response`. Típicamente, debes llamar a este método desde el método `boot` de uno de los [proveedores de servicios](/docs/%7B%7Bversion%7D%7D/providers) de tu aplicación, como el proveedor de servicios `App\Providers\AppServiceProvider`:


```php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\Response;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Response::macro('caps', function (string $value) {
            return Response::make(strtoupper($value));
        });
    }
}
```
La función `macro` acepta un nombre como su primer argumento y una función anónima como su segundo argumento. La función anónima del macro se ejecutará al llamar al nombre del macro desde una implementación de `ResponseFactory` o el helper `response`:


```php
return response()->caps('foo');
```