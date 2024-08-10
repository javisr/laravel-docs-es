# Notificaciones

- [Introducción](#introduction)
- [Generando Notificaciones](#generating-notifications)
- [Enviando Notificaciones](#sending-notifications)
    - [Usando el Trait Notifiable](#using-the-notifiable-trait)
    - [Usando el Facade Notification](#using-the-notification-facade)
    - [Especificando Canales de Entrega](#specifying-delivery-channels)
    - [Encolando Notificaciones](#queueing-notifications)
    - [Notificaciones Bajo Demanda](#on-demand-notifications)
- [Notificaciones por Correo](#mail-notifications)
    - [Formateando Mensajes de Correo](#formatting-mail-messages)
    - [Personalizando el Remitente](#customizing-the-sender)
    - [Personalizando el Destinatario](#customizing-the-recipient)
    - [Personalizando el Asunto](#customizing-the-subject)
    - [Personalizando el Mailer](#customizing-the-mailer)
    - [Personalizando las Plantillas](#customizing-the-templates)
    - [Adjuntos](#mail-attachments)
    - [Agregando Etiquetas y Metadatos](#adding-tags-metadata)
    - [Personalizando el Mensaje de Symfony](#customizing-the-symfony-message)
    - [Usando Mailables](#using-mailables)
    - [Previsualizando Notificaciones por Correo](#previewing-mail-notifications)
- [Notificaciones por Correo Markdown](#markdown-mail-notifications)
    - [Generando el Mensaje](#generating-the-message)
    - [Escribiendo el Mensaje](#writing-the-message)
    - [Personalizando los Componentes](#customizing-the-components)
- [Notificaciones en Base de Datos](#database-notifications)
    - [Requisitos Previos](#database-prerequisites)
    - [Formateando Notificaciones en Base de Datos](#formatting-database-notifications)
    - [Accediendo a las Notificaciones](#accessing-the-notifications)
    - [Marcando Notificaciones como Leídas](#marking-notifications-as-read)
- [Notificaciones por Difusión](#broadcast-notifications)
    - [Requisitos Previos](#broadcast-prerequisites)
    - [Formateando Notificaciones por Difusión](#formatting-broadcast-notifications)
    - [Escuchando Notificaciones](#listening-for-notifications)
- [Notificaciones por SMS](#sms-notifications)
    - [Requisitos Previos](#sms-prerequisites)
    - [Formateando Notificaciones por SMS](#formatting-sms-notifications)
    - [Contenido Unicode](#unicode-content)
    - [Personalizando el Número "De"](#customizing-the-from-number)
    - [Agregando una Referencia de Cliente](#adding-a-client-reference)
    - [Enrutando Notificaciones por SMS](#routing-sms-notifications)
- [Notificaciones por Slack](#slack-notifications)
    - [Requisitos Previos](#slack-prerequisites)
    - [Formateando Notificaciones por Slack](#formatting-slack-notifications)
    - [Interactividad de Slack](#slack-interactivity)
    - [Enrutando Notificaciones por Slack](#routing-slack-notifications)
    - [Notificando Espacios de Trabajo Externos de Slack](#notifying-external-slack-workspaces)
- [Localizando Notificaciones](#localizing-notifications)
- [Pruebas](#testing)
- [Eventos de Notificación](#notification-events)
- [Canales Personalizados](#custom-channels)

<a name="introduction"></a>
## Introducción

Además del soporte para [enviar correos](/docs/{{version}}/mail), Laravel proporciona soporte para enviar notificaciones a través de una variedad de canales de entrega, incluyendo correo electrónico, SMS (a través de [Vonage](https://www.vonage.com/communications-apis/), anteriormente conocido como Nexmo), y [Slack](https://slack.com). Además, se han creado una variedad de [canales de notificación construidos por la comunidad](https://laravel-notification-channels.com/about/#suggesting-a-new-channel) para enviar notificaciones a través de docenas de canales diferentes. ¡Las notificaciones también pueden almacenarse en una base de datos para que se puedan mostrar en tu interfaz web!

Típicamente, las notificaciones deben ser mensajes cortos e informativos que notifiquen a los usuarios sobre algo que ocurrió en tu aplicación. Por ejemplo, si estás escribiendo una aplicación de facturación, podrías enviar una notificación de "Factura Pagada" a tus usuarios a través de los canales de correo electrónico y SMS.

<a name="generating-notifications"></a>
## Generando Notificaciones

En Laravel, cada notificación está representada por una única clase que generalmente se almacena en el directorio `app/Notifications`. No te preocupes si no ves este directorio en tu aplicación: se creará para ti cuando ejecutes el comando Artisan `make:notification`:

```shell
php artisan make:notification InvoicePaid
```

Este comando colocará una nueva clase de notificación en tu directorio `app/Notifications`. Cada clase de notificación contiene un método `via` y un número variable de métodos de construcción de mensajes, como `toMail` o `toDatabase`, que convierten la notificación en un mensaje adaptado para ese canal en particular.

<a name="sending-notifications"></a>
## Enviando Notificaciones

<a name="using-the-notifiable-trait"></a>
### Usando el Trait Notifiable

Las notificaciones pueden enviarse de dos maneras: utilizando el método `notify` del trait `Notifiable` o utilizando el [facade](/docs/{{version}}/facades) `Notification`. El trait `Notifiable` está incluido en el modelo `App\Models\User` de tu aplicación por defecto:

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;

    class User extends Authenticatable
    {
        use Notifiable;
    }

El método `notify` que proporciona este trait espera recibir una instancia de notificación:

    use App\Notifications\InvoicePaid;

    $user->notify(new InvoicePaid($invoice));

> [!NOTE]  
> Recuerda, puedes usar el trait `Notifiable` en cualquiera de tus modelos. No estás limitado a incluirlo solo en tu modelo `User`.

<a name="using-the-notification-facade"></a>
### Usando el Facade Notification

Alternativamente, puedes enviar notificaciones a través del [facade](/docs/{{version}}/facades) `Notification`. Este enfoque es útil cuando necesitas enviar una notificación a múltiples entidades notificables, como una colección de usuarios. Para enviar notificaciones usando el facade, pasa todas las entidades notificables y la instancia de notificación al método `send`:

    use Illuminate\Support\Facades\Notification;

    Notification::send($users, new InvoicePaid($invoice));

También puedes enviar notificaciones de inmediato usando el método `sendNow`. Este método enviará la notificación de inmediato, incluso si la notificación implementa la interfaz `ShouldQueue`:

    Notification::sendNow($developers, new DeploymentCompleted($deployment));

<a name="specifying-delivery-channels"></a>
### Especificando Canales de Entrega

Cada clase de notificación tiene un método `via` que determina en qué canales se entregará la notificación. Las notificaciones pueden enviarse a través de los canales `mail`, `database`, `broadcast`, `vonage` y `slack`.

> [!NOTE]  
> Si deseas utilizar otros canales de entrega como Telegram o Pusher, consulta el sitio web de [Canales de Notificación de Laravel](http://laravel-notification-channels.com).

El método `via` recibe una instancia de `$notifiable`, que será una instancia de la clase a la que se envía la notificación. Puedes usar `$notifiable` para determinar en qué canales se debe entregar la notificación:

    /**
     * Obtener los canales de entrega de la notificación.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return $notifiable->prefers_sms ? ['vonage'] : ['mail', 'database'];
    }

<a name="queueing-notifications"></a>
### Encolando Notificaciones

> [!WARNING]  
> Antes de encolar notificaciones, debes configurar tu cola y [iniciar un trabajador](/docs/{{version}}/queues#running-the-queue-worker).

Enviar notificaciones puede llevar tiempo, especialmente si el canal necesita hacer una llamada a una API externa para entregar la notificación. Para acelerar el tiempo de respuesta de tu aplicación, permite que tu notificación sea encolada agregando la interfaz `ShouldQueue` y el trait `Queueable` a tu clase. La interfaz y el trait ya están importados para todas las notificaciones generadas usando el comando `make:notification`, por lo que puedes agregarlos de inmediato a tu clase de notificación:

    <?php

    namespace App\Notifications;

    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Notifications\Notification;

    class InvoicePaid extends Notification implements ShouldQueue
    {
        use Queueable;

        // ...
    }

Una vez que se ha agregado la interfaz `ShouldQueue` a tu notificación, puedes enviar la notificación como de costumbre. Laravel detectará la interfaz `ShouldQueue` en la clase y encolará automáticamente la entrega de la notificación:

    $user->notify(new InvoicePaid($invoice));

Al encolar notificaciones, se creará un trabajo encolado para cada combinación de destinatario y canal. Por ejemplo, se enviarán seis trabajos a la cola si tu notificación tiene tres destinatarios y dos canales.

<a name="delaying-notifications"></a>
#### Retrasando Notificaciones

Si deseas retrasar la entrega de la notificación, puedes encadenar el método `delay` a la instancia de tu notificación:

    $delay = now()->addMinutes(10);

    $user->notify((new InvoicePaid($invoice))->delay($delay));

Puedes pasar un array al método `delay` para especificar la cantidad de retraso para canales específicos:

    $user->notify((new InvoicePaid($invoice))->delay([
        'mail' => now()->addMinutes(5),
        'sms' => now()->addMinutes(10),
    ]));

Alternativamente, puedes definir un método `withDelay` en la clase de notificación. El método `withDelay` debe devolver un array de nombres de canales y valores de retraso:

    /**
     * Determinar el retraso de entrega de la notificación.
     *
     * @return array<string, \Illuminate\Support\Carbon>
     */
    public function withDelay(object $notifiable): array
    {
        return [
            'mail' => now()->addMinutes(5),
            'sms' => now()->addMinutes(10),
        ];
    }

<a name="customizing-the-notification-queue-connection"></a>
#### Personalizando la Conexión de Cola de Notificación

Por defecto, las notificaciones encoladas se encolarán utilizando la conexión de cola predeterminada de tu aplicación. Si deseas especificar una conexión diferente que se debe usar para una notificación particular, puedes llamar al método `onConnection` desde el constructor de tu notificación:

    <?php

    namespace App\Notifications;

    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Notifications\Notification;

    class InvoicePaid extends Notification implements ShouldQueue
    {
        use Queueable;

        /**
         * Crear una nueva instancia de notificación.
         */
        public function __construct()
        {
            $this->onConnection('redis');
        }
    }

O, si deseas especificar una conexión de cola específica que se debe usar para cada canal de notificación admitido por la notificación, puedes definir un método `viaConnections` en tu notificación. Este método debe devolver un array de pares de nombre de canal / nombre de conexión de cola:

    /**
     * Determinar qué conexiones se deben usar para cada canal de notificación.
     *
     * @return array<string, string>
     */
    public function viaConnections(): array
    {
        return [
            'mail' => 'redis',
            'database' => 'sync',
        ];
    }

<a name="customizing-notification-channel-queues"></a>
#### Personalizando las Colas de Canales de Notificación

Si deseas especificar una cola específica que se debe usar para cada canal de notificación admitido por la notificación, puedes definir un método `viaQueues` en tu notificación. Este método debe devolver un array de pares de nombre de canal / nombre de cola:

    /**
     * Determinar qué colas se deben usar para cada canal de notificación.
     *
     * @return array<string, string>
     */
    public function viaQueues(): array
    {
        return [
            'mail' => 'mail-queue',
            'slack' => 'slack-queue',
        ];
    }

<a name="queued-notification-middleware"></a>
#### Middleware de Notificación Encolada

Las notificaciones encoladas pueden definir middleware [al igual que los trabajos encolados](/docs/{{version}}/queues#job-middleware). Para comenzar, define un método `middleware` en tu clase de notificación. El método `middleware` recibirá las variables `$notifiable` y `$channel`, que te permiten personalizar el middleware devuelto según el destino de la notificación:

    use Illuminate\Queue\Middleware\RateLimited;

    /**
     * Obtener el middleware por el que debe pasar el trabajo de notificación.
     *
     * @return array<int, object>
     */
    public function middleware(object $notifiable, string $channel)
    {
        return match ($channel) {
            'email' => [new RateLimited('postmark')],
            'slack' => [new RateLimited('slack')],
            default => [],
        };
    }

<a name="queued-notifications-and-database-transactions"></a>
#### Notificaciones Encoladas y Transacciones de Base de Datos

Cuando las notificaciones encoladas se envían dentro de transacciones de base de datos, pueden ser procesadas por la cola antes de que la transacción de base de datos se haya confirmado. Cuando esto sucede, cualquier actualización que hayas realizado en modelos o registros de base de datos durante la transacción de base de datos puede no reflejarse aún en la base de datos. Además, cualquier modelo o registro de base de datos creado dentro de la transacción puede no existir en la base de datos. Si tu notificación depende de estos modelos, pueden ocurrir errores inesperados cuando se procese el trabajo que envía la notificación encolada.

Si la opción de configuración `after_commit` de tu conexión de cola está establecida en `false`, aún puedes indicar que una notificación encolada particular debe enviarse después de que todas las transacciones de base de datos abiertas se hayan confirmado llamando al método `afterCommit` al enviar la notificación:

    use App\Notifications\InvoicePaid;

    $user->notify((new InvoicePaid($invoice))->afterCommit());

Alternativamente, puedes llamar al método `afterCommit` desde el constructor de tu notificación:

    <?php

    namespace App\Notifications;

    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Notifications\Notification;

    class InvoicePaid extends Notification implements ShouldQueue
    {
        use Queueable;

        /**
         * Crear una nueva instancia de notificación.
         */
        public function __construct()
        {
            $this->afterCommit();
        }
    }

> [!NOTE]  
> Para aprender más sobre cómo solucionar estos problemas, revisa la documentación sobre [trabajos encolados y transacciones de base de datos](/docs/{{version}}/queues#jobs-and-database-transactions).

<a name="determining-if-the-queued-notification-should-be-sent"></a>
#### Determinando si se Debe Enviar una Notificación Encolada

Después de que una notificación encolada ha sido enviada a la cola para su procesamiento en segundo plano, generalmente será aceptada por un trabajador de cola y enviada a su destinatario previsto.

Sin embargo, si deseas tomar la decisión final sobre si la notificación encolada debe ser enviada después de que esté siendo procesada por un trabajador de cola, puedes definir un método `shouldSend` en la clase de notificación. Si este método devuelve `false`, la notificación no será enviada:

    /**
     * Determinar si la notificación debe ser enviada.
     */
    public function shouldSend(object $notifiable, string $channel): bool
    {
        return $this->invoice->isPaid();
    }

<a name="on-demand-notifications"></a>
### Notificaciones Bajo Demanda

A veces, es posible que necesites enviar una notificación a alguien que no esté almacenado como un "usuario" de tu aplicación. Usando el método `route` del facade `Notification`, puedes especificar información de enrutamiento de notificación ad-hoc antes de enviar la notificación:

```markdown
    use Illuminate\Broadcasting\Channel;
    use Illuminate\Support\Facades\Notification;

    Notification::route('mail', 'taylor@example.com')
                ->route('vonage', '5555555555')
                ->route('slack', '#slack-channel')
                ->route('broadcast', [new Channel('channel-name')])
                ->notify(new InvoicePaid($invoice));

Si deseas proporcionar el nombre del destinatario al enviar una notificación bajo demanda a la ruta `mail`, puedes proporcionar un array que contenga la dirección de correo electrónico como clave y el nombre como valor del primer elemento en el array:

    Notification::route('mail', [
        'barrett@example.com' => 'Barrett Blair',
    ])->notify(new InvoicePaid($invoice));

Usando el método `routes`, puedes proporcionar información de enrutamiento ad-hoc para múltiples canales de notificación a la vez:

    Notification::routes([
        'mail' => ['barrett@example.com' => 'Barrett Blair'],
        'vonage' => '5555555555',
    ])->notify(new InvoicePaid($invoice));

<a name="mail-notifications"></a>
## Notificaciones por Correo

<a name="formatting-mail-messages"></a>
### Formateo de Mensajes de Correo

Si una notificación admite ser enviada como un correo electrónico, debes definir un método `toMail` en la clase de notificación. Este método recibirá una entidad `$notifiable` y debe devolver una instancia de `Illuminate\Notifications\Messages\MailMessage`.

La clase `MailMessage` contiene algunos métodos simples para ayudarte a construir mensajes de correo electrónico transaccionales. Los mensajes de correo pueden contener líneas de texto así como un "llamado a la acción". Veamos un ejemplo del método `toMail`:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        $url = url('/invoice/'.$this->invoice->id);

        return (new MailMessage)
                    ->greeting('¡Hola!')
                    ->line('¡Una de tus facturas ha sido pagada!')
                    ->lineIf($this->amount > 0, "Monto pagado: {$this->amount}")
                    ->action('Ver Factura', $url)
                    ->line('¡Gracias por usar nuestra aplicación!');
    }

> [!NOTE]  
> Ten en cuenta que estamos usando `$this->invoice->id` en nuestro método `toMail`. Puedes pasar cualquier dato que tu notificación necesite para generar su mensaje en el constructor de la notificación.

En este ejemplo, registramos un saludo, una línea de texto, un llamado a la acción y luego otra línea de texto. Estos métodos proporcionados por el objeto `MailMessage` hacen que sea simple y rápido formatear pequeños correos electrónicos transaccionales. El canal de correo luego traducirá los componentes del mensaje en una hermosa plantilla de correo electrónico HTML responsiva con un contraparte en texto plano. Aquí hay un ejemplo de un correo electrónico generado por el canal `mail`:

<img src="https://laravel.com/img/docs/notification-example-2.png">

> [!NOTE]  
> Al enviar notificaciones por correo, asegúrate de establecer la opción de configuración `name` en tu archivo de configuración `config/app.php`. Este valor se utilizará en el encabezado y pie de página de tus mensajes de notificación por correo.

<a name="error-messages"></a>
#### Mensajes de Error

Algunas notificaciones informan a los usuarios sobre errores, como un pago de factura fallido. Puedes indicar que un mensaje de correo se refiere a un error llamando al método `error` al construir tu mensaje. Al usar el método `error` en un mensaje de correo, el botón de llamado a la acción será rojo en lugar de negro:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->error()
                    ->subject('Pago de Factura Fallido')
                    ->line('...');
    }

<a name="other-mail-notification-formatting-options"></a>
#### Otras Opciones de Formateo de Notificaciones por Correo

En lugar de definir las "líneas" de texto en la clase de notificación, puedes usar el método `view` para especificar una plantilla personalizada que debería ser utilizada para renderizar el correo de notificación:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)->view(
            'mail.invoice.paid', ['invoice' => $this->invoice]
        );
    }

Puedes especificar una vista de texto plano para el mensaje de correo pasando el nombre de la vista como el segundo elemento de un array que se le da al método `view`:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)->view(
            ['mail.invoice.paid', 'mail.invoice.paid-text'],
            ['invoice' => $this->invoice]
        );
    }

O, si tu mensaje solo tiene una vista de texto plano, puedes utilizar el método `text`:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)->text(
            'mail.invoice.paid-text', ['invoice' => $this->invoice]
        );
    }

<a name="customizing-the-sender"></a>
### Personalizando el Remitente

Por defecto, la dirección del remitente / desde del correo está definida en el archivo de configuración `config/mail.php`. Sin embargo, puedes especificar la dirección desde para una notificación específica usando el método `from`:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->from('barrett@example.com', 'Barrett Blair')
                    ->line('...');
    }

<a name="customizing-the-recipient"></a>
### Personalizando el Destinatario

Al enviar notificaciones a través del canal `mail`, el sistema de notificaciones buscará automáticamente una propiedad `email` en tu entidad notifiable. Puedes personalizar qué dirección de correo electrónico se utiliza para entregar la notificación definiendo un método `routeNotificationForMail` en la entidad notifiable:

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;
    use Illuminate\Notifications\Notification;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * Enrutar notificaciones para el canal de correo.
         *
         * @return  array<string, string>|string
         */
        public function routeNotificationForMail(Notification $notification): array|string
        {
            // Retornar solo la dirección de correo...
            return $this->email_address;

            // Retornar dirección de correo y nombre...
            return [$this->email_address => $this->name];
        }
    }

<a name="customizing-the-subject"></a>
### Personalizando el Asunto

Por defecto, el asunto del correo es el nombre de la clase de la notificación formateado a "Title Case". Así que, si tu clase de notificación se llama `InvoicePaid`, el asunto del correo será `Invoice Paid`. Si deseas especificar un asunto diferente para el mensaje, puedes llamar al método `subject` al construir tu mensaje:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->subject('Asunto de la Notificación')
                    ->line('...');
    }

<a name="customizing-the-mailer"></a>
### Personalizando el Mailer

Por defecto, la notificación por correo se enviará utilizando el mailer predeterminado definido en el archivo de configuración `config/mail.php`. Sin embargo, puedes especificar un mailer diferente en tiempo de ejecución llamando al método `mailer` al construir tu mensaje:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->mailer('postmark')
                    ->line('...');
    }

<a name="customizing-the-templates"></a>
### Personalizando las Plantillas

Puedes modificar la plantilla HTML y de texto plano utilizada por las notificaciones por correo publicando los recursos del paquete de notificaciones. Después de ejecutar este comando, las plantillas de notificación por correo se ubicarán en el directorio `resources/views/vendor/notifications`:

```shell
php artisan vendor:publish --tag=laravel-notifications
```

<a name="mail-attachments"></a>
### Adjuntos

Para agregar adjuntos a una notificación por correo, usa el método `attach` mientras construyes tu mensaje. El método `attach` acepta la ruta absoluta al archivo como su primer argumento:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->greeting('¡Hola!')
                    ->attach('/path/to/file');
    }

> [!NOTE]  
> El método `attach` ofrecido por los mensajes de correo de notificación también acepta [objetos adjuntos](/docs/{{version}}/mail#attachable-objects). Consulta la completa [documentación de objetos adjuntos](/docs/{{version}}/mail#attachable-objects) para aprender más.

Al adjuntar archivos a un mensaje, también puedes especificar el nombre de visualización y/o tipo MIME pasando un `array` como segundo argumento al método `attach`:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->greeting('¡Hola!')
                    ->attach('/path/to/file', [
                        'as' => 'name.pdf',
                        'mime' => 'application/pdf',
                    ]);
    }

A diferencia de adjuntar archivos en objetos mailable, no puedes adjuntar un archivo directamente desde un disco de almacenamiento usando `attachFromStorage`. Debes usar el método `attach` con una ruta absoluta al archivo en el disco de almacenamiento. Alternativamente, podrías devolver un [mailable](/docs/{{version}}/mail#generating-mailables) desde el método `toMail`:

    use App\Mail\InvoicePaid as InvoicePaidMailable;

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): Mailable
    {
        return (new InvoicePaidMailable($this->invoice))
                    ->to($notifiable->email)
                    ->attachFromStorage('/path/to/file');
    }

Cuando sea necesario, se pueden adjuntar múltiples archivos a un mensaje usando el método `attachMany`:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->greeting('¡Hola!')
                    ->attachMany([
                        '/path/to/forge.svg',
                        '/path/to/vapor.svg' => [
                            'as' => 'Logo.svg',
                            'mime' => 'image/svg+xml',
                        ],
                    ]);
    }

<a name="raw-data-attachments"></a>
#### Adjuntos de Datos Crudos

El método `attachData` puede ser utilizado para adjuntar una cadena de bytes crudos como un adjunto. Al llamar al método `attachData`, debes proporcionar el nombre del archivo que debe ser asignado al adjunto:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->greeting('¡Hola!')
                    ->attachData($this->pdf, 'name.pdf', [
                        'mime' => 'application/pdf',
                    ]);
    }

<a name="adding-tags-metadata"></a>
### Agregando Etiquetas y Metadatos

Algunos proveedores de correo electrónico de terceros como Mailgun y Postmark admiten "etiquetas" y "metadatos" de mensajes, que pueden ser utilizados para agrupar y rastrear correos electrónicos enviados por tu aplicación. Puedes agregar etiquetas y metadatos a un mensaje de correo a través de los métodos `tag` y `metadata`:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->greeting('¡Comentario Votado!')
                    ->tag('upvote')
                    ->metadata('comment_id', $this->comment->id);
    }

Si tu aplicación está utilizando el controlador de Mailgun, puedes consultar la documentación de Mailgun para más información sobre [etiquetas](https://documentation.mailgun.com/en/latest/user_manual.html#tagging-1) y [metadatos](https://documentation.mailgun.com/en/latest/user_manual.html#attaching-data-to-messages). Asimismo, la documentación de Postmark también puede ser consultada para más información sobre su soporte para [etiquetas](https://postmarkapp.com/blog/tags-support-for-smtp) y [metadatos](https://postmarkapp.com/support/article/1125-custom-metadata-faq).

Si tu aplicación está utilizando Amazon SES para enviar correos electrónicos, debes usar el método `metadata` para adjuntar [etiquetas "SES"](https://docs.aws.amazon.com/ses/latest/APIReference/API_MessageTag.html) al mensaje.

<a name="customizing-the-symfony-message"></a>
### Personalizando el Mensaje de Symfony

El método `withSymfonyMessage` de la clase `MailMessage` te permite registrar una función anónima que será invocada con la instancia de Mensaje de Symfony antes de enviar el mensaje. Esto te da la oportunidad de personalizar profundamente el mensaje antes de que sea entregado:

    use Symfony\Component\Mime\Email;

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->withSymfonyMessage(function (Email $message) {
                        $message->getHeaders()->addTextHeader(
                            'Custom-Header', 'Header Value'
                        );
                    });
    }

<a name="using-mailables"></a>
### Usando Mailables

Si es necesario, puedes devolver un objeto [mailable completo](/docs/{{version}}/mail) desde el método `toMail` de tu notificación. Al devolver un `Mailable` en lugar de un `MailMessage`, necesitarás especificar el destinatario del mensaje usando el método `to` del objeto mailable:

    use App\Mail\InvoicePaid as InvoicePaidMailable;
    use Illuminate\Mail\Mailable;

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): Mailable
    {
        return (new InvoicePaidMailable($this->invoice))
                    ->to($notifiable->email);
    }

<a name="mailables-and-on-demand-notifications"></a>
#### Mailables y Notificaciones Bajo Demanda

Si estás enviando una [notificación bajo demanda](#on-demand-notifications), la instancia `$notifiable` dada al método `toMail` será una instancia de `Illuminate\Notifications\AnonymousNotifiable`, que ofrece un método `routeNotificationFor` que puede ser utilizado para recuperar la dirección de correo electrónico a la que se debe enviar la notificación bajo demanda:

    use App\Mail\InvoicePaid as InvoicePaidMailable;
    use Illuminate\Notifications\AnonymousNotifiable;
    use Illuminate\Mail\Mailable;

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): Mailable
    {
        $address = $notifiable instanceof AnonymousNotifiable
                ? $notifiable->routeNotificationFor('mail')
                : $notifiable->email;

        return (new InvoicePaidMailable($this->invoice))
                    ->to($address);
    }

<a name="previewing-mail-notifications"></a>
### Previsualizando Notificaciones por Correo
```

Cuando diseñas una plantilla de notificación por correo, es conveniente previsualizar rápidamente el mensaje de correo renderizado en tu navegador como una plantilla Blade típica. Por esta razón, Laravel te permite devolver cualquier mensaje de correo generado por una notificación de correo directamente desde una función anónima de ruta o un controlador. Cuando se devuelve un `MailMessage`, se renderizará y se mostrará en el navegador, lo que te permitirá previsualizar rápidamente su diseño sin necesidad de enviarlo a una dirección de correo electrónico real:

    use App\Models\Invoice;
    use App\Notifications\InvoicePaid;

    Route::get('/notification', function () {
        $invoice = Invoice::find(1);

        return (new InvoicePaid($invoice))
                    ->toMail($invoice->user);
    });

<a name="markdown-mail-notifications"></a>
## Notificaciones de Correo Markdown

Las notificaciones de correo Markdown te permiten aprovechar las plantillas preconstruidas de notificaciones de correo, mientras te dan más libertad para escribir mensajes más largos y personalizados. Dado que los mensajes están escritos en Markdown, Laravel puede renderizar hermosas plantillas HTML responsivas para los mensajes mientras también genera automáticamente un contraparte en texto plano.

<a name="generating-the-message"></a>
### Generando el Mensaje

Para generar una notificación con una plantilla Markdown correspondiente, puedes usar la opción `--markdown` del comando Artisan `make:notification`:

```shell
php artisan make:notification InvoicePaid --markdown=mail.invoice.paid
```

Como todas las demás notificaciones de correo, las notificaciones que utilizan plantillas Markdown deben definir un método `toMail` en su clase de notificación. Sin embargo, en lugar de usar los métodos `line` y `action` para construir la notificación, usa el método `markdown` para especificar el nombre de la plantilla Markdown que debe ser utilizada. Un array de datos que desees hacer disponible para la plantilla puede ser pasado como el segundo argumento del método:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        $url = url('/invoice/'.$this->invoice->id);

        return (new MailMessage)
                    ->subject('Factura Pagada')
                    ->markdown('mail.invoice.paid', ['url' => $url]);
    }

<a name="writing-the-message"></a>
### Escribiendo el Mensaje

Las notificaciones de correo Markdown utilizan una combinación de componentes Blade y sintaxis Markdown que te permiten construir notificaciones fácilmente mientras aprovechas los componentes de notificación precreados de Laravel:

```blade
<x-mail::message>
# Invoice Paid

Your invoice has been paid!

<x-mail::button :url="$url">
View Invoice
</x-mail::button>

Thanks,<br>
{{ config('app.name') }}
</x-mail::message>
```

<a name="button-component"></a>
#### Componente de Botón

El componente de botón renderiza un enlace de botón centrado. El componente acepta dos argumentos, una `url` y un `color` opcional. Los colores soportados son `primary`, `green`, y `red`. Puedes agregar tantos componentes de botón a una notificación como desees:

```blade
<x-mail::button :url="$url" color="green">
Ver Factura
</x-mail::button>
```

<a name="panel-component"></a>
#### Componente de Panel

El componente de panel renderiza el bloque de texto dado en un panel que tiene un color de fondo ligeramente diferente al del resto de la notificación. Esto te permite llamar la atención sobre un bloque de texto dado:

```blade
<x-mail::panel>
Este es el contenido del panel.
</x-mail::panel>
```

<a name="table-component"></a>
#### Componente de Tabla

El componente de tabla te permite transformar una tabla Markdown en una tabla HTML. El componente acepta la tabla Markdown como su contenido. La alineación de las columnas de la tabla es soportada utilizando la sintaxis de alineación de tablas Markdown por defecto:

```blade
<x-mail::table>
| Laravel       | Table         | Example       |
| ------------- | :-----------: | ------------: |
| Col 2 is      | Centered      | $10           |
| Col 3 is      | Right-Aligned | $20           |
</x-mail::table>
```

<a name="customizing-the-components"></a>
### Personalizando los Componentes

Puedes exportar todos los componentes de notificación Markdown a tu propia aplicación para personalizarlos. Para exportar los componentes, usa el comando Artisan `vendor:publish` para publicar la etiqueta de activo `laravel-mail`:

```shell
php artisan vendor:publish --tag=laravel-mail
```

Este comando publicará los componentes de correo Markdown en el directorio `resources/views/vendor/mail`. El directorio `mail` contendrá un directorio `html` y un directorio `text`, cada uno conteniendo sus respectivas representaciones de cada componente disponible. Eres libre de personalizar estos componentes como desees.

<a name="customizing-the-css"></a>
#### Personalizando el CSS

Después de exportar los componentes, el directorio `resources/views/vendor/mail/html/themes` contendrá un archivo `default.css`. Puedes personalizar el CSS en este archivo y tus estilos se inyectarán automáticamente dentro de las representaciones HTML de tus notificaciones Markdown.

Si deseas construir un tema completamente nuevo para los componentes Markdown de Laravel, puedes colocar un archivo CSS dentro del directorio `html/themes`. Después de nombrar y guardar tu archivo CSS, actualiza la opción `theme` del archivo de configuración `mail` para que coincida con el nombre de tu nuevo tema.

Para personalizar el tema de una notificación individual, puedes llamar al método `theme` mientras construyes el mensaje de correo de la notificación. El método `theme` acepta el nombre del tema que debe ser utilizado al enviar la notificación:

    /**
     * Obtener la representación del correo de la notificación.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->theme('invoice')
                    ->subject('Factura Pagada')
                    ->markdown('mail.invoice.paid', ['url' => $url]);
    }

<a name="database-notifications"></a>
## Notificaciones de Base de Datos

<a name="database-prerequisites"></a>
### Requisitos Previos

El canal de notificación `database` almacena la información de la notificación en una tabla de base de datos. Esta tabla contendrá información como el tipo de notificación, así como una estructura de datos JSON que describe la notificación.

Puedes consultar la tabla para mostrar las notificaciones en la interfaz de usuario de tu aplicación. Pero, antes de que puedas hacer eso, necesitarás crear una tabla de base de datos para almacenar tus notificaciones. Puedes usar el comando `make:notifications-table` para generar una [migración](/docs/{{version}}/migrations) con el esquema de tabla adecuado:

```shell
php artisan make:notifications-table

php artisan migrate
```

> [!NOTE]  
> Si tus modelos notificados están utilizando [UUID o ULID como claves primarias](/docs/{{version}}/eloquent#uuid-and-ulid-keys), deberías reemplazar el método `morphs` con [`uuidMorphs`](/docs/{{version}}/migrations#column-method-uuidMorphs) o [`ulidMorphs`](/docs/{{version}}/migrations#column-method-ulidMorphs) en la migración de la tabla de notificaciones.

<a name="formatting-database-notifications"></a>
### Formateando Notificaciones de Base de Datos

Si una notificación admite ser almacenada en una tabla de base de datos, debes definir un método `toDatabase` o `toArray` en la clase de notificación. Este método recibirá una entidad `$notifiable` y debe devolver un array PHP plano. El array devuelto será codificado como JSON y almacenado en la columna `data` de tu tabla `notifications`. Veamos un ejemplo del método `toArray`:

    /**
     * Obtener la representación en array de la notificación.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'invoice_id' => $this->invoice->id,
            'amount' => $this->invoice->amount,
        ];
    }

Cuando la notificación se almacena en la base de datos de tu aplicación, la columna `type` se poblará con el nombre de clase de la notificación. Sin embargo, puedes personalizar este comportamiento definiendo un método `databaseType` en tu clase de notificación:

    /**
     * Obtener el tipo de base de datos de la notificación.
     *
     * @return string
     */
    public function databaseType(object $notifiable): string
    {
        return 'invoice-paid';
    }

<a name="todatabase-vs-toarray"></a>
#### `toDatabase` vs. `toArray`

El método `toArray` también es utilizado por el canal `broadcast` para determinar qué datos transmitir a tu frontend impulsado por JavaScript. Si deseas tener dos representaciones de array diferentes para los canales `database` y `broadcast`, deberías definir un método `toDatabase` en lugar de un método `toArray`.

<a name="accessing-the-notifications"></a>
### Accediendo a las Notificaciones

Una vez que las notificaciones están almacenadas en la base de datos, necesitas una forma conveniente de acceder a ellas desde tus entidades notificables. El rasgo `Illuminate\Notifications\Notifiable`, que está incluido en el modelo `App\Models\User` por defecto de Laravel, incluye una relación [Eloquent](/docs/{{version}}/eloquent-relationships) `notifications` que devuelve las notificaciones para la entidad. Para obtener notificaciones, puedes acceder a este método como cualquier otra relación Eloquent. Por defecto, las notificaciones se ordenarán por la marca de tiempo `created_at`, con las notificaciones más recientes al principio de la colección:

    $user = App\Models\User::find(1);

    foreach ($user->notifications as $notification) {
        echo $notification->type;
    }

Si deseas recuperar solo las notificaciones "no leídas", puedes usar la relación `unreadNotifications`. Nuevamente, estas notificaciones se ordenarán por la marca de tiempo `created_at`, con las notificaciones más recientes al principio de la colección:

    $user = App\Models\User::find(1);

    foreach ($user->unreadNotifications as $notification) {
        echo $notification->type;
    }

> [!NOTE]  
> Para acceder a tus notificaciones desde tu cliente JavaScript, deberías definir un controlador de notificaciones para tu aplicación que devuelva las notificaciones para una entidad notificable, como el usuario actual. Luego puedes hacer una solicitud HTTP a la URL de ese controlador desde tu cliente JavaScript.

<a name="marking-notifications-as-read"></a>
### Marcando Notificaciones como Leídas

Típicamente, querrás marcar una notificación como "leída" cuando un usuario la visualiza. El rasgo `Illuminate\Notifications\Notifiable` proporciona un método `markAsRead`, que actualiza la columna `read_at` en el registro de la base de datos de la notificación:

    $user = App\Models\User::find(1);

    foreach ($user->unreadNotifications as $notification) {
        $notification->markAsRead();
    }

Sin embargo, en lugar de recorrer cada notificación, puedes usar el método `markAsRead` directamente en una colección de notificaciones:

    $user->unreadNotifications->markAsRead();

También puedes usar una consulta de actualización masiva para marcar todas las notificaciones como leídas sin recuperarlas de la base de datos:

    $user = App\Models\User::find(1);

    $user->unreadNotifications()->update(['read_at' => now()]);

Puedes `delete` las notificaciones para eliminarlas de la tabla por completo:

    $user->notifications()->delete();

<a name="broadcast-notifications"></a>
## Notificaciones de Transmisión

<a name="broadcast-prerequisites"></a>
### Requisitos Previos

Antes de transmitir notificaciones, debes configurar y familiarizarte con los servicios de [transmisión de eventos](/docs/{{version}}/broadcasting) de Laravel. La transmisión de eventos proporciona una forma de reaccionar a eventos de Laravel del lado del servidor desde tu frontend impulsado por JavaScript.

<a name="formatting-broadcast-notifications"></a>
### Formateando Notificaciones de Transmisión

El canal `broadcast` transmite notificaciones utilizando los servicios de [transmisión de eventos](/docs/{{version}}/broadcasting) de Laravel, permitiendo que tu frontend impulsado por JavaScript reciba notificaciones en tiempo real. Si una notificación admite la transmisión, puedes definir un método `toBroadcast` en la clase de notificación. Este método recibirá una entidad `$notifiable` y debe devolver una instancia de `BroadcastMessage`. Si el método `toBroadcast` no existe, se utilizará el método `toArray` para reunir los datos que deben ser transmitidos. Los datos devueltos serán codificados como JSON y transmitidos a tu frontend impulsado por JavaScript. Veamos un ejemplo del método `toBroadcast`:

    use Illuminate\Notifications\Messages\BroadcastMessage;

    /**
     * Obtener la representación transmitible de la notificación.
     */
    public function toBroadcast(object $notifiable): BroadcastMessage
    {
        return new BroadcastMessage([
            'invoice_id' => $this->invoice->id,
            'amount' => $this->invoice->amount,
        ]);
    }

<a name="broadcast-queue-configuration"></a>
#### Configuración de Cola de Transmisión

Todas las notificaciones de transmisión se ponen en cola para su transmisión. Si deseas configurar la conexión de cola o el nombre de cola que se utiliza para poner en cola la operación de transmisión, puedes usar los métodos `onConnection` y `onQueue` de `BroadcastMessage`:

    return (new BroadcastMessage($data))
                    ->onConnection('sqs')
                    ->onQueue('broadcasts');

<a name="customizing-the-notification-type"></a>
#### Personalizando el Tipo de Notificación

Además de los datos que especifiques, todas las notificaciones de transmisión también tienen un campo `type` que contiene el nombre completo de la clase de la notificación. Si deseas personalizar el `type` de la notificación, puedes definir un método `broadcastType` en la clase de notificación:

    /**
     * Obtener el tipo de la notificación que se está transmitiendo.
     */
    public function broadcastType(): string
    {
        return 'broadcast.message';
    }

<a name="listening-for-notifications"></a>
### Escuchando Notificaciones

Las notificaciones se transmitirán en un canal privado formateado utilizando una convención `{notifiable}.{id}`. Así que, si estás enviando una notificación a una instancia de `App\Models\User` con un ID de `1`, la notificación se transmitirá en el canal privado `App.Models.User.1`. Al usar [Laravel Echo](/docs/{{version}}/broadcasting#client-side-installation), puedes escuchar fácilmente las notificaciones en un canal utilizando el método `notification`:

    Echo.private('App.Models.User.' + userId)
        .notification((notification) => {
            console.log(notification.type);
        });

<a name="customizing-the-notification-channel"></a>
#### Personalizando el Canal de Notificación

Si deseas personalizar en qué canal se transmiten las notificaciones de una entidad, puedes definir un método `receivesBroadcastNotificationsOn` en la entidad notificable:

    <?php

    namespace App\Models;

    use Illuminate\Broadcasting\PrivateChannel;
    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * Los canales en los que el usuario recibe transmisiones de notificación.
         */
        public function receivesBroadcastNotificationsOn(): string
        {
            return 'users.'.$this->id;
        }
    }

<a name="sms-notifications"></a>
## Notificaciones SMS

<a name="sms-prerequisites"></a>
### Requisitos Previos

Enviar notificaciones SMS en Laravel es impulsado por [Vonage](https://www.vonage.com/) (anteriormente conocido como Nexmo). Antes de que puedas enviar notificaciones a través de Vonage, necesitas instalar los paquetes `laravel/vonage-notification-channel` y `guzzlehttp/guzzle`:

    composer require laravel/vonage-notification-channel guzzlehttp/guzzle

El paquete incluye un [archivo de configuración](https://github.com/laravel/vonage-notification-channel/blob/3.x/config/vonage.php). Sin embargo, no estás obligado a exportar este archivo de configuración a tu propia aplicación. Simplemente puedes usar las variables de entorno `VONAGE_KEY` y `VONAGE_SECRET` para definir tus claves públicas y secretas de Vonage.

Después de definir tus claves, deberías establecer una variable de entorno `VONAGE_SMS_FROM` que defina el número de teléfono desde el cual se deben enviar tus mensajes SMS por defecto. Puedes generar este número de teléfono dentro del panel de control de Vonage:

    VONAGE_SMS_FROM=15556666666

<a name="formatting-sms-notifications"></a>
### Formateo de Notificaciones SMS

Si una notificación admite ser enviada como un SMS, debes definir un método `toVonage` en la clase de notificación. Este método recibirá una entidad `$notifiable` y debe devolver una instancia de `Illuminate\Notifications\Messages\VonageMessage`:

    use Illuminate\Notifications\Messages\VonageMessage;

    /**
     * Obtener la representación de Vonage / SMS de la notificación.
     */
    public function toVonage(object $notifiable): VonageMessage
    {
        return (new VonageMessage)
                    ->content('El contenido de tu mensaje SMS');
    }

<a name="unicode-content"></a>
#### Contenido Unicode

Si tu mensaje SMS contendrá caracteres unicode, debes llamar al método `unicode` al construir la instancia de `VonageMessage`:

    use Illuminate\Notifications\Messages\VonageMessage;

    /**
     * Obtener la representación de Vonage / SMS de la notificación.
     */
    public function toVonage(object $notifiable): VonageMessage
    {
        return (new VonageMessage)
                    ->content('Tu mensaje unicode')
                    ->unicode();
    }

<a name="customizing-the-from-number"></a>
### Personalizando el Número "De"

Si deseas enviar algunas notificaciones desde un número de teléfono que es diferente del número de teléfono especificado por tu variable de entorno `VONAGE_SMS_FROM`, puedes llamar al método `from` en una instancia de `VonageMessage`:

    use Illuminate\Notifications\Messages\VonageMessage;

    /**
     * Obtener la representación de Vonage / SMS de la notificación.
     */
    public function toVonage(object $notifiable): VonageMessage
    {
        return (new VonageMessage)
                    ->content('El contenido de tu mensaje SMS')
                    ->from('15554443333');
    }

<a name="adding-a-client-reference"></a>
### Agregando una Referencia de Cliente

Si deseas llevar un seguimiento de los costos por usuario, equipo o cliente, puedes agregar una "referencia de cliente" a la notificación. Vonage te permitirá generar informes utilizando esta referencia de cliente para que puedas entender mejor el uso de SMS de un cliente en particular. La referencia de cliente puede ser cualquier cadena de hasta 40 caracteres:

    use Illuminate\Notifications\Messages\VonageMessage;

    /**
     * Obtener la representación de Vonage / SMS de la notificación.
     */
    public function toVonage(object $notifiable): VonageMessage
    {
        return (new VonageMessage)
                    ->clientReference((string) $notifiable->id)
                    ->content('El contenido de tu mensaje SMS');
    }

<a name="routing-sms-notifications"></a>
### Enrutando Notificaciones SMS

Para enrutar las notificaciones de Vonage al número de teléfono adecuado, define un método `routeNotificationForVonage` en tu entidad notifiable:

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;
    use Illuminate\Notifications\Notification;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * Enrutar notificaciones para el canal de Vonage.
         */
        public function routeNotificationForVonage(Notification $notification): string
        {
            return $this->phone_number;
        }
    }

<a name="slack-notifications"></a>
## Notificaciones de Slack

<a name="slack-prerequisites"></a>
### Requisitos Previos

Antes de enviar notificaciones de Slack, debes instalar el canal de notificación de Slack a través de Composer:

```shell
composer require laravel/slack-notification-channel
```

Además, debes crear una [Aplicación de Slack](https://api.slack.com/apps?new_app=1) para tu espacio de trabajo de Slack.

Si solo necesitas enviar notificaciones al mismo espacio de trabajo de Slack en el que se creó la Aplicación, debes asegurarte de que tu Aplicación tenga los alcances `chat:write`, `chat:write.public` y `chat:write.customize`. Estos alcances se pueden agregar desde la pestaña de gestión de la Aplicación "OAuth & Permissions" dentro de Slack.

A continuación, copia el "Token OAuth de Bot User" de la Aplicación y colócalo dentro de un array de configuración `slack` en el archivo de configuración `services.php` de tu aplicación. Este token se puede encontrar en la pestaña "OAuth & Permissions" dentro de Slack:

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

<a name="slack-app-distribution"></a>
#### Distribución de la Aplicación

Si tu aplicación enviará notificaciones a espacios de trabajo de Slack externos que son propiedad de los usuarios de tu aplicación, necesitarás "distribuir" tu Aplicación a través de Slack. La distribución de la Aplicación se puede gestionar desde la pestaña "Manage Distribution" de tu Aplicación dentro de Slack. Una vez que tu Aplicación ha sido distribuida, puedes usar [Socialite](/docs/{{version}}/socialite) para [obtener tokens de Bot de Slack](/docs/{{version}}/socialite#slack-bot-scopes) en nombre de los usuarios de tu aplicación.

<a name="formatting-slack-notifications"></a>
### Formateo de Notificaciones de Slack

Si una notificación admite ser enviada como un mensaje de Slack, debes definir un método `toSlack` en la clase de notificación. Este método recibirá una entidad `$notifiable` y debe devolver una instancia de `Illuminate\Notifications\Slack\SlackMessage`. Puedes construir notificaciones enriquecidas utilizando [la API Block Kit de Slack](https://api.slack.com/block-kit). El siguiente ejemplo puede ser previsualizado en [el generador Block Kit de Slack](https://app.slack.com/block-kit-builder/T01KWS6K23Z#%7B%22blocks%22:%5B%7B%22type%22:%22header%22,%22text%22:%7B%22type%22:%22plain_text%22,%22text%22:%22Factura%20Pagada%22%7D%7D,%7B%22type%22:%22context%22,%22elements%22:%5B%7B%22type%22:%22plain_text%22,%22text%22:%22Cliente%20%231234%22%7D%5D%7D,%7B%22type%22:%22section%22,%22text%22:%7B%22type%22:%22plain_text%22,%22text%22:%22Se%20ha%20pagado%20una%20factura.%22%7D,%22fields%22:%5B%7B%22type%22:%22mrkdwn%22,%22text%22:%22*Factura%20No:*%5Cn1000%22%7D,%7B%22type%22:%22mrkdwn%22,%22text%22:%22*Destinatario%20de%20la%20Factura:*%5Cntaylor@laravel.com%22%7D%5D%7D,%7B%22type%22:%22divider%22%7D,%7B%22type%22:%22section%22,%22text%22:%7B%22type%22:%22plain_text%22,%22text%22:%22¡Felicidades!%22%7D%7D%5D%7D):

    use Illuminate\Notifications\Slack\BlockKit\Blocks\ContextBlock;
    use Illuminate\Notifications\Slack\BlockKit\Blocks\SectionBlock;
    use Illuminate\Notifications\Slack\BlockKit\Composites\ConfirmObject;
    use Illuminate\Notifications\Slack\SlackMessage;

    /**
     * Obtener la representación de Slack de la notificación.
     */
    public function toSlack(object $notifiable): SlackMessage
    {
        return (new SlackMessage)
                ->text('¡Una de tus facturas ha sido pagada!')
                ->headerBlock('Factura Pagada')
                ->contextBlock(function (ContextBlock $block) {
                    $block->text('Cliente #1234');
                })
                ->sectionBlock(function (SectionBlock $block) {
                    $block->text('Se ha pagado una factura.');
                    $block->field("*Factura No:*\n1000")->markdown();
                    $block->field("*Destinatario de la Factura:*\ntaylor@laravel.com")->markdown();
                })
                ->dividerBlock()
                ->sectionBlock(function (SectionBlock $block) {
                    $block->text('¡Felicidades!');
                });
    }

<a name="slack-interactivity"></a>
### Interactividad de Slack

El sistema de notificaciones Block Kit de Slack proporciona potentes características para [manejar la interacción del usuario](https://api.slack.com/interactivity/handling). Para utilizar estas características, tu Aplicación de Slack debe tener "Interactividad" habilitada y una "URL de Solicitud" configurada que apunte a una URL servida por tu aplicación. Estas configuraciones se pueden gestionar desde la pestaña de gestión de la Aplicación "Interactivity & Shortcuts" dentro de Slack.

En el siguiente ejemplo, que utiliza el método `actionsBlock`, Slack enviará una solicitud `POST` a tu "URL de Solicitud" con una carga útil que contiene el usuario de Slack que hizo clic en el botón, el ID del botón clicado, y más. Tu aplicación puede entonces determinar la acción a tomar basada en la carga útil. También debes [verificar la solicitud](https://api.slack.com/authentication/verifying-requests-from-slack) fue hecha por Slack:

    use Illuminate\Notifications\Slack\BlockKit\Blocks\ActionsBlock;
    use Illuminate\Notifications\Slack\BlockKit\Blocks\ContextBlock;
    use Illuminate\Notifications\Slack\BlockKit\Blocks\SectionBlock;
    use Illuminate\Notifications\Slack\SlackMessage;

    /**
     * Obtener la representación de Slack de la notificación.
     */
    public function toSlack(object $notifiable): SlackMessage
    {
        return (new SlackMessage)
                ->text('¡Una de tus facturas ha sido pagada!')
                ->headerBlock('Factura Pagada')
                ->contextBlock(function (ContextBlock $block) {
                    $block->text('Cliente #1234');
                })
                ->sectionBlock(function (SectionBlock $block) {
                    $block->text('Se ha pagado una factura.');
                })
                ->actionsBlock(function (ActionsBlock $block) {
                     // ID predeterminado es "button_acknowledge_invoice"...
                    $block->button('Reconocer Factura')->primary();

                    // Configurar manualmente el ID...
                    $block->button('Negar')->danger()->id('deny_invoice');
                });
    }

<a name="slack-confirmation-modals"></a>
#### Modales de Confirmación

Si deseas que los usuarios deban confirmar una acción antes de que se realice, puedes invocar el método `confirm` al definir tu botón. El método `confirm` acepta un mensaje y una función anónima que recibe una instancia de `ConfirmObject`:

    use Illuminate\Notifications\Slack\BlockKit\Blocks\ActionsBlock;
    use Illuminate\Notifications\Slack\BlockKit\Blocks\ContextBlock;
    use Illuminate\Notifications\Slack\BlockKit\Blocks\SectionBlock;
    use Illuminate\Notifications\Slack\BlockKit\Composites\ConfirmObject;
    use Illuminate\Notifications\Slack\SlackMessage;

    /**
     * Obtener la representación de Slack de la notificación.
     */
    public function toSlack(object $notifiable): SlackMessage
    {
        return (new SlackMessage)
                ->text('¡Una de tus facturas ha sido pagada!')
                ->headerBlock('Factura Pagada')
                ->contextBlock(function (ContextBlock $block) {
                    $block->text('Cliente #1234');
                })
                ->sectionBlock(function (SectionBlock $block) {
                    $block->text('Se ha pagado una factura.');
                })
                ->actionsBlock(function (ActionsBlock $block) {
                    $block->button('Reconocer Factura')
                        ->primary()
                        ->confirm(
                            '¿Reconocer el pago y enviar un correo electrónico de agradecimiento?',
                            function (ConfirmObject $dialog) {
                                $dialog->confirm('Sí');
                                $dialog->deny('No');
                            }
                        );
                });
    }

<a name="inspecting-slack-blocks"></a>
#### Inspeccionando Bloques de Slack

Si deseas inspeccionar rápidamente los bloques que has estado construyendo, puedes invocar el método `dd` en la instancia de `SlackMessage`. El método `dd` generará y volcará una URL al [Generador Block Kit de Slack](https://app.slack.com/block-kit-builder/), que muestra una vista previa de la carga útil y la notificación en tu navegador. Puedes pasar `true` al método `dd` para volcar la carga útil sin procesar:

    return (new SlackMessage)
            ->text('¡Una de tus facturas ha sido pagada!')
            ->headerBlock('Factura Pagada')
            ->dd();

<a name="routing-slack-notifications"></a>
### Enrutando Notificaciones de Slack

Para dirigir las notificaciones de Slack al equipo y canal de Slack apropiados, define un método `routeNotificationForSlack` en tu modelo notifiable. Este método puede devolver uno de tres valores:

- `null` - que difiere el enrutamiento al canal configurado en la notificación misma. Puedes usar el método `to` al construir tu `SlackMessage` para configurar el canal dentro de la notificación.
- Una cadena que especifica el canal de Slack al que enviar la notificación, por ejemplo, `#support-channel`.
- Una instancia de `SlackRoute`, que te permite especificar un token OAuth y un nombre de canal, por ejemplo, `SlackRoute::make($this->slack_channel, $this->slack_token)`. Este método debe ser utilizado para enviar notificaciones a espacios de trabajo externos.

Por ejemplo, devolver `#support-channel` desde el método `routeNotificationForSlack` enviará la notificación al canal `#support-channel` en el espacio de trabajo asociado con el token OAuth de Bot User ubicado en el archivo de configuración `services.php` de tu aplicación:

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;
    use Illuminate\Notifications\Notification;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * Enrutar notificaciones para el canal de Slack.
         */
        public function routeNotificationForSlack(Notification $notification): mixed
        {
            return '#support-channel';
        }
    }

<a name="notifying-external-slack-workspaces"></a>
### Notificando Espacios de Trabajo de Slack Externos

> [!NOTE]  
> Antes de enviar notificaciones a espacios de trabajo de Slack externos, tu Aplicación de Slack debe ser [distribuida](#slack-app-distribution).

Por supuesto, a menudo querrás enviar notificaciones a los espacios de trabajo de Slack que son propiedad de los usuarios de tu aplicación. Para hacerlo, primero necesitarás obtener un token OAuth de Slack para el usuario. Afortunadamente, [Laravel Socialite](/docs/{{version}}/socialite) incluye un controlador de Slack que te permitirá autenticar fácilmente a los usuarios de tu aplicación con Slack y [obtener un token de bot](/docs/{{version}}/socialite#slack-bot-scopes).

Una vez que hayas obtenido el token de bot y lo hayas almacenado en la base de datos de tu aplicación, puedes utilizar el método `SlackRoute::make` para enrutar una notificación al espacio de trabajo del usuario. Además, tu aplicación probablemente necesitará ofrecer una oportunidad para que el usuario especifique a qué canal deben enviarse las notificaciones:

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;
    use Illuminate\Notifications\Notification;
    use Illuminate\Notifications\Slack\SlackRoute;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * Enrutar notificaciones para el canal de Slack.
         */
        public function routeNotificationForSlack(Notification $notification): mixed
        {
            return SlackRoute::make($this->slack_channel, $this->slack_token);
        }
    }

<a name="localizing-notifications"></a>
## Localizando Notificaciones

Laravel te permite enviar notificaciones en un idioma diferente al idioma actual de la solicitud HTTP, y recordará este idioma si la notificación está en cola.

Para lograr esto, la clase `Illuminate\Notifications\Notification` ofrece un método `locale` para establecer el idioma deseado. La aplicación cambiará a este idioma cuando la notificación esté siendo evaluada y luego volverá al idioma anterior cuando la evaluación esté completa:

```php
$user->notify((new InvoicePaid($invoice))->locale('es'));

La localización de múltiples entradas notificables también se puede lograr a través de la fachada `Notification`:

    Notification::locale('es')->send(
        $users, new InvoicePaid($invoice)
    );

<a name="user-preferred-locales"></a>
### Locales Preferidos del Usuario

A veces, las aplicaciones almacenan el locale preferido de cada usuario. Al implementar el contrato `HasLocalePreference` en tu modelo notificable, puedes instruir a Laravel para que use este locale almacenado al enviar una notificación:

    use Illuminate\Contracts\Translation\HasLocalePreference;

    class User extends Model implements HasLocalePreference
    {
        /**
         * Obtener el locale preferido del usuario.
         */
        public function preferredLocale(): string
        {
            return $this->locale;
        }
    }

Una vez que hayas implementado la interfaz, Laravel usará automáticamente el locale preferido al enviar notificaciones y mailables al modelo. Por lo tanto, no es necesario llamar al método `locale` al usar esta interfaz:

    $user->notify(new InvoicePaid($invoice));

<a name="testing"></a>
## Pruebas

Puedes usar el método `fake` de la fachada `Notification` para evitar que se envíen notificaciones. Típicamente, el envío de notificaciones no está relacionado con el código que realmente estás probando. Lo más probable es que sea suficiente simplemente afirmar que Laravel fue instruido para enviar una notificación dada.

Después de llamar al método `fake` de la fachada `Notification`, puedes afirmar que se instruyó a enviar notificaciones a los usuarios e incluso inspeccionar los datos que recibieron las notificaciones:

```php tab=Pest
<?php

use App\Notifications\OrderShipped;
use Illuminate\Support\Facades\Notification;

test('orders can be shipped', function () {
    Notification::fake();

    // Perform order shipping...

    // Assert that no notifications were sent...
    Notification::assertNothingSent();

    // Assert a notification was sent to the given users...
    Notification::assertSentTo(
        [$user], OrderShipped::class
    );

    // Assert a notification was not sent...
    Notification::assertNotSentTo(
        [$user], AnotherNotification::class
    );

    // Assert that a given number of notifications were sent...
    Notification::assertCount(3);
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use App\Notifications\OrderShipped;
use Illuminate\Support\Facades\Notification;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_orders_can_be_shipped(): void
    {
        Notification::fake();

        // Perform order shipping...

        // Assert that no notifications were sent...
        Notification::assertNothingSent();

        // Assert a notification was sent to the given users...
        Notification::assertSentTo(
            [$user], OrderShipped::class
        );

        // Assert a notification was not sent...
        Notification::assertNotSentTo(
            [$user], AnotherNotification::class
        );

        // Assert that a given number of notifications were sent...
        Notification::assertCount(3);
    }
}
```

Puedes pasar una función anónima a los métodos `assertSentTo` o `assertNotSentTo` para afirmar que se envió una notificación que pasa una "prueba de verdad" dada. Si al menos una notificación fue enviada que pasa la prueba de verdad dada, entonces la afirmación será exitosa:

    Notification::assertSentTo(
        $user,
        function (OrderShipped $notification, array $channels) use ($order) {
            return $notification->order->id === $order->id;
        }
    );

<a name="on-demand-notifications"></a>
#### Notificaciones a Pedido

Si el código que estás probando envía [notificaciones a pedido](#on-demand-notifications), puedes probar que la notificación a pedido fue enviada a través del método `assertSentOnDemand`:

    Notification::assertSentOnDemand(OrderShipped::class);

Al pasar una función anónima como segundo argumento al método `assertSentOnDemand`, puedes determinar si se envió una notificación a pedido a la dirección "ruta" correcta:

    Notification::assertSentOnDemand(
        OrderShipped::class,
        function (OrderShipped $notification, array $channels, object $notifiable) use ($user) {
            return $notifiable->routes['mail'] === $user->email;
        }
    );

<a name="notification-events"></a>
## Eventos de Notificación

<a name="notification-sending-event"></a>
#### Evento de Envío de Notificación

Cuando se envía una notificación, el evento `Illuminate\Notifications\Events\NotificationSending` es despachado por el sistema de notificaciones. Esto contiene la entidad "notificable" y la instancia de la notificación en sí. Puedes crear [escuchadores de eventos](/docs/{{version}}/events) para este evento dentro de tu aplicación:

    use Illuminate\Notifications\Events\NotificationSending;

    class CheckNotificationStatus
    {
        /**
         * Manejar el evento dado.
         */
        public function handle(NotificationSending $event): void
        {
            // ...
        }
    }

La notificación no se enviará si un escuchador de eventos para el evento `NotificationSending` devuelve `false` desde su método `handle`:

    /**
     * Manejar el evento dado.
     */
    public function handle(NotificationSending $event): bool
    {
        return false;
    }

Dentro de un escuchador de eventos, puedes acceder a las propiedades `notifiable`, `notification` y `channel` en el evento para aprender más sobre el destinatario de la notificación o la notificación en sí:

    /**
     * Manejar el evento dado.
     */
    public function handle(NotificationSending $event): void
    {
        // $event->channel
        // $event->notifiable
        // $event->notification
    }

<a name="notification-sent-event"></a>
#### Evento de Notificación Enviada

Cuando se envía una notificación, el evento `Illuminate\Notifications\Events\NotificationSent` [evento](/docs/{{version}}/events) es despachado por el sistema de notificaciones. Esto contiene la entidad "notificable" y la instancia de la notificación en sí. Puedes crear [escuchadores de eventos](/docs/{{version}}/events) para este evento dentro de tu aplicación:

    use Illuminate\Notifications\Events\NotificationSent;

    class LogNotification
    {
        /**
         * Manejar el evento dado.
         */
        public function handle(NotificationSent $event): void
        {
            // ...
        }
    }

Dentro de un escuchador de eventos, puedes acceder a las propiedades `notifiable`, `notification`, `channel` y `response` en el evento para aprender más sobre el destinatario de la notificación o la notificación en sí:

    /**
     * Manejar el evento dado.
     */
    public function handle(NotificationSent $event): void
    {
        // $event->channel
        // $event->notifiable
        // $event->notification
        // $event->response
    }

<a name="custom-channels"></a>
## Canales Personalizados

Laravel incluye un puñado de canales de notificación, pero es posible que desees escribir tus propios controladores para entregar notificaciones a través de otros canales. Laravel lo hace simple. Para comenzar, define una clase que contenga un método `send`. El método debe recibir dos argumentos: un `$notifiable` y una `$notification`.

Dentro del método `send`, puedes llamar a métodos en la notificación para recuperar un objeto de mensaje entendido por tu canal y luego enviar la notificación a la instancia `$notifiable` como desees:

    <?php

    namespace App\Notifications;

    use Illuminate\Notifications\Notification;

    class VoiceChannel
    {
        /**
         * Enviar la notificación dada.
         */
        public function send(object $notifiable, Notification $notification): void
        {
            $message = $notification->toVoice($notifiable);

            // Enviar notificación a la instancia $notifiable...
        }
    }

Una vez que tu clase de canal de notificación ha sido definida, puedes devolver el nombre de la clase desde el método `via` de cualquiera de tus notificaciones. En este ejemplo, el método `toVoice` de tu notificación puede devolver cualquier objeto que elijas para representar mensajes de voz. Por ejemplo, podrías definir tu propia clase `VoiceMessage` para representar estos mensajes:

    <?php

    namespace App\Notifications;

    use App\Notifications\Messages\VoiceMessage;
    use App\Notifications\VoiceChannel;
    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Notifications\Notification;

    class InvoicePaid extends Notification
    {
        use Queueable;

        /**
         * Obtener los canales de notificación.
         */
        public function via(object $notifiable): string
        {
            return VoiceChannel::class;
        }

        /**
         * Obtener la representación de voz de la notificación.
         */
        public function toVoice(object $notifiable): VoiceMessage
        {
            // ...
        }
    }
```
