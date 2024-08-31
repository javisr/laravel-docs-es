# Eventos

- [Introducción](#introduction)
- [Generando Eventos y Listenadores](#generating-events-and-listeners)
- [Registrando Eventos y Listenadores](#registering-events-and-listeners)
  - [Descubrimiento de Eventos](#event-discovery)
  - [Registrando Eventos Manualmente](#manually-registering-events)
  - [Listenadores de Función Anónima](#closure-listeners)
- [Definiendo Eventos](#defining-events)
- [Definiendo Listenadores](#defining-listeners)
- [Listenadores de Eventos en Cola](#queued-event-listeners)
  - [Interactuando Manualmente con la Cola](#manually-interacting-with-the-queue)
  - [Listenadores de Eventos en Cola y Transacciones de Base de Datos](#queued-event-listeners-and-database-transactions)
  - [Manejando Trabajos Fallidos](#handling-failed-jobs)
- [Despachando Eventos](#dispatching-events)
  - [Despachando Eventos Después de Transacciones de Base de Datos](#dispatching-events-after-database-transactions)
- [Suscriptores de Eventos](#event-subscribers)
  - [Escribiendo Suscriptores de Eventos](#writing-event-subscribers)
  - [Registrando Suscriptores de Eventos](#registering-event-subscribers)
- [Pruebas](#testing)
  - [Simulando un Conjunto de Eventos](#faking-a-subset-of-events)
  - [Simulaciones de Eventos con Ámbito](#scoped-event-fakes)

<a name="introduction"></a>
## Introducción

Los eventos de Laravel proporcionan una implementación simple del patrón observador, lo que te permite suscribirte y escuchar varios eventos que ocurren dentro de tu aplicación. Las clases de eventos se almacenan típicamente en el directorio `app/Events`, mientras que sus oyentes se almacenan en `app/Listeners`. No te preocupes si no ves estos directorios en tu aplicación, ya que se crearán para ti a medida que generes eventos y oyentes utilizando comandos de consola Artisan.
Los eventos son una excelente manera de desacoplar varios aspectos de tu aplicación, ya que un solo evento puede tener múltiples oyentes que no dependen entre sí. Por ejemplo, puede que desees enviar una notificación de Slack a tu usuario cada vez que se haya enviado un pedido. En lugar de acoplar tu código de procesamiento de pedidos a tu código de notificación de Slack, puedes disparar un evento `App\Events\OrderShipped` que un oyente puede recibir y usar para despachar una notificación de Slack.

<a name="generating-events-and-listeners"></a>
## Generando Eventos y Escuchas

Para generar rápidamente eventos y oyentes, puedes usar los comandos Artisan `make:event` y `make:listener`:


```shell
php artisan make:event PodcastProcessed

php artisan make:listener SendPodcastNotification --event=PodcastProcessed

```
Para mayor comodidad, también puedes invocar los comandos Artisan `make:event` y `make:listener` sin argumentos adicionales. Cuando lo hagas, Laravel te pedirá automáticamente el nombre de la clase y, al crear un listener, el evento al que debe escuchar:


```shell
php artisan make:event

php artisan make:listener

```

<a name="registering-events-and-listeners"></a>
## Registrando Eventos y Escuchadores


<a name="event-discovery"></a>
### Descubrimiento de Eventos

Por defecto, Laravel encontrará y registrará automáticamente tus oyentes de eventos escaneando el directorio `Listeners` de tu aplicación. Cuando Laravel encuentre cualquier método de clase oyente que comience con `handle` o `__invoke`, Laravel registrará esos métodos como oyentes de eventos para el evento que está tipado en la firma del método:


```php
use App\Events\PodcastProcessed;

class SendPodcastNotification
{
    /**
     * Handle the given event.
     */
    public function handle(PodcastProcessed $event): void
    {
        // ...
    }
}
```
Si planeas almacenar tus oyentes en un directorio diferente o dentro de múltiples directorios, puedes instruir a Laravel para que escanee esos directorios utilizando el método `withEvents` en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withEvents(discover: [
    __DIR__.'/../app/Domain/Orders/Listeners',
])
```

<a name="event-discovery-in-production"></a>
#### Descubrimiento de Eventos en Producción

Para darle un impulso de velocidad a tu aplicación, deberías almacenar en caché un manifiesto de todos los oyentes de tu aplicación utilizando los comandos Artisan `optimize` o `event:cache`. Típicamente, este comando debe ejecutarse como parte del [proceso de despliegue](/docs/%7B%7Bversion%7D%7D/deployment#optimization) de tu aplicación. Este manifiesto será utilizado por el framework para acelerar el proceso de registro de eventos. El comando `event:clear` puede usarse para destruir la caché de eventos.

<a name="manually-registering-events"></a>
### Registrando Eventos Manualmente

Usando la facade `Event`, puedes registrar manualmente eventos y sus correspondientes oyentes dentro del método `boot` del `AppServiceProvider` de tu aplicación:


```php
use App\Domain\Orders\Events\PodcastProcessed;
use App\Domain\Orders\Listeners\SendPodcastNotification;
use Illuminate\Support\Facades\Event;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Event::listen(
        PodcastProcessed::class,
        SendPodcastNotification::class,
    );
}
```
El comando `event:list` se puede utilizar para listar todos los escuchas registrados dentro de tu aplicación:


```shell
php artisan event:list

```

<a name="closure-listeners"></a>
### Listeners de Funciones Anónimas

Típicamente, los listeners se definen como clases; sin embargo, también puedes registrar manualmente listeners de eventos basados en funciones anónimas en el método `boot` del `AppServiceProvider` de tu aplicación:


```php
use App\Events\PodcastProcessed;
use Illuminate\Support\Facades\Event;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Event::listen(function (PodcastProcessed $event) {
        // ...
    });
}
```

<a name="queuable-anonymous-event-listeners"></a>
#### Listeners de Eventos Anónimos en Cola

Al registrar oyentes de eventos basados en funciones anónimas, puedes envolver la función anónima del oyente dentro de la función `Illuminate\Events\queueable` para instruir a Laravel a que ejecute el oyente utilizando la [cola](/docs/%7B%7Bversion%7D%7D/queues):


```php
use App\Events\PodcastProcessed;
use function Illuminate\Events\queueable;
use Illuminate\Support\Facades\Event;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Event::listen(queueable(function (PodcastProcessed $event) {
        // ...
    }));
}
```
Al igual que los trabajos en cola, puedes usar los métodos `onConnection`, `onQueue` y `delay` para personalizar la ejecución del oyente en cola:


```php
Event::listen(queueable(function (PodcastProcessed $event) {
    // ...
})->onConnection('redis')->onQueue('podcasts')->delay(now()->addSeconds(10)));
```
Si deseas manejar los fallos de los oyentes en cola anónimos, puedes proporcionar una función anónima al método `catch` mientras defines el oyente `queueable`. Esta función anónima recibirá la instancia del evento y la instancia `Throwable` que causó el fallo del oyente:


```php
use App\Events\PodcastProcessed;
use function Illuminate\Events\queueable;
use Illuminate\Support\Facades\Event;
use Throwable;

Event::listen(queueable(function (PodcastProcessed $event) {
    // ...
})->catch(function (PodcastProcessed $event, Throwable $e) {
    // The queued listener failed...
}));
```

<a name="wildcard-event-listeners"></a>
#### Escuchadores de Eventos con Comodín

También puedes registrar oyentes utilizando el carácter `*` como parámetro comodín, lo que te permite capturar múltiples eventos en el mismo oyente. Los oyentes comodín reciben el nombre del evento como su primer argumento y el array completo de datos del evento como su segundo argumento:


```php
Event::listen('event.*', function (string $eventName, array $data) {
    // ...
});
```

<a name="defining-events"></a>
## Definición de Eventos

Una clase de evento es esencialmente un contenedor de datos que contiene la información relacionada con el evento. Por ejemplo, supongamos que un evento `App\Events\OrderShipped` recibe un objeto [Eloquent ORM](/docs/%7B%7Bversion%7D%7D/eloquent):


```php
<?php

namespace App\Events;

use App\Models\Order;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class OrderShipped
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * Create a new event instance.
     */
    public function __construct(
        public Order $order,
    ) {}
}
```
Como puedes ver, esta clase de evento no contiene lógica. Es un contenedor para la instancia de `App\Models\Order` que fue comprada. El trait `SerializesModels` utilizado por el evento serializará de manera elegante cualquier modelo Eloquent si el objeto del evento se serializa utilizando la función `serialize` de PHP, como al utilizar [listeners en cola](#queued-event-listeners).

<a name="defining-listeners"></a>
## Definiendo Escuchas

A continuación, echemos un vistazo al listener para nuestro evento de ejemplo. Los listeners de eventos reciben instancias de eventos en su método `handle`. El comando Artisan `make:listener`, cuando se invoca con la opción `--event`, importará automáticamente la clase de evento adecuada y sugerirá el tipo del evento en el método `handle`. Dentro del método `handle`, puedes realizar cualquier acción necesaria para responder al evento:


```php
<?php

namespace App\Listeners;

use App\Events\OrderShipped;

class SendShipmentNotification
{
    /**
     * Create the event listener.
     */
    public function __construct()
    {
        // ...
    }

    /**
     * Handle the event.
     */
    public function handle(OrderShipped $event): void
    {
        // Access the order using $event->order...
    }
}
```
> [!NOTA]
Sus oyentes de eventos también pueden indicar cualquier dependencia que necesiten en sus constructores. Todos los oyentes de eventos se resuelven a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel, así que las dependencias se inyectarán automáticamente.

<a name="stopping-the-propagation-of-an-event"></a>
#### Deteniendo la Propagación de un Evento

A veces, es posible que desees detener la propagación de un evento a otros oyentes. Puedes hacerlo devolviendo `false` desde el método `handle` de tu oyente.

<a name="queued-event-listeners"></a>
## Listeners de Eventos en Cola

Realizar un encolado de oyentes puede ser beneficioso si tu oyente va a realizar una tarea lenta, como enviar un correo electrónico o hacer una solicitud HTTP. Antes de usar oyentes encolados, asegúrate de [configurar tu cola](/docs/%7B%7Bversion%7D%7D/queues) y de iniciar un trabajador de cola en tu servidor o entorno de desarrollo local.
Para especificar que un listener debe ser encolado, añade la interfaz `ShouldQueue` a la clase del listener. Los listeners generados por los comandos Artisan `make:listener` ya tienen esta interfaz importada en el espacio de nombres actual, por lo que puedes usarla de inmediato:


```php
<?php

namespace App\Listeners;

use App\Events\OrderShipped;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendShipmentNotification implements ShouldQueue
{
    // ...
}
```
¡Eso es! Ahora, cuando se despacha un evento manejado por este listener, el listener será automáticamente encolado por el despachador de eventos utilizando el [sistema de colas](/docs/%7B%7Bversion%7D%7D/queues) de Laravel. Si no se lanzan excepciones cuando se ejecuta el listener en la cola, el trabajo encolado se eliminará automáticamente después de haber terminado de procesarse.

<a name="customizing-the-queue-connection-queue-name"></a>
#### Personalizando la Conexión de Cola, Nombre y Retraso

Si deseas personalizar la conexión de la cola, el nombre de la cola o el tiempo de retraso de la cola de un escuchador de eventos, puedes definir las propiedades `$connection`, `$queue` o `$delay` en tu clase de listener:


```php
<?php

namespace App\Listeners;

use App\Events\OrderShipped;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendShipmentNotification implements ShouldQueue
{
    /**
     * The name of the connection the job should be sent to.
     *
     * @var string|null
     */
    public $connection = 'sqs';

    /**
     * The name of the queue the job should be sent to.
     *
     * @var string|null
     */
    public $queue = 'listeners';

    /**
     * The time (seconds) before the job should be processed.
     *
     * @var int
     */
    public $delay = 60;
}
```
Si deseas definir la conexión de la cola del oyente, el nombre de la cola o el retraso en tiempo de ejecución, puedes definir los métodos `viaConnection`, `viaQueue` o `withDelay` en el oyente:


```php
/**
 * Get the name of the listener's queue connection.
 */
public function viaConnection(): string
{
    return 'sqs';
}

/**
 * Get the name of the listener's queue.
 */
public function viaQueue(): string
{
    return 'listeners';
}

/**
 * Get the number of seconds before the job should be processed.
 */
public function withDelay(OrderShipped $event): int
{
    return $event->highPriority ? 0 : 60;
}
```

<a name="conditionally-queueing-listeners"></a>
#### Encolando Escuchas de Forma Condicional

A veces, es posible que necesites determinar si un oyente debe ser encolado en función de algunos datos que solo están disponibles en tiempo de ejecución. Para lograr esto, se puede agregar un método `shouldQueue` a un oyente para determinar si el oyente debe ser encolado. Si el método `shouldQueue` devuelve `false`, el oyente no será encolado:


```php
<?php

namespace App\Listeners;

use App\Events\OrderCreated;
use Illuminate\Contracts\Queue\ShouldQueue;

class RewardGiftCard implements ShouldQueue
{
    /**
     * Reward a gift card to the customer.
     */
    public function handle(OrderCreated $event): void
    {
        // ...
    }

    /**
     * Determine whether the listener should be queued.
     */
    public function shouldQueue(OrderCreated $event): bool
    {
        return $event->order->subtotal >= 5000;
    }
}
```

<a name="manually-interacting-with-the-queue"></a>
### Interactuando Manualmente con la Cola

Si necesitas acceder manualmente a los métodos `delete` y `release` del trabajo en cola subyacente del listener, puedes hacerlo utilizando el trait `Illuminate\Queue\InteractsWithQueue`. Este trait se importa por defecto en los listeners generados y proporciona acceso a estos métodos:


```php
<?php

namespace App\Listeners;

use App\Events\OrderShipped;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class SendShipmentNotification implements ShouldQueue
{
    use InteractsWithQueue;

    /**
     * Handle the event.
     */
    public function handle(OrderShipped $event): void
    {
        if (true) {
            $this->release(30);
        }
    }
}
```

<a name="queued-event-listeners-and-database-transactions"></a>
### Listeners de Eventos en Cola y Transacciones de Base de Datos

Cuando los oyentes en cola se despachan dentro de transacciones de base de datos, pueden ser procesados por la cola antes de que la transacción de la base de datos se haya cometido. Cuando esto sucede, cualquier actualización que hayas realizado en modelos o registros de la base de datos durante la transacción de la base de datos puede no estar aún reflejada en la base de datos. Además, cualquier modelo o registro de la base de datos creado dentro de la transacción puede no existir en la base de datos. Si tu oyente depende de estos modelos, pueden ocurrir errores inesperados cuando se procesa el trabajo que despacha el oyente en cola.
Si la opción de configuración `after_commit` de la conexión de tu cola está configurada en `false`, aún puedes indicar que un listener en particular en cola debe ser despachado después de que se hayan completado todas las transacciones de base de datos abiertas implementando la interfaz `ShouldQueueAfterCommit` en la clase del listener:


```php
<?php

namespace App\Listeners;

use Illuminate\Contracts\Queue\ShouldQueueAfterCommit;
use Illuminate\Queue\InteractsWithQueue;

class SendShipmentNotification implements ShouldQueueAfterCommit
{
    use InteractsWithQueue;
}
```
> [!NOTA]
Para obtener más información sobre cómo solucionar estos problemas, consulta la documentación sobre [trabajos en cola y transacciones de base de datos](/docs/%7B%7Bversion%7D%7D/queues#jobs-and-database-transactions).

<a name="handling-failed-jobs"></a>
### Manejo de Trabajos Fallidos

A veces, tus oyentes de eventos en cola pueden fallar. Si el oyente en cola excede el número máximo de intentos definido por tu trabajador de cola, se llamará al método `failed` en tu oyente. El método `failed` recibe la instancia del evento y el `Throwable` que causó el fallo:


```php
<?php

namespace App\Listeners;

use App\Events\OrderShipped;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Throwable;

class SendShipmentNotification implements ShouldQueue
{
    use InteractsWithQueue;

    /**
     * Handle the event.
     */
    public function handle(OrderShipped $event): void
    {
        // ...
    }

    /**
     * Handle a job failure.
     */
    public function failed(OrderShipped $event, Throwable $exception): void
    {
        // ...
    }
}
```

<a name="specifying-queued-listener-maximum-attempts"></a>
#### Especificando el Máximo de Intentos del Listener en Cola

Si uno de tus oyentes en cola está encontrando un error, probablemente no desees que siga intentando indefinidamente. Por lo tanto, Laravel proporciona varias formas de especificar cuántas veces o por cuánto tiempo se puede intentar un oyente.
Puedes definir una propiedad `$tries` en tu clase de listener para especificar cuántas veces se puede intentar el listener antes de que se considere que ha fallado:


```php
<?php

namespace App\Listeners;

use App\Events\OrderShipped;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class SendShipmentNotification implements ShouldQueue
{
    use InteractsWithQueue;

    /**
     * The number of times the queued listener may be attempted.
     *
     * @var int
     */
    public $tries = 5;
}
```
Como alternativa a definir cuántas veces se puede intentar un oyente antes de que falle, puedes definir un momento en el que ya no se debe intentar el oyente. Esto permite que se intente un oyente cualquier número de veces dentro de un marco de tiempo dado. Para definir el momento en el que ya no se debe intentar un oyente, añade un método `retryUntil` a tu clase de oyente. Este método debe devolver una instancia de `DateTime`:


```php
use DateTime;

/**
 * Determine the time at which the listener should timeout.
 */
public function retryUntil(): DateTime
{
    return now()->addMinutes(5);
}
```

<a name="dispatching-events"></a>
## Despachando Eventos

Para despachar un evento, puedes llamar al método estático `dispatch` en el evento. Este método está disponible en el evento mediante el rasgo `Illuminate\Foundation\Events\Dispatchable`. Cualquier argumento pasado al método `dispatch` se pasará al constructor del evento:


```php
<?php

namespace App\Http\Controllers;

use App\Events\OrderShipped;
use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class OrderShipmentController extends Controller
{
    /**
     * Ship the given order.
     */
    public function store(Request $request): RedirectResponse
    {
        $order = Order::findOrFail($request->order_id);

        // Order shipment logic...

        OrderShipped::dispatch($order);

        return redirect('/orders');
    }
}
```
Si deseas despachar un evento de forma condicional, puedes usar los métodos `dispatchIf` y `dispatchUnless`:


```php
OrderShipped::dispatchIf($condition, $order);

OrderShipped::dispatchUnless($condition, $order);
```
> [!NOTA]
Al realizar pruebas, puede ser útil afirmar que ciertos eventos fueron despachados sin activar realmente sus oyentes. Los [ayudantes de prueba integrados](#testing) de Laravel lo facilitan.

<a name="dispatching-events-after-database-transactions"></a>
### Despachando Eventos Después de Transacciones de Base de Datos

A veces, es posible que desees instruir a Laravel para que despache un evento solo después de que se haya confirmado la transacción activa de la base de datos. Para hacer esto, puedes implementar la interfaz `ShouldDispatchAfterCommit` en la clase del evento.
Esta interfaz instruye a Laravel a no despachar el evento hasta que se confirme la transacción de base de datos actual. Si la transacción falla, el evento será descartado. Si no hay una transacción de base de datos en curso cuando se despacha el evento, el evento se despachará de inmediato:


```php
<?php

namespace App\Events;

use App\Models\Order;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class OrderShipped implements ShouldDispatchAfterCommit
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * Create a new event instance.
     */
    public function __construct(
        public Order $order,
    ) {}
}
```

<a name="event-subscribers"></a>
## Suscriptores de Eventos


<a name="writing-event-subscribers"></a>
### Escribiendo Suscriptores de Eventos

Los suscriptores de eventos son clases que pueden suscribirse a múltiples eventos desde dentro de la propia clase del suscriptor, lo que te permite definir varios controladores de eventos dentro de una sola clase. Los suscriptores deben definir un método `subscribe`, al cual se le pasará una instancia del despachador de eventos. Puedes llamar al método `listen` en el despachador dado para registrar oyentes de eventos:


```php
<?php

namespace App\Listeners;

use Illuminate\Auth\Events\Login;
use Illuminate\Auth\Events\Logout;
use Illuminate\Events\Dispatcher;

class UserEventSubscriber
{
    /**
     * Handle user login events.
     */
    public function handleUserLogin(Login $event): void {}

    /**
     * Handle user logout events.
     */
    public function handleUserLogout(Logout $event): void {}

    /**
     * Register the listeners for the subscriber.
     */
    public function subscribe(Dispatcher $events): void
    {
        $events->listen(
            Login::class,
            [UserEventSubscriber::class, 'handleUserLogin']
        );

        $events->listen(
            Logout::class,
            [UserEventSubscriber::class, 'handleUserLogout']
        );
    }
}
```
Si tus métodos de escucha de eventos están definidos dentro del suscriptor mismo, puede que te resulte más conveniente devolver un array de eventos y nombres de métodos desde el método `subscribe` del suscriptor. Laravel determinará automáticamente el nombre de la clase del suscriptor al registrar los oyentes de eventos:


```php
<?php

namespace App\Listeners;

use Illuminate\Auth\Events\Login;
use Illuminate\Auth\Events\Logout;
use Illuminate\Events\Dispatcher;

class UserEventSubscriber
{
    /**
     * Handle user login events.
     */
    public function handleUserLogin(Login $event): void {}

    /**
     * Handle user logout events.
     */
    public function handleUserLogout(Logout $event): void {}

    /**
     * Register the listeners for the subscriber.
     *
     * @return array<string, string>
     */
    public function subscribe(Dispatcher $events): array
    {
        return [
            Login::class => 'handleUserLogin',
            Logout::class => 'handleUserLogout',
        ];
    }
}
```

<a name="registering-event-subscribers"></a>
### Registrando Suscriptores de Eventos

Después de escribir el suscriptor, estás listo para registrarlo con el despachador de eventos. Puedes registrar suscriptores utilizando el método `subscribe` de la fachada `Event`. Típicamente, esto debe hacerse dentro del método `boot` del `AppServiceProvider` de tu aplicación:


```php
<?php

namespace App\Providers;

use App\Listeners\UserEventSubscriber;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Event::subscribe(UserEventSubscriber::class);
    }
}
```

<a name="testing"></a>
## Pruebas

Al probar código que despacha eventos, es posible que desees instruir a Laravel para que no ejecute realmente los listeners del evento, ya que el código del listener se puede probar de manera directa y separada del código que despacha el evento correspondiente. Por supuesto, para probar el listener en sí, puedes instanciar una instancia del listener e invocar el método `handle` directamente en tu prueba.
Usando el método `fake` de la fachada `Event`, puedes evitar que los oyentes se ejecuten, ejecutar el código bajo prueba y luego afirmar qué eventos fueron despachados por tu aplicación utilizando los métodos `assertDispatched`, `assertNotDispatched` y `assertNothingDispatched`:


```php
<?php

use App\Events\OrderFailedToShip;
use App\Events\OrderShipped;
use Illuminate\Support\Facades\Event;

test('orders can be shipped', function () {
    Event::fake();

    // Perform order shipping...

    // Assert that an event was dispatched...
    Event::assertDispatched(OrderShipped::class);

    // Assert an event was dispatched twice...
    Event::assertDispatched(OrderShipped::class, 2);

    // Assert an event was not dispatched...
    Event::assertNotDispatched(OrderFailedToShip::class);

    // Assert that no events were dispatched...
    Event::assertNothingDispatched();
});

```


```php
<?php

namespace Tests\Feature;

use App\Events\OrderFailedToShip;
use App\Events\OrderShipped;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * Test order shipping.
     */
    public function test_orders_can_be_shipped(): void
    {
        Event::fake();

        // Perform order shipping...

        // Assert that an event was dispatched...
        Event::assertDispatched(OrderShipped::class);

        // Assert an event was dispatched twice...
        Event::assertDispatched(OrderShipped::class, 2);

        // Assert an event was not dispatched...
        Event::assertNotDispatched(OrderFailedToShip::class);

        // Assert that no events were dispatched...
        Event::assertNothingDispatched();
    }
}

```
Puedes pasar una función anónima a los métodos `assertDispatched` o `assertNotDispatched` para afirmar que se despachó un evento que pasa una prueba de "verdad" dada. Si se despachó al menos un evento que pasa la prueba de verdad dada, la afirmación será exitosa:


```php
Event::assertDispatched(function (OrderShipped $event) use ($order) {
    return $event->order->id === $order->id;
});
```
Si simplemente deseas afirmar que un listener de eventos está escuchando un evento dado, puedes usar el método `assertListening`:


```php
Event::assertListening(
    OrderShipped::class,
    SendShipmentNotification::class
);
```
> [!WARNING]
Después de llamar a `Event::fake()`, no se ejecutarán escuchadores de eventos. Así que, si tus pruebas usan fábricas de modelos que dependen de eventos, como crear un UUID durante un evento `creating` de un modelo, debes llamar a `Event::fake()` **después** de usar tus fábricas.

<a name="faking-a-subset-of-events"></a>
### Falsificando un Conjunto de Eventos

Si solo deseas simular escuchas de eventos para un conjunto específico de eventos, puedes pasarlos al método `fake` o `fakeFor`:


```php
test('orders can be processed', function () {
    Event::fake([
        OrderCreated::class,
    ]);

    $order = Order::factory()->create();

    Event::assertDispatched(OrderCreated::class);

    // Other events are dispatched as normal...
    $order->update([...]);
});

```


```php
/**
 * Test order process.
 */
public function test_orders_can_be_processed(): void
{
    Event::fake([
        OrderCreated::class,
    ]);

    $order = Order::factory()->create();

    Event::assertDispatched(OrderCreated::class);

    // Other events are dispatched as normal...
    $order->update([...]);
}

```
Puedes simular todos los eventos excepto un conjunto de eventos específicos utilizando el método `except`:


```php
Event::fake()->except([
    OrderCreated::class,
]);
```

<a name="scoped-event-fakes"></a>
### Fakes de Eventos con Alcance

Si solo deseas simular listeners de eventos por una porción de tu prueba, puedes usar el método `fakeFor`:


```php
<?php

use App\Events\OrderCreated;
use App\Models\Order;
use Illuminate\Support\Facades\Event;

test('orders can be processed', function () {
    $order = Event::fakeFor(function () {
        $order = Order::factory()->create();

        Event::assertDispatched(OrderCreated::class);

        return $order;
    });

    // Events are dispatched as normal and observers will run ...
    $order->update([...]);
});

```


```php
<?php

namespace Tests\Feature;

use App\Events\OrderCreated;
use App\Models\Order;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * Test order process.
     */
    public function test_orders_can_be_processed(): void
    {
        $order = Event::fakeFor(function () {
            $order = Order::factory()->create();

            Event::assertDispatched(OrderCreated::class);

            return $order;
        });

        // Events are dispatched as normal and observers will run ...
        $order->update([...]);
    }
}

```