# Eventos

- [Introducción](#introduction)
- [Registro de eventos y oyentes](#registering-events-and-listeners)
  - [Generación de eventos y oyentes](#generating-events-and-listeners)
  - [Registro manual de eventos](#manually-registering-events)
  - [Descubrimiento de Eventos](#event-discovery)
- [Definición de eventos](#defining-events)
- [Definición de oyentes](#defining-listeners)
- [Receptores de Eventos en Cola](#queued-event-listeners)
  - [Interacción Manual con la Cola](#manually-interacting-with-the-queue)
  - [Receptores de Eventos en Cola y Transacciones de Base de Datos](#queued-event-listeners-and-database-transactions)
  - [Manejo de Trabajos Fallidos](#handling-failed-jobs)
- [Despacho de Eventos](#dispatching-events)
- [Suscriptores de Eventos](#event-subscribers)
  - [Escritura de Suscriptores de Eventos](#writing-event-subscribers)
  - [Registro de Suscriptores de eventos](#registering-event-subscribers)

<a name="introduction"></a>
## Introducción

Los eventos de Laravel proporcionan una implementación simple del patrón observador, permitiéndote suscribirte y escuchar varios eventos que ocurren dentro de tu aplicación. Las clases de eventos se almacenan normalmente en el directorio `app/Events`, mientras que sus oyentes se almacenan en `app/Listeners`. No te preocupes si no ves estos directorios en tu aplicación, ya que serán creados por ti cuando generes eventos y listeners utilizando los comandos de la consola de Artisan.

Los eventos son útiles para desacoplar varios aspectos de su aplicación, ya que un solo evento puede tener múltiples oyentes que no dependen unos de otros. Por ejemplo, es posible que desee enviar una notificación Slack a su usuario cada vez que un pedido ha sido enviado. En lugar de acoplar su código de procesamiento de pedidos a su código de notificación Slack, puede lanzar un evento `App\Events\OrderShipped` que un oyente puede recibir y utilizar para enviar una notificación Slack.

<a name="registering-events-and-listeners"></a>
## Registro de Eventos y Oyentes

El `App\Providers\EventServiceProvider` incluido con su aplicación Laravel es un buen lugar para registrar todos los oyentes de eventos de su aplicación. La propiedad `listen` contiene una array de todos los eventos (claves) y sus oyentes (valores). Puedes añadir tantos eventos a este array como requiera tu aplicación. Por ejemplo, vamos a añadir un evento `OrderShipped`:

    use App\Events\OrderShipped;
    use App\Listeners\SendShipmentNotification;

    /**
     * The event listener mappings for the application.
     *
     * @var array
     */
    protected $listen = [
        OrderShipped::class => [
            SendShipmentNotification::class,
        ],
    ];

> **Nota**  
> El comando `event:list  puede ser utilizado para mostrar una lista de todos los eventos y oyentes (listeners) registrados por tu aplicación.

<a name="generating-events-and-listeners"></a>
### Generación de Eventos y Oyentes

Por supuesto, crear manualmente los archivos para cada evento y oyente es engorroso. En su lugar, añade listeners y eventos a tu `EventServiceProvider` y utiliza el comando `event:generate` de Artisan. Este comando generará cualquier evento o listener que esté listado en tu `EventServiceProvider` y que aún no exista:

```shell
php artisan event:generate
```

De manera alternativa, puedes utilizar los comandos `make:event` y `make:listener` de Artisan para generar eventos y listeners individuales:

```shell
php artisan make:event PodcastProcessed

php artisan make:listener SendPodcastNotification --event=PodcastProcessed
```

<a name="manually-registering-events"></a>
### Registro Manual de Eventos

Típicamente, los eventos deben ser registrados en el array `$listen` del `EventServiceProvider`; sin embargo, también puedes registrar manualmente oyentes de eventos basados en clases o closure en el método `boot` de tu `EventServiceProvider`:

    use App\Events\PodcastProcessed;
    use App\Listeners\SendPodcastNotification;
    use Illuminate\Support\Facades\Event;

    /**
     * Register any other events for your application.
     *
     * @return void
     */
    public function boot()
    {
        Event::listen(
            PodcastProcessed::class,
            [SendPodcastNotification::class, 'handle']
        );

        Event::listen(function (PodcastProcessed $event) {
            //
        });
    }

<a name="queuable-anonymous-event-listeners"></a>
#### Oyentes de Eventos Anónimos en Cola

Al registrar manualmente oyentes de eventos basados en closure, puede envolver el closure del oyente dentro de la función `Illuminate\Events\queueable` para indicar a Laravel que ejecute el oyente utilizando la [cola](/docs/{{version}}/queues):

    use App\Events\PodcastProcessed;
    use function Illuminate\Events\queueable;
    use Illuminate\Support\Facades\Event;

    /**
     * Register any other events for your application.
     *
     * @return void
     */
    public function boot()
    {
        Event::listen(queueable(function (PodcastProcessed $event) {
            //
        }));
    }

Al igual que los trabajos en cola, puedes utilizar los métodos `onConnection`, `onQueue` y `delay` para personalizar la ejecución del oyente en cola:

    Event::listen(queueable(function (PodcastProcessed $event) {
        //
    })->onConnection('redis')->onQueue('podcasts')->delay(now()->addSeconds(10)));

Si quieres gestionar los fallos de un receptor anónimo en cola, puedes proporcionar un closure al método `catch` mientras defines el receptor en `queueable`. Este closure recibirá la instancia del evento y la instancia `Throwable` que causó el fallo del listener:

    use App\Events\PodcastProcessed;
    use function Illuminate\Events\queueable;
    use Illuminate\Support\Facades\Event;
    use Throwable;

    Event::listen(queueable(function (PodcastProcessed $event) {
        //
    })->catch(function (PodcastProcessed $event, Throwable $e) {
        // The queued listener failed...
    }));

<a name="wildcard-event-listeners"></a>
#### Oyentes de Eventos Comodín

Puedes incluso registrar oyentes utilizando el `*` como parámetro comodín, permitiéndote capturar múltiples eventos en el mismo oyente. Los oyentes comodín reciben el nombre del evento como primer argumento y el array completo de datos del evento como segundo argumento:

    Event::listen('event.*', function ($eventName, array $data) {
        //
    });

<a name="event-discovery"></a>
### Descubrimiento de Eventos

En lugar de registrar eventos y oyentes manualmente en el array `$listen` del `EventServiceProvider`, puedes habilitar el descubrimiento automático de eventos. Cuando el descubrimiento de eventos está habilitado, Laravel automáticamente encontrará y registrará tus eventos y listeners escaneando el directorio `Listeners` de tu aplicación. Además, cualquier evento definido explícitamente en el `EventServiceProvider` seguirá siendo registrado.

Laravel encuentra listeners de eventos escaneando las clases listener usando los servicios de reflexión de PHP. Cuando Laravel encuentra cualquier método de la clase listener que comienza con `handle` o `__invoke`, Laravel registrará esos métodos como oyentes de eventos para el evento que se indica en la firma del método:

    use App\Events\PodcastProcessed;

    class SendPodcastNotification
    {
        /**
         * Handle the given event.
         *
         * @param  \App\Events\PodcastProcessed  $event
         * @return void
         */
        public function handle(PodcastProcessed $event)
        {
            //
        }
    }

El descubrimiento de eventos está deshabilitado por defecto, pero puedes habilitarlo anulando el método `shouldDiscoverEvents` del `EventServiceProvider` de tu aplicación:

    /**
     * Determine if events and listeners should be automatically discovered.
     *
     * @return bool
     */
    public function shouldDiscoverEvents()
    {
        return true;
    }

Por defecto, todos los listeners dentro del directorio `app/Listeners` de tu aplicación serán escaneados. Si desea definir directorios adicionales para escanear, puede sobreescribir el método `discoverEventsWithin` en su `EventServiceProvider`:

    /**
     * Get the listener directories that should be used to discover events.
     *
     * @return array
     */
    protected function discoverEventsWithin()
    {
        return [
            $this->app->path('Listeners'),
        ];
    }

<a name="event-discovery-in-production"></a>
#### Descubrimiento de Eventos en Producción

En producción, no es eficiente para el framework escanear todos tus listeners en cada petición. Por lo tanto, durante el proceso de despliegue, debes ejecutar el comando `event:cache` de Artisan para cachear un manifiesto de todos los eventos y listeners de tu aplicación. Este manifiesto será utilizado por el framework para acelerar el proceso de registro de eventos. El comando  `event:clear` puede ser utilizado para destruir la cache.

<a name="defining-events"></a>
## Definición de Eventos

Una clase de evento es esencialmente un contenedor de datos que contiene la información relacionada con el evento. Por ejemplo, supongamos que un evento `App\Events\OrderShipped` recibe un objeto [ORM Eloquent](/docs/{{version}}/eloquent):

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
         * The order instance.
         *
         * @var \App\Models\Order
         */
        public $order;

        /**
         * Create a new event instance.
         *
         * @param  \App\Models\Order  $order
         * @return void
         */
        public function __construct(Order $order)
        {
            $this->order = $order;
        }
    }

Como puede ver, esta clase de evento no contiene lógica. Es un contenedor para la instancia `App\Models\Order` que fue comprada. El trait `SerializesModels` usado por el evento serializará cualquier modelo Eloquent si el objeto del evento es serializado usando la función `serialize` de PHP, como cuando se utilizan oyentes [en cola](#queued-event-listeners).

<a name="defining-listeners"></a>
## Definición de Oyentes

A continuación, echemos un vistazo al listener de nuestro evento de ejemplo. Los oyentes de eventos reciben instancias de eventos en su método `handle`. Los comandos `event:generate` y `make:listener` de Artisan importarán automáticamente la clase de evento apropiada y el tipo de evento en el método `handle`. Dentro del método `handle`, puedes realizar cualquier acción necesaria para responder al evento:

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;

    class SendShipmentNotification
    {
        /**
         * Create the event listener.
         *
         * @return void
         */
        public function __construct()
        {
            //
        }

        /**
         * Handle the event.
         *
         * @param  \App\Events\OrderShipped  $event
         * @return void
         */
        public function handle(OrderShipped $event)
        {
            // Access the order using $event->order...
        }
    }

> **Nota**  
> Tus oyentes de eventos también pueden indicar cualquier dependencia que necesiten en sus constructores. Todos los oyentes de eventos se resuelven a través del [contenedor de servicios](/docs/{{version}}/container) de Laravel, por lo que las dependencias se inyectarán automáticamente.

<a name="stopping-the-propagation-of-an-event"></a>
#### Detener la Propagación de un Evento

A veces, es posible que desee detener la propagación de un evento a otros oyentes. Puedes hacerlo devolviendo `false` desde el método `handle` de tu receptor.

<a name="queued-event-listeners"></a>
## Receptores de Eventos en Cola

Poner en cola listeners puede ser beneficioso si tu listener va a realizar una tarea lenta como enviar un email o hacer una petición HTTP. Antes de utilizar oyentes en cola, asegúrate de [configurar tu cola](/docs/{{version}}/queues) e iniciar un trabajador de cola en tu servidor o entorno de desarrollo local.

Para especificar que un listener debe ser puesto en cola, añade la interfaz `ShouldQueue` a la clase listener. Los oyentes generados por los comandos `event:generate` y `make:listener` de Artisan ya tienen esta interfaz importada en el espacio de nombres actual, por lo que puedes utilizarla inmediatamente:

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;
    use Illuminate\Contracts\Queue\ShouldQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        //
    }

Ya está. Ahora, cuando un evento manejado por este listener es despachado, el listener será automáticamente puesto en cola por el despachador de eventos usando el [sistema de colas](/docs/{{version}}/queues) de Laravel. Si no se lanzan excepciones cuando el listener es ejecutado por la cola, el trabajo en cola será automáticamente borrado después de que haya terminado de procesarse.

<a name="customizing-the-queue-connection-queue-name"></a>
#### Personalizando la Conexión a la Cola y el Nombre de la Cola

Si deseas personalizar la conexión a la cola, el nombre de la cola o el tiempo de retardo de la cola de un listener de eventos, puedes definir las propiedades `$connection`, `$queue` o `$delay` en tu clase listener:

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

Si desea definir la conexión o el nombre de la cola del receptor en tiempo de ejecución, puede definir los métodos `viaConnection` o `viaQueue` en el receptor:

    /**
     * Get the name of the listener's queue connection.
     *
     * @return string
     */
    public function viaConnection()
    {
        return 'sqs';
    }

    /**
     * Get the name of the listener's queue.
     *
     * @return string
     */
    public function viaQueue()
    {
        return 'listeners';
    }

<a name="conditionally-queueing-listeners"></a>
#### Puesta en cola condicional de receptores

A veces es necesario determinar si un receptor debe ponerse en cola en función de algunos datos que sólo están disponibles en tiempo de ejecución. Para ello, se puede añadir un método `shouldQueue` a un receptor para determinar si debe ponerse en cola. Si el método `shouldQueue` devuelve `false`, el listener no se ejecutará:

    <?php

    namespace App\Listeners;

    use App\Events\OrderCreated;
    use Illuminate\Contracts\Queue\ShouldQueue;

    class RewardGiftCard implements ShouldQueue
    {
        /**
         * Reward a gift card to the customer.
         *
         * @param  \App\Events\OrderCreated  $event
         * @return void
         */
        public function handle(OrderCreated $event)
        {
            //
        }

        /**
         * Determine whether the listener should be queued.
         *
         * @param  \App\Events\OrderCreated  $event
         * @return bool
         */
        public function shouldQueue(OrderCreated $event)
        {
            return $event->order->subtotal >= 5000;
        }
    }

<a name="manually-interacting-with-the-queue"></a>
### Interacción Manual con la Cola

Si necesitas acceder manualmente a los métodos `delete` y `release` del trabajo de la cola subyacente del listener, puedes hacerlo utilizando el trait `Illuminate\Queue\InteractsWithQueue`. Este trait se importa por defecto en los oyentes generados y proporciona acceso a estos métodos:

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
         *
         * @param  \App\Events\OrderShipped  $event
         * @return void
         */
        public function handle(OrderShipped $event)
        {
            if (true) {
                $this->release(30);
            }
        }
    }

<a name="queued-event-listeners-and-database-transactions"></a>
### Receptores de Eventos en Cola y Transacciones de Base de Datos

Cuando los listeners en cola se envían dentro de transacciones de base de datos, pueden ser procesados por la cola antes de que la transacción de base de datos se haya "commiteado". Cuando esto ocurre, cualquier actualización que haya realizado en los modelos o registros de la base de datos durante la transacción de la base de datos puede no reflejarse todavía en la base de datos. Además, es posible que los modelos o registros de base de datos creados durante la transacción no existan en la base de datos. Si tu listener depende de estos modelos, pueden ocurrir errores inesperados cuando el trabajo que envía el listener encolado es procesado.

Si la opción de configuración `after_commit` de su conexión de cola se establece en `false`, aún puede indicar que un oyente en cola en particular debe enviarse después de que se hayan confirmado todas las transacciones abiertas de la base de datos definiendo una propiedad `$afterCommit` en la clase de oyente:

    <?php

    namespace App\Listeners;

    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Queue\InteractsWithQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        use InteractsWithQueue;

        public $afterCommit = true;
    }

> **Nota**  
> Para obtener más información sobre cómo solucionar estos problemas, consulte la documentación relativa a los trabajos en cola [y las transacciones de base de datos](/docs/{{version}}/queues#jobs-and-database-transactions).

<a name="handling-failed-jobs"></a>
### Manejo de Trabajos Fallidos

A veces sus oyentes de eventos en cola pueden fallar. Si el oyente en cola excede el número máximo de intentos definido por su trabajador de cola, el método `failed` será llamado en su oyente. El método `failed` recibe la instancia del evento y el `Throwable` que causó el fallo:

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
         *
         * @param  \App\Events\OrderShipped  $event
         * @return void
         */
        public function handle(OrderShipped $event)
        {
            //
        }

        /**
         * Handle a job failure.
         *
         * @param  \App\Events\OrderShipped  $event
         * @param  \Throwable  $exception
         * @return void
         */
        public function failed(OrderShipped $event, $exception)
        {
            //
        }
    }

<a name="specifying-queued-listener-maximum-attempts"></a>
#### Especificación de intentos máximos de oyentes en cola

Si uno de tus listeners en cola se encuentra con un error, es probable que no quieras que siga reintentando indefinidamente. Por lo tanto, Laravel proporciona varias maneras de especificar cuántas veces o durante cuánto tiempo se puede intentar un oyente.

Puedes definir una propiedad `$tries` en tu clase listener para especificar cuántas veces se puede intentar la escucha antes de que se considere que ha fallado:

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

Como alternativa a la definición de cuántas veces se puede intentar la escucha antes de que falle, se puede definir un tiempo en el que no se debe intentar la escucha. Esto permite que se intente la escucha cualquier número de veces dentro de un periodo de tiempo determinado. Para definir el momento en el que no se debe volver a intentar la escucha, añada un método `retryUntil` a la clase listener. Este método debe devolver una instancia de `DateTime`:

    /**
     * Determine the time at which the listener should timeout.
     *
     * @return \DateTime
     */
    public function retryUntil()
    {
        return now()->addMinutes(5);
    }

<a name="dispatching-events"></a>
## Despachando Eventos

Para enviar un evento, puede llamar al método estático `dispatch` del evento. Este método está disponible en el evento mediante el trait `Illuminate\Foundation\Events\Dispatchable`. Cualquier argumento pasado al método `dispatch` será pasado al constructor del evento:

    <?php

    namespace App\Http\Controllers;

    use App\Events\OrderShipped;
    use App\Http\Controllers\Controller;
    use App\Models\Order;
    use Illuminate\Http\Request;

    class OrderShipmentController extends Controller
    {
        /**
         * Ship the given order.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function store(Request $request)
        {
            $order = Order::findOrFail($request->order_id);

            // Order shipment logic...

            OrderShipped::dispatch($order);
        }
    }

Si quieres enviar un evento condicionalmente, puedes utilizar los métodos `dispatchIf` y `dispatchUnless`:

    OrderShipped::dispatchIf($condition, $order);

    OrderShipped::dispatchUnless($condition, $order);

> **Nota**  
> En los tests, puede ser útil afirmar que ciertos eventos fueron despachados sin activar realmente sus oyentes. Los [helpers de ayuda para tests de](/docs/{{version}}/mocking#event-fake) Laravel lo hacen muy fácil.

<a name="event-subscribers"></a>
## Suscriptores de Eventos

<a name="writing-event-subscribers"></a>
### Escritura de Suscriptores de Eventos

Los suscriptores de eventos son clases que pueden suscribirse a múltiples eventos desde dentro de la propia clase suscriptora, permitiéndote definir varios manejadores de eventos dentro de una única clase. Los suscriptores deben definir un método `subscribe`, al que se le pasará una instancia del despachador de eventos. Puedes llamar al método `listen` en el despachador dado para registrar oyentes de eventos:

    <?php

    namespace App\Listeners;

    use Illuminate\Auth\Events\Login;
    use Illuminate\Auth\Events\Logout;

    class UserEventSubscriber
    {
        /**
         * Handle user login events.
         */
        public function handleUserLogin($event) {}

        /**
         * Handle user logout events.
         */
        public function handleUserLogout($event) {}

        /**
         * Register the listeners for the subscriber.
         *
         * @param  \Illuminate\Events\Dispatcher  $events
         * @return void
         */
        public function subscribe($events)
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

Si tus métodos de escucha de eventos están definidos dentro del propio suscriptor, puede que te resulte más útil devolver un array de eventos y nombres de métodos desde el método `subscribe` del suscriptor. Laravel determinará automáticamente el nombre de la clase del suscriptor al registrar los oyentes de eventos:

    <?php

    namespace App\Listeners;

    use Illuminate\Auth\Events\Login;
    use Illuminate\Auth\Events\Logout;

    class UserEventSubscriber
    {
        /**
         * Handle user login events.
         */
        public function handleUserLogin($event) {}

        /**
         * Handle user logout events.
         */
        public function handleUserLogout($event) {}

        /**
         * Register the listeners for the subscriber.
         *
         * @param  \Illuminate\Events\Dispatcher  $events
         * @return array
         */
        public function subscribe($events)
        {
            return [
                Login::class => 'handleUserLogin',
                Logout::class => 'handleUserLogout',
            ];
        }
    }

<a name="registering-event-subscribers"></a>
### Registro de suscriptores de eventos

Después de escribir el suscriptor, estás listo para registrarlo con el despachador de eventos. Puedes registrar suscriptores usando la propiedad `$subscribe` del `EventServiceProvider`. Por ejemplo, agreguemos el `UserEventSubscriber` a la lista:

    <?php

    namespace App\Providers;

    use App\Listeners\UserEventSubscriber;
    use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

    class EventServiceProvider extends ServiceProvider
    {
        /**
         * The event listener mappings for the application.
         *
         * @var array
         */
        protected $listen = [
            //
        ];

        /**
         * The subscriber classes to register.
         *
         * @var array
         */
        protected $subscribe = [
            UserEventSubscriber::class,
        ];
    }
