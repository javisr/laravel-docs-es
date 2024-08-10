# Limitación de Tasa

- [Introducción](#introduction)
    - [Configuración de Caché](#cache-configuration)
- [Uso Básico](#basic-usage)
    - [Incrementar Intentos Manualmente](#manually-incrementing-attempts)
    - [Limpiar Intentos](#clearing-attempts)

<a name="introduction"></a>
## Introducción

Laravel incluye una abstracción de limitación de tasa fácil de usar que, en conjunto con la [caché](cache) de tu aplicación, proporciona una forma sencilla de limitar cualquier acción durante un período de tiempo específico.

> [!NOTE]  
> Si estás interesado en limitar la tasa de solicitudes HTTP entrantes, consulta la [documentación del middleware de limitación de tasa](/docs/{{version}}/routing#rate-limiting).

<a name="cache-configuration"></a>
### Configuración de Caché

Típicamente, el limitador de tasa utiliza la caché predeterminada de tu aplicación según lo definido por la clave `default` dentro del archivo de configuración `cache` de tu aplicación. Sin embargo, puedes especificar qué controlador de caché debe usar el limitador de tasa definiendo una clave `limiter` dentro del archivo de configuración `cache` de tu aplicación:

    'default' => env('CACHE_STORE', 'database'),

    'limiter' => 'redis',

<a name="basic-usage"></a>
## Uso Básico

La fachada `Illuminate\Support\Facades\RateLimiter` puede ser utilizada para interactuar con el limitador de tasa. El método más simple ofrecido por el limitador de tasa es el método `attempt`, que limita la tasa de un callback dado durante un número específico de segundos.

El método `attempt` devuelve `false` cuando el callback no tiene intentos restantes disponibles; de lo contrario, el método `attempt` devolverá el resultado del callback o `true`. El primer argumento aceptado por el método `attempt` es una "clave" del limitador de tasa, que puede ser cualquier cadena de tu elección que represente la acción que se está limitando:

    use Illuminate\Support\Facades\RateLimiter;

    $executed = RateLimiter::attempt(
        'send-message:'.$user->id,
        $perMinute = 5,
        function() {
            // Enviar mensaje...
        }
    );

    if (! $executed) {
      return '¡Demasiados mensajes enviados!';
    }

Si es necesario, puedes proporcionar un cuarto argumento al método `attempt`, que es la "tasa de decadencia", o el número de segundos hasta que los intentos disponibles se restablezcan. Por ejemplo, podemos modificar el ejemplo anterior para permitir cinco intentos cada dos minutos:

    $executed = RateLimiter::attempt(
        'send-message:'.$user->id,
        $perTwoMinutes = 5,
        function() {
            // Enviar mensaje...
        },
        $decayRate = 120,
    );

<a name="manually-incrementing-attempts"></a>
### Incrementar Intentos Manualmente

Si deseas interactuar manualmente con el limitador de tasa, hay una variedad de otros métodos disponibles. Por ejemplo, puedes invocar el método `tooManyAttempts` para determinar si una clave de limitador de tasa dada ha excedido su número máximo de intentos permitidos por minuto:

    use Illuminate\Support\Facades\RateLimiter;

    if (RateLimiter::tooManyAttempts('send-message:'.$user->id, $perMinute = 5)) {
        return '¡Demasiados intentos!';
    }

    RateLimiter::increment('send-message:'.$user->id);

    // Enviar mensaje...

Alternativamente, puedes usar el método `remaining` para recuperar el número de intentos restantes para una clave dada. Si una clave dada tiene reintentos restantes, puedes invocar el método `increment` para incrementar el número total de intentos:

    use Illuminate\Support\Facades\RateLimiter;

    if (RateLimiter::remaining('send-message:'.$user->id, $perMinute = 5)) {
        RateLimiter::increment('send-message:'.$user->id);

        // Enviar mensaje...
    }

Si deseas incrementar el valor para una clave de limitador de tasa dada en más de uno, puedes proporcionar la cantidad deseada al método `increment`:

    RateLimiter::increment('send-message:'.$user->id, amount: 5);

<a name="determining-limiter-availability"></a>
#### Determinando la Disponibilidad del Limitador

Cuando una clave no tiene más intentos restantes, el método `availableIn` devuelve el número de segundos restantes hasta que más intentos estén disponibles:

    use Illuminate\Support\Facades\RateLimiter;

    if (RateLimiter::tooManyAttempts('send-message:'.$user->id, $perMinute = 5)) {
        $seconds = RateLimiter::availableIn('send-message:'.$user->id);

        return 'Puedes intentar de nuevo en '.$seconds.' segundos.';
    }

    RateLimiter::increment('send-message:'.$user->id);

    // Enviar mensaje...

<a name="clearing-attempts"></a>
### Limpiar Intentos

Puedes restablecer el número de intentos para una clave de limitador de tasa dada utilizando el método `clear`. Por ejemplo, puedes restablecer el número de intentos cuando un mensaje dado es leído por el receptor:

    use App\Models\Message;
    use Illuminate\Support\Facades\RateLimiter;

    /**
     * Marcar el mensaje como leído.
     */
    public function read(Message $message): Message
    {
        $message->markAsRead();

        RateLimiter::clear('send-message:'.$message->user_id);

        return $message;
    }
