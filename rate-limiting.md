# Limitación de tasa

- [Introducción](#introduction)
  - [Configuración de Caché](#cache-configuration)
- [Uso Básico](#basic-usage)
  - [Incrementando Intentos Manualmente](#manually-incrementing-attempts)
  - [Borrando Intentos](#clearing-attempts)

<a name="introduction"></a>
## Introducción

Laravel incluye una abstracción de limitación de tasa fácil de usar que, en combinación con la [caché](cache) de tu aplicación, proporciona una manera sencilla de limitar cualquier acción durante un período de tiempo específico.
> [!NOTA]
Si estás interesado en limitar la tasa de solicitudes HTTP entrantes, consulta la [documentación del middleware de limitador de tasa](/docs/%7B%7Bversion%7D%7D/routing#rate-limiting).

<a name="cache-configuration"></a>
### Configuración de Caché

Típicamente, el limitador de tasa utiliza la caché de aplicación predeterminada que se define por la clave `default` dentro del archivo de configuración `cache` de tu aplicación. Sin embargo, puedes especificar qué driver de caché debe usar el limitador de tasa definiendo una clave `limiter` dentro del archivo de configuración `cache` de tu aplicación:


```php
'default' => env('CACHE_STORE', 'database'),

'limiter' => 'redis',
```

<a name="basic-usage"></a>
## Uso Básico

La fachada `Illuminate\Support\Facades\RateLimiter` puede utilizarse para interactuar con el limitador de velocidad. El método más simple que ofrece el limitador de velocidad es el método `attempt`, que limita la tasa de un callback dado durante un número dado de segundos.
El método `attempt` devuelve `false` cuando el callback no tiene intentos restantes disponibles; de lo contrario, el método `attempt` devolverá el resultado del callback o `true`. El primer argumento que acepta el método `attempt` es una "clave" de limitador de velocidad, que puede ser cualquier cadena que elijas y que represente la acción que se está limitando:


```php
use Illuminate\Support\Facades\RateLimiter;

$executed = RateLimiter::attempt(
    'send-message:'.$user->id,
    $perMinute = 5,
    function() {
        // Send message...
    }
);

if (! $executed) {
  return 'Too many messages sent!';
}
```
Si es necesario, puedes proporcionar un cuarto argumento al método `attempt`, que es la "tasa de decaimiento", o el número de segundos hasta que se restablezcan los intentos disponibles. Por ejemplo, podemos modificar el ejemplo anterior para permitir cinco intentos cada dos minutos:


```php
$executed = RateLimiter::attempt(
    'send-message:'.$user->id,
    $perTwoMinutes = 5,
    function() {
        // Send message...
    },
    $decayRate = 120,
);
```

<a name="manually-incrementing-attempts"></a>
### Incrementando Intentos Manualmente

Si deseas interactuar manualmente con el limitador de tasa, hay una variedad de otros métodos disponibles. Por ejemplo, puedes invocar el método `tooManyAttempts` para determinar si una clave de limitador de tasa dada ha superado su número máximo de intentos permitidos por minuto:


```php
use Illuminate\Support\Facades\RateLimiter;

if (RateLimiter::tooManyAttempts('send-message:'.$user->id, $perMinute = 5)) {
    return 'Too many attempts!';
}

RateLimiter::increment('send-message:'.$user->id);

// Send message...
```
Alternativamente, puedes usar el método `remaining` para recuperar el número de intentos restantes para una clave dada. Si una clave dada tiene reintentos restantes, puedes invocar el método `increment` para incrementar el número total de intentos:


```php
use Illuminate\Support\Facades\RateLimiter;

if (RateLimiter::remaining('send-message:'.$user->id, $perMinute = 5)) {
    RateLimiter::increment('send-message:'.$user->id);

    // Send message...
}
```
Si deseas aumentar el valor para una clave de limitador de tasa dada en más de uno, puedes proporcionar la cantidad deseada al método `increment`:


```php
RateLimiter::increment('send-message:'.$user->id, amount: 5);
```

<a name="determining-limiter-availability"></a>
#### Determinando la Disponibilidad de Limitadores

Cuando una clave ya no tiene más intentos disponibles, el método `availableIn` devuelve el número de segundos que quedan hasta que se puedan realizar más intentos:


```php
use Illuminate\Support\Facades\RateLimiter;

if (RateLimiter::tooManyAttempts('send-message:'.$user->id, $perMinute = 5)) {
    $seconds = RateLimiter::availableIn('send-message:'.$user->id);

    return 'You may try again in '.$seconds.' seconds.';
}

RateLimiter::increment('send-message:'.$user->id);

// Send message...
```

<a name="clearing-attempts"></a>
### Intentos de Borrado

Puedes restablecer el número de intentos para una clave de limitador de tasa dada utilizando el método `clear`. Por ejemplo, puedes restablecer el número de intentos cuando un mensaje dado es leído por el receptor:


```php
use App\Models\Message;
use Illuminate\Support\Facades\RateLimiter;

/**
 * Mark the message as read.
 */
public function read(Message $message): Message
{
    $message->markAsRead();

    RateLimiter::clear('send-message:'.$message->user_id);

    return $message;
}
```