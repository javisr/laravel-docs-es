# Limitador de Uso

- [Introducción](#introduction)
    - [Configuración de la cache](#cache-configuration)
- [Uso básico](#basic-usage)
  - [Incremento manual de intentos](#manually-incrementing-attempts)
  - [Borrado de intentos](#clearing-attempts)

<a name="introduction"></a>
## Introducción

Laravel incluye una abstracción de limitación de tasa uso fácil de usar que, en conjunción con la [cache](cache) de tu aplicación, proporciona una forma sencilla de limitar cualquier acción durante una ventana de tiempo especificada.

> **Nota**  
> Si estás interesado en limitar la tasan de uso de peticiones HTTP entrantes, por favor consulta la [documentación](routing#rate-limiting) del [middleware de limitacion](routing#rate-limiting).

<a name="cache-configuration"></a>
### Configuración de la Cache

Normalmente, el limitador de tasa de uso utiliza la cache por defecto de su aplicación, definida por la clave `default` dentro del archivo de configuración de `cache` de su aplicación. Sin embargo, puede especificar qué controlador de cache debe utilizar el limitador definiendo una clave llamada `limiter` en el archivo de configuración de `cache` de su aplicación:

    'default' => 'memcached',

    'limiter' => 'redis',

<a name="basic-usage"></a>
## Uso Básico

La facade `Illuminate\Support\Facades\RateLimiter` puede utilizarse para interactuar con el limitador. El método más sencillo ofrecido por el limitador es el método `attempt`, que limita el número de veces que un callback dado es ejecutado durante un número determinado de segundos.

El método `attempt` devuelve `false` cuando a la llamada de retorno no le quedan intentos disponibles; en caso contrario, el método `attempt` devolverá el resultado de la llamada de retorno o `true`. El primer argumento aceptado por el método `attempt` es una "clave" de limitación, que puede ser cualquier cadena de su elección que represente la acción que se está limitando:

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

<a name="manually-incrementing-attempts"></a>
### Incremento manual de intentos

Si desea interactuar manualmente con el limitador, dispone de otros métodos. Por ejemplo, puede invocar el método `tooManyAttempts` para determinar si una clave de limitación dada ha excedido su número máximo de intentos permitidos por minuto:

    use Illuminate\Support\Facades\RateLimiter;

    if (RateLimiter::tooManyAttempts('send-message:'.$user->id, $perMinute = 5)) {
        return 'Too many attempts!';
    }

De manera alternativa, puede utilizar el método `remaining` para recuperar el número de intentos restantes de una clave dada. Si una clave tiene reintentos restantes, puede invocar el método `hit` para incrementar el número de intentos totales:

    use Illuminate\Support\Facades\RateLimiter;

    if (RateLimiter::remaining('send-message:'.$user->id, $perMinute = 5)) {
        RateLimiter::hit('send-message:'.$user->id);

        // Send message...
    }

<a name="determining-limiter-availability"></a>
#### Determinación de la disponibilidad del limitador

Cuando a una clave no le quedan más intentos, el método `availableIn` devuelve el número de segundos que quedan hasta que haya más intentos disponibles:

    use Illuminate\Support\Facades\RateLimiter;

    if (RateLimiter::tooManyAttempts('send-message:'.$user->id, $perMinute = 5)) {
        $seconds = RateLimiter::availableIn('send-message:'.$user->id);

        return 'You may try again in '.$seconds.' seconds.';
    }

<a name="clearing-attempts"></a>
### Restablecer Intentos

Puede restablecer el número de intentos para una clave determinada utilizando el método `clear`. Por ejemplo, puede restablecer el número de intentos cuando el receptor lea un mensaje determinado:

    use App\Models\Message;
    use Illuminate\Support\Facades\RateLimiter;

    /**
     * Mark the message as read.
     *
     * @param  \App\Models\Message  $message
     * @return \App\Models\Message
     */
    public function read(Message $message)
    {
        $message->markAsRead();

        RateLimiter::clear('send-message:'.$message->user_id);

        return $message;
    }
