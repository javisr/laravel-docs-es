# Transmisión

- [Introducción](#introduction)
- [Instalación del lado del servidor](#server-side-installation)
    - [Configuración](#configuration)
    - [Reverb](#reverb)
    - [Pusher Channels](#pusher-channels)
    - [Ably](#ably)
- [Instalación del lado del cliente](#client-side-installation)
    - [Reverb](#client-reverb)
    - [Pusher Channels](#client-pusher-channels)
    - [Ably](#client-ably)
- [Descripción general del concepto](#concept-overview)
    - [Usando una aplicación de ejemplo](#using-example-application)
- [Definiendo eventos de transmisión](#defining-broadcast-events)
    - [Nombre de la transmisión](#broadcast-name)
    - [Datos de la transmisión](#broadcast-data)
    - [Cola de transmisión](#broadcast-queue)
    - [Condiciones de transmisión](#broadcast-conditions)
    - [Transmisión y transacciones de base de datos](#broadcasting-and-database-transactions)
- [Autorizando canales](#authorizing-channels)
    - [Definiendo callbacks de autorización](#defining-authorization-callbacks)
    - [Definiendo clases de canal](#defining-channel-classes)
- [Transmitiendo eventos](#broadcasting-events)
    - [Solo a otros](#only-to-others)
    - [Personalizando la conexión](#customizing-the-connection)
    - [Eventos anónimos](#anonymous-events)
- [Recibiendo transmisiones](#receiving-broadcasts)
    - [Escuchando eventos](#listening-for-events)
    - [Abandonando un canal](#leaving-a-channel)
    - [Espacios de nombres](#namespaces)
- [Canales de presencia](#presence-channels)
    - [Autorizando canales de presencia](#authorizing-presence-channels)
    - [Uniéndose a canales de presencia](#joining-presence-channels)
    - [Transmitiendo a canales de presencia](#broadcasting-to-presence-channels)
- [Transmisión de modelos](#model-broadcasting)
    - [Convenciones de transmisión de modelos](#model-broadcasting-conventions)
    - [Escuchando transmisiones de modelos](#listening-for-model-broadcasts)
- [Eventos del cliente](#client-events)
- [Notificaciones](#notifications)

<a name="introduction"></a>
## Introducción

En muchas aplicaciones web modernas, se utilizan WebSockets para implementar interfaces de usuario en tiempo real y con actualizaciones en vivo. Cuando se actualizan algunos datos en el servidor, típicamente se envía un mensaje a través de una conexión WebSocket para ser manejado por el cliente. Los WebSockets proporcionan una alternativa más eficiente que estar consultando continuamente el servidor de tu aplicación en busca de cambios de datos que deberían reflejarse en tu interfaz de usuario.

Por ejemplo, imagina que tu aplicación puede exportar los datos de un usuario a un archivo CSV y enviárselo por correo electrónico. Sin embargo, crear este archivo CSV toma varios minutos, así que decides crear y enviar el CSV dentro de un [trabajo en cola](/docs/{{version}}/queues). Cuando el CSV ha sido creado y enviado al usuario, podemos usar la transmisión de eventos para despachar un evento `App\Events\UserDataExported` que es recibido por el JavaScript de nuestra aplicación. Una vez que se recibe el evento, podemos mostrar un mensaje al usuario de que su CSV ha sido enviado por correo electrónico sin que necesite actualizar la página.

Para ayudarte a construir este tipo de características, Laravel facilita "transmitir" tus [eventos](/docs/{{version}}/events) de Laravel del lado del servidor a través de una conexión WebSocket. Transmitir tus eventos de Laravel te permite compartir los mismos nombres de eventos y datos entre tu aplicación de Laravel del lado del servidor y tu aplicación de JavaScript del lado del cliente.

Los conceptos básicos detrás de la transmisión son simples: los clientes se conectan a canales nombrados en el frontend, mientras que tu aplicación de Laravel transmite eventos a estos canales en el backend. Estos eventos pueden contener cualquier dato adicional que desees poner a disposición del frontend.

<a name="supported-drivers"></a>
#### Controladores soportados

Por defecto, Laravel incluye tres controladores de transmisión del lado del servidor para que elijas: [Laravel Reverb](https://reverb.laravel.com), [Pusher Channels](https://pusher.com/channels) y [Ably](https://ably.com).

> [!NOTE]  
> Antes de sumergirte en la transmisión de eventos, asegúrate de haber leído la documentación de Laravel sobre [eventos y oyentes](/docs/{{version}}/events).

<a name="server-side-installation"></a>
## Instalación del lado del servidor

Para comenzar a usar la transmisión de eventos de Laravel, necesitamos hacer algunas configuraciones dentro de la aplicación de Laravel, así como instalar algunos paquetes.

La transmisión de eventos se logra mediante un controlador de transmisión del lado del servidor que transmite tus eventos de Laravel para que Laravel Echo (una biblioteca de JavaScript) pueda recibirlos dentro del cliente del navegador. No te preocupes, recorreremos cada parte del proceso de instalación paso a paso.

<a name="configuration"></a>
### Configuración

Toda la configuración de transmisión de eventos de tu aplicación se almacena en el archivo de configuración `config/broadcasting.php`. No te preocupes si este directorio no existe en tu aplicación; se creará cuando ejecutes el comando Artisan `install:broadcasting`.

Laravel admite varios controladores de transmisión de forma predeterminada: [Laravel Reverb](/docs/{{version}}/reverb), [Pusher Channels](https://pusher.com/channels), [Ably](https://ably.com) y un controlador `log` para desarrollo local y depuración. Además, se incluye un controlador `null` que te permite desactivar la transmisión durante las pruebas. Se incluye un ejemplo de configuración para cada uno de estos controladores en el archivo de configuración `config/broadcasting.php`.

<a name="installation"></a>
#### Instalación

Por defecto, la transmisión no está habilitada en nuevas aplicaciones de Laravel. Puedes habilitar la transmisión usando el comando Artisan `install:broadcasting`:

```shell
php artisan install:broadcasting
```

El comando `install:broadcasting` creará el archivo de configuración `config/broadcasting.php`. Además, el comando creará el archivo `routes/channels.php` donde puedes registrar las rutas y callbacks de autorización de transmisión de tu aplicación.

<a name="queue-configuration"></a>
#### Configuración de la cola

Antes de transmitir cualquier evento, primero debes configurar y ejecutar un [trabajador de cola](/docs/{{version}}/queues). Toda la transmisión de eventos se realiza a través de trabajos en cola para que el tiempo de respuesta de tu aplicación no se vea seriamente afectado por los eventos que se transmiten.

<a name="reverb"></a>
### Reverb

Al ejecutar el comando `install:broadcasting`, se te pedirá que instales [Laravel Reverb](/docs/{{version}}/reverb). Por supuesto, también puedes instalar Reverb manualmente usando el gestor de paquetes Composer.

```sh
composer require laravel/reverb
```

Una vez que el paquete esté instalado, puedes ejecutar el comando de instalación de Reverb para publicar la configuración, agregar las variables de entorno requeridas por Reverb y habilitar la transmisión de eventos en tu aplicación:

```sh
php artisan reverb:install
```

Puedes encontrar instrucciones detalladas de instalación y uso de Reverb en la [documentación de Reverb](/docs/{{version}}/reverb).

<a name="pusher-channels"></a>
### Pusher Channels

Si planeas transmitir tus eventos usando [Pusher Channels](https://pusher.com/channels), deberías instalar el SDK de PHP de Pusher Channels usando el gestor de paquetes Composer:

```shell
composer require pusher/pusher-php-server
```

A continuación, deberías configurar tus credenciales de Pusher Channels en el archivo de configuración `config/broadcasting.php`. Ya se incluye un ejemplo de configuración de Pusher Channels en este archivo, lo que te permite especificar rápidamente tu clave, secreto e ID de aplicación. Normalmente, deberías configurar tus credenciales de Pusher Channels en el archivo `.env` de tu aplicación:

```ini
PUSHER_APP_ID="your-pusher-app-id"
PUSHER_APP_KEY="your-pusher-key"
PUSHER_APP_SECRET="your-pusher-secret"
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME="https"
PUSHER_APP_CLUSTER="mt1"
```

La configuración `pusher` del archivo `config/broadcasting.php` también te permite especificar `options` adicionales que son compatibles con Channels, como el clúster.

Luego, establece la variable de entorno `BROADCAST_CONNECTION` en `pusher` en el archivo `.env` de tu aplicación:

```ini
BROADCAST_CONNECTION=pusher
```

Finalmente, estás listo para instalar y configurar [Laravel Echo](#client-side-installation), que recibirá los eventos de transmisión en el lado del cliente.

<a name="ably"></a>
### Ably

> [!NOTE]  
> La documentación a continuación discute cómo usar Ably en modo de "compatibilidad con Pusher". Sin embargo, el equipo de Ably recomienda y mantiene un broadcaster y un cliente Echo que pueden aprovechar las capacidades únicas que ofrece Ably. Para obtener más información sobre el uso de los controladores mantenidos por Ably, consulta la [documentación del broadcaster de Laravel de Ably](https://github.com/ably/laravel-broadcaster).

Si planeas transmitir tus eventos usando [Ably](https://ably.com), deberías instalar el SDK de PHP de Ably usando el gestor de paquetes Composer:

```shell
composer require ably/ably-php
```

A continuación, deberías configurar tus credenciales de Ably en el archivo de configuración `config/broadcasting.php`. Ya se incluye un ejemplo de configuración de Ably en este archivo, lo que te permite especificar rápidamente tu clave. Normalmente, este valor debería establecerse a través de la variable de entorno `ABLY_KEY` [variable de entorno](/docs/{{version}}/configuration#environment-configuration):

```ini
ABLY_KEY=your-ably-key
```

Luego, establece la variable de entorno `BROADCAST_CONNECTION` en `ably` en el archivo `.env` de tu aplicación:

```ini
BROADCAST_CONNECTION=ably
```

Finalmente, estás listo para instalar y configurar [Laravel Echo](#client-side-installation), que recibirá los eventos de transmisión en el lado del cliente.

<a name="client-side-installation"></a>
## Instalación del lado del cliente

<a name="client-reverb"></a>
### Reverb

[Laravel Echo](https://github.com/laravel/echo) es una biblioteca de JavaScript que facilita suscribirse a canales y escuchar eventos transmitidos por tu controlador de transmisión del lado del servidor. Puedes instalar Echo a través del gestor de paquetes NPM. En este ejemplo, también instalaremos el paquete `pusher-js` ya que Reverb utiliza el protocolo Pusher para suscripciones WebSocket, canales y mensajes:

```shell
npm install --save-dev laravel-echo pusher-js
```

Una vez que Echo esté instalado, estás listo para crear una nueva instancia de Echo en el JavaScript de tu aplicación. Un buen lugar para hacer esto es al final del archivo `resources/js/bootstrap.js` que se incluye con el marco de Laravel. Por defecto, ya se incluye una configuración de Echo de ejemplo en este archivo; simplemente necesitas descomentarla y actualizar la opción de configuración `broadcaster` a `reverb`:

```js
import Echo from 'laravel-echo';

import Pusher from 'pusher-js';
window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: 'reverb',
    key: import.meta.env.VITE_REVERB_APP_KEY,
    wsHost: import.meta.env.VITE_REVERB_HOST,
    wsPort: import.meta.env.VITE_REVERB_PORT,
    wssPort: import.meta.env.VITE_REVERB_PORT,
    forceTLS: (import.meta.env.VITE_REVERB_SCHEME ?? 'https') === 'https',
    enabledTransports: ['ws', 'wss'],
});
```

A continuación, deberías compilar los activos de tu aplicación:

```shell
npm run build
```

> [!WARNING]  
> El broadcaster `reverb` de Laravel Echo requiere laravel-echo v1.16.0+.

<a name="client-pusher-channels"></a>
### Pusher Channels

[Laravel Echo](https://github.com/laravel/echo) es una biblioteca de JavaScript que facilita suscribirse a canales y escuchar eventos transmitidos por tu controlador de transmisión del lado del servidor. Echo también aprovecha el paquete NPM `pusher-js` para implementar el protocolo Pusher para suscripciones WebSocket, canales y mensajes.

El comando Artisan `install:broadcasting` instala automáticamente los paquetes `laravel-echo` y `pusher-js` por ti; sin embargo, también puedes instalar estos paquetes manualmente a través de NPM:

```shell
npm install --save-dev laravel-echo pusher-js
```

Una vez que Echo esté instalado, estás listo para crear una nueva instancia de Echo en el JavaScript de tu aplicación. El comando `install:broadcasting` crea un archivo de configuración de Echo en `resources/js/echo.js`; sin embargo, la configuración predeterminada en este archivo está destinada a Laravel Reverb. Puedes copiar la configuración a continuación para transitar tu configuración a Pusher:

```js
import Echo from 'laravel-echo';

import Pusher from 'pusher-js';
window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: 'pusher',
    key: import.meta.env.VITE_PUSHER_APP_KEY,
    cluster: import.meta.env.VITE_PUSHER_APP_CLUSTER,
    forceTLS: true
});
```

A continuación, deberías definir los valores apropiados para las variables de entorno de Pusher en el archivo `.env` de tu aplicación. Si estas variables no existen ya en tu archivo `.env`, deberías agregarlas:

```ini
PUSHER_APP_ID="your-pusher-app-id"
PUSHER_APP_KEY="your-pusher-key"
PUSHER_APP_SECRET="your-pusher-secret"
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME="https"
PUSHER_APP_CLUSTER="mt1"

VITE_APP_NAME="${APP_NAME}"
VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
```

Una vez que hayas ajustado la configuración de Echo de acuerdo a las necesidades de tu aplicación, puedes compilar los activos de tu aplicación:

```shell
npm run build
```

> [!NOTE]  
> Para aprender más sobre cómo compilar los activos de JavaScript de tu aplicación, consulta la documentación sobre [Vite](/docs/{{version}}/vite).

<a name="using-an-existing-client-instance"></a>
#### Usando una instancia de cliente existente

Si ya tienes una instancia de cliente de Pusher Channels preconfigurada que te gustaría que Echo utilizara, puedes pasarla a Echo a través de la opción de configuración `client`:

```js
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

const options = {
    broadcaster: 'pusher',
    key: 'your-pusher-channels-key'
}

window.Echo = new Echo({
    ...options,
    client: new Pusher(options.key, options)
});
```

<a name="client-ably"></a>
### Ably

> [!NOTE]  
> La documentación a continuación discute cómo usar Ably en modo de "compatibilidad con Pusher". Sin embargo, el equipo de Ably recomienda y mantiene un broadcaster y un cliente Echo que pueden aprovechar las capacidades únicas que ofrece Ably. Para obtener más información sobre el uso de los controladores mantenidos por Ably, consulta la [documentación del broadcaster de Laravel de Ably](https://github.com/ably/laravel-broadcaster).

[Laravel Echo](https://github.com/laravel/echo) es una biblioteca de JavaScript que facilita suscribirse a canales y escuchar eventos transmitidos por tu controlador de transmisión del lado del servidor. Echo también aprovecha el paquete NPM `pusher-js` para implementar el protocolo Pusher para suscripciones WebSocket, canales y mensajes.

El comando Artisan `install:broadcasting` instala automáticamente los paquetes `laravel-echo` y `pusher-js` por ti; sin embargo, también puedes instalar estos paquetes manualmente a través de NPM:

```shell
npm install --save-dev laravel-echo pusher-js
```

**Antes de continuar, deberías habilitar el soporte para el protocolo Pusher en la configuración de tu aplicación Ably. Puedes habilitar esta función dentro de la sección "Configuración del adaptador de protocolo" del panel de configuración de tu aplicación Ably.**

Una vez que Echo esté instalado, estás listo para crear una nueva instancia de Echo en el JavaScript de tu aplicación. El comando `install:broadcasting` crea un archivo de configuración de Echo en `resources/js/echo.js`; sin embargo, la configuración predeterminada en este archivo está destinada a Laravel Reverb. Puedes copiar la configuración a continuación para transitar tu configuración a Ably:

```js
import Echo from 'laravel-echo';

import Pusher from 'pusher-js';
window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: 'pusher',
    key: import.meta.env.VITE_ABLY_PUBLIC_KEY,
    wsHost: 'realtime-pusher.ably.io',
    wsPort: 443,
    disableStats: true,
    encrypted: true,
});
```

Es posible que hayas notado que nuestra configuración de Echo de Ably hace referencia a una variable de entorno `VITE_ABLY_PUBLIC_KEY`. El valor de esta variable debería ser tu clave pública de Ably. Tu clave pública es la parte de tu clave de Ably que ocurre antes del carácter `:`.

Una vez que hayas ajustado la configuración de Echo de acuerdo a tus necesidades, puedes compilar los activos de tu aplicación:

```shell
npm run dev
```

> [!NOTE]  
> Para aprender más sobre cómo compilar los activos de JavaScript de tu aplicación, consulta la documentación sobre [Vite](/docs/{{version}}/vite).

<a name="concept-overview"></a>
## Descripción general del concepto

La transmisión de eventos de Laravel te permite transmitir tus eventos de Laravel del lado del servidor a tu aplicación de JavaScript del lado del cliente utilizando un enfoque basado en controladores para WebSockets. Actualmente, Laravel se envía con controladores de [Pusher Channels](https://pusher.com/channels) y [Ably](https://ably.com). Los eventos pueden ser consumidos fácilmente en el lado del cliente utilizando el paquete de JavaScript [Laravel Echo](#client-side-installation).

Los eventos se transmiten a través de "canales", que pueden especificarse como públicos o privados. Cualquier visitante de tu aplicación puede suscribirse a un canal público sin ninguna autenticación o autorización; sin embargo, para suscribirse a un canal privado, un usuario debe estar autenticado y autorizado para escuchar en ese canal.

<a name="using-example-application"></a>
### Usando una aplicación de ejemplo

Antes de sumergirnos en cada componente de la transmisión de eventos, tomemos una visión general utilizando una tienda de comercio electrónico como ejemplo.

En nuestra aplicación, supongamos que tenemos una página que permite a los usuarios ver el estado de envío de sus pedidos. Supongamos también que se dispara un evento `OrderShipmentStatusUpdated` cuando se procesa una actualización del estado de envío:

```php
    use App\Events\OrderShipmentStatusUpdated;

    OrderShipmentStatusUpdated::dispatch($order);

<a name="the-shouldbroadcast-interface"></a>
#### La interfaz `ShouldBroadcast`

Cuando un usuario está viendo uno de sus pedidos, no queremos que tenga que actualizar la página para ver las actualizaciones de estado. En su lugar, queremos transmitir las actualizaciones a la aplicación a medida que se crean. Por lo tanto, necesitamos marcar el evento `OrderShipmentStatusUpdated` con la interfaz `ShouldBroadcast`. Esto le indicará a Laravel que transmita el evento cuando se dispare:

    <?php

    namespace App\Events;

    use App\Models\Order;
    use Illuminate\Broadcasting\Channel;
    use Illuminate\Broadcasting\InteractsWithSockets;
    use Illuminate\Broadcasting\PresenceChannel;
    use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
    use Illuminate\Queue\SerializesModels;

    class OrderShipmentStatusUpdated implements ShouldBroadcast
    {
        /**
         * La instancia del pedido.
         *
         * @var \App\Models\Order
         */
        public $order;
    }

La interfaz `ShouldBroadcast` requiere que nuestro evento defina un método `broadcastOn`. Este método es responsable de devolver los canales en los que el evento debe transmitirse. Un stub vacío de este método ya está definido en las clases de eventos generadas, por lo que solo necesitamos completar sus detalles. Solo queremos que el creador del pedido pueda ver las actualizaciones de estado, por lo que transmitiremos el evento en un canal privado que está vinculado al pedido:

    use Illuminate\Broadcasting\Channel;
    use Illuminate\Broadcasting\PrivateChannel;

    /**
     * Obtener el canal en el que el evento debe transmitirse.
     */
    public function broadcastOn(): Channel
    {
        return new PrivateChannel('orders.'.$this->order->id);
    }

Si deseas que el evento se transmita en múltiples canales, puedes devolver un `array` en su lugar:

    use Illuminate\Broadcasting\PrivateChannel;

    /**
     * Obtener los canales en los que el evento debe transmitirse.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('orders.'.$this->order->id),
            // ...
        ];
    }

<a name="example-application-authorizing-channels"></a>
#### Autorizando Canales

Recuerda, los usuarios deben estar autorizados para escuchar en canales privados. Podemos definir nuestras reglas de autorización de canales en el archivo `routes/channels.php` de nuestra aplicación. En este ejemplo, necesitamos verificar que cualquier usuario que intente escuchar en el canal privado `orders.1` sea realmente el creador del pedido:

    use App\Models\Order;
    use App\Models\User;

    Broadcast::channel('orders.{orderId}', function (User $user, int $orderId) {
        return $user->id === Order::findOrNew($orderId)->user_id;
    });

El método `channel` acepta dos argumentos: el nombre del canal y un callback que devuelve `true` o `false` indicando si el usuario está autorizado para escuchar en el canal.

Todos los callbacks de autorización reciben al usuario autenticado actualmente como su primer argumento y cualquier parámetro adicional de comodín como sus argumentos subsiguientes. En este ejemplo, estamos utilizando el marcador de posición `{orderId}` para indicar que la parte "ID" del nombre del canal es un comodín.

<a name="listening-for-event-broadcasts"></a>
#### Escuchando Transmisiones de Eventos

A continuación, solo queda escuchar el evento en nuestra aplicación JavaScript. Podemos hacer esto usando [Laravel Echo](#client-side-installation). Primero, utilizaremos el método `private` para suscribirnos al canal privado. Luego, podemos usar el método `listen` para escuchar el evento `OrderShipmentStatusUpdated`. Por defecto, todas las propiedades públicas del evento se incluirán en el evento de transmisión:

```js
Echo.private(`orders.${orderId}`)
    .listen('OrderShipmentStatusUpdated', (e) => {
        console.log(e.order);
    });
```

<a name="defining-broadcast-events"></a>
## Definiendo Eventos de Transmisión

Para informar a Laravel que un evento dado debe ser transmitido, debes implementar la interfaz `Illuminate\Contracts\Broadcasting\ShouldBroadcast` en la clase del evento. Esta interfaz ya está importada en todas las clases de eventos generadas por el marco, por lo que puedes agregarla fácilmente a cualquiera de tus eventos.

La interfaz `ShouldBroadcast` requiere que implementes un único método: `broadcastOn`. El método `broadcastOn` debe devolver un canal o un array de canales en los que el evento debe transmitirse. Los canales deben ser instancias de `Channel`, `PrivateChannel` o `PresenceChannel`. Las instancias de `Channel` representan canales públicos a los que cualquier usuario puede suscribirse, mientras que `PrivateChannels` y `PresenceChannels` representan canales privados que requieren [autorización de canal](#authorizing-channels):

    <?php

    namespace App\Events;

    use App\Models\User;
    use Illuminate\Broadcasting\Channel;
    use Illuminate\Broadcasting\InteractsWithSockets;
    use Illuminate\Broadcasting\PresenceChannel;
    use Illuminate\Broadcasting\PrivateChannel;
    use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
    use Illuminate\Queue\SerializesModels;

    class ServerCreated implements ShouldBroadcast
    {
        use SerializesModels;

        /**
         * Crear una nueva instancia de evento.
         */
        public function __construct(
            public User $user,
        ) {}

        /**
         * Obtener los canales en los que el evento debe transmitirse.
         *
         * @return array<int, \Illuminate\Broadcasting\Channel>
         */
        public function broadcastOn(): array
        {
            return [
                new PrivateChannel('user.'.$this->user->id),
            ];
        }
    }

Después de implementar la interfaz `ShouldBroadcast`, solo necesitas [disparar el evento](/docs/{{version}}/events) como lo harías normalmente. Una vez que el evento ha sido disparado, un [trabajo en cola](/docs/{{version}}/queues) transmitirá automáticamente el evento utilizando tu controlador de transmisión especificado.

<a name="broadcast-name"></a>
### Nombre de Transmisión

Por defecto, Laravel transmitirá el evento utilizando el nombre de la clase del evento. Sin embargo, puedes personalizar el nombre de la transmisión definiendo un método `broadcastAs` en el evento:

    /**
     * El nombre de la transmisión del evento.
     */
    public function broadcastAs(): string
    {
        return 'server.created';
    }

Si personalizas el nombre de la transmisión utilizando el método `broadcastAs`, debes asegurarte de registrar tu listener con un carácter `.` al principio. Esto le indicará a Echo que no anteponga el espacio de nombres de la aplicación al evento:

    .listen('.server.created', function (e) {
        ....
    });

<a name="broadcast-data"></a>
### Datos de Transmisión

Cuando un evento es transmitido, todas sus propiedades `public` se serializan automáticamente y se transmiten como la carga útil del evento, lo que te permite acceder a cualquiera de sus datos públicos desde tu aplicación JavaScript. Así que, por ejemplo, si tu evento tiene una única propiedad pública `$user` que contiene un modelo Eloquent, la carga útil de transmisión del evento sería:

```json
{
    "user": {
        "id": 1,
        "name": "Patrick Stewart"
        ...
    }
}
```

Sin embargo, si deseas tener un control más detallado sobre tu carga útil de transmisión, puedes agregar un método `broadcastWith` a tu evento. Este método debe devolver el array de datos que deseas transmitir como la carga útil del evento:

    /**
     * Obtener los datos a transmitir.
     *
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return ['id' => $this->user->id];
    }

<a name="broadcast-queue"></a>
### Cola de Transmisión

Por defecto, cada evento de transmisión se coloca en la cola predeterminada para la conexión de cola predeterminada especificada en tu archivo de configuración `queue.php`. Puedes personalizar la conexión de cola y el nombre utilizados por el transmisor definiendo las propiedades `connection` y `queue` en tu clase de evento:

    /**
     * El nombre de la conexión de cola a utilizar al transmitir el evento.
     *
     * @var string
     */
    public $connection = 'redis';

    /**
     * El nombre de la cola en la que colocar el trabajo de transmisión.
     *
     * @var string
     */
    public $queue = 'default';

Alternativamente, puedes personalizar el nombre de la cola definiendo un método `broadcastQueue` en tu evento:

    /**
     * El nombre de la cola en la que colocar el trabajo de transmisión.
     */
    public function broadcastQueue(): string
    {
        return 'default';
    }

Si deseas transmitir tu evento utilizando la cola `sync` en lugar del controlador de cola predeterminado, puedes implementar la interfaz `ShouldBroadcastNow` en lugar de `ShouldBroadcast`:

    <?php

    use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;

    class OrderShipmentStatusUpdated implements ShouldBroadcastNow
    {
        // ...
    }

<a name="broadcast-conditions"></a>
### Condiciones de Transmisión

A veces deseas transmitir tu evento solo si se cumple una determinada condición. Puedes definir estas condiciones agregando un método `broadcastWhen` a tu clase de evento:

    /**
     * Determinar si este evento debe transmitirse.
     */
    public function broadcastWhen(): bool
    {
        return $this->order->value > 100;
    }

<a name="broadcasting-and-database-transactions"></a>
#### Transmisión y Transacciones de Base de Datos

Cuando los eventos de transmisión se envían dentro de transacciones de base de datos, pueden ser procesados por la cola antes de que la transacción de base de datos se haya confirmado. Cuando esto sucede, cualquier actualización que hayas realizado en modelos o registros de base de datos durante la transacción de base de datos puede no estar reflejada en la base de datos. Además, cualquier modelo o registro de base de datos creado dentro de la transacción puede no existir en la base de datos. Si tu evento depende de estos modelos, pueden ocurrir errores inesperados cuando se procesa el trabajo que transmite el evento.

Si la opción de configuración `after_commit` de tu conexión de cola está establecida en `false`, aún puedes indicar que un evento de transmisión particular debe ser enviado después de que todas las transacciones de base de datos abiertas se hayan confirmado implementando la interfaz `ShouldDispatchAfterCommit` en la clase del evento:

    <?php

    namespace App\Events;

    use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
    use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
    use Illuminate\Queue\SerializesModels;

    class ServerCreated implements ShouldBroadcast, ShouldDispatchAfterCommit
    {
        use SerializesModels;
    }

> [!NOTE]  
> Para obtener más información sobre cómo solucionar estos problemas, consulta la documentación sobre [trabajos en cola y transacciones de base de datos](/docs/{{version}}/queues#jobs-and-database-transactions).

<a name="authorizing-channels"></a>
## Autorizando Canales

Los canales privados requieren que autorices que el usuario autenticado actualmente puede escuchar en el canal. Esto se logra haciendo una solicitud HTTP a tu aplicación Laravel con el nombre del canal y permitiendo que tu aplicación determine si el usuario puede escuchar en ese canal. Al usar [Laravel Echo](#client-side-installation), la solicitud HTTP para autorizar suscripciones a canales privados se realizará automáticamente.

Cuando la transmisión está habilitada, Laravel registra automáticamente la ruta `/broadcasting/auth` para manejar las solicitudes de autorización. La ruta `/broadcasting/auth` se coloca automáticamente dentro del grupo de middleware `web`.

<a name="defining-authorization-callbacks"></a>
### Definiendo Callbacks de Autorización

A continuación, necesitamos definir la lógica que realmente determinará si el usuario autenticado actualmente puede escuchar un canal dado. Esto se hace en el archivo `routes/channels.php` que fue creado por el comando Artisan `install:broadcasting`. En este archivo, puedes usar el método `Broadcast::channel` para registrar callbacks de autorización de canal:

    use App\Models\User;

    Broadcast::channel('orders.{orderId}', function (User $user, int $orderId) {
        return $user->id === Order::findOrNew($orderId)->user_id;
    });

El método `channel` acepta dos argumentos: el nombre del canal y un callback que devuelve `true` o `false` indicando si el usuario está autorizado para escuchar en el canal.

Todos los callbacks de autorización reciben al usuario autenticado actualmente como su primer argumento y cualquier parámetro adicional de comodín como sus argumentos subsiguientes. En este ejemplo, estamos utilizando el marcador de posición `{orderId}` para indicar que la parte "ID" del nombre del canal es un comodín.

Puedes ver una lista de los callbacks de autorización de transmisión de tu aplicación utilizando el comando Artisan `channel:list`:

```shell
php artisan channel:list
```

<a name="authorization-callback-model-binding"></a>
#### Vinculación de Modelos en Callbacks de Autorización

Al igual que las rutas HTTP, las rutas de canal también pueden aprovechar la [vinculación de modelos de ruta implícita y explícita](/docs/{{version}}/routing#route-model-binding). Por ejemplo, en lugar de recibir un ID de pedido de tipo cadena o numérico, puedes solicitar una instancia real del modelo `Order`:

    use App\Models\Order;
    use App\Models\User;

    Broadcast::channel('orders.{order}', function (User $user, Order $order) {
        return $user->id === $order->user_id;
    });

> [!WARNING]  
> A diferencia de la vinculación de modelos de ruta HTTP, la vinculación de modelos de canal no admite el [alcance de vinculación de modelos implícitos](/docs/{{version}}/routing#implicit-model-binding-scoping) automático. Sin embargo, esto rara vez es un problema porque la mayoría de los canales pueden ser limitados en función de la clave primaria única de un solo modelo.

<a name="authorization-callback-authentication"></a>
#### Autenticación de Callbacks de Autorización

Los canales de transmisión privados y de presencia autentican al usuario actual a través del guardia de autenticación predeterminado de tu aplicación. Si el usuario no está autenticado, la autorización del canal se niega automáticamente y el callback de autorización nunca se ejecuta. Sin embargo, puedes asignar múltiples guardias personalizados que deben autenticar la solicitud entrante si es necesario:

    Broadcast::channel('channel', function () {
        // ...
    }, ['guards' => ['web', 'admin']]);

<a name="defining-channel-classes"></a>
### Definiendo Clases de Canal

Si tu aplicación está consumiendo muchos canales diferentes, tu archivo `routes/channels.php` podría volverse voluminoso. Por lo tanto, en lugar de usar funciones anónimas para autorizar canales, puedes usar clases de canal. Para generar una clase de canal, utiliza el comando Artisan `make:channel`. Este comando colocará una nueva clase de canal en el directorio `App/Broadcasting`.

```shell
php artisan make:channel OrderChannel
```

A continuación, registra tu canal en tu archivo `routes/channels.php`:

    use App\Broadcasting\OrderChannel;

    Broadcast::channel('orders.{order}', OrderChannel::class);

Finalmente, puedes colocar la lógica de autorización para tu canal en el método `join` de la clase de canal. Este método `join` contendrá la misma lógica que normalmente habrías colocado en tu función anónima de autorización de canal. También puedes aprovechar la vinculación de modelos de canal:

    <?php

    namespace App\Broadcasting;

    use App\Models\Order;
    use App\Models\User;

    class OrderChannel
    {
        /**
         * Crear una nueva instancia de canal.
         */
        public function __construct()
        {
            // ...
        }

        /**
         * Autenticar el acceso del usuario al canal.
         */
        public function join(User $user, Order $order): array|bool
        {
            return $user->id === $order->user_id;
        }
    }

> [!NOTE]  
> Al igual que muchas otras clases en Laravel, las clases de canal se resolverán automáticamente mediante el [contenedor de servicios](/docs/{{version}}/container). Por lo tanto, puedes indicar cualquier dependencia requerida por tu canal en su constructor.
```

```markdown
<a name="broadcasting-events"></a>
## Transmitiendo Eventos

Una vez que hayas definido un evento y lo hayas marcado con la interfaz `ShouldBroadcast`, solo necesitas disparar el evento utilizando el método de despacho del evento. El despachador de eventos notará que el evento está marcado con la interfaz `ShouldBroadcast` y pondrá el evento en cola para su transmisión:

    use App\Events\OrderShipmentStatusUpdated;

    OrderShipmentStatusUpdated::dispatch($order);

<a name="only-to-others"></a>
### Solo a Otros

Al construir una aplicación que utiliza la transmisión de eventos, es posible que ocasionalmente necesites transmitir un evento a todos los suscriptores de un canal dado, excepto al usuario actual. Puedes lograr esto utilizando el helper `broadcast` y el método `toOthers`:

    use App\Events\OrderShipmentStatusUpdated;

    broadcast(new OrderShipmentStatusUpdated($update))->toOthers();

Para entender mejor cuándo podrías querer usar el método `toOthers`, imaginemos una aplicación de lista de tareas donde un usuario puede crear una nueva tarea ingresando un nombre de tarea. Para crear una tarea, tu aplicación podría hacer una solicitud a una URL `/task` que transmite la creación de la tarea y devuelve una representación JSON de la nueva tarea. Cuando tu aplicación JavaScript recibe la respuesta del punto final, podría insertar directamente la nueva tarea en su lista de tareas así:

```js
axios.post('/task', task)
    .then((response) => {
        this.tasks.push(response.data);
    });
```

Sin embargo, recuerda que también transmitimos la creación de la tarea. Si tu aplicación JavaScript también está escuchando este evento para agregar tareas a la lista de tareas, tendrás tareas duplicadas en tu lista: una del punto final y otra de la transmisión. Puedes resolver esto utilizando el método `toOthers` para instruir al transmisor que no transmita el evento al usuario actual.

> [!WARNING]  
> Tu evento debe usar el trait `Illuminate\Broadcasting\InteractsWithSockets` para poder llamar al método `toOthers`.

<a name="only-to-others-configuration"></a>
#### Configuración

Cuando inicializas una instancia de Laravel Echo, se asigna un ID de socket a la conexión. Si estás utilizando una instancia global de [Axios](https://github.com/mzabriskie/axios) para hacer solicitudes HTTP desde tu aplicación JavaScript, el ID de socket se adjuntará automáticamente a cada solicitud saliente como un encabezado `X-Socket-ID`. Luego, cuando llames al método `toOthers`, Laravel extraerá el ID de socket del encabezado e instruirá al transmisor que no transmita a ninguna conexión con ese ID de socket.

Si no estás utilizando una instancia global de Axios, necesitarás configurar manualmente tu aplicación JavaScript para enviar el encabezado `X-Socket-ID` con todas las solicitudes salientes. Puedes recuperar el ID de socket utilizando el método `Echo.socketId`:

```js
var socketId = Echo.socketId();
```

<a name="customizing-the-connection"></a>
### Personalizando la Conexión

Si tu aplicación interactúa con múltiples conexiones de transmisión y deseas transmitir un evento utilizando un transmisor diferente al predeterminado, puedes especificar qué conexión utilizar para enviar un evento utilizando el método `via`:

    use App\Events\OrderShipmentStatusUpdated;

    broadcast(new OrderShipmentStatusUpdated($update))->via('pusher');

Alternativamente, puedes especificar la conexión de transmisión del evento llamando al método `broadcastVia` dentro del constructor del evento. Sin embargo, antes de hacerlo, debes asegurarte de que la clase del evento use el trait `InteractsWithBroadcasting`:

    <?php

    namespace App\Events;

    use Illuminate\Broadcasting\Channel;
    use Illuminate\Broadcasting\InteractsWithBroadcasting;
    use Illuminate\Broadcasting\InteractsWithSockets;
    use Illuminate\Broadcasting\PresenceChannel;
    use Illuminate\Broadcasting\PrivateChannel;
    use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
    use Illuminate\Queue\SerializesModels;

    class OrderShipmentStatusUpdated implements ShouldBroadcast
    {
        use InteractsWithBroadcasting;

        /**
         * Crear una nueva instancia de evento.
         */
        public function __construct()
        {
            $this->broadcastVia('pusher');
        }
    }

<a name="anonymous-events"></a>
### Eventos Anónimos

A veces, puedes querer transmitir un evento simple a la interfaz de tu aplicación sin crear una clase de evento dedicada. Para acomodar esto, la fachada `Broadcast` te permite transmitir "eventos anónimos":

```php
Broadcast::on('orders.'.$order->id)->send();
```

El ejemplo anterior transmitirá el siguiente evento:

```json
{
    "event": "AnonymousEvent",
    "data": "[]",
    "channel": "orders.1"
}
```

Usando los métodos `as` y `with`, puedes personalizar el nombre y los datos del evento:

```php
Broadcast::on('orders.'.$order->id)
    ->as('OrderPlaced')
    ->with($order)
    ->send();
```

El ejemplo anterior transmitirá un evento como el siguiente:

```json
{
    "event": "OrderPlaced",
    "data": "{ id: 1, total: 100 }",
    "channel": "orders.1"
}
```

Si deseas transmitir el evento anónimo en un canal privado o de presencia, puedes utilizar los métodos `private` y `presence`:

```php
Broadcast::private('orders.'.$order->id)->send();
Broadcast::presence('channels.'.$channel->id)->send();
```

Transmitir un evento anónimo utilizando el método `send` despacha el evento a la [cola](/docs/{{version}}/queues) de tu aplicación para su procesamiento. Sin embargo, si deseas transmitir el evento de inmediato, puedes usar el método `sendNow`:

```php
Broadcast::on('orders.'.$order->id)->sendNow();
```

Para transmitir el evento a todos los suscriptores del canal, excepto al usuario autenticado actualmente, puedes invocar el método `toOthers`:

```php
Broadcast::on('orders.'.$order->id)
    ->toOthers()
    ->send();
```

<a name="receiving-broadcasts"></a>
## Recibiendo Transmisiones

<a name="listening-for-events"></a>
### Escuchando Eventos

Una vez que hayas [instalado e instanciado Laravel Echo](#client-side-installation), estás listo para comenzar a escuchar eventos que se transmiten desde tu aplicación Laravel. Primero, utiliza el método `channel` para recuperar una instancia de un canal, luego llama al método `listen` para escuchar un evento específico:

```js
Echo.channel(`orders.${this.order.id}`)
    .listen('OrderShipmentStatusUpdated', (e) => {
        console.log(e.order.name);
    });
```

Si deseas escuchar eventos en un canal privado, utiliza el método `private` en su lugar. Puedes seguir encadenando llamadas al método `listen` para escuchar múltiples eventos en un solo canal:

```js
Echo.private(`orders.${this.order.id}`)
    .listen(/* ... */)
    .listen(/* ... */)
    .listen(/* ... */);
```

<a name="stop-listening-for-events"></a>
#### Detener la Escucha de Eventos

Si deseas dejar de escuchar un evento dado sin [abandonar el canal](#leaving-a-channel), puedes usar el método `stopListening`:

```js
Echo.private(`orders.${this.order.id}`)
    .stopListening('OrderShipmentStatusUpdated')
```

<a name="leaving-a-channel"></a>
### Abandonando un Canal

Para abandonar un canal, puedes llamar al método `leaveChannel` en tu instancia de Echo:

```js
Echo.leaveChannel(`orders.${this.order.id}`);
```

Si deseas abandonar un canal y también sus canales privados y de presencia asociados, puedes llamar al método `leave`:

```js
Echo.leave(`orders.${this.order.id}`);
```
<a name="namespaces"></a>
### Espacios de Nombres

Es posible que hayas notado en los ejemplos anteriores que no especificamos el espacio de nombres completo `App\Events` para las clases de eventos. Esto se debe a que Echo asumirá automáticamente que los eventos se encuentran en el espacio de nombres `App\Events`. Sin embargo, puedes configurar el espacio de nombres raíz cuando instancias Echo pasando una opción de configuración `namespace`:

```js
window.Echo = new Echo({
    broadcaster: 'pusher',
    // ...
    namespace: 'App.Other.Namespace'
});
```

Alternativamente, puedes prefijar las clases de eventos con un `.` al suscribirte a ellas usando Echo. Esto te permitirá siempre especificar el nombre de clase completamente calificado:

```js
Echo.channel('orders')
    .listen('.Namespace\\Event\\Class', (e) => {
        // ...
    });
```

<a name="presence-channels"></a>
## Canales de Presencia

Los canales de presencia se basan en la seguridad de los canales privados mientras exponen la característica adicional de ser conscientes de quién está suscrito al canal. Esto facilita la construcción de potentes características colaborativas en la aplicación, como notificar a los usuarios cuando otro usuario está viendo la misma página o listar a los habitantes de una sala de chat.

<a name="authorizing-presence-channels"></a>
### Autorizando Canales de Presencia

Todos los canales de presencia también son canales privados; por lo tanto, los usuarios deben ser [autorizados para acceder a ellos](#authorizing-channels). Sin embargo, al definir callbacks de autorización para los canales de presencia, no devolverás `true` si el usuario está autorizado para unirse al canal. En su lugar, debes devolver un array de datos sobre el usuario.

Los datos devueltos por el callback de autorización estarán disponibles para los oyentes de eventos del canal de presencia en tu aplicación JavaScript. Si el usuario no está autorizado para unirse al canal de presencia, debes devolver `false` o `null`:

    use App\Models\User;

    Broadcast::channel('chat.{roomId}', function (User $user, int $roomId) {
        if ($user->canJoinRoom($roomId)) {
            return ['id' => $user->id, 'name' => $user->name];
        }
    });

<a name="joining-presence-channels"></a>
### Uniéndose a Canales de Presencia

Para unirte a un canal de presencia, puedes usar el método `join` de Echo. El método `join` devolverá una implementación de `PresenceChannel` que, además de exponer el método `listen`, te permite suscribirte a los eventos `here`, `joining` y `leaving`.

```js
Echo.join(`chat.${roomId}`)
    .here((users) => {
        // ...
    })
    .joining((user) => {
        console.log(user.name);
    })
    .leaving((user) => {
        console.log(user.name);
    })
    .error((error) => {
        console.error(error);
    });
```

El callback `here` se ejecutará inmediatamente una vez que el canal se haya unido con éxito y recibirá un array que contiene la información del usuario de todos los demás usuarios actualmente suscritos al canal. El método `joining` se ejecutará cuando un nuevo usuario se una a un canal, mientras que el método `leaving` se ejecutará cuando un usuario abandone el canal. El método `error` se ejecutará cuando el punto final de autenticación devuelva un código de estado HTTP diferente de 200 o si hay un problema al analizar el JSON devuelto.

<a name="broadcasting-to-presence-channels"></a>
### Transmitiendo a Canales de Presencia

Los canales de presencia pueden recibir eventos al igual que los canales públicos o privados. Usando el ejemplo de una sala de chat, podríamos querer transmitir eventos `NewMessage` al canal de presencia de la sala. Para hacerlo, devolveremos una instancia de `PresenceChannel` desde el método `broadcastOn` del evento:

    /**
     * Obtener los canales en los que el evento debe transmitirse.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PresenceChannel('chat.'.$this->message->room_id),
        ];
    }

Al igual que con otros eventos, puedes usar el helper `broadcast` y el método `toOthers` para excluir al usuario actual de recibir la transmisión:

    broadcast(new NewMessage($message));

    broadcast(new NewMessage($message))->toOthers();

Como es típico en otros tipos de eventos, puedes escuchar eventos enviados a canales de presencia utilizando el método `listen` de Echo:

```js
Echo.join(`chat.${roomId}`)
    .here(/* ... */)
    .joining(/* ... */)
    .leaving(/* ... */)
    .listen('NewMessage', (e) => {
        // ...
    });
```

<a name="model-broadcasting"></a>
## Transmisión de Modelos

> [!WARNING]  
> Antes de leer la siguiente documentación sobre la transmisión de modelos, te recomendamos que te familiarices con los conceptos generales de los servicios de transmisión de modelos de Laravel, así como con cómo crear y escuchar eventos de transmisión manualmente.

Es común transmitir eventos cuando se crean, actualizan o eliminan los [modelos Eloquent](/docs/{{version}}/eloquent) de tu aplicación. Por supuesto, esto se puede lograr fácilmente definiendo manualmente [eventos personalizados para los cambios de estado del modelo Eloquent](/docs/{{version}}/eloquent#events) y marcando esos eventos con la interfaz `ShouldBroadcast`.

Sin embargo, si no estás utilizando estos eventos para ningún otro propósito en tu aplicación, puede ser engorroso crear clases de eventos con el único propósito de transmitirlas. Para remediar esto, Laravel te permite indicar que un modelo Eloquent debe transmitir automáticamente sus cambios de estado.

Para comenzar, tu modelo Eloquent debe usar el trait `Illuminate\Database\Eloquent\BroadcastsEvents`. Además, el modelo debe definir un método `broadcastOn`, que devolverá un array de canales en los que los eventos del modelo deben transmitirse:

```php
<?php

namespace App\Models;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Database\Eloquent\BroadcastsEvents;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Post extends Model
{
    use BroadcastsEvents, HasFactory;

    /**
     * Get the user that the post belongs to.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the channels that model events should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel|\Illuminate\Database\Eloquent\Model>
     */
    public function broadcastOn(string $event): array
    {
        return [$this, $this->user];
    }
}
```

Una vez que tu modelo incluya este trait y defina sus canales de transmisión, comenzará a transmitir automáticamente eventos cuando se cree, actualice, elimine, elimine de forma temporal o restaure una instancia de modelo.

Además, es posible que hayas notado que el método `broadcastOn` recibe un argumento de cadena `$event`. Este argumento contiene el tipo de evento que ha ocurrido en el modelo y tendrá un valor de `created`, `updated`, `deleted`, `trashed` o `restored`. Al inspeccionar el valor de esta variable, puedes determinar qué canales (si los hay) debe transmitir el modelo para un evento particular:

```php
/**
 * Get the channels that model events should broadcast on.
 *
 * @return array<string, array<int, \Illuminate\Broadcasting\Channel|\Illuminate\Database\Eloquent\Model>>
 */
public function broadcastOn(string $event): array
{
    return match ($event) {
        'deleted' => [],
        default => [$this, $this->user],
    };
}
```

<a name="customizing-model-broadcasting-event-creation"></a>
#### Personalizando la Creación de Eventos de Transmisión de Modelos

Ocasionalmente, es posible que desees personalizar cómo Laravel crea el evento de transmisión de modelo subyacente. Puedes lograr esto definiendo un método `newBroadcastableEvent` en tu modelo Eloquent. Este método debe devolver una instancia de `Illuminate\Database\Eloquent\BroadcastableModelEventOccurred`:

```php
use Illuminate\Database\Eloquent\BroadcastableModelEventOccurred;

/**
 * Create a new broadcastable model event for the model.
 */
protected function newBroadcastableEvent(string $event): BroadcastableModelEventOccurred
{
    return (new BroadcastableModelEventOccurred(
        $this, $event
    ))->dontBroadcastToCurrentUser();
}
```

<a name="model-broadcasting-conventions"></a>
### Convenciones de Transmisión de Modelos

<a name="model-broadcasting-channel-conventions"></a>
#### Convenciones de Canales

Como habrás notado, el método `broadcastOn` en el ejemplo de modelo anterior no devolvió instancias de `Channel`. En su lugar, se devolvieron directamente modelos Eloquent. Si se devuelve una instancia de modelo Eloquent desde el método `broadcastOn` de tu modelo (o se contiene en un array devuelto por el método), Laravel instanciará automáticamente una instancia de canal privado para el modelo utilizando el nombre de clase del modelo y el identificador de clave primaria como el nombre del canal.

Así, un modelo `App\Models\User` con un `id` de `1` se convertiría en una instancia de `Illuminate\Broadcasting\PrivateChannel` con un nombre de `App.Models.User.1`. Por supuesto, además de devolver instancias de modelo Eloquent desde el método `broadcastOn` de tu modelo, puedes devolver instancias completas de `Channel` para tener control total sobre los nombres de los canales del modelo:

```php
use Illuminate\Broadcasting\PrivateChannel;

/**
 * Get the channels that model events should broadcast on.
 *
 * @return array<int, \Illuminate\Broadcasting\Channel>
 */
public function broadcastOn(string $event): array
{
    return [
        new PrivateChannel('user.'.$this->id)
    ];
}
```

Si planeas devolver explícitamente una instancia de canal desde el método `broadcastOn` de tu modelo, puedes pasar una instancia de modelo Eloquent al constructor del canal. Al hacerlo, Laravel utilizará las convenciones de canal del modelo discutidas anteriormente para convertir el modelo Eloquent en una cadena de nombre de canal:

```php
return [new Channel($this->user)];
```

Si necesitas determinar el nombre del canal de un modelo, puedes llamar al método `broadcastChannel` en cualquier instancia de modelo. Por ejemplo, este método devuelve la cadena `App.Models.User.1` para un modelo `App\Models\User` con un `id` de `1`:

```php
$user->broadcastChannel()
```

<a name="model-broadcasting-event-conventions"></a>
#### Convenciones de Eventos

Dado que los eventos de transmisión de modelos no están asociados con un evento "real" dentro del directorio `App\Events` de tu aplicación, se les asigna un nombre y una carga útil basados en convenciones. La convención de Laravel es transmitir el evento utilizando el nombre de clase del modelo (sin incluir el espacio de nombres) y el nombre del evento del modelo que activó la transmisión.

Así, por ejemplo, una actualización del modelo `App\Models\Post` transmitiría un evento a tu aplicación del lado del cliente como `PostUpdated` con la siguiente carga útil:

```json
{
    "model": {
        "id": 1,
        "title": "My first post"
        ...
    },
    ...
    "socket": "someSocketId",
}
```

La eliminación del modelo `App\Models\User` transmitiría un evento llamado `UserDeleted`.
```

Si lo deseas, puedes definir un nombre de transmisión y una carga útil personalizados agregando un método `broadcastAs` y `broadcastWith` a tu modelo. Estos métodos reciben el nombre del evento / operación del modelo que está ocurriendo, lo que te permite personalizar el nombre y la carga útil del evento para cada operación del modelo. Si se devuelve `null` desde el método `broadcastAs`, Laravel utilizará las convenciones de nombres de eventos de transmisión del modelo discutidas anteriormente al transmitir el evento:

```php
/**
 * The model event's broadcast name.
 */
public function broadcastAs(string $event): string|null
{
    return match ($event) {
        'created' => 'post.created',
        default => null,
    };
}

/**
 * Get the data to broadcast for the model.
 *
 * @return array<string, mixed>
 */
public function broadcastWith(string $event): array
{
    return match ($event) {
        'created' => ['title' => $this->title],
        default => ['model' => $this],
    };
}
```

<a name="listening-for-model-broadcasts"></a>
### Escuchando Transmisiones de Modelos

Una vez que hayas agregado el rasgo `BroadcastsEvents` a tu modelo y definido el método `broadcastOn` de tu modelo, estás listo para comenzar a escuchar eventos de modelo transmitidos dentro de tu aplicación del lado del cliente. Antes de comenzar, es posible que desees consultar la documentación completa sobre [escuchar eventos](#listening-for-events).

Primero, utiliza el método `private` para recuperar una instancia de un canal, luego llama al método `listen` para escuchar un evento específico. Típicamente, el nombre del canal dado al método `private` debe corresponder a las [convenciones de transmisión de modelos](#model-broadcasting-conventions) de Laravel.

Una vez que hayas obtenido una instancia de canal, puedes usar el método `listen` para escuchar un evento particular. Dado que los eventos de transmisión de modelos no están asociados con un evento "real" dentro del directorio `App\Events` de tu aplicación, el [nombre del evento](#model-broadcasting-event-conventions) debe estar precedido por un `.` para indicar que no pertenece a un espacio de nombres particular. Cada evento de transmisión de modelo tiene una propiedad `model` que contiene todas las propiedades transmitibles del modelo:

```js
Echo.private(`App.Models.User.${this.user.id}`)
    .listen('.PostUpdated', (e) => {
        console.log(e.model);
    });
```

<a name="client-events"></a>
## Eventos del Cliente

> [!NOTE]  
> Al usar [Pusher Channels](https://pusher.com/channels), debes habilitar la opción "Eventos del Cliente" en la sección "Configuración de la Aplicación" de tu [tablero de aplicaciones](https://dashboard.pusher.com/) para poder enviar eventos del cliente.

A veces, es posible que desees transmitir un evento a otros clientes conectados sin tocar tu aplicación Laravel en absoluto. Esto puede ser particularmente útil para cosas como notificaciones de "escribiendo", donde deseas alertar a los usuarios de tu aplicación que otro usuario está escribiendo un mensaje en una pantalla determinada.

Para transmitir eventos del cliente, puedes usar el método `whisper` de Echo:

```js
Echo.private(`chat.${roomId}`)
    .whisper('typing', {
        name: this.user.name
    });
```

Para escuchar eventos del cliente, puedes usar el método `listenForWhisper`:

```js
Echo.private(`chat.${roomId}`)
    .listenForWhisper('typing', (e) => {
        console.log(e.name);
    });
```

<a name="notifications"></a>
## Notificaciones

Al combinar la transmisión de eventos con [notificaciones](/docs/{{version}}/notifications), tu aplicación JavaScript puede recibir nuevas notificaciones a medida que ocurren sin necesidad de actualizar la página. Antes de comenzar, asegúrate de leer la documentación sobre el uso del [canal de notificación de transmisión](/docs/{{version}}/notifications#broadcast-notifications).

Una vez que hayas configurado una notificación para usar el canal de transmisión, puedes escuchar los eventos de transmisión utilizando el método `notification` de Echo. Recuerda, el nombre del canal debe coincidir con el nombre de la clase de la entidad que recibe las notificaciones:

```js
Echo.private(`App.Models.User.${userId}`)
    .notification((notification) => {
        console.log(notification.type);
    });
```

En este ejemplo, todas las notificaciones enviadas a las instancias de `App\Models\User` a través del canal `broadcast` serían recibidas por la función de callback. Se incluye una función de callback de autorización de canal para el canal `App.Models.User.{id}` en el archivo `routes/channels.php` de tu aplicación.
