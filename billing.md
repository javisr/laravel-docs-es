# Cashier Laravel (Stripe)

- [Introducción](#introduction)
- [Actualización del Cashier](#upgrading-cashier)
- [Instalación](#installation)
  - [Migración de bases de datos](#database-migrations)
- [Configuración](#configuration)
  - [Modelo de Facturación](#billable-model)
  - [Claves API](#api-keys)
  - [Configuración de divisas](#currency-configuration)
  - [Configuración de impuestos](#tax-configuration)
  - [Registro](#logging)
  - [Uso de modelos personalizados](#using-custom-models)
- [Clientes](#customers)
  - [Recuperación de clientes](#retrieving-customers)
  - [Creación de clientes](#creating-customers)
  - [Actualización de clientes](#updating-customers)
  - [Saldos](#balances)
  - [Identificadores fiscales](#tax-ids)
  - [Sincronización de datos de clientes con Stripe](#syncing-customer-data-with-stripe)
  - [Portal de facturación](#billing-portal)
- [Métodos de pago](#payment-methods)
  - [Almacenamiento de métodos de pago](#storing-payment-methods)
  - [Recuperación de métodos de pago](#retrieving-payment-methods)
  - [Determinación de si un usuario tiene una forma de pago](#check-for-a-payment-method)
  - [Actualización de la forma de pago predeterminada](#updating-the-default-payment-method)
  - [Adición de vías de pago](#adding-payment-methods)
  - [Eliminación de métodos de pago](#deleting-payment-methods)
- [Suscripciones](#subscriptions)
  - [Creación de suscripciones](#creating-subscriptions)
  - [Comprobación del estado de la suscripción](#checking-subscription-status)
  - [Modificación de precios](#changing-prices)
  - [Cantidad de suscripciones](#subscription-quantity)
  - [Suscripciones con varios productos](#subscriptions-with-multiple-products)
  - [Facturación con contador](#metered-billing)
  - [Impuestos de suscripción](#subscription-taxes)
  - [Fecha de anclaje del abono](#subscription-anchor-date)
  - [Cancelación de suscripciones](#cancelling-subscriptions)
  - [Reanudación de suscripciones](#resuming-subscriptions)
- [Pruebas de suscripción](#subscription-trials)
  - [Con método de pago por adelantado](#with-payment-method-up-front)
  - [Sin método de pago por adelantado](#without-payment-method-up-front)
  - [Ampliación de periodo de pruebas](#extending-trials)
- [Gestión de Webhooks de Stripe](#handling-stripe-webhooks)
  - [Definición de controladores de eventos Webhook](#defining-webhook-event-handlers)
  - [Verificación de Firmas Webhook](#verifying-webhook-signatures)
- [Cargos Simples](#single-charges)
  - [Cargo simple](#simple-charge)
  - [Cargo con factura](#charge-with-invoice)
  - [Creación de intenciones de pago](#creating-payment-intents)
  - [Reembolso de cargos](#refunding-charges)
- [Pago](#checkout)
  - [Comprobación de productos](#product-checkouts)
  - [Cobro único](#single-charge-checkouts)
  - [Comprobación de suscripciones](#subscription-checkouts)
  - [Recopilación de números de identificación fiscal](#collecting-tax-ids)
  - [Comprobación de invitados](#guest-checkouts)
- [Facturas](#invoices)
  - [Recuperación de facturas](#retrieving-invoices)
  - [Próximas facturas](#upcoming-invoices)
  - [Vista previa de facturas de suscripción](#previewing-subscription-invoices)
  - [Generación de PDF de facturas](#generating-invoice-pdfs)
- [Gestión de pagos fallidos](#handling-failed-payments)
- [Autenticación fuerte de clientes (SCA)](#strong-customer-authentication)
  - [Pagos que requieren confirmación adicional](#payments-requiring-additional-confirmation)
  - [Notificaciones de pago fuera de sesión](#off-session-payment-notifications)
- [SDK de Stripe](#stripe-sdk)
- [Testing](#testing)

<a name="introduction"></a>
## Introducción

[Laravel Cashier Stripe](https://github.com/laravel/cashier-stripe) proporciona una interfaz expresiva y fluida para los servicios de facturación de suscripciones [de Stripe](https://stripe.com). Maneja casi todo el código de facturación de suscripciones que temes escribir. Además de la gestión básica de la suscripción, Cashier puede manejar cupones, el intercambio de suscripción, suscripción en "cantidades", los períodos de gracia de cancelación, e incluso generar facturas en PDF.

<a name="upgrading-cashier"></a>
## Actualización del Cashier

Cuando actualice a una nueva versión de Cashier, es importante que revise detenidamente [la guía de actualización](https://github.com/laravel/cashier-stripe/blob/master/UPGRADE.md).

> **Advertencia**  
> Para evitar romper los cambios, Cashier utiliza una versión fija de Stripe API. Cashier 14 utiliza la versión `2022-11-15` de la API de Stripe. La versión de la API de Stripe se actualizará en versiones menores con el fin de hacer uso de las nuevas características y mejoras de Stripe.

<a name="installation"></a>
## Instalación

En primer lugar, instale el paquete de Cashier para Stripe utilizando el gestor de paquetes Composer:

```shell
composer require laravel/cashier
```

> **Advertencia**  
> Para garantizar que Cashier gestiona correctamente todos los eventos de Stripe, recuerde configurar la [gestión de webhooks de Cashier](#handling-stripe-webhooks).

<a name="database-migrations"></a>
### Migración de bases de datos

El proveedor de servicios de Cashier registra su propio directorio de migración de base de datos, así que recuerda migrar tu base de datos después de instalar el paquete. Las migraciones de Cashier añadirán varias columnas a tu tabla `users` así como crearán una nueva tabla `subscriptions` para contener todas las suscripciones de tus clientes:

```shell
php artisan migrate
```

Si necesita sobrescribir las migraciones que vienen con Cashier, puede publicarlas utilizando el comando `vendor:publish` de Artisan:

```shell
php artisan vendor:publish --tag="cashier-migrations"
```

Si desea evitar que las migraciones de Cashier se ejecuten por completo, puede utilizar el método `ignoreMigrations` proporcionado por Cashier. Lo normal es que este método sea llamado en el método `register` de su `AppServiceProvider`:

    use Laravel\Cashier\Cashier;

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        Cashier::ignoreMigrations();
    }

> **Advertencia**  
> Stripe recomienda que cualquier columna utilizada para almacenar identificadores de Stripe distinga entre mayúsculas y minúsculas. Puede encontrar más información al respecto en la [documentación de Stripe](https://stripe.com/docs/upgrades#what-changes-does-stripe-consider-to-be-backwards-compatible).

<a name="configuration"></a>
## Configuración

<a name="billable-model"></a>
### Modelo de Facturación

Antes de utilizar Cashier, añada el trait `Billable` a la definición de su modelo facturable. Típicamente, este será el modelo `App\Models\User`. Este trait proporciona varios métodos que le permiten realizar tareas comunes de facturación, como crear suscripciones, aplicar cupones y actualizar la información del método de pago:

    use Laravel\Cashier\Billable;

    class User extends Authenticatable
    {
        use Billable;
    }

Cashier asume que su modelo de facturación será la clase `App\Models\User` que viene con Laravel. Si desea cambiar esto, puede especificar un modelo diferente a través del método `useCustomerModel`. Por lo general, este método es llamado en el método de `boot` de su clase `AppServiceProvider`:

    use App\Models\Cashier\User;
    use Laravel\Cashier\Cashier;

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Cashier::useCustomerModel(User::class);
    }

> **Advertencia**  
> Si estás usando un modelo distinto al modelo `App\Models\User` suministrado por Laravel, necesitarás publicar y modificar las [migraciones Cashier](#installation) suministradas para que coincidan con el nombre de tabla de tu modelo alternativo.

<a name="api-keys"></a>
### Claves API

A continuación, debe configurar sus claves API de Stripe en el archivo `.env` de su aplicación. Puede recuperar sus claves API de Stripe desde el panel de control de Stripe:

```ini
STRIPE_KEY=your-stripe-key
STRIPE_SECRET=your-stripe-secret
STRIPE_WEBHOOK_SECRET=your-stripe-webhook-secret
```

> **Advertencia**  
> Debe asegurarse de que la variable de entorno `STRIPE_WEBHOOK_SECRET` está definida en el archivo . `env` de su aplicación, ya que esta variable se utiliza para garantizar que los webhooks entrantes proceden realmente de Stripe.

<a name="currency-configuration"></a>
### Configuración de Divisas

La moneda por defecto del Cashier es el Dólar Estadounidense (USD). Puede cambiar la moneda por defecto configurando la variable de entorno `CASHIER_CURRENCY` dentro del archivo . `env` de su aplicación:

```ini
CASHIER_CURRENCY=eur
```

Además de configurar la moneda de Cashier, también puede especificar una configuración regional que se utilizará al dar formato a los valores monetarios para su visualización en las facturas. Internamente, Cashier utiliza [la clase `NumberFormatter` de PHP](https://www.php.net/manual/en/class.numberformatter.php) para establecer la configuración regional de la moneda:

```ini
CASHIER_CURRENCY_LOCALE=nl_BE
```

> **Advertencia**  
> Para utilizar otros idiomas distintos an inglés (`en`), asegúrese de que la extensión `ext-intl` PHP está instalada y configurada en su servidor.

<a name="tax-configuration"></a>
### Configuración de impuestos

Gracias a [Stripe Tax](https://stripe.com/tax), es posible calcular automáticamente los impuestos para todas las facturas generadas por Stripe. Puede habilitar el cálculo automático de impuestos invocando el método `calculateTaxes` en el método `boot` de la clase `App\Providers\AppServiceProvider` de su aplicación:

    use Laravel\Cashier\Cashier;

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Cashier::calculateTaxes();
    }

Una vez habilitado el cálculo de impuestos, las nuevas suscripciones y las facturas puntuales que se generen recibirán el cálculo automático de impuestos.

Para que esta característica funcione correctamente, los detalles de facturación de su cliente, como el nombre del cliente, la dirección y la identificación fiscal, deben sincronizarse con Stripe. Para ello, puede utilizar los métodos de [sincronización de datos de cliente](#syncing-customer-data-with-stripe) e [identificadores fiscales](#tax-ids) que ofrece Cashier.

> **Advertencia**  
> Desafortunadamente, por ahora, no se calculan impuestos para los [cargos únicos](#single-charges) o los [pagos de un solo cargo](#single-charge-checkouts). Además, Stripe Tax es actualmente "sólo por invitación" durante su periodo beta. Puede solicitar acceso a Stripe Tax a través del [sitio web de Stripe](https://stripe.com/tax#request-access) Tax.

<a name="logging"></a>
### Registro

Cashier le permite especificar el canal de registro que se utilizará cuando se registren errores fatales de Stripe. Puede especificar el canal de registro definiendo la variable de entorno `CASHIER_LOGGER` dentro del archivo `.env` de su aplicación:

```ini
CASHIER_LOGGER=stack
```

Las excepciones generadas por llamadas a la API de Stripe se registrarán a través del canal de registro predeterminado de su aplicación.

<a name="using-custom-models"></a>
### Uso de modelos personalizados

Puede ampliar los modelos utilizados internamente por Cashier definiendo su propio modelo y extendiendo el modelo correspondiente de Cashier:

    use Laravel\Cashier\Subscription as CashierSubscription;

    class Subscription extends CashierSubscription
    {
        // ...
    }

Después de definir su modelo, puede indicar a Cashier que utilice su modelo personalizado a través de la clase `Laravel\Cashier\Cashier`. Normalmente, debe informar a Cashier sobre sus modelos personalizados en el método de `boot` de la clase `App\Providers\AppServiceProvider` de su aplicación:

    use App\Models\Cashier\Subscription;
    use App\Models\Cashier\SubscriptionItem;

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Cashier::useSubscriptionModel(Subscription::class);
        Cashier::useSubscriptionItemModel(SubscriptionItem::class);
    }

<a name="customers"></a>
## Clientes

<a name="retrieving-customers"></a>
### Recuperación de Clientes

Puede recuperar un cliente por su ID de Stripe utilizando el método `Cashier::findBillable`. Este método devolverá una instancia del modelo facturable:

    use Laravel\Cashier\Cashier;

    $user = Cashier::findBillable($stripeId);

<a name="creating-customers"></a>
### Creación de Clientes

Ocasionalmente, puede que desee crear un cliente de Stripe sin iniciar una suscripción. Puede hacerlo utilizando el método `createAsStripeCustomer`:

    $stripeCustomer = $user->createAsStripeCustomer();

Una vez que el cliente ha sido creado en Stripe, puede iniciar una suscripción en una fecha posterior. Puedes proporcionar un array `$options` opcional para pasar cualquier [parámetro adicional de creación de cliente que sea soportado por la API de Stripe](https://stripe.com/docs/api/customers/create):

    $stripeCustomer = $user->createAsStripeCustomer($options);

Puede utilizar el método `asStripeCustomer` si desea devolver el objeto cliente de Stripe para un modelo facturable:

    $stripeCustomer = $user->asStripeCustomer();

Puede utilizar el método `createOrGetStripeCustomer` si desea recuperar el objeto cliente de Stripe para un modelo facturable determinado pero no está seguro de si el modelo facturable ya es un cliente dentro de Stripe. Este método creará un nuevo cliente en Stripe si aún no existe:

    $stripeCustomer = $user->createOrGetStripeCustomer();

<a name="updating-customers"></a>
### Actualización de clientes

Ocasionalmente, puede que desee actualizar el cliente de Stripe directamente con información adicional. Puede hacerlo utilizando el método `updateStripeCustomer`. Este método acepta una array de [opciones de actualización de clientes soportadas por la API de Stripe](https://stripe.com/docs/api/customers/update):

    $stripeCustomer = $user->updateStripeCustomer($options);

<a name="balances"></a>
### Saldos

Stripe le permite acreditar o debitar el "saldo" de un cliente. Posteriormente, este saldo se abonará o cargará en las nuevas facturas. Para comprobar el saldo total del cliente puede utilizar el método de `balance` que está disponible en su modelo facturable. El método de `balance` devolverá una representación de cadena formateada del saldo en la moneda del cliente:

    $balance = $user->balance();

Para acreditar el saldo de un cliente, puede proporcionar un valor al método `creditBalance`. Si lo desea, también puede proporcionar una descripción:

    $user->creditBalance(500, 'Premium customer top-up.');

Proporcionar un valor al método `debitBalance` cargará el saldo del cliente:

    $user->debitBalance(300, 'Bad usage penalty.');

El método `applyBalance` creará nuevas transacciones de saldo de cliente para el cliente. Puede recuperar estos registros de transacciones utilizando el método `balanceTransactions`, que puede ser útil para proporcionar un registro de créditos y débitos para que el cliente lo revise:

    // Retrieve all transactions...
    $transactions = $user->balanceTransactions();

    foreach ($transactions as $transaction) {
        // Transaction amount...
        $amount = $transaction->amount(); // $2.31

        // Retrieve the related invoice when available...
        $invoice = $transaction->invoice();
    }

<a name="tax-ids"></a>
### Identificadores Fiscales

Cashier ofrece una forma sencilla de gestionar los identificadores fiscales de un cliente. Por ejemplo, el método `taxIds` se puede utilizar para recuperar todos los [identificadores fiscales](https://stripe.com/docs/api/customer_tax_ids/object) que se asignan a un cliente como una colección:

    $taxIds = $user->taxIds();

También puede recuperar una identificación fiscal específica para un cliente por su identificador:

    $taxId = $user->findTaxId('txi_belgium');

Puede crear un nuevo identificador fiscal proporcionando un [tipo](https://stripe.com/docs/api/customer_tax_ids/object#tax_id_object-type) y valor válidos al método `createTaxId`:

    $taxId = $user->createTaxId('eu_vat', 'BE0123456789');

El método `createTaxId` añadirá inmediatamente el NIF a la cuenta del cliente. [Stripe también realiza la verificación de los ID de IVA (VAT)](https://stripe.com/docs/invoicing/customer/tax-ids#validation); sin embargo, se trata de un proceso asíncrono. Puede recibir notificaciones de actualizaciones de verificación suscribiéndose al evento webhook `customer.tax_id.updated` e inspeccionando [el parámetro de `verificación` de ID de IVA (VAT)](https://stripe.com/docs/api/customer_tax_ids/object#tax_id_object-verification). Para más información sobre el manejo de webhooks, consulte la [documentación sobre la definición de manejadores de webhooks](#handling-stripe-webhooks).

Puede eliminar un identificador fiscal utilizando el método `deleteTaxId`:

    $user->deleteTaxId('txi_belgium');

<a name="syncing-customer-data-with-stripe"></a>
### Sincronización de datos de clientes con Stripe

Normalmente, cuando los usuarios de su aplicación actualizan su nombre, dirección de correo electrónico u otra información que también almacena Stripe, debe informar a Stripe de las actualizaciones. Al hacerlo, la copia de Stripe de la información estará sincronizada con la de su aplicación.

Para automatizar esto, puede definir un receptor de eventos en su modelo de facturación que reaccione al evento de `updated` del modelo. Luego, dentro de tu listener de eventos, puedes invocar el método `syncStripeCustomerDetails` en el modelo:

    use function Illuminate\Events\queueable;

    /**
     * The "booted" method of the model.
     *
     * @return void
     */
    protected static function booted()
    {
        static::updated(queueable(function ($customer) {
            if ($customer->hasStripeId()) {
                $customer->syncStripeCustomerDetails();
            }
        }));
    }

Ahora, cada vez que su modelo de cliente se actualice, su información se sincronizará con Stripe. Para mayor comodidad, Cashier sincronizará automáticamente la información de su cliente con Stripe en la creación inicial del cliente.

Puede personalizar las columnas utilizadas para sincronizar la información del cliente con Stripe sobreescribiendo una variedad de métodos proporcionados por Cashier. Por ejemplo, puede sobreescribir el método `stripeName` para personalizar el atributo que debe ser considerado como el "nombre" del cliente cuando Cashier sincroniza la información del cliente con Stripe:

    /**
     * Get the customer name that should be synced to Stripe.
     *
     * @return string|null
     */
    public function stripeName()
    {
        return $this->company_name;
    }

Del mismo modo, puede sobreescribir los métodos `stripeEmail`, `stripePhone`, `stripeAddress` y `stripePreferredLocales`. Estos métodos sincronizarán la información con sus correspondientes parámetros de cliente al [actualizar el objeto cliente de Stripe](https://stripe.com/docs/api/customers/update). Si desea tener un control total sobre el proceso de sincronización de la información del cliente, puede sobreescribir el método `syncStripeCustomerDetails`.

<a name="billing-portal"></a>
### Portal de facturación

Stripe ofrece [una forma sencilla de configurar un portal de facturación](https://stripe.com/docs/billing/subscriptions/customer-portal) para que su cliente pueda gestionar su suscripción, métodos de pago y ver su historial de facturación. Puede redirigir a sus usuarios al portal de facturación invocando el método `redirectToBillingPortal` en el modelo facturable desde un controlador o ruta:

    use Illuminate\Http\Request;

    Route::get('/billing-portal', function (Request $request) {
        return $request->user()->redirectToBillingPortal();
    });

Por defecto, cuando el usuario termine de gestionar su suscripción, podrá volver a la ruta de `inicio` de su aplicación a través de un enlace dentro del portal de facturación de Stripe. Puede proporcionar una URL personalizada a la que el usuario debería volver pasando la URL como argumento al método `redirectToBillingPortal`:

    use Illuminate\Http\Request;

    Route::get('/billing-portal', function (Request $request) {
        return $request->user()->redirectToBillingPortal(route('billing'));
    });

Si desea generar la URL al portal de facturación sin generar una respuesta de redirección HTTP, puede invocar el método `billingPortalUrl`:

    $url = $request->user()->billingPortalUrl(route('billing'));

<a name="payment-methods"></a>
## Métodos de Pago

<a name="storing-payment-methods"></a>
### Almacenamiento de métodos de pago

Para crear suscripciones o realizar cargos "puntuales" con Stripe, necesitarás almacenar un método de pago y recuperar su identificador de Stripe. El enfoque utilizado para lograr esto difiere en función de si planea utilizar el método de pago para suscripciones o cargos únicos, por lo que examinaremos ambos a continuación.

<a name="payment-methods-for-subscriptions"></a>
#### Métodos de pago para suscripciones

Al almacenar la información de la tarjeta de crédito de un cliente para su uso futuro en una suscripción, se debe utilizar la API "Setup Intents" de Stripe para recopilar de forma segura los detalles del método de pago del cliente. Una "Setup Intent" indica a Stripe la intención de cargar el método de pago de un cliente. El trait `Billable` de Cashier incluye el método `createSetupIntent` para crear fácilmente una nueva Setup Intent. Debes invocar este método desde la ruta o controlador que renderizará el formulario que recoge los detalles del método de pago de tu cliente:

    return view('update-payment-method', [
        'intent' => $user->createSetupIntent()
    ]);

Una vez creada la Setup Intent y pasada a la vista, debes adjuntar su `secret` al elemento que recogerá el método de pago. Por ejemplo, considere este formulario "actualizar método de pago":

```html
<input id="card-holder-name" type="text">

<!-- Stripe Elements Placeholder -->
<div id="card-element"></div>

<button id="card-button" data-secret="{{ $intent->client_secret }}">
    Update Payment Method
</button>
```

A continuación, se puede utilizar la librería Stripe.js para adjuntar un elemento [Stripe](https://stripe.com/docs/stripe-js) al formulario y recoger de forma segura los datos de pago del cliente:

```html
<script src="https://js.stripe.com/v3/"></script>

<script>
    const stripe = Stripe('stripe-public-key');

    const elements = stripe.elements();
    const cardElement = elements.create('card');

    cardElement.mount('#card-element');
</script>
```

A continuación, la tarjeta puede ser verificada y un "identificador de método de pago" seguro puede ser recuperado de Stripe utilizando [el método `confirmCardSetup` de Stripe](https://stripe.com/docs/js/setup_intents/confirm_card_setup):

```js
const cardHolderName = document.getElementById('card-holder-name');
const cardButton = document.getElementById('card-button');
const clientSecret = cardButton.dataset.secret;

cardButton.addEventListener('click', async (e) => {
    const { setupIntent, error } = await stripe.confirmCardSetup(
        clientSecret, {
            payment_method: {
                card: cardElement,
                billing_details: { name: cardHolderName.value }
            }
        }
    );

    if (error) {
        // Display "error.message" to the user...
    } else {
        // The card has been verified successfully...
    }
});
```

Una vez que la tarjeta ha sido verificada por Stripe, puede pasar el identificador `setupIntent.payment_method` resultante a su aplicación Laravel, donde se puede adjuntar al cliente. El método de pago puede [añadirse como un nuevo método de pago](#adding-payment-methods) o [utilizarse para actualizar el método de pago predeterminado](#updating-the-default-payment-method). También puede utilizar inmediatamente el identificador de método de pago para [crear una nueva suscripción](#creating-subscriptions).

> **Nota**  
> Si desea obtener más información acerca de Setup Intents y la recopilación de detalles de pago del cliente por favor [revise esta visión general proporcionada por Stripe](https://stripe.com/docs/payments/save-and-reuse#php).

<a name="payment-methods-for-single-charges"></a>
#### Métodos de pago para cargos individuales

Por supuesto, al realizar un único cargo contra la forma de pago de un cliente, sólo tendremos que utilizar un identificador de forma de pago una vez. Debido a las limitaciones de Stripe, no puede utilizar el método de pago predeterminado almacenado de un cliente para cargos únicos. Debe permitir que el cliente introduzca los detalles de su método de pago utilizando la librería Stripe.js. Por ejemplo, considere el siguiente formulario:

```html
<input id="card-holder-name" type="text">

<!-- Stripe Elements Placeholder -->
<div id="card-element"></div>

<button id="card-button">
    Process Payment
</button>
```

Una vez definido el formulario, se puede utilizar la librería Stripe.js para adjuntar un [elemento Stripe](https://stripe.com/docs/stripe-js) al formulario y recoger de forma segura los datos de pago del cliente:

```html
<script src="https://js.stripe.com/v3/"></script>

<script>
    const stripe = Stripe('stripe-public-key');

    const elements = stripe.elements();
    const cardElement = elements.create('card');

    cardElement.mount('#card-element');
</script>
```

A continuación, la tarjeta puede ser verificada y un "identificador de método de pago" seguro puede ser recuperado de Stripe utilizando [el método `createPaymentMethod` de Stripe](https://stripe.com/docs/stripe-js/reference#stripe-create-payment-method):

```js
const cardHolderName = document.getElementById('card-holder-name');
const cardButton = document.getElementById('card-button');

cardButton.addEventListener('click', async (e) => {
    const { paymentMethod, error } = await stripe.createPaymentMethod(
        'card', cardElement, {
            billing_details: { name: cardHolderName.value }
        }
    );

    if (error) {
        // Display "error.message" to the user...
    } else {
        // The card has been verified successfully...
    }
});
```

Si la tarjeta se verifica correctamente, puede pasar el `paymentMethod.id` a su aplicación Laravel y procesar un [único cargo](#simple-charge).

<a name="retrieving-payment-methods"></a>
### Recuperación de métodos de pago

El método `paymentMethods` en la instancia del modelo facturable devuelve una colección de instancias `Laravel\Cashier\PaymentMethod`:

    $paymentMethods = $user->paymentMethods();

Por defecto, este método devolverá métodos de pago del tipo `card`. Para recuperar métodos de pago de un tipo diferente, puede pasar el `type` como argumento al método:

    $paymentMethods = $user->paymentMethods('sepa_debit');

Para recuperar el método de pago por defecto del cliente, se puede utilizar el método `defaultPaymentMethod`:

    $paymentMethod = $user->defaultPaymentMethod();

Puedes recuperar un método de pago específico que esté adjunto al modelo facturable usando el método `findPaymentMethod`:

    $paymentMethod = $user->findPaymentMethod($paymentMethodId);

<a name="check-for-a-payment-method"></a>
### Determinar si un usuario tiene una forma de pago

Para determinar si un modelo facturable tiene un método de pago por defecto asociado a su cuenta, invoque el método `hasDefaultPaymentMethod`:

    if ($user->hasDefaultPaymentMethod()) {
        //
    }

Puedes utilizar el método `hasPaymentMethod` para determinar si un modelo facturable tiene al menos un método de pago asociado a su cuenta:

    if ($user->hasPaymentMethod()) {
        //
    }

Este método determinará si el modelo facturable tiene métodos de pago del tipo `card`. Para determinar si existe un método de pago de otro tipo para el modelo, puede pasar el `type` como argumento al método:

    if ($user->hasPaymentMethod('sepa_debit')) {
        //
    }

<a name="updating-the-default-payment-method"></a>
### Actualización de la Forma de Pago por Defecto

El método `updateDefaultPaymentMethod` puede utilizarse para actualizar la información del método de pago por defecto de un cliente. Este método acepta un identificador de método de pago de Stripe y asignará el nuevo método de pago como método de pago de facturación predeterminado:

    $user->updateDefaultPaymentMethod($paymentMethod);

Para sincronizar la información del método de pago predeterminado con la información del método de pago predeterminado del cliente en Stripe, puede utilizar el método `updateDefaultPaymentMethodFromStripe`:

    $user->updateDefaultPaymentMethodFromStripe();

> **Advertencia**  
> El método de pago predeterminado en un cliente sólo se puede utilizar para facturar y crear nuevas suscripciones. Debido a las limitaciones impuestas por Stripe, no puede utilizarse para cargos únicos.

<a name="adding-payment-methods"></a>
### Añadir métodos de pago

Para añadir un nuevo método de pago, puede llamar al método `addPaymentMethod` en el modelo facturable, pasando el identificador del método de pago:

    $user->addPaymentMethod($paymentMethod);

> **Nota**  
> Para aprender a recuperar identificadores de métodos de pago, por favor revise la [documentación de almacenamiento de métodos de pago](#storing-payment-methods).

<a name="deleting-payment-methods"></a>
### Eliminar métodos de pago

Para eliminar un método de pago, puede llamar al método `delete` en la instancia `Laravel\Cashier\PaymentMethod` que desea eliminar:

    $paymentMethod->delete();

El método `deletePaymentMethod` borrará un método de pago específico del modelo facturable:

    $user->deletePaymentMethod('pm_visa');

El método `deletePaymentMethods` borrará toda la información del método de pago para el modelo facturable:

    $user->deletePaymentMethods();

Por defecto, este método borrará los métodos de pago del tipo `card`. Para borrar métodos de pago de un tipo diferente puedes pasar el `type` como argumento al método:

    $user->deletePaymentMethods('sepa_debit');

> **Advertencia**  
> Si un usuario tiene una suscripción activa, su aplicación no debe permitirle eliminar su método de pago predeterminado.

<a name="subscriptions"></a>
## Suscripciones

Las suscripciones proporcionan una forma de establecer pagos recurrentes para sus clientes. Las suscripciones de Stripe gestionadas por Cashier proporcionan soporte para múltiples precios de suscripción, cantidades de suscripción, pruebas y más.

<a name="creating-subscriptions"></a>
### Creación de suscripciones

Para crear una suscripción, primero recupere una instancia de su modelo facturable, que normalmente será una instancia de `App\Models\User`. Una vez que haya recuperado la instancia del modelo, puede utilizar el método `newSubscription` para crear la suscripción del modelo:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $request->user()->newSubscription(
            'default', 'price_monthly'
        )->create($request->paymentMethodId);

        // ...
    });

El primer argumento que se pasa al método `newSubscription` debe ser el nombre interno de la suscripción. Si su aplicación sólo ofrece una única suscripción, puede llamarla `default` o `primary`. Este nombre de suscripción es sólo para uso interno de la aplicación y no debe mostrarse a los usuarios. Además, no debe contener espacios y nunca debe cambiarse después de crear la suscripción. El segundo argumento es el precio específico al que se suscribe el usuario. Este valor debe corresponder al identificador del precio en Stripe.

El método `create`, que acepta [un identificador de método de pago de Stripe](#storing-payment-methods) o un objeto Stripe `PaymentMethod`, iniciará la suscripción así como actualizará su base de datos con el ID de cliente de Stripe del modelo facturable y otra información de facturación relevante.

> **Advertencia**  
> Si se pasa un identificador de método de pago directamente al método `create` de suscripción, también se añadirá automáticamente a los métodos de pago almacenados del usuario.

<a name="collecting-recurring-payments-via-invoice-emails"></a>
#### Cobro de pagos periódicos a través de correos electrónicos de factura

En lugar de cobrar automáticamente los pagos periódicos de un cliente, puede indicar a Stripe que envíe una factura por correo electrónico al cliente cada vez que venza su pago periódico. A continuación, el cliente puede pagar manualmente la factura una vez que la reciba. El cliente no necesita proporcionar un método de pago por adelantado al cobrar pagos periódicos mediante facturas:

    $user->newSubscription('default', 'price_monthly')->createAndSendInvoice();

La cantidad de tiempo que un cliente tiene para pagar su factura antes de que se cancele su suscripción viene determinada por la opción `days_until_due`. Por defecto, es de 30 días; sin embargo, puede proporcionar un valor específico para esta opción si lo desea:

    $user->newSubscription('default', 'price_monthly')->createAndSendInvoice([], [
        'days_until_due' => 30
    ]);

<a name="subscription-quantities"></a>
#### Cantidades

Si desea establecer una [cantidad](https://stripe.com/docs/billing/subscriptions/quantities) específica para el precio al crear la suscripción, debe invocar el método de `quantity` en el generador de suscripciones antes de crear la suscripción:

    $user->newSubscription('default', 'price_monthly')
         ->quantity(5)
         ->create($paymentMethod);

<a name="additional-details"></a>
#### Detalles adicionales

Si desea especificar opciones adicionales de [cliente](https://stripe.com/docs/api/customers/create) o [suscripción](https://stripe.com/docs/api/subscriptions/create) soportadas por Stripe, puede hacerlo pasándolas como segundo y tercer argumento al método `create`:

    $user->newSubscription('default', 'price_monthly')->create($paymentMethod, [
        'email' => $email,
    ], [
        'metadata' => ['note' => 'Some extra information.'],
    ]);

<a name="coupons"></a>
#### Cupones

Si desea aplicar un cupón al crear la suscripción, puede utilizar el método `withCoupon`:

    $user->newSubscription('default', 'price_monthly')
         ->withCoupon('code')
         ->create($paymentMethod);

O, si desea aplicar un [código de promoción de Stripe](https://stripe.com/docs/billing/subscriptions/discounts/codes), puede utilizar el método `withPromotionCode`:

    $user->newSubscription('default', 'price_monthly')
         ->withPromotionCode('promo_code_id')
         ->create($paymentMethod);

El Id. del código de promoción debe ser el Id. de la API de Stripe asignado al código de promoción y no el código de promoción del cliente. Si necesita encontrar un ID de código de promoción basado en un código de promoción de cara al cliente, puede utilizar el método `findPromotionCode`:

    // Find a promotion code ID by its customer facing code...
    $promotionCode = $user->findPromotionCode('SUMMERSALE');

    // Find an active promotion code ID by its customer facing code...
    $promotionCode = $user->findActivePromotionCode('SUMMERSALE');

En el ejemplo anterior, el objeto devuelto `$promotionCode` es una instancia de `Laravel\Cashier\PromotionCode`. Esta clase decora un objeto `Stripe\PromotionCode` subyacente. Puede recuperar el cupón relacionado con el código de promoción invocando el método `coupon`:

    $coupon = $user->findPromotionCode('SUMMERSALE')->coupon();

La instancia de cupón le permite determinar el importe del descuento y si el cupón representa un descuento fijo o un descuento basado en porcentaje:

    if ($coupon->isPercentage()) {
        return $coupon->percentOff().'%'; // 21.5%
    } else {
        return $coupon->amountOff(); // $5.99
    }

También puede recuperar los descuentos que se aplican actualmente a un cliente o suscripción:

    $discount = $billable->discount();

    $discount = $subscription->discount();

Las instancias `Laravel\Cashier\Discount` devueltas decoran una instancia de objeto `Stripe\Discount` subyacente. Puede recuperar el cupón relacionado con este descuento invocando el método `coupon`:

    $coupon = $subscription->discount()->coupon();

Si desea aplicar un nuevo cupón o código `promocional` a un cliente o suscripción, puede hacerlo mediante los métodos `applyCoupon` o `applyPromotionCode`:

    $billable->applyCoupon('coupon_id');
    $billable->applyPromotionCode('promotion_code_id');

    $subscription->applyCoupon('coupon_id');
    $subscription->applyPromotionCode('promotion_code_id');

Recuerde que debe utilizar el ID de API de Stripe asignado al código de promoción y no el código de promoción orientado al cliente. Sólo se puede aplicar un cupón o código promocional a un cliente o suscripción en un momento dado.

Para más información sobre este tema, consulte la documentación de Stripe relativa a [cupones](https://stripe.com/docs/billing/subscriptions/coupons) y [códigos promocionales](https://stripe.com/docs/billing/subscriptions/coupons/codes).

<a name="adding-subscriptions"></a>
#### Añadir suscripciones

Si desea añadir una suscripción a un cliente que ya tiene un método de pago predeterminado, puede invocar el método `add` en el generador de suscripciones:

    use App\Models\User;

    $user = User::find(1);

    $user->newSubscription('default', 'price_monthly')->add();

<a name="creating-subscriptions-from-the-stripe-dashboard"></a>
#### Crear suscripciones desde el panel de Stripe

También puede crear suscripciones desde el propio panel de Stripe. Al hacerlo, Cashier sincronizará las suscripciones recién añadidas y les asignará un nombre `por defecto`. Para personalizar el nombre de la suscripción que se asigna a las suscripciones creadas desde el cuadro de mandos, [extienda el `WebhookController`](#defining-webhook-event-handlers) y sobrescriba el método `newSubscriptionName`.

Además, sólo puede crear un tipo de suscripción a través del panel de Stripe. Si su aplicación ofrece múltiples suscripciones que utilizan diferentes nombres, sólo se puede añadir un tipo de suscripción a través del panel de Stripe.

Por último, siempre debe asegurarse de añadir sólo una suscripción activa por tipo de suscripción ofrecida por su aplicación. Si un cliente tiene dos suscripciones `por defecto`, sólo la suscripción añadida más recientemente será utilizada por Cashier aunque ambas estén sincronizadas con la base de datos de su aplicación.

<a name="checking-subscription-status"></a>
### Comprobación del estado de la suscripción

Una vez que un cliente está suscrito a su aplicación, puede comprobar fácilmente su estado de suscripción utilizando una variedad de métodos creados para ello. En primer lugar, el método `subscribed` devuelve `true` si el cliente tiene una suscripción activa, incluso si la suscripción está actualmente dentro de su periodo de prueba. El método `subscribed` acepta el nombre de la suscripción como primer argumento:

    if ($user->subscribed('default')) {
        //
    }

El método `subscribed` también es un buen candidato para ser usado en un [middleware de ruta](/docs/{{version}}/middleware), ya que permite filtrar el acceso a rutas y controladores en función del estado de suscripción del usuario:

    <?php

    namespace App\Http\Middleware;

    use Closure;

    class EnsureUserIsSubscribed
    {
        /**
         * Handle an incoming request.
         *
         * @param  \Illuminate\Http\Request  $request
         * @param  \Closure  $next
         * @return mixed
         */
        public function handle($request, Closure $next)
        {
            if ($request->user() && ! $request->user()->subscribed('default')) {
                // This user is not a paying customer...
                return redirect('billing');
            }

            return $next($request);
        }
    }

Si desea determinar si un usuario aún se encuentra dentro de su periodo de prueba, puede utilizar el método `onTrial`. Este método puede ser útil para determinar si debe mostrar una advertencia al usuario de que aún se encuentra en su periodo de prueba:

    if ($user->subscription('default')->onTrial()) {
        //
    }

El método `subscribedToProduct` puede utilizarse para determinar si el usuario está suscrito a un determinado producto en función del identificador de un determinado producto de Stripe. En Stripe, los productos son colecciones de precios. En este ejemplo, determinaremos si la suscripción `por defecto` del usuario está suscrita activamente al producto "premium" de la aplicación. El identificador de producto de Stripe dado debería corresponderse con uno de los identificadores de su producto en el panel de Stripe:

    if ($user->subscribedToProduct('prod_premium', 'default')) {
        //
    }

Al pasar una array al método `subscribedToProduct`, puede determinar si la suscripción `predeterminada` del usuario está suscrita activamente al producto "básico" o "premium" de la aplicación:

    if ($user->subscribedToProduct(['prod_basic', 'prod_premium'], 'default')) {
        //
    }

El método `subscribedToPrice` puede utilizarse para determinar si la suscripción de un cliente corresponde a un ID de precio determinado:

    if ($user->subscribedToPrice('price_basic_monthly', 'default')) {
        //
    }

El método `recurring` puede utilizarse para determinar si el usuario está suscrito actualmente y ya no se encuentra dentro de su periodo de prueba:

    if ($user->subscription('default')->recurring()) {
        //
    }

> **Advertencia**  
> Si un usuario tiene dos suscripciones con el mismo nombre, el método de `suscripción` siempre devolverá la suscripción más reciente. Por ejemplo, un usuario puede tener dos registros de suscripción con el nombre `predeterminado`; sin embargo, una de las suscripciones puede ser una suscripción antigua y caducada, mientras que la otra es la suscripción actual y activa. Siempre se devolverá la suscripción más reciente, mientras que las suscripciones más antiguas se conservan en la base de datos para su revisión histórica.

<a name="cancelled-subscription-status"></a>
#### Estado de suscripción cancelada

Para determinar si el usuario fue una vez un suscriptor activo pero ha cancelado su suscripción, puede utilizar el método `canceled`:

    if ($user->subscription('default')->canceled()) {
        //
    }

También puede determinar si un usuario ha cancelado su suscripción pero aún está en su "periodo de gracia" hasta que la suscripción expire completamente. Por ejemplo, si un usuario cancela una suscripción el 5 de marzo que originalmente estaba programada para expirar el 10 de marzo, el usuario está en su "periodo de gracia" hasta el 10 de marzo. Tenga en cuenta que el método `subscribed` sigue devolviendo `true` durante este tiempo:

    if ($user->subscription('default')->onGracePeriod()) {
        //
    }

Para determinar si el usuario ha cancelado su suscripción y ya no se encuentra dentro de su "periodo de gracia", puede utilizar el método `ended`:

    if ($user->subscription('default')->ended()) {
        //
    }

<a name="incomplete-and-past-due-status"></a>
#### Estado incompleto y vencido

Si una suscripción requiere una acción de pago secundaria después de su creación, la suscripción se marcará como `incomplete`. Los estados de suscripción se almacenan en la columna `stripe_status` de la tabla  `subscriptions` de la base de datos de Cashier.

Del mismo modo, si se requiere una acción de pago secundaria al intercambiar precios, la suscripción se marcará como `past_due`. Cuando su suscripción se encuentre en cualquiera de estos estados no estará activa hasta que el cliente haya confirmado su pago. La determinación de si una suscripción tiene un pago incompleto puede realizarse utilizando el método `hasIncompletePayment` en el modelo facturable o en una instancia de suscripción:

    if ($user->hasIncompletePayment('default')) {
        //
    }

    if ($user->subscription('default')->hasIncompletePayment()) {
        //
    }

Cuando una suscripción tiene un pago incompleto, debe dirigir al usuario a la página de confirmación de pago del Cashier, pasando el identificador `latestPayment`. Puede utilizar el método `latestPayment` disponible en la instancia de suscripción para recuperar este identificador:

```html
<a href="{{ route('cashier.payment', $subscription->latestPayment()->id) }}">
    Please confirm your payment.
</a>
```

Si desea que la suscripción se siga considerando activa cuando se encuentra en estado `past_due` o `incomplete`, puede utilizar los métodos `keepPastDueSubscriptionsActive` y `keepIncompleteSubscriptionsActive` proporcionados por Cashier. Por lo general, estos métodos deben ser llamados en el método de `register` de su `App\Providers\AppServiceProvider`:

    use Laravel\Cashier\Cashier;

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        Cashier::keepPastDueSubscriptionsActive();
        Cashier::keepIncompleteSubscriptionsActive();
    }

> **Advertencia**  
> Cuando una suscripción está en estado `incomplete`, no puede modificarse hasta que se confirme el pago. Por tanto, los métodos `swap` y `updateQuantity` lanzarán una excepción cuando la suscripción esté en estado `incomplete`.

<a name="subscription-scopes"></a>
#### Scopes de suscripción

La mayoría de los estados de suscripción también están disponibles como `scopes` de consulta para que pueda consultar fácilmente en su base de datos las suscripciones que se encuentran en un estado determinado:

    // Get all active subscriptions...
    $subscriptions = Subscription::query()->active()->get();

    // Get all of the canceled subscriptions for a user...
    $subscriptions = $user->subscriptions()->canceled()->get();

A continuación encontrará una lista completa de los ámbitos disponibles:

    Subscription::query()->active();
    Subscription::query()->canceled();
    Subscription::query()->ended();
    Subscription::query()->incomplete();
    Subscription::query()->notCanceled();
    Subscription::query()->notOnGracePeriod();
    Subscription::query()->notOnTrial();
    Subscription::query()->onGracePeriod();
    Subscription::query()->onTrial();
    Subscription::query()->pastDue();
    Subscription::query()->recurring();

<a name="changing-prices"></a>
### Modificación de precios

Después de que un cliente se suscriba a su aplicación, puede que ocasionalmente quiera cambiar a un nuevo precio de suscripción. Para cambiar a un cliente a un nuevo precio, pase el identificador del precio de Stripe al método `swap`. Cuando se intercambian precios, se asume que el usuario desea reactivar su suscripción si fue cancelada previamente. El identificador de precio dado debe corresponder a un identificador de precio de Stripe disponible en el panel de Stripe:

    use App\Models\User;

    $user = App\Models\User::find(1);

    $user->subscription('default')->swap('price_yearly');

Si el cliente está en periodo de prueba, el periodo de prueba se mantendrá. Además, si existe una "cantidad" para la suscripción, esa cantidad también se mantendrá.

Si desea intercambiar precios y cancelar cualquier periodo de prueba en el que se encuentre el cliente, puede invocar el método `skipTrial`:

    $user->subscription('default')
            ->skipTrial()
            ->swap('price_yearly');

Si desea intercambiar precios y facturar inmediatamente al cliente en lugar de esperar a su próximo ciclo de facturación, puede utilizar el método `swapAndInvoice`:

    $user = User::find(1);

    $user->subscription('default')->swapAndInvoice('price_yearly');

<a name="prorations"></a>
#### Prorrateos

Por defecto, Stripe prorratea los cargos al intercambiar precios. Se puede utilizar el método `noProrate` para actualizar el precio de la suscripción sin prorratear los cargos:

    $user->subscription('default')->noProrate()->swap('price_yearly');

Para más información sobre el prorrateo de suscripciones, consulte la [documentación de Stripe](https://stripe.com/docs/billing/subscriptions/prorations).

> **Advertencia**  
> La ejecución del método `noProrate` antes del método `swapAndInvoice` no tendrá ningún efecto sobre el prorrateo. Siempre se emitirá una factura.

<a name="subscription-quantity"></a>
### Cantidad de suscripciones

A veces las suscripciones se ven afectadas por la "cantidad". Por ejemplo, una aplicación de gestión de proyectos podría cobrar 10 dólares al mes por proyecto. Puede utilizar los métodos `incrementQuantity` y `decrementQuantity` para aumentar o disminuir fácilmente la cantidad de su suscripción:

    use App\Models\User;

    $user = User::find(1);

    $user->subscription('default')->incrementQuantity();

    // Add five to the subscription's current quantity...
    $user->subscription('default')->incrementQuantity(5);

    $user->subscription('default')->decrementQuantity();

    // Subtract five from the subscription's current quantity...
    $user->subscription('default')->decrementQuantity(5);

De manera alternativa, puede establecer una cantidad específica utilizando el método `updateQuantity`:

    $user->subscription('default')->updateQuantity(10);

El método `noProrate` puede utilizarse para actualizar la cantidad de la suscripción sin prorratear los cargos:

    $user->subscription('default')->noProrate()->updateQuantity(10);

Para más información sobre cantidades de suscripción, consulte la [documentación de Stripe](https://stripe.com/docs/subscriptions/quantities).

<a name="quantities-for-subscription-with-multiple-products"></a>
#### Cantidades para suscripciones con varios productos

Si su suscripción es una suscripción [con múltiples productos](#subscriptions-with-multiple-products), debe pasar el ID del precio cuya cantidad desea aumentar o disminuir como segundo argumento a los métodos increment / decrement:

    $user->subscription('default')->incrementQuantity(1, 'price_chat');

<a name="subscriptions-with-multiple-products"></a>
### Suscripciones con varios productos

Las[suscripciones con múltiples productos](https://stripe.com/docs/billing/subscriptions/multiple-products) le permiten asignar múltiples productos de facturación a una única suscripción. Por ejemplo, imagine que está creando una aplicación de servicio de atención al cliente que tiene un precio de suscripción base de 10 al mes, pero que ofrece un producto adicional de chat en directo por 15 al mes. La información de las suscripciones con múltiples productos se almacena en la tabla de base de datos `subscription_items` de Cashier.

Puede especificar varios productos para una suscripción determinada pasando una array de precios como segundo argumento al método `newSubscription`:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $request->user()->newSubscription('default', [
            'price_monthly',
            'price_chat',
        ])->create($request->paymentMethodId);

        // ...
    });

En el ejemplo anterior, el cliente tendrá dos precios asociados a su suscripción `predeterminada`. Ambos precios se cobrarán en sus respectivos intervalos de facturación. Si es necesario, puede utilizar el método `quantity` para indicar una cantidad específica para cada precio:

    $user = User::find(1);

    $user->newSubscription('default', ['price_monthly', 'price_chat'])
        ->quantity(5, 'price_chat')
        ->create($paymentMethod);

Si desea añadir otro precio a una suscripción existente, puede invocar el método `addPrice` de la suscripción:

    $user = User::find(1);

    $user->subscription('default')->addPrice('price_chat');

El ejemplo anterior añadirá el nuevo precio y se facturará al cliente en su próximo ciclo de facturación. Si desea facturar al cliente inmediatamente, puede utilizar el método `addPriceAndInvoice`:

    $user->subscription('default')->addPriceAndInvoice('price_chat');

Si desea añadir un precio con una cantidad específica, puede pasar la cantidad como segundo argumento de los métodos `addPrice` o `addPriceAndInvoice`:

    $user = User::find(1);

    $user->subscription('default')->addPrice('price_chat', 5);

Puede eliminar precios de suscripciones utilizando el método `removePrice`:

    $user->subscription('default')->removePrice('price_chat');

> **Advertencia**  
> No debe eliminar el último precio de una suscripción. En su lugar, simplemente debe cancelar la suscripción.

<a name="swapping-prices"></a>
#### Cambio de precios

También puede cambiar los precios adjuntos a una suscripción con múltiples productos. Por ejemplo, imagine que un cliente tiene una suscripción `price_basic` con un producto complementario `price_chat` y usted desea cambiar al cliente del precio `price_basic` al precio `price_pro`:

    use App\Models\User;

    $user = User::find(1);

    $user->subscription('default')->swap(['price_pro', 'price_chat']);

Al ejecutar el ejemplo anterior, se elimina el elemento de suscripción subyacente con el `price_basic` y se conserva el que tiene el `price_chat`. Además, se crea un nuevo elemento de suscripción para el `precio_pro`.

También puede especificar opciones de elementos de suscripción pasando una array de pares clave/valor al método `swap`. Por ejemplo, puede que necesite especificar las cantidades del precio de suscripción:

    $user = User::find(1);

    $user->subscription('default')->swap([
        'price_pro' => ['quantity' => 5],
        'price_chat'
    ]);

Si desea intercambiar un único precio en una suscripción, puede hacerlo utilizando el método `swap` en el propio elemento de suscripción. Este método es especialmente útil si desea conservar todos los metadatos existentes en los demás precios de la suscripción:

    $user = User::find(1);

    $user->subscription('default')
            ->findItemOrFail('price_basic')
            ->swap('price_pro');

<a name="proration"></a>
#### Prorrateo

De forma predeterminada, Stripe prorrateará los cargos al añadir o eliminar precios de una suscripción con varios productos. Si desea realizar un ajuste de precio sin prorrateo, debe encadenar el método `noProrate` en su operación de precio:

    $user->subscription('default')->noProrate()->removePrice('price_chat');

<a name="swapping-quantities"></a>
#### Cantidades

Si desea actualizar las cantidades de los precios de suscripción individuales, puede hacerlo utilizando los [métodos de cantidad existentes](#subscription-quantity) pasando el nombre del precio como argumento adicional al método:

    $user = User::find(1);

    $user->subscription('default')->incrementQuantity(5, 'price_chat');

    $user->subscription('default')->decrementQuantity(3, 'price_chat');

    $user->subscription('default')->updateQuantity(10, 'price_chat');

> **Advertencia**  
> Cuando una suscripción tiene varios precios, los atributos `stripe_price` y `quantity` del modelo de `suscripción` serán `null`. Para acceder a los atributos de precio individuales, debe utilizar la relación `items` disponible en el modelo `Subscription`.

<a name="subscription-items"></a>
#### Elementos de suscripción

Cuando una suscripción tiene varios precios, tendrá varios "artículos" de suscripción almacenados en la tabla `subscription_items` de su base de datos. Puede acceder a ellos a través de la relación `items` de la suscripción:

    use App\Models\User;

    $user = User::find(1);

    $subscriptionItem = $user->subscription('default')->items->first();

    // Retrieve the Stripe price and quantity for a specific item...
    $stripePrice = $subscriptionItem->stripe_price;
    $quantity = $subscriptionItem->quantity;

También puede recuperar un precio específico utilizando el método `findItemOrFail`:

    $user = User::find(1);

    $subscriptionItem = $user->subscription('default')->findItemOrFail('price_chat');

<a name="metered-billing"></a>
### Facturación por contador

La [facturación por contador](https://stripe.com/docs/billing/subscriptions/metered-billing) permite cobrar a los clientes en función del uso del producto durante un ciclo de facturación. Por ejemplo, puede cobrar a los clientes en función del número de mensajes de texto o correos electrónicos que envían al mes.

Para empezar a utilizar la facturación por contador, primero tendrá que crear un nuevo producto en su panel de Stripe con un precio por contador. A continuación, utilice el `meteredPrice` para añadir el ID de precio por contador a una suscripción de cliente:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $request->user()->newSubscription('default')
            ->meteredPrice('price_metered')
            ->create($request->paymentMethodId);

        // ...
    });

También puede iniciar una suscripción con contador a través de [Stripe Checkout](#checkout):

    $checkout = Auth::user()
            ->newSubscription('default', [])
            ->meteredPrice('price_metered')
            ->checkout();

    return view('your-checkout-view', [
        'checkout' => $checkout,
    ]);

<a name="reporting-usage"></a>
#### Informes de uso

A medida que su cliente utilice su aplicación, deberá informar de su uso a Stripe para que se le pueda facturar con precisión. Para incrementar el uso de una suscripción con contador, puede utilizar el método `reportUsage`:

    $user = User::find(1);

    $user->subscription('default')->reportUsage();

Por defecto, se añade una "cantidad de uso" de 1 al periodo de facturación. De manera alternativa, puede pasar una cantidad específica de "uso" para añadir al uso del cliente para el período de facturación:

    $user = User::find(1);

    $user->subscription('default')->reportUsage(15);

Si su aplicación ofrece varios precios en una única suscripción, tendrá que utilizar el método `reportUsageFor` para especificar el precio medido para el que desea informar del uso:

    $user = User::find(1);

    $user->subscription('default')->reportUsageFor('price_metered', 15);

A veces, puede que necesite actualizar el uso que ha informado previamente. Para ello, puede pasar una marca de tiempo o una instancia de `DateTimeInterface` como segundo parámetro a `reportUsage`. Al hacerlo, Stripe actualizará el uso del que se informó en ese momento. Puede seguir actualizando los registros de uso anteriores, ya que la fecha y hora dadas aún se encuentran dentro del período de facturación actual:

    $user = User::find(1);

    $user->subscription('default')->reportUsage(5, $timestamp);

<a name="retrieving-usage-records"></a>
#### Recuperación de registros de uso

Para recuperar el uso anterior de un cliente, puede utilizar el método `usageRecords` de una instancia de suscripción:

    $user = User::find(1);

    $usageRecords = $user->subscription('default')->usageRecords();

Si su aplicación ofrece múltiples precios en una única suscripción, puede utilizar el método `usageRecordsFor` para especificar el precio medido para el que desea recuperar los registros de uso:

    $user = User::find(1);

    $usageRecords = $user->subscription('default')->usageRecordsFor('price_metered');

Los métodos `usageRecords` y `usageRecordsFor` devuelven una instancia de colección que contiene una array asociativo de registros de uso. Puede iterar sobre esta array para mostrar el consumo total de un cliente:

    @foreach ($usageRecords as $usageRecord)
        - Period Starting: {{ $usageRecord['period']['start'] }}
        - Period Ending: {{ $usageRecord['period']['end'] }}
        - Total Usage: {{ $usageRecord['total_usage'] }}
    @endforeach

Para una referencia completa de todos los datos de uso devueltos y cómo utilizar la paginación basada en cursor de Stripe, consulte [la documentación oficial de la API de Stripe](https://stripe.com/docs/api/usage_records/subscription_item_summary_list).

<a name="subscription-taxes"></a>
### Impuestos de suscripción

> **Advertencia**  
> En lugar de calcular los tipos impositivos manualmente, puede [calcular automáticamente los impuestos utilizando Stripe Tax](#tax-configuration)

Para especificar los tipos impositivos que paga un usuario en una suscripción, debe implementar el método `taxRates` en su modelo facturable y devolver una array que contenga los ID de tipos impositivos de Stripe. Puede definir estos tipos impositivos en [su panel de control](https://dashboard.stripe.com/test/tax-rates) de Stripe:

    /**
     * The tax rates that should apply to the customer's subscriptions.
     *
     * @return array
     */
    public function taxRates()
    {
        return ['txr_id'];
    }

El método `taxRates` le permite aplicar un tipo impositivo cliente por cliente, lo que puede ser útil para una base de usuarios que abarque varios países y tipos impositivos.

Si ofrece suscripciones con varios productos, puede definir diferentes tipos impositivos para cada precio implementando un método `priceTaxRates` en su modelo de facturación:

    /**
     * The tax rates that should apply to the customer's subscriptions.
     *
     * @return array
     */
    public function priceTaxRates()
    {
        return [
            'price_monthly' => ['txr_id'],
        ];
    }

> **Advertencia**  
> El método `taxRates` sólo se aplica a los cargos de suscripción. Si utiliza Cashier para realizar cargos "puntuales", deberá especificar manualmente el tipo impositivo en ese momento.

<a name="syncing-tax-rates"></a>
#### Sincronización de tipos impositivos

Al cambiar los IDs de tipos impositivos codificados devueltos por el método `taxRates`, la configuración de impuestos en cualquier suscripción existente para el usuario seguirá siendo la misma. Si desea actualizar el valor de impuestos de las suscripciones existentes con los nuevos valores de `taxRates`, debe llamar al método `syncTaxRates` en la instancia de suscripción del usuario:

    $user->subscription('default')->syncTaxRates();

Esto también sincronizará los tipos impositivos de cualquier artículo para una suscripción con múltiples productos. Si su aplicación ofrece suscripciones con múltiples productos, deberá asegurarse de que su modelo de facturación implementa el método `priceTaxRates` [comentado anteriormente](#subscription-taxes).

<a name="tax-exemption"></a>
#### Exención de impuestos

Cashier también ofrece los métodos `isNotTaxExempt`, `isTaxExempt` y `reverseChargeApplies` para determinar si el cliente está exento de impuestos. Estos métodos llamarán a la API de Stripe para determinar el estado de exención de impuestos de un cliente:

    use App\Models\User;

    $user = User::find(1);

    $user->isTaxExempt();
    $user->isNotTaxExempt();
    $user->reverseChargeApplies();

> **Advertencia**  
> Estos métodos también están disponibles en cualquier objeto `Laravel\Cashier\Invoice`. Sin embargo, cuando se invocan sobre un objeto `Factura`, los métodos determinarán el estado de exención en el momento en que se creó la factura.

<a name="subscription-anchor-date"></a>
### Fecha de anclaje de la suscripción

De forma predeterminada, el anclaje del ciclo de facturación es la fecha en que se creó la suscripción o, si se utiliza un período de prueba, la fecha en que finaliza la prueba. Si desea modificar la fecha de anclaje de facturación, puede utilizar el método `anchorBillingCycleOn`:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $anchor = Carbon::parse('first day of next month');

        $request->user()->newSubscription('default', 'price_monthly')
                    ->anchorBillingCycleOn($anchor->startOfDay())
                    ->create($request->paymentMethodId);

        // ...
    });

Para más información sobre la gestión de ciclos de facturación de suscripciones, consulte la [documentación sobre ciclos de facturación de Stripe](https://stripe.com/docs/billing/subscriptions/billing-cycle)

<a name="cancelling-subscriptions"></a>
### Cancelación de suscripciones

Para cancelar una suscripción, llame al método `cancel` de la suscripción del usuario:

    $user->subscription('default')->cancel();

Cuando se cancela una suscripción, Cashier establecerá automáticamente la columna `ends_at` en su tabla `subscriptions` de la base de datos. Esta columna se utiliza para saber cuándo el método `subscribed` debe empezar a devolver `false`.

Por ejemplo, si un cliente cancela una suscripción el 1 de marzo, pero la suscripción no estaba programada para finalizar hasta el 5 de marzo, el método `subscribed` continuará devolviendo `true` hasta el 5 de marzo. Esto se hace porque normalmente se permite a un usuario seguir utilizando una aplicación hasta el final de su ciclo de facturación.

Puede determinar si un usuario ha cancelado su suscripción pero aún está en su "periodo de gracia" utilizando el método `onGracePeriod`:

    if ($user->subscription('default')->onGracePeriod()) {
        //
    }

Si desea cancelar una suscripción inmediatamente, llame al método `cancelNow` en la suscripción del usuario:

    $user->subscription('default')->cancelNow();

Si desea cancelar una suscripción inmediatamente y facturar cualquier uso medido no facturado restante o elementos de factura de prorrateo nuevos / pendientes, llame al método `cancelNowAndInvoice` en la suscripción del usuario:

    $user->subscription('default')->cancelNowAndInvoice();

También puede optar por cancelar la suscripción en un momento determinado:

    $user->subscription('default')->cancelAt(
        now()->addDays(10)
    );

<a name="resuming-subscriptions"></a>
### Reanudación de suscripciones

Si un cliente ha cancelado su suscripción y desea reanudarla, puede invocar el método `resume` en la suscripción. El cliente debe estar aún dentro de su "periodo de gracia" para poder reanudar una suscripción:

    $user->subscription('default')->resume();

Si el cliente cancela una suscripción y luego la reanuda antes de que haya expirado por completo, no se le facturará inmediatamente. En su lugar, su suscripción se reactivará y se le facturará en el ciclo de facturación original.

<a name="subscription-trials"></a>
## Pruebas de suscripción

<a name="with-payment-method-up-front"></a>
### Con método de pago por adelantado

Si desea ofrecer periodos de prueba a sus clientes sin dejar de recopilar la información del método de pago por adelantado, debe utilizar el método `trialDays` al crear sus suscripciones:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $request->user()->newSubscription('default', 'price_monthly')
                    ->trialDays(10)
                    ->create($request->paymentMethodId);

        // ...
    });

Este método establecerá la fecha de finalización del período de prueba en el registro de suscripción dentro de la base de datos e indicará a Stripe que no comience a facturar al cliente hasta después de esta fecha. Al utilizar el método `trialDays`, Cashier sobrescribirá cualquier período de prueba predeterminado configurado para el precio en Stripe.

> **Advertencia**  
> Si la suscripción del cliente no se cancela antes de la fecha de finalización de la prueba se le cobrará tan pronto como la prueba expire, por lo que debe asegurarse de notificar a sus usuarios de su fecha de finalización de la prueba.

El método `trialUntil` le permite proporcionar una instancia `DateTime` que especifica cuando debe finalizar el periodo de prueba:

    use Carbon\Carbon;

    $user->newSubscription('default', 'price_monthly')
                ->trialUntil(Carbon::now()->addDays(10))
                ->create($paymentMethod);

Puede determinar si un usuario está dentro de su periodo de prueba utilizando el método `onTrial` de la instancia de usuario o el método `onTrial` de la instancia de suscripción. Los dos ejemplos siguientes son equivalentes:

    if ($user->onTrial('default')) {
        //
    }

    if ($user->subscription('default')->onTrial()) {
        //
    }

Puede utilizar el método `endTrial` para finalizar inmediatamente una prueba de suscripción:

    $user->subscription('default')->endTrial();

Para determinar si una prueba existente ha caducado, puede utilizar los métodos `hasExpiredTrial`:

    if ($user->hasExpiredTrial('default')) {
        //
    }

    if ($user->subscription('default')->hasExpiredTrial()) {
        //
    }

<a name="defining-trial-days-in-stripe-cashier"></a>
#### Definición de días de prueba en Stripe / Cashier

Puede elegir definir cuántos días de prueba reciben sus precios en el panel de Stripe o pasarlos siempre explícitamente utilizando Cashier. Si elige definir los días de prueba de su precio en Stripe debe tener en cuenta que las nuevas suscripciones, incluyendo las nuevas suscripciones para un cliente que tuvo una suscripción en el pasado, siempre recibirán un período de prueba a menos que llame explícitamente al método `skipTrial()`.

<a name="without-payment-method-up-front"></a>
### Sin método de pago por adelantado

Si desea ofrecer periodos de prueba sin recopilar la información del método de pago del usuario por adelantado, puede establecer la columna `trial_ends_at` en el registro de usuario en la fecha de finalización de prueba que desee. Esto se hace normalmente durante el registro del usuario:

    use App\Models\User;

    $user = User::create([
        // ...
        'trial_ends_at' => now()->addDays(10),
    ]);

> **Advertencia**  
> Asegúrese de añadir un [cast de fecha](/docs/{{version}}/eloquent-mutators##date-casting) para el atributo `trial_ends_at` dentro de la definición de clase de su modelo facturable.

Cashier se refiere a este tipo de prueba como "prueba genérica", ya que no está vinculada a ninguna suscripción existente. El método `onTrial` en la instancia del modelo facturable devolverá `true` si la fecha actual no es posterior al valor de `trial_ends_at`:

    if ($user->onTrial()) {
        // User is within their trial period...
    }

Una vez que esté listo para crear una suscripción real para el usuario, puede utilizar el método `newSubscription` como de costumbre:

    $user = User::find(1);

    $user->newSubscription('default', 'price_monthly')->create($paymentMethod);

Para recuperar la fecha de finalización de la prueba del usuario, puede utilizar el método `trialEndsAt`. Este método devolverá una instancia de fecha Carbon si el usuario está en periodo de prueba o `null` si no lo está. También puede pasar un parámetro opcional de nombre de suscripción si desea obtener la fecha de finalización de la prueba para una suscripción específica que no sea la predeterminada:

    if ($user->onTrial()) {
        $trialEndsAt = $user->trialEndsAt('main');
    }

También puede utilizar el método `onGenericTrial` si desea saber específicamente que el usuario se encuentra dentro de su periodo de prueba "genérico" y aún no ha creado una suscripción real:

    if ($user->onGenericTrial()) {
        // User is within their "generic" trial period...
    }

<a name="extending-trials"></a>
### Ampliación de periodo de pruebas

El método `extendTrial` le permite ampliar el periodo de prueba de una suscripción después de que ésta haya sido creada. Si el periodo de prueba ya ha caducado y ya se está facturando al cliente por la suscripción, aún puede ofrecerle una ampliación del periodo de prueba. El tiempo transcurrido durante el período de prueba se deducirá de la próxima factura del cliente:

    use App\Models\User;

    $subscription = User::find(1)->subscription('default');

    // End the trial 7 days from now...
    $subscription->extendTrial(
        now()->addDays(7)
    );

    // Add an additional 5 days to the trial...
    $subscription->extendTrial(
        $subscription->trial_ends_at->addDays(5)
    );

<a name="handling-stripe-webhooks"></a>
## Manejo de Webhooks de Stripe

> **Nota**  
> Puede utilizar [la CLI de Stripe](https://stripe.com/docs/stripe-cli) para probar los webhooks durante el desarrollo local.

Stripe puede notificar a su aplicación de una variedad de eventos a través de webhooks. Por defecto, una ruta que apunta al controlador de webhooks de Cashier es automáticamente registrada por el proveedor de servicios de Cashier. Este controlador gestionará todas las peticiones entrantes de webhooks.

Por defecto, el controlador de webhooks de Cashier gestionará automáticamente la cancelación de suscripciones que tengan demasiados cargos fallidos (según lo definido por su configuración de Stripe), actualizaciones de clientes, eliminaciones de clientes, actualizaciones de suscripciones y cambios en el método de pago; sin embargo, como pronto descubriremos, puede ampliar este controlador para gestionar cualquier evento de webhooks de Stripe que desee.

Para asegurarte de que tu aplicación puede manejar los webhooks de Stripe, asegúrate de configurar la URL del webhook en el panel de control de Stripe. Por defecto, el controlador de webhooks de Cashier responde a la ruta `/stripe/webhook` URL. La lista completa de todos los webhooks que debes habilitar en el panel de control de Stripe son:

- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `customer.updated`
- `customer.deleted`
- `invoice.payment_action_required`

Para mayor comodidad, Cashier incluye un comando `cashier:webhook` Artisan. Este comando creará un webhook en Stripe que escuchará todos los eventos requeridos por Cashier:

```shell
php artisan cashier:webhook
```

Por defecto, el webhook creado apuntará a la URL definida por la variable de entorno `APP_URL` y la ruta `cashier.webhook` que se incluye con Cashier. Puedes proporcionar la opción `--url` al invocar el comando si deseas utilizar una URL diferente:

```shell
php artisan cashier:webhook --url "https://example.com/stripe/webhook"
```

El webhook que se crea utilizará la versión de la API de Stripe con la que tu versión de Cashier sea compatible. Si desea utilizar una versión diferente de Stripe, puede proporcionar la opción `--api-version`:

```shell
php artisan cashier:webhook --api-version="2019-12-03"
```

Tras la creación, el webhook se activará inmediatamente. Si desea crear el webhook pero desactivarlo hasta que esté listo, puede proporcionar la opción `--disabled` al invocar el comando:

```shell
php artisan cashier:webhook --disabled
```

> **Advertencia**  
> Asegúrese de proteger las solicitudes entrantes de webhooks de Stripe con el middleware [verificación de firma de webhooks](#verifying-webhook-signatures) incluido en Cashier.

<a name="webhooks-csrf-protection"></a>
#### Webhooks y Protección CSRF

Dado que los webhooks de Stripe necesitan evitar la [protección CSRF](/docs/{{version}}/csrf) de Laravel, asegúrate de listar el URI como una excepción en el middleware `App\Http\Middleware\VerifyCsrfToken` de tu aplicación o lista la ruta fuera del grupo de middleware `web`:

    protected $except = [
        'stripe/*',
    ];

<a name="defining-webhook-event-handlers"></a>
### Definición de manejadores de eventos Webhook

Cashier gestiona automáticamente las cancelaciones de suscripción por cargos fallidos y otros eventos webhook de Stripe comunes. Sin embargo, si tiene eventos webhook adicionales que le gustaría gestionar, puede hacerlo escuchando los siguientes eventos que son enviados por Cashier:

- `Laravel\Cashier\Events\WebhookReceived`
- `Laravel\Cashier\Events\WebhookHandled`

Ambos eventos contienen la carga completa del webhook de Stripe. Por ejemplo, si deseas gestionar el webhook `invoice.payment_succeeded`, puedes registrar un [listener](/docs/{{version}}/events#defining-listeners) que gestione el evento:

    <?php

    namespace App\Listeners;

    use Laravel\Cashier\Events\WebhookReceived;

    class StripeEventListener
    {
        /**
         * Handle received Stripe webhooks.
         *
         * @param  \Laravel\Cashier\Events\WebhookReceived  $event
         * @return void
         */
        public function handle(WebhookReceived $event)
        {
            if ($event->payload['type'] === 'invoice.payment_succeeded') {
                // Handle the incoming event...
            }
        }
    }

Una vez definido el receptor, puede registrarlo en el `EventServiceProvider` de su aplicación:

    <?php

    namespace App\Providers;

    use App\Listeners\StripeEventListener;
    use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
    use Laravel\Cashier\Events\WebhookReceived;

    class EventServiceProvider extends ServiceProvider
    {
        protected $listen = [
            WebhookReceived::class => [
                StripeEventListener::class,
            ],
        ];
    }

<a name="verifying-webhook-signatures"></a>
### Verificación de Firmas Webhook

Para asegurar sus webhooks, puede utilizar [las firmas webhook de  Stripe](https://stripe.com/docs/webhooks/signatures). Para mayor comodidad, Cashier incluye automáticamente un middleware que valida que la solicitud entrante de webhook de Stripe es válida.

Para habilitar la verificación del webhook, asegúrese de que la variable de entorno `STRIPE_WEBHOOK_SECRET` está configurada en el archivo `.env` de su aplicación. El `secret` del webhook puede recuperarse desde el panel de control de su cuenta de Stripe.

<a name="single-charges"></a>
## Cargos únicos

<a name="simple-charge"></a>
### Cargo simple

Si desea realizar un cargo único al un cliente, puede utilizar el método  `charge` en una instancia de modelo facturable. Necesitará [proporcionar un identificador de método de pago](#payment-methods-for-single-charges) como segundo argumento del método `charge`:

    use Illuminate\Http\Request;

    Route::post('/purchase', function (Request $request) {
        $stripeCharge = $request->user()->charge(
            100, $request->paymentMethodId
        );

        // ...
    });

El método de `charge` acepta un array como tercer argumento, permitiéndote pasar cualquier opción que desees a la creación de cargo subyacente de Stripe. Puede encontrar más información sobre las opciones disponibles al crear cargos en la [documentación de Stripe](https://stripe.com/docs/api/charges/create):

    $user->charge(100, $paymentMethod, [
        'custom_option' => $value,
    ]);

También puede utilizar el método de `charge` sin un cliente o usuario subyacente. Para ello, invoque el método `charge` en una nueva instancia del modelo de facturación de su aplicación:

    use App\Models\User;

    $stripeCharge = (new User)->charge(100, $paymentMethod);

El método de `charge` lanzará una excepción si el cargo falla. Si el cargo se realiza correctamente, el método devolverá una instancia de `Laravel\Cashier\Payment`:

    try {
        $payment = $user->charge(100, $paymentMethod);
    } catch (Exception $e) {
        //
    }

> **Advertencia**  
> El método de `charge` acepta el importe de pago en el denominador más bajo de la moneda utilizada por su aplicación. Por ejemplo, si los clientes pagan en dólares estadounidenses, los importes deben especificarse en peniques.

<a name="charge-with-invoice"></a>
### Cargo con factura

A veces puede necesitar realizar un cargo único y ofrecer un recibo en PDF a su cliente. El método `invoicePrice` le permite hacer precisamente eso. Por ejemplo, vamos a facturar a un cliente cinco camisas nuevas:

    $user->invoicePrice('price_tshirt', 5);

La factura se cargará inmediatamente a la forma de pago predeterminada del usuario. El método `invoicePrice` también acepta un array como tercer argumento. Esta array contiene las opciones de facturación para el elemento de la factura. El cuarto argumento aceptado por el método es también un array que debe contener las opciones de facturación de la propia factura:

    $user->invoicePrice('price_tshirt', 5, [
        'discounts' => [
            ['coupon' => 'SUMMER21SALE']
        ],
    ], [
        'default_tax_rates' => ['txr_id'],
    ]);

De forma similar a `invoicePrice`, puede utilizar el método `tabPrice` para crear un cargo único por múltiples artículos (hasta 250 artículos por factura) añadiéndolos a la "ficha" del cliente y facturando después al cliente. Por ejemplo, podemos facturar a un cliente cinco camisetas y dos tazas:

    $user->tabPrice('price_tshirt', 5);
    $user->tabPrice('price_mug', 2);
    $user->invoice();

De manera alternativa, puede utilizar el método `invoiceFor` para hacer un cargo "único" contra el método de pago predeterminado del cliente:

    $user->invoiceFor('One Time Fee', 500);

Aunque el método `invoiceFor` está disponible para su uso, se recomienda que utilice los métodos `invoicePrice` y `tabPrice` con precios predefinidos. De este modo, tendrá acceso a mejores análisis y datos en su panel de control de Stripe en relación con sus ventas por producto.

> **Advertencia**  
> Los métodos `invoice`, `invoicePrice` y `invoiceFor` crearán una factura de Stripe que reintentará los intentos de facturación fallidos. Si no desea que las facturas reintenten cargos fallidos, deberá cerrarlas utilizando la API de Stripe tras el primer cargo fallido.

<a name="creating-payment-intents"></a>
### Creación de intentos de pago

Puedes crear una nueva intención de pago de Stripe invocando el método `pay` en una instancia de modelo facturable. Al llamar a este método se creará una intención de pago envuelta en una instancia `Laravel\Cashier\Payment`:

    use Illuminate\Http\Request;

    Route::post('/pay', function (Request $request) {
        $payment = $request->user()->pay(
            $request->get('amount')
        );

        return $payment->client_secret;
    });

Después de crear la intención de pago, puedes devolver el secreto del cliente al frontend de tu aplicación para que el usuario pueda completar el pago en su navegador. Para obtener más información sobre la creación de flujos de pago completos utilizando intentos de pago de Stripe, consulte la [documentación de Stripe](https://stripe.com/docs/payments/accept-a-payment?platform=web).

Al utilizar el método de `pay`, los métodos de pago predeterminados que están habilitados en su panel de Stripe estarán disponibles para el cliente. De manera alternativa, si sólo desea permitir el uso de algunos métodos de pago específicos, puede utilizar el método `payWith`:

    use Illuminate\Http\Request;

    Route::post('/pay', function (Request $request) {
        $payment = $request->user()->payWith(
            $request->get('amount'), ['card', 'bancontact']
        );

        return $payment->client_secret;
    });

> **Advertencia**  
> Los métodos `pay` y `payWith` aceptan el importe del pago en el denominador más bajo de la moneda utilizada por su aplicación. Por ejemplo, si los clientes pagan en dólares estadounidenses, los importes deben especificarse en peniques.

<a name="refunding-charges"></a>
### Reembolso de cargos

Si necesita reembolsar un cargo de Stripe, puede utilizar el método de `refund`. Este método acepta el [ID de la intención de pago](#payment-methods-for-single-charges) de Stripe como primer argumento:

    $payment = $user->charge(100, $paymentMethodId);

    $user->refund($payment->id);

<a name="invoices"></a>
## Facturas

<a name="retrieving-invoices"></a>
### Recuperación de facturas

Puede recuperar fácilmente una array de facturas de un modelo facturable utilizando el método `invoices`. El método `invoices` devuelve una colección de instancias de `Laravel\Cashier\Invoice`:

    $invoices = $user->invoices();

Si desea incluir las facturas pendientes en los resultados, puede utilizar el método `invoicesIncludingPending`:

    $invoices = $user->invoicesIncludingPending();

Puede utilizar el método `findInvoice` para recuperar una factura específica por su ID:

    $invoice = $user->findInvoice($invoiceId);

<a name="displaying-invoice-information"></a>
#### Visualización de la información de la factura

Al listar las facturas del cliente, puede utilizar los métodos de la factura para mostrar la información relevante de la factura. Por ejemplo, puede listar cada factura en una tabla, permitiendo al usuario descargar fácilmente cualquiera de ellas:

    <table>
        @foreach ($invoices as $invoice)
            <tr>
                <td>{{ $invoice->date()->toFormattedDateString() }}</td>
                <td>{{ $invoice->total() }}</td>
                <td><a href="/user/invoice/{{ $invoice->id }}">Download</a></td>
            </tr>
        @endforeach
    </table>

<a name="upcoming-invoices"></a>
### Próximas facturas

Para recuperar la próxima factura de un cliente, puede utilizar el método `upcomingInvoice`:

    $invoice = $user->upcomingInvoice();

Del mismo modo, si el cliente tiene varias suscripciones, también puede recuperar la próxima factura para una suscripción específica:

    $invoice = $user->subscription('default')->upcomingInvoice();

<a name="previewing-subscription-invoices"></a>
### Vista previa de facturas de suscripción

Utilizando el método `previewInvoice`, puede previsualizar una factura antes de realizar cambios en el precio. Esto le permitirá determinar qué aspecto tendrá la factura de su cliente cuando se realice un cambio de precio determinado:

    $invoice = $user->subscription('default')->previewInvoice('price_yearly');

Puede pasar un array de precios al método `previewInvoice` para previsualizar facturas con múltiples precios nuevos:

    $invoice = $user->subscription('default')->previewInvoice(['price_yearly', 'price_metered']);

<a name="generating-invoice-pdfs"></a>
### Generar PDFs de facturas

Antes de generar las facturas en PDF, debe utilizar Composer para instalar la biblioteca Dompdf, que es el renderizador de facturas predeterminado para Cashier:

```php
composer require dompdf/dompdf
```

Desde una ruta o controlador, puede utilizar el método `downloadInvoice` para generar una descarga PDF de una factura determinada. Este método generará automáticamente la respuesta HTTP necesaria para descargar la factura:

    use Illuminate\Http\Request;

    Route::get('/user/invoice/{invoice}', function (Request $request, $invoiceId) {
        return $request->user()->downloadInvoice($invoiceId);
    });

Por defecto, todos los datos de la factura se derivan de los datos del cliente y de la factura almacenados en Stripe. El nombre del archivo se basa en el valor de configuración de `app.name`. Sin embargo, puede personalizar algunos de estos datos proporcionando una array como segundo argumento del método `downloadInvoice`. Este array te permite personalizar información como los detalles de tu empresa y producto:

    return $request->user()->downloadInvoice($invoiceId, [
        'vendor' => 'Your Company',
        'product' => 'Your Product',
        'street' => 'Main Str. 1',
        'location' => '2000 Antwerp, Belgium',
        'phone' => '+32 499 00 00 00',
        'email' => 'info@example.com',
        'url' => 'https://example.com',
        'vendorVat' => 'BE123456789',
    ]);

El método `downloadInvoice` también permite un nombre de archivo personalizado a través de su tercer argumento. Este nombre de archivo tendrá automáticamente el sufijo `.pdf`:

    return $request->user()->downloadInvoice($invoiceId, [], 'my-invoice');

<a name="custom-invoice-render"></a>
#### Generador de facturas propios

Cashier también permite utilizar un renderizador de facturas propio. Por defecto, Cashier utiliza la implementación `DompdfInvoiceRenderer`, que utiliza la librería [dompdf](https://github.com/dompdf/dompdf) de PHP para generar las facturas de Cashier. Sin embargo, puede utilizar cualquier renderizador que desee mediante la implementación de la interfaz `Laravel\Cashier\Contracts\InvoiceRenderer`. Por ejemplo, puede que desee renderizar una factura PDF utilizando una llamada API a un servicio de renderizado PDF de terceros:

    use Illuminate\Support\Facades\Http;
    use Laravel\Cashier\Contracts\InvoiceRenderer;
    use Laravel\Cashier\Invoice;

    class ApiInvoiceRenderer implements InvoiceRenderer
    {
        /**
         * Render the given invoice and return the raw PDF bytes.
         *
         * @param  \Laravel\Cashier\Invoice. $invoice
         * @param  array  $data
         * @param  array  $options
         * @return string
         */
        public function render(Invoice $invoice, array $data = [], array $options = []): string
        {
            $html = $invoice->view($data)->render();

            return Http::get('https://example.com/html-to-pdf', ['html' => $html])->get()->body();
        }
    }

Una vez que haya implementado el contrato de renderizado de facturas, debe actualizar el valor de configuración `cashier.invoices.renderer` en el archivo de configuración `config/cashier.php` de su aplicación. Este valor de configuración debe establecerse con el nombre de clase de la implementación de su renderizador personalizado.

<a name="checkout"></a>
## Pago

Cashier Stripe también proporciona soporte para [Stripe Checkout](https://stripe.com/payments/checkout)out. Stripe Checkout facilita la implementación de páginas personalizadas para aceptar pagos, proporcionando una página de pago pre-construida y alojada.

La siguiente documentación contiene información sobre cómo empezar a utilizar Stripe Checkout con Cashier. Para obtener más información sobre Stripe Checkout, también puede consultar [la documentación de Stripe Checkout](https://stripe.com/docs/payments/checkout).

<a name="product-checkouts"></a>
### Comprobación de productos

Puede realizar un pago para un producto existente que haya sido creado dentro de su panel de control de Stripe utilizando el método de `checkout` en un modelo facturable. El método de `checkout` iniciará una nueva sesión de Stripe Checkout. Por defecto, se le pedirá que pase un ID de precio de Stripe:

    use Illuminate\Http\Request;

    Route::get('/product-checkout', function (Request $request) {
        return $request->user()->checkout('price_tshirt');
    });

Si es necesario, también puede especificar una cantidad de producto:

    use Illuminate\Http\Request;

    Route::get('/product-checkout', function (Request $request) {
        return $request->user()->checkout(['price_tshirt' => 15]);
    });

Cuando un cliente visite esta ruta será redirigido a la página de pago de Stripe. Por defecto, cuando un usuario completa con éxito o cancela una compra será redirigido a la ubicación de su ruta de `inicio`, pero puede especificar URLs de devolución de llamada personalizadas utilizando las opciones `success_url` y `cancel_url`:

    use Illuminate\Http\Request;

    Route::get('/product-checkout', function (Request $request) {
        return $request->user()->checkout(['price_tshirt' => 1], [
            'success_url' => route('your-success-route'),
            'cancel_url' => route('your-cancel-route'),
        ]);
    });

Al definir su opción de pago `success_url`, puede indicar a Stripe que añada el ID de sesión de pago como parámetro de cadena de consulta al invocar su URL. Para ello, añada la cadena literal `{CHECKOUT_SESSION_ID}` a su cadena de consulta `success_url`. Stripe sustituirá este marcador de posición por el ID de sesión de pago real:

    use Illuminate\Http\Request;
    use Stripe\Checkout\Session;
    use Stripe\Customer;

    Route::get('/product-checkout', function (Request $request) {
        return $request->user()->checkout(['price_tshirt' => 1], [
            'success_url' => route('checkout-success').'?session_id={CHECKOUT_SESSION_ID}',
            'cancel_url' => route('checkout-cancel'),
        ]);
    });

    Route::get('/checkout-success', function (Request $request) {
        $checkoutSession = $request->user()->stripe()->checkout->sessions->retrieve($request->get('session_id'));

        return view('checkout.success', ['checkoutSession' => $checkoutSession]);
    })->name('checkout-success');

<a name="checkout-promotion-codes"></a>
#### Códigos de promoción

Por defecto, Stripe Checkout no permite [códigos promocionales canjeables por el usuario](https://stripe.com/docs/billing/subscriptions/discounts/codes). Por suerte, existe una forma sencilla de habilitarlos para su página de Pago. Para ello, puede invocar el método `allowPromotionCodes`:

    use Illuminate\Http\Request;

    Route::get('/product-checkout', function (Request $request) {
        return $request->user()
            ->allowPromotionCodes()
            ->checkout('price_tshirt');
    });

<a name="single-charge-checkouts"></a>
### Cobros simples

También puede realizar un cargo simple para un producto ad-hoc que no haya sido creado en su panel de Stripe. Para ello puede utilizar el método `checkoutCharge` en un modelo facturable y pasarle un importe facturable, un nombre de producto y una cantidad opcional. Cuando un cliente visite esta ruta será redirigido a la página de pago de Stripe:

    use Illuminate\Http\Request;

    Route::get('/charge-checkout', function (Request $request) {
        return $request->user()->checkoutCharge(1200, 'T-Shirt', 5);
    });

> **Advertencia**  
> Al utilizar el método `checkoutCharge`, Stripe siempre creará un nuevo producto y precio en su panel de Stripe. Por lo tanto, le recomendamos que cree los productos por adelantado en su panel de Stripe y utilice el método de `checkout` en su lugar.

<a name="subscription-checkouts"></a>
### Pago de suscripciones

> **Advertencia**  
> El uso de Stripe Checkout para suscripciones requiere que habilite el webhook `customer.subscription.created` en su panel de Stripe. Este webhook creará el registro de suscripción en su base de datos y almacenará todos los elementos de suscripción relevantes.

También puede utilizar Stripe Checkout para iniciar suscripciones. Después de definir su suscripción con los métodos de creación de suscripciones de Cashier, puede llamar al método `checkout`. Cuando un cliente visite esta ruta será redirigido a la página de pago de Stripe:

    use Illuminate\Http\Request;

    Route::get('/subscription-checkout', function (Request $request) {
        return $request->user()
            ->newSubscription('default', 'price_monthly')
            ->checkout();
    });

Al igual que con las compras de productos, puede personalizar las URL de éxito y cancelación:

    use Illuminate\Http\Request;

    Route::get('/subscription-checkout', function (Request $request) {
        return $request->user()
            ->newSubscription('default', 'price_monthly')
            ->checkout([
                'success_url' => route('your-success-route'),
                'cancel_url' => route('your-cancel-route'),
            ]);
    });

Por supuesto, también puede habilitar códigos de promoción para los pagos de suscripciones:

    use Illuminate\Http\Request;

    Route::get('/subscription-checkout', function (Request $request) {
        return $request->user()
            ->newSubscription('default', 'price_monthly')
            ->allowPromotionCodes()
            ->checkout();
    });

> **Advertencia**  
> Lamentablemente, Stripe Checkout no admite todas las opciones de facturación de suscripción al iniciar suscripciones. El uso del método `anchorBillingCycleOn` en el generador de suscripciones, la configuración del comportamiento de prorrateo o la configuración del comportamiento de pago no tendrán ningún efecto durante las sesiones de Stripe Checkout. Consulte la [documentación de la API de sesión de Stripe Checkout](https://stripe.com/docs/api/checkout/sessions/create) para revisar qué parámetros están disponibles.

<a name="stripe-checkout-trial-periods"></a>
#### Pago con Stripe y periodos de prueba

Por supuesto, puede definir un período de prueba al crear una suscripción que se completará mediante Stripe Checkout:

    $checkout = Auth::user()->newSubscription('default', 'price_monthly')
        ->trialDays(3)
        ->checkout();

Sin embargo, el período de prueba debe ser de al menos 48 horas, que es la cantidad mínima de tiempo de prueba que admite Stripe Checkout.

<a name="stripe-checkout-subscriptions-and-webhooks"></a>
#### Suscripciones y Webhooks

Recuerde que Stripe y Cashier actualizan el estado de las suscripciones a través de webhooks, por lo que existe la posibilidad de que una suscripción aún no esté activa cuando el cliente vuelva a la aplicación después de introducir su información de pago. Para manejar este escenario, es posible que desee mostrar un mensaje informando al usuario de que su pago o suscripción está pendiente.

<a name="collecting-tax-ids"></a>
### Recopilación de identificadores fiscales

El proceso de pago también permite recopilar el número de identificación fiscal del cliente. Para activarlo en una sesión de pago, invoque el método `collectTaxIds` al crear la sesión:

    $checkout = $user->collectTaxIds()->checkout('price_tshirt');

Cuando se invoque este método, el cliente dispondrá de una nueva casilla de verificación que le permitirá indicar si está comprando como empresa. Si es así, tendrán la oportunidad de proporcionar su número de identificación fiscal.

> **Advertencia**  
> Si ya ha configurado [la recaudación automática de impuestos](#tax-configuration) en el proveedor de servicios de su aplicación, esta función se habilitará automáticamente y no será necesario invocar el método `collectTaxIds`.

<a name="guest-checkouts"></a>
### Pagos de invitados

Utilizando el método `Checkout::guest`, puede iniciar sesiones de pago para clientes de su aplicación que no tengan una "cuenta":

    use Illuminate\Http\Request;
    use Laravel\Cashier\Checkout;

    Route::get('/product-checkout', function (Request $request) {
        return Checkout::guest()->create('price_tshirt', [
            'success_url' => route('your-success-route'),
            'cancel_url' => route('your-cancel-route'),
        ]);
    });

De forma similar a cuando se crean sesiones de pago para usuarios existentes, puede utilizar métodos adicionales disponibles en la instancia `Laravel\Cashier\CheckoutBuilder` para personalizar la sesión de pago de invitados:

    use Illuminate\Http\Request;
    use Laravel\Cashier\Checkout;

    Route::get('/product-checkout', function (Request $request) {
        return Checkout::guest()
            ->withPromotionCode('promo-code')
            ->create('price_tshirt', [
                'success_url' => route('your-success-route'),
                'cancel_url' => route('your-cancel-route'),
            ]);
    });

Una vez completado el pago, Stripe puede enviar un evento webhook `checkout.session.completed`, así que asegúrate de [configurar tu webhook de Stripe](https://dashboard.stripe.com/webhooks) para que envíe este evento a tu aplicación. Una vez que el webhook ha sido habilitado dentro del panel de Stripe, puede [manejar el webhook con Cashier](#handling-stripe-webhooks). El objeto contenido en la carga útil del webhook será un [objeto de`pago`](https://stripe.com/docs/api/checkout/sessions/object) que podrá inspeccionar para completar el pedido de su cliente.

<a name="handling-failed-payments"></a>
## Gestión de pagos fallidos

A veces, los pagos por suscripciones o cargos únicos pueden fallar. Cuando esto sucede, Cashier lanzará una excepción `Laravel\Cashier\Exceptions\IncompletePayment` que le informa de que esto ha sucedido. Después de capturar esta excepción, tiene dos opciones sobre cómo proceder.

En primer lugar, puede redirigir al cliente a la página de confirmación de pago que se incluye con el Cashier. Esta página ya tiene una ruta asociada registrada a través del proveedor de servicios de Cashier. Así, puede capturar la excepción `IncompletePayment` y redirigir al usuario a la página de confirmación de pago:

    use Laravel\Cashier\Exceptions\IncompletePayment;

    try {
        $subscription = $user->newSubscription('default', 'price_monthly')
                                ->create($paymentMethod);
    } catch (IncompletePayment $exception) {
        return redirect()->route(
            'cashier.payment',
            [$exception->payment->id, 'redirect' => route('home')]
        );
    }

En la página de confirmación del pago, se le pedirá al cliente que introduzca de nuevo la información de su tarjeta de crédito y realice cualquier acción adicional requerida por Stripe, como la confirmación "3D Secure". Tras confirmar su pago, el usuario será redirigido a la URL proporcionada por el parámetro `redirect`  especificado anteriormente. Tras la redirección, se añadirán a la URL las variables de cadena de consulta `message` (cadena) y `success` (entero). Actualmente, la página de pago admite los siguientes tipos de métodos de pago:

<div class="content-list" markdown="1">

- Credit Cards
- Alipay
- Bancontact
- BECS Direct Debit
- EPS
- Giropay
- iDEAL
- SEPA Direct Debit

</div>

Como alternativa, puede permitir que Stripe gestione la confirmación del pago por usted. En este caso, en lugar de redirigir a la página de confirmación de pago, puede [configurar los correos electrónicos de facturación automática de Stripe](https://dashboard.stripe.com/account/billing/automatic) en su panel de Stripe. Sin embargo, si se detecta una excepción `IncompletePayment`, debe informar al usuario de que recibirá un correo electrónico con más instrucciones de confirmación del pago.

Se pueden lanzar excepciones de pago para los siguientes métodos: `charge`, `invoiceFor` y `invoice` en modelos que utilicen el trait `Billable`. Al interactuar con suscripciones, el método `create` del `SubscriptionBuilder` y los métodos `incrementAndInvoice` y `swapAndInvoice` de los modelos `Subscription` y `SubscriptionItem` pueden lanzar excepciones de pago incompleto.

Para determinar si una suscripción existente tiene un pago incompleto, se puede utilizar el método `hasIncompletePayment` en el modelo facturable o en una instancia de suscripción:

    if ($user->hasIncompletePayment('default')) {
        //
    }

    if ($user->subscription('default')->hasIncompletePayment()) {
        //
    }

Puede obtener el estado específico de un pago incompleto inspeccionando la propiedad de `payment` en la instancia de excepción:

    use Laravel\Cashier\Exceptions\IncompletePayment;

    try {
        $user->charge(1000, 'pm_card_threeDSecure2Required');
    } catch (IncompletePayment $exception) {
        // Get the payment intent status...
        $exception->payment->status;

        // Check specific conditions...
        if ($exception->payment->requiresPaymentMethod()) {
            // ...
        } elseif ($exception->payment->requiresConfirmation()) {
            // ...
        }
    }

<a name="strong-customer-authentication"></a>
## Autenticación fuerte de clientes

Si su empresa o uno de sus clientes tiene su sede en Europa, deberá cumplir la normativa de autenticación fuerte de clientes (SCA) de la UE. Esta normativa fue impuesta en septiembre de 2019 por la Unión Europea para prevenir el fraude en los pagos. Por suerte, Stripe y Cashier están preparados para construir aplicaciones que cumplan con SCA.

> **Advertencia**  
> Antes de empezar, revise [la guía de Stripe sobre PSD2 y SCA](https://stripe.com/guides/strong-customer-authentication), así como su [documentación sobre las nuevas API de SCA](https://stripe.com/docs/strong-customer-authentication).

<a name="payments-requiring-additional-confirmation"></a>
### Pagos que requieren confirmación adicional

Las regulaciones SCA a menudo requieren una verificación adicional para confirmar y procesar un pago. Cuando esto ocurra, Cashier lanzará una excepción `Laravel\Cashier\Exceptions\IncompletePayment` que le informará de que es necesaria una verificación adicional. Más información sobre cómo manejar estas excepciones se puede encontrar en la documentación sobre el [manejo de pagos fallidos](#handling-failed-payments).

Las pantallas de confirmación de pago presentadas por Stripe o Cashier pueden adaptarse al flujo de pago de un banco o emisor de tarjeta específico y pueden incluir confirmación de tarjeta adicional, un pequeño cargo temporal, autenticación de dispositivo independiente u otras formas de verificación.

<a name="incomplete-and-past-due-state"></a>
#### Estado incompleto y vencido

Cuando un pago necesita confirmación adicional, la suscripción permanecerá en estado `incomplete` o `past_due`, tal y como indica su columna de base de datos `stripe_status`. Cashier activará automáticamente la suscripción del cliente tan pronto como se complete la confirmación del pago y su aplicación sea notificada por Stripe a través del webhook de finalización de pago.

Para obtener más información sobre los estados `incomplete` y `past_due`, consulte [nuestra documentación adicional sobre estos estados](#incomplete-and-past-due-status).

<a name="off-session-payment-notifications"></a>
### Notificaciones de pago fuera de sesión

Dado que la normativa SCA requiere que los clientes verifiquen ocasionalmente sus detalles de pago incluso mientras su suscripción está activa, Cashier puede enviar una notificación al cliente cuando se requiera una confirmación de pago fuera de sesión. Por ejemplo, esto puede ocurrir cuando se renueva una suscripción. La notificación de pago de Cashier puede activarse estableciendo la variable de entorno `CASHIER_PAYMENT_NOTIFICATION` en una clase de notificación. Por defecto, esta notificación está desactivada. Por supuesto, Cashier incluye una clase de notificación que puede utilizar para este propósito, pero usted es libre de proporcionar su propia clase de notificación si lo desea:

```ini
CASHIER_PAYMENT_NOTIFICATION=Laravel\Cashier\Notifications\ConfirmPayment
```

Para asegurarse de que se envían notificaciones de confirmación de pago fuera de sesión, compruebe que [los webhooks de Stripe están configurados](#handling-stripe-webhooks) para su aplicación y que el webhook `invoice.payment_action_required` está habilitado en su panel de Stripe. Además, tu modelo `Billable` también debería utilizar el trait `Illuminate\Notifications\Notifiable` de Laravel.

> **Aviso**  
> Las notificaciones se enviarán incluso cuando los clientes realicen manualmente un pago que requiera confirmación adicional. Desafortunadamente, no hay forma de que Stripe sepa que el pago se hizo manualmente o "fuera de sesión". Sin embargo, un cliente simplemente verá un mensaje de "Pago correcto" si visita la página de pago después de haber confirmado su pago. El cliente no podrá confirmar accidentalmente el mismo pago dos veces e incurrir en un segundo cargo accidental.

<a name="stripe-sdk"></a>
## SDK de Stripe

Muchos de los objetos de Cashier son envoltorios de objetos del SDK de Stripe. Si desea interactuar con los objetos Stripe directamente, puede recuperarlos convenientemente utilizando el método `asStripe`:

    $stripeSubscription = $subscription->asStripeSubscription();

    $stripeSubscription->application_fee_percent = 5;

    $stripeSubscription->save();

También puede utilizar el método `updateStripeSubscription` para actualizar una suscripción de Stripe directamente:

    $subscription->updateStripeSubscription(['application_fee_percent' => 5]);

Puede invocar el método `stripe` en la clase `Cashier` si desea utilizar el cliente `Stripe\StripeClient` directamente. Por ejemplo, podría utilizar este método para acceder a la instancia `StripeClient` y recuperar una lista de precios de su cuenta Stripe:

    use Laravel\Cashier\Cashier;

    $prices = Cashier::stripe()->prices->all();

<a name="testing"></a>
## Testing

Cuando pruebe una aplicación que utilice Cashier, puede "mockear" las peticiones HTTP reales a la API de Stripe; sin embargo, esto requiere que reimplemente parcialmente el propio comportamiento de Cashier. Por lo tanto, le recomendamos que permita que sus tests accedan a la API real de Stripe. Aunque esto es más lento, proporciona más confianza en que su aplicación está funcionando como se esperaba y cualquier tests lenta puede ser colocada dentro de su propio grupo de pruebas PHPUnit.

Al realizar las pruebas, recuerde que Cashier en sí ya tiene un gran conjunto de test, por lo que sólo debe centrarse en probar la suscripción y el flujo de pago de su propia aplicación y no todos los comportamientos subyacentes de Cashier.

Para empezar, añada la versión de **prueba** de su secreto Stripe a su archivo `phpunit.xml`:

    <env name="STRIPE_SECRET" value="sk_test_<your-key>"/>

Ahora, cada vez que interactúe con Cashier durante las pruebas, enviará solicitudes reales de la API a su entorno de pruebas de Stripe. Para mayor comodidad, usted debe pre-llenar su cuenta de prueba de Stripe con suscripciones / precios que puede utilizar durante las pruebas.

> **Nota**  
> Con el fin de testear una variedad de escenarios de facturación, tales como denegaciones de tarjetas de crédito y fallos, puede utilizar la amplia gama de [números de tarjetas de prueba y tokens](https://stripe.com/docs/testing) proporcionados por Stripe.
