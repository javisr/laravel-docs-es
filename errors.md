# Manejo de Errores

- [Introducción](#introduction)
- [Configuración](#configuration)
- [Manejo de Excepciones](#handling-exceptions)
  - [Reportar Excepciones](#reporting-exceptions)
  - [Niveles de Registro de Excepciones](#exception-log-levels)
  - [Ignorar Excepciones por Tipo](#ignoring-exceptions-by-type)
  - [Renderizar Excepciones](#rendering-exceptions)
  - [Excepciones Reportables y Renderizables](#renderable-exceptions)
- [Limitar Excepciones Reportadas](#throttling-reported-exceptions)
- [Excepciones HTTP](#http-exceptions)
  - [Páginas de Error HTTP Personalizadas](#custom-http-error-pages)

<a name="introduction"></a>
## Introducción

Cuando inicias un nuevo proyecto Laravel, el manejo de errores y excepciones ya está configurado para ti; sin embargo, en cualquier momento, puedes usar el método `withExceptions` en el archivo `bootstrap/app.php` de tu aplicación para gestionar cómo se informan y se muestran las excepciones en tu aplicación.
El objeto `$exceptions` proporcionado a la función anónima `withExceptions` es una instancia de `Illuminate\Foundation\Configuration\Exceptions` y es responsable de gestionar el manejo de excepciones en tu aplicación. Profundizaremos en este objeto a lo largo de esta documentación.

<a name="configuration"></a>
## Configuración

La opción `debug` en tu archivo de configuración `config/app.php` determina cuánta información sobre un error se muestra realmente al usuario. Por defecto, esta opción está configurada para respetar el valor de la variable de entorno `APP_DEBUG`, que se almacena en tu archivo `.env`.
Durante el desarrollo local, deberías configurar la variable de entorno `APP_DEBUG` en `true`. **En tu entorno de producción, este valor siempre debe ser `false`. Si el valor se establece en `true` en producción, corres el riesgo de exponer valores de configuración sensibles a los usuarios finales de tu aplicación.**

<a name="handling-exceptions"></a>
## Manejo de Excepciones


<a name="reporting-exceptions"></a>
### Informando Excepciones

En Laravel, el reporte de excepciones se utiliza para registrar excepciones o enviarlas a un servicio externo [Sentry](https://github.com/getsentry/sentry-laravel) o [Flare](https://flareapp.io). Por defecto, las excepciones se registrarán según tu configuración de [logging](/docs/%7B%7Bversion%7D%7D/logging). Sin embargo, puedes registrar excepciones como desees.
Si necesitas reportar diferentes tipos de excepciones de diversas maneras, puedes usar el método de excepción `report` en el `bootstrap/app.php` de tu aplicación para registrar una función anónima que se debe ejecutar cuando se necesita reportar una excepción de un tipo dado. Laravel determinará qué tipo de excepción reporta la función anónima examinando el tipo de indicación de la función anónima:


```php
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->report(function (InvalidOrderException $e) {
        // ...
    });
})
```
Cuando registras un callback de reporte de excepciones personalizado utilizando el método `report`, Laravel seguirá registrando la excepción utilizando la configuración de registro predeterminada para la aplicación. Si deseas detener la propagación de la excepción a la pila de registro predeterminada, puedes usar el método `stop` al definir tu callback de reporte o retornar `false` desde el callback:


```php
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->report(function (InvalidOrderException $e) {
        // ...
    })->stop();

    $exceptions->report(function (InvalidOrderException $e) {
        return false;
    });
})
```
> [!NOTA]
Para personalizar el reporte de excepciones para una excepción dada, también puedes utilizar [excepciones reportables](/docs/%7B%7Bversion%7D%7D/errors#renderable-exceptions).

<a name="global-log-context"></a>
#### Contexto de Registro Global

Si está disponible, Laravel añade automáticamente el ID del usuario actual a cada mensaje de registro de excepción como datos contextuales. Puedes definir tus propios datos contextuales globales utilizando el método `context` de la excepción en el archivo `bootstrap/app.php` de tu aplicación. Esta información se incluirá en cada mensaje de registro de excepción escrito por tu aplicación:


```php
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->context(fn () => [
        'foo' => 'bar',
    ]);
})
```

<a name="exception-log-context"></a>
#### Contexto del Registro de Excepciones

Aunque añadir contexto a cada mensaje de registro puede ser útil, a veces una excepción particular puede tener un contexto único que te gustaría incluir en tus registros. Al definir un método `context` en una de las excepciones de tu aplicación, puedes especificar cualquier dato relevante a esa excepción que deba añadirse a la entrada de registro de la excepción:


```php
<?php

namespace App\Exceptions;

use Exception;

class InvalidOrderException extends Exception
{
    // ...

    /**
     * Get the exception's context information.
     *
     * @return array<string, mixed>
     */
    public function context(): array
    {
        return ['order_id' => $this->orderId];
    }
}
```

<a name="the-report-helper"></a>
#### El Helper `report`

A veces es posible que necesites informar una excepción pero continuar manejando la solicitud actual. La función auxiliar `report` te permite informar rápidamente una excepción sin renderizar una página de error para el usuario:


```php
public function isValid(string $value): bool
{
    try {
        // Validate the value...
    } catch (Throwable $e) {
        report($e);

        return false;
    }
}
```

<a name="deduplicating-reported-exceptions"></a>
#### Dedupliando Excepciones Reportadas

Si estás utilizando la función `report` en toda tu aplicación, es posible que ocasionalmente informes la misma excepción varias veces, creando entradas duplicadas en tus registros.
Si deseas asegurarte de que una sola instancia de una excepción se informe una sola vez, puedes invocar el método de excepción `dontReportDuplicates` en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->dontReportDuplicates();
})
```
Ahora, cuando se llama al helper `report` con la misma instancia de una excepción, solo se informará la primera llamada:


```php
$original = new RuntimeException('Whoops!');

report($original); // reported

try {
    throw $original;
} catch (Throwable $caught) {
    report($caught); // ignored
}

report($original); // ignored
report($caught); // ignored

```

<a name="exception-log-levels"></a>
### Niveles de Log de Excepción

Cuando se escriben mensajes en los [registros](/docs/%7B%7Bversion%7D%7D/logging) de tu aplicación, los mensajes se escriben en un [nivel de registro](/docs/%7B%7Bversion%7D%7D/logging#log-levels) especificado, que indica la gravedad o importancia del mensaje que se está registrando.
Como se mencionó anteriormente, incluso cuando registras un callback de reporte de excepciones personalizado utilizando el método `report`, Laravel seguirá registrando la excepción utilizando la configuración de registro predeterminada para la aplicación; sin embargo, dado que el nivel de registro a veces puede influir en los canales en los que se registra un mensaje, puede que desees configurar el nivel de registro en el que se registran ciertas excepciones.
Para lograr esto, puedes usar el método de excepción `level` en el archivo `bootstrap/app.php` de tu aplicación. Este método recibe el tipo de excepción como primer argumento y el nivel de registro como segundo argumento:


```php
use PDOException;
use Psr\Log\LogLevel;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->level(PDOException::class, LogLevel::CRITICAL);
})
```

<a name="ignoring-exceptions-by-type"></a>
### Ignorando Excepciones por Tipo

Al construir tu aplicación, habrá ciertos tipos de excepciones que nunca querrás reportar. Para ignorar estas excepciones, puedes usar el método de excepción `dontReport` en el archivo `bootstrap/app.php` de tu aplicación. Cualquier clase proporcionada a este método nunca será reportada; sin embargo, aún pueden tener lógica de renderizado personalizada:


```php
use App\Exceptions\InvalidOrderException;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->dontReport([
        InvalidOrderException::class,
    ]);
})
```
Alternativamente, puedes simplemente "marcar" una clase de excepción con la interfaz `Illuminate\Contracts\Debug\ShouldntReport`. Cuando una excepción está marcada con esta interfaz, nunca será reportada por el manejador de excepciones de Laravel:


```php
<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Contracts\Debug\ShouldntReport;

class PodcastProcessingException extends Exception implements ShouldntReport
{
    //
}

```
Internamente, Laravel ya ignora algunos tipos de errores por ti, como las excepciones que resultan de errores HTTP 404 o respuestas HTTP 419 generadas por tokens CSRF inválidos. Si deseas instruir a Laravel para que deje de ignorar un tipo dado de excepción, puedes usar el método de excepción `stopIgnoring` en el archivo `bootstrap/app.php` de tu aplicación:


```php
use Symfony\Component\HttpKernel\Exception\HttpException;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->stopIgnoring(HttpException::class);
})
```

<a name="rendering-exceptions"></a>
### Renderizando Excepciones

Por defecto, el manejador de excepciones de Laravel convertirá las excepciones en una respuesta HTTP por ti. Sin embargo, puedes registrar un cierre de renderizado personalizado para excepciones de un tipo dado. Puedes lograr esto utilizando el método de excepción `render` en el archivo `bootstrap/app.php` de tu aplicación.
La `función anónima` pasada al método `render` debe devolver una instancia de `Illuminate\Http\Response`, que puede generarse a través del helper `response`. Laravel determinará qué tipo de excepción renderiza la `función anónima` examinando el tipo de hint de la `función anónima`:


```php
use App\Exceptions\InvalidOrderException;
use Illuminate\Http\Request;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->render(function (InvalidOrderException $e, Request $request) {
        return response()->view('errors.invalid-order', status: 500);
    });
})
```
También puedes usar el método `render` para sobrescribir el comportamiento de renderizado para excepciones integradas de Laravel o Symfony como `NotFoundHttpException`. Si la función anónima dada al método `render` no devuelve un valor, se utilizará el renderizado de excepciones predeterminado de Laravel:


```php
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->render(function (NotFoundHttpException $e, Request $request) {
        if ($request->is('api/*')) {
            return response()->json([
                'message' => 'Record not found.'
            ], 404);
        }
    });
})
```

<a name="rendering-exceptions-as-json"></a>
#### Representando Excepciones como JSON

Al renderizar una excepción, Laravel determinará automáticamente si la excepción debe renderizarse como una respuesta HTML o JSON en función del encabezado `Accept` de la solicitud. Si deseas personalizar cómo Laravel determina si debe renderizar respuestas de excepción en HTML o JSON, puedes utilizar el método `shouldRenderJsonWhen`:


```php
use Illuminate\Http\Request;
use Throwable;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->shouldRenderJsonWhen(function (Request $request, Throwable $e) {
        if ($request->is('admin/*')) {
            return true;
        }

        return $request->expectsJson();
    });
})
```

<a name="customizing-the-exception-response"></a>
#### Personalizando la Respuesta de Excepción

Rara vez, es posible que necesites personalizar toda la respuesta HTTP renderizada por el manejador de excepciones de Laravel. Para lograr esto, puedes registrar una `función anónima` de personalización de respuesta utilizando el método `respond`:


```php
use Symfony\Component\HttpFoundation\Response;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->respond(function (Response $response) {
        if ($response->getStatusCode() === 419) {
            return back()->with([
                'message' => 'The page expired, please try again.',
            ]);
        }

        return $response;
    });
})
```

<a name="renderable-exceptions"></a>
### Excepciones Reportables y Renderizables

En lugar de definir el comportamiento de informes y renderización personalizados en el archivo `bootstrap/app.php` de tu aplicación, puedes definir los métodos `report` y `render` directamente en las excepciones de tu aplicación. Cuando estos métodos existan, serán llamados automáticamente por el framework:


```php
<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class InvalidOrderException extends Exception
{
    /**
     * Report the exception.
     */
    public function report(): void
    {
        // ...
    }

    /**
     * Render the exception into an HTTP response.
     */
    public function render(Request $request): Response
    {
        return response(/* ... */);
    }
}
```
Si tu excepción extiende una excepción que ya es renderizable, como una excepción incorporada de Laravel o Symfony, puedes devolver `false` desde el método `render` de la excepción para renderizar la respuesta HTTP predeterminada de la excepción:


```php
/**
 * Render the exception into an HTTP response.
 */
public function render(Request $request): Response|bool
{
    if (/** Determine if the exception needs custom rendering */) {

        return response(/* ... */);
    }

    return false;
}
```
Si tu excepción contiene lógica de reporte personalizada que solo es necesaria cuando se cumplen ciertas condiciones, es posible que debas instruir a Laravel para que a veces reporte la excepción utilizando la configuración de manejo de excepciones predeterminada. Para lograr esto, puedes devolver `false` desde el método `report` de la excepción:


```php
/**
 * Report the exception.
 */
public function report(): bool
{
    if (/** Determine if the exception needs custom reporting */) {

        // ...

        return true;
    }

    return false;
}
```
> [!NOTA]
Puedes sugerir cualquier dependencia requerida del método `report` y serán inyectadas automáticamente en el método por el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel.

<a name="throttling-reported-exceptions"></a>
### Limitando Excepciones Reportadas

Si tu aplicación informa un número muy grande de excepciones, es posible que desees limitar cuántas excepciones se registran o se envían realmente al servicio de seguimiento de errores externo de tu aplicación.
Para tomar una tasa de muestreo aleatoria de excepciones, puedes usar el método de excepción `throttle` en el archivo `bootstrap/app.php` de tu aplicación. El método `throttle` recibe una función anónima que debe devolver una instancia de `Lottery`:


```php
use Illuminate\Support\Lottery;
use Throwable;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->throttle(function (Throwable $e) {
        return Lottery::odds(1, 1000);
    });
})
```
También es posible muestrear de manera condicional en función del tipo de excepción. Si deseas muestrear solo instancias de una clase de excepción específica, puedes devolver una instancia de `Lottery` solo para esa clase:


```php
use App\Exceptions\ApiMonitoringException;
use Illuminate\Support\Lottery;
use Throwable;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->throttle(function (Throwable $e) {
        if ($e instanceof ApiMonitoringException) {
            return Lottery::odds(1, 1000);
        }
    });
})
```
También puedes limitar las excepciones registradas o enviadas a un servicio de seguimiento de errores externo devolviendo una instancia de `Limit` en lugar de un `Lottery`. Esto es útil si deseas protegerte contra ráfagas repentinas de excepciones que inundan tus registros, por ejemplo, cuando un servicio de terceros utilizado por tu aplicación está inactivo:


```php
use Illuminate\Broadcasting\BroadcastException;
use Illuminate\Cache\RateLimiting\Limit;
use Throwable;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->throttle(function (Throwable $e) {
        if ($e instanceof BroadcastException) {
            return Limit::perMinute(300);
        }
    });
})
```
Por defecto, los límites utilizarán la clase de la excepción como la clave de límite de tasa. Puedes personalizar esto especificando tu propia clave utilizando el método `by` en el `Limit`:


```php
use Illuminate\Broadcasting\BroadcastException;
use Illuminate\Cache\RateLimiting\Limit;
use Throwable;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->throttle(function (Throwable $e) {
        if ($e instanceof BroadcastException) {
            return Limit::perMinute(300)->by($e->getMessage());
        }
    });
})
```
Por supuesto, puedes devolver una mezcla de instancias de `Lottery` y `Limit` para diferentes excepciones:


```php
use App\Exceptions\ApiMonitoringException;
use Illuminate\Broadcasting\BroadcastException;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Lottery;
use Throwable;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->throttle(function (Throwable $e) {
        return match (true) {
            $e instanceof BroadcastException => Limit::perMinute(300),
            $e instanceof ApiMonitoringException => Lottery::odds(1, 1000),
            default => Limit::none(),
        };
    });
})
```

<a name="http-exceptions"></a>
## Excepciones HTTP

Algunas excepciones describen códigos de error HTTP del servidor. Por ejemplo, este puede ser un error de "página no encontrada" (404), un "error no autorizado" (401) o incluso un error 500 generado por el desarrollador. Para generar tal respuesta desde cualquier lugar de su aplicación, puede usar el helper `abort`:


```php
abort(404);
```

<a name="custom-http-error-pages"></a>
### Páginas de Error HTTP Personalizadas

Laravel facilita la visualización de páginas de error personalizadas para varios códigos de estado HTTP. Por ejemplo, para personalizar la página de error para códigos de estado HTTP 404, crea una plantilla de vista `resources/views/errors/404.blade.php`. Esta vista se renderizará para todos los errores 404 generados por tu aplicación. Las vistas dentro de este directorio deben nombrarse para coincidir con el código de estado HTTP al que corresponden. La instancia `Symfony\Component\HttpKernel\Exception\HttpException` generada por la función `abort` se pasará a la vista como una variable `$exception`:


```php
<h2>{{ $exception->getMessage() }}</h2>
```
Puedes publicar las plantillas de página de error por defecto de Laravel utilizando el comando Artisan `vendor:publish`. Una vez que se hayan publicado las plantillas, puedes personalizarlas a tu gusto:


```shell
php artisan vendor:publish --tag=laravel-errors

```

<a name="fallback-http-error-pages"></a>
#### Páginas de Error HTTP de Reserva

También puedes definir una página de error de "respaldo" para una serie dada de códigos de estado HTTP. Esta página se renderizará si no hay una página correspondiente para el código de estado HTTP específico que ocurrió. Para lograr esto, define una plantilla `4xx.blade.php` y una plantilla `5xx.blade.php` en el directorio `resources/views/errors` de tu aplicación.
Al definir páginas de error de respaldo, las páginas de respaldo no afectarán las respuestas de error `404`, `500` y `503` ya que Laravel tiene páginas internas dedicadas para estos códigos de estado. Para personalizar las páginas que se muestran para estos códigos de estado, debes definir una página de error personalizada para cada uno de ellos de forma individual.