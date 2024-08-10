# Correo

- [Introducción](#introduction)
    - [Configuración](#configuration)
    - [Requisitos Previos del Controlador](#driver-prerequisites)
    - [Configuración de Failover](#failover-configuration)
    - [Configuración de Round Robin](#round-robin-configuration)
- [Generando Mailables](#generating-mailables)
- [Escribiendo Mailables](#writing-mailables)
    - [Configurando el Remitente](#configuring-the-sender)
    - [Configurando la Vista](#configuring-the-view)
    - [Datos de la Vista](#view-data)
    - [Adjuntos](#attachments)
    - [Adjuntos en Línea](#inline-attachments)
    - [Objetos Adjuntos](#attachable-objects)
    - [Encabezados](#headers)
    - [Etiquetas y Metadatos](#tags-and-metadata)
    - [Personalizando el Mensaje de Symfony](#customizing-the-symfony-message)
- [Mailables en Markdown](#markdown-mailables)
    - [Generando Mailables en Markdown](#generating-markdown-mailables)
    - [Escribiendo Mensajes en Markdown](#writing-markdown-messages)
    - [Personalizando los Componentes](#customizing-the-components)
- [Enviando Correo](#sending-mail)
    - [Cola de Correo](#queueing-mail)
- [Renderizando Mailables](#rendering-mailables)
    - [Previsualizando Mailables en el Navegador](#previewing-mailables-in-the-browser)
- [Localizando Mailables](#localizing-mailables)
- [Pruebas](#testing-mailables)
    - [Probando el Contenido del Mailable](#testing-mailable-content)
    - [Probando el Envío del Mailable](#testing-mailable-sending)
- [Correo y Desarrollo Local](#mail-and-local-development)
- [Eventos](#events)
- [Transportes Personalizados](#custom-transports)
    - [Transportes Adicionales de Symfony](#additional-symfony-transports)

<a name="introduction"></a>
## Introducción

Enviar correos electrónicos no tiene que ser complicado. Laravel proporciona una API de correo limpia y simple impulsada por el popular componente [Symfony Mailer](https://symfony.com/doc/7.0/mailer.html). Laravel y Symfony Mailer proporcionan controladores para enviar correos electrónicos a través de SMTP, Mailgun, Postmark, Resend, Amazon SES y `sendmail`, lo que te permite comenzar rápidamente a enviar correos a través de un servicio local o basado en la nube de tu elección.

<a name="configuration"></a>
### Configuración

Los servicios de correo de Laravel pueden configurarse a través del archivo de configuración `config/mail.php` de tu aplicación. Cada mailer configurado dentro de este archivo puede tener su propia configuración única e incluso su propio "transporte" único, lo que permite que tu aplicación utilice diferentes servicios de correo para enviar ciertos mensajes de correo electrónico. Por ejemplo, tu aplicación podría usar Postmark para enviar correos electrónicos transaccionales mientras usa Amazon SES para enviar correos electrónicos masivos.

Dentro de tu archivo de configuración `mail`, encontrarás un array de configuración `mailers`. Este array contiene una entrada de configuración de muestra para cada uno de los principales controladores / transportes de correo admitidos por Laravel, mientras que el valor de configuración `default` determina qué mailer se utilizará por defecto cuando tu aplicación necesite enviar un mensaje de correo electrónico.

<a name="driver-prerequisites"></a>
### Requisitos Previos del Controlador / Transporte

Los controladores basados en API como Mailgun, Postmark, Resend y MailerSend son a menudo más simples y rápidos que enviar correo a través de servidores SMTP. Siempre que sea posible, recomendamos que utilices uno de estos controladores.

<a name="mailgun-driver"></a>
#### Controlador de Mailgun

Para usar el controlador de Mailgun, instala el transporte Mailgun Mailer de Symfony a través de Composer:

```shell
composer require symfony/mailgun-mailer symfony/http-client
```

A continuación, establece la opción `default` en el archivo de configuración `config/mail.php` de tu aplicación a `mailgun` y agrega el siguiente array de configuración a tu array de `mailers`:

    'mailgun' => [
        'transport' => 'mailgun',
        // 'client' => [
        //     'timeout' => 5,
        // ],
    ],

Después de configurar el mailer predeterminado de tu aplicación, agrega las siguientes opciones a tu archivo de configuración `config/services.php`:

    'mailgun' => [
        'domain' => env('MAILGUN_DOMAIN'),
        'secret' => env('MAILGUN_SECRET'),
        'endpoint' => env('MAILGUN_ENDPOINT', 'api.mailgun.net'),
        'scheme' => 'https',
    ],

Si no estás utilizando la [región de Mailgun](https://documentation.mailgun.com/en/latest/api-intro.html#mailgun-regions) de los Estados Unidos, puedes definir el endpoint de tu región en el archivo de configuración `services`:

    'mailgun' => [
        'domain' => env('MAILGUN_DOMAIN'),
        'secret' => env('MAILGUN_SECRET'),
        'endpoint' => env('MAILGUN_ENDPOINT', 'api.eu.mailgun.net'),
        'scheme' => 'https',
    ],

<a name="postmark-driver"></a>
#### Controlador de Postmark

Para usar el controlador de [Postmark](https://postmarkapp.com/), instala el transporte Postmark Mailer de Symfony a través de Composer:

```shell
composer require symfony/postmark-mailer symfony/http-client
```

A continuación, establece la opción `default` en el archivo de configuración `config/mail.php` de tu aplicación a `postmark`. Después de configurar el mailer predeterminado de tu aplicación, asegúrate de que tu archivo de configuración `config/services.php` contenga las siguientes opciones:

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

Si deseas especificar el flujo de mensajes de Postmark que debe ser utilizado por un mailer dado, puedes agregar la opción de configuración `message_stream_id` al array de configuración del mailer. Este array de configuración se puede encontrar en el archivo de configuración `config/mail.php` de tu aplicación:

    'postmark' => [
        'transport' => 'postmark',
        'message_stream_id' => env('POSTMARK_MESSAGE_STREAM_ID'),
        // 'client' => [
        //     'timeout' => 5,
        // ],
    ],

De esta manera, también puedes configurar múltiples mailers de Postmark con diferentes flujos de mensajes.

<a name="resend-driver"></a>
#### Controlador de Resend

Para usar el controlador de [Resend](https://resend.com/), instala el SDK de PHP de Resend a través de Composer:

```shell
composer require resend/resend-php
```

A continuación, establece la opción `default` en el archivo de configuración `config/mail.php` de tu aplicación a `resend`. Después de configurar el mailer predeterminado de tu aplicación, asegúrate de que tu archivo de configuración `config/services.php` contenga las siguientes opciones:

    'resend' => [
        'key' => env('RESEND_KEY'),
    ],

<a name="ses-driver"></a>
#### Controlador de SES

Para usar el controlador de Amazon SES, primero debes instalar el SDK de Amazon AWS para PHP. Puedes instalar esta biblioteca a través del gestor de paquetes Composer:

```shell
composer require aws/aws-sdk-php
```

A continuación, establece la opción `default` en tu archivo de configuración `config/mail.php` a `ses` y verifica que tu archivo de configuración `config/services.php` contenga las siguientes opciones:

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

Para utilizar [credenciales temporales](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html) de AWS a través de un token de sesión, puedes agregar una clave `token` a la configuración de SES de tu aplicación:

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
        'token' => env('AWS_SESSION_TOKEN'),
    ],

Para interactuar con las [funciones de gestión de suscripciones](https://docs.aws.amazon.com/ses/latest/dg/sending-email-subscription-management.html) de SES, puedes devolver el encabezado `X-Ses-List-Management-Options` en el array devuelto por el método [`headers`](#headers) de un mensaje de correo:

```php
/**
 * Get the message headers.
 */
public function headers(): Headers
{
    return new Headers(
        text: [
            'X-Ses-List-Management-Options' => 'contactListName=MyContactList;topicName=MyTopic',
        ],
    );
}
```

Si deseas definir [opciones adicionales](https://docs.aws.amazon.com/aws-sdk-php/v3/api/api-sesv2-2019-09-27.html#sendemail) que Laravel debe pasar al método `SendEmail` del SDK de AWS al enviar un correo electrónico, puedes definir un array `options` dentro de tu configuración de `ses`:

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
        'options' => [
            'ConfigurationSetName' => 'MyConfigurationSet',
            'EmailTags' => [
                ['Name' => 'foo', 'Value' => 'bar'],
            ],
        ],
    ],

<a name="mailersend-driver"></a>
#### Controlador de MailerSend

[MailerSend](https://www.mailersend.com/), un servicio de correo electrónico y SMS transaccional, mantiene su propio controlador de correo basado en API para Laravel. El paquete que contiene el controlador se puede instalar a través del gestor de paquetes Composer:

```shell
composer require mailersend/laravel-driver
```

Una vez que el paquete esté instalado, agrega la variable de entorno `MAILERSEND_API_KEY` al archivo `.env` de tu aplicación. Además, la variable de entorno `MAIL_MAILER` debe definirse como `mailersend`:

```shell
MAIL_MAILER=mailersend
MAIL_FROM_ADDRESS=app@yourdomain.com
MAIL_FROM_NAME="App Name"

MAILERSEND_API_KEY=your-api-key
```

Finalmente, agrega MailerSend al array de `mailers` en el archivo de configuración `config/mail.php` de tu aplicación:

```php
'mailersend' => [
    'transport' => 'mailersend',
],
```

Para aprender más sobre MailerSend, incluyendo cómo usar plantillas alojadas, consulta la [documentación del controlador de MailerSend](https://github.com/mailersend/mailersend-laravel-driver#usage).

<a name="failover-configuration"></a>
### Configuración de Failover

A veces, un servicio externo que has configurado para enviar el correo de tu aplicación puede estar inactivo. En estos casos, puede ser útil definir una o más configuraciones de entrega de correo de respaldo que se utilizarán en caso de que tu controlador de entrega principal esté inactivo.

Para lograr esto, debes definir un mailer dentro del archivo de configuración `mail` de tu aplicación que utilice el transporte `failover`. El array de configuración para el mailer `failover` de tu aplicación debe contener un array de `mailers` que haga referencia al orden en que se deben elegir los mailers configurados para la entrega:

    'mailers' => [
        'failover' => [
            'transport' => 'failover',
            'mailers' => [
                'postmark',
                'mailgun',
                'sendmail',
            ],
        ],

        // ...
    ],

Una vez que tu mailer de failover ha sido definido, debes establecer este mailer como el mailer predeterminado utilizado por tu aplicación especificando su nombre como el valor de la clave de configuración `default` dentro del archivo de configuración `mail` de tu aplicación:

    'default' => env('MAIL_MAILER', 'failover'),

<a name="round-robin-configuration"></a>
### Configuración de Round Robin

El transporte `roundrobin` te permite distribuir tu carga de trabajo de correo entre múltiples mailers. Para comenzar, define un mailer dentro del archivo de configuración `mail` de tu aplicación que utilice el transporte `roundrobin`. El array de configuración para tu mailer `roundrobin` debe contener un array de `mailers` que haga referencia a qué mailers configurados deben ser utilizados para la entrega:

    'mailers' => [
        'roundrobin' => [
            'transport' => 'roundrobin',
            'mailers' => [
                'ses',
                'postmark',
            ],
        ],

        // ...
    ],

Una vez que tu mailer de round robin ha sido definido, debes establecer este mailer como el mailer predeterminado utilizado por tu aplicación especificando su nombre como el valor de la clave de configuración `default` dentro del archivo de configuración `mail` de tu aplicación:

    'default' => env('MAIL_MAILER', 'roundrobin'),

El transporte round robin selecciona un mailer aleatorio de la lista de mailers configurados y luego cambia al siguiente mailer disponible para cada correo electrónico subsiguiente. En contraste con el transporte `failover`, que ayuda a lograr *[alta disponibilidad](https://en.wikipedia.org/wiki/High_availability)*, el transporte `roundrobin` proporciona *[balanceo de carga](https://en.wikipedia.org/wiki/Load_balancing_(computing))*.

<a name="generating-mailables"></a>
## Generando Mailables

Al construir aplicaciones Laravel, cada tipo de correo electrónico enviado por tu aplicación se representa como una clase "mailable". Estas clases se almacenan en el directorio `app/Mail`. No te preocupes si no ves este directorio en tu aplicación, ya que se generará para ti cuando crees tu primera clase mailable utilizando el comando Artisan `make:mail`:

```shell
php artisan make:mail OrderShipped
```

<a name="writing-mailables"></a>
## Escribiendo Mailables

Una vez que hayas generado una clase mailable, ábrela para que podamos explorar su contenido. La configuración de la clase mailable se realiza en varios métodos, incluidos los métodos `envelope`, `content` y `attachments`.

El método `envelope` devuelve un objeto `Illuminate\Mail\Mailables\Envelope` que define el asunto y, a veces, los destinatarios del mensaje. El método `content` devuelve un objeto `Illuminate\Mail\Mailables\Content` que define la [plantilla Blade](/docs/{{version}}/blade) que se utilizará para generar el contenido del mensaje.

<a name="configuring-the-sender"></a>
### Configurando el Remitente

<a name="using-the-envelope"></a>
#### Usando el Sobre

Primero, exploremos la configuración del remitente del correo electrónico. O, en otras palabras, de quién será el correo electrónico. Hay dos formas de configurar el remitente. Primero, puedes especificar la dirección "from" en el sobre de tu mensaje:

    use Illuminate\Mail\Mailables\Address;
    use Illuminate\Mail\Mailables\Envelope;

    /**
     * Obtener el sobre del mensaje.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            from: new Address('jeffrey@example.com', 'Jeffrey Way'),
            subject: 'Pedido Enviado',
        );
    }

Si lo deseas, también puedes especificar una dirección `replyTo`:

    return new Envelope(
        from: new Address('jeffrey@example.com', 'Jeffrey Way'),
        replyTo: [
            new Address('taylor@example.com', 'Taylor Otwell'),
        ],
        subject: 'Pedido Enviado',
    );

<a name="using-a-global-from-address"></a>
#### Usando una Dirección `from` Global

Sin embargo, si tu aplicación utiliza la misma dirección "from" para todos sus correos electrónicos, puede volverse engorroso agregarla a cada clase mailable que generes. En su lugar, puedes especificar una dirección "from" global en tu archivo de configuración `config/mail.php`. Esta dirección se utilizará si no se especifica ninguna otra dirección "from" dentro de la clase mailable:

    'from' => [
        'address' => env('MAIL_FROM_ADDRESS', 'hello@example.com'),
        'name' => env('MAIL_FROM_NAME', 'Ejemplo'),
    ],

Además, puedes definir una dirección "reply_to" global dentro de tu archivo de configuración `config/mail.php`:

    'reply_to' => ['address' => 'example@example.com', 'name' => 'Nombre de la App'],

<a name="configuring-the-view"></a>
### Configurando la Vista

Dentro del método `content` de una clase mailable, puedes definir la `view`, o qué plantilla debe utilizarse al renderizar el contenido del correo electrónico. Dado que cada correo electrónico utiliza típicamente una [plantilla Blade](/docs/{{version}}/blade) para renderizar su contenido, tienes todo el poder y la conveniencia del motor de plantillas Blade al construir el HTML de tu correo electrónico:

    /**
     * Obtener la definición del contenido del mensaje.
     */
    public function content(): Content
    {
        return new Content(
            view: 'mail.orders.shipped',
        );
    }

> [!NOTE]  
> Es posible que desees crear un directorio `resources/views/emails` para albergar todas tus plantillas de correo electrónico; sin embargo, eres libre de colocarlas donde desees dentro de tu directorio `resources/views`.

<a name="plain-text-emails"></a>
#### Correos Electrónicos en Texto Plano

Si deseas definir una versión en texto plano de tu correo electrónico, puedes especificar la plantilla de texto plano al crear la definición de `Content` del mensaje. Al igual que el parámetro `view`, el parámetro `text` debe ser un nombre de plantilla que se utilizará para renderizar el contenido del correo electrónico. Eres libre de definir tanto una versión HTML como una versión en texto plano de tu mensaje:

```php
    /**
     * Obtener la definición del contenido del mensaje.
     */
    public function content(): Content
    {
        return new Content(
            view: 'mail.orders.shipped',
            text: 'mail.orders.shipped-text'
        );
    }

Para mayor claridad, el parámetro `html` puede usarse como un alias del parámetro `view`:

    return new Content(
        html: 'mail.orders.shipped',
        text: 'mail.orders.shipped-text'
    );

<a name="view-data"></a>
### Datos de la Vista

<a name="via-public-properties"></a>
#### A través de Propiedades Públicas

Típicamente, querrás pasar algunos datos a tu vista que puedas utilizar al renderizar el HTML del correo electrónico. Hay dos formas en que puedes hacer que los datos estén disponibles para tu vista. Primero, cualquier propiedad pública definida en tu clase mailable estará automáticamente disponible para la vista. Así que, por ejemplo, puedes pasar datos al constructor de tu clase mailable y establecer esos datos en propiedades públicas definidas en la clase:

    <?php

    namespace App\Mail;

    use App\Models\Order;
    use Illuminate\Bus\Queueable;
    use Illuminate\Mail\Mailable;
    use Illuminate\Mail\Mailables\Content;
    use Illuminate\Queue\SerializesModels;

    class OrderShipped extends Mailable
    {
        use Queueable, SerializesModels;

        /**
         * Crear una nueva instancia de mensaje.
         */
        public function __construct(
            public Order $order,
        ) {}

        /**
         * Obtener la definición del contenido del mensaje.
         */
        public function content(): Content
        {
            return new Content(
                view: 'mail.orders.shipped',
            );
        }
    }

Una vez que los datos se han establecido en una propiedad pública, estarán automáticamente disponibles en tu vista, por lo que puedes acceder a ellos como accederías a cualquier otro dato en tus plantillas Blade:

    <div>
        Precio: {{ $order->price }}
    </div>

<a name="via-the-with-parameter"></a>
#### A través del Parámetro `with`:

Si deseas personalizar el formato de los datos de tu correo electrónico antes de que se envíen a la plantilla, puedes pasar manualmente tus datos a la vista a través del parámetro `with` de la definición de `Content`. Típicamente, aún pasarás datos a través del constructor de la clase mailable; sin embargo, deberías establecer estos datos en propiedades `protected` o `private` para que los datos no estén automáticamente disponibles para la plantilla:

    <?php

    namespace App\Mail;

    use App\Models\Order;
    use Illuminate\Bus\Queueable;
    use Illuminate\Mail\Mailable;
    use Illuminate\Mail\Mailables\Content;
    use Illuminate\Queue\SerializesModels;

    class OrderShipped extends Mailable
    {
        use Queueable, SerializesModels;

        /**
         * Crear una nueva instancia de mensaje.
         */
        public function __construct(
            protected Order $order,
        ) {}

        /**
         * Obtener la definición del contenido del mensaje.
         */
        public function content(): Content
        {
            return new Content(
                view: 'mail.orders.shipped',
                with: [
                    'orderName' => $this->order->name,
                    'orderPrice' => $this->order->price,
                ],
            );
        }
    }

Una vez que los datos se han pasado al método `with`, estarán automáticamente disponibles en tu vista, por lo que puedes acceder a ellos como accederías a cualquier otro dato en tus plantillas Blade:

    <div>
        Precio: {{ $orderPrice }}
    </div>

<a name="attachments"></a>
### Adjuntos

Para agregar adjuntos a un correo electrónico, agregarás adjuntos al array devuelto por el método `attachments` del mensaje. Primero, puedes agregar un adjunto proporcionando una ruta de archivo al método `fromPath` proporcionado por la clase `Attachment`:

    use Illuminate\Mail\Mailables\Attachment;

    /**
     * Obtener los adjuntos para el mensaje.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromPath('/path/to/file'),
        ];
    }

Al adjuntar archivos a un mensaje, también puedes especificar el nombre de visualización y/o el tipo MIME para el adjunto utilizando los métodos `as` y `withMime`:

    /**
     * Obtener los adjuntos para el mensaje.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromPath('/path/to/file')
                    ->as('name.pdf')
                    ->withMime('application/pdf'),
        ];
    }

<a name="attaching-files-from-disk"></a>
#### Adjuntando Archivos Desde el Disco

Si has almacenado un archivo en uno de tus [discos de sistema de archivos](/docs/{{version}}/filesystem), puedes adjuntarlo al correo electrónico utilizando el método de adjunto `fromStorage`:

    /**
     * Obtener los adjuntos para el mensaje.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromStorage('/path/to/file'),
        ];
    }

Por supuesto, también puedes especificar el nombre y el tipo MIME del adjunto:

    /**
     * Obtener los adjuntos para el mensaje.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromStorage('/path/to/file')
                    ->as('name.pdf')
                    ->withMime('application/pdf'),
        ];
    }

El método `fromStorageDisk` puede usarse si necesitas especificar un disco de almacenamiento diferente al disco predeterminado:

    /**
     * Obtener los adjuntos para el mensaje.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromStorageDisk('s3', '/path/to/file')
                    ->as('name.pdf')
                    ->withMime('application/pdf'),
        ];
    }

<a name="raw-data-attachments"></a>
#### Adjuntos de Datos en Crudo

El método de adjunto `fromData` puede usarse para adjuntar una cadena de bytes en crudo como un adjunto. Por ejemplo, podrías usar este método si has generado un PDF en memoria y deseas adjuntarlo al correo electrónico sin escribirlo en disco. El método `fromData` acepta una función anónima que resuelve los bytes de datos en crudo, así como el nombre que se debe asignar al adjunto:

    /**
     * Obtener los adjuntos para el mensaje.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromData(fn () => $this->pdf, 'Report.pdf')
                    ->withMime('application/pdf'),
        ];
    }

<a name="inline-attachments"></a>
### Adjuntos en Línea

Incrustar imágenes en línea en tus correos electrónicos es típicamente complicado; sin embargo, Laravel proporciona una forma conveniente de adjuntar imágenes a tus correos electrónicos. Para incrustar una imagen en línea, utiliza el método `embed` en la variable `$message` dentro de tu plantilla de correo electrónico. Laravel hace que la variable `$message` esté automáticamente disponible para todas tus plantillas de correo electrónico, por lo que no necesitas preocuparte por pasarla manualmente:

```blade
<body>
    Here is an image:

    <img src="{{ $message->embed($pathToImage) }}">
</body>
```

> [!WARNING]  
> La variable `$message` no está disponible en las plantillas de mensajes de texto plano, ya que los mensajes de texto plano no utilizan adjuntos en línea.

<a name="embedding-raw-data-attachments"></a>
#### Incrustando Adjuntos de Datos en Crudo

Si ya tienes una cadena de datos de imagen en crudo que deseas incrustar en una plantilla de correo electrónico, puedes llamar al método `embedData` en la variable `$message`. Al llamar al método `embedData`, necesitarás proporcionar un nombre de archivo que se debe asignar a la imagen incrustada:

```blade
<body>
    Here is an image from raw data:

    <img src="{{ $message->embedData($data, 'example-image.jpg') }}">
</body>
```

<a name="attachable-objects"></a>
### Objetos Adjuntables

Si bien adjuntar archivos a mensajes a través de rutas de cadena simples es a menudo suficiente, en muchos casos las entidades adjuntables dentro de tu aplicación están representadas por clases. Por ejemplo, si tu aplicación está adjuntando una foto a un mensaje, tu aplicación también puede tener un modelo `Photo` que representa esa foto. Cuando ese es el caso, ¿no sería conveniente simplemente pasar el modelo `Photo` al método `attach`? Los objetos adjuntables te permiten hacer precisamente eso.

Para comenzar, implementa la interfaz `Illuminate\Contracts\Mail\Attachable` en el objeto que será adjuntable a los mensajes. Esta interfaz dicta que tu clase define un método `toMailAttachment` que devuelve una instancia de `Illuminate\Mail\Attachment`:

    <?php

    namespace App\Models;

    use Illuminate\Contracts\Mail\Attachable;
    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Mail\Attachment;

    class Photo extends Model implements Attachable
    {
        /**
         * Obtener la representación adjuntable del modelo.
         */
        public function toMailAttachment(): Attachment
        {
            return Attachment::fromPath('/path/to/file');
        }
    }

Una vez que hayas definido tu objeto adjuntable, puedes devolver una instancia de ese objeto desde el método `attachments` al construir un mensaje de correo electrónico:

    /**
     * Obtener los adjuntos para el mensaje.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [$this->photo];
    }

Por supuesto, los datos de los adjuntos pueden almacenarse en un servicio de almacenamiento de archivos remoto como Amazon S3. Así que, Laravel también te permite generar instancias de adjuntos a partir de datos que están almacenados en uno de tus [discos de sistema de archivos](/docs/{{version}}/filesystem):

    // Crear un adjunto a partir de un archivo en tu disco predeterminado...
    return Attachment::fromStorage($this->path);

    // Crear un adjunto a partir de un archivo en un disco específico...
    return Attachment::fromStorageDisk('backblaze', $this->path);

Además, puedes crear instancias de adjuntos a través de datos que tienes en memoria. Para lograr esto, proporciona una función anónima al método `fromData`. La función anónima debe devolver los datos en crudo que representan el adjunto:

    return Attachment::fromData(fn () => $this->content, 'Photo Name');

Laravel también proporciona métodos adicionales que puedes usar para personalizar tus adjuntos. Por ejemplo, puedes usar los métodos `as` y `withMime` para personalizar el nombre del archivo y el tipo MIME:

    return Attachment::fromPath('/path/to/file')
            ->as('Photo Name')
            ->withMime('image/jpeg');

<a name="headers"></a>
### Encabezados

A veces, es posible que necesites adjuntar encabezados adicionales al mensaje saliente. Por ejemplo, es posible que necesites establecer un `Message-Id` personalizado u otros encabezados de texto arbitrarios.

Para lograr esto, define un método `headers` en tu mailable. El método `headers` debe devolver una instancia de `Illuminate\Mail\Mailables\Headers`. Esta clase acepta parámetros `messageId`, `references` y `text`. Por supuesto, puedes proporcionar solo los parámetros que necesites para tu mensaje particular:

    use Illuminate\Mail\Mailables\Headers;

    /**
     * Obtener los encabezados del mensaje.
     */
    public function headers(): Headers
    {
        return new Headers(
            messageId: 'custom-message-id@example.com',
            references: ['previous-message@example.com'],
            text: [
                'X-Custom-Header' => 'Custom Value',
            ],
        );
    }

<a name="tags-and-metadata"></a>
### Etiquetas y Metadatos

Algunos proveedores de correo electrónico de terceros como Mailgun y Postmark admiten "etiquetas" y "metadatos" de mensajes, que pueden usarse para agrupar y rastrear correos electrónicos enviados por tu aplicación. Puedes agregar etiquetas y metadatos a un mensaje de correo electrónico a través de tu definición de `Envelope`:

    use Illuminate\Mail\Mailables\Envelope;

    /**
     * Obtener el sobre del mensaje.
     *
     * @return \Illuminate\Mail\Mailables\Envelope
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Orden Enviada',
            tags: ['shipment'],
            metadata: [
                'order_id' => $this->order->id,
            ],
        );
    }

Si tu aplicación está utilizando el controlador de Mailgun, puedes consultar la documentación de Mailgun para obtener más información sobre [etiquetas](https://documentation.mailgun.com/en/latest/user_manual.html#tagging-1) y [metadatos](https://documentation.mailgun.com/en/latest/user_manual.html#attaching-data-to-messages). Asimismo, la documentación de Postmark también puede consultarse para obtener más información sobre su soporte para [etiquetas](https://postmarkapp.com/blog/tags-support-for-smtp) y [metadatos](https://postmarkapp.com/support/article/1125-custom-metadata-faq).

Si tu aplicación está utilizando Amazon SES para enviar correos electrónicos, debes usar el método `metadata` para adjuntar [etiquetas "SES"](https://docs.aws.amazon.com/ses/latest/APIReference/API_MessageTag.html) al mensaje.

<a name="customizing-the-symfony-message"></a>
### Personalizando el Mensaje de Symfony

Las capacidades de correo de Laravel están impulsadas por Symfony Mailer. Laravel te permite registrar callbacks personalizados que se invocarán con la instancia de Mensaje de Symfony antes de enviar el mensaje. Esto te brinda la oportunidad de personalizar profundamente el mensaje antes de que se envíe. Para lograr esto, define un parámetro `using` en tu definición de `Envelope`:

    use Illuminate\Mail\Mailables\Envelope;
    use Symfony\Component\Mime\Email;

    /**
     * Obtener el sobre del mensaje.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Orden Enviada',
            using: [
                function (Email $message) {
                    // ...
                },
            ]
        );
    }

<a name="markdown-mailables"></a>
## Markdown Mailables

Los mensajes de correo electrónico en Markdown te permiten aprovechar las plantillas y componentes preconstruidos de [notificaciones de correo](/docs/{{version}}/notifications#mail-notifications) en tus mailables. Dado que los mensajes están escritos en Markdown, Laravel puede renderizar hermosas plantillas HTML responsivas para los mensajes mientras también genera automáticamente un contraparte en texto plano.

<a name="generating-markdown-mailables"></a>
### Generando Markdown Mailables

Para generar un mailable con una plantilla Markdown correspondiente, puedes usar la opción `--markdown` del comando Artisan `make:mail`:

```shell
php artisan make:mail OrderShipped --markdown=mail.orders.shipped
```

Luego, al configurar la definición de `Content` del mailable dentro de su método `content`, utiliza el parámetro `markdown` en lugar del parámetro `view`:

    use Illuminate\Mail\Mailables\Content;

    /**
     * Obtener la definición del contenido del mensaje.
     */
    public function content(): Content
    {
        return new Content(
            markdown: 'mail.orders.shipped',
            with: [
                'url' => $this->orderUrl,
            ],
        );
    }

<a name="writing-markdown-messages"></a>
### Escribiendo Mensajes en Markdown

Los mailables en Markdown utilizan una combinación de componentes Blade y sintaxis Markdown que te permiten construir fácilmente mensajes de correo mientras aprovechas los componentes de interfaz de usuario de correo electrónico preconstruidos de Laravel:

```blade
<x-mail::message>
# Order Shipped

Your order has been shipped!

<x-mail::button :url="$url">
View Order
</x-mail::button>

Thanks,<br>
{{ config('app.name') }}
</x-mail::message>
```

> [!NOTE]  
> No uses una indentación excesiva al escribir correos electrónicos en Markdown. Según los estándares de Markdown, los analizadores de Markdown renderizarán el contenido indentado como bloques de código.

<a name="button-component"></a>
#### Componente de Botón

El componente de botón renderiza un enlace de botón centrado. El componente acepta dos argumentos, una `url` y un `color` opcional. Los colores admitidos son `primary`, `success` y `error`. Puedes agregar tantos componentes de botón a un mensaje como desees:


```blade
<x-mail::button :url="$url" color="success">
Ver Pedido
</x-mail::button>
```

<a name="panel-component"></a>
#### Componente de Panel

El componente de panel renderiza el bloque de texto dado en un panel que tiene un color de fondo ligeramente diferente al del resto del mensaje. Esto te permite llamar la atención sobre un bloque de texto específico:

```blade
<x-mail::panel>
Este es el contenido del panel.
</x-mail::panel>
```

<a name="table-component"></a>
#### Componente de Tabla

El componente de tabla te permite transformar una tabla de Markdown en una tabla HTML. El componente acepta la tabla de Markdown como su contenido. La alineación de las columnas de la tabla es compatible utilizando la sintaxis de alineación de tablas de Markdown por defecto:

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

Puedes exportar todos los componentes de correo de Markdown a tu propia aplicación para personalizarlos. Para exportar los componentes, utiliza el comando Artisan `vendor:publish` para publicar la etiqueta de activo `laravel-mail`:

```shell
php artisan vendor:publish --tag=laravel-mail
```

Este comando publicará los componentes de correo de Markdown en el directorio `resources/views/vendor/mail`. El directorio `mail` contendrá un directorio `html` y un directorio `text`, cada uno conteniendo sus respectivas representaciones de cada componente disponible. Eres libre de personalizar estos componentes como desees.

<a name="customizing-the-css"></a>
#### Personalizando el CSS

Después de exportar los componentes, el directorio `resources/views/vendor/mail/html/themes` contendrá un archivo `default.css`. Puedes personalizar el CSS en este archivo y tus estilos se convertirán automáticamente en estilos CSS en línea dentro de las representaciones HTML de tus mensajes de correo de Markdown.

Si deseas construir un tema completamente nuevo para los componentes de Markdown de Laravel, puedes colocar un archivo CSS dentro del directorio `html/themes`. Después de nombrar y guardar tu archivo CSS, actualiza la opción `theme` del archivo de configuración `config/mail.php` de tu aplicación para que coincida con el nombre de tu nuevo tema.

Para personalizar el tema de un mailable individual, puedes establecer la propiedad `$theme` de la clase mailable al nombre del tema que debe usarse al enviar ese mailable.

<a name="sending-mail"></a>
## Enviando Correo

Para enviar un mensaje, utiliza el método `to` en el `Mail` [facade](/docs/{{version}}/facades). El método `to` acepta una dirección de correo electrónico, una instancia de usuario o una colección de usuarios. Si pasas un objeto o colección de objetos, el correo utilizará automáticamente sus propiedades `email` y `name` al determinar los destinatarios del correo, así que asegúrate de que estos atributos estén disponibles en tus objetos. Una vez que hayas especificado tus destinatarios, puedes pasar una instancia de tu clase mailable al método `send`:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Mail\OrderShipped;
    use App\Models\Order;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Mail;

    class OrderShipmentController extends Controller
    {
        /**
         * Enviar el pedido dado.
         */
        public function store(Request $request): RedirectResponse
        {
            $order = Order::findOrFail($request->order_id);

            // Enviar el pedido...

            Mail::to($request->user())->send(new OrderShipped($order));

            return redirect('/orders');
        }
    }

No estás limitado a solo especificar los destinatarios "to" al enviar un mensaje. Eres libre de establecer destinatarios "to", "cc" y "bcc" encadenando sus respectivos métodos juntos:

    Mail::to($request->user())
        ->cc($moreUsers)
        ->bcc($evenMoreUsers)
        ->send(new OrderShipped($order));

<a name="looping-over-recipients"></a>
#### Iterando sobre Destinatarios

Ocasionalmente, puede que necesites enviar un mailable a una lista de destinatarios iterando sobre un array de destinatarios / direcciones de correo electrónico. Sin embargo, dado que el método `to` agrega direcciones de correo electrónico a la lista de destinatarios del mailable, cada iteración a través del bucle enviará otro correo a cada destinatario anterior. Por lo tanto, siempre debes recrear la instancia del mailable para cada destinatario:

    foreach (['taylor@example.com', 'dries@example.com'] as $recipient) {
        Mail::to($recipient)->send(new OrderShipped($order));
    }

<a name="sending-mail-via-a-specific-mailer"></a>
#### Enviando Correo a través de un Mailer Específico

Por defecto, Laravel enviará correos utilizando el mailer configurado como el mailer `default` en el archivo de configuración `mail` de tu aplicación. Sin embargo, puedes usar el método `mailer` para enviar un mensaje utilizando una configuración de mailer específica:

    Mail::mailer('postmark')
            ->to($request->user())
            ->send(new OrderShipped($order));

<a name="queueing-mail"></a>
### Enviando Correo en Cola

<a name="queueing-a-mail-message"></a>
#### Enviando un Mensaje de Correo en Cola

Dado que enviar mensajes de correo puede afectar negativamente el tiempo de respuesta de tu aplicación, muchos desarrolladores eligen poner en cola los mensajes de correo para enviarlos en segundo plano. Laravel facilita esto utilizando su [API de cola unificada](/docs/{{version}}/queues). Para poner en cola un mensaje de correo, utiliza el método `queue` en el `Mail` facade después de especificar los destinatarios del mensaje:

    Mail::to($request->user())
        ->cc($moreUsers)
        ->bcc($evenMoreUsers)
        ->queue(new OrderShipped($order));

Este método se encargará automáticamente de agregar un trabajo a la cola para que el mensaje se envíe en segundo plano. Necesitarás [configurar tus colas](/docs/{{version}}/queues) antes de usar esta función.

<a name="delayed-message-queueing"></a>
#### Envío de Mensajes en Cola con Retraso

Si deseas retrasar la entrega de un mensaje de correo en cola, puedes usar el método `later`. Como su primer argumento, el método `later` acepta una instancia de `DateTime` que indica cuándo debe enviarse el mensaje:

    Mail::to($request->user())
        ->cc($moreUsers)
        ->bcc($evenMoreUsers)
        ->later(now()->addMinutes(10), new OrderShipped($order));

<a name="pushing-to-specific-queues"></a>
#### Enviando a Colas Específicas

Dado que todas las clases mailable generadas utilizando el comando `make:mail` hacen uso del trait `Illuminate\Bus\Queueable`, puedes llamar a los métodos `onQueue` y `onConnection` en cualquier instancia de clase mailable, lo que te permite especificar la conexión y el nombre de la cola para el mensaje:

    $message = (new OrderShipped($order))
                    ->onConnection('sqs')
                    ->onQueue('emails');

    Mail::to($request->user())
        ->cc($moreUsers)
        ->bcc($evenMoreUsers)
        ->queue($message);

<a name="queueing-by-default"></a>
#### Enviando en Cola por Defecto

Si tienes clases mailable que deseas que siempre se envíen en cola, puedes implementar el contrato `ShouldQueue` en la clase. Ahora, incluso si llamas al método `send` al enviar, el mailable seguirá siendo enviado en cola ya que implementa el contrato:

    use Illuminate\Contracts\Queue\ShouldQueue;

    class OrderShipped extends Mailable implements ShouldQueue
    {
        // ...
    }

<a name="queued-mailables-and-database-transactions"></a>
#### Mailables en Cola y Transacciones de Base de Datos

Cuando los mailables en cola se envían dentro de transacciones de base de datos, pueden ser procesados por la cola antes de que la transacción de base de datos se haya confirmado. Cuando esto sucede, cualquier actualización que hayas realizado en modelos o registros de base de datos durante la transacción de base de datos puede no estar reflejada en la base de datos. Además, cualquier modelo o registro de base de datos creado dentro de la transacción puede no existir en la base de datos. Si tu mailable depende de estos modelos, pueden ocurrir errores inesperados cuando se procese el trabajo que envía el mailable en cola.

Si la opción de configuración `after_commit` de tu conexión de cola está establecida en `false`, aún puedes indicar que un mailable en cola particular debe ser enviado después de que todas las transacciones de base de datos abiertas se hayan confirmado llamando al método `afterCommit` al enviar el mensaje de correo:

    Mail::to($request->user())->send(
        (new OrderShipped($order))->afterCommit()
    );

Alternativamente, puedes llamar al método `afterCommit` desde el constructor de tu mailable:

    <?php

    namespace App\Mail;

    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Mail\Mailable;
    use Illuminate\Queue\SerializesModels;

    class OrderShipped extends Mailable implements ShouldQueue
    {
        use Queueable, SerializesModels;

        /**
         * Crear una nueva instancia de mensaje.
         */
        public function __construct()
        {
            $this->afterCommit();
        }
    }

> [!NOTE]  
> Para aprender más sobre cómo solucionar estos problemas, revisa la documentación sobre [trabajos en cola y transacciones de base de datos](/docs/{{version}}/queues#jobs-and-database-transactions).

<a name="rendering-mailables"></a>
## Renderizando Mailables

A veces, puedes desear capturar el contenido HTML de un mailable sin enviarlo. Para lograr esto, puedes llamar al método `render` del mailable. Este método devolverá el contenido HTML evaluado del mailable como una cadena:

    use App\Mail\InvoicePaid;
    use App\Models\Invoice;

    $invoice = Invoice::find(1);

    return (new InvoicePaid($invoice))->render();

<a name="previewing-mailables-in-the-browser"></a>
### Previsualizando Mailables en el Navegador

Al diseñar la plantilla de un mailable, es conveniente previsualizar rápidamente el mailable renderizado en tu navegador como una plantilla Blade típica. Por esta razón, Laravel te permite devolver cualquier mailable directamente desde una función de ruta o controlador. Cuando se devuelve un mailable, se renderizará y se mostrará en el navegador, permitiéndote previsualizar rápidamente su diseño sin necesidad de enviarlo a una dirección de correo electrónico real:

    Route::get('/mailable', function () {
        $invoice = App\Models\Invoice::find(1);

        return new App\Mail\InvoicePaid($invoice);
    });

<a name="localizing-mailables"></a>
## Localizando Mailables

Laravel te permite enviar mailables en un idioma diferente al idioma actual de la solicitud, e incluso recordará este idioma si el correo está en cola.

Para lograr esto, el `Mail` facade ofrece un método `locale` para establecer el idioma deseado. La aplicación cambiará a este idioma cuando se evalúe la plantilla del mailable y luego volverá al idioma anterior cuando la evaluación esté completa:

    Mail::to($request->user())->locale('es')->send(
        new OrderShipped($order)
    );

<a name="user-preferred-locales"></a>
### Idiomas Preferidos por el Usuario

A veces, las aplicaciones almacenan el idioma preferido de cada usuario. Al implementar el contrato `HasLocalePreference` en uno o más de tus modelos, puedes instruir a Laravel para que use este idioma almacenado al enviar correos:

    use Illuminate\Contracts\Translation\HasLocalePreference;

    class User extends Model implements HasLocalePreference
    {
        /**
         * Obtener el idioma preferido del usuario.
         */
        public function preferredLocale(): string
        {
            return $this->locale;
        }
    }

Una vez que hayas implementado la interfaz, Laravel utilizará automáticamente el idioma preferido al enviar mailables y notificaciones al modelo. Por lo tanto, no es necesario llamar al método `locale` al usar esta interfaz:

    Mail::to($request->user())->send(new OrderShipped($order));

<a name="testing-mailables"></a>
## Pruebas

<a name="testing-mailable-content"></a>
### Probando el Contenido del Mailable

Laravel proporciona una variedad de métodos para inspeccionar la estructura de tu mailable. Además, Laravel proporciona varios métodos convenientes para probar que tu mailable contiene el contenido que esperas. Estos métodos son: `assertSeeInHtml`, `assertDontSeeInHtml`, `assertSeeInOrderInHtml`, `assertSeeInText`, `assertDontSeeInText`, `assertSeeInOrderInText`, `assertHasAttachment`, `assertHasAttachedData`, `assertHasAttachmentFromStorage`, y `assertHasAttachmentFromStorageDisk`.

Como puedes esperar, las afirmaciones "HTML" afirman que la versión HTML de tu mailable contiene una cadena dada, mientras que las afirmaciones "texto" afirman que la versión de texto plano de tu mailable contiene una cadena dada:

```php tab=Pest
use App\Mail\InvoicePaid;
use App\Models\User;

test('mailable content', function () {
    $user = User::factory()->create();

    $mailable = new InvoicePaid($user);

    $mailable->assertFrom('jeffrey@example.com');
    $mailable->assertTo('taylor@example.com');
    $mailable->assertHasCc('abigail@example.com');
    $mailable->assertHasBcc('victoria@example.com');
    $mailable->assertHasReplyTo('tyler@example.com');
    $mailable->assertHasSubject('Invoice Paid');
    $mailable->assertHasTag('example-tag');
    $mailable->assertHasMetadata('key', 'value');

    $mailable->assertSeeInHtml($user->email);
    $mailable->assertSeeInHtml('Invoice Paid');
    $mailable->assertSeeInOrderInHtml(['Invoice Paid', 'Thanks']);

    $mailable->assertSeeInText($user->email);
    $mailable->assertSeeInOrderInText(['Invoice Paid', 'Thanks']);

    $mailable->assertHasAttachment('/path/to/file');
    $mailable->assertHasAttachment(Attachment::fromPath('/path/to/file'));
    $mailable->assertHasAttachedData($pdfData, 'name.pdf', ['mime' => 'application/pdf']);
    $mailable->assertHasAttachmentFromStorage('/path/to/file', 'name.pdf', ['mime' => 'application/pdf']);
    $mailable->assertHasAttachmentFromStorageDisk('s3', '/path/to/file', 'name.pdf', ['mime' => 'application/pdf']);
});
```

```php tab=PHPUnit
use App\Mail\InvoicePaid;
use App\Models\User;

public function test_mailable_content(): void
{
    $user = User::factory()->create();

    $mailable = new InvoicePaid($user);

    $mailable->assertFrom('jeffrey@example.com');
    $mailable->assertTo('taylor@example.com');
    $mailable->assertHasCc('abigail@example.com');
    $mailable->assertHasBcc('victoria@example.com');
    $mailable->assertHasReplyTo('tyler@example.com');
    $mailable->assertHasSubject('Invoice Paid');
    $mailable->assertHasTag('example-tag');
    $mailable->assertHasMetadata('key', 'value');

    $mailable->assertSeeInHtml($user->email);
    $mailable->assertSeeInHtml('Invoice Paid');
    $mailable->assertSeeInOrderInHtml(['Invoice Paid', 'Thanks']);

    $mailable->assertSeeInText($user->email);
    $mailable->assertSeeInOrderInText(['Invoice Paid', 'Thanks']);

    $mailable->assertHasAttachment('/path/to/file');
    $mailable->assertHasAttachment(Attachment::fromPath('/path/to/file'));
    $mailable->assertHasAttachedData($pdfData, 'name.pdf', ['mime' => 'application/pdf']);
    $mailable->assertHasAttachmentFromStorage('/path/to/file', 'name.pdf', ['mime' => 'application/pdf']);
    $mailable->assertHasAttachmentFromStorageDisk('s3', '/path/to/file', 'name.pdf', ['mime' => 'application/pdf']);
}
```

<a name="testing-mailable-sending"></a>
### Probando el Envío del Mailable

Sugerimos probar el contenido de tus mailables por separado de tus pruebas que afirman que un mailable dado fue "enviado" a un usuario específico. Típicamente, el contenido de los mailables no es relevante para el código que estás probando, y es suficiente simplemente afirmar que Laravel fue instruido para enviar un mailable dado.

Puedes usar el método `fake` del facade `Mail` para evitar que se envíen correos. Después de llamar al método `fake` del facade `Mail`, puedes afirmar que los mailables fueron instruidos para ser enviados a los usuarios e incluso inspeccionar los datos que recibieron los mailables:

```php tab=Pest
<?php

use App\Mail\OrderShipped;
use Illuminate\Support\Facades\Mail;

test('orders can be shipped', function () {
    Mail::fake();

    // Perform order shipping...

    // Assert that no mailables were sent...
    Mail::assertNothingSent();

    // Assert that a mailable was sent...
    Mail::assertSent(OrderShipped::class);

    // Assert a mailable was sent twice...
    Mail::assertSent(OrderShipped::class, 2);

    // Assert a mailable was sent to an email address...
    Mail::assertSent(OrderShipped::class, 'example@laravel.com');

    // Assert a mailable was sent to multiple email addresses...
    Mail::assertSent(OrderShipped::class, ['example@laravel.com', '...']);

    // Assert a mailable was not sent...
    Mail::assertNotSent(AnotherMailable::class);

    // Assert 3 total mailables were sent...
    Mail::assertSentCount(3);
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use App\Mail\OrderShipped;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_orders_can_be_shipped(): void
    {
        Mail::fake();

        // Perform order shipping...

        // Assert that no mailables were sent...
        Mail::assertNothingSent();

        // Assert that a mailable was sent...
        Mail::assertSent(OrderShipped::class);

        // Assert a mailable was sent twice...
        Mail::assertSent(OrderShipped::class, 2);

        // Assert a mailable was sent to an email address...
        Mail::assertSent(OrderShipped::class, 'example@laravel.com');

        // Assert a mailable was sent to multiple email addresses...
        Mail::assertSent(OrderShipped::class, ['example@laravel.com', '...']);

        // Assert a mailable was not sent...
        Mail::assertNotSent(AnotherMailable::class);

        // Assert 3 total mailables were sent...
        Mail::assertSentCount(3);
    }
}
```

Si estás poniendo en cola mailables para entrega en segundo plano, deberías usar el método `assertQueued` en lugar de `assertSent`:

    Mail::assertQueued(OrderShipped::class);
    Mail::assertNotQueued(OrderShipped::class);
    Mail::assertNothingQueued();
    Mail::assertQueuedCount(3);

Puedes pasar una función a los métodos `assertSent`, `assertNotSent`, `assertQueued`, o `assertNotQueued` para afirmar que un mailable fue enviado que pasa una "prueba de verdad" dada. Si al menos un mailable fue enviado que pasa la prueba de verdad dada, entonces la afirmación será exitosa:

    Mail::assertSent(function (OrderShipped $mail) use ($order) {
        return $mail->order->id === $order->id;
    });

Al llamar a los métodos de afirmación del facade `Mail`, la instancia del mailable aceptada por la función proporcionada expone métodos útiles para examinar el mailable:

    Mail::assertSent(OrderShipped::class, function (OrderShipped $mail) use ($user) {
        return $mail->hasTo($user->email) &&
               $mail->hasCc('...') &&
               $mail->hasBcc('...') &&
               $mail->hasReplyTo('...') &&
               $mail->hasFrom('...') &&
               $mail->hasSubject('...');
    });

La instancia del mailable también incluye varios métodos útiles para examinar los archivos adjuntos en un mailable:

    use Illuminate\Mail\Mailables\Attachment;

    Mail::assertSent(OrderShipped::class, function (OrderShipped $mail) {
        return $mail->hasAttachment(
            Attachment::fromPath('/path/to/file')
                    ->as('name.pdf')
                    ->withMime('application/pdf')
        );
    });

    Mail::assertSent(OrderShipped::class, function (OrderShipped $mail) {
        return $mail->hasAttachment(
            Attachment::fromStorageDisk('s3', '/path/to/file')
        );
    });

    Mail::assertSent(OrderShipped::class, function (OrderShipped $mail) use ($pdfData) {
        return $mail->hasAttachment(
            Attachment::fromData(fn () => $pdfData, 'name.pdf')
        );
    });

Puede que hayas notado que hay dos métodos para afirmar que no se envió correo: `assertNotSent` y `assertNotQueued`. A veces puedes desear afirmar que no se envió ningún correo **o** que no se puso en cola. Para lograr esto, puedes usar los métodos `assertNothingOutgoing` y `assertNotOutgoing`:

```markdown
    Mail::assertNothingOutgoing();

    Mail::assertNotOutgoing(function (OrderShipped $mail) use ($order) {
        return $mail->order->id === $order->id;
    });

<a name="mail-and-local-development"></a>
## Correo y Desarrollo Local

Al desarrollar una aplicación que envía correos electrónicos, probablemente no querrás enviar realmente correos electrónicos a direcciones de correo electrónico en vivo. Laravel proporciona varias formas de "desactivar" el envío real de correos electrónicos durante el desarrollo local.

<a name="log-driver"></a>
#### Controlador de Registro

En lugar de enviar tus correos electrónicos, el controlador de correo `log` escribirá todos los mensajes de correo electrónico en tus archivos de registro para su inspección. Típicamente, este controlador solo se usaría durante el desarrollo local. Para obtener más información sobre cómo configurar tu aplicación por entorno, consulta la [documentación de configuración](/docs/{{version}}/configuration#environment-configuration).

<a name="mailtrap"></a>
#### HELO / Mailtrap / Mailpit

Alternativamente, puedes usar un servicio como [HELO](https://usehelo.com) o [Mailtrap](https://mailtrap.io) y el controlador `smtp` para enviar tus mensajes de correo electrónico a un buzón "ficticio" donde puedes verlos en un cliente de correo electrónico real. Este enfoque tiene la ventaja de permitirte inspeccionar realmente los correos electrónicos finales en el visor de mensajes de Mailtrap.

Si estás usando [Laravel Sail](/docs/{{version}}/sail), puedes previsualizar tus mensajes usando [Mailpit](https://github.com/axllent/mailpit). Cuando Sail está en funcionamiento, puedes acceder a la interfaz de Mailpit en: `http://localhost:8025`.

<a name="using-a-global-to-address"></a>
#### Usando una Dirección `to` Global

Finalmente, puedes especificar una dirección "to" global invocando el método `alwaysTo` ofrecido por el facade `Mail`. Típicamente, este método debería ser llamado desde el método `boot` de uno de los proveedores de servicios de tu aplicación:

    use Illuminate\Support\Facades\Mail;

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        if ($this->app->environment('local')) {
            Mail::alwaysTo('taylor@example.com');
        }
    }

<a name="events"></a>
## Eventos

Laravel despacha dos eventos mientras envía mensajes de correo. El evento `MessageSending` se despacha antes de que se envíe un mensaje, mientras que el evento `MessageSent` se despacha después de que se ha enviado un mensaje. Recuerda, estos eventos se despachan cuando el correo está siendo *enviado*, no cuando está en cola. Puedes crear [escuchadores de eventos](/docs/{{version}}/events) para estos eventos dentro de tu aplicación:

    use Illuminate\Mail\Events\MessageSending;
    // use Illuminate\Mail\Events\MessageSent;

    class LogMessage
    {
        /**
         * Manejar el evento dado.
         */
        public function handle(MessageSending $event): void
        {
            // ...
        }
    }

<a name="custom-transports"></a>
## Transportes Personalizados

Laravel incluye una variedad de transportes de correo; sin embargo, es posible que desees escribir tus propios transportes para entregar correos electrónicos a través de otros servicios que Laravel no admite de forma predeterminada. Para comenzar, define una clase que extienda la clase `Symfony\Component\Mailer\Transport\AbstractTransport`. Luego, implementa los métodos `doSend` y `__toString()` en tu transporte:

    use MailchimpTransactional\ApiClient;
    use Symfony\Component\Mailer\SentMessage;
    use Symfony\Component\Mailer\Transport\AbstractTransport;
    use Symfony\Component\Mime\Address;
    use Symfony\Component\Mime\MessageConverter;

    class MailchimpTransport extends AbstractTransport
    {
        /**
         * Crear una nueva instancia de transporte Mailchimp.
         */
        public function __construct(
            protected ApiClient $client,
        ) {
            parent::__construct();
        }

        /**
         * {@inheritDoc}
         */
        protected function doSend(SentMessage $message): void
        {
            $email = MessageConverter::toEmail($message->getOriginalMessage());

            $this->client->messages->send(['message' => [
                'from_email' => $email->getFrom(),
                'to' => collect($email->getTo())->map(function (Address $email) {
                    return ['email' => $email->getAddress(), 'type' => 'to'];
                })->all(),
                'subject' => $email->getSubject(),
                'text' => $email->getTextBody(),
            ]]);
        }

        /**
         * Obtener la representación en cadena del transporte.
         */
        public function __toString(): string
        {
            return 'mailchimp';
        }
    }

Una vez que hayas definido tu transporte personalizado, puedes registrarlo a través del método `extend` proporcionado por el facade `Mail`. Típicamente, esto debería hacerse dentro del método `boot` del proveedor de servicios `AppServiceProvider` de tu aplicación. Se pasará un argumento `$config` a la función proporcionada al método `extend`. Este argumento contendrá el array de configuración definido para el correo en el archivo de configuración `config/mail.php` de la aplicación:

    use App\Mail\MailchimpTransport;
    use Illuminate\Support\Facades\Mail;

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        Mail::extend('mailchimp', function (array $config = []) {
            return new MailchimpTransport(/* ... */);
        });
    }

Una vez que tu transporte personalizado ha sido definido y registrado, puedes crear una definición de correo dentro del archivo de configuración `config/mail.php` de tu aplicación que utilice el nuevo transporte:

    'mailchimp' => [
        'transport' => 'mailchimp',
        // ...
    ],

<a name="additional-symfony-transports"></a>
### Transportes Adicionales de Symfony

Laravel incluye soporte para algunos transportes de correo mantenidos por Symfony, como Mailgun y Postmark. Sin embargo, es posible que desees extender Laravel con soporte para transportes adicionales mantenidos por Symfony. Puedes hacerlo requiriendo el transportador de Symfony necesario a través de Composer y registrando el transporte con Laravel. Por ejemplo, puedes instalar y registrar el transportador de correo "Brevo" (anteriormente "Sendinblue") de Symfony:

```none
composer require symfony/brevo-mailer symfony/http-client
```

Una vez que el paquete del transportador Brevo ha sido instalado, puedes agregar una entrada para tus credenciales de API de Brevo en el archivo de configuración `services` de tu aplicación:

    'brevo' => [
        'key' => 'your-api-key',
    ],

A continuación, puedes usar el método `extend` del facade `Mail` para registrar el transporte con Laravel. Típicamente, esto debería hacerse dentro del método `boot` de un proveedor de servicios:

    use Illuminate\Support\Facades\Mail;
    use Symfony\Component\Mailer\Bridge\Brevo\Transport\BrevoTransportFactory;
    use Symfony\Component\Mailer\Transport\Dsn;

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        Mail::extend('brevo', function () {
            return (new BrevoTransportFactory)->create(
                new Dsn(
                    'brevo+api',
                    'default',
                    config('services.brevo.key')
                )
            );
        });
    }

Una vez que tu transporte ha sido registrado, puedes crear una definición de correo dentro del archivo de configuración `config/mail.php` de tu aplicación que utilice el nuevo transporte:

    'brevo' => [
        'transport' => 'brevo',
        // ...
    ],
```
