# Notificaciones

- [Introducción](#introduction)
- [Generando Notificaciones](#generating-notifications)
- [Enviando Notificaciones](#sending-notifications)
  - [Usando el Trait Notifiable](#using-the-notifiable-trait)
  - [Usando la Facade de Notificación](#using-the-notification-facade)
  - [Especificando Canales de Entrega](#specifying-delivery-channels)
  - [Encolando Notificaciones](#queueing-notifications)
  - [Notificaciones a Pedido](#on-demand-notifications)
- [Notificaciones por Mail](#mail-notifications)
  - [Formateando Mensajes de Mail](#formatting-mail-messages)
  - [Personalizando el Remitente](#customizing-the-sender)
  - [Personalizando el Destinatario](#customizing-the-recipient)
  - [Personalizando el Asunto](#customizing-the-subject)
  - [Personalizando el Mailer](#customizing-the-mailer)
  - [Personalizando las Plantillas](#customizing-the-templates)
  - [Adjuntos](#mail-attachments)
  - [Añadiendo Etiquetas y Metadatos](#adding-tags-metadata)
  - [Personalizando el Mensaje de Symfony](#customizing-the-symfony-message)
  - [Usando Mailables](#using-mailables)
  - [Previsualizando Notificaciones por Mail](#previewing-mail-notifications)
- [Notificaciones por Mail Markdown](#markdown-mail-notifications)
  - [Generando el Mensaje](#generating-the-message)
  - [Escribiendo el Mensaje](#writing-the-message)
  - [Personalizando los Componentes](#customizing-the-components)
- [Notificaciones de Base de Datos](#database-notifications)
  - [Requisitos Previos](#database-prerequisites)
  - [Formateando Notificaciones de Base de Datos](#formatting-database-notifications)
  - [Accediendo a las Notificaciones](#accessing-the-notifications)
  - [Marcando Notificaciones como Leídas](#marking-notifications-as-read)
- [Notificaciones de Difusión](#broadcast-notifications)
  - [Requisitos Previos](#broadcast-prerequisites)
  - [Formateando Notificaciones de Difusión](#formatting-broadcast-notifications)
  - [Escuchando Notificaciones](#listening-for-notifications)
- [Notificaciones SMS](#sms-notifications)
  - [Requisitos Previos](#sms-prerequisites)
  - [Formateando Notificaciones SMS](#formatting-sms-notifications)
  - [Contenido Unicode](#unicode-content)
  - [Personalizando el Número "Desde"]( #customizing-the-from-number)
  - [Añadiendo una Referencia de Cliente](#adding-a-client-reference)
  - [Enrutando Notificaciones SMS](#routing-sms-notifications)
- [Notificaciones de Slack](#slack-notifications)
  - [Requisitos Previos](#slack-prerequisites)
  - [Formateando Notificaciones de Slack](#formatting-slack-notifications)
  - [Interactividad de Slack](#slack-interactivity)
  - [Enrutando Notificaciones de Slack](#routing-slack-notifications)
  - [Notificando Espacios de Trabajo de Slack Externos](#notifying-external-slack-workspaces)
- [Localizando Notificaciones](#localizing-notifications)
- [Pruebas](#testing)
- [Eventos de Notificación](#notification-events)
- [Canales Personalizados](#custom-channels)

<a name="introduction"></a>
## Introducción

Además del soporte para [enviar correos electrónicos](/docs/%7B%7Bversion%7D%7D/mail), Laravel ofrece soporte para enviar notificaciones a través de una variedad de canales de entrega, incluyendo correo electrónico, SMS (a través de [Vonage](https://www.vonage.com/communications-apis/), anteriormente conocido como Nexmo), y [Slack](https://slack.com). Además, se han creado una variedad de [canales de notificación construidos por la comunidad](https://laravel-notification-channels.com/about/#suggesting-a-new-channel) para enviar notificaciones a través de docenas de canales diferentes. ¡Las notificaciones también se pueden almacenar en una base de datos para que puedan mostrarse en tu interfaz web!
Típicamente, las notificaciones deben ser mensajes cortos e informativos que notifiquen a los usuarios sobre algo que ocurrió en su aplicación. Por ejemplo, si estás escribiendo una aplicación de facturación, podrías enviar una notificación de "Factura Pagada" a tus usuarios a través de los canales de correo electrónico y SMS.

<a name="generating-notifications"></a>
## Generando Notificaciones

En Laravel, cada notificación está representada por una sola clase que se almacena típicamente en el directorio `app/Notifications`. No te preocupes si no ves este directorio en tu aplicación: se creará para ti cuando ejecutes el comando Artisan `make:notification`:


```shell
php artisan make:notification InvoicePaid

```
Este comando colocará una nueva clase de notificación en tu directorio `app/Notifications`. Cada clase de notificación contiene un método `via` y un número variable de métodos de construcción de mensajes, como `toMail` o `toDatabase`, que convierten la notificación en un mensaje adaptado para ese canal particular.

<a name="sending-notifications"></a>
## Enviando Notificaciones


<a name="using-the-notifiable-trait"></a>
### Uso del Trait Notifiable

Las notificaciones pueden enviarse de dos maneras: utilizando el método `notify` del trait `Notifiable` o utilizando la `Notification` [facade](/docs/%7B%7Bversion%7D%7D/facades). El trait `Notifiable` está incluido en el modelo `App\Models\User` de tu aplicación por defecto:


```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use Notifiable;
}
```
El método `notify` que proporciona este trait espera recibir una instancia de notificación:


```php
use App\Notifications\InvoicePaid;

$user->notify(new InvoicePaid($invoice));
```
> [!NOTA]
Recuerda que puedes usar el trait `Notifiable` en cualquiera de tus modelos. No estás limitado a incluirlo solo en tu modelo `User`.

<a name="using-the-notification-facade"></a>
### Usando la Facade de Notificación

Alternativamente, puedes enviar notificaciones a través de la `facade` [Notification](/docs/%7B%7Bversion%7D%7D/facades). Este enfoque es útil cuando necesitas enviar una notificación a múltiples entidades notificables, como una colección de usuarios. Para enviar notificaciones utilizando la facade, pasa todas las entidades notificables y la instancia de notificación al método `send`:


```php
use Illuminate\Support\Facades\Notification;

Notification::send($users, new InvoicePaid($invoice));
```
También puedes enviar notificaciones de inmediato utilizando el método `sendNow`. Este método enviará la notificación de inmediato incluso si la notificación implementa la interfaz `ShouldQueue`:


```php
Notification::sendNow($developers, new DeploymentCompleted($deployment));
```

<a name="specifying-delivery-channels"></a>
### Especificando Canales de Entrega

Cada clase de notificación tiene un método `via` que determina en qué canales se entregará la notificación. Las notificaciones pueden enviarse a través de los canales `mail`, `database`, `broadcast`, `vonage` y `slack`.
> [!NOTA]
Si deseas utilizar otros canales de entrega como Telegram o Pusher, visita el sitio web de [Laravel Notification Channels](http://laravel-notification-channels.com) impulsado por la comunidad.
El método `via` recibe una instancia de `$notifiable`, que será una instancia de la clase a la que se está enviando la notificación. Puedes usar `$notifiable` para determinar en qué canales debe entregarse la notificación:


```php
/**
 * Get the notification's delivery channels.
 *
 * @return array<int, string>
 */
public function via(object $notifiable): array
{
    return $notifiable->prefers_sms ? ['vonage'] : ['mail', 'database'];
}
```

<a name="queueing-notifications"></a>
### Notificaciones en Cola

> [!WARNING]
Antes de encolar notificaciones, debes configurar tu cola y [iniciar un worker](/docs/%7B%7Bversion%7D%7D/queues#running-the-queue-worker).
Enviar notificaciones puede llevar tiempo, especialmente si el canal necesita hacer una llamada a una API externa para entregar la notificación. Para acelerar el tiempo de respuesta de tu aplicación, permite que tu notificación sea encolada agregando la interfaz `ShouldQueue` y el trait `Queueable` a tu clase. La interfaz y el trait ya están importados para todas las notificaciones generadas utilizando el comando `make:notification`, así que puedes añadirlos inmediatamente a tu clase de notificación:


```php
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
```
Una vez que se haya añadido la interfaz `ShouldQueue` a tu notificación, puedes enviar la notificación como de costumbre. Laravel detectará la interfaz `ShouldQueue` en la clase y, automáticamente, encolará la entrega de la notificación:
Al hacer cola de notificaciones, se creará un trabajo en cola para cada combinación de destinatario y canal. Por ejemplo, se despacharán seis trabajos a la cola si tu notificación tiene tres destinatarios y dos canales.

<a name="delaying-notifications"></a>
#### Retraso de Notificaciones

Si deseas retrasar la entrega de la notificación, puedes encadenar el método `delay` a la instancia de tu notificación:


```php
$delay = now()->addMinutes(10);

$user->notify((new InvoicePaid($invoice))->delay($delay));
```
Puedes pasar un array al método `delay` para especificar la cantidad de demora para canales específicos:


```php
$user->notify((new InvoicePaid($invoice))->delay([
    'mail' => now()->addMinutes(5),
    'sms' => now()->addMinutes(10),
]));
```
Alternativamente, puedes definir un método `withDelay` en la propia clase de notificación. El método `withDelay` debe devolver un array de nombres de canales y valores de retraso:


```php
/**
 * Determine the notification's delivery delay.
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
```

<a name="customizing-the-notification-queue-connection"></a>
#### Personalizando la Conexión de la Cola de Notificaciones

Por defecto, las notificaciones en cola se encolarán utilizando la conexión de cola predeterminada de tu aplicación. Si deseas especificar una conexión diferente que se debe usar para una notificación en particular, puedes llamar al método `onConnection` desde el constructor de tu notificación:


```php
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
     */
    public function __construct()
    {
        $this->onConnection('redis');
    }
}
```
O, si deseas especificar una conexión de cola específica que se debe usar para cada canal de notificación admitido por la notificación, puedes definir un método `viaConnections` en tu notificación. Este método debe devolver un array de pares de nombre de canal / nombre de conexión de cola:


```php
/**
 * Determine which connections should be used for each notification channel.
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
```

<a name="customizing-notification-channel-queues"></a>
#### Personalizando las Colas del Canal de Notificación

Si deseas especificar una cola específica que debe utilizarse para cada canal de notificación admitido por la notificación, puedes definir un método `viaQueues` en tu notificación. Este método debe devolver un array de pares de nombre de canal / nombre de cola:


```php
/**
 * Determine which queues should be used for each notification channel.
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
```

<a name="queued-notification-middleware"></a>
#### Middleware de Notificación en Cola

Las notificaciones en cola pueden definir middleware [al igual que los trabajos en cola](/docs/%7B%7Bversion%7D%7D/queues#job-middleware). Para comenzar, define un método `middleware` en tu clase de notificación. El método `middleware` recibirá las variables `$notifiable` y `$channel`, lo que te permite personalizar el middleware devuelto según el destino de la notificación:


```php
use Illuminate\Queue\Middleware\RateLimited;

/**
 * Get the middleware the notification job should pass through.
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
```

<a name="queued-notifications-and-database-transactions"></a>
#### Notificaciones en Cola y Transacciones de Base de Datos

Cuando se despachan notificaciones en cola dentro de transacciones de base de datos, pueden ser procesadas por la cola antes de que la transacción de la base de datos se haya confirmado. Cuando esto sucede, cualquier actualización que hayas realizado a modelos o registros de base de datos durante la transacción de base de datos puede no reflejarse aún en la base de datos. Además, cualquier modelo o registro de base de datos creado dentro de la transacción puede no existir en la base de datos. Si tu notificación depende de estos modelos, pueden ocurrir errores inesperados cuando se procesa el trabajo que envía la notificación en cola.
Si la opción de configuración `after_commit` de la conexión de cola está configurada en `false`, aún puedes indicar que una notificación en cola particular debe ser despachada después de que se hayan confirmado todas las transacciones de base de datos abiertas llamando al método `afterCommit` al enviar la notificación:


```php
use App\Notifications\InvoicePaid;

$user->notify((new InvoicePaid($invoice))->afterCommit());
```
Alternativamente, puedes llamar al método `afterCommit` desde el constructor de tu notificación:


```php
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
     */
    public function __construct()
    {
        $this->afterCommit();
    }
}
```
> [!NOTE]
Para obtener más información sobre cómo solucionar estos problemas, revisa la documentación sobre [trabajos en cola y transacciones de base de datos](/docs/%7B%7Bversion%7D%7D/queues#jobs-and-database-transactions).

<a name="determining-if-the-queued-notification-should-be-sent"></a>
#### Determinando si se debe enviar una notificación en cola

Después de que se haya despachado una notificación en cola para su procesamiento en segundo plano, típicamente será aceptada por un trabajador de cola y enviada a su destinatario previsto.
Sin embargo, si deseas tomar la decisión final sobre si la notificación en cola debe ser enviada después de que esté siendo procesada por un trabajador de cola, puedes definir un método `shouldSend` en la clase de notificación. Si este método devuelve `false`, la notificación no será enviada:


```php
/**
 * Determine if the notification should be sent.
 */
public function shouldSend(object $notifiable, string $channel): bool
{
    return $this->invoice->isPaid();
}
```
### Notificaciones Bajo Demanda

A veces es posible que necesites enviar una notificación a alguien que no está almacenado como un "usuario" de tu aplicación. Usando el método `route` de la fachada `Notification`, puedes especificar información de enrutamiento de notificación ad-hoc antes de enviar la notificación:


```php
use Illuminate\Broadcasting\Channel;
use Illuminate\Support\Facades\Notification;

Notification::route('mail', 'taylor@example.com')
            ->route('vonage', '5555555555')
            ->route('slack', '#slack-channel')
            ->route('broadcast', [new Channel('channel-name')])
            ->notify(new InvoicePaid($invoice));
```
Si deseas proporcionar el nombre del destinatario al enviar una notificación bajo demanda a la ruta `mail`, puedes proporcionar un array que contenga la dirección de correo electrónico como la clave y el nombre como el valor del primer elemento del array:


```php
Notification::route('mail', [
    'barrett@example.com' => 'Barrett Blair',
])->notify(new InvoicePaid($invoice));
```
Usando el método `routes`, puedes proporcionar información de enrutamiento ad-hoc para múltiples canales de notificación a la vez:


```php
Notification::routes([
    'mail' => ['barrett@example.com' => 'Barrett Blair'],
    'vonage' => '5555555555',
])->notify(new InvoicePaid($invoice));
```

<a name="mail-notifications"></a>
## Notificaciones por Correo


<a name="formatting-mail-messages"></a>
### Formateo de Mensajes de Correo

Si una notificación admite ser enviada como un correo electrónico, debes definir un método `toMail` en la clase de notificación. Este método recibirá una entidad `$notifiable` y debe devolver una instancia de `Illuminate\Notifications\Messages\MailMessage`.
La clase `MailMessage` contiene algunos métodos simples para ayudarte a crear mensajes de correo electrónico transaccionales. Los mensajes de correo pueden contener líneas de texto así como un "llamado a la acción". Echemos un vistazo a un ejemplo del método `toMail`:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    $url = url('/invoice/'.$this->invoice->id);

    return (new MailMessage)
                ->greeting('Hello!')
                ->line('One of your invoices has been paid!')
                ->lineIf($this->amount > 0, "Amount paid: {$this->amount}")
                ->action('View Invoice', $url)
                ->line('Thank you for using our application!');
}
```
> [!NOTE]
Nota que estamos utilizando `$this->invoice->id` en nuestro método `toMail`. Puedes pasar cualquier dato que tu notificación necesite para generar su mensaje en el constructor de la notificación.
En este ejemplo, registramos un saludo, una línea de texto, un llamado a la acción y luego otra línea de texto. Estos métodos proporcionados por el objeto `MailMessage` hacen que sea simple y rápido formatear pequeños correos electrónicos transaccionales. El canal de correo luego traducirá los componentes del mensaje en una hermosa plantilla de correo electrónico HTML receptiva con un contraparte de texto plano. Aquí hay un ejemplo de un correo electrónico generado por el canal `mail`:
<img src="https://laravel.com/img/docs/notification-example-2.png">
> [!NOTA]
Al enviar notificaciones por correo, asegúrate de configurar la opción de configuración `name` en tu archivo de configuración `config/app.php`. Este valor se utilizará en el encabezado y pie de tus mensajes de notificación por correo.

<a name="error-messages"></a>
#### Mensajes de Error

Algunas notificaciones informan a los usuarios sobre errores, como un pago de factura fallido. Puedes indicar que un mensaje de correo está relacionado con un error llamando al método `error` al construir tu mensaje. Al usar el método `error` en un mensaje de correo, el botón de llamada a la acción será rojo en lugar de negro:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)
                ->error()
                ->subject('Invoice Payment Failed')
                ->line('...');
}
```

<a name="other-mail-notification-formatting-options"></a>
#### Otras Opciones de Formato de Notificación por Correo

En lugar de definir las "líneas" de texto en la clase de notificación, puedes usar el método `view` para especificar una plantilla personalizada que se debe utilizar para renderizar el correo electrónico de notificación:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)->view(
        'mail.invoice.paid', ['invoice' => $this->invoice]
    );
}
```
Puedes especificar una vista de texto plano para el mensaje de correo pasando el nombre de la vista como el segundo elemento de un array que se le da al método `view`:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)->view(
        ['mail.invoice.paid', 'mail.invoice.paid-text'],
        ['invoice' => $this->invoice]
    );
}
```
O, si tu mensaje solo tiene una vista de texto plano, puedes utilizar el método `text`:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)->text(
        'mail.invoice.paid-text', ['invoice' => $this->invoice]
    );
}
```

<a name="customizing-the-sender"></a>
### Personalizando el Remitente

Por defecto, la dirección del remitente / dirección de desde del correo electrónico se define en el archivo de configuración `config/mail.php`. Sin embargo, puedes especificar la dirección de desde para una notificación específica utilizando el método `from`:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)
                ->from('barrett@example.com', 'Barrett Blair')
                ->line('...');
}
```

<a name="customizing-the-recipient"></a>
### Personalizando el Destinatario

Al enviar notificaciones a través del canal `mail`, el sistema de notificaciones buscará automáticamente una propiedad `email` en tu entidad notifiable. Puedes personalizar qué dirección de correo electrónico se utiliza para entregar la notificación definiendo un método `routeNotificationForMail` en la entidad notifiable:


```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Notifications\Notification;

class User extends Authenticatable
{
    use Notifiable;

    /**
     * Route notifications for the mail channel.
     *
     * @return  array<string, string>|string
     */
    public function routeNotificationForMail(Notification $notification): array|string
    {
        // Return email address only...
        return $this->email_address;

        // Return email address and name...
        return [$this->email_address => $this->name];
    }
}
```

<a name="customizing-the-subject"></a>
### Personalizando el Asunto

Por defecto, el asunto del correo electrónico es el nombre de la clase de la notificación formateado en "Title Case". Así que, si tu clase de notificación se llama `InvoicePaid`, el asunto del correo electrónico será `Invoice Paid`. Si deseas especificar un asunto diferente para el mensaje, puedes llamar al método `subject` al construir tu mensaje:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)
                ->subject('Notification Subject')
                ->line('...');
}
```

<a name="customizing-the-mailer"></a>
### Personalizando el Mailer

Por defecto, la notificación por correo electrónico se enviará utilizando el mailer predeterminado definido en el archivo de configuración `config/mail.php`. Sin embargo, puedes especificar un mailer diferente en tiempo de ejecución llamando al método `mailer` al construir tu mensaje:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)
                ->mailer('postmark')
                ->line('...');
}
```

<a name="customizing-the-templates"></a>
### Personalizando las Plantillas

Puedes modificar la plantilla HTML y de texto plano utilizada por las notificaciones de correo publicando los recursos del paquete de notificaciones. Después de ejecutar este comando, las plantillas de notificación de correo se ubicará en el directorio `resources/views/vendor/notifications`:


```shell
php artisan vendor:publish --tag=laravel-notifications

```

<a name="mail-attachments"></a>
### Adjuntos

Para agregar archivos adjuntos a una notificación por correo electrónico, utiliza el método `attach` mientras construyes tu mensaje. El método `attach` acepta la ruta absoluta al archivo como su primer argumento:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)
                ->greeting('Hello!')
                ->attach('/path/to/file');
}
```
> [!NOTE]
El método `attach` que ofrecen los mensajes de correo de notificación también acepta [objetos adjuntos](/docs/%7B%7Bversion%7D%7D/mail#attachable-objects). Por favor, consulta la completa [documentación de objetos adjuntos](/docs/%7B%7Bversion%7D%7D/mail#attachable-objects) para aprender más.
Al adjuntar archivos a un mensaje, también puedes especificar el nombre a mostrar y / o el tipo MIME pasando un `array` como segundo argumento al método `attach`:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)
                ->greeting('Hello!')
                ->attach('/path/to/file', [
                    'as' => 'name.pdf',
                    'mime' => 'application/pdf',
                ]);
}
```
A diferencia de adjuntar archivos en objetos mailable, no puedes adjuntar un archivo directamente desde un disco de almacenamiento utilizando `attachFromStorage`. Debes usar el método `attach` con una ruta absoluta al archivo en el disco de almacenamiento. Alternativamente, podrías devolver un [mailable](/docs/%7B%7Bversion%7D%7D/mail#generating-mailables) desde el método `toMail`:


```php
use App\Mail\InvoicePaid as InvoicePaidMailable;

/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): Mailable
{
    return (new InvoicePaidMailable($this->invoice))
                ->to($notifiable->email)
                ->attachFromStorage('/path/to/file');
}
```
Cuando sea necesario, se pueden adjuntar múltiples archivos a un mensaje utilizando el método `attachMany`:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
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
```

<a name="raw-data-attachments"></a>
#### Archivos de Datos en Crudo

El método `attachData` puede utilizarse para adjuntar una cadena de bytes en bruto como un archivo adjunto. Al llamar al método `attachData`, debes proporcionar el nombre del archivo que se debe asignar al archivo adjunto:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)
                ->greeting('Hello!')
                ->attachData($this->pdf, 'name.pdf', [
                    'mime' => 'application/pdf',
                ]);
}
```

<a name="adding-tags-metadata"></a>
### Agregar Etiquetas y Metadatos

Algunos proveedores de correo electrónico de terceros como Mailgun y Postmark admiten "etiquetas" y "metadatos" de mensaje, que se pueden usar para agrupar y rastrear correos electrónicos enviados por su aplicación. Puede agregar etiquetas y metadatos a un mensaje de correo electrónico a través de los métodos `tag` y `metadata`:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)
                ->greeting('Comment Upvoted!')
                ->tag('upvote')
                ->metadata('comment_id', $this->comment->id);
}
```
Si tu aplicación está utilizando el driver de Mailgun, puedes consultar la documentación de Mailgun para obtener más información sobre [etiquetas](https://documentation.mailgun.com/en/latest/user_manual.html#tagging-1) y [metadatos](https://documentation.mailgun.com/en/latest/user_manual.html#attaching-data-to-messages). Del mismo modo, también se puede consultar la documentación de Postmark para obtener más información sobre su soporte para [etiquetas](https://postmarkapp.com/blog/tags-support-for-smtp) y [metadatos](https://postmarkapp.com/support/article/1125-custom-metadata-faq).
Si tu aplicación está utilizando Amazon SES para enviar correos electrónicos, deberías usar el método `metadata` para adjuntar [etiquetas "SES"](https://docs.aws.amazon.com/ses/latest/APIReference/API_MessageTag.html) al mensaje.

<a name="customizing-the-symfony-message"></a>
### Personalizando el Mensaje de Symfony

El método `withSymfonyMessage` de la clase `MailMessage` te permite registrar una función anónima que se invocará con la instancia del mensaje Symfony antes de enviar el mensaje. Esto te da la oportunidad de personalizar profundamente el mensaje antes de que sea entregado:


```php
use Symfony\Component\Mime\Email;

/**
 * Get the mail representation of the notification.
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
```

<a name="using-mailables"></a>
### Usando Mailables

Si es necesario, puedes devolver un objeto [mailable completo](/docs/%7B%7Bversion%7D%7D/mail) desde el método `toMail` de tu notificación. Al devolver un `Mailable` en lugar de un `MailMessage`, deberás especificar el destinatario del mensaje utilizando el método `to` del objeto mailable:


```php
use App\Mail\InvoicePaid as InvoicePaidMailable;
use Illuminate\Mail\Mailable;

/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): Mailable
{
    return (new InvoicePaidMailable($this->invoice))
                ->to($notifiable->email);
}
```

<a name="mailables-and-on-demand-notifications"></a>
#### Mailables y Notificaciones Bajo Demanda

Si estás enviando una [notificación bajo demanda](#on-demand-notifications), la instancia de `$notifiable` dada al método `toMail` será una instancia de `Illuminate\Notifications\AnonymousNotifiable`, que ofrece un método `routeNotificationFor` que se puede usar para recuperar la dirección de correo electrónico a la que se debe enviar la notificación bajo demanda:


```php
use App\Mail\InvoicePaid as InvoicePaidMailable;
use Illuminate\Notifications\AnonymousNotifiable;
use Illuminate\Mail\Mailable;

/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): Mailable
{
    $address = $notifiable instanceof AnonymousNotifiable
            ? $notifiable->routeNotificationFor('mail')
            : $notifiable->email;

    return (new InvoicePaidMailable($this->invoice))
                ->to($address);
}
```

<a name="previewing-mail-notifications"></a>
### Previsualizando Notificaciones por Correo

Al diseñar una plantilla de notificación por correo, es conveniente previsualizar rápidamente el mensaje de correo renderizado en tu navegador como una plantilla Blade típica. Por esta razón, Laravel te permite devolver cualquier mensaje de correo generado por una notificación por correo directamente desde una función anónima de ruta o un controlador. Cuando se devuelve un `MailMessage`, se renderizará y se mostrará en el navegador, lo que te permitirá previsualizar rápidamente su diseño sin necesidad de enviarlo a una dirección de correo electrónico real:


```php
use App\Models\Invoice;
use App\Notifications\InvoicePaid;

Route::get('/notification', function () {
    $invoice = Invoice::find(1);

    return (new InvoicePaid($invoice))
                ->toMail($invoice->user);
});
```

<a name="markdown-mail-notifications"></a>
## Notificaciones de Correo Markdown

Las notificaciones de correo Markdown te permiten aprovechar las plantillas predefinidas de notificaciones por correo, al mismo tiempo que te brindan más libertad para escribir mensajes personalizados más largos. Dado que los mensajes están escritos en Markdown, Laravel puede renderizar hermosas plantillas HTML responsivas para los mensajes y también generar automáticamente un equivalente en texto plano.

<a name="generating-the-message"></a>
### Generando el Mensaje

Para generar una notificación con una plantilla Markdown correspondiente, puedes utilizar la opción `--markdown` del comando Artisan `make:notification`:


```shell
php artisan make:notification InvoicePaid --markdown=mail.invoice.paid

```
Como todas las demás notificaciones por correo, las notificaciones que utilizan plantillas Markdown deben definir un método `toMail` en su clase de notificación. Sin embargo, en lugar de usar los métodos `line` y `action` para construir la notificación, utiliza el método `markdown` para especificar el nombre de la plantilla Markdown que se debe usar. Se puede pasar un array de datos que deseas hacer disponibles para la plantilla como segundo argumento del método:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    $url = url('/invoice/'.$this->invoice->id);

    return (new MailMessage)
                ->subject('Invoice Paid')
                ->markdown('mail.invoice.paid', ['url' => $url]);
}
```

<a name="writing-the-message"></a>
### Escribiendo el Mensaje

Las notificaciones por correo en Markdown utilizan una combinación de componentes de Blade y sintaxis Markdown, lo que te permite construir notificaciones fácilmente mientras aprovechas los componentes de notificación predefinidos de Laravel:


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

El componente de botón renderiza un enlace de botón centrado. El componente acepta dos argumentos, una `url` y un `color` opcional. Los colores admitidos son `primary`, `green` y `red`. Puedes añadir tantos componentes de botón a una notificación como desees:


```blade
<x-mail::button :url="$url" color="green">
View Invoice
</x-mail::button>

```

<a name="panel-component"></a>
#### Componente de Panel

El componente del panel renderiza el bloque de texto dado en un panel que tiene un color de fondo ligeramente diferente al del resto de la notificación. Esto te permite llamar la atención sobre un bloque de texto dado:


```blade
<x-mail::panel>
This is the panel content.
</x-mail::panel>

```

<a name="table-component"></a>
#### Componente de Tabla

El componente de tabla te permite transformar una tabla Markdown en una tabla HTML. El componente acepta la tabla Markdown como su contenido. Se admite la alineación de columnas de tabla utilizando la sintaxis de alineación de tabla Markdown predeterminada:


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

Puedes exportar todos los componentes de notificación Markdown a tu propia aplicación para personalizarlos. Para exportar los componentes, utiliza el comando Artisan `vendor:publish` para publicar la etiqueta de activo `laravel-mail`:


```shell
php artisan vendor:publish --tag=laravel-mail

```
Este comando publicará los componentes de correo Markdown en el directorio `resources/views/vendor/mail`. El directorio `mail` contendrá un directorio `html` y un directorio `text`, cada uno conteniendo sus respectivas representaciones de cada componente disponible. Puedes personalizar estos componentes como desees.

<a name="customizing-the-css"></a>
#### Personalizando el CSS

Después de exportar los componentes, el directorio `resources/views/vendor/mail/html/themes` contendrá un archivo `default.css`. Puedes personalizar el CSS en este archivo y tus estilos se incluirán automáticamente en las representaciones HTML de tus notificaciones Markdown.
Si deseas crear un tema completamente nuevo para los componentes de Markdown de Laravel, puedes colocar un archivo CSS dentro del directorio `html/themes`. Después de nombrar y guardar tu archivo CSS, actualiza la opción `theme` del archivo de configuración `mail` para que coincida con el nombre de tu nuevo tema.
Para personalizar el tema de una notificación individual, puedes llamar al método `theme` mientras construyes el mensaje de correo de la notificación. El método `theme` acepta el nombre del tema que se debe usar al enviar la notificación:


```php
/**
 * Get the mail representation of the notification.
 */
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)
                ->theme('invoice')
                ->subject('Invoice Paid')
                ->markdown('mail.invoice.paid', ['url' => $url]);
}
```

<a name="database-notifications"></a>
## Notificaciones de Base de Datos


<a name="database-prerequisites"></a>
El canal de notificaciones `database` almacena la información de notificación en una tabla de base de datos. Esta tabla contendrá información como el tipo de notificación, así como una estructura de datos JSON que describe la notificación.
Puedes consultar la tabla para mostrar las notificaciones en la interfaz de usuario de tu aplicación. Pero, antes de que puedas hacer eso, necesitarás crear una tabla de base de datos para mantener tus notificaciones. Puedes usar el comando `make:notifications-table` para generar una [migración](/docs/%7B%7Bversion%7D%7D/migrations) con el esquema de tabla apropiado:


```shell
php artisan make:notifications-table

php artisan migrate

```
> [!NOTA]
Si tus modelos notifiables están usando [claves primarias UUID o ULID](/docs/%7B%7Bversion%7D%7D/eloquent#uuid-and-ulid-keys), deberías reemplazar el método `morphs` con [`uuidMorphs`](/docs/%7B%7Bversion%7D%7D/migrations#column-method-uuidMorphs) o [`ulidMorphs`](/docs/%7B%7Bversion%7D%7D/migrations#column-method-ulidMorphs) en la migración de la tabla de notificaciones.

<a name="formatting-database-notifications"></a>
### Formateo de Notificaciones de Base de Datos

Si una notificación admite ser almacenada en una tabla de base de datos, debes definir un método `toDatabase` o `toArray` en la clase de notificación. Este método recibirá una entidad `$notifiable` y debe devolver un array PHP plano. El array devuelto será codificado como JSON y almacenado en la columna `data` de tu tabla `notifications`. Vamos a ver un ejemplo del método `toArray`:


```php
/**
 * Get the array representation of the notification.
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
```
Cuando la notificación se almacena en la base de datos de tu aplicación, la columna `type` se rellenará con el nombre de la clase de la notificación. Sin embargo, puedes personalizar este comportamiento definiendo un método `databaseType` en tu clase de notificación:


```php
/**
 * Get the notification's database type.
 *
 * @return string
 */
public function databaseType(object $notifiable): string
{
    return 'invoice-paid';
}
```

<a name="todatabase-vs-toarray"></a>
#### `toDatabase` vs. `toArray`

El método `toArray` también es utilizado por el canal `broadcast` para determinar qué datos transmitir a tu frontend impulsado por JavaScript. Si deseas tener dos representaciones de array diferentes para los canales `database` y `broadcast`, debes definir un método `toDatabase` en lugar de un método `toArray`.

<a name="accessing-the-notifications"></a>
### Accediendo a las Notificaciones

Una vez que las notificaciones están almacenadas en la base de datos, necesitas una forma conveniente de acceder a ellas desde tus entidades notificables. El trait `Illuminate\Notifications\Notifiable`, que se incluye en el modelo `App\Models\User` por defecto de Laravel, incluye una relación `notifications` [Eloquent relationship](/docs/%7B%7Bversion%7D%7D/eloquent-relationships) que devuelve las notificaciones para la entidad. Para obtener las notificaciones, puedes acceder a este método como cualquier otra relación Eloquent. Por defecto, las notificaciones se ordenarán por la marca de tiempo `created_at`, con las notificaciones más recientes al principio de la colección:


```php
$user = App\Models\User::find(1);

foreach ($user->notifications as $notification) {
    echo $notification->type;
}
```
Si deseas recuperar solo las notificaciones "no leídas", puedes usar la relación `unreadNotifications`. Nuevamente, estas notificaciones se ordenarán por la marca de tiempo `created_at`, con las notificaciones más recientes al principio de la colección:


```php
$user = App\Models\User::find(1);

foreach ($user->unreadNotifications as $notification) {
    echo $notification->type;
}
```
> [!NOTA]
Para acceder a tus notificaciones desde tu cliente JavaScript, debes definir un controlador de notificaciones para tu aplicación que devuelva las notificaciones para una entidad notificable, como el usuario actual. Luego, puedes hacer una solicitud HTTP a la URL de ese controlador desde tu cliente JavaScript.

<a name="marking-notifications-as-read"></a>
### Marcando Notificaciones como Leídas

Típicamente, querrás marcar una notificación como "leída" cuando un usuario la visualiza. El trait `Illuminate\Notifications\Notifiable` proporciona un método `markAsRead`, que actualiza la columna `read_at` en el registro de la base de datos de la notificación:


```php
$user = App\Models\User::find(1);

foreach ($user->unreadNotifications as $notification) {
    $notification->markAsRead();
}
```
Sin embargo, en lugar de iterar a través de cada notificación, puedes usar el método `markAsRead` directamente en una colección de notificaciones:


```php
$user->unreadNotifications->markAsRead();
```
También puedes utilizar una consulta de actualización masiva para marcar todas las notificaciones como leídas sin recuperarlas de la base de datos:


```php
$user = App\Models\User::find(1);

$user->unreadNotifications()->update(['read_at' => now()]);
```
Puedes `eliminar` las notificaciones para quitarlas de la tabla por completo:


```php
$user->notifications()->delete();
```

<a name="broadcast-notifications"></a>
## Notificaciones de Difusión


<a name="broadcast-prerequisites"></a>
Antes de transmitir notificaciones, debes configurar y conocer los servicios de [transmisión de eventos](/docs/%7B%7Bversion%7D%7D/broadcasting) de Laravel. La transmisión de eventos proporciona una forma de reaccionar a eventos de Laravel del lado del servidor desde tu frontend impulsado por JavaScript.

<a name="formatting-broadcast-notifications"></a>
### Formateo de Notificaciones de Transmisión

El canal `broadcast` transmite notificaciones utilizando los servicios de [broadcasting de eventos](/docs/%7B%7Bversion%7D%7D/broadcasting) de Laravel, permitiendo que tu frontend alimentado por JavaScript reciba notificaciones en tiempo real. Si una notificación admite broadcasting, puedes definir un método `toBroadcast` en la clase de notificación. Este método recibirá una entidad `$notifiable` y debería devolver una instancia de `BroadcastMessage`. Si el método `toBroadcast` no existe, se utilizará el método `toArray` para reunir los datos que deben ser transmitidos. Los datos devueltos se codificarán como JSON y se transmitirán a tu frontend alimentado por JavaScript. Veamos un ejemplo del método `toBroadcast`:


```php
use Illuminate\Notifications\Messages\BroadcastMessage;

/**
 * Get the broadcastable representation of the notification.
 */
public function toBroadcast(object $notifiable): BroadcastMessage
{
    return new BroadcastMessage([
        'invoice_id' => $this->invoice->id,
        'amount' => $this->invoice->amount,
    ]);
}
```

<a name="broadcast-queue-configuration"></a>
#### Configuración de Cola de Transmisión

Todas las notificaciones de transmisión se encolan para su transmisión. Si deseas configurar la conexión de cola o el nombre de cola que se utiliza para encolar la operación de transmisión, puedes usar los métodos `onConnection` y `onQueue` de `BroadcastMessage`:


```php
return (new BroadcastMessage($data))
                ->onConnection('sqs')
                ->onQueue('broadcasts');
```

<a name="customizing-the-notification-type"></a>
#### Personalizando el Tipo de Notificación

Además de los datos que especifiques, todas las notificaciones de transmisión también tienen un campo `type` que contiene el nombre completo de la clase de la notificación. Si deseas personalizar el `type` de la notificación, puedes definir un método `broadcastType` en la clase de notificación:


```php
/**
 * Get the type of the notification being broadcast.
 */
public function broadcastType(): string
{
    return 'broadcast.message';
}
```

<a name="listening-for-notifications"></a>
### Escuchando Notificaciones

Las notificaciones se transmitirán en un canal privado formateado utilizando una convención `{notifiable}.{id}`. Así que, si estás enviando una notificación a una instancia de `App\Models\User` con un ID de `1`, la notificación se transmitirá en el canal privado `App.Models.User.1`. Al usar [Laravel Echo](/docs/%7B%7Bversion%7D%7D/broadcasting#client-side-installation), puedes escuchar fácilmente notificaciones en un canal utilizando el método `notification`:


```php
Echo.private('App.Models.User.' + userId)
    .notification((notification) => {
        console.log(notification.type);
    });
```

<a name="customizing-the-notification-channel"></a>
#### Personalizando el Canal de Notificación

Si deseas personalizar en qué canal se transmiten las notificaciones de transmisión de una entidad, puedes definir un método `receivesBroadcastNotificationsOn` en la entidad notifiable:


```php
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
     */
    public function receivesBroadcastNotificationsOn(): string
    {
        return 'users.'.$this->id;
    }
}
```

<a name="sms-notifications"></a>
## Notificaciones por SMS


<a name="sms-prerequisites"></a>
Enviar notificaciones por SMS en Laravel está impulsado por [Vonage](https://www.vonage.com/) (anteriormente conocido como Nexmo). Antes de que puedas enviar notificaciones a través de Vonage, necesitas instalar los paquetes `laravel/vonage-notification-channel` y `guzzlehttp/guzzle`:


```php
composer require laravel/vonage-notification-channel guzzlehttp/guzzle
```
El paquete incluye un [archivo de configuración](https://github.com/laravel/vonage-notification-channel/blob/3.x/config/vonage.php). Sin embargo, no es necesario que exportes este archivo de configuración a tu propia aplicación. Puedes simplemente usar las variables de entorno `VONAGE_KEY` y `VONAGE_SECRET` para definir tus claves pública y secreta de Vonage.
Después de definir tus claves, debes configurar una variable de entorno `VONAGE_SMS_FROM` que defina el número de teléfono desde el cual se deben enviar tus mensajes SMS por defecto. Puedes generar este número de teléfono dentro del panel de control de Vonage:


```php
VONAGE_SMS_FROM=15556666666
```

<a name="formatting-sms-notifications"></a>
### Formateo de Notificaciones SMS

Si una notificación admite ser enviada como un SMS, debes definir un método `toVonage` en la clase de notificación. Este método recibirá una entidad `$notifiable` y debe devolver una instancia de `Illuminate\Notifications\Messages\VonageMessage`:


```php
use Illuminate\Notifications\Messages\VonageMessage;

/**
 * Get the Vonage / SMS representation of the notification.
 */
public function toVonage(object $notifiable): VonageMessage
{
    return (new VonageMessage)
                ->content('Your SMS message content');
}
```

<a name="unicode-content"></a>
#### Contenido Unicode

Si tu mensaje SMS contendrá caracteres unicode, debes llamar al método `unicode` al construir la instancia de `VonageMessage`:


```php
use Illuminate\Notifications\Messages\VonageMessage;

/**
 * Get the Vonage / SMS representation of the notification.
 */
public function toVonage(object $notifiable): VonageMessage
{
    return (new VonageMessage)
                ->content('Your unicode message')
                ->unicode();
}
```

<a name="customizing-the-from-number"></a>
### Personalizando el número "Desde"

Si deseas enviar algunas notificaciones desde un número de teléfono que es diferente del número de teléfono especificado por tu variable de entorno `VONAGE_SMS_FROM`, puedes llamar al método `from` en una instancia de `VonageMessage`:


```php
use Illuminate\Notifications\Messages\VonageMessage;

/**
 * Get the Vonage / SMS representation of the notification.
 */
public function toVonage(object $notifiable): VonageMessage
{
    return (new VonageMessage)
                ->content('Your SMS message content')
                ->from('15554443333');
}
```

<a name="adding-a-client-reference"></a>
### Añadir una referencia de cliente

Si deseas hacer un seguimiento de costos por usuario, equipo o cliente, puedes añadir una "referencia de cliente" a la notificación. Vonage te permitirá generar informes utilizando esta referencia de cliente para que puedas entender mejor el uso de SMS de un cliente en particular. La referencia de cliente puede ser cualquier cadena de hasta 40 caracteres:


```php
use Illuminate\Notifications\Messages\VonageMessage;

/**
 * Get the Vonage / SMS representation of the notification.
 */
public function toVonage(object $notifiable): VonageMessage
{
    return (new VonageMessage)
                ->clientReference((string) $notifiable->id)
                ->content('Your SMS message content');
}
```

<a name="routing-sms-notifications"></a>
### Enrutando Notificaciones SMS

Para enrutar las notificaciones de Vonage al número de teléfono correcto, define un método `routeNotificationForVonage` en tu entidad notifiable:


```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Notifications\Notification;

class User extends Authenticatable
{
    use Notifiable;

    /**
     * Route notifications for the Vonage channel.
     */
    public function routeNotificationForVonage(Notification $notification): string
    {
        return $this->phone_number;
    }
}
```

<a name="slack-notifications"></a>
## Notificaciones de Slack


<a name="slack-prerequisites"></a>
### Requisitos previos

Antes de enviar notificaciones de Slack, debes instalar el canal de notificaciones de Slack a través de Composer:


```shell
composer require laravel/slack-notification-channel

```
Además, debes crear una [Slack App](https://api.slack.com/apps?new_app=1) para tu espacio de trabajo de Slack.
Si solo necesitas enviar notificaciones al mismo espacio de trabajo de Slack en el que se crea la aplicación, debes asegurarte de que tu aplicación tenga los alcances `chat:write`, `chat:write.public` y `chat:write.customize`. Estos alcances se pueden agregar desde la pestaña de gestión de aplicaciones "OAuth y permisos" dentro de Slack.
A continuación, copia el "Token OAuth de Bot User" de la aplicación y colócalo dentro de un array de configuración `slack` en el archivo de configuración `services.php` de tu aplicación. Este token se puede encontrar en la pestaña "OAuth & Permissions" dentro de Slack:


```php
'slack' => [
    'notifications' => [
        'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
        'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
    ],
],
```

<a name="slack-app-distribution"></a>
#### Distribución de Aplicaciones

Si tu aplicación va a enviar notificaciones a espacios de trabajo de Slack externos que son propiedad de los usuarios de tu aplicación, necesitarás "distribuir" tu aplicación a través de Slack. La distribución de la aplicación se puede gestionar desde la pestaña "Gestionar distribución" de tu aplicación dentro de Slack. Una vez que tu aplicación haya sido distribuida, puedes usar [Socialite](/docs/%7B%7Bversion%7D%7D/socialite) para [obtener tokens de bot de Slack](/docs/%7B%7Bversion%7D%7D/socialite#slack-bot-scopes) en nombre de los usuarios de tu aplicación.

<a name="formatting-slack-notifications"></a>
### Formateando Notificaciones de Slack

Si una notificación admite ser enviada como un mensaje de Slack, debes definir un método `toSlack` en la clase de notificación. Este método recibirá una entidad `$notifiable` y debe devolver una instancia de `Illuminate\Notifications\Slack\SlackMessage`. Puedes construir notificaciones enriquecidas utilizando [la API Block Kit de Slack](https://api.slack.com/block-kit). El siguiente ejemplo puede ser visualizado en [el generador de Block Kit de Slack](https://app.slack.com/block-kit-builder/T01KWS6K23Z#%7B%22blocks%22:%5B%7B%22type%22:%22header%22,%22text%22:%7B%22type%22:%22plain_text%22,%22text%22:%22Factura%20Pagada%22%7D%7D,%7B%22type%22:%22context%22,%22elements%22:%5B%7B%22type%22:%22plain_text%22,%22text%22:%22Cliente%20%231234%22%7D%5D%7D,%7B%22type%22:%22section%22,%22text%22:%7B%22type%22:%22plain_text%22,%22text%22:%22Se%20ha%20pagado%20una%20factura.%22%7D,%22fields%22:%5B%7B%22type%22:%22mrkdwn%22,%22text%22:%22*Factura%20No:*%5Cn1000%22%7D,%7B%22type%22:%22mrkdwn%22,%22text%22:%22*Destinatario%20de%20la%20factura:*%5Cntaylor@laravel.com%22%7D%5D%7D,%7B%22type%22:%22divider%22%7D,%7B%22type%22:%22section%22,%22text%22:%7B%22type%22:%22plain_text%22,%22text%22:%22¡Felicidades!%22%7D%7D%5D%7D):


```php
use Illuminate\Notifications\Slack\BlockKit\Blocks\ContextBlock;
use Illuminate\Notifications\Slack\BlockKit\Blocks\SectionBlock;
use Illuminate\Notifications\Slack\BlockKit\Composites\ConfirmObject;
use Illuminate\Notifications\Slack\SlackMessage;

/**
 * Get the Slack representation of the notification.
 */
public function toSlack(object $notifiable): SlackMessage
{
    return (new SlackMessage)
            ->text('One of your invoices has been paid!')
            ->headerBlock('Invoice Paid')
            ->contextBlock(function (ContextBlock $block) {
                $block->text('Customer #1234');
            })
            ->sectionBlock(function (SectionBlock $block) {
                $block->text('An invoice has been paid.');
                $block->field("*Invoice No:*\n1000")->markdown();
                $block->field("*Invoice Recipient:*\ntaylor@laravel.com")->markdown();
            })
            ->dividerBlock()
            ->sectionBlock(function (SectionBlock $block) {
                $block->text('Congratulations!');
            });
}
```

<a name="slack-interactivity"></a>
### Interactividad de Slack

El sistema de notificaciones Block Kit de Slack ofrece potentes características para [manejar la interacción del usuario](https://api.slack.com/interactivity/handling). Para utilizar estas funciones, tu aplicación de Slack debe tener "Interactividad" habilitada y una "URL de solicitud" configurada que apunte a una URL servida por tu aplicación. Estas configuraciones se pueden gestionar desde la pestaña de gestión de aplicaciones "Interactivity & Shortcuts" dentro de Slack.
En el siguiente ejemplo, que utiliza el método `actionsBlock`, Slack enviará una solicitud `POST` a tu "URL de Solicitud" con un payload que contiene el usuario de Slack que hizo clic en el botón, el ID del botón clicado y más. Tu aplicación puede luego determinar la acción a tomar basada en el payload. También deberías [verificar que la solicitud](https://api.slack.com/authentication/verifying-requests-from-slack) fue realizada por Slack:


```php
use Illuminate\Notifications\Slack\BlockKit\Blocks\ActionsBlock;
use Illuminate\Notifications\Slack\BlockKit\Blocks\ContextBlock;
use Illuminate\Notifications\Slack\BlockKit\Blocks\SectionBlock;
use Illuminate\Notifications\Slack\SlackMessage;

/**
 * Get the Slack representation of the notification.
 */
public function toSlack(object $notifiable): SlackMessage
{
    return (new SlackMessage)
            ->text('One of your invoices has been paid!')
            ->headerBlock('Invoice Paid')
            ->contextBlock(function (ContextBlock $block) {
                $block->text('Customer #1234');
            })
            ->sectionBlock(function (SectionBlock $block) {
                $block->text('An invoice has been paid.');
            })
            ->actionsBlock(function (ActionsBlock $block) {
                 // ID defaults to "button_acknowledge_invoice"...
                $block->button('Acknowledge Invoice')->primary();

                // Manually configure the ID...
                $block->button('Deny')->danger()->id('deny_invoice');
            });
}
```

<a name="slack-confirmation-modals"></a>
#### Modales de Confirmación

Si deseas que los usuarios confirmen una acción antes de que se realice, puedes invocar el método `confirm` al definir tu botón. El método `confirm` acepta un mensaje y una función anónima que recibe una instancia de `ConfirmObject`:


```php
use Illuminate\Notifications\Slack\BlockKit\Blocks\ActionsBlock;
use Illuminate\Notifications\Slack\BlockKit\Blocks\ContextBlock;
use Illuminate\Notifications\Slack\BlockKit\Blocks\SectionBlock;
use Illuminate\Notifications\Slack\BlockKit\Composites\ConfirmObject;
use Illuminate\Notifications\Slack\SlackMessage;

/**
 * Get the Slack representation of the notification.
 */
public function toSlack(object $notifiable): SlackMessage
{
    return (new SlackMessage)
            ->text('One of your invoices has been paid!')
            ->headerBlock('Invoice Paid')
            ->contextBlock(function (ContextBlock $block) {
                $block->text('Customer #1234');
            })
            ->sectionBlock(function (SectionBlock $block) {
                $block->text('An invoice has been paid.');
            })
            ->actionsBlock(function (ActionsBlock $block) {
                $block->button('Acknowledge Invoice')
                    ->primary()
                    ->confirm(
                        'Acknowledge the payment and send a thank you email?',
                        function (ConfirmObject $dialog) {
                            $dialog->confirm('Yes');
                            $dialog->deny('No');
                        }
                    );
            });
}
```

<a name="inspecting-slack-blocks"></a>
#### Inspeccionando Bloques de Slack

Si deseas inspeccionar rápidamente los bloques que has estado construyendo, puedes invocar el método `dd` en la instancia de `SlackMessage`. El método `dd` generará y volcará una URL al [Block Kit Builder](https://app.slack.com/block-kit-builder/) de Slack, que muestra una vista previa de la carga útil y la notificación en tu navegador. Puedes pasar `true` al método `dd` para volcar la carga útil en bruto:


```php
return (new SlackMessage)
        ->text('One of your invoices has been paid!')
        ->headerBlock('Invoice Paid')
        ->dd();
```

<a name="routing-slack-notifications"></a>
### Enrutando Notificaciones de Slack

Para dirigir las notificaciones de Slack al equipo y canal de Slack apropiados, define un método `routeNotificationForSlack` en tu modelo notifiable. Este método puede devolver uno de tres valores:
- `null` - lo que diferencia el enrutamiento al canal configurado en la notificación misma. Puedes usar el método `to` al construir tu `SlackMessage` para configurar el canal dentro de la notificación.
- Una cadena que especifica el canal de Slack al que enviar la notificación, por ejemplo, `#support-channel`.
- Una instancia de `SlackRoute`, que te permite especificar un token OAuth y un nombre de canal, por ejemplo, `SlackRoute::make($this->slack_channel, $this->slack_token)`. Este método debe usarse para enviar notificaciones a espacios de trabajo externos.
Por ejemplo, devolver `#support-channel` desde el método `routeNotificationForSlack` enviará la notificación al canal `#support-channel` en el espacio de trabajo asociado con el token OAuth del Bot User ubicado en el archivo de configuración `services.php` de tu aplicación:


```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Notifications\Notification;

class User extends Authenticatable
{
    use Notifiable;

    /**
     * Route notifications for the Slack channel.
     */
    public function routeNotificationForSlack(Notification $notification): mixed
    {
        return '#support-channel';
    }
}
```

<a name="notifying-external-slack-workspaces"></a>
### Notificando Espacios de Trabajo Externos de Slack

> [!NOTE]
Antes de enviar notificaciones a espacios de trabajo de Slack externos, tu aplicación Slack debe ser [distribuida](#slack-app-distribution).
Por supuesto, a menudo querrás enviar notificaciones a los espacios de trabajo de Slack pertenecientes a los usuarios de tu aplicación. Para hacerlo, primero necesitarás obtener un token OAuth de Slack para el usuario. Afortunadamente, [Laravel Socialite](/docs/%7B%7Bversion%7D%7D/socialite) incluye un driver de Slack que te permitirá autenticar fácilmente a los usuarios de tu aplicación con Slack y [obtener un token de bot](/docs/%7B%7Bversion%7D%7D/socialite#slack-bot-scopes).
Una vez que hayas obtenido el token del bot y lo hayas almacenado en la base de datos de tu aplicación, puedes utilizar el método `SlackRoute::make` para enviar una notificación al espacio de trabajo del usuario. Además, tu aplicación probablemente necesitará ofrecer una oportunidad para que el usuario especifique a qué canal se deben enviar las notificaciones:


```php
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
     * Route notifications for the Slack channel.
     */
    public function routeNotificationForSlack(Notification $notification): mixed
    {
        return SlackRoute::make($this->slack_channel, $this->slack_token);
    }
}
```

<a name="localizing-notifications"></a>
## Localizando Notificaciones

Laravel te permite enviar notificaciones en un locale diferente al locale actual de la solicitud HTTP, e incluso recordará este locale si la notificación está en cola.
Para lograr esto, la clase `Illuminate\Notifications\Notification` ofrece un método `locale` para establecer el idioma deseado. La aplicación cambiará a este locale cuando se esté evaluando la notificación y luego revertirá al locale anterior cuando la evaluación esté completa:


```php
$user->notify((new InvoicePaid($invoice))->locale('es'));
```
La localización de múltiples entradas notificables también se puede lograr a través de la fachada `Notification`:


```php
Notification::locale('es')->send(
    $users, new InvoicePaid($invoice)
);
```

<a name="user-preferred-locales"></a>
### Locales Preferidos del Usuario

A veces, las aplicaciones almacenan el locale preferido de cada usuario. Al implementar el contrato `HasLocalePreference` en tu modelo notifiable, puedes instruir a Laravel para que use este locale almacenado al enviar una notificación:


```php
use Illuminate\Contracts\Translation\HasLocalePreference;

class User extends Model implements HasLocalePreference
{
    /**
     * Get the user's preferred locale.
     */
    public function preferredLocale(): string
    {
        return $this->locale;
    }
}
```
Una vez que hayas implementado la interfaz, Laravel utilizará automáticamente el locale preferido al enviar notificaciones y mailables al modelo. Por lo tanto, no es necesario llamar al método `locale` al usar esta interfaz:


```php
$user->notify(new InvoicePaid($invoice));
```

<a name="testing"></a>
## Pruebas

Puedes usar el método `fake` de la facade `Notification` para evitar que se envíen notificaciones. Típicamente, el envío de notificaciones no está relacionado con el código que estás probando. Lo más probable es que sea suficiente simplemente afirmar que Laravel fue instruido para enviar una notificación dada.
Después de llamar al método `fake` de la fachada `Notification`, puedes afirmar que se ordenó el envío de notificaciones a los usuarios e incluso inspeccionar los datos que recibieron las notificaciones:


```php
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


```php
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
Puedes pasar una `función anónima` a los métodos `assertSentTo` o `assertNotSentTo` para afirmar que se envió una notificación que pasa una "prueba de verdad" dada. Si al menos una notificación fue enviada que pasa la prueba de verdad dada, entonces la afirmación será exitosa:


```php
Notification::assertSentTo(
    $user,
    function (OrderShipped $notification, array $channels) use ($order) {
        return $notification->order->id === $order->id;
    }
);
```

<a name="on-demand-notifications"></a>
#### Notificaciones a Pedido

Si el código que estás probando envía [notificaciones bajo demanda](#on-demand-notifications), puedes verificar que la notificación bajo demanda fue enviada a través del método `assertSentOnDemand`:


```php
Notification::assertSentOnDemand(OrderShipped::class);
```
Al pasar una `función anónima` como segundo argumento al método `assertSentOnDemand`, puedes determinar si se envió una notificación bajo demanda a la dirección de "ruta" correcta:


```php
Notification::assertSentOnDemand(
    OrderShipped::class,
    function (OrderShipped $notification, array $channels, object $notifiable) use ($user) {
        return $notifiable->routes['mail'] === $user->email;
    }
);
```

<a name="notification-events"></a>
## Eventos de Notificación


<a name="notification-sending-event"></a>
#### Evento de Envío de Notificación

Cuando se está enviando una notificación, el evento `Illuminate\Notifications\Events\NotificationSending` es despachado por el sistema de notificaciones. Esto contiene la entidad "notificable" y la instancia de la notificación misma. Puedes crear [escuchadores de eventos](/docs/%7B%7Bversion%7D%7D/events) para este evento dentro de tu aplicación:


```php
use Illuminate\Notifications\Events\NotificationSending;

class CheckNotificationStatus
{
    /**
     * Handle the given event.
     */
    public function handle(NotificationSending $event): void
    {
        // ...
    }
}
```
La notificación no se enviará si un listener de eventos para el evento `NotificationSending` devuelve `false` desde su método `handle`:


```php
/**
 * Handle the given event.
 */
public function handle(NotificationSending $event): bool
{
    return false;
}
```
Dentro de un listener de eventos, puedes acceder a las propiedades `notifiable`, `notification` y `channel` en el evento para aprender más sobre el destinatario de la notificación o la notificación en sí:


```php
/**
 * Handle the given event.
 */
public function handle(NotificationSending $event): void
{
    // $event->channel
    // $event->notifiable
    // $event->notification
}
```

<a name="notification-sent-event"></a>
#### Evento de Notificación Enviada

Cuando se envía una notificación, el evento `Illuminate\Notifications\Events\NotificationSent` [event](/docs/%7B%7Bversion%7D%7D/events) es despachado por el sistema de notificaciones. Esto contiene la entidad "notificable" y la instancia de notificación en sí. Puedes crear [escuchas de eventos](/docs/%7B%7Bversion%7D%7D/events) para este evento dentro de tu aplicación:


```php
use Illuminate\Notifications\Events\NotificationSent;

class LogNotification
{
    /**
     * Handle the given event.
     */
    public function handle(NotificationSent $event): void
    {
        // ...
    }
}
```
Dentro de un listener de eventos, puedes acceder a las propiedades `notifiable`, `notification`, `channel` y `response` en el evento para saber más sobre el destinatario de la notificación o la notificación misma:


```php
/**
 * Handle the given event.
 */
public function handle(NotificationSent $event): void
{
    // $event->channel
    // $event->notifiable
    // $event->notification
    // $event->response
}
```

<a name="custom-channels"></a>
## Canales Personalizados

Laravel viene con un puñado de canales de notificación, pero es posible que desees escribir tus propios controladores para entregar notificaciones a través de otros canales. Laravel lo hace simple. Para comenzar, define una clase que contenga un método `send`. El método debería recibir dos argumentos: un `$notifiable` y una `$notification`.
Dentro del método `send`, puedes llamar a métodos en la notificación para recuperar un objeto de mensaje que sea entendido por tu canal y luego enviar la notificación a la instancia `$notifiable` como desees:


```php
<?php

namespace App\Notifications;

use Illuminate\Notifications\Notification;

class VoiceChannel
{
    /**
     * Send the given notification.
     */
    public function send(object $notifiable, Notification $notification): void
    {
        $message = $notification->toVoice($notifiable);

        // Send notification to the $notifiable instance...
    }
}
```
Una vez que se haya definido la clase de tu canal de notificación, puedes devolver el nombre de la clase desde el método `via` de cualquiera de tus notificaciones. En este ejemplo, el método `toVoice` de tu notificación puede devolver cualquier objeto que elijas para representar mensajes de voz. Por ejemplo, podrías definir tu propia clase `VoiceMessage` para representar estos mensajes:


```php
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
     */
    public function via(object $notifiable): string
    {
        return VoiceChannel::class;
    }

    /**
     * Get the voice representation of the notification.
     */
    public function toVoice(object $notifiable): VoiceMessage
    {
        // ...
    }
}
```