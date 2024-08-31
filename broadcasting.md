# Difusión (Broadcasting)

- [Introducción](#introduction)
- [Instalación del Lado del Servidor](#server-side-installation)
  - [Configuración](#configuration)
  - [Reverb](#reverb)
  - [Canales de Pusher](#pusher-channels)
  - [Ably](#ably)
- [Instalación del Lado del Cliente](#client-side-installation)
  - [Reverb](#client-reverb)
  - [Canales de Pusher](#client-pusher-channels)
  - [Ably](#client-ably)
- [Descripción General del Concepto](#concept-overview)
  - [Usando una Aplicación de Ejemplo](#using-example-application)
- [Definiendo Eventos de Difusión](#defining-broadcast-events)
  - [Nombre de Difusión](#broadcast-name)
  - [Datos de Difusión](#broadcast-data)
  - [Cola de Difusión](#broadcast-queue)
  - [Condiciones de Difusión](#broadcast-conditions)
  - [Difusión y Transacciones de Base de Datos](#broadcasting-and-database-transactions)
- [Autorizando Canales](#authorizing-channels)
  - [Definiendo Callbacks de Autorización](#defining-authorization-callbacks)
  - [Definiendo Clases de Canal](#defining-channel-classes)
- [Transmitiendo Eventos](#broadcasting-events)
  - [Solo a Otros](#only-to-others)
  - [Personalizando la Conexión](#customizing-the-connection)
  - [Eventos Anónimos](#anonymous-events)
- [Recibiendo Difusiones](#receiving-broadcasts)
  - [Escuchando Eventos](#listening-for-events)
  - [Abandonando un Canal](#leaving-a-channel)
  - [Espacios de Nombres](#namespaces)
- [Canales de Presencia](#presence-channels)
  - [Autorizando Canales de Presencia](#authorizing-presence-channels)
  - [Uniéndose a Canales de Presencia](#joining-presence-channels)
  - [Transmitiendo a Canales de Presencia](#broadcasting-to-presence-channels)
- [Model Broadcasting](#model-broadcasting)
  - [Convenciones de Transmisión de Modelos](#model-broadcasting-conventions)
  - [Escuchando Difusiones de Modelos](#listening-for-model-broadcasts)
- [Eventos del Cliente](#client-events)
- [Notificaciones](#notifications)

<a name="introduction"></a>
## Introducción

En muchas aplicaciones web modernas, se utilizan WebSockets para implementar interfaces de usuario en tiempo real y con actualizaciones en vivo. Cuando se actualizan algunos datos en el servidor, típicamente se envía un mensaje a través de una conexión WebSocket para que lo maneje el cliente. Los WebSockets ofrecen una alternativa más eficiente que el sondeo continuo del servidor de su aplicación en busca de cambios de datos que deberían reflejarse en su interfaz de usuario.
Por ejemplo, imagina que tu aplicación puede exportar los datos de un usuario a un archivo CSV y enviarlo por correo electrónico. Sin embargo, crear este archivo CSV lleva varios minutos, así que eliges crear y enviar el CSV dentro de un [trabajo en cola](/docs/%7B%7Bversion%7D%7D/queues). Cuando se ha creado el CSV y se ha enviado por correo al usuario, podemos usar la transmisión de eventos para despachar un evento `App\Events\UserDataExported` que es recibido por el JavaScript de nuestra aplicación. Una vez que se recibe el evento, podemos mostrar un mensaje al usuario de que su CSV ha sido enviado por correo electrónico sin que tenga que actualizar la página.
Para ayudarte a construir este tipo de funcionalidades, Laravel facilita "transmitir" tus [eventos](/docs/%7B%7Bversion%7D%7D/events) de Laravel en el lado del servidor a través de una conexión WebSocket. Transmitir tus eventos de Laravel te permite compartir los mismos nombres de evento y datos entre tu aplicación Laravel en el lado del servidor y tu aplicación JavaScript en el lado del cliente.
Los conceptos básicos detrás de la transmisión son simples: los clientes se conectan a canales nombrados en el frontend, mientras que tu aplicación Laravel transmite eventos a estos canales en el backend. Estos eventos pueden contener cualquier dato adicional que desees hacer disponible en el frontend.

<a name="supported-drivers"></a>
#### Drivers Soportados

Por defecto, Laravel incluye tres controladores de transmisión del lado del servidor para que elijas: [Laravel Reverb](https://reverb.laravel.com), [Pusher Channels](https://pusher.com/channels) y [Ably](https://ably.com).
> [!NOTE]
Antes de sumergirte en la transmisión de eventos, asegúrate de haber leído la documentación de Laravel sobre [eventos y oyentes](/docs/%7B%7Bversion%7D%7D/events).

<a name="server-side-installation"></a>
## Instalación del Lado del Servidor

Para comenzar a usar la transmisión de eventos de Laravel, necesitamos hacer algunas configuraciones dentro de la aplicación Laravel, así como instalar algunos paquetes.
La transmisión de eventos se lleva a cabo mediante un driver de transmisión del lado del servidor que transmite tus eventos de Laravel para que Laravel Echo (una biblioteca de JavaScript) pueda recibirlos dentro del cliente del navegador. No te preocupes, recorreremos cada parte del proceso de instalación paso a paso.

<a name="configuration"></a>
### Configuración

Toda la configuración de transmisión de eventos de tu aplicación se almacena en el archivo de configuración `config/broadcasting.php`. No te preocupes si este directorio no existe en tu aplicación; se creará cuando ejecutes el comando Artisan `install:broadcasting`.
Laravel soporta varios drivers de broadcasting listos para usar: [Laravel Reverb](/docs/%7B%7Bversion%7D%7D/reverb), [Pusher Channels](https://pusher.com/channels), [Ably](https://ably.com) y un driver `log` para desarrollo y depuración locales. Además, se incluye un driver `null` que te permite deshabilitar el broadcasting durante las pruebas. Se incluye un ejemplo de configuración para cada uno de estos drivers en el archivo de configuración `config/broadcasting.php`.

<a name="installation"></a>
#### Instalación

Por defecto, la transmisión no está habilitada en nuevas aplicaciones Laravel. Puedes habilitar la transmisión utilizando el comando Artisan `install:broadcasting`:


```shell
php artisan install:broadcasting

```
El comando `install:broadcasting` creará el archivo de configuración `config/broadcasting.php`. Además, el comando creará el archivo `routes/channels.php` donde podrás registrar las rutas de autorización de transmisión y las devoluciones de llamada de tu aplicación.

<a name="queue-configuration"></a>
#### Configuración de Cola

Antes de transmitir cualquier evento, primero debes configurar y ejecutar un [trabajador de cola](/docs/%7B%7Bversion%7D%7D/queues). Toda la transmisión de eventos se realiza a través de trabajos en cola para que el tiempo de respuesta de tu aplicación no se vea seriamente afectado por los eventos que se están transmitiendo.

<a name="reverb"></a>
Al ejecutar el comando `install:broadcasting`, se te pedirá que instales [Laravel Reverb](/docs/%7B%7Bversion%7D%7D/reverb). Por supuesto, también puedes instalar Reverb manualmente utilizando el gestor de paquetes Composer.


```sh
composer require laravel/reverb

```
Una vez que el paquete esté instalado, puedes ejecutar el comando de instalación de Reverb para publicar la configuración, añadir las variables de entorno requeridas por Reverb y habilitar la transmisión de eventos en tu aplicación:


```sh
php artisan reverb:install

```
Puedes encontrar instrucciones detalladas de instalación y uso de Reverb en la [documentación de Reverb](/docs/%7B%7Bversion%7D%7D/reverb).

<a name="pusher-channels"></a>
Si planeas transmitir tus eventos utilizando [Pusher Channels](https://pusher.com/channels), debes instalar el SDK de PHP de Pusher Channels utilizando el gestor de paquetes Composer:


```shell
composer require pusher/pusher-php-server

```
A continuación, debes configurar tus credenciales de Pusher Channels en el archivo de configuración `config/broadcasting.php`. Ya se incluye un ejemplo de configuración de Pusher Channels en este archivo, lo que te permite especificar rápidamente tu clave, secreto e ID de aplicación. Típicamente, debes configurar tus credenciales de Pusher Channels en el archivo `.env` de tu aplicación:


```ini
PUSHER_APP_ID="your-pusher-app-id"
PUSHER_APP_KEY="your-pusher-key"
PUSHER_APP_SECRET="your-pusher-secret"
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME="https"
PUSHER_APP_CLUSTER="mt1"

```
La configuración `pusher` del archivo `config/broadcasting.php` también te permite especificar opciones adicionales que son soportadas por Channels, como el clúster.
Luego, establece la variable de entorno `BROADCAST_CONNECTION` en `pusher` en el archivo `.env` de tu aplicación:


```ini
BROADCAST_CONNECTION=pusher

```

<a name="ably"></a>
Si planeas transmitir tus eventos utilizando [Ably](https://ably.com), deberías instalar el SDK PHP de Ably usando el gestor de paquetes Composer:


```shell
composer require ably/ably-php

```
A continuación, debes configurar tus credenciales de Ably en el archivo de configuración `config/broadcasting.php`. Ya se incluye un ejemplo de configuración de Ably en este archivo, lo que te permite especificar rápidamente tu clave. Típicamente, este valor debe establecerse a través de la variable de entorno `ABLY_KEY` [variable de entorno](/docs/%7B%7Bversion%7D%7D/configuration#environment-configuration):


```ini
ABLY_KEY=your-ably-key

```
Entonces, establece la variable de entorno `BROADCAST_CONNECTION` en `ably` en el archivo `.env` de tu aplicación:


```ini
BROADCAST_CONNECTION=ably

```
Finalmente, estás listo para instalar y configurar [Laravel Echo](#client-side-installation), que recibirá los eventos de broadcast en el lado del cliente.

<a name="client-side-installation"></a>
## Instalación del lado del cliente


<a name="client-reverb"></a>
### Reverb

[Laravel Echo](https://github.com/laravel/echo) es una biblioteca de JavaScript que facilita la suscripción a canales y la escucha de eventos transmitidos por tu driver de transmisión del lado del servidor. Puedes instalar Echo a través del gestor de paquetes NPM. En este ejemplo, también instalaremos el paquete `pusher-js` ya que Reverb utiliza el protocolo Pusher para suscripciones WebSocket, canales y mensajes:
Una vez que Echo está instalado, estás listo para crear una nueva instancia de Echo en el JavaScript de tu aplicación. Un buen lugar para hacer esto es al final del archivo `resources/js/bootstrap.js` que se incluye con el framework Laravel. Por defecto, ya se incluye una configuración de Echo de ejemplo en este archivo; simplemente necesitas descomentarlo y actualizar la opción de configuración `broadcaster` a `reverb`:


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
A continuación, debes compilar los activos de tu aplicación:
> [!WARNING]
El `reverb` broadcaster de Laravel Echo requiere laravel-echo v1.16.0+.

<a name="client-pusher-channels"></a>
### Pusher Channels

Una vez que Echo esté instalado, estarás listo para crear una nueva instancia de Echo en el JavaScript de tu aplicación. El comando `install:broadcasting` crea un archivo de configuración de Echo en `resources/js/echo.js`; sin embargo, la configuración predeterminada en este archivo está destinada a Laravel Reverb. Puedes copiar la configuración a continuación para cambiar tu configuración a Pusher:


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
A continuación, debes definir los valores apropiados para las variables de entorno de Pusher en el archivo `.env` de tu aplicación. Si estas variables no existen ya en tu archivo `.env`, debes añadirlas:


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
Una vez que hayas ajustado la configuración de Echo según las necesidades de tu aplicación, puedes compilar los activos de tu aplicación:


```shell
npm run build

```

<a name="using-an-existing-client-instance"></a>
#### Usando una Instancia de Cliente Existente

Si ya tienes una instancia del cliente de Pusher Channels preconfigurada que te gustaría que Echo utilice, puedes pasarla a Echo a través de la opción de configuración `client`:


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

> [!NOTA]
La documentación a continuación discute cómo usar Ably en modo "compatible con Pusher". Sin embargo, el equipo de Ably recomienda y mantiene un broadcasting y un cliente Echo que pueden aprovechar las capacidades únicas que ofrece Ably. Para obtener más información sobre el uso de los drivers mantenidos por Ably, por favor [consulta la documentación del broadcaster de Laravel de Ably](https://github.com/ably/laravel-broadcaster).
[Laravel Echo](https://github.com/laravel/echo) es una biblioteca de JavaScript que facilita la suscripción a canales y la escucha de eventos transmitidos por tu driver de transmisión del lado del servidor. Echo también utiliza el paquete NPM `pusher-js` para implementar el protocolo Pusher para suscripciones WebSocket, canales y mensajes.
El comando Artisan `install:broadcasting` instala automáticamente los paquetes `laravel-echo` y `pusher-js` por ti; sin embargo, también puedes instalar estos paquetes manualmente a través de NPM:


```shell
npm install --save-dev laravel-echo pusher-js

```
**Antes de continuar, debes habilitar el soporte del protocolo Pusher en la configuración de tu aplicación Ably. Puedes habilitar esta función dentro de la sección "Configuración del Adaptador de Protocolo" del panel de configuración de tu aplicación Ably.**
Una vez que Echo esté instalado, estás listo para crear una nueva instancia de Echo en el JavaScript de tu aplicación. El comando `install:broadcasting` crea un archivo de configuración de Echo en `resources/js/echo.js`; sin embargo, la configuración predeterminada en este archivo está destinada a Laravel Reverb. Puedes copiar la configuración a continuación para trasladar tu configuración a Ably:


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
Es posible que hayas notado que nuestra configuración de Ably Echo hace referencia a una variable de entorno `VITE_ABLY_PUBLIC_KEY`. El valor de esta variable debe ser tu clave pública de Ably. Tu clave pública es la porción de tu clave de Ably que ocurre antes del carácter `:`.
Una vez que hayas ajustado la configuración de Echo según tus necesidades, puedes compilar los activos de tu aplicación:


```shell
npm run dev

```
> [!NOTA]
Para obtener más información sobre la compilación de los activos de JavaScript de tu aplicación, consulta la documentación sobre [Vite](/docs/%7B%7Bversion%7D%7D/vite).

<a name="concept-overview"></a>
## Visión General del Concepto

El broadcasting de eventos de Laravel te permite transmitir tus eventos de Laravel del lado del servidor a tu aplicación JavaScript del lado del cliente utilizando un enfoque basado en controladores para WebSockets. Actualmente, Laravel incluye los controladores de [Pusher Channels](https://pusher.com/channels) y [Ably](https://ably.com). Los eventos pueden ser consumidos fácilmente en el lado del cliente utilizando el paquete JavaScript [Laravel Echo](#client-side-installation).
Los eventos se transmiten a través de "canales", que pueden especificarse como públicos o privados. Cualquier visitante de tu aplicación puede suscribirse a un canal público sin ninguna autenticación o autorización; sin embargo, para suscribirse a un canal privado, un usuario debe estar autenticado y autorizado para escuchar en ese canal.

<a name="using-example-application"></a>
### Usando un Aplicación de Ejemplo

Antes de profundizar en cada componente de la transmisión de eventos, hagamos un vistazo general utilizando una tienda de comercio electrónico como ejemplo.
En nuestra aplicación, supongamos que tenemos una página que permite a los usuarios ver el estado de envío de sus pedidos. Supongamos también que se dispara un evento `OrderShipmentStatusUpdated` cuando se procesa una actualización del estado de envío en la aplicación:

<a name="the-shouldbroadcast-interface"></a>
#### La interfaz `ShouldBroadcast`

Cuando un usuario está viendo uno de sus pedidos, no queremos que tenga que actualizar la página para ver las actualizaciones de estado. En su lugar, queremos transmitir las actualizaciones a la aplicación a medida que se crean. Así que necesitamos marcar el evento `OrderShipmentStatusUpdated` con la interfaz `ShouldBroadcast`. Esto instruirá a Laravel a transmitir el evento cuando se dispare:


```php
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
     * The order instance.
     *
     * @var \App\Models\Order
     */
    public $order;
}
```
La interfaz `ShouldBroadcast` requiere que nuestro evento defina un método `broadcastOn`. Este método es responsable de devolver los canales en los que el evento debe transmitirse. Ya se ha definido un método de plantilla vacío en las clases de evento generadas, así que solo necesitamos completar sus detalles. Solo queremos que el creador del pedido pueda ver las actualizaciones de estado, así que transmitiremos el evento en un canal privado que esté vinculado al pedido:


```php
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\PrivateChannel;

/**
 * Get the channel the event should broadcast on.
 */
public function broadcastOn(): Channel
{
    return new PrivateChannel('orders.'.$this->order->id);
}
```
Si deseas que el evento se transmita en múltiples canales, puedes devolver un `array` en su lugar:


```php
use Illuminate\Broadcasting\PrivateChannel;

/**
 * Get the channels the event should broadcast on.
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
```

<a name="example-application-authorizing-channels"></a>
#### Autorizando Canales

Recuerda que los usuarios deben estar autorizados para escuchar en canales privados. Podemos definir nuestras reglas de autorización de canales en el archivo `routes/channels.php` de nuestra aplicación. En este ejemplo, necesitamos verificar que cualquier usuario que intente escuchar en el canal privado `orders.1` sea en realidad el creador del pedido:


```php
use App\Models\Order;
use App\Models\User;

Broadcast::channel('orders.{orderId}', function (User $user, int $orderId) {
    return $user->id === Order::findOrNew($orderId)->user_id;
});
```

<a name="listening-for-event-broadcasts"></a>
#### Escuchando Transmisiones de Eventos

A continuación, solo queda escuchar el evento en nuestra aplicación JavaScript. Podemos hacer esto utilizando [Laravel Echo](#client-side-installation). Primero, utilizaremos el método `private` para suscribirnos al canal privado. Luego, podemos usar el método `listen` para escuchar el evento `OrderShipmentStatusUpdated`. Por defecto, se incluirán todas las propiedades públicas del evento en el evento de transmisión:


```js
Echo.private(`orders.${orderId}`)
    .listen('OrderShipmentStatusUpdated', (e) => {
        console.log(e.order);
    });

```

<a name="defining-broadcast-events"></a>
## Definiendo Eventos de Difusión

Para informar a Laravel que un evento dado debe ser transmitido, debes implementar la interfaz `Illuminate\Contracts\Broadcasting\ShouldBroadcast` en la clase del evento. Esta interfaz ya está importada en todas las clases de eventos generadas por el framework, así que puedes añadirla fácilmente a cualquiera de tus eventos.
La interfaz `ShouldBroadcast` requiere que implementes un solo método: `broadcastOn`. El método `broadcastOn` debería devolver un canal o un array de canales en los que se debe transmitir el evento. Los canales deben ser instancias de `Channel`, `PrivateChannel` o `PresenceChannel`. Las instancias de `Channel` representan canales públicos a los que cualquier usuario puede suscribirse, mientras que `PrivateChannels` y `PresenceChannels` representan canales privados que requieren [autorización de canal](#authorizing-channels):


```php
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
     * Create a new event instance.
     */
    public function __construct(
        public User $user,
    ) {}

    /**
     * Get the channels the event should broadcast on.
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
```
Después de implementar la interfaz `ShouldBroadcast`, solo necesitas [disparar el evento](/docs/%7B%7Bversion%7D%7D/events) como lo harías normalmente. Una vez que se haya disparado el evento, un [trabajo en cola](/docs/%7B%7Bversion%7D%7D/queues) transmitirá automáticamente el evento utilizando tu driver de transmisión especificado.

<a name="broadcast-name"></a>
### Nombre de Difusión

Por defecto, Laravel transmitirá el evento utilizando el nombre de la clase del evento. Sin embargo, puedes personalizar el nombre de transmisión definiendo un método `broadcastAs` en el evento:


```php
/**
 * The event's broadcast name.
 */
public function broadcastAs(): string
{
    return 'server.created';
}
```
Si personalizas el nombre de difusión utilizando el método `broadcastAs`, debes asegurarte de registrar tu listener con un carácter `.` al principio. Esto instruirá a Echo a no añadir el espacio de nombres de la aplicación al evento:


```php
.listen('.server.created', function (e) {
    ....
});
```

<a name="broadcast-data"></a>
### Datos de Difusión

Cuando se transmite un evento, todas sus propiedades `public` se serializan automáticamente y se transmiten como la carga útil del evento, lo que te permite acceder a cualquier dato público desde tu aplicación JavaScript. Así que, por ejemplo, si tu evento tiene una sola propiedad `$user` pública que contiene un modelo Eloquent, la carga útil de transmisión del evento sería:


```json
{
    "user": {
        "id": 1,
        "name": "Patrick Stewart"
        ...
    }
}

```
Sin embargo, si deseas tener un control más detallado sobre tu carga útil de transmisión, puedes añadir un método `broadcastWith` a tu evento. Este método debe devolver el array de datos que deseas transmitir como la carga útil del evento:


```php
/**
 * Get the data to broadcast.
 *
 * @return array<string, mixed>
 */
public function broadcastWith(): array
{
    return ['id' => $this->user->id];
}
```

<a name="broadcast-queue"></a>
### Cola de Transmisión

Por defecto, cada evento de transmisión se coloca en la cola predeterminada para la conexión de cola predeterminada especificada en tu archivo de configuración `queue.php`. Puedes personalizar la conexión de cola y el nombre utilizado por el broadcaster definiendo las propiedades `connection` y `queue` en tu clase de evento:


```php
/**
 * The name of the queue connection to use when broadcasting the event.
 *
 * @var string
 */
public $connection = 'redis';

/**
 * The name of the queue on which to place the broadcasting job.
 *
 * @var string
 */
public $queue = 'default';
```
Alternativamente, puedes personalizar el nombre de la cola definiendo un método `broadcastQueue` en tu evento:


```php
/**
 * The name of the queue on which to place the broadcasting job.
 */
public function broadcastQueue(): string
{
    return 'default';
}
```
Si deseas transmitir tu evento utilizando la cola `sync` en lugar del driver de cola predeterminado, puedes implementar la interfaz `ShouldBroadcastNow` en lugar de `ShouldBroadcast`:


```php
<?php

use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;

class OrderShipmentStatusUpdated implements ShouldBroadcastNow
{
    // ...
}
```

<a name="broadcast-conditions"></a>
### Condiciones de Transmisión

A veces quieres transmitir tu evento solo si una condición dada es verdadera. Puedes definir estas condiciones añadiendo un método `broadcastWhen` a tu clase de evento:


```php
/**
 * Determine if this event should broadcast.
 */
public function broadcastWhen(): bool
{
    return $this->order->value > 100;
}
```

<a name="broadcasting-and-database-transactions"></a>
#### Transmisión y Transacciones de Base de Datos

Cuando se despachan eventos de transmisión dentro de transacciones de base de datos, pueden ser procesados por la cola antes de que se haya confirmado la transacción de la base de datos. Cuando esto sucede, cualquier actualización que hayas hecho a modelos o registros de base de datos durante la transacción de la base de datos puede no estar aún reflejada en la base de datos. Además, cualquier modelo o registro de base de datos creado dentro de la transacción puede no existir en la base de datos. Si tu evento depende de estos modelos, pueden ocurrir errores inesperados cuando se procesa el trabajo que transmite el evento.
Si la opción de configuración `after_commit` de la conexión de tu cola está configurada en `false`, aún puedes indicar que un evento de difusión particular debe ser despachado después de que se hayan confirmado todas las transacciones de base de datos abiertas implementando la interfaz `ShouldDispatchAfterCommit` en la clase del evento:


```php
<?php

namespace App\Events;

use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
use Illuminate\Queue\SerializesModels;

class ServerCreated implements ShouldBroadcast, ShouldDispatchAfterCommit
{
    use SerializesModels;
}
```
> [!NOTA]
Para obtener más información sobre cómo solucionar estos problemas, por favor revisa la documentación sobre [trabajos en cola y transacciones de base de datos](/docs/%7B%7Bversion%7D%7D/queues#jobs-and-database-transactions).

<a name="authorizing-channels"></a>
## Autorizando Canales

Los canales privados requieren que autorices que el usuario autenticado actualmente pueda escuchar en el canal. Esto se logra haciendo una solicitud HTTP a tu aplicación Laravel con el nombre del canal y permitiendo que tu aplicación determine si el usuario puede escuchar en ese canal. Al usar [Laravel Echo](#client-side-installation), la solicitud HTTP para autorizar suscripciones a canales privados se realizará automáticamente.
Cuando se habilita la transmisión, Laravel registra automáticamente la ruta `/broadcasting/auth` para manejar las solicitudes de autorización. La ruta `/broadcasting/auth` se coloca automáticamente dentro del grupo de middleware `web`.

<a name="defining-authorization-callbacks"></a>
### Definiendo Callbacks de Autorización

A continuación, necesitamos definir la lógica que determinará si el usuario autenticado actualmente puede escuchar un canal dado. Esto se hace en el archivo `routes/channels.php` que fue creado por el comando Artisan `install:broadcasting`. En este archivo, puedes usar el método `Broadcast::channel` para registrar los callbacks de autorización del canal:


```php
use App\Models\User;

Broadcast::channel('orders.{orderId}', function (User $user, int $orderId) {
    return $user->id === Order::findOrNew($orderId)->user_id;
});
```
El método `channel` acepta два аргумента: el nombre del canal y un callback que devuelve `true` o `false`, indicando si el usuario está autorizado a escuchar en el canal.
Todos los callbacks de autorización reciben al usuario autenticado actualmente como su primer argumento y cualquier parámetro adicional como argumentos subsecuentes. En este ejemplo, estamos utilizando el placeholder `{orderId}` para indicar que la porción "ID" del nombre del canal es un comodín.
Puedes ver una lista de los callbacks de autorización de difusión de tu aplicación utilizando el comando Artisan `channel:list`:


```shell
php artisan channel:list

```

<a name="authorization-callback-model-binding"></a>
#### Vinculación de Modelo de Callback de Autorización

Al igual que las rutas HTTP, las rutas de canal también pueden aprovechar el [enlazado de modelos de ruta](/docs/%7B%7Bversion%7D%7D/routing#route-model-binding) implícito y explícito. Por ejemplo, en lugar de recibir un ID de orden en formato de cadena o numérico, puedes solicitar una instancia real del modelo `Order`:


```php
use App\Models\Order;
use App\Models\User;

Broadcast::channel('orders.{order}', function (User $user, Order $order) {
    return $user->id === $order->user_id;
});
```
> [!WARNING]
A diferencia del enlace de modelo implícito de rutas HTTP, el enlace de modelo de canal no admite el [alcance de enlace de modelo implícito](/docs/%7B%7Bversion%7D%7D/routing#implicit-model-binding-scoping) automático. Sin embargo, esto rara vez es un problema porque la mayoría de los canales se pueden limitar según la clave principal única de un solo modelo.

<a name="authorization-callback-authentication"></a>
#### Autenticación de Callback de Autorización

Los canales de difusión privados y de presencia autentican al usuario actual a través del guardia de autenticación predeterminado de tu aplicación. Si el usuario no está autenticado, la autorización del canal se niega automáticamente y el callback de autorización nunca se ejecuta. Sin embargo, puedes asignar múltiples guardias personalizados que deberían autenticar la solicitud entrante si es necesario:


```php
Broadcast::channel('channel', function () {
    // ...
}, ['guards' => ['web', 'admin']]);
```

<a name="defining-channel-classes"></a>
### Definiendo Clases de Canal

Si tu aplicación está consumiendo muchos canales diferentes, tu archivo `routes/channels.php` podría volverse voluminoso. Así que, en lugar de usar funciones anónimas para autorizar canales, puedes usar clases de canal. Para generar una clase de canal, usa el comando Artisan `make:channel`. Este comando colocará una nueva clase de canal en el directorio `App/Broadcasting`.


```shell
php artisan make:channel OrderChannel

```
A continuación, registra tu canal en el archivo `routes/channels.php`:


```php
use App\Broadcasting\OrderChannel;

Broadcast::channel('orders.{order}', OrderChannel::class);
```
Finalmente, puedes colocar la lógica de autorización para tu canal en el método `join` de la clase del canal. Este método `join` albergará la misma lógica que normalmente habrías colocado en tu función anónima de autorización del canal. También puedes aprovechar el enlace de modelo del canal:


```php
<?php

namespace App\Broadcasting;

use App\Models\Order;
use App\Models\User;

class OrderChannel
{
    /**
     * Create a new channel instance.
     */
    public function __construct()
    {
        // ...
    }

    /**
     * Authenticate the user's access to the channel.
     */
    public function join(User $user, Order $order): array|bool
    {
        return $user->id === $order->user_id;
    }
}
```
> [!NOTA]
Al igual que muchas otras clases en Laravel, las clases de canal serán resueltas automáticamente por el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container). Así que puedes indicar cualquier dependencia requerida por tu canal en su constructor.

<a name="broadcasting-events"></a>
## Transmitiendo Eventos

Una vez que hayas definido un evento y lo hayas marcado con la interfaz `ShouldBroadcast`, solo necesitas disparar el evento utilizando el método de despacho del evento. El despachador de eventos notará que el evento está marcado con la interfaz `ShouldBroadcast` y pondrá el evento en cola para su difusión:


```php
use App\Events\OrderShipmentStatusUpdated;

OrderShipmentStatusUpdated::dispatch($order);
```

<a name="only-to-others"></a>
### Solo a Otros

Al construir una aplicación que utiliza la transmisión de eventos, es posible que ocasionalmente necesites transmitir un evento a todos los suscriptores de un canal dado, excepto al usuario actual. Puedes lograr esto utilizando el helper `broadcast` y el método `toOthers`:


```php
use App\Events\OrderShipmentStatusUpdated;

broadcast(new OrderShipmentStatusUpdated($update))->toOthers();
```
Para entender mejor cuándo puede que desees usar el método `toOthers`, imaginemos una aplicación de lista de tareas donde un usuario puede crear una nueva tarea ingresando un nombre de tarea. Para crear una tarea, tu aplicación podría hacer una solicitud a una URL `/task` que difunde la creación de la tarea y devuelve una representación JSON de la nueva tarea. Cuando tu aplicación JavaScript recibe la respuesta del punto final, podría insertar directamente la nueva tarea en su lista de tareas de la siguiente manera:


```js
axios.post('/task', task)
    .then((response) => {
        this.tasks.push(response.data);
    });

```
Sin embargo, recuerda que también emitimos la creación de la tarea. Si tu aplicación JavaScript también está escuchando este evento para añadir tareas a la lista de tareas, tendrás tareas duplicadas en tu lista: una desde el punto final y otra desde la transmisión. Puedes resolver esto utilizando el método `toOthers` para instruir al emisor a no difundir el evento al usuario actual.
> [!WARNING]
Tu evento debe usar el trait `Illuminate\Broadcasting\InteractsWithSockets` para poder llamar al método `toOthers`.

<a name="only-to-others-configuration"></a>
#### Configuración

Cuando inicializas una instancia de Laravel Echo, se asigna un ID de socket a la conexión. Si estás utilizando una instancia global de [Axios](https://github.com/mzabriskie/axios) para realizar solicitudes HTTP desde tu aplicación JavaScript, el ID de socket se adjuntará automáticamente a cada solicitud saliente como un encabezado `X-Socket-ID`. Luego, cuando llames al método `toOthers`, Laravel extraerá el ID de socket del encabezado e instruirá al servicio de difusión a que no envíe a ninguna conexión con ese ID de socket.
Si no estás utilizando una instancia global de Axios, necesitarás configurar manualmente tu aplicación JavaScript para enviar el encabezado `X-Socket-ID` con todas las solicitudes salientes. Puedes recuperar el ID del socket utilizando el método `Echo.socketId`:


```js
var socketId = Echo.socketId();

```

<a name="customizing-the-connection"></a>
### Personalizando la Conexión

Si tu aplicación interactúa con múltiples conexiones de transmisión y deseas transmitir un evento utilizando un transmisor diferente al predeterminado, puedes especificar a qué conexión enviar un evento utilizando el método `via`:


```php
use App\Events\OrderShipmentStatusUpdated;

broadcast(new OrderShipmentStatusUpdated($update))->via('pusher');
```
Alternativamente, puedes especificar la conexión de difusión del evento llamando al método `broadcastVia` dentro del constructor del evento. Sin embargo, antes de hacerlo, debes asegurarte de que la clase del evento utilice el trait `InteractsWithBroadcasting`:


```php
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
     * Create a new event instance.
     */
    public function __construct()
    {
        $this->broadcastVia('pusher');
    }
}
```

<a name="anonymous-events"></a>
### Eventos Anónimos

A veces, es posible que desees transmitir un evento simple a la interfaz de tu aplicación sin crear una clase de evento dedicada. Para acomodar esto, la fachada `Broadcast` te permite transmitir "eventos anónimos":


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
El ejemplo anterior emitirá un evento como el siguiente:


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
Transmitir un evento anónimo utilizando el método `send` despacha el evento a la [cola](/docs/%7B%7Bversion%7D%7D/queues) de tu aplicación para su procesamiento. Sin embargo, si deseas transmitir el evento de inmediato, puedes usar el método `sendNow`:


```php
Broadcast::on('orders.'.$order->id)->sendNow();

```
Para transmitir el evento a todos los suscriptores del canal excepto al usuario autenticado actualmente, puedes invocar el método `toOthers`:


```php
Broadcast::on('orders.'.$order->id)
    ->toOthers()
    ->send();

```

<a name="receiving-broadcasts"></a>
## Recibiendo Difusiones


<a name="listening-for-events"></a>
### Escuchando Eventos

Una vez que hayas [instalado e instanciado Laravel Echo](#client-side-installation), estás listo para comenzar a escuchar los eventos que se transmiten desde tu aplicación Laravel. Primero, usa el método `channel` para recuperar una instancia de un canal, luego llama al método `listen` para escuchar un evento específico:


```js
Echo.channel(`orders.${this.order.id}`)
    .listen('OrderShipmentStatusUpdated', (e) => {
        console.log(e.order.name);
    });

```
Si deseas escuchar eventos en un canal privado, utiliza en su lugar el método `private`. Puedes seguir encadenando llamadas al método `listen` para escuchar múltiples eventos en un solo canal:


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

Para salir de un canal, puedes llamar al método `leaveChannel` en tu instancia de Echo:


```js
Echo.leaveChannel(`orders.${this.order.id}`);

```
Si deseas abandonar un canal y también sus canales privados y de presencia asociados, puedes llamar al método `leave`:


```js
Echo.leave(`orders.${this.order.id}`);

```

<a name="namespaces"></a>
### Espacios de nombres

Es posible que hayas notado en los ejemplos anteriores que no especificamos el espacio de nombres completo `App\Events` para las clases de eventos. Esto se debe a que Echo asumirá automáticamente que los eventos se encuentran en el espacio de nombres `App\Events`. Sin embargo, puedes configurar el espacio de nombres raíz cuando instancias Echo pasando una opción de configuración `namespace`:


```js
window.Echo = new Echo({
    broadcaster: 'pusher',
    // ...
    namespace: 'App.Other.Namespace'
});

```
Alternativamente, puedes prefijar las clases de evento con un `.` al suscribirte a ellas utilizando Echo. Esto te permitirá especificar siempre el nombre de la clase completamente cualificada:


```js
Echo.channel('orders')
    .listen('.Namespace\\Event\\Class', (e) => {
        // ...
    });

```

<a name="presence-channels"></a>
## Canales de Presencia

Los canales de presencia se basan en la seguridad de los canales privados mientras exponen la característica adicional de saber quién está suscrito al canal. Esto facilita la construcción de potentes funcionalidades de aplicación colaborativa, como notificar a los usuarios cuando otro usuario está viendo la misma página o listar a los habitantes de una sala de chat.

<a name="authorizing-presence-channels"></a>
### Autorización de Canales de Presencia

Todos los canales de presencia también son canales privados; por lo tanto, los usuarios deben ser [autorizados para acceder a ellos](#authorizing-channels). Sin embargo, al definir callbacks de autorización para los canales de presencia, no devolverás `true` si el usuario está autorizado para unirse al canal. En su lugar, deberías devolver un array de datos sobre el usuario.
Los datos devueltos por la callback de autorización estarán disponibles para los escuchadores de eventos del canal de presencia en tu aplicación JavaScript. Si el usuario no está autorizado para unirse al canal de presencia, debes devolver `false` o `null`:


```php
use App\Models\User;

Broadcast::channel('chat.{roomId}', function (User $user, int $roomId) {
    if ($user->canJoinRoom($roomId)) {
        return ['id' => $user->id, 'name' => $user->name];
    }
});
```

<a name="joining-presence-channels"></a>
### Unirse a Canales de Presencia

Para unirte a un canal de presencia, puedes usar el método `join` de Echo. El método `join` devolverá una implementación de `PresenceChannel` que, junto con exponer el método `listen`, te permite suscribirte a los eventos `here`, `joining` y `leaving`.


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
El callback `here` se ejecutará de inmediato una vez que el canal se haya unido con éxito, y recibirá un array que contiene la información del usuario de todos los otros usuarios que están actualmente suscritos al canal. El método `joining` se ejecutará cuando un nuevo usuario se una a un canal, mientras que el método `leaving` se ejecutará cuando un usuario salga del canal. El método `error` se ejecutará cuando el endpoint de autenticación devuelva un código de estado HTTP diferente a 200 o si hay un problema al analizar el JSON devuelto.

<a name="broadcasting-to-presence-channels"></a>
### Transmitiendo a Canales de Presencia

Los canales de presencia pueden recibir eventos al igual que los canales públicos o privados. Usando el ejemplo de un chat, es posible que queramos transmitir eventos `NewMessage` al canal de presencia de la sala. Para hacerlo, devolveremos una instancia de `PresenceChannel` desde el método `broadcastOn` del evento:


```php
/**
 * Get the channels the event should broadcast on.
 *
 * @return array<int, \Illuminate\Broadcasting\Channel>
 */
public function broadcastOn(): array
{
    return [
        new PresenceChannel('chat.'.$this->message->room_id),
    ];
}
```
Al igual que con otros eventos, puedes usar el helper `broadcast` y el método `toOthers` para excluir al usuario actual de recibir la transmisión:


```php
broadcast(new NewMessage($message));

broadcast(new NewMessage($message))->toOthers();
```
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
## Transmitiendo Modelos

> [!WARNING]
Antes de leer la siguiente documentación sobre la difusión de modelos, te recomendamos que te familiarices con los conceptos generales de los servicios de difusión de modelos de Laravel, así como con cómo crear y escuchar manualmente eventos de difusión.
Es común transmitir eventos cuando se crean, actualizan o eliminan los [modelos Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent) de tu aplicación. Por supuesto, esto se puede lograr fácilmente definiendo manualmente [eventos personalizados para los cambios de estado del modelo Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent#events) y marcando esos eventos con la interfaz `ShouldBroadcast`.
Sin embargo, si no estás utilizando estos eventos para otros propósitos en tu aplicación, puede ser tedioso crear clases de evento con el único propósito de transmitirlas. Para remedy esto, Laravel te permite indicar que un modelo Eloquent debería transmitir automáticamente sus cambios de estado.
Para empezar, tu modelo Eloquent debe usar el trait `Illuminate\Database\Eloquent\BroadcastsEvents`. Además, el modelo debe definir un método `broadcastOn`, que devolverá un array de canales en los que los eventos del modelo deben ser transmitidos:


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
Una vez que tu modelo incluya este rasgo y defina sus canales de difusión, comenzará a transmitir automáticamente eventos cuando se cree, actualice, elimine, envase o restaure una instancia del modelo.
Además, es posible que hayas notado que el método `broadcastOn` recibe un argumento de cadena `$event`. Este argumento contiene el tipo de evento que ha ocurrido en el modelo y tendrá un valor de `created`, `updated`, `deleted`, `trashed` o `restored`. Al inspeccionar el valor de esta variable, puedes determinar a qué canales (si los hay) debe transmitir el modelo para un evento particular:


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
#### Personalizando la Creación de Eventos de Difusión de Modelos

Ocasionalmente, es posible que desees personalizar cómo Laravel crea el evento de difusión de modelo subyacente. Puedes lograr esto definiendo un método `newBroadcastableEvent` en tu modelo Eloquent. Este método debe devolver una instancia de `Illuminate\Database\Eloquent\BroadcastableModelEventOccurred`:


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
#### Convenciones de Canal

Como habrás notado, el método `broadcastOn` en el ejemplo del modelo anterior no devolvió instancias de `Channel`. En su lugar, se devolvieron directamente modelos Eloquent. Si una instancia de modelo Eloquent es devuelta por el método `broadcastOn` de tu modelo (o está contenida en un array devuelto por el método), Laravel instanciará automáticamente una instancia de canal privado para el modelo utilizando el nombre de la clase del modelo y el identificador de clave primaria como el nombre del canal.
Entonces, un modelo `App\Models\User` con un `id` de `1` se convertiría en una instancia de `Illuminate\Broadcasting\PrivateChannel` con un nombre de `App.Models.User.1`. Por supuesto, además de devolver instancias de modelos Eloquent desde el método `broadcastOn` de tu modelo, puedes devolver instancias completas de `Channel` para tener un control total sobre los nombres de los canales del modelo:


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
Si planeas devolver explícitamente una instancia de canal desde el método `broadcastOn` de tu modelo, puedes pasar una instancia del modelo Eloquent al constructor del canal. Al hacerlo, Laravel utilizará las convenciones de canal del modelo discutidas anteriormente para convertir el modelo Eloquent en una cadena de nombre de canal:


```php
return [new Channel($this->user)];

```
Si necesitas determinar el nombre del canal de un modelo, puedes llamar al método `broadcastChannel` en cualquier instancia del modelo. Por ejemplo, este método devuelve la cadena `App.Models.User.1` para un modelo `App\Models\User` con un `id` de `1`:


```php
$user->broadcastChannel()

```

<a name="model-broadcasting-event-conventions"></a>
#### Convenciones de Eventos

Dado que los eventos de transmisión del modelo no están asociados con un evento "real" dentro del directorio `App\Events` de tu aplicación, se les asigna un nombre y una carga útil basados en convenciones. La convención de Laravel es transmitir el evento utilizando el nombre de la clase del modelo (sin incluir el espacio de nombres) y el nombre del evento del modelo que activó la transmisión.
Entonces, por ejemplo, una actualización al modelo `App\Models\Post` transmitiría un evento a tu aplicación del lado del cliente como `PostUpdated` con la siguiente carga útil:


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
Si lo deseas, puedes definir un nombre de transmisión y una carga útil personalizados añadiendo un método `broadcastAs` y `broadcastWith` a tu modelo. Estos métodos reciben el nombre del evento / operación del modelo que está ocurriendo, lo que te permite personalizar el nombre del evento y la carga útil para cada operación del modelo. Si el método `broadcastAs` devuelve `null`, Laravel utilizará las convenciones de nombres de eventos de transmisión del modelo discutidas arriba al transmitir el evento:


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

Una vez que hayas añadido el trait `BroadcastsEvents` a tu modelo y definido el método `broadcastOn` de tu modelo, estás listo para comenzar a escuchar eventos de modelo transmitidos en tu aplicación del lado del cliente. Antes de empezar, es posible que desees consultar la documentación completa sobre [escuchar eventos](#listening-for-events).
Primero, utiliza el método `private` para recuperar una instancia de un canal, luego llama al método `listen` para escuchar un evento especificado. Típicamente, el nombre del canal dado al método `private` debe corresponder a las [convenios de difusión de modelos](#model-broadcasting-conventions) de Laravel.
Una vez que hayas obtenido una instancia de canal, puedes usar el método `listen` para escuchar un evento particular. Dado que los eventos de transmisión de modelos no están asociados con un evento "real" dentro del directorio `App\Events` de tu aplicación, el [nombre del evento](#model-broadcasting-event-conventions) debe llevar un prefijo `.` para indicar que no pertenece a un espacio de nombres particular. Cada evento de transmisión de modelo tiene una propiedad `model` que contiene todas las propiedades transmitibles del modelo:


```js
Echo.private(`App.Models.User.${this.user.id}`)
    .listen('.PostUpdated', (e) => {
        console.log(e.model);
    });

```

<a name="client-events"></a>
## Eventos del Cliente

> [!NOTA]
Al utilizar [Pusher Channels](https://pusher.com/channels), debes habilitar la opción "Eventos de Cliente" en la sección "Configuración de la Aplicación" de tu [tablero de aplicaciones](https://dashboard.pusher.com/) para poder enviar eventos de cliente.
A veces puede que desees transmitir un evento a otros clientes conectados sin contactar en absoluto tu aplicación Laravel. Esto puede ser particularmente útil para cosas como notificaciones de "escribiendo", donde deseas alertar a los usuarios de tu aplicación que otro usuario está escribiendo un mensaje en una pantalla dada.
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

Al combinar la transmisión de eventos con [notificaciones](/docs/%7B%7Bversion%7D%7D/notifications), tu aplicación JavaScript puede recibir nuevas notificaciones a medida que ocurren sin necesidad de actualizar la página. Antes de comenzar, asegúrate de leer la documentación sobre el uso del [canal de notificación de transmisión](/docs/%7B%7Bversion%7D%7D/notifications#broadcast-notifications).
Una vez que hayas configurado una notificación para usar el canal de transmisión, puedes escuchar los eventos de transmisión utilizando el método `notification` de Echo. Recuerda, el nombre del canal debe coincidir con el nombre de la clase de la entidad que recibe las notificaciones:


```js
Echo.private(`App.Models.User.${userId}`)
    .notification((notification) => {
        console.log(notification.type);
    });

```
En este ejemplo, todas las notificaciones enviadas a las instancias de `App\Models\User` a través del canal `broadcast` serían recibidas por el callback. Un callback de autorización de canal para el canal `App.Models.User.{id}` está incluido en el archivo `routes/channels.php` de tu aplicación.