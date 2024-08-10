# Eventos

- [Introducción](#introduction)
- [Generando Eventos y Listeners](#generating-events-and-listeners)
- [Registrando Eventos y Listeners](#registering-events-and-listeners)
    - [Descubrimiento de Eventos](#event-discovery)
    - [Registro Manual de Eventos](#manually-registering-events)
    - [Listeners de Funciones Anónimas](#closure-listeners)
- [Definiendo Eventos](#defining-events)
- [Definiendo Listeners](#defining-listeners)
- [Listeners de Eventos en Cola](#queued-event-listeners)
    - [Interacción Manual con la Cola](#manually-interacting-with-the-queue)
    - [Listeners de Eventos en Cola y Transacciones de Base de Datos](#queued-event-listeners-and-database-transactions)
    - [Manejo de Trabajos Fallidos](#handling-failed-jobs)
- [Despachando Eventos](#dispatching-events)
    - [Despachando Eventos Después de Transacciones de Base de Datos](#dispatching-events-after-database-transactions)
- [Suscriptores de Eventos](#event-subscribers)
    - [Escribiendo Suscriptores de Eventos](#writing-event-subscribers)
    - [Registrando Suscriptores de Eventos](#registering-event-subscribers)
- [Pruebas](#testing)
    - [Simulando un Subconjunto de Eventos](#faking-a-subset-of-events)
    - [Simulaciones de Eventos con Alcance](#scoped-event-fakes)

<a name="introduction"></a>
## Introducción

Los eventos de Laravel proporcionan una implementación simple del patrón observador, permitiéndote suscribirte y escuchar varios eventos que ocurren dentro de tu aplicación. Las clases de eventos se almacenan típicamente en el directorio `app/Events`, mientras que sus listeners se almacenan en `app/Listeners`. No te preocupes si no ves estos directorios en tu aplicación, ya que se crearán para ti a medida que generes eventos y listeners utilizando comandos de consola Artisan.

Los eventos sirven como una excelente manera de desacoplar varios aspectos de tu aplicación, ya que un solo evento puede tener múltiples listeners que no dependen entre sí. Por ejemplo, puedes desear enviar una notificación de Slack a tu usuario cada vez que un pedido haya sido enviado. En lugar de acoplar tu código de procesamiento de pedidos con tu código de notificación de Slack, puedes generar un evento `App\Events\OrderShipped` que un listener puede recibir y usar para despachar una notificación de Slack.

<a name="generating-events-and-listeners"></a>
## Generando Eventos y Listeners

Para generar rápidamente eventos y listeners, puedes usar los comandos Artisan `make:event` y `make:listener`:

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
## Registrando Eventos y Listeners

<a name="event-discovery"></a>
### Descubrimiento de Eventos

Por defecto, Laravel encontrará y registrará automáticamente tus listeners de eventos escaneando el directorio `Listeners` de tu aplicación. Cuando Laravel encuentra cualquier método de clase listener que comience con `handle` o `__invoke`, Laravel registrará esos métodos como listeners de eventos para el evento que está tipado en la firma del método:

    use App\Events\PodcastProcessed;

    class SendPodcastNotification
    {
        /**
         * Manejar el evento dado.
         */
        public function handle(PodcastProcessed $event): void
        {
            // ...
        }
    }

Si planeas almacenar tus listeners en un directorio diferente o dentro de múltiples directorios, puedes instruir a Laravel para que escanee esos directorios utilizando el método `withEvents` en el archivo `bootstrap/app.php` de tu aplicación:

    ->withEvents(discover: [
        __DIR__.'/../app/Domain/Orders/Listeners',
    ])

El comando `event:list` puede ser utilizado para listar todos los listeners registrados dentro de tu aplicación:

```shell
php artisan event:list
```

<a name="event-discovery-in-production"></a>
#### Descubrimiento de Eventos en Producción

Para darle un impulso de velocidad a tu aplicación, deberías almacenar en caché un manifiesto de todos los listeners de tu aplicación utilizando los comandos Artisan `optimize` o `event:cache`. Típicamente, este comando debería ejecutarse como parte de tu [proceso de despliegue](/docs/{{version}}/deployment#optimization). Este manifiesto será utilizado por el framework para acelerar el proceso de registro de eventos. El comando `event:clear` puede ser utilizado para destruir la caché de eventos.

<a name="manually-registering-events"></a>
### Registro Manual de Eventos

Usando el facade `Event`, puedes registrar manualmente eventos y sus listeners correspondientes dentro del método `boot` de tu `AppServiceProvider` de la aplicación:

    use App\Domain\Orders\Events\PodcastProcessed;
    use App\Domain\Orders\Listeners\SendPodcastNotification;
    use Illuminate\Support\Facades\Event;

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        Event::listen(
            PodcastProcessed::class,
            SendPodcastNotification::class,
        );
    }

El comando `event:list` puede ser utilizado para listar todos los listeners registrados dentro de tu aplicación:

```shell
php artisan event:list
```

<a name="closure-listeners"></a>
### Listeners de Funciones Anónimas

Típicamente, los listeners se definen como clases; sin embargo, también puedes registrar manualmente listeners de eventos basados en funciones anónimas en el método `boot` de tu `AppServiceProvider` de la aplicación:

    use App\Events\PodcastProcessed;
    use Illuminate\Support\Facades\Event;

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        Event::listen(function (PodcastProcessed $event) {
            // ...
        });
    }

<a name="queuable-anonymous-event-listeners"></a>
#### Listeners de Eventos Anónimos en Cola

Al registrar listeners de eventos basados en funciones anónimas, puedes envolver la función listener dentro de la función `Illuminate\Events\queueable` para instruir a Laravel a ejecutar el listener utilizando la [cola](/docs/{{version}}/queues):

    use App\Events\PodcastProcessed;
    use function Illuminate\Events\queueable;
    use Illuminate\Support\Facades\Event;

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        Event::listen(queueable(function (PodcastProcessed $event) {
            // ...
        }));
    }

Al igual que los trabajos en cola, puedes usar los métodos `onConnection`, `onQueue` y `delay` para personalizar la ejecución del listener en cola:

    Event::listen(queueable(function (PodcastProcessed $event) {
        // ...
    })->onConnection('redis')->onQueue('podcasts')->delay(now()->addSeconds(10)));

Si deseas manejar fallos de listeners anónimos en cola, puedes proporcionar una función anónima al método `catch` mientras defines el listener `queueable`. Esta función anónima recibirá la instancia del evento y la instancia `Throwable` que causó el fallo del listener:

    use App\Events\PodcastProcessed;
    use function Illuminate\Events\queueable;
    use Illuminate\Support\Facades\Event;
    use Throwable;

    Event::listen(queueable(function (PodcastProcessed $event) {
        // ...
    })->catch(function (PodcastProcessed $event, Throwable $e) {
        // El listener en cola falló...
    }));

<a name="wildcard-event-listeners"></a>
#### Listeners de Eventos con Comodín

También puedes registrar listeners utilizando el carácter `*` como un parámetro comodín, lo que te permite capturar múltiples eventos en el mismo listener. Los listeners comodín reciben el nombre del evento como su primer argumento y el array de datos del evento completo como su segundo argumento:

    Event::listen('event.*', function (string $eventName, array $data) {
        // ...
    });

<a name="defining-events"></a>
## Definiendo Eventos

Una clase de evento es esencialmente un contenedor de datos que contiene la información relacionada con el evento. Por ejemplo, supongamos que un evento `App\Events\OrderShipped` recibe un objeto de [Eloquent ORM](/docs/{{version}}/eloquent):

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
         * Crear una nueva instancia de evento.
         */
        public function __construct(
            public Order $order,
        ) {}
    }

Como puedes ver, esta clase de evento no contiene lógica. Es un contenedor para la instancia de `App\Models\Order` que fue comprada. El trait `SerializesModels` utilizado por el evento serializará de manera elegante cualquier modelo de Eloquent si el objeto del evento es serializado utilizando la función `serialize` de PHP, como cuando se utilizan [listeners en cola](#queued-event-listeners).

<a name="defining-listeners"></a>
## Definiendo Listeners

A continuación, echemos un vistazo al listener para nuestro evento de ejemplo. Los listeners de eventos reciben instancias de eventos en su método `handle`. El comando Artisan `make:listener`, cuando se invoca con la opción `--event`, importará automáticamente la clase de evento adecuada y tipará el evento en el método `handle`. Dentro del método `handle`, puedes realizar cualquier acción necesaria para responder al evento:

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;

    class SendShipmentNotification
    {
        /**
         * Crear el listener de evento.
         */
        public function __construct()
        {
            // ...
        }

        /**
         * Manejar el evento.
         */
        public function handle(OrderShipped $event): void
        {
            // Acceder al pedido usando $event->order...
        }
    }

> [!NOTE]  
> Tus listeners de eventos también pueden tipar cualquier dependencia que necesiten en sus constructores. Todos los listeners de eventos se resuelven a través del [contenedor de servicios](/docs/{{version}}/container) de Laravel, por lo que las dependencias se inyectarán automáticamente.

<a name="stopping-the-propagation-of-an-event"></a>
#### Deteniendo la Propagación de un Evento

A veces, puedes desear detener la propagación de un evento a otros listeners. Puedes hacerlo devolviendo `false` desde el método `handle` de tu listener.

<a name="queued-event-listeners"></a>
## Listeners de Eventos en Cola

Colocar listeners en cola puede ser beneficioso si tu listener va a realizar una tarea lenta, como enviar un correo electrónico o hacer una solicitud HTTP. Antes de usar listeners en cola, asegúrate de [configurar tu cola](/docs/{{version}}/queues) y de iniciar un trabajador de cola en tu servidor o entorno de desarrollo local.

Para especificar que un listener debe ser encolado, agrega la interfaz `ShouldQueue` a la clase del listener. Los listeners generados por los comandos Artisan `make:listener` ya tienen esta interfaz importada en el espacio de nombres actual, por lo que puedes usarla de inmediato:

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;
    use Illuminate\Contracts\Queue\ShouldQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        // ...
    }

¡Eso es todo! Ahora, cuando un evento manejado por este listener es despachado, el listener será automáticamente encolado por el despachador de eventos utilizando el [sistema de colas](/docs/{{version}}/queues) de Laravel. Si no se lanzan excepciones cuando el listener es ejecutado por la cola, el trabajo en cola será automáticamente eliminado después de que haya terminado de procesarse.

<a name="customizing-the-queue-connection-queue-name"></a>
#### Personalizando la Conexión de Cola, Nombre y Retraso

Si deseas personalizar la conexión de cola, el nombre de la cola o el tiempo de retraso de un listener de eventos, puedes definir las propiedades `$connection`, `$queue` o `$delay` en tu clase de listener:

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;
    use Illuminate\Contracts\Queue\ShouldQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        /**
         * El nombre de la conexión a la que se debe enviar el trabajo.
         *
         * @var string|null
         */
        public $connection = 'sqs';

        /**
         * El nombre de la cola a la que se debe enviar el trabajo.
         *
         * @var string|null
         */
        public $queue = 'listeners';

        /**
         * El tiempo (en segundos) antes de que el trabajo deba ser procesado.
         *
         * @var int
         */
        public $delay = 60;
    }

Si deseas definir la conexión de cola, el nombre de la cola o el retraso del listener en tiempo de ejecución, puedes definir los métodos `viaConnection`, `viaQueue` o `withDelay` en el listener:

    /**
     * Obtener el nombre de la conexión de cola del listener.
     */
    public function viaConnection(): string
    {
        return 'sqs';
    }

    /**
     * Obtener el nombre de la cola del listener.
     */
    public function viaQueue(): string
    {
        return 'listeners';
    }

    /**
     * Obtener el número de segundos antes de que el trabajo deba ser procesado.
     */
    public function withDelay(OrderShipped $event): int
    {
        return $event->highPriority ? 0 : 60;
    }

<a name="conditionally-queueing-listeners"></a>
#### Colocando Condicionalmente en Cola los Listeners

A veces, puedes necesitar determinar si un listener debe ser encolado en función de algunos datos que solo están disponibles en tiempo de ejecución. Para lograr esto, se puede agregar un método `shouldQueue` a un listener para determinar si el listener debe ser encolado. Si el método `shouldQueue` devuelve `false`, el listener no será encolado:

    <?php

    namespace App\Listeners;

    use App\Events\OrderCreated;
    use Illuminate\Contracts\Queue\ShouldQueue;

    class RewardGiftCard implements ShouldQueue
    {
        /**
         * Recompensar una tarjeta de regalo al cliente.
         */
        public function handle(OrderCreated $event): void
        {
            // ...
        }

        /**
         * Determinar si el listener debe ser encolado.
         */
        public function shouldQueue(OrderCreated $event): bool
        {
            return $event->order->subtotal >= 5000;
        }
    }

<a name="manually-interacting-with-the-queue"></a>
### Interacción Manual con la Cola

Si necesitas acceder manualmente a los métodos `delete` y `release` del trabajo subyacente del listener en cola, puedes hacerlo utilizando el trait `Illuminate\Queue\InteractsWithQueue`. Este trait se importa por defecto en los listeners generados y proporciona acceso a estos métodos:

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Queue\InteractsWithQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        use InteractsWithQueue;

        /**
         * Manejar el evento.
         */
        public function handle(OrderShipped $event): void
        {
            if (true) {
                $this->release(30);
            }
        }
    }

<a name="queued-event-listeners-and-database-transactions"></a>
### Listeners de Eventos en Cola y Transacciones de Base de Datos

Cuando los listeners en cola son despachados dentro de transacciones de base de datos, pueden ser procesados por la cola antes de que la transacción de base de datos se haya confirmado. Cuando esto sucede, cualquier actualización que hayas realizado en modelos o registros de base de datos durante la transacción puede no estar reflejada aún en la base de datos. Además, cualquier modelo o registro de base de datos creado dentro de la transacción puede no existir en la base de datos. Si tu listener depende de estos modelos, pueden ocurrir errores inesperados cuando se procesa el trabajo que despacha el listener en cola.

Si la opción de configuración `after_commit` de la conexión de tu cola está establecida en `false`, aún puedes indicar que un oyente en cola particular debe ser despachado después de que todas las transacciones de base de datos abiertas hayan sido confirmadas implementando la interfaz `ShouldHandleEventsAfterCommit` en la clase del oyente:

    <?php

    namespace App\Listeners;

    use Illuminate\Contracts\Events\ShouldHandleEventsAfterCommit;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Queue\InteractsWithQueue;

    class SendShipmentNotification implements ShouldQueue, ShouldHandleEventsAfterCommit
    {
        use InteractsWithQueue;
    }

> [!NOTE]  
> Para aprender más sobre cómo solucionar estos problemas, revisa la documentación sobre [trabajos en cola y transacciones de base de datos](/docs/{{version}}/queues#jobs-and-database-transactions).

<a name="handling-failed-jobs"></a>
### Manejo de Trabajos Fallidos

A veces, tus oyentes de eventos en cola pueden fallar. Si el oyente en cola excede el número máximo de intentos definido por tu trabajador de cola, se llamará al método `failed` en tu oyente. El método `failed` recibe la instancia del evento y el `Throwable` que causó la falla:

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
         * Manejar el evento.
         */
        public function handle(OrderShipped $event): void
        {
            // ...
        }

        /**
         * Manejar un fallo de trabajo.
         */
        public function failed(OrderShipped $event, Throwable $exception): void
        {
            // ...
        }
    }

<a name="specifying-queued-listener-maximum-attempts"></a>
#### Especificando el Número Máximo de Intentos del Oyente en Cola

Si uno de tus oyentes en cola está encontrando un error, probablemente no quieras que siga intentando indefinidamente. Por lo tanto, Laravel proporciona varias formas de especificar cuántas veces o por cuánto tiempo se puede intentar un oyente.

Puedes definir una propiedad `$tries` en tu clase de oyente para especificar cuántas veces se puede intentar el oyente antes de que se considere que ha fallado:

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Queue\InteractsWithQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        use InteractsWithQueue;

        /**
         * El número de veces que se puede intentar el oyente en cola.
         *
         * @var int
         */
        public $tries = 5;
    }

Como alternativa a definir cuántas veces se puede intentar un oyente antes de que falle, puedes definir un tiempo en el que el oyente ya no debería ser intentado. Esto permite que un oyente sea intentado cualquier número de veces dentro de un marco de tiempo dado. Para definir el tiempo en el que un oyente ya no debería ser intentado, agrega un método `retryUntil` a tu clase de oyente. Este método debe devolver una instancia de `DateTime`:

    use DateTime;

    /**
     * Determinar el tiempo en el que el oyente debería expirar.
     */
    public function retryUntil(): DateTime
    {
        return now()->addMinutes(5);
    }

<a name="dispatching-events"></a>
## Despachando Eventos

Para despachar un evento, puedes llamar al método estático `dispatch` en el evento. Este método está disponible en el evento mediante el rasgo `Illuminate\Foundation\Events\Dispatchable`. Cualquier argumento pasado al método `dispatch` será pasado al constructor del evento:

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
         * Enviar el pedido dado.
         */
        public function store(Request $request): RedirectResponse
        {
            $order = Order::findOrFail($request->order_id);

            // Lógica de envío del pedido...

            OrderShipped::dispatch($order);

            return redirect('/orders');
        }
    }

Si deseas despachar un evento condicionalmente, puedes usar los métodos `dispatchIf` y `dispatchUnless`:

    OrderShipped::dispatchIf($condition, $order);

    OrderShipped::dispatchUnless($condition, $order);

> [!NOTE]  
> Al probar, puede ser útil afirmar que ciertos eventos fueron despachados sin activar realmente sus oyentes. Los [ayudantes de prueba integrados de Laravel](#testing) facilitan esto.

<a name="dispatching-events-after-database-transactions"></a>
### Despachando Eventos Después de Transacciones de Base de Datos

A veces, puedes querer instruir a Laravel para que solo despache un evento después de que la transacción de base de datos activa haya sido confirmada. Para hacerlo, puedes implementar la interfaz `ShouldDispatchAfterCommit` en la clase del evento.

Esta interfaz instruye a Laravel a no despachar el evento hasta que la transacción de base de datos actual esté confirmada. Si la transacción falla, el evento será descartado. Si no hay ninguna transacción de base de datos en progreso cuando se despacha el evento, el evento será despachado inmediatamente:

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
         * Crear una nueva instancia de evento.
         */
        public function __construct(
            public Order $order,
        ) {}
    }

<a name="event-subscribers"></a>
## Suscriptores de Eventos

<a name="writing-event-subscribers"></a>
### Escribiendo Suscriptores de Eventos

Los suscriptores de eventos son clases que pueden suscribirse a múltiples eventos desde dentro de la propia clase del suscriptor, lo que te permite definir varios controladores de eventos dentro de una sola clase. Los suscriptores deben definir un método `subscribe`, que recibirá una instancia del despachador de eventos. Puedes llamar al método `listen` en el despachador dado para registrar oyentes de eventos:

    <?php

    namespace App\Listeners;

    use Illuminate\Auth\Events\Login;
    use Illuminate\Auth\Events\Logout;
    use Illuminate\Events\Dispatcher;

    class UserEventSubscriber
    {
        /**
         * Manejar eventos de inicio de sesión de usuario.
         */
        public function handleUserLogin(Login $event): void {}

        /**
         * Manejar eventos de cierre de sesión de usuario.
         */
        public function handleUserLogout(Logout $event): void {}

        /**
         * Registrar los oyentes para el suscriptor.
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

Si tus métodos de oyente de eventos están definidos dentro del propio suscriptor, puede ser más conveniente devolver un array de eventos y nombres de métodos desde el método `subscribe` del suscriptor. Laravel determinará automáticamente el nombre de la clase del suscriptor al registrar los oyentes de eventos:

    <?php

    namespace App\Listeners;

    use Illuminate\Auth\Events\Login;
    use Illuminate\Auth\Events\Logout;
    use Illuminate\Events\Dispatcher;

    class UserEventSubscriber
    {
        /**
         * Manejar eventos de inicio de sesión de usuario.
         */
        public function handleUserLogin(Login $event): void {}

        /**
         * Manejar eventos de cierre de sesión de usuario.
         */
        public function handleUserLogout(Logout $event): void {}

        /**
         * Registrar los oyentes para el suscriptor.
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

<a name="registering-event-subscribers"></a>
### Registrando Suscriptores de Eventos

Después de escribir el suscriptor, estás listo para registrarlo con el despachador de eventos. Puedes registrar suscriptores usando el método `subscribe` de la fachada `Event`. Típicamente, esto debería hacerse dentro del método `boot` del `AppServiceProvider` de tu aplicación:

    <?php

    namespace App\Providers;

    use App\Listeners\UserEventSubscriber;
    use Illuminate\Support\Facades\Event;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Inicializar cualquier servicio de la aplicación.
         */
        public function boot(): void
        {
            Event::subscribe(UserEventSubscriber::class);
        }
    }

<a name="testing"></a>
## Pruebas

Al probar código que despacha eventos, puede que desees instruir a Laravel para que no ejecute realmente los oyentes del evento, ya que el código del oyente puede ser probado directamente y por separado del código que despacha el evento correspondiente. Por supuesto, para probar el oyente en sí, puedes instanciar una instancia de oyente e invocar el método `handle` directamente en tu prueba.

Usando el método `fake` de la fachada `Event`, puedes evitar que los oyentes se ejecuten, ejecutar el código bajo prueba y luego afirmar qué eventos fueron despachados por tu aplicación usando los métodos `assertDispatched`, `assertNotDispatched` y `assertNothingDispatched`:

```php tab=Pest
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

```php tab=PHPUnit
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

Puedes pasar una función anónima a los métodos `assertDispatched` o `assertNotDispatched` para afirmar que se despachó un evento que pasa una "prueba de verdad" dada. Si al menos un evento fue despachado que pasa la prueba de verdad dada, entonces la afirmación será exitosa:

    Event::assertDispatched(function (OrderShipped $event) use ($order) {
        return $event->order->id === $order->id;
    });

Si simplemente deseas afirmar que un oyente de evento está escuchando un evento dado, puedes usar el método `assertListening`:

    Event::assertListening(
        OrderShipped::class,
        SendShipmentNotification::class
    );

> [!WARNING]  
> Después de llamar a `Event::fake()`, no se ejecutarán oyentes de eventos. Así que, si tus pruebas utilizan fábricas de modelos que dependen de eventos, como crear un UUID durante el evento `creating` de un modelo, deberías llamar a `Event::fake()` **después** de usar tus fábricas.

<a name="faking-a-subset-of-events"></a>
### Simulando un Conjunto de Eventos

Si solo deseas simular oyentes de eventos para un conjunto específico de eventos, puedes pasarlos al método `fake` o `fakeFor`:

```php tab=Pest
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

```php tab=PHPUnit
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

Puedes simular todos los eventos excepto un conjunto de eventos especificados usando el método `except`:

    Event::fake()->except([
        OrderCreated::class,
    ]);

<a name="scoped-event-fakes"></a>
### Simulaciones de Eventos con Alcance

Si solo deseas simular oyentes de eventos para una parte de tu prueba, puedes usar el método `fakeFor`:

```php tab=Pest
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

```php tab=PHPUnit
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
