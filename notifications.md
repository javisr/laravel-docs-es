# Notificaciones

- [Introducción](#introduction)
- [Generación de notificaciones](#generating-notifications)
- [Envío de notificaciones](#sending-notifications)
  - [Uso del trait Notificable](#using-the-notifiable-trait)
  - [Uso de la facade de notificación](#using-the-notification-facade)
  - [Especificación de Canales de Entrega](#specifying-delivery-channels)
  - [Puesta en cola de notificaciones](#queueing-notifications)
  - [Notificaciones a petición](#on-demand-notifications)
- [Notificaciones por correo](#mail-notifications)
  - [Formateo de Mensajes de Correo](#formatting-mail-messages)
  - [Personalización del remitente](#customizing-the-sender)
  - [Personalización del destinatario](#customizing-the-recipient)
  - [Personalización del asunto](#customizing-the-subject)
  - [Personalización del remitente](#customizing-the-mailer)
  - [Personalización de las plantillas](#customizing-the-templates)
  - [Adjuntos](#mail-attachments)
  - [Añadir etiquetas y metadatos](#adding-tags-metadata)
  - [Personalización del mensaje Symfony](#customizing-the-symfony-message)
  - [Uso de Mailables](#using-mailables)
  - [Vista previa de las notificaciones por correo](#previewing-mail-notifications)
- [Notificaciones de correo Markdown](#markdown-mail-notifications)
  - [Generación del mensaje](#generating-the-message)
  - [Escribiendo el mensaje](#writing-the-message)
  - [Personalización de los componentes](#customizing-the-components)
- [Notificaciones de base de datos](#database-notifications)
  - [Requisitos previos](#database-prerequisites)
  - [Formateo de Notificaciones de Base de Datos](#formatting-database-notifications)
  - [Acceso a las notificaciones](#accessing-the-notifications)
  - [Marcar Notificaciones como Leídas](#marking-notifications-as-read)
- [Difusión de Notificaciones](#broadcast-notifications)
  - [Requisitos previos](#broadcast-prerequisites)
  - [Formateo de Notificaciones de Difusión](#formatting-broadcast-notifications)
  - [Recepción de notificaciones](#listening-for-notifications)
- [Notificaciones SMS](#sms-notifications)
  - [Requisitos previos](#sms-prerequisites)
  - [Formateo de notificaciones SMS](#formatting-sms-notifications)
  - [Formateo de notificaciones con código corto](#formatting-shortcode-notifications)
  - [Personalización del número "Desde"](#customizing-the-from-number)
  - [Añadir una referencia de cliente](#adding-a-client-reference)
  - [Enrutamiento de notificaciones SMS](#routing-sms-notifications)
- [Notificaciones de Slack](#slack-notifications)
  - [Requisitos previos](#slack-prerequisites)
  - [Formato de las notificaciones de Slack](#formatting-slack-notifications)
  - [Adjuntos de Slack](#slack-attachments)
  - [Enrutamiento de notificaciones de Slack](#routing-slack-notifications)
- [Localización de Notificaciones](#localizing-notifications)
- [Eventos de Notificación](#notification-events)
- [Canales Personalizados](#custom-channels)

<a name="introduction"></a>
## Introducción

Además de soporte para [el envío de emails](/docs/{{version}}/mail), Laravel proporciona soporte para el envío de notificaciones a través de una variedad de canales, incluyendo email, SMS (a través de [Vonage](https://www.vonage.com/communications-apis/), anteriormente conocido como Nexmo), y [Slack](https://slack.com). Además, existe una gran variedad de [canales de notificación construidos por la comunidad](https://laravel-notification-channels.com/about/#suggesting-a-new-channel) para enviar notificaciones a través de docenas de canales diferentes. Las notificaciones también pueden almacenarse en una base de datos para que puedan mostrarse en su interfaz web.

Normalmente, las notificaciones son mensajes cortos e informativos que avisen a los usuarios de algo que ha ocurrido en tu aplicación. Por ejemplo, si estás escribiendo una aplicación de facturación, podrías enviar una notificación de "Factura pagada" a tus usuarios a través de los canales de email y SMS.

<a name="generating-notifications"></a>
## Generación de Notificaciones

En Laravel, cada notificación está representada por una única clase que normalmente se almacena en el directorio `app/Notifications`. No te preocupes si no ves este directorio en tu aplicación - será creado para automaticamente cuando ejecutes el comando `make:notification` Artisan:

```shell
php artisan make:notification InvoicePaid
```

Este comando colocará una nueva clase de notificación en el directorio `app/Notifications`. Cada clase de notificación contiene un método `via` y un número variable de métodos de construcción de mensajes, como `toMail` o `toDatabase`, que convierten la notificación en un mensaje adaptado a ese canal en particular.

<a name="sending-notifications"></a>
## Envío de notificaciones

<a name="using-the-notifiable-trait"></a>
### Uso del Rasgo Notificable

Las notificaciones pueden enviarse de dos formas: utilizando el método `notify` del trait `Notifiable` o utilizando la [facade](/docs/{{version}}/facades) `Notification`. El trait `Notifiable` se incluye por defecto en el modelo `App\Models\User` de su aplicación:

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

> **Nota**  
> Recuerda que puedes utilizar el trait `Notifiable` en cualquiera de tus modelos. No estás limitado a incluirlo sólo en tu modelo de `User`.

<a name="using-the-notification-facade"></a>
### Uso de la facade de notificación

De manera alternativa, puede enviar notificaciones a través de la [facade](/docs/{{version}}/facades) `Notification`. Este enfoque es útil cuando se necesita enviar una notificación a múltiples entidades notificables, como una colección de usuarios. Para enviar notificaciones utilizando la facade, pasa todas las entidades notificables y la instancia de notificación al método `send`:

    use Illuminate\Support\Facades\Notification;

    Notification::send($users, new InvoicePaid($invoice));

También puedes enviar notificaciones inmediatamente utilizando el método `sendNow`. Este método enviará la notificación inmediatamente incluso si la notificación implementa la interfaz `ShouldQueue`:

    Notification::sendNow($developers, new DeploymentCompleted($deployment));

<a name="specifying-delivery-channels"></a>
### Especificación de Canales de Entrega

Cada clase de notificación tiene un método `via` que determina en qué canales se enviará la notificación. Las notificaciones pueden enviarse a través de los canales `mail`, `database`, `broadcast`, `vonage` y `slack`.

> **Nota**  
> Si quieres utilizar otros canales de envío como Telegram o Pusher, consulta el [sitio web](http://laravel-notification-channels.com) de la comunidad [Laravel Notification Channels](http://laravel-notification-channels.com).

El método `via` recibe una instancia `$notifiable`, que será una instancia de la clase a la que se está enviando la notificación. Puede utilizar `$notifiable` para determinar en qué canales debe enviarse la notificación:

    /**
     * Get the notification's delivery channels.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        return $notifiable->prefers_sms ? ['vonage'] : ['mail', 'database'];
    }

<a name="queueing-notifications"></a>
### Puesta en cola de notificaciones

> **Advertencia**  
> Antes de poner notificaciones en cola deberías configurar tu cola e [iniciar un worker](/docs/{{version}}/queues).

El envío de notificaciones puede llevar tiempo, especialmente si el canal necesita hacer una llamada a una API externa para entregar la notificación. Para acelerar el tiempo de respuesta de tu aplicación, manda tu notificación a la cola añadiendo la interfaz `ShouldQueue` y el trait `Queueable` a tu clase. La interfaz y el trait ya están importados para todas las notificaciones generadas mediante el comando `make:notification`, por lo que puedes añadirlos inmediatamente a tu clase de notificación:

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

Una vez que la interfaz `ShouldQueue` ha sido añadida a tu notificación, puedes enviar la notificación de forma normal. Laravel detectará la interfaz `ShouldQueue` en la clase y automáticamente pondrá en cola la entrega de la notificación:

    $user->notify(new InvoicePaid($invoice));

Al poner en cola las notificaciones, se creará un trabajo en cola para cada combinación de destinatario y canal. Por ejemplo, seis trabajos serán enviados a la cola si tu notificación tiene tres destinatarios y dos canales.

<a name="delaying-notifications"></a>
#### Retrasar notificaciones

Si desea retrasar la entrega de la notificación, puede encadenar el método de `delay` en su instanciación de notificación:

    $delay = now()->addMinutes(10);

    $user->notify((new InvoicePaid($invoice))->delay($delay));

<a name="delaying-notifications-per-channel"></a>
#### Retrasar notificaciones por canal

Puede pasar un array al método `delay` para especificar cuanto desea retrasar la notificación para un canal específico:

    $user->notify((new InvoicePaid($invoice))->delay([
        'mail' => now()->addMinutes(5),
        'sms' => now()->addMinutes(10),
    ]));

De manera alternativa, puede definir un método `withDelay` en la propia clase de notificación. El método `withDelay` debe devolver un array de nombres de canales y valores de retardo:

    /**
     * Determine the notification's delivery delay.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function withDelay($notifiable)
    {
        return [
            'mail' => now()->addMinutes(5),
            'sms' => now()->addMinutes(10),
        ];
    }

<a name="customizing-the-notification-queue-connection"></a>
#### Personalización de la conexión de la cola de notificaciones

Por defecto, las notificaciones en cola se encolarán utilizando la conexión de cola por defecto de su aplicación. Si desea especificar una conexión diferente para una notificación en particular, puede definir una propiedad `$connection` en la clase de notificación:

    /**
     * The name of the queue connection to use when queueing the notification.
     *
     * @var string
     */
    public $connection = 'redis';

O, si desea especificar una conexión de cola específica que se debe utilizar para cada canal de notificación soportado por la notificación, puede definir un método `viaConnections` en su notificación. Este método debe devolver un array de pares nombre de canal / nombre de conexión de cola:

    /**
     * Determine which connections should be used for each notification channel.
     *
     * @return array
     */
    public function viaConnections()
    {
        return [
            'mail' => 'redis',
            'database' => 'sync',
        ];
    }

<a name="customizing-notification-channel-queues"></a>
#### Personalización de colas de canales de notificación

Si desea especificar una cola específica que debe utilizarse para cada canal de notificación soportado por la notificación, puede definir un método `viaQueues` en su notificación. Este método debe devolver un array de pares nombre de canal / nombre de cola:

    /**
     * Determine which queues should be used for each notification channel.
     *
     * @return array
     */
    public function viaQueues()
    {
        return [
            'mail' => 'mail-queue',
            'slack' => 'slack-queue',
        ];
    }

<a name="queued-notifications-and-database-transactions"></a>
#### Notificaciones en cola y transacciones de base de datos

Cuando las notificaciones en cola se envían dentro de transacciones de base de datos, pueden ser procesadas por la cola antes de que la transacción de base de datos se haya "commiteado". Cuando esto ocurre, cualquier actualización que haya realizado en los modelos o registros de la base de datos durante la transacción de la base de datos puede no reflejarse todavía en la base de datos. Además, es posible que los modelos o registros de base de datos creados durante la transacción no existan en la base de datos. Si su notificación depende de estos modelos, pueden producirse errores inesperados cuando se procese el trabajo que envía la notificación en cola.

Si la opción de configuración `after_commit` de su conexión de cola está establecida en `false`, puede indicar que una notificación en cola concreta debe enviarse después de que todas las transacciones de base de datos abiertas se hayan consignado llamando al método `afterCommit` al enviar la notificación:

    use App\Notifications\InvoicePaid;

    $user->notify((new InvoicePaid($invoice))->afterCommit());

De manera alternativa, puede llamar al método `afterCommit` desde el constructor de su notificación:

    <?php

    namespace App\Notifications;

    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Notifications\Notification;

    class InvoicePaid extends Notification implements ShouldQueue
    {
        use Queueable;

        /**
         * Create a new notification instance.
         *
         * @return void
         */
        public function __construct()
        {
            $this->afterCommit();
        }
    }

> **Nota**  
> Para obtener más información sobre cómo solucionar estos problemas, consulte la documentación relativa a los trabajos en cola [y las transacciones de base de datos](/docs/{{version}}/queues#jobs-and-database-transactions).

<a name="determining-if-the-queued-notification-should-be-sent"></a>
#### Cómo determinar si se debe enviar una notificación en cola

Después de que una notificación en cola haya sido enviada a la cola para su procesamiento en segundo plano, normalmente será aceptada por un trabajador de la cola y enviada a su destinatario.

Sin embargo, si deseas tomar la decisión final sobre si la notificación en cola debe ser enviada después de ser procesada por un trabajador de la cola, puedes definir un método `shouldSend` en la clase de notificación. Si este método devuelve `false`, la notificación no se enviará:

    /**
     * Determine if the notification should be sent.
     *
     * @param  mixed  $notifiable
     * @param  string  $channel
     * @return bool
     */
    public function shouldSend($notifiable, $channel)
    {
        return $this->invoice->isPaid();
    }

<a name="on-demand-notifications"></a>
### Notificaciones bajo demanda

A veces puedes necesitar enviar una notificación a alguien que no está almacenado como "usuario" de tu aplicación. Utilizando el método `route` de la facade `Notification`, puedes especificar información de enrutamiento de notificaciones ad-hoc antes de enviar la notificación:

    use Illuminate\Broadcasting\Channel;

    Notification::route('mail', 'taylor@example.com')
                ->route('vonage', '5555555555')
                ->route('slack', 'https://hooks.slack.com/services/...')
                ->route('broadcast', [new Channel('channel-name')])
                ->notify(new InvoicePaid($invoice));

Si quieres proporcionar el nombre del destinatario al enviar una notificación bajo demanda a la ruta de `mail`, puedes proporcionar un array que contenga la dirección de email como clave y el nombre como valor del primer elemento del array:

    Notification::route('mail', [
        'barrett@example.com' => 'Barrett Blair',
    ])->notify(new InvoicePaid($invoice));

<a name="mail-notifications"></a>
## Notificaciones por correo

<a name="formatting-mail-messages"></a>
### Formateo de Mensajes de Correo

Si una notificación admite ser enviada como un email, debe definir un método `toMail` en la clase de notificación. Este método recibirá una entidad `$notifiable` y devolverá una instancia `Illuminate\Notifications\Messages\MailMessage`.

La clase `MailMessage` contiene algunos métodos sencillos para ayudarle a construir mensajes de email transaccionales. Los mensajes de correo pueden contener líneas de texto, así como una "llamada a la acción". Veamos un ejemplo del método `toMail`:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        $url = url('/invoice/'.$this->invoice->id);

        return (new MailMessage)
                    ->greeting('Hello!')
                    ->line('One of your invoices has been paid!')
                    ->lineIf($this->amount > 0, "Amount paid: {$this->amount}")
                    ->action('View Invoice', $url)
                    ->line('Thank you for using our application!');
    }

> **Nota**  
> Nota estamos usando `$this->invoice->id` en nuestro método `toMail`. Puedes pasar cualquier dato que tu notificación necesite para generar su mensaje en el constructor de la notificación.

En este ejemplo, registramos un saludo, una línea de texto, una llamada a la acción, y luego otra línea de texto. Estos métodos proporcionados por el objeto `MailMessage` hacen que sea sencillo y rápido dar formato a pequeños correos electrónicos transaccionales. A continuación, el canal de correo traducirá los componentes del mensaje en una bonita plantilla de email HTML con una contrapartida de texto sin formato. A continuación se muestra un ejemplo de un email generado por el canal de `mail`:

<img src="https://documentacionlaravel.com/img/docs/notification-example-2.png">

> **Nota**  
> Cuando envíe notificaciones por correo, asegúrese de establecer la opción de configuración `name` en su archivo de configuración `config/app.php`. Este valor se utilizará en la cabecera y el pie de página de sus mensajes de notificación por correo.

<a name="error-messages"></a>
#### Mensajes de error

Algunas notificaciones informan a los usuarios de errores, como el pago fallido de una factura. Puede indicar que un mensaje de correo se refiere a un error llamando al método `error` cuando construya su mensaje. Cuando utilice el método de `error` en un mensaje de correo, el botón de llamada a la acción será rojo en lugar de negro:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->error()
                    ->subject('Invoice Payment Failed')
                    ->line('...');
    }

<a name="other-mail-notification-formatting-options"></a>
#### Otras opciones de formato de las notificaciones de correo

En lugar de definir las "líneas" de texto en la clase de notificación, puede utilizar el método `view` para especificar una plantilla personalizada que debe utilizarse para renderizar el email de notificación:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)->view(
            'emails.name', ['invoice' => $this->invoice]
        );
    }

Puede especificar una vista de texto plano para el mensaje de correo pasando el nombre de la vista como segundo elemento de una array que se proporciona al método `view`:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)->view(
            ['emails.name.html', 'emails.name.plain'],
            ['invoice' => $this->invoice]
        );
    }

<a name="customizing-the-sender"></a>
### Personalización del remitente

Por defecto, la dirección del remitente del email se define en el archivo de configuración `config/mail.php`. Sin embargo, puede especificar la dirección del remitente para una notificación específica utilizando el método `from`:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->from('barrett@example.com', 'Barrett Blair')
                    ->line('...');
    }

<a name="customizing-the-recipient"></a>
### Personalización del destinatario

Al enviar notificaciones a través del canal de `mail`, el sistema de notificación buscará automáticamente una propiedad de `email` electrónico en su entidad notificable. Puede personalizar qué  email se utiliza para enviar la notificación definiendo un método `routeNotificationForMail` en la entidad notificable:

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * Route notifications for the mail channel.
         *
         * @param  \Illuminate\Notifications\Notification  $notification
         * @return array|string
         */
        public function routeNotificationForMail($notification)
        {
            // Return email address only...
            return $this->email_address;

            // Return email address and name...
            return [$this->email_address => $this->name];
        }
    }

<a name="customizing-the-subject"></a>
### Personalización del asunto

Por defecto, el asunto del email es el nombre de la clase de notificación formateado a "Title Case". Así, si su clase de notificación se llama `InvoicePaid`, el asunto del email será `Invoice Paid`. Si desea especificar un asunto diferente para el mensaje, puede llamar al método `subject` cuando construya su mensaje:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->subject('Notification Subject')
                    ->line('...');
    }

<a name="customizing-the-mailer"></a>
### Personalización del remitente

Por defecto, la notificación por email se enviará utilizando el mailer por defecto definido en el archivo de configuración `config/mail.php`. Sin embargo, puede especificar un mailer diferente en tiempo de ejecución llamando al método `mailer` cuando construya su mensaje:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->mailer('postmark')
                    ->line('...');
    }

<a name="customizing-the-templates"></a>s
### Personalización de las plantillas

Puede modificar la plantilla HTML y el texto plano utilizado por las notificaciones de correo publicando los recursos del paquete de notificaciones. Tras ejecutar este comando, las plantillas de notificaciones por correo se ubicarán en el directorio `resources/views/vendor/notifications`:

```shell
php artisan vendor:publish --tag=laravel-notifications
```

<a name="mail-attachments"></a>
### Adjuntos

Para añadir archivos adjuntos a una notificación por email, utilice el método `attach` al crear el mensaje. El método `attach` acepta la ruta absoluta al archivo como primer argumento:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->greeting('Hello!')
                    ->attach('/path/to/file');
    }

> **Nota**  
> El método `attach` que ofrecen los mensajes de correo de notificación también acepta objetos [adjuntables](/docs/{{version}}/mail#attachable-objects). Para más información, consulta la completa [documentación](/docs/{{version}}/mail#attachable-objects) sobre objetos adjuntables.

Al adjuntar archivos a un mensaje, también puede especificar el nombre para mostrar y/o el tipo MIME pasando una `array` como segundo argumento al método `attach`:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->greeting('Hello!')
                    ->attach('/path/to/file', [
                        'as' => 'name.pdf',
                        'mime' => 'application/pdf',
                    ]);
    }

A diferencia de lo que ocurre al adjuntar archivos en objetos enviables por correo, no puedes adjuntar un archivo directamente desde un disco de almacenamiento utilizando `attachFromStorage`. Debe utilizar el método `attach` con una ruta absoluta al archivo en el disco de almacenamiento. De manera alternativa, puedes devolver un [mailable](/docs/{{version}}/mail#generating-mailables) desde el método `toMail`:

    use App\Mail\InvoicePaid as InvoicePaidMailable;

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return Mailable
     */
    public function toMail($notifiable)
    {
        return (new InvoicePaidMailable($this->invoice))
                    ->to($notifiable->email)
                    ->attachFromStorage('/path/to/file');
    }

Cuando sea necesario, se pueden adjuntar varios archivos a un mensaje utilizando el método `attachMany`:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->greeting('Hello!')
                    ->attachMany([
                        '/path/to/forge.svg',
                        '/path/to/vapor.svg' => [
                            'as' => 'Logo.svg',
                            'mime' => 'image/svg+xml',
                        ],
                    ]);
    }

<a name="raw-data-attachments"></a>
#### Archivos adjuntos de datos sin procesar

El método `attachData` puede utilizarse para adjuntar una cadena de bytes sin procesar. Cuando se llama al método `attachData`, se debe proporcionar el nombre de archivo que se debe asignar al adjunto:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->greeting('Hello!')
                    ->attachData($this->pdf, 'name.pdf', [
                        'mime' => 'application/pdf',
                    ]);
    }

<a name="adding-tags-metadata"></a>
### Añadir etiquetas y metadatos

Algunos proveedores de correo de terceros como Mailgun y Postmark soportan "etiquetas" y "metadatos" de mensajes, que pueden ser utilizados para agrupar y rastrear los correos electrónicos enviados por su aplicación. Puede añadir etiquetas y metadatos a un mensaje de email mediante los métodos `tag` y `metadata`:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->greeting('Comment Upvoted!')
                    ->tag('upvote')
                    ->metadata('comment_id', $this->comment->id);
    }

Si su aplicación utiliza el controlador Mailgun, puede consultar la documentación de Mailgun para obtener más información sobre [etiquetas](https://documentation.mailgun.com/en/latest/user_manual.html#tagging-1) y [metadatos](https://documentation.mailgun.com/en/latest/user_manual.html#attaching-data-to-messages). Del mismo modo, también puede consultar la documentación de Postmark para obtener más información sobre su compatibilidad con [etiquetas](https://postmarkapp.com/blog/tags-support-for-smtp) y [metadatos](https://postmarkapp.com/support/article/1125-custom-metadata-faq).

Si su aplicación utiliza Amazon SES para enviar correos electrónicos, debe utilizar el método de `metadata` para adjuntar ["etiquetas" SES](https://docs.aws.amazon.com/ses/latest/APIReference/API_MessageTag.html) al mensaje.

<a name="customizing-the-symfony-message"></a>
### Personalización del mensaje Symfony

El método `withSymfonyMessage` de la clase `MailMessage` permite registrar un closure que se invocará con la instancia de Symfony Message antes de enviar el mensaje. Esto te da la oportunidad de personalizar profundamente el mensaje antes de que se entregue:

    use Symfony\Component\Mime\Email;

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->withSymfonyMessage(function (Email $message) {
                        $message->getHeaders()->addTextHeader(
                            'Custom-Header', 'Header Value'
                        );
                    });
    }

<a name="using-mailables"></a>
### Uso de Mailables

Si es necesario, puede devolver un [objeto mailable](/docs/{{version}}/mail) completo desde el método `toMail` de su notificación. Si devuelve un `Mailable` en lugar de un `MailMessage`, deberá especificar el destinatario del mensaje mediante el método `to` del objeto mailable:

    use App\Mail\InvoicePaid as InvoicePaidMailable;

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return Mailable
     */
    public function toMail($notifiable)
    {
        return (new InvoicePaidMailable($this->invoice))
                    ->to($notifiable->email);
    }

<a name="mailables-and-on-demand-notifications"></a>
#### Mailables y notificaciones bajo demanda

Si está enviando una [notificación bajo demanda](#on-demand-notifications), la instancia `$notifiable` dada al método `toMail` será una instancia de `Illuminate\Notifications\AnonymousNotifiable`, que ofrece un método `routeNotificationFor` que puede utilizarse para recuperar la dirección de email a la que debe enviarse la notificación bajo demanda:

    use App\Mail\InvoicePaid as InvoicePaidMailable;
    use Illuminate\Notifications\AnonymousNotifiable;

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return Mailable
     */
    public function toMail($notifiable)
    {
        $address = $notifiable instanceof AnonymousNotifiable
                ? $notifiable->routeNotificationFor('mail')
                : $notifiable->email;

        return (new InvoicePaidMailable($this->invoice))
                    ->to($address);
    }

<a name="previewing-mail-notifications"></a>
### Vista previa de las notificaciones por correo

Al diseñar una plantilla de notificación de correo, es conveniente previsualizar rápidamente el mensaje de correo renderizado en el navegador como una plantilla típica de Blade. Por esta razón, Laravel permite devolver cualquier mensaje de correo generado por una notificación de correo directamente desde un closure ruta o controlador. Cuando un `MailMessage` es devuelto, será renderizado y mostrado en el navegador, permitiéndote previsualizar rápidamente su diseño sin necesidad de enviarlo a una dirección de correo real:

    use App\Models\Invoice;
    use App\Notifications\InvoicePaid;

    Route::get('/notification', function () {
        $invoice = Invoice::find(1);

        return (new InvoicePaid($invoice))
                    ->toMail($invoice->user);
    });

<a name="markdown-mail-notifications"></a>
## Notificaciones de correo Markdown

Las notificaciones de correo Markdown le permiten aprovechar las plantillas preconstruidas de las notificaciones de correo, a la vez que le dan más libertad para escribir mensajes más largos y personalizados. Dado que los mensajes están escritos en Markdown, Laravel es capaz de renderizar plantillas HTML hermosas y responsivas para los mensajes, al mismo tiempo que genera automáticamente una contraparte en texto plano.

<a name="generating-the-message"></a>
### Generación del mensaje

Para generar una notificación con su correspondiente plantilla Markdown, puedes utilizar la opción `--markdown` del comando `make:notification` Artisan:

```shell
php artisan make:notification InvoicePaid --markdown=mail.invoice.paid
```

Al igual que el resto de notificaciones de correo, las notificaciones que utilizan plantillas Markdown deben definir un método `toMail` en su clase de notificación. Sin embargo, en lugar de utilizar los métodos `line` y `action` para construir la notificación, utilice el método `markdown` para especificar el nombre de la plantilla Markdown que debe utilizarse. Como segundo argumento del método puede pasarse un array de datos que desee poner a disposición de la plantilla:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        $url = url('/invoice/'.$this->invoice->id);

        return (new MailMessage)
                    ->subject('Invoice Paid')
                    ->markdown('mail.invoice.paid', ['url' => $url]);
    }

<a name="writing-the-message"></a>
### Redacción del mensaje

Las notificaciones de correo Markdown utilizan una combinación de componentes Blade y sintaxis Markdown que le permiten construir fácilmente notificaciones mientras aprovecha los componentes de notificación preelaborados de Laravel:

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
#### Componente de botón

El componente de botón muestra un enlace de botón centrado. El componente acepta dos argumentos, una `url` y un `color` opcional. Los colores soportados son `primary`, `green`, y `red`. Puede añadir tantos componentes de botón a una notificación como desee:

```blade
<x-mail::button :url="$url" color="green">
View Invoice
</x-mail::button>
```

<a name="panel-component"></a>
#### Componente de panel

El componente panel muestra el bloque de texto en un panel con un color de fondo ligeramente distinto al del resto de la notificación. Esto le permite llamar la atención sobre un bloque de texto determinado:

```blade
<x-mail::panel>
This is the panel content.
</x-mail::panel>
```

<a name="table-component"></a>
#### Componente de tabla

El componente tabla permite transformar una tabla Markdown en una tabla HTML. El componente acepta la tabla Markdown como contenido. La alineación de las columnas de la tabla se realiza utilizando la sintaxis predeterminada de alineación de tablas de Markdown:

```blade
<x-mail::table>
| Laravel       | Table         | Example  |
| ------------- |:-------------:| --------:|
| Col 2 is      | Centered      | $10      |
| Col 3 is      | Right-Aligned | $20      |
</x-mail::table>
```

<a name="customizing-the-components"></a>
### Personalización de los componentes

Puede exportar todos los componentes de notificación Markdown a su propia aplicación para personalizarlos. Para exportar los componentes, utilice el comando `vendor:publish` Artisan para publicar la etiqueta asset `laravel-mail`:

```shell
php artisan vendor:publish --tag=laravel-mail
```

Este comando publicará los componentes de correo Markdown en el directorio `resources/views/vendor/mail`. El directorio `mail` contendrá un directorio `html` y un directorio `text`, cada uno con sus respectivas representaciones de cada componente disponible. Puede personalizar estos componentes como desee.

<a name="customizing-the-css"></a>
#### Personalizar el CSS

Después de exportar los componentes, el directorio `resources/views/vendor/mail/html/themes` contendrá un archivo `default.css`. Puede personalizar el CSS de este archivo y sus estilos se incluirán automáticamente en las representaciones HTML de sus notificaciones Markdown.

Si deseas construir un tema completamente nuevo para los componentes Markdown de Laravel, puedes colocar un archivo CSS dentro del directorio `html/themes`. Después de nombrar y guardar su archivo CSS, actualice la opción de `theme` del archivo de configuración de `mail` para que coincida con el nombre de su nuevo tema.

Para personalizar el tema de una notificación individual, puede llamar al método del `theme` mientras crea el mensaje de correo de la notificación. El método de `theme` acepta el nombre del tema que debe utilizarse al enviar la notificación:

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
                    ->theme('invoice')
                    ->subject('Invoice Paid')
                    ->markdown('mail.invoice.paid', ['url' => $url]);
    }

<a name="database-notifications"></a>
## Notificaciones de base de datos

<a name="database-prerequisites"></a>
### Requisitos previos

El canal de notificación de `database` almacena la información de la notificación en una tabla de base de datos. Esta tabla contendrá información como el tipo de notificación, así como una estructura de datos JSON que describe la notificación.

Puede consultar la tabla para mostrar las notificaciones en la interfaz de usuario de su aplicación. Pero, antes de que pueda hacer eso, necesitará crear una tabla de base de datos para contener sus notificaciones. Puede utilizar el comando `notifications:table` para generar una [migración](/docs/{{version}}/migrations) con el esquema de tabla adecuado:

```shell
php artisan notifications:table

php artisan migrate
```

<a name="formatting-database-notifications"></a>
### Formateo de las Notificaciones de la Base de Datos

Si una notificación soporta ser almacenada en una tabla de base de datos, debes definir un método `toDatabase` o `toArray` en la clase de notificación. Este método recibirá una entidad `$notifiable` y devolverá un array PHP plano. El array devuelto será codificado como JSON y almacenado en la columna de `data` de tu tabla de `notifications`. Veamos un ejemplo del método `toArray`:

    /**
     * Get the array representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function toArray($notifiable)
    {
        return [
            'invoice_id' => $this->invoice->id,
            'amount' => $this->invoice->amount,
        ];
    }

<a name="todatabase-vs-toarray"></a>
#### `toDatabase` Vs. `toArray`

El método `toArray` también es utilizado por el canal de `broadcast` para determinar qué datos difundir a su frontend con JavaScript. Si desea tener dos representaciones de array diferentes para los canales `database` y `broadcast`, debe definir un método `toDatabase` en lugar de un método `toArray`.

<a name="accessing-the-notifications"></a>
### Acceso a las notificaciones

Una vez almacenadas las notificaciones en la base de datos, necesitará una forma cómoda de acceder a ellas desde sus entidades notificables. El trait `Illuminate\Notifications\Notifiable`, que se incluye en el modelo `App\Models\User` por defecto de Laravel, incluye una [relación Eloquent](/docs/{{version}}/eloquent-relationships) llamada `notifications` que devuelve las notificaciones de la entidad. Para obtener notificaciones, puedes acceder a este método como a cualquier otra relación Eloquent. Por defecto, las notificaciones se ordenarán por la fecha de `creación (created_at)` con las notificaciones más recientes al principio de la colección:

    $user = App\Models\User::find(1);

    foreach ($user->notifications as $notification) {
        echo $notification->type;
    }

Si desea recuperar sólo las notificaciones "no leídas", puede utilizar la relación `unreadNotifications`. De nuevo, estas notificaciones se ordenarán por la columna `created_at`, con las notificaciones más recientes al principio de la colección:

    $user = App\Models\User::find(1);

    foreach ($user->unreadNotifications as $notification) {
        echo $notification->type;
    }

> **Nota**  
> Para acceder a tus notificaciones desde tu cliente JavaScript, debes definir un controlador de notificaciones para tu aplicación que devuelva las notificaciones para una entidad notificable, como el usuario actual. A continuación, puede realizar una solicitud HTTP a la URL de ese controlador desde su cliente JavaScript.

<a name="marking-notifications-as-read"></a>
### Marcar Notificaciones como Leídas

Normalmente, querrá marcar una notificación como "leída" cuando un usuario la vea. El trait `Illuminate\Notifications\Notifiable` proporciona un método `markAsRead`, que actualiza la columna `read_at` en el registro de base de datos de la notificación:

    $user = App\Models\User::find(1);

    foreach ($user->unreadNotifications as $notification) {
        $notification->markAsRead();
    }

Sin embargo, en lugar de recorrer cada notificación, puede utilizar el método `markAsRead` directamente en una colección de notificaciones:

    $user->unreadNotifications->markAsRead();

También puede utilizar una consulta de actualización masiva para marcar todas las notificaciones como leídas sin recuperarlas de la base de datos:

    $user = App\Models\User::find(1);

    $user->unreadNotifications()->update(['read_at' => now()]);

Puede borrar las notificaciones para eliminarlas completamente de la tabla usando el método `delete`:

    $user->notifications()->delete();

<a name="broadcast-notifications"></a>
## Notificaciones  Broadcast

<a name="broadcast-prerequisites"></a>
### Requisitos previos

Antes de difundir las notificaciones, debe configurar y estar familiarizado con los servicios de [difusión de eventos (event broadcasting)](/docs/{{version}}/broadcasting) de Laravel. La difusión de eventos proporciona una manera de reaccionar a los eventos de Laravel del lado del servidor desde su frontend con JavaScript.

<a name="formatting-broadcast-notifications"></a>
### Formato de notificaciones  Broadcast

El canal de `broadcast` difunde notificaciones utilizando los servicios de [event broadcasting](/docs/{{version}}/broadcasting) de Laravel, lo que permite a tu frontend con JavaScript recibir notificaciones en tiempo real. Si una notificación soporta broadcasting, puedes definir un método `toBroadcast` en la clase de notificación. Este método recibirá una entidad `$notifiable` y devolverá una instancia de `BroadcastMessage`. Si el método `toBroadcast` no existe, se utilizará el método `toArray` para recoger los datos que deben ser difundidos. Los datos devueltos se codificarán como JSON y se transmitirán a su frontend con JavaScript. Veamos un ejemplo del método `toBroadcast`:

    use Illuminate\Notifications\Messages\BroadcastMessage;

    /**
     * Get the broadcastable representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return BroadcastMessage
     */
    public function toBroadcast($notifiable)
    {
        return new BroadcastMessage([
            'invoice_id' => $this->invoice->id,
            'amount' => $this->invoice->amount,
        ]);
    }

<a name="broadcast-queue-configuration"></a>
#### Configuración de la cola de Broadcast

Todas las notificaciones broadcast se ponen en cola para su difusión. Si desea configurar la conexión de la cola o el nombre de la cola que se utilizará, puede utilizar los métodos `onConnection` y `onQueue` de `BroadcastMessage`:

    return (new BroadcastMessage($data))
                    ->onConnection('sqs')
                    ->onQueue('broadcasts');

<a name="customizing-the-notification-type"></a>
#### Personalización del tipo de notificación

Además de los datos que especifique, todas las notificaciones broadcast también tienen un campo de `type` que contiene el nombre completo de la clase de la notificación. Si desea personalizar el tipo de notificación, puede definir un método `broadcastType` en la clase de notificación:

    use Illuminate\Notifications\Messages\BroadcastMessage;

    /**
     * Get the type of the notification being broadcast.
     *
     * @return string
     */
    public function broadcastType()
    {
        return 'broadcast.message';
    }

<a name="listening-for-notifications"></a>
### Escucha de notificaciones

Las notificaciones se emitirán en un canal privado formateado utilizando la convención `{notifiable}.{id}`. Por lo tanto, si está enviando una notificación a una instancia de `App.Models.User` con un ID de `1`, la notificación se emitirá en el canal privado `App.Models.User.1`. Cuando se utiliza [Laravel Echo](/docs/{{version}}/broadcasting#client-side-installation), puede escuchar fácilmente las notificaciones en un canal utilizando el método de `notification`:

    Echo.private('App.Models.User.' + userId)
        .notification((notification) => {
            console.log(notification.type);
        });

<a name="customizing-the-notification-channel"></a>
#### Personalización del canal de notificación

Si desea personalizar el canal por el que se emiten las notificaciones de una entidad, puede definir un método `receivesBroadcastNotificationsOn` en la entidad notificable:

    <?php

    namespace App\Models;

    use Illuminate\Broadcasting\PrivateChannel;
    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * The channels the user receives notification broadcasts on.
         *
         * @return string
         */
        public function receivesBroadcastNotificationsOn()
        {
            return 'users.'.$this->id;
        }
    }

<a name="sms-notifications"></a>
## Notificaciones SMS

<a name="sms-prerequisites"></a>
### Requisitos previos

El envío de notificaciones SMS en Laravel es impulsado por [Vonage](https://www.vonage.com/) (anteriormente conocido como Nexmo). Antes de poder enviar notificaciones a través de Vonage, necesitas instalar los paquetes `laravel/vonage-notification-channel` y `guzzlehttp/guzzle`:

    composer require laravel/vonage-notification-channel guzzlehttp/guzzle

El paquete incluye un [archivo de configuración](https://github.com/laravel/vonage-notification-channel/blob/3.x/config/vonage.php). Sin embargo, no es necesario que exportes este archivo de configuración a tu propia aplicación. Puedes simplemente utilizar las variables de entorno `VONAGE_KEY` y `VONAGE_SECRET` para definir tus claves públicas y secretas de Vonage.

Después de definir sus claves, puede establecer una variable de entorno `VONAGE_SMS_FROM` que defina el número de teléfono desde el que se enviarán sus mensajes SMS por defecto. Puedes generar este número de teléfono dentro del panel de control de Vonage:

    VONAGE_SMS_FROM=15556666666

<a name="formatting-sms-notifications"></a>
### Formateo de notificaciones SMS

Si una notificación admite el envío como SMS, debes definir un método `toVonage` en la clase de notificación. Este método recibirá una entidad `$notifiable` y devolverá una instancia `Illuminate\Notifications\Messages\VonageMessage`:

    /**
     * Get the Vonage / SMS representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\VonageMessage
     */
    public function toVonage($notifiable)
    {
        return (new VonageMessage)
                    ->content('Your SMS message content');
    }

<a name="unicode-content"></a>
#### Contenido Unicode

Si tu mensaje SMS contiene caracteres unicode, deberás llamar al método `unicode` cuando construyas la instancia de `VonageMessage`:

    /**
     * Get the Vonage / SMS representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\VonageMessage
     */
    public function toVonage($notifiable)
    {
        return (new VonageMessage)
                    ->content('Your unicode message')
                    ->unicode();
    }

<a name="customizing-the-from-number"></a>
### Personalización del número "Desde"

Si deseas enviar algunas notificaciones desde un número de teléfono que es diferente del número de teléfono especificado por tu variable de entorno `VONAGE_SMS_FROM`, puedes llamar al método `from` en una instancia de `VonageMessage`:

    /**
     * Get the Vonage / SMS representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\VonageMessage
     */
    public function toVonage($notifiable)
    {
        return (new VonageMessage)
                    ->content('Your SMS message content')
                    ->from('15554443333');
    }

<a name="adding-a-client-reference"></a>
### Cómo agregar una referencia de cliente

Si deseas realizar un seguimiento de los costos por usuario, equipo o cliente, puedes agregar una "referencia de cliente" a la notificación. Vonage te permitirá generar informes usando esta referencia de cliente para que puedas comprender mejor el uso de SMS de un cliente en particular. La referencia del cliente puede ser cualquier cadena de hasta 40 caracteres:

    /**
     * Get the Vonage / SMS representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\VonageMessage
     */
    public function toVonage($notifiable)
    {
        return (new VonageMessage)
                    ->clientReference((string) $notifiable->id)
                    ->content('Your SMS message content');
    }

<a name="routing-sms-notifications"></a>
### Enrutamiento de notificaciones SMS

Para dirigir las notificaciones de Vonage al número de teléfono correcto, define un método `routeNotificationForVonage` en tu entidad notificable:

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * Route notifications for the Vonage channel.
         *
         * @param  \Illuminate\Notifications\Notification  $notification
         * @return string
         */
        public function routeNotificationForVonage($notification)
        {
            return $this->phone_number;
        }
    }

<a name="slack-notifications"></a>
## Notificaciones Slack

<a name="slack-prerequisites"></a>
### Requisitos previos

Antes de poder enviar notificaciones a través de Slack, debes instalar el canal de notificaciones de Slack a través de Composer:

```shell
composer require laravel/slack-notification-channel
```

También deberás crear una [aplicación Slack](https://api.slack.com/apps?new_app=1) para tu equipo. Después de crear la aplicación, debes configurar un "Incoming Webhook" para el área de trabajo. Slack le proporcionará una URL de webhook que podrá utilizar [para enviar las notificaciones de Slack](#routing-slack-notifications).

<a name="formatting-slack-notifications"></a>
### Formateo de notificaciones Slack

Si una notificación admite ser enviada como un mensaje de Slack, debe definir un método `toSlack` en la clase de notificación. Este método recibirá una entidad `$notifiable` y devolverá una instancia `Illuminate\Notifications\Messages\SlackMessage`. Los mensajes de Slack pueden contener contenido de texto, así como un "adjunto" que formatea texto adicional o una array de campos. Veamos un ejemplo básico de `toSlack`:

    /**
     * Get the Slack representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\SlackMessage
     */
    public function toSlack($notifiable)
    {
        return (new SlackMessage)
                    ->content('One of your invoices has been paid!');
    }

<a name="slack-attachments"></a>
### Adjuntos de Slack

También puede añadir "archivos adjuntos" a los mensajes de Slack. Los archivos adjuntos proporcionan opciones de formato más ricas que los simples mensajes de texto. En este ejemplo, enviaremos una notificación de error sobre una excepción que se ha producido en una aplicación, incluyendo un enlace para ver más detalles sobre la excepción:

    /**
     * Get the Slack representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\SlackMessage
     */
    public function toSlack($notifiable)
    {
        $url = url('/exceptions/'.$this->exception->id);

        return (new SlackMessage)
                    ->error()
                    ->content('Whoops! Something went wrong.')
                    ->attachment(function ($attachment) use ($url) {
                        $attachment->title('Exception: File Not Found', $url)
                                   ->content('File [background.jpg] was not found.');
                    });
    }

Los archivos adjuntos también permiten especificar una array de datos que deben presentarse al usuario. Los datos proporcionados se presentarán en un formato tipo tabla para facilitar su lectura:

    /**
     * Get the Slack representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return SlackMessage
     */
    public function toSlack($notifiable)
    {
        $url = url('/invoices/'.$this->invoice->id);

        return (new SlackMessage)
                    ->success()
                    ->content('One of your invoices has been paid!')
                    ->attachment(function ($attachment) use ($url) {
                        $attachment->title('Invoice 1322', $url)
                                   ->fields([
                                        'Title' => 'Server Expenses',
                                        'Amount' => '$1,234',
                                        'Via' => 'American Express',
                                        'Was Overdue' => ':-1:',
                                    ]);
                    });
    }

<a name="markdown-attachment-content"></a>
#### Markdown Attachment Content

Si algunos de sus campos adjuntos contienen Markdown, puede utilizar el método `markdown` para indicar a Slack que analice y muestre los campos adjuntos dados como texto con formato Markdown. Los valores aceptados por este método son: `pretext`, `text`, y/o `fields`. Para más información sobre el formato de los adjuntos de Slack, consulte la [documentación de la API de Slack](https://api.slack.com/docs/message-formatting#message_formatting):

    /**
     * Get the Slack representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return SlackMessage
     */
    public function toSlack($notifiable)
    {
        $url = url('/exceptions/'.$this->exception->id);

        return (new SlackMessage)
                    ->error()
                    ->content('Whoops! Something went wrong.')
                    ->attachment(function ($attachment) use ($url) {
                        $attachment->title('Exception: File Not Found', $url)
                                   ->content('File [background.jpg] was *not found*.')
                                   ->markdown(['text']);
                    });
    }

<a name="routing-slack-notifications"></a>
### Enrutamiento de notificaciones de Slack

Para dirigir las notificaciones de Slack al equipo y canal de Slack adecuados, defina un método `routeNotificationForSlack` en su entidad notificable. Esto debería devolver la URL webhook a la que la notificación debe ser entregada. Las URL de webhook pueden generarse añadiendo un servicio "Incoming Webhook" a su equipo de Slack:

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * Route notifications for the Slack channel.
         *
         * @param  \Illuminate\Notifications\Notification  $notification
         * @return string
         */
        public function routeNotificationForSlack($notification)
        {
            return 'https://hooks.slack.com/services/...';
        }
    }

<a name="localizing-notifications"></a>
## Localización de notificaciones

Laravel permite enviar notificaciones en una configuración regional distinta de la configuración regional actual de la petición HTTP, e incluso recordará esta configuración regional si la notificación se pone en cola.

Para ello, la clase `Illuminate\Notifications\Notification` ofrece un método `locale` para establecer el idioma deseado. La aplicación cambiará a esta configuración regional cuando se esté evaluando la notificación y luego volverá a la configuración regional anterior cuando finalice la evaluación:

    $user->notify((new InvoicePaid($invoice))->locale('es'));

La localización de múltiples entradas notificables también puede lograrse a través de la facade `Notification`:

    Notification::locale('es')->send(
        $users, new InvoicePaid($invoice)
    );

<a name="user-preferred-locales"></a>
### Idiomas preferidos por el usuario

A veces, las aplicaciones almacenan la configuración regional preferida de cada usuario. Implementando el contrato `HasLocalePreference` en tu modelo de notificación, puedes indicar a Laravel que utilice esta configuración regional almacenada cuando envíe una notificación:

    use Illuminate\Contracts\Translation\HasLocalePreference;

    class User extends Model implements HasLocalePreference
    {
        /**
         * Get the user's preferred locale.
         *
         * @return string
         */
        public function preferredLocale()
        {
            return $this->locale;
        }
    }

Una vez implementada la interfaz, Laravel utilizará automáticamente la configuración regional preferida al enviar notificaciones y mailables al modelo. Por lo tanto, no hay necesidad de llamar al método `locale` cuando se utiliza esta interfaz:

    $user->notify(new InvoicePaid($invoice));

<a name="notification-events"></a>
## Eventos de Notificación

<a name="notification-sending-event"></a>
#### Evento de envío de notificaciones

Cuando se envía una notificación, el sistema de notificación envía el [evento](/docs/{{version}}/events) `Illuminate\Notifications\Events\NotificationSending` que contiene la entidad "notificable" y la propia instancia de notificación. Puede registrar escuchas para este evento en el `EventServiceProvider` de su aplicación:

    use App\Listeners\CheckNotificationStatus;
    use Illuminate\Notifications\Events\NotificationSending;

    /**
     * The event listener mappings for the application.
     *
     * @var array
     */
    protected $listen = [
        NotificationSending::class => [
            CheckNotificationStatus::class,
        ],
    ];

La notificación no se enviará si un listener de eventos para el evento `NotificationSending` devuelve `false` desde su método `handle`:

    use Illuminate\Notifications\Events\NotificationSending;

    /**
     * Handle the event.
     *
     * @param  \Illuminate\Notifications\Events\NotificationSending  $event
     * @return void
     */
    public function handle(NotificationSending $event)
    {
        return false;
    }

Dentro de un receptor de eventos, puedes acceder a las propiedades `notifiable`, `notification` y `channel` del evento para saber más sobre el destinatario de la notificación o sobre la propia notificación:

    /**
     * Handle the event.
     *
     * @param  \Illuminate\Notifications\Events\NotificationSending  $event
     * @return void
     */
    public function handle(NotificationSending $event)
    {
        // $event->channel
        // $event->notifiable
        // $event->notification
    }

<a name="notification-sent-event"></a>
#### Evento Notificación Enviada

Cuando se envía una notificación, el sistema de notificación envía el [evento](/docs/{{version}}/events) `Illuminate\Notifications\Events\NotificationSent`que contiene la entidad "notificable" y la propia instancia de notificación. Puede registrar oyentes para este evento en su `EventServiceProvider`:

    use App\Listeners\LogNotification;
    use Illuminate\Notifications\Events\NotificationSent;

    /**
     * The event listener mappings for the application.
     *
     * @var array
     */
    protected $listen = [
        NotificationSent::class => [
            LogNotification::class,
        ],
    ];

> **Nota**  
> Después de registrar escuchadores en tu `EventServiceProvider`, utiliza el comando `event:generate` Artisan para generar rápidamente clases de escuchadores.

Dentro de un escuchador de eventos, puedes acceder a las propiedades `notifiable`, `notification`, `channel` y `response` del evento para saber más sobre el destinatario de la notificación o la notificación en sí:

    /**
     * Handle the event.
     *
     * @param  \Illuminate\Notifications\Events\NotificationSent  $event
     * @return void
     */
    public function handle(NotificationSent $event)
    {
        // $event->channel
        // $event->notifiable
        // $event->notification
        // $event->response
    }

<a name="custom-channels"></a>
## Canales Personalizados

Laravel viene con un puñado de canales de notificación, pero es posible que desee escribir sus propios controladores para entregar notificaciones a través de otros canales. Laravel lo hace simple. Para empezar, define una clase que contenga un método de `send`. El método debe recibir dos argumentos: un `$notifiable` y un `$notification`.

Dentro del método `send`, puedes llamar a métodos de la notificación para recuperar un objeto mensaje entendido por tu canal y luego enviar la notificación a la instancia `$notifiable` como desees:

    <?php

    namespace App\Notifications;

    use Illuminate\Notifications\Notification;

    class VoiceChannel
    {
        /**
         * Send the given notification.
         *
         * @param  mixed  $notifiable
         * @param  \Illuminate\Notifications\Notification  $notification
         * @return void
         */
        public function send($notifiable, Notification $notification)
        {
            $message = $notification->toVoice($notifiable);

            // Send notification to the $notifiable instance...
        }
    }

Una vez definida tu clase de canal de notificación, puedes devolver el nombre de la clase desde el método `via` de cualquiera de tus notificaciones. En este ejemplo, el método `toVoice` de tu notificación puede devolver cualquier objeto que elijas para representar mensajes de voz. Por ejemplo, podrías definir tu propia clase `VoiceMessage` para representar estos mensajes:

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
         * Get the notification channels.
         *
         * @param  mixed  $notifiable
         * @return array|string
         */
        public function via($notifiable)
        {
            return [VoiceChannel::class];
        }

        /**
         * Get the voice representation of the notification.
         *
         * @param  mixed  $notifiable
         * @return VoiceMessage
         */
        public function toVoice($notifiable)
        {
            // ...
        }
    }
