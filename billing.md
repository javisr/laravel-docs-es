# Laravel Cashier (Stripe)

- [Introducción](#introduction)
- [Actualizando Cashier](#upgrading-cashier)
- [Instalación](#installation)
- [Configuración](#configuration)
  - [Modelo Facturable](#billable-model)
  - [Claves API](#api-keys)
  - [Configuración de Moneda](#currency-configuration)
  - [Configuración de Impuestos](#tax-configuration)
  - [Registro](#logging)
  - [Usando Modelos Personalizados](#using-custom-models)
- [Inicio Rápido](#quickstart)
  - [Vendiendo Productos](#quickstart-selling-products)
  - [Vendiendo Suscripciones](#quickstart-selling-subscriptions)
- [Clientes](#customers)
  - [Recuperar Clientes](#retrieving-customers)
  - [Crear Clientes](#creating-customers)
  - [Actualizar Clientes](#updating-customers)
  - [Balances](#balances)
  - [IDs de Impuesto](#tax-ids)
  - [Sincronizar Datos de Clientes con Stripe](#syncing-customer-data-with-stripe)
  - [Portal de Facturación](#billing-portal)
- [Métodos de Pago](#payment-methods)
  - [Almacenar Métodos de Pago](#storing-payment-methods)
  - [Recuperar Métodos de Pago](#retrieving-payment-methods)
  - [Presencia del Método de Pago](#payment-method-presence)
  - [Actualizar el Método de Pago Predeterminado](#updating-the-default-payment-method)
  - [Agregar Métodos de Pago](#adding-payment-methods)
  - [Eliminar Métodos de Pago](#deleting-payment-methods)
- [Suscripciones](#subscriptions)
  - [Crear Suscripciones](#creating-subscriptions)
  - [Verificar Estado de Suscripción](#checking-subscription-status)
  - [Cambiar Precios](#changing-prices)
  - [Cantidad de Suscripciones](#subscription-quantity)
  - [Suscripciones con Múltiples Productos](#subscriptions-with-multiple-products)
  - [Múltiples Suscripciones](#multiple-subscriptions)
  - [Facturación Medida](#metered-billing)
  - [Impuestos de Suscripciones](#subscription-taxes)
  - [Fecha Ancla de Suscripción](#subscription-anchor-date)
  - [Cancelar Suscripciones](#cancelling-subscriptions)
  - [Reanudar Suscripciones](#resuming-subscriptions)
- [Pruebas de Suscripción](#subscription-trials)
  - [Con Método de Pago por Adelantado](#with-payment-method-up-front)
  - [Sin Método de Pago por Adelantado](#without-payment-method-up-front)
  - [Extender Pruebas](#extending-trials)
- [Manejo de Webhooks de Stripe](#handling-stripe-webhooks)
  - [Definir Controladores de Eventos de Webhook](#defining-webhook-event-handlers)
  - [Verificar Firmas de Webhook](#verifying-webhook-signatures)
- [Cargos Únicos](#single-charges)
  - [Cargo Simple](#simple-charge)
  - [Cargo con Factura](#charge-with-invoice)
  - [Crear Intenciones de Pago](#creating-payment-intents)
  - [Reembolsar Cargos](#refunding-charges)
- [Checkout](#checkout)
  - [Checkout de Productos](#product-checkouts)
  - [Checkout de Cargos Únicos](#single-charge-checkouts)
  - [Checkout de Suscripciones](#subscription-checkouts)
  - [Recoger IDs de Impuesto](#collecting-tax-ids)
  - [Checkout de Invitados](#guest-checkouts)
- [Facturas](#invoices)
  - [Recuperar Facturas](#retrieving-invoices)
  - [Facturas Próximas](#upcoming-invoices)
  - [Previsualizar Facturas de Suscripción](#previewing-subscription-invoices)
  - [Generar PDFs de Facturas](#generating-invoice-pdfs)
- [Manejo de Pagos Fallidos](#handling-failed-payments)
  - [Confirmar Pagos](#confirming-payments)
- [Autenticación Fuerte de Clientes (SCA)](#strong-customer-authentication)
  - [Pagos que Requieren Confirmación Adicional](#payments-requiring-additional-confirmation)
  - [Notificaciones de Pagos Fuera de Sesión](#off-session-payment-notifications)
- [SDK de Stripe](#stripe-sdk)
- [Pruebas](#testing)

<a name="introduction"></a>
## Introducción

[Laravel Cashier Stripe](https://github.com/laravel/cashier-stripe) proporciona una interfaz fluida y expresiva para los servicios de facturación por suscripción de [Stripe](https://stripe.com). Maneja casi todo el código de facturación por suscripción que temes tener que escribir. Además de la gestión básica de suscripciones, Cashier puede manejar cupones, cambiar suscripciones, "cantidades" de suscripción, períodos de gracia de cancelación e incluso generar PDFs de facturas.

<a name="upgrading-cashier"></a>
## Actualizando Cashier

Al actualizar a una nueva versión de Cashier, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/cashier-stripe/blob/master/UPGRADE.md).
> [!WARNING]
Para prevenir cambios disruptivos, Cashier utiliza una versión fija de la API de Stripe. Cashier 15 utiliza la versión de la API de Stripe `2023-10-16`. La versión de la API de Stripe se actualizará en lanzamientos menores para aprovechar nuevas características y mejoras de Stripe.

<a name="installation"></a>
## Instalación

Primero, instala el paquete Cashier para Stripe utilizando el gestor de paquetes Composer:


```shell
composer require laravel/cashier

```
Después de instalar el paquete, publica las migraciones de Cashier usando el comando Artisan `vendor:publish`:


```shell
php artisan vendor:publish --tag="cashier-migrations"

```
Entonces, migra tu base de datos:


```shell
php artisan migrate

```
Las migraciones de Cashier añadirán varias columnas a tu tabla `users`. También crearán una nueva tabla `subscriptions` para mantener todas las suscripciones de tus clientes y una tabla `subscription_items` para suscripciones con múltiples precios.
Si lo deseas, también puedes publicar el archivo de configuración de Cashier utilizando el comando Artisan `vendor:publish`:


```shell
php artisan vendor:publish --tag="cashier-config"

```
Por último, para asegurarte de que Cashier maneje correctamente todos los eventos de Stripe, recuerda [configurar el manejo de webhooks de Cashier](#handling-stripe-webhooks).
> [!WARNING]
Stripe recomienda que cualquier columna utilizada para almacenar identificadores de Stripe sea sensible a mayúsculas y minúsculas. Por lo tanto, debes asegurarte de que la collation de la columna `stripe_id` esté configurada en `utf8_bin` al usar MySQL. Se puede encontrar más información al respecto en la [documentación de Stripe](https://stripe.com/docs/upgrades#what-changes-does-stripe-consider-to-be-backwards-compatible).

<a name="configuration"></a>
## Configuración


<a name="billable-model"></a>
### Modelo Facturable

Antes de usar Cashier, añade el trait `Billable` a la definición de tu modelo facturable. Típicamente, este será el modelo `App\Models\User`. Este trait proporciona varios métodos que te permiten realizar tareas de facturación comunes, como crear suscripciones, aplicar cupones y actualizar información del método de pago:


```php
use Laravel\Cashier\Billable;

class User extends Authenticatable
{
    use Billable;
}
```
Cashier asume que tu modelo facturable será la clase `App\Models\User` que se incluye con Laravel. Si deseas cambiar esto, puedes especificar un modelo diferente a través del método `useCustomerModel`. Este método se debe llamar típicamente en el método `boot` de tu clase `AppServiceProvider`:


```php
use App\Models\Cashier\User;
use Laravel\Cashier\Cashier;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Cashier::useCustomerModel(User::class);
}
```
> [!WARNING]
Si estás utilizando un modelo diferente al modelo `App\Models\User` proporcionado por Laravel, necesitarás publicar y modificar las [migraciones de Cashier](#installation) proporcionadas para que coincidan con el nombre de la tabla de tu modelo alternativo.

<a name="api-keys"></a>
### Claves de API

A continuación, debes configurar tus claves API de Stripe en el archivo `.env` de tu aplicación. Puedes recuperar tus claves API de Stripe desde el panel de control de Stripe:


```ini
STRIPE_KEY=your-stripe-key
STRIPE_SECRET=your-stripe-secret
STRIPE_WEBHOOK_SECRET=your-stripe-webhook-secret

```
> [!WARNING]
Debes asegurarte de que la variable de entorno `STRIPE_WEBHOOK_SECRET` esté definida en el archivo `.env` de tu aplicación, ya que esta variable se utiliza para asegurar que los webhooks entrantes sean realmente de Stripe.

<a name="currency-configuration"></a>
### Configuración de Moneda

La moneda predeterminada de Cashier son Dólares Estadounidenses (USD). Puedes cambiar la moneda predeterminada configurando la variable de entorno `CASHIER_CURRENCY` dentro del archivo `.env` de tu aplicación:


```ini
CASHIER_CURRENCY=eur

```
Además de configurar la moneda de Cashier, también puedes especificar un locale que se utilizará al formatear valores monetarios para su visualización en facturas. Internamente, Cashier utiliza la clase `NumberFormatter` de [PHP](https://www.php.net/manual/en/class.numberformatter.php) para establecer el locale de la moneda:


```ini
CASHIER_CURRENCY_LOCALE=nl_BE

```
> [!WARNING]
Para usar locales que no sean `en`, asegúrate de que la extensión PHP `ext-intl` esté instalada y configurada en tu servidor.

<a name="tax-configuration"></a>
### Configuración de Impuestos

Gracias a [Stripe Tax](https://stripe.com/tax), es posible calcular automáticamente los impuestos para todas las facturas generadas por Stripe. Puedes habilitar el cálculo automático de impuestos invocando el método `calculateTaxes` en el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:


```php
use Laravel\Cashier\Cashier;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Cashier::calculateTaxes();
}
```
Una vez que se ha habilitado el cálculo de impuestos, todas las nuevas suscripciones y cualquier factura única que se genere recibirán un cálculo de impuestos automático.
Para que esta función funcione correctamente, los detalles de facturación de tu cliente, como el nombre del cliente, la dirección y el ID fiscal, deben estar sincronizados con Stripe. Puedes usar los métodos de [sincronización de datos del cliente](#syncing-customer-data-with-stripe) y [ID fiscal](#tax-ids) que ofrece Cashier para lograr esto.

<a name="logging"></a>
### Registro

Cashier te permite especificar el canal de registro que se utilizará al registrar errores fatales de Stripe. Puedes especificar el canal de registro definiendo la variable de entorno `CASHIER_LOGGER` dentro del archivo `.env` de tu aplicación:


```ini
CASHIER_LOGGER=stack

```
Las excepciones que son generadas por las llamadas a la API de Stripe se registrarán a través del canal de registro predeterminado de tu aplicación.

<a name="using-custom-models"></a>
### Usando Modelos Personalizados

Puedes extender los modelos utilizados internamente por Cashier definiendo tu propio modelo y extendiendo el modelo correspondiente de Cashier:


```php
use Laravel\Cashier\Subscription as CashierSubscription;

class Subscription extends CashierSubscription
{
    // ...
}
```
Después de definir tu modelo, puedes instruir a Cashier para que use tu modelo personalizado a través de la clase `Laravel\Cashier\Cashier`. Típicamente, debes informar a Cashier sobre tus modelos personalizados en el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:


```php
use App\Models\Cashier\Subscription;
use App\Models\Cashier\SubscriptionItem;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Cashier::useSubscriptionModel(Subscription::class);
    Cashier::useSubscriptionItemModel(SubscriptionItem::class);
}
```

<a name="quickstart"></a>
## Guía Rápida


<a name="quickstart-selling-products"></a>
### Vendiendo Productos

Para cobrar a los clientes por productos de un solo cargo no recurrentes, utilizaremos Cashier para dirigir a los clientes a Stripe Checkout, donde proporcionarán sus detalles de pago y confirmarán su compra. Una vez que se haya realizado el pago a través de Checkout, el cliente será redirigido a una URL de éxito de su elección dentro de su aplicación:


```php
use Illuminate\Http\Request;

Route::get('/checkout', function (Request $request) {
    $stripePriceId = 'price_deluxe_album';

    $quantity = 1;

    return $request->user()->checkout([$stripePriceId => $quantity], [
        'success_url' => route('checkout-success'),
        'cancel_url' => route('checkout-cancel'),
    ]);
})->name('checkout');

Route::view('/checkout/success', 'checkout.success')->name('checkout-success');
Route::view('/checkout/cancel', 'checkout.cancel')->name('checkout-cancel');
```
Como puedes ver en el ejemplo anterior, utilizaremos el método `checkout` proporcionado por Cashier para redirigir al cliente a Stripe Checkout por un "identificador de precio" dado. Al usar Stripe, los "precios" se refieren a [precios definidos para productos específicos](https://stripe.com/docs/products-prices/how-products-and-prices-work).
Si es necesario, el método `checkout` creará automáticamente un cliente en Stripe y conectará ese registro de cliente de Stripe al usuario correspondiente en la base de datos de tu aplicación. Después de completar la sesión de pago, el cliente será redirigido a una página de éxito o cancelación dedicada donde puedes mostrar un mensaje informativo al cliente.

<a name="providing-meta-data-to-stripe-checkout"></a>
#### Proporcionando Metadatos a Stripe Checkout

Al vender productos, es común hacer un seguimiento de los pedidos completados y los productos comprados a través de modelos `Cart` y `Order` definidos por tu propia aplicación. Al redirigir a los clientes a Stripe Checkout para completar una compra, es posible que debas proporcionar un identificador de pedido existente para que puedas asociar la compra completada con el pedido correspondiente cuando el cliente sea redirigido de vuelta a tu aplicación.
Para lograr esto, puedes proporcionar un array de `metadata` al método `checkout`. Imaginemos que se crea una `Order` pendiente dentro de nuestra aplicación cuando un usuario inicia el proceso de pago. Recuerda que los modelos `Cart` y `Order` en este ejemplo son ilustrativos y no proporcionados por Cashier. Eres libre de implementar estos conceptos según las necesidades de tu propia aplicación:


```php
use App\Models\Cart;
use App\Models\Order;
use Illuminate\Http\Request;

Route::get('/cart/{cart}/checkout', function (Request $request, Cart $cart) {
    $order = Order::create([
        'cart_id' => $cart->id,
        'price_ids' => $cart->price_ids,
        'status' => 'incomplete',
    ]);

    return $request->user()->checkout($order->price_ids, [
        'success_url' => route('checkout-success').'?session_id={CHECKOUT_SESSION_ID}',
        'cancel_url' => route('checkout-cancel'),
        'metadata' => ['order_id' => $order->id],
    ]);
})->name('checkout');
```
Como puedes ver en el ejemplo anterior, cuando un usuario inicia el proceso de pago, proporcionaremos todos los identificadores de precio de Stripe asociados al carrito / pedido al método `checkout`. Por supuesto, tu aplicación es responsable de asociar estos elementos con el "carrito de compras" o pedido a medida que el cliente los añade. También proporcionamos el ID del pedido a la sesión de Stripe Checkout a través del array `metadata`. Finalmente, hemos añadido la variable de plantilla `CHECKOUT_SESSION_ID` a la ruta de éxito de Checkout. Cuando Stripe redirija a los clientes de vuelta a tu aplicación, esta variable de plantilla se rellenará automáticamente con el ID de la sesión de Checkout.
A continuación, construyamos la ruta de éxito de Checkout. Esta es la ruta a la que los usuarios serán redirigidos después de que se haya completado su compra a través de Stripe Checkout. Dentro de esta ruta, podemos recuperar el ID de sesión de Stripe Checkout y la instancia de Stripe Checkout asociada para acceder a nuestros metadatos proporcionados y actualizar el pedido de nuestro cliente en consecuencia:


```php
use App\Models\Order;
use Illuminate\Http\Request;
use Laravel\Cashier\Cashier;

Route::get('/checkout/success', function (Request $request) {
    $sessionId = $request->get('session_id');

    if ($sessionId === null) {
        return;
    }

    $session = Cashier::stripe()->checkout->sessions->retrieve($sessionId);

    if ($session->payment_status !== 'paid') {
        return;
    }

    $orderId = $session['metadata']['order_id'] ?? null;

    $order = Order::findOrFail($orderId);

    $order->update(['status' => 'completed']);

    return view('checkout-success', ['order' => $order]);
})->name('checkout-success');
```
Por favor, consulta la documentación de Stripe para obtener más información sobre los [datos contenidos en el objeto de sesión de Checkout](https://stripe.com/docs/api/checkout/sessions/object).

<a name="quickstart-selling-subscriptions"></a>
### Vendiendo Suscripciones

> [!NOTE]
Antes de utilizar Stripe Checkout, debes definir Productos con precios fijos en tu panel de control de Stripe. Además, debes [configurar el manejo de webhooks de Cashier](#handling-stripe-webhooks).
Ofrecer facturación de productos y suscripciones a través de tu aplicación puede ser intimidante. Sin embargo, gracias a Cashier y [Stripe Checkout](https://stripe.com/payments/checkout), puedes construir fácilmente integraciones de pago modernas y robustas.
Para aprender cómo vender suscripciones utilizando Cashier y Stripe Checkout, consideremos el simple escenario de un servicio de suscripción con un plan mensual básico (`price_basic_monthly`) y un plan anual (`price_basic_yearly`). Estos dos precios podrían agruparse bajo un producto "Básico" (`pro_basic`) en nuestro panel de control de Stripe. Además, nuestro servicio de suscripción podría ofrecer un plan Experto como `pro_expert`.
Primero, descubramos cómo un cliente puede suscribirse a nuestros servicios. Por supuesto, puedes imaginar que el cliente podría hacer clic en un botón de "suscribirse" para el plan Básico en la página de precios de nuestra aplicación. Este botón o enlace debe dirigir al usuario a una ruta de Laravel que crea la sesión de Stripe Checkout para su plan elegido:


```php
use Illuminate\Http\Request;

Route::get('/subscription-checkout', function (Request $request) {
    return $request->user()
        ->newSubscription('default', 'price_basic_monthly')
        ->trialDays(5)
        ->allowPromotionCodes()
        ->checkout([
            'success_url' => route('your-success-route'),
            'cancel_url' => route('your-cancel-route'),
        ]);
});
```
Como puedes ver en el ejemplo anterior, redirigiremos al cliente a una sesión de Stripe Checkout que les permitirá suscribirse a nuestro plan Básico. Después de un pago exitoso o una cancelación, el cliente será redirigido de vuelta a la URL que proporcionamos al método `checkout`. Para saber cuándo ha comenzado realmente su suscripción (ya que algunos métodos de pago requieren unos segundos para procesar), también necesitaremos [configurar el manejo de webhooks de Cashier](#handling-stripe-webhooks).
Ahora que los clientes pueden iniciar sus suscripciones, necesitamos restringir ciertas partes de nuestra aplicación para que solo los usuarios suscritos puedan acceder a ellas. Por supuesto, siempre podemos determinar el estado de suscripción actual de un usuario a través del método `subscribed` proporcionado por el trait `Billable` de Cashier:


```blade
@if ($user->subscribed())
    <p>You are subscribed.</p>
@endif

```
Incluso podemos determinar fácilmente si un usuario está suscrito a un producto o precio específicos:


```blade
@if ($user->subscribedToProduct('pro_basic'))
    <p>You are subscribed to our Basic product.</p>
@endif

@if ($user->subscribedToPrice('price_basic_monthly'))
    <p>You are subscribed to our monthly Basic plan.</p>
@endif

```

<a name="quickstart-building-a-subscribed-middleware"></a>
#### Construyendo un Middleware de Suscripción

Para mayor comodidad, es posible que desees crear un [middleware](/docs/%7B%7Bversion%7D%7D/middleware) que determine si la solicitud entrante proviene de un usuario suscrito. Una vez que se haya definido este middleware, puedes asignarlo fácilmente a una ruta para evitar que los usuarios que no están suscritos accedan a la ruta:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class Subscribed
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->user()?->subscribed()) {
            // Redirect user to billing page and ask them to subscribe...
            return redirect('/billing');
        }

        return $next($request);
    }
}
```
Una vez que se ha definido el middleware, puedes asignarlo a una ruta:


```php
use App\Http\Middleware\Subscribed;

Route::get('/dashboard', function () {
    // ...
})->middleware([Subscribed::class]);
```

<a name="quickstart-allowing-customers-to-manage-their-billing-plan"></a>
#### Permitiendo a los Clientes Gestionar su Plan de Facturación

Por supuesto, los clientes pueden querer cambiar su plan de suscripción a otro producto o "nivel". La forma más sencilla de permitir esto es dirigiendo a los clientes al [Portal de facturación de clientes](https://stripe.com/docs/no-code/customer-portal) de Stripe, que ofrece una interfaz de usuario alojada que permite a los clientes descargar facturas, actualizar su método de pago y cambiar planes de suscripción.
Primero, define un enlace o botón dentro de tu aplicación que dirija a los usuarios a una ruta de Laravel que utilizaremos para iniciar una sesión en el Portal de Facturación:


```blade
<a href="{{ route('billing') }}">
    Billing
</a>

```
A continuación, definamos la ruta que inicia una sesión del Portal de Facturación de Stripe y redirige al usuario al Portal. El método `redirectToBillingPortal` acepta la URL a la que los usuarios deben regresar al salir del Portal:


```php
use Illuminate\Http\Request;

Route::get('/billing', function (Request $request) {
    return $request->user()->redirectToBillingPortal(route('dashboard'));
})->middleware(['auth'])->name('billing');
```
> [!NOTA]
Mientras hayas configurado el manejo de webhooks de Cashier, Cashier mantendrá automáticamente las tablas de base de datos relacionadas con Cashier de tu aplicación en sincronía al inspeccionar los webhooks entrantes de Stripe. Así que, por ejemplo, cuando un usuario cancela su suscripción a través del Portal de facturación de clientes de Stripe, Cashier recibirá el webhook correspondiente y marcará la suscripción como "cancelada" en la base de datos de tu aplicación.

<a name="customers"></a>
## Clientes


<a name="retrieving-customers"></a>
### Recuperando Clientes

Puedes recuperar un cliente por su ID de Stripe utilizando el método `Cashier::findBillable`. Este método devolverá una instancia del modelo facturable:


```php
use Laravel\Cashier\Cashier;

$user = Cashier::findBillable($stripeId);
```

<a name="creating-customers"></a>
### Creando Clientes

Ocasionalmente, es posible que desees crear un cliente de Stripe sin comenzar una suscripción. Puedes lograr esto utilizando el método `createAsStripeCustomer`:


```php
$stripeCustomer = $user->createAsStripeCustomer();
```
Una vez que el cliente ha sido creado en Stripe, puedes iniciar una suscripción en una fecha posterior. Puedes proporcionar un array `$options` opcional para pasar cualquier parámetro adicional de [creación de cliente que son soportados por la API de Stripe](https://stripe.com/docs/api/customers/create):


```php
$stripeCustomer = $user->createAsStripeCustomer($options);
```
Puedes usar el método `asStripeCustomer` si deseas devolver el objeto del cliente de Stripe para un modelo facturable:


```php
$stripeCustomer = $user->asStripeCustomer();
```
El método `createOrGetStripeCustomer` se puede utilizar si deseas recuperar el objeto de cliente de Stripe para un modelo facturable dado, pero no estás seguro de si el modelo facturable ya es un cliente dentro de Stripe. Este método creará un nuevo cliente en Stripe si uno no existe ya:


```php
$stripeCustomer = $user->createOrGetStripeCustomer();
```

<a name="updating-customers"></a>
### Actualizando Clientes

Ocasionalmente, es posible que desees actualizar el cliente de Stripe directamente con información adicional. Puedes lograr esto utilizando el método `updateStripeCustomer`. Este método acepta un array de [opciones de actualización de cliente soportadas por la API de Stripe](https://stripe.com/docs/api/customers/update):


```php
$stripeCustomer = $user->updateStripeCustomer($options);
```

<a name="balances"></a>
### Saldos

Stripe te permite acreditar o debitar el "saldo" de un cliente. Más tarde, este saldo se acreditará o debitará en nuevas facturas. Para verificar el saldo total del cliente, puedes usar el método `balance` que está disponible en tu modelo facturable. El método `balance` devolverá una representación de cadena formateada del saldo en la moneda del cliente:


```php
$balance = $user->balance();
```
Para acreditar el saldo de un cliente, puedes proporcionar un valor al método `creditBalance`. Si lo deseas, también puedes proporcionar una descripción:


```php
$user->creditBalance(500, 'Premium customer top-up.');
```
Proporcionar un valor al método `debitBalance` debitará el saldo del cliente:


```php
$user->debitBalance(300, 'Bad usage penalty.');
```
El método `applyBalance` creará nuevas transacciones de saldo para el cliente. Puedes recuperar estos registros de transacción utilizando el método `balanceTransactions`, lo cual puede ser útil para proporcionar un registro de créditos y débitos para que el cliente revise:


```php
// Retrieve all transactions...
$transactions = $user->balanceTransactions();

foreach ($transactions as $transaction) {
    // Transaction amount...
    $amount = $transaction->amount(); // $2.31

    // Retrieve the related invoice when available...
    $invoice = $transaction->invoice();
}
```

<a name="tax-ids"></a>
### IDs fiscales

Cashier ofrece una manera fácil de gestionar los ID fiscales de un cliente. Por ejemplo, se puede usar el método `taxIds` para recuperar todos los [ID fiscales](https://stripe.com/docs/api/customer_tax_ids/object) que están asignados a un cliente como una colección:


```php
$taxIds = $user->taxIds();
```
También puedes recuperar un ID fiscal específico para un cliente por su identificador:


```php
$taxId = $user->findTaxId('txi_belgium');
```
Puedes crear un nuevo ID de impuesto proporcionando un [tipo](https://stripe.com/docs/api/customer_tax_ids/object#tax_id_object-type) y un valor válidos al método `createTaxId`:


```php
$taxId = $user->createTaxId('eu_vat', 'BE0123456789');
```
El método `createTaxId` añadirá inmediatamente el ID de IVA a la cuenta del cliente. [La verificación de ID de IVA también la realiza Stripe](https://stripe.com/docs/invoicing/customer/tax-ids#validation); sin embargo, este es un proceso asincrónico. Puedes recibir notificaciones de actualizaciones de verificación suscribiéndote al evento webhook `customer.tax_id.updated` e inspeccionando el parámetro `verification` de los ID de IVA. Para obtener más información sobre el manejo de webhooks, consulta la [documentación sobre la definición de controladores de webhook](#handling-stripe-webhooks).
Puedes eliminar un ID fiscal utilizando el método `deleteTaxId`:


```php
$user->deleteTaxId('txi_belgium');
```

<a name="syncing-customer-data-with-stripe"></a>
### Sincronizando Datos de Clientes con Stripe

Típicamente, cuando los usuarios de tu aplicación actualizan su nombre, dirección de correo electrónico u otra información que también es almacenada por Stripe, deberías informar a Stripe sobre las actualizaciones. Al hacerlo, la copia de Stripe de la información estará sincronizada con la de tu aplicación.
Para automatizar esto, puedes definir un oyente de eventos en tu modelo facturable que reaccione al evento `updated` del modelo. Luego, dentro de tu oyente de eventos, puedes invocar el método `syncStripeCustomerDetails` en el modelo:


```php
use App\Models\User;
use function Illuminate\Events\queueable;

/**
 * The "booted" method of the model.
 */
protected static function booted(): void
{
    static::updated(queueable(function (User $customer) {
        if ($customer->hasStripeId()) {
            $customer->syncStripeCustomerDetails();
        }
    }));
}
```
Ahora, cada vez que se actualice tu modelo de cliente, su información se sincronizará con Stripe. Para mayor comodidad, Cashier sincronizará automáticamente la información de tu cliente con Stripe en la creación inicial del cliente.
Puedes personalizar las columnas utilizadas para sincronizar la información del cliente con Stripe sobreescribiendo una variedad de métodos proporcionados por Cashier. Por ejemplo, puedes sobreescribir el método `stripeName` para personalizar el atributo que se debe considerar como el "nombre" del cliente cuando Cashier sincroniza la información del cliente con Stripe:


```php
/**
 * Get the customer name that should be synced to Stripe.
 */
public function stripeName(): string|null
{
    return $this->company_name;
}
```
De manera similar, puedes sobrescribir los métodos `stripeEmail`, `stripePhone`, `stripeAddress` y `stripePreferredLocales`. Estos métodos sincronizarán la información con sus parámetros de cliente correspondientes al [actualizar el objeto de cliente de Stripe](https://stripe.com/docs/api/customers/update). Si deseas tener control total sobre el proceso de sincronización de información del cliente, puedes sobrescribir el método `syncStripeCustomerDetails`.

<a name="billing-portal"></a>
### Portal de facturación

Stripe ofrece [una manera sencilla de configurar un portal de facturación](https://stripe.com/docs/billing/subscriptions/customer-portal) para que tu cliente pueda gestionar su suscripción, métodos de pago y ver su historial de facturación. Puedes redirigir a tus usuarios al portal de facturación invocando el método `redirectToBillingPortal` en el modelo facturable desde un controlador o ruta:


```php
use Illuminate\Http\Request;

Route::get('/billing-portal', function (Request $request) {
    return $request->user()->redirectToBillingPortal();
});
```
Por defecto, cuando el usuario haya terminado de gestionar su suscripción, podrá regresar a la ruta `home` de su aplicación a través de un enlace dentro del portal de facturación de Stripe. Puedes proporcionar una URL personalizada a la que el usuario debe regresar pasando la URL como argumento al método `redirectToBillingPortal`:


```php
use Illuminate\Http\Request;

Route::get('/billing-portal', function (Request $request) {
    return $request->user()->redirectToBillingPortal(route('billing'));
});
```
Si deseas generar la URL al portal de facturación sin generar una respuesta de redirección HTTP, puedes invocar el método `billingPortalUrl`:


```php
$url = $request->user()->billingPortalUrl(route('billing'));
```

<a name="payment-methods"></a>
## Métodos de Pago


<a name="storing-payment-methods"></a>
### Almacenando Métodos de Pago

Para crear suscripciones o realizar cargos "puntuales" con Stripe, necesitarás almacenar un método de pago y recuperar su identificador de Stripe. El enfoque utilizado para lograr esto difiere según si planeas usar el método de pago para suscripciones o cargos únicos, así que examinaremos ambos a continuación.

<a name="payment-methods-for-subscriptions"></a>
#### Métodos de Pago para Suscripciones

Al almacenar la información de la tarjeta de crédito de un cliente para su uso futuro mediante una suscripción, se debe usar la API "Setup Intents" de Stripe para recopilar de manera segura los detalles del método de pago del cliente. Un "Setup Intent" indica a Stripe la intención de cargar el método de pago de un cliente. El trait `Billable` de Cashier incluye el método `createSetupIntent` para crear fácilmente un nuevo Setup Intent. Debes invocar este método desde la ruta o el controlador que renderizará el formulario que recopila los detalles del método de pago de tu cliente:


```php
return view('update-payment-method', [
    'intent' => $user->createSetupIntent()
]);
```
Después de haber creado el Setup Intent y haberlo pasado a la vista, deberías adjuntar su secreto al elemento que recopilará el método de pago. Por ejemplo, considera este formulario de "actualizar método de pago":


```html
<input id="card-holder-name" type="text">

<!-- Stripe Elements Placeholder -->
<div id="card-element"></div>

<button id="card-button" data-secret="{{ $intent->client_secret }}">
    Update Payment Method
</button>

```
A continuación, se puede usar la biblioteca Stripe.js para adjuntar un [Stripe Element](https://stripe.com/docs/stripe-js) al formulario y recopilar de manera segura los detalles de pago del cliente:
A continuación, se puede verificar la tarjeta y recuperar un "identificador de método de pago" seguro de Stripe utilizando el [método `confirmCardSetup` de Stripe](https://stripe.com/docs/js/setup_intents/confirm_card_setup):


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
Después de que la tarjeta haya sido verificada por Stripe, puedes pasar el identificador `setupIntent.payment_method` resultante a tu aplicación Laravel, donde se puede adjuntar al cliente. El método de pago puede ser [agregado como un nuevo método de pago](#adding-payment-methods) o [usado para actualizar el método de pago predeterminado](#updating-the-default-payment-method). También puedes usar inmediatamente el identificador del método de pago para [crear una nueva suscripción](#creating-subscriptions).
> [!NOTA]
Si deseas más información sobre los Intents de Configuración y la recopilación de detalles de pago del cliente, por favor [revisa este resumen proporcionado por Stripe](https://stripe.com/docs/payments/save-and-reuse#php).

<a name="payment-methods-for-single-charges"></a>
#### Métodos de Pago para Cargos Únicos

Por supuesto, al realizar un solo cargo contra el método de pago de un cliente, solo necesitaremos usar un identificador del método de pago una vez. Debido a las limitaciones de Stripe, no puedes usar el método de pago predeterminado almacenado de un cliente para cargos únicos. Debes permitir que el cliente ingrese los detalles de su método de pago utilizando la biblioteca Stripe.js. Por ejemplo, considera el siguiente formulario:


```html
<input id="card-holder-name" type="text">

<!-- Stripe Elements Placeholder -->
<div id="card-element"></div>

<button id="card-button">
    Process Payment
</button>

```
Después de definir dicho formulario, se puede usar la biblioteca Stripe.js para adjuntar un [Stripe Element](https://stripe.com/docs/stripe-js) al formulario y recopilar de manera segura los detalles de pago del cliente:


```html
<script src="https://js.stripe.com/v3/"></script>

<script>
    const stripe = Stripe('stripe-public-key');

    const elements = stripe.elements();
    const cardElement = elements.create('card');

    cardElement.mount('#card-element');
</script>

```
A continuación, se puede verificar la tarjeta y se puede recuperar un "identificador de método de pago" seguro de Stripe utilizando el método `createPaymentMethod` de [Stripe](https://stripe.com/docs/stripe-js/reference#stripe-create-payment-method):


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
Si la tarjeta se verifica con éxito, puedes pasar el `paymentMethod.id` a tu aplicación Laravel y procesar un [cobro único](#simple-charge).

<a name="retrieving-payment-methods"></a>
### Recuperando Métodos de Pago

El método `paymentMethods` en la instancia del modelo facturable devuelve una colección de instancias de `Laravel\Cashier\PaymentMethod`:


```php
$paymentMethods = $user->paymentMethods();
```
Por defecto, este método devolverá métodos de pago de todo tipo. Para recuperar métodos de pago de un tipo específico, puedes pasar el `type` como argumento al método:


```php
$paymentMethods = $user->paymentMethods('sepa_debit');
```
Para recuperar el método de pago predeterminado del cliente, se puede usar el método `defaultPaymentMethod`:


```php
$paymentMethod = $user->defaultPaymentMethod();
```
Puedes recuperar un método de pago específico que esté asociado al modelo facturable utilizando el método `findPaymentMethod`:


```php
$paymentMethod = $user->findPaymentMethod($paymentMethodId);
```

<a name="payment-method-presence"></a>
### Presencia del Método de Pago

Para determinar si un modelo facturable tiene un método de pago predeterminado asociado a su cuenta, invoca el método `hasDefaultPaymentMethod`:


```php
if ($user->hasDefaultPaymentMethod()) {
    // ...
}
```
Puedes usar el método `hasPaymentMethod` para determinar si un modelo facturable tiene al menos un método de pago asociado a su cuenta:


```php
if ($user->hasPaymentMethod()) {
    // ...
}
```
Este método determinará si el modelo facturable tiene algún método de pago en absoluto. Para determinar si existe un método de pago de un tipo específico para el modelo, puedes pasar el `type` como argumento al método:


```php
if ($user->hasPaymentMethod('sepa_debit')) {
    // ...
}
```

<a name="updating-the-default-payment-method"></a>
### Actualizando el Método de Pago Predeterminado

El método `updateDefaultPaymentMethod` se puede utilizar para actualizar la información del método de pago predeterminado de un cliente. Este método acepta un identificador de método de pago de Stripe y asignará el nuevo método de pago como el método de pago predeterminado de facturación:


```php
$user->updateDefaultPaymentMethod($paymentMethod);
```
Para sincronizar la información de tu método de pago predeterminado con la información del método de pago predeterminado del cliente en Stripe, puedes usar el método `updateDefaultPaymentMethodFromStripe`:


```php
$user->updateDefaultPaymentMethodFromStripe();
```
> [!WARNING]
El método de pago predeterminado en un cliente solo se puede usar para la facturación y la creación de nuevas suscripciones. Debido a las limitaciones impuestas por Stripe, no se puede usar para cargos únicos.

<a name="adding-payment-methods"></a>
### Agregar Métodos de Pago

Para añadir un nuevo método de pago, puedes llamar al método `addPaymentMethod` en el modelo facturable, pasando el identificador del método de pago:


```php
$user->addPaymentMethod($paymentMethod);
```
> [!NOTA]
Para aprender a cómo recuperar identificadores de métodos de pago, por favor revisa la [documentación sobre el almacenamiento de métodos de pago](#storing-payment-methods).

<a name="deleting-payment-methods"></a>
### Eliminando Métodos de Pago

Para eliminar un método de pago, puedes llamar al método `delete` en la instancia de `Laravel\Cashier\PaymentMethod` que deseas eliminar:


```php
$paymentMethod->delete();
```
El método `deletePaymentMethod` eliminará un método de pago específico del modelo facturable:


```php
$user->deletePaymentMethod('pm_visa');
```
El método `deletePaymentMethods` eliminará toda la información del método de pago para el modelo facturable:


```php
$user->deletePaymentMethods();
```
Por defecto, este método eliminará los métodos de pago de todos los tipos. Para eliminar métodos de pago de un tipo específico, puedes pasar el `type` como argumento al método:


```php
$user->deletePaymentMethods('sepa_debit');
```
> [!WARNING]
Si un usuario tiene una suscripción activa, tu aplicación no debe permitirle eliminar su método de pago predeterminado.

<a name="subscriptions"></a>
## Suscripciones

Las suscripciones ofrecen una manera de establecer pagos recurrentes para tus clientes. Las suscripciones de Stripe gestionadas por Cashier brindan soporte para múltiples precios de suscripción, cantidades de suscripción, pruebas y más.

<a name="creating-subscriptions"></a>
### Creando Suscripciones

Para crear una suscripción, primero recupera una instancia de tu modelo facturable, que típicamente será una instancia de `App\Models\User`. Una vez que hayas recuperado la instancia del modelo, puedes usar el método `newSubscription` para crear la suscripción del modelo:


```php
use Illuminate\Http\Request;

Route::post('/user/subscribe', function (Request $request) {
    $request->user()->newSubscription(
        'default', 'price_monthly'
    )->create($request->paymentMethodId);

    // ...
});
```
El primer argumento pasado al método `newSubscription` debe ser el tipo interno de la suscripción. Si tu aplicación solo ofrece una suscripción, podrías llamarla `default` o `primary`. Este tipo de suscripción es solo para uso interno de la aplicación y no está destinado a ser mostrado a los usuarios. Además, no debe contener espacios y nunca debe ser cambiado después de crear la suscripción. El segundo argumento es el precio específico al que el usuario se está suscribiendo. Este valor debe corresponder al identificador del precio en Stripe.
El método `create`, que acepta [un identificador de método de pago de Stripe](#storing-payment-methods) o un objeto `PaymentMethod` de Stripe, iniciará la suscripción y actualizará tu base de datos con el ID de cliente de Stripe del modelo facturable y otra información de facturación relevante.
> [!WARNING]
Pasar un identificador de método de pago directamente al método de suscripción `create` también lo añadirá automáticamente a los métodos de pago almacenados del usuario.

<a name="collecting-recurring-payments-via-invoice-emails"></a>
#### Recolección de Pagos Recurrentes a través de Correos Electrónicos de Factura

En lugar de cobrar automáticamente los pagos recurrentes de un cliente, puedes instruir a Stripe para que envíe por correo electrónico una factura al cliente cada vez que su pago recurrente sea vencido. Luego, el cliente puede pagar manualmente la factura una vez que la reciba. El cliente no necesita proporcionar un método de pago por adelantado al recaudar pagos recurrentes a través de facturas:


```php
$user->newSubscription('default', 'price_monthly')->createAndSendInvoice();
```
La cantidad de tiempo que un cliente tiene para pagar su factura antes de que se cancele su suscripción está determinada por la opción `days_until_due`. Por defecto, son 30 días; sin embargo, puedes proporcionar un valor específico para esta opción si lo deseas:


```php
$user->newSubscription('default', 'price_monthly')->createAndSendInvoice([], [
    'days_until_due' => 30
]);
```

<a name="subscription-quantities"></a>
Si deseas establecer una [cantidad](https://stripe.com/docs/billing/subscriptions/quantities) específica para el precio al crear la suscripción, debes invocar el método `quantity` en el constructor de la suscripción antes de crear la suscripción:


```php
$user->newSubscription('default', 'price_monthly')
     ->quantity(5)
     ->create($paymentMethod);
```

<a name="additional-details"></a>
#### Detalles Adicionales

Si deseas especificar opciones adicionales de [cliente](https://stripe.com/docs/api/customers/create) o de [suscripción](https://stripe.com/docs/api/subscriptions/create) que son compatibles con Stripe, puedes hacerlo pasándolas como el segundo y tercer argumento al método `create`:


```php
$user->newSubscription('default', 'price_monthly')->create($paymentMethod, [
    'email' => $email,
], [
    'metadata' => ['note' => 'Some extra information.'],
]);
```

<a name="coupons"></a>
#### Cupones

Si deseas aplicar un cupón al crear la suscripción, puedes usar el método `withCoupon`:


```php
$user->newSubscription('default', 'price_monthly')
     ->withCoupon('code')
     ->create($paymentMethod);
```
O, si deseas aplicar un [código de promoción de Stripe](https://stripe.com/docs/billing/subscriptions/discounts/codes), puedes usar el método `withPromotionCode`:


```php
$user->newSubscription('default', 'price_monthly')
     ->withPromotionCode('promo_code_id')
     ->create($paymentMethod);
```
El ID del código de promoción dado debe ser el ID de la API de Stripe asignado al código de promoción y no el código de promoción visible para el cliente. Si necesitas encontrar un ID de código de promoción basado en un código de promoción visible para el cliente dado, puedes usar el método `findPromotionCode`:


```php
// Find a promotion code ID by its customer facing code...
$promotionCode = $user->findPromotionCode('SUMMERSALE');

// Find an active promotion code ID by its customer facing code...
$promotionCode = $user->findActivePromotionCode('SUMMERSALE');
```
En el ejemplo anterior, el objeto `$promotionCode` devuelto es una instancia de `Laravel\Cashier\PromotionCode`. Esta clase decora un objeto subyacente `Stripe\PromotionCode`. Puedes recuperar el cupón relacionado con el código de promoción invocando el método `coupon`:


```php
$coupon = $user->findPromotionCode('SUMMERSALE')->coupon();
```
La instancia del cupón te permite determinar el monto del descuento y si el cupón representa un descuento fijo o un descuento porcentual:


```php
if ($coupon->isPercentage()) {
    return $coupon->percentOff().'%'; // 21.5%
} else {
    return $coupon->amountOff(); // $5.99
}
```
También puedes recuperar los descuentos que están actualmente aplicados a un cliente o suscripción:


```php
$discount = $billable->discount();

$discount = $subscription->discount();
```
Las instancias `Laravel\Cashier\Discount` devueltas decoran una instancia del objeto `Stripe\Discount` subyacente. Puedes recuperar el cupón relacionado con este descuento invocando el método `coupon`:


```php
$coupon = $subscription->discount()->coupon();
```
Si deseas aplicar un nuevo cupón o código de promoción a un cliente o suscripción, puedes hacerlo a través de los métodos `applyCoupon` o `applyPromotionCode`:


```php
$billable->applyCoupon('coupon_id');
$billable->applyPromotionCode('promotion_code_id');

$subscription->applyCoupon('coupon_id');
$subscription->applyPromotionCode('promotion_code_id');
```
Recuerda que debes usar el ID de la API de Stripe asignado al código de promoción y no el código de promoción visible para el cliente. Solo se puede aplicar un cupón o código de promoción a un cliente o suscripción en un momento dado.
Para obtener más información sobre este tema, consulta la documentación de Stripe sobre [cupones](https://stripe.com/docs/billing/subscriptions/coupons) y [códigos de promoción](https://stripe.com/docs/billing/subscriptions/coupons/codes).

<a name="adding-subscriptions"></a>
#### Agregar Suscripciones

Si deseas añadir una suscripción a un cliente que ya tiene un método de pago predeterminado, puedes invocar el método `add` en el generador de suscripciones:


```php
use App\Models\User;

$user = User::find(1);

$user->newSubscription('default', 'price_monthly')->add();
```

<a name="creating-subscriptions-from-the-stripe-dashboard"></a>
#### Creando suscripciones desde el panel de control de Stripe

También puedes crear suscripciones desde el propio panel de control de Stripe. Al hacerlo, Cashier sincronizará las suscripciones recién añadidas y les asignará un tipo de `default`. Para personalizar el tipo de suscripción que se asigna a las suscripciones creadas en el panel de control, [define controladores de eventos de webhook](#defining-webhook-event-handlers).
Además, solo puedes crear un tipo de suscripción a través del panel de control de Stripe. Si tu aplicación ofrece múltiples suscripciones que utilizan diferentes tipos, solo se puede añadir un tipo de suscripción a través del panel de control de Stripe.
Finalmente, debes asegurarte de añadir solo una suscripción activa por tipo de suscripción ofrecida por tu aplicación. Si un cliente tiene dos suscripciones `default`, solo se utilizará la suscripción añadida más recientemente por Cashier, aunque ambas estén sincronizadas con la base de datos de tu aplicación.

<a name="checking-subscription-status"></a>
### Verificando el Estado de Suscripción

Una vez que un cliente está suscrito a tu aplicación, puedes verificar fácilmente su estado de suscripción utilizando una variedad de métodos convenientes. Primero, el método `subscribed` devuelve `true` si el cliente tiene una suscripción activa, incluso si la suscripción está actualmente dentro de su período de prueba. El método `subscribed` acepta el tipo de suscripción como su primer argumento:


```php
if ($user->subscribed('default')) {
    // ...
}
```
El método `subscribed` también es un gran candidato para un [middleware de ruta](/docs/%7B%7Bversion%7D%7D/middleware), lo que te permite filtrar el acceso a rutas y controladores según el estado de suscripción del usuario:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsSubscribed
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user() && ! $request->user()->subscribed('default')) {
            // This user is not a paying customer...
            return redirect('/billing');
        }

        return $next($request);
    }
}
```
Si deseas determinar si un usuario todavía está dentro de su período de prueba, puedes usar el método `onTrial`. Este método puede ser útil para determinar si debes mostrar una advertencia al usuario de que todavía está en su período de prueba:


```php
if ($user->subscription('default')->onTrial()) {
    // ...
}
```
El método `subscribedToProduct` se puede utilizar para determinar si el usuario está suscrito a un producto dado basado en el identificador de un producto de Stripe dado. En Stripe, los productos son colecciones de precios. En este ejemplo, determinaremos si la suscripción `default` del usuario está suscrita activamente al producto "premium" de la aplicación. El identificador de producto de Stripe dado debe corresponder a uno de los identificadores de tus productos en el panel de control de Stripe:


```php
if ($user->subscribedToProduct('prod_premium', 'default')) {
    // ...
}
```
Al pasar un array al método `subscribedToProduct`, puedes determinar si la suscripción `default` del usuario está suscrita activamente al producto "básico" o "premium" de la aplicación:


```php
if ($user->subscribedToProduct(['prod_basic', 'prod_premium'], 'default')) {
    // ...
}
```
El método `subscribedToPrice` se puede utilizar para determinar si la suscripción de un cliente corresponde a un ID de precio dado:


```php
if ($user->subscribedToPrice('price_basic_monthly', 'default')) {
    // ...
}
```
El método `recurring` se puede utilizar para determinar si el usuario está actualmente suscrito y ya no está dentro de su período de prueba:


```php
if ($user->subscription('default')->recurring()) {
    // ...
}
```
> [!WARNING]
Si un usuario tiene dos suscripciones del mismo tipo, la suscripción más reciente será siempre devuelta por el método `subscription`. Por ejemplo, un usuario podría tener dos registros de suscripción con el tipo `default`; sin embargo, una de las suscripciones puede ser una suscripción antigua y caducada, mientras que la otra es la suscripción activa actual. La suscripción más reciente siempre será devuelta mientras que las suscripciones más antiguas se mantienen en la base de datos para revisión histórica.

<a name="cancelled-subscription-status"></a>
#### Estado de Suscripción Cancelada

Para determinar si el usuario fue una vez un suscriptor activo pero ha cancelado su suscripción, puedes usar el método `canceled`:


```php
if ($user->subscription('default')->canceled()) {
    // ...
}
```
También puedes determinar si un usuario ha cancelado su suscripción pero aún está en su "período de gracia" hasta que la suscripción expire completamente. Por ejemplo, si un usuario cancela una suscripción el 5 de marzo que originalmente estaba programada para expirar el 10 de marzo, el usuario está en su "período de gracia" hasta el 10 de marzo. Ten en cuenta que el método `subscribed` aún devuelve `true` durante este tiempo:
Para determinar si el usuario ha cancelado su suscripción y ya no se encuentra dentro de su "período de gracia", puedes usar el método `ended`:


```php
if ($user->subscription('default')->ended()) {
    // ...
}
```

<a name="incomplete-and-past-due-status"></a>
#### Estado Incompleto y Atrasado

Si una suscripción requiere una acción de pago secundaria después de la creación, la suscripción será marcada como `incomplete`. Los estados de suscripción se almacenan en la columna `stripe_status` de la tabla de base de datos `subscriptions` de Cashier.
De manera similar, si se requiere una acción de pago secundaria al cambiar precios, la suscripción será marcada como `past_due`. Cuando tu suscripción esté en cualquiera de estos estados, no estará activa hasta que el cliente haya confirmado su pago. Determinar si una suscripción tiene un pago incompleto se puede lograr utilizando el método `hasIncompletePayment` en el modelo facturable o en una instancia de suscripción:
Cuando un pago de suscripción está incompleto, debes dirigir al usuario a la página de confirmación de pago de Cashier, pasando el identificador `latestPayment`. Puedes usar el método `latestPayment` disponible en la instancia de suscripción para recuperar este identificador:


```html
<a href="{{ route('cashier.payment', $subscription->latestPayment()->id) }}">
    Please confirm your payment.
</a>

```
Si deseas que la suscripción siga siendo considerada activa cuando está en un estado `past_due` o `incomplete`, puedes usar los métodos `keepPastDueSubscriptionsActive` y `keepIncompleteSubscriptionsActive` proporcionados por Cashier. Típicamente, estos métodos deben ser llamados en el método `register` de tu `App\Providers\AppServiceProvider`:


```php
use Laravel\Cashier\Cashier;

/**
 * Register any application services.
 */
public function register(): void
{
    Cashier::keepPastDueSubscriptionsActive();
    Cashier::keepIncompleteSubscriptionsActive();
}
```
> [!WARNING]
Cuando una suscripción está en un estado `incompleto`, no se puede cambiar hasta que se confirme el pago. Por lo tanto, los métodos `swap` y `updateQuantity` lanzarán una excepción cuando la suscripción esté en un estado `incompleto`.

<a name="subscription-scopes"></a>
#### Ámbitos de Suscripción

La mayoría de los estados de suscripción también están disponibles como alcances de consulta para que puedas consultar fácilmente tu base de datos en busca de suscripciones que estén en un estado dado:


```php
// Get all active subscriptions...
$subscriptions = Subscription::query()->active()->get();

// Get all of the canceled subscriptions for a user...
$subscriptions = $user->subscriptions()->canceled()->get();
```
A continuación se encuentra una lista completa de los alcances disponibles:


```php
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
```

<a name="changing-prices"></a>
### Cambiando Precios

Después de que un cliente se suscriba a tu aplicación, es posible que ocasionalmente desee cambiar a un nuevo precio de suscripción. Para cambiar un cliente a un nuevo precio, pasa el identificador del precio de Stripe al método `swap`. Al cambiar de precios, se asume que el usuario querrá reactivar su suscripción si fue cancelada previamente. El identificador de precio dado debe corresponder a un identificador de precio de Stripe disponible en el panel de control de Stripe:


```php
use App\Models\User;

$user = App\Models\User::find(1);

$user->subscription('default')->swap('price_yearly');
```
Si el cliente está en período de prueba, se mantendrá el período de prueba. Además, si existe una "cantidad" para la suscripción, esa cantidad también se mantendrá.
Si deseas intercambiar precios y cancelar cualquier periodo de prueba en el que el cliente se encuentre actualmente, puedes invocar el método `skipTrial`:


```php
$user->subscription('default')
        ->skipTrial()
        ->swap('price_yearly');
```
Si deseas intercambiar precios e facturar al cliente de inmediato en lugar de esperar su próximo ciclo de facturación, puedes usar el método `swapAndInvoice`:


```php
$user = User::find(1);

$user->subscription('default')->swapAndInvoice('price_yearly');
```

<a name="prorations"></a>
#### Prorrateos

Por defecto, Stripe prorratea los cargos al cambiar entre precios. El método `noProrate` se puede utilizar para actualizar el precio de la suscripción sin prorratear los cargos:


```php
$user->subscription('default')->noProrate()->swap('price_yearly');
```
Para obtener más información sobre la prorrateación de suscripciones, consulta la [documentación de Stripe](https://stripe.com/docs/billing/subscriptions/prorations).
> [!WARNING]
Ejecutar el método `noProrate` antes del método `swapAndInvoice` no tendrá efecto en la prorrateo. Siempre se emitirá una factura.

<a name="subscription-quantity"></a>
### Cantidad de Suscripción

A veces las suscripciones se ven afectadas por la "cantidad". Por ejemplo, una aplicación de gestión de proyectos puede cobrar $10 por mes por proyecto. Puedes usar los métodos `incrementQuantity` y `decrementQuantity` para aumentar o disminuir fácilmente la cantidad de tu suscripción:


```php
use App\Models\User;

$user = User::find(1);

$user->subscription('default')->incrementQuantity();

// Add five to the subscription's current quantity...
$user->subscription('default')->incrementQuantity(5);

$user->subscription('default')->decrementQuantity();

// Subtract five from the subscription's current quantity...
$user->subscription('default')->decrementQuantity(5);
```
Alternativamente, puedes establecer una cantidad específica utilizando el método `updateQuantity`:


```php
$user->subscription('default')->updateQuantity(10);
```
El método `noProrate` se puede usar para actualizar la cantidad de la suscripción sin prorratear los cargos:


```php
$user->subscription('default')->noProrate()->updateQuantity(10);
```
Para obtener más información sobre las cantidades de suscripción, consulta la [documentación de Stripe](https://stripe.com/docs/subscriptions/quantities).

<a name="quantities-for-subscription-with-multiple-products"></a>
#### Cantidades para Suscripciones con Múltiples Productos

Si tu suscripción es una [suscripción con múltiples productos](#subscriptions-with-multiple-products), debes pasar el ID del precio cuya cantidad deseas incrementar o decrementar como el segundo argumento a los métodos de incremento / decremento:


```php
$user->subscription('default')->incrementQuantity(1, 'price_chat');
```

<a name="subscriptions-with-multiple-products"></a>
### Suscripciones con Múltiples Productos

[Suscripción con múltiples productos](https://stripe.com/docs/billing/subscriptions/multiple-products) te permite asignar múltiples productos de facturación a una sola suscripción. Por ejemplo, imagina que estás construyendo una aplicación de "helpdesk" para servicio al cliente que tiene un precio de suscripción base de $10 por mes, pero ofrece un producto adicional de chat en vivo por $15 adicionales al mes. La información de las suscripciones con múltiples productos se almacena en la tabla de base de datos `subscription_items` de Cashier.
Puedes especificar múltiples productos para una suscripción dada pasando un array de precios como segundo argumento al método `newSubscription`:


```php
use Illuminate\Http\Request;

Route::post('/user/subscribe', function (Request $request) {
    $request->user()->newSubscription('default', [
        'price_monthly',
        'price_chat',
    ])->create($request->paymentMethodId);

    // ...
});
```
En el ejemplo anterior, el cliente tendrá dos precios adjuntos a su suscripción `default`. Ambos precios se cobrarán en sus respectivos intervalos de facturación. Si es necesario, puedes usar el método `quantity` para indicar una cantidad específica para cada precio:


```php
$user = User::find(1);

$user->newSubscription('default', ['price_monthly', 'price_chat'])
    ->quantity(5, 'price_chat')
    ->create($paymentMethod);
```
Si deseas añadir otro precio a una suscripción existente, puedes invocar el método `addPrice` de la suscripción:


```php
$user = User::find(1);

$user->subscription('default')->addPrice('price_chat');
```
El ejemplo anterior añadirá el nuevo precio y el cliente será facturado por ello en su próximo ciclo de facturación. Si deseas facturar al cliente de inmediato, puedes usar el método `addPriceAndInvoice`:


```php
$user->subscription('default')->addPriceAndInvoice('price_chat');
```
Si deseas añadir un precio con una cantidad específica, puedes pasar la cantidad como segundo argumento de los métodos `addPrice` o `addPriceAndInvoice`:


```php
$user = User::find(1);

$user->subscription('default')->addPrice('price_chat', 5);
```
Puedes eliminar precios de las suscripciones utilizando el método `removePrice`:


```php
$user->subscription('default')->removePrice('price_chat');
```
> [!WARNING]
No puedes eliminar el último precio de una suscripción. En su lugar, simplemente debes cancelar la suscripción.

<a name="swapping-prices"></a>
#### Intercambiando Precios

También puedes cambiar los precios asociados a una suscripción con múltiples productos. Por ejemplo, imagina que un cliente tiene una suscripción `price_basic` con un producto adicional `price_chat` y deseas actualizar al cliente de `price_basic` a `price_pro`:


```php
use App\Models\User;

$user = User::find(1);

$user->subscription('default')->swap(['price_pro', 'price_chat']);
```
Al ejecutar el ejemplo anterior, el elemento de suscripción subyacente con el `price_basic` es eliminado y el que tiene el `price_chat` se preserva. Además, se crea un nuevo elemento de suscripción para el `price_pro`.
También puedes especificar opciones de artículos de suscripción pasando un array de pares clave / valor al método `swap`. Por ejemplo, es posible que necesites especificar las cantidades de precios de suscripción:


```php
$user = User::find(1);

$user->subscription('default')->swap([
    'price_pro' => ['quantity' => 5],
    'price_chat'
]);
```
Si deseas cambiar un solo precio en una suscripción, puedes hacerlo utilizando el método `swap` en el propio elemento de suscripción. Este enfoque es particularmente útil si deseas preservar todos los metadatos existentes en los otros precios de la suscripción:


```php
$user = User::find(1);

$user->subscription('default')
        ->findItemOrFail('price_basic')
        ->swap('price_pro');
```

<a name="proration"></a>
#### Prorrateo

Por defecto, Stripe ajustará proporcionalmente los cargos al añadir o eliminar precios de una suscripción con múltiples productos. Si deseas hacer un ajuste de precio sin prorrateo, debes encadenar el método `noProrate` a tu operación de precio:


```php
$user->subscription('default')->noProrate()->removePrice('price_chat');
```

<a name="swapping-quantities"></a>
#### Cantidades

Si deseas actualizar las cantidades en precios de suscripción individuales, puedes hacerlo utilizando los [métodos de cantidad existentes](#subscription-quantity) pasando el ID del precio como un argumento adicional al método:


```php
$user = User::find(1);

$user->subscription('default')->incrementQuantity(5, 'price_chat');

$user->subscription('default')->decrementQuantity(3, 'price_chat');

$user->subscription('default')->updateQuantity(10, 'price_chat');
```
> [!WARNING]
Cuando una suscripción tiene múltiples precios, los atributos `stripe_price` y `quantity` en el modelo `Subscription` serán `null`. Para acceder a los atributos de precio individuales, debes usar la relación `items` disponible en el modelo `Subscription`.

<a name="subscription-items"></a>
#### Elementos de Suscripción

Cuando una suscripción tiene múltiples precios, tendrá múltiples "elementos" de suscripción almacenados en la tabla `subscription_items` de tu base de datos. Puedes acceder a estos a través de la relación `items` en la suscripción:


```php
use App\Models\User;

$user = User::find(1);

$subscriptionItem = $user->subscription('default')->items->first();

// Retrieve the Stripe price and quantity for a specific item...
$stripePrice = $subscriptionItem->stripe_price;
$quantity = $subscriptionItem->quantity;
```
También puedes recuperar un precio específico utilizando el método `findItemOrFail`:


```php
$user = User::find(1);

$subscriptionItem = $user->subscription('default')->findItemOrFail('price_chat');
```

<a name="multiple-subscriptions"></a>
### Múltiples Suscripciones

Stripe permite que tus clientes tengan múltiples suscripciones de manera simultánea. Por ejemplo, puedes tener un gimnasio que ofrece una suscripción a natación y una suscripción a levantamiento de pesas, y cada suscripción puede tener precios diferentes. Por supuesto, los clientes deberían poder suscribirse a uno o ambos planes.
Cuando tu aplicación crea suscripciones, puedes proporcionar el tipo de suscripción al método `newSubscription`. El tipo puede ser cualquier cadena que represente el tipo de suscripción que el usuario está iniciando:


```php
use Illuminate\Http\Request;

Route::post('/swimming/subscribe', function (Request $request) {
    $request->user()->newSubscription('swimming')
        ->price('price_swimming_monthly')
        ->create($request->paymentMethodId);

    // ...
});
```
En este ejemplo, iniciamos una suscripción mensual de natación para el cliente. Sin embargo, puede que deseen cambiar a una suscripción anual en un momento posterior. Al ajustar la suscripción del cliente, podemos simplemente cambiar el precio en la suscripción `swimming`:


```php
$user->subscription('swimming')->swap('price_swimming_yearly');
```
Por supuesto, también puedes cancelar la suscripción por completo:


```php
$user->subscription('swimming')->cancel();
```

<a name="metered-billing"></a>
### Facturación Medida

[Facturación medida](https://stripe.com/docs/billing/subscriptions/metered-billing) te permite cobrar a los clientes según su uso del producto durante un ciclo de facturación. Por ejemplo, puedes cobrar a los clientes según el número de mensajes de texto o correos electrónicos que envían por mes.
Para comenzar a usar la facturación medida, primero necesitarás crear un nuevo producto en tu panel de Stripe con un precio medido. Luego, utiliza el `meteredPrice` para añadir el ID del precio medido a una suscripción de cliente:


```php
use Illuminate\Http\Request;

Route::post('/user/subscribe', function (Request $request) {
    $request->user()->newSubscription('default')
        ->meteredPrice('price_metered')
        ->create($request->paymentMethodId);

    // ...
});
```
También puedes iniciar una suscripción medida a través de [Stripe Checkout](#checkout):


```php
$checkout = Auth::user()
        ->newSubscription('default', [])
        ->meteredPrice('price_metered')
        ->checkout();

return view('your-checkout-view', [
    'checkout' => $checkout,
]);
```

<a name="reporting-usage"></a>
#### Reportando Uso

A medida que tu cliente utiliza tu aplicación, informarás su uso a Stripe para que puedan facturar de manera precisa. Para incrementar el uso de una suscripción medida, puedes usar el método `reportUsage`:


```php
$user = User::find(1);

$user->subscription('default')->reportUsage();
```
Por defecto, se añade una "cantidad de uso" de 1 al período de facturación. Alternativamente, puedes pasar una cantidad específica de "uso" para añadir al uso del cliente para el período de facturación:


```php
$user = User::find(1);

$user->subscription('default')->reportUsage(15);
```
Si tu aplicación ofrece múltiples precios en una sola suscripción, necesitarás usar el método `reportUsageFor` para especificar el precio medido para el cual deseas informar el uso:


```php
$user = User::find(1);

$user->subscription('default')->reportUsageFor('price_metered', 15);
```
A veces, es posible que necesites actualizar el uso que has informado anteriormente. Para lograr esto, puedes pasar una marca de tiempo o una instancia de `DateTimeInterface` como segundo parámetro a `reportUsage`. Al hacerlo, Stripe actualizará el uso que se informó en ese momento dado. Puedes seguir actualizando registros de uso anteriores mientras la fecha y hora dadas aún estén dentro del período de facturación actual:


```php
$user = User::find(1);

$user->subscription('default')->reportUsage(5, $timestamp);
```

<a name="retrieving-usage-records"></a>
#### Recuperando Registros de Uso

Para recuperar el uso pasado de un cliente, puedes usar el método `usageRecords` de una instancia de suscripción:


```php
$user = User::find(1);

$usageRecords = $user->subscription('default')->usageRecords();
```
Si tu aplicación ofrece múltiples precios en una sola suscripción, puedes usar el método `usageRecordsFor` para especificar el precio medido del cual deseas recuperar los registros de uso:


```php
$user = User::find(1);

$usageRecords = $user->subscription('default')->usageRecordsFor('price_metered');
```
Los métodos `usageRecords` y `usageRecordsFor` devuelven una instancia de Collection que contiene un array asociativo de registros de uso. Puedes iterar sobre este array para mostrar el uso total de un cliente:


```php
@foreach ($usageRecords as $usageRecord)
    - Period Starting: {{ $usageRecord['period']['start'] }}
    - Period Ending: {{ $usageRecord['period']['end'] }}
    - Total Usage: {{ $usageRecord['total_usage'] }}
@endforeach
```
Para una referencia completa de todos los datos de uso devueltos y cómo utilizar la paginación basada en el cursor de Stripe, consulta [la documentación oficial de la API de Stripe](https://stripe.com/docs/api/usage_records/subscription_item_summary_list).

<a name="subscription-taxes"></a>
### Impuestos de Suscripción

> [!WARNING]
En lugar de calcular las tasas de impuestos manualmente, puedes [calcular impuestos automáticamente utilizando Stripe Tax](#tax-configuration)
Para especificar las tasas de impuestos que un usuario paga en una suscripción, debes implementar el método `taxRates` en tu modelo facturable y devolver un array que contenga los IDs de tasa de impuesto de Stripe. Puedes definir estas tasas de impuestos en [tu panel de control de Stripe](https://dashboard.stripe.com/test/tax-rates):


```php
/**
 * The tax rates that should apply to the customer's subscriptions.
 *
 * @return array<int, string>
 */
public function taxRates(): array
{
    return ['txr_id'];
}
```
El método `taxRates` te permite aplicar una tasa de impuestos de cliente a cliente, lo que puede ser útil para una base de usuarios que abarca múltiples países y tasas impositivas.
Si estás ofreciendo suscripciones con múltiples productos, puedes definir diferentes tasas de impuestos para cada precio implementando un método `priceTaxRates` en tu modelo facturable:


```php
/**
 * The tax rates that should apply to the customer's subscriptions.
 *
 * @return array<string, array<int, string>>
 */
public function priceTaxRates(): array
{
    return [
        'price_monthly' => ['txr_id'],
    ];
}
```
> [!WARNING]
El método `taxRates` solo se aplica a los cargos de suscripción. Si utilizas Cashier para hacer cargos "puntuales", necesitarás especificar manualmente la tasa impositiva en ese momento.

<a name="syncing-tax-rates"></a>
#### Sincronizando Tasas Impositivas

Al cambiar los ID de tasas de impuestos codificados de forma rígida que devuelve el método `taxRates`, la configuración de impuestos en cualquier suscripción existente para el usuario permanecerá igual. Si deseas actualizar el valor de impuestos para las suscripciones existentes con los nuevos valores de `taxRates`, debes llamar al método `syncTaxRates` en la instancia de suscripción del usuario:


```php
$user->subscription('default')->syncTaxRates();
```
Esto también sincronizará las tasas de impuestos de cualquier elemento para una suscripción con múltiples productos. Si tu aplicación está ofreciendo suscripciones con múltiples productos, debes asegurarte de que tu modelo facturable implemente el método `priceTaxRates` [discutido arriba](#subscription-taxes).

<a name="tax-exemption"></a>
#### Exención de Impuestos

Cashier también ofrece los métodos `isNotTaxExempt`, `isTaxExempt` y `reverseChargeApplies` para determinar si el cliente está exento de impuestos. Estos métodos llamarán a la API de Stripe para determinar el estado de exención de impuestos de un cliente:


```php
use App\Models\User;

$user = User::find(1);

$user->isTaxExempt();
$user->isNotTaxExempt();
$user->reverseChargeApplies();
```
> [!WARNING]
Estos métodos también están disponibles en cualquier objeto `Laravel\Cashier\Invoice`. Sin embargo, cuando se invocan en un objeto `Invoice`, los métodos determinarán el estado de exención en el momento en que se creó la factura.

<a name="subscription-anchor-date"></a>
### Fecha de Ancla de Suscripción

Por defecto, el ancla del ciclo de facturación es la fecha en que se creó la suscripción o, si se utiliza un período de prueba, la fecha en que finaliza la prueba. Si deseas modificar la fecha del ancla de facturación, puedes usar el método `anchorBillingCycleOn`:


```php
use Illuminate\Http\Request;

Route::post('/user/subscribe', function (Request $request) {
    $anchor = Carbon::parse('first day of next month');

    $request->user()->newSubscription('default', 'price_monthly')
                ->anchorBillingCycleOn($anchor->startOfDay())
                ->create($request->paymentMethodId);

    // ...
});
```
Para obtener más información sobre la gestión de ciclos de facturación de suscripciones, consulta la [documentación del ciclo de facturación de Stripe](https://stripe.com/docs/billing/subscriptions/billing-cycle)

<a name="cancelling-subscriptions"></a>
### Cancelando Suscripciones

Para cancelar una suscripción, llama al método `cancel` en la suscripción del usuario:


```php
$user->subscription('default')->cancel();
```
Cuando se cancela una suscripción, Cashier establecerá automáticamente la columna `ends_at` en tu tabla de base de datos `subscriptions`. Esta columna se utiliza para saber cuándo el método `subscribed` debe comenzar a devolver `false`.
Por ejemplo, si un cliente cancela una suscripción el 1 de marzo, pero la suscripción no estaba programada para finalizar hasta el 5 de marzo, el método `subscribed` seguirá devolviendo `true` hasta el 5 de marzo. Esto se hace porque generalmente se permite a un usuario seguir utilizando una aplicación hasta el final de su ciclo de facturación.
Puedes determinar si un usuario ha cancelado su suscripción pero aún está en su "período de gracia" utilizando el método `onGracePeriod`:


```php
if ($user->subscription('default')->onGracePeriod()) {
    // ...
}
```
Si deseas cancelar una suscripción de inmediato, llama al método `cancelNow` en la suscripción del usuario:


```php
$user->subscription('default')->cancelNow();
```
Si deseas cancelar una suscripción de inmediato e incluir en la factura cualquier uso medido no facturado restante o nuevos elementos de factura de prorrateo pendientes, llama al método `cancelNowAndInvoice` en la suscripción del usuario:


```php
$user->subscription('default')->cancelNowAndInvoice();
```
También puedes elegir cancelar la suscripción en un momento específico:


```php
$user->subscription('default')->cancelAt(
    now()->addDays(10)
);
```
Finalmente, siempre debes cancelar las suscripciones de los usuarios antes de eliminar el modelo de usuario asociado:


```php
$user->subscription('default')->cancelNow();

$user->delete();
```

<a name="resuming-subscriptions"></a>
### Reanudando Suscripciones

Si un cliente ha cancelado su suscripción y deseas reanudarla, puedes invocar el método `resume` en la suscripción. El cliente debe seguir estando dentro de su "período de gracia" para poder reanudar una suscripción:


```php
$user->subscription('default')->resume();
```
Si el cliente cancela una suscripción y luego reanuda esa suscripción antes de que la suscripción haya expirado completamente, el cliente no será facturado de inmediato. En su lugar, su suscripción se reactivará y se les facturará en el ciclo de facturación original.

<a name="subscription-trials"></a>
## Pruebas de Suscripción


<a name="with-payment-method-up-front"></a>
### Con Método de Pago Anticipado

Si deseas ofrecer períodos de prueba a tus clientes mientras aun así collects información del método de pago por adelantado, deberías usar el método `trialDays` al crear tus suscripciones:


```php
use Illuminate\Http\Request;

Route::post('/user/subscribe', function (Request $request) {
    $request->user()->newSubscription('default', 'price_monthly')
                ->trialDays(10)
                ->create($request->paymentMethodId);

    // ...
});
```
Este método establecerá la fecha de finalización del período de prueba en el registro de suscripción dentro de la base de datos e instruirá a Stripe para que no comience a facturar al cliente hasta después de esta fecha. Al usar el método `trialDays`, Cashier sobrescribirá cualquier período de prueba predeterminado configurado para el precio en Stripe.
> [!WARNING]
Si la suscripción del cliente no se cancela antes de la fecha de finalización de la prueba, se les cobrará tan pronto como expire la prueba, así que debes asegurarte de notificar a tus usuarios sobre la fecha de finalización de su prueba.
El método `trialUntil` te permite proporcionar una instancia de `DateTime` que especifica cuándo debe finalizar el período de prueba:


```php
use Carbon\Carbon;

$user->newSubscription('default', 'price_monthly')
            ->trialUntil(Carbon::now()->addDays(10))
            ->create($paymentMethod);
```
Puedes determinar si un usuario está dentro de su período de prueba utilizando ya sea el método `onTrial` de la instancia del usuario o el método `onTrial` de la instancia de la suscripción. Los dos ejemplos a continuación son equivalentes:


```php
if ($user->onTrial('default')) {
    // ...
}

if ($user->subscription('default')->onTrial()) {
    // ...
}
```
Puedes usar el método `endTrial` para finalizar inmediatamente un período de prueba de suscripción:


```php
$user->subscription('default')->endTrial();
```
Para determinar si un período de prueba existente ha expirado, puedes usar los métodos `hasExpiredTrial`:


```php
if ($user->hasExpiredTrial('default')) {
    // ...
}

if ($user->subscription('default')->hasExpiredTrial()) {
    // ...
}
```

<a name="defining-trial-days-in-stripe-cashier"></a>
#### Definiendo Días de Prueba en Stripe / Cashier

Puedes elegir definir cuántos días de prueba recibirán los precios en el panel de Stripe o siempre pasarlos explícitamente utilizando Cashier. Si eliges definir los días de prueba de tu precio en Stripe, debes tener en cuenta que las nuevas suscripciones, incluidas las nuevas suscripciones para un cliente que tuvo una suscripción en el pasado, siempre recibirán un período de prueba a menos que llames explícitamente al método `skipTrial()`.

<a name="without-payment-method-up-front"></a>
### Sin Método de Pago por Adelantado

Si deseas ofrecer períodos de prueba sin recopilar la información del método de pago del usuario por adelantado, puedes establecer la columna `trial_ends_at` en el registro del usuario a la fecha de finalización de prueba deseada. Esto se hace típicamente durante el registro del usuario:


```php
use App\Models\User;

$user = User::create([
    // ...
    'trial_ends_at' => now()->addDays(10),
]);
```
> [!WARNING]
Asegúrate de añadir un [date cast](/docs/%7B%7Bversion%7D%7D/eloquent-mutators#date-casting) para el atributo `trial_ends_at` dentro de la definición de la clase de tu modelo facturable.
Cashier se refiere a este tipo de prueba como una "prueba genérica", ya que no está vinculada a ninguna suscripción existente. El método `onTrial` en la instancia del modelo facturable devolverá `true` si la fecha actual no ha pasado el valor de `trial_ends_at`:


```php
if ($user->onTrial()) {
    // User is within their trial period...
}
```
Una vez que estés listo para crear una suscripción real para el usuario, puedes usar el método `newSubscription` como de costumbre:


```php
$user = User::find(1);

$user->newSubscription('default', 'price_monthly')->create($paymentMethod);
```
Para recuperar la fecha de finalización de la prueba del usuario, puedes usar el método `trialEndsAt`. Este método devolverá una instancia de fecha Carbon si un usuario está en un período de prueba o `null` si no lo está. También puedes pasar un parámetro opcional de tipo de suscripción si deseas obtener la fecha de finalización de la prueba para una suscripción específica además de la predeterminada:


```php
if ($user->onTrial()) {
    $trialEndsAt = $user->trialEndsAt('main');
}
```
También puedes usar el método `onGenericTrial` si deseas saber específicamente que el usuario está dentro de su período de prueba "genérico" y aún no ha creado una suscripción activa:


```php
if ($user->onGenericTrial()) {
    // User is within their "generic" trial period...
}
```

<a name="extending-trials"></a>
### Extendiendo Pruebas

El método `extendTrial` te permite extender el período de prueba de una suscripción después de que se haya creado la suscripción. Si el período de prueba ya ha expirado y el cliente ya está siendo facturado por la suscripción, aún puedes ofrecerles una prueba extendida. El tiempo transcurrido dentro del período de prueba se deducirá de la próxima factura del cliente:


```php
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
```

<a name="handling-stripe-webhooks"></a>
## Manejo de Webhooks de Stripe

> [!NOTE]
Puedes usar [la CLI de Stripe](https://stripe.com/docs/stripe-cli) para ayudar a probar webhooks durante el desarrollo local.
Stripe puede notificar a tu aplicación sobre una variedad de eventos a través de webhooks. Por defecto, se registra automáticamente una ruta que apunta al controlador de webhooks de Cashier por el proveedor de servicios de Cashier. Este controlador manejará todas las solicitudes de webhook entrantes.
Por defecto, el controlador de webhook de Cashier gestionará automáticamente la cancelación de suscripciones que tienen demasiados cargos fallidos (según lo definido por tu configuración de Stripe), actualizaciones de clientes, eliminaciones de clientes, actualizaciones de suscripciones y cambios en el método de pago; sin embargo, como pronto descubriremos, puedes extender este controlador para manejar cualquier evento de webhook de Stripe que desees.
Para asegurarte de que tu aplicación pueda manejar los webhooks de Stripe, asegúrate de configurar la URL del webhook en el panel de control de Stripe. Por defecto, el controlador de webhooks de Cashier responde a la ruta de URL `/stripe/webhook`. La lista completa de todos los webhooks que debes habilitar en el panel de control de Stripe es:
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `customer.updated`
- `customer.deleted`
- `payment_method.automatically_updated`
- `invoice.payment_action_required`
- `invoice.payment_succeeded`
Para mayor comodidad, Cashier incluye un comando Artisan `cashier:webhook`. Este comando creará un webhook en Stripe que escucha todos los eventos requeridos por Cashier:


```shell
php artisan cashier:webhook

```
Por defecto, el webhook creado apuntará a la URL definida por la variable de entorno `APP_URL` y la ruta `cashier.webhook` que se incluye con Cashier. Puedes proporcionar la opción `--url` al invocar el comando si deseas usar una URL diferente:


```shell
php artisan cashier:webhook --url "https://example.com/stripe/webhook"

```
El webhook que se crea utilizará la versión de API de Stripe con la que tu versión de Cashier es compatible. Si deseas usar una versión diferente de Stripe, puedes proporcionar la opción `--api-version`:


```shell
php artisan cashier:webhook --api-version="2019-12-03"

```
Después de la creación, el webhook estará inmediatamente activo. Si deseas crear el webhook pero tenerlo deshabilitado hasta que estés listo, puedes proporcionar la opción `--disabled` al invocar el comando:


```shell
php artisan cashier:webhook --disabled

```
> [!WARNING]
Asegúrate de proteger las solicitudes de webhook entrantes de Stripe con el middleware de [verificación de firma de webhook](#verifying-webhook-signatures) incluido en Cashier.

<a name="webhooks-csrf-protection"></a>
#### Webhooks y Protección CSRF

Dado que los webhooks de Stripe necesitan eludir la [protección CSRF](/docs/%7B%7Bversion%7D%7D/csrf) de Laravel, debes asegurarte de que Laravel no intente validar el token CSRF para los webhooks de Stripe entrantes. Para lograr esto, debes excluir `stripe/*` de la protección CSRF en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->validateCsrfTokens(except: [
        'stripe/*',
    ]);
})
```

<a name="defining-webhook-event-handlers"></a>
### Definiendo Controladores de Eventos Webhook

Cashier maneja automáticamente las cancelaciones de suscripciones para cargos fallidos y otros eventos comunes de webhook de Stripe. Sin embargo, si tienes eventos de webhook adicionales que te gustaría manejar, puedes hacerlo escuchando los siguientes eventos que son despachados por Cashier:
- `Laravel\Cashier\Events\WebhookReceived`
- `Laravel\Cashier\Events\WebhookHandled`
Ambos eventos contienen la carga útil completa del webhook de Stripe. Por ejemplo, si deseas manejar el webhook `invoice.payment_succeeded`, puedes registrar un [listener](/docs/%7B%7Bversion%7D%7D/events#defining-listeners) que manejará el evento:


```php
<?php

namespace App\Listeners;

use Laravel\Cashier\Events\WebhookReceived;

class StripeEventListener
{
    /**
     * Handle received Stripe webhooks.
     */
    public function handle(WebhookReceived $event): void
    {
        if ($event->payload['type'] === 'invoice.payment_succeeded') {
            // Handle the incoming event...
        }
    }
}
```

<a name="verifying-webhook-signatures"></a>
### Verificando Firmas de Webhook

Para asegurar tus webhooks, puedes usar [las firmas de webhook de Stripe](https://stripe.com/docs/webhooks/signatures). Para mayor comodidad, Cashier incluye automáticamente un middleware que valida que la solicitud del webhook de Stripe entrante sea válida.
Para habilitar la verificación del webhook, asegúrate de que la variable de entorno `STRIPE_WEBHOOK_SECRET` esté configurada en el archivo `.env` de tu aplicación. El `secreto` del webhook se puede obtener del panel de control de tu cuenta de Stripe.

<a name="single-charges"></a>
## Cargos Únicos


<a name="simple-charge"></a>
### Cargo Simple

Si deseas realizar un cargo único a un cliente, puedes usar el método `charge` en una instancia del modelo facturable. Necesitarás [proporcionar un identificador de método de pago](#payment-methods-for-single-charges) como segundo argumento al método `charge`:


```php
use Illuminate\Http\Request;

Route::post('/purchase', function (Request $request) {
    $stripeCharge = $request->user()->charge(
        100, $request->paymentMethodId
    );

    // ...
});
```
El método `charge` acepta un array como su tercer argumento, lo que te permite pasar cualquier opción que desees a la creación del cargo subyacente en Stripe. Puedes encontrar más información sobre las opciones disponibles al crear cargos en la [documentación de Stripe](https://stripe.com/docs/api/charges/create):


```php
$user->charge(100, $paymentMethod, [
    'custom_option' => $value,
]);
```
También puedes utilizar el método `charge` sin un cliente o usuario subyacente. Para lograr esto, invoca el método `charge` en una nueva instancia del modelo facturable de tu aplicación:


```php
use App\Models\User;

$stripeCharge = (new User)->charge(100, $paymentMethod);
```
El método `charge` lanzará una excepción si el cargo falla. Si el cargo es exitoso, se devolverá una instancia de `Laravel\Cashier\Payment` desde el método:


```php
try {
    $payment = $user->charge(100, $paymentMethod);
} catch (Exception $e) {
    // ...
}
```
> [!WARNING]
El método `charge` acepta el monto del pago en el menor denominador de la moneda utilizada por su aplicación. Por ejemplo, si los clientes están pagando en dólares estadounidenses, los montos deben especificarse en centavos.

<a name="charge-with-invoice"></a>
### Cargar con Factura

A veces es posible que necesites hacer un cargo único y ofrecer una factura en PDF a tu cliente. El método `invoicePrice` te permite hacer precisamente eso. Por ejemplo, vamos a facturar a un cliente por cinco camisetas nuevas:


```php
$user->invoicePrice('price_tshirt', 5);
```
La factura se cargará inmediatamente contra el método de pago predeterminado del usuario. El método `invoicePrice` también acepta un array como su tercer argumento. Este array contiene las opciones de facturación para el elemento de factura. El cuarto argumento aceptado por el método también es un array que debe contener las opciones de facturación para la propia factura:


```php
$user->invoicePrice('price_tshirt', 5, [
    'discounts' => [
        ['coupon' => 'SUMMER21SALE']
    ],
], [
    'default_tax_rates' => ['txr_id'],
]);
```
De manera similar a `invoicePrice`, puedes usar el método `tabPrice` para crear un cargo único por múltiples artículos (hasta 250 artículos por factura) añadiéndolos al "tab" del cliente y luego facturando al cliente. Por ejemplo, podemos facturar a un cliente por cinco camisas y dos tazas:


```php
$user->tabPrice('price_tshirt', 5);
$user->tabPrice('price_mug', 2);
$user->invoice();
```
Alternativamente, puedes usar el método `invoiceFor` para hacer un cargo "único" contra el método de pago predeterminado del cliente:


```php
$user->invoiceFor('One Time Fee', 500);
```
Aunque el método `invoiceFor` está disponible para que lo uses, se recomienda que utilices los métodos `invoicePrice` y `tabPrice` con precios predefinidos. Al hacerlo, tendrás acceso a mejores análisis y datos dentro de tu panel de control de Stripe sobre tus ventas de manera individual por producto.
> [!WARNING]
Los métodos `invoice`, `invoicePrice` e `invoiceFor` crearán una factura de Stripe que reiniciará los intentos de facturación fallidos. Si no desea que las facturas intenten nuevamente los cargos fallidos, deberá cerrarlas utilizando la API de Stripe después del primer cargo fallido.

<a name="creating-payment-intents"></a>
### Creando Intenciones de Pago

Puedes crear un nuevo intent de pago de Stripe invocando el método `pay` en una instancia de un modelo facturable. Llamar a este método creará un intento de pago que está envuelto en una instancia de `Laravel\Cashier\Payment`:


```php
use Illuminate\Http\Request;

Route::post('/pay', function (Request $request) {
    $payment = $request->user()->pay(
        $request->get('amount')
    );

    return $payment->client_secret;
});
```
Después de crear el intento de pago, puedes devolver el secreto del cliente al frontend de tu aplicación para que el usuario pueda completar el pago en su navegador. Para leer más sobre la construcción de flujos de pago completos utilizando intentos de pago de Stripe, consulta la [documentación de Stripe](https://stripe.com/docs/payments/accept-a-payment?platform=web).
Al usar el método `pay`, los métodos de pago predeterminados que están habilitados dentro de tu panel de Stripe estarán disponibles para el cliente. Alternativamente, si solo deseas permitir el uso de algunos métodos de pago específicos, puedes usar el método `payWith`:


```php
use Illuminate\Http\Request;

Route::post('/pay', function (Request $request) {
    $payment = $request->user()->payWith(
        $request->get('amount'), ['card', 'bancontact']
    );

    return $payment->client_secret;
});
```
> [!WARNING]
Los métodos `pay` y `payWith` aceptan el monto del pago en el menor denominador de la moneda utilizada por su aplicación. Por ejemplo, si los clientes están pagando en dólares estadounidenses, los montos deben especificarse en centavos.

<a name="refunding-charges"></a>
### Reembolsando Cargos

Si necesitas reembolsar un cargo de Stripe, puedes usar el método `refund`. Este método acepta el [ID de la intención de pago](#payment-methods-for-single-charges) de Stripe como su primer argumento:


```php
$payment = $user->charge(100, $paymentMethodId);

$user->refund($payment->id);
```

<a name="invoices"></a>
## Facturas


<a name="retrieving-invoices"></a>
### Recuperando Facturas

Puedes recuperar fácilmente un array de las facturas de un modelo facturable utilizando el método `invoices`. El método `invoices` devuelve una colección de instancias de `Laravel\Cashier\Invoice`:


```php
$invoices = $user->invoices();
```
Si deseas incluir facturas pendientes en los resultados, puedes usar el método `invoicesIncludingPending`:


```php
$invoices = $user->invoicesIncludingPending();
```
Puedes usar el método `findInvoice` para recuperar una factura específica por su ID:


```php
$invoice = $user->findInvoice($invoiceId);
```

<a name="displaying-invoice-information"></a>
#### Mostrando la Información de la Factura

Al listar las facturas del cliente, puedes usar los métodos de la factura para mostrar la información relevante de la factura. Por ejemplo, es posible que desees listar cada factura en una tabla, permitiendo al usuario descargar fácilmente cualquiera de ellas:


```php
<table>
    @foreach ($invoices as $invoice)
        <tr>
            <td>{{ $invoice->date()->toFormattedDateString() }}</td>
            <td>{{ $invoice->total() }}</td>
            <td><a href="/user/invoice/{{ $invoice->id }}">Download</a></td>
        </tr>
    @endforeach
</table>
```

<a name="upcoming-invoices"></a>
### Facturas Próximas

Para recuperar la próxima factura de un cliente, puedes usar el método `upcomingInvoice`:


```php
$invoice = $user->upcomingInvoice();
```
De manera similar, si el cliente tiene múltiples suscripciones, también puedes recuperar la próxima factura para una suscripción específica:


```php
$invoice = $user->subscription('default')->upcomingInvoice();
```

<a name="previewing-subscription-invoices"></a>
### Vista previa de las Facturas de Suscripción

Usando el método `previewInvoice`, puedes previsualizar una factura antes de realizar cambios de precio. Esto te permitirá determinar cómo se verá la factura de tu cliente cuando se realice un cambio de precio dado:


```php
$invoice = $user->subscription('default')->previewInvoice('price_yearly');
```
Puedes pasar un array de precios al método `previewInvoice` para previsualizar facturas con múltiples precios nuevos:


```php
$invoice = $user->subscription('default')->previewInvoice(['price_yearly', 'price_metered']);
```

<a name="generating-invoice-pdfs"></a>
### Generando PDFs de Factura

Antes de generar PDFs de facturas, debes usar Composer para instalar la biblioteca Dompdf, que es el renderizador de facturas por defecto para Cashier:


```php
composer require dompdf/dompdf

```
Desde dentro de una ruta o controlador, puedes usar el método `downloadInvoice` para generar una descarga PDF de una factura dada. Este método generará automáticamente la respuesta HTTP adecuada necesaria para descargar la factura:


```php
use Illuminate\Http\Request;

Route::get('/user/invoice/{invoice}', function (Request $request, string $invoiceId) {
    return $request->user()->downloadInvoice($invoiceId);
});
```
Por defecto, todos los datos de la factura se derivan de los datos del cliente y de la factura almacenados en Stripe. El nombre del archivo se basa en tu valor de configuración `app.name`. Sin embargo, puedes personalizar algunos de estos datos proporcionando un array como segundo argumento al método `downloadInvoice`. Este array te permite personalizar información como los detalles de tu empresa y producto:


```php
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
```
El método `downloadInvoice` también permite un nombre de archivo personalizado a través de su tercer argumento. Este nombre de archivo se verá automáticamente con el sufijo `.pdf`:


```php
return $request->user()->downloadInvoice($invoiceId, [], 'my-invoice');
```

<a name="custom-invoice-render"></a>
#### Renderizador de Factura Personalizado

Cashier también permite usar un renderizador de facturas personalizado. Por defecto, Cashier utiliza la implementación `DompdfInvoiceRenderer`, que utiliza la biblioteca PHP [dompdf](https://github.com/dompdf/dompdf) para generar las facturas de Cashier. Sin embargo, puedes usar cualquier renderizador que desees implementando la interfaz `Laravel\Cashier\Contracts\InvoiceRenderer`. Por ejemplo, es posible que desees renderizar un PDF de factura utilizando una llamada a la API a un servicio de renderizado de PDF de terceros:


```php
use Illuminate\Support\Facades\Http;
use Laravel\Cashier\Contracts\InvoiceRenderer;
use Laravel\Cashier\Invoice;

class ApiInvoiceRenderer implements InvoiceRenderer
{
    /**
     * Render the given invoice and return the raw PDF bytes.
     */
    public function render(Invoice $invoice, array $data = [], array $options = []): string
    {
        $html = $invoice->view($data)->render();

        return Http::get('https://example.com/html-to-pdf', ['html' => $html])->get()->body();
    }
}
```
Una vez que hayas implementado el contrato del renderizador de facturas, deberías actualizar el valor de configuración `cashier.invoices.renderer` en el archivo de configuración `config/cashier.php` de tu aplicación. Este valor de configuración debe establecerse en el nombre de la clase de tu implementación personalizada del renderizador.

<a name="checkout"></a>
## Checkout

Cashier Stripe también proporciona soporte para [Stripe Checkout](https://stripe.com/payments/checkout). Stripe Checkout elimina la dificultad de implementar páginas personalizadas para aceptar pagos al ofrecer una página de pago alojada y preconstruida.
La siguiente documentación contiene información sobre cómo comenzar a usar Stripe Checkout con Cashier. Para obtener más información sobre Stripe Checkout, también deberías considerar revisar [la documentación de Stripe sobre Checkout](https://stripe.com/docs/payments/checkout).

<a name="product-checkouts"></a>
### Comprobaciones de Productos

Puedes realizar un checkout para un producto existente que ha sido creado dentro de tu dashboard de Stripe utilizando el método `checkout` en un modelo facturable. El método `checkout` iniciará una nueva sesión de Stripe Checkout. Por defecto, se requiere que pases un ID de precio de Stripe:


```php
use Illuminate\Http\Request;

Route::get('/product-checkout', function (Request $request) {
    return $request->user()->checkout('price_tshirt');
});
```
Si es necesario, también puedes especificar una cantidad de producto:


```php
use Illuminate\Http\Request;

Route::get('/product-checkout', function (Request $request) {
    return $request->user()->checkout(['price_tshirt' => 15]);
});
```
Cuando un cliente visita esta ruta, será redirigido a la página de pago de Stripe. Por defecto, cuando un usuario completa o cancela una compra con éxito, será redirigido a la ubicación de tu ruta `home`, pero puedes especificar URL de retorno personalizadas utilizando las opciones `success_url` y `cancel_url`:


```php
use Illuminate\Http\Request;

Route::get('/product-checkout', function (Request $request) {
    return $request->user()->checkout(['price_tshirt' => 1], [
        'success_url' => route('your-success-route'),
        'cancel_url' => route('your-cancel-route'),
    ]);
});
```
Al definir tu opción de checkout `success_url`, puedes instruir a Stripe para que añada el ID de la sesión de checkout como un parámetro de cadena de consulta al invocar tu URL. Para hacerlo, añade la cadena literal `{CHECKOUT_SESSION_ID}` a la cadena de consulta de tu `success_url`. Stripe reemplazará este marcador de posición con el ID real de la sesión de checkout:


```php
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
```

<a name="checkout-promotion-codes"></a>
#### Códigos de Promoción

Por defecto, Stripe Checkout no permite [códigos de promoción canjeables por el usuario](https://stripe.com/docs/billing/subscriptions/discounts/codes). Afortunadamente, hay una manera fácil de habilitar estos códigos en tu página de Checkout. Para hacerlo, puedes invocar el método `allowPromotionCodes`:


```php
use Illuminate\Http\Request;

Route::get('/product-checkout', function (Request $request) {
    return $request->user()
        ->allowPromotionCodes()
        ->checkout('price_tshirt');
});
```

<a name="single-charge-checkouts"></a>
### Verificaciones de Carga Única

También puedes realizar un cargo simple por un producto ad-hoc que no ha sido creado en tu dashboard de Stripe. Para hacerlo, puedes usar el método `checkoutCharge` en un modelo facturable y pasarle un monto cobrable, un nombre de producto y una cantidad opcional. Cuando un cliente visite esta ruta, será redirigido a la página de pago de Stripe:


```php
use Illuminate\Http\Request;

Route::get('/charge-checkout', function (Request $request) {
    return $request->user()->checkoutCharge(1200, 'T-Shirt', 5);
});
```
> [!WARNING]
Al utilizar el método `checkoutCharge`, Stripe siempre creará un nuevo producto y precio en tu panel de control de Stripe. Por lo tanto, te recomendamos que crees los productos de antemano en tu panel de control de Stripe y uses el método `checkout` en su lugar.

<a name="subscription-checkouts"></a>
### Verificaciones de Suscripción

> [!WARNING]
Usar Stripe Checkout para suscripciones requiere que habilites el webhook `customer.subscription.created` en tu panel de control de Stripe. Este webhook creará el registro de suscripción en tu base de datos y almacenará todos los elementos de suscripción relevantes.
También puedes usar Stripe Checkout para iniciar suscripciones. Después de definir tu suscripción con los métodos de generador de suscripciones de Cashier, puedes llamar al método `checkout`. Cuando un cliente visite esta ruta, será redirigido a la página de pago de Stripe:


```php
use Illuminate\Http\Request;

Route::get('/subscription-checkout', function (Request $request) {
    return $request->user()
        ->newSubscription('default', 'price_monthly')
        ->checkout();
});
```
Al igual que con los pagos de productos, puedes personalizar las URL de éxito y cancelación:


```php
use Illuminate\Http\Request;

Route::get('/subscription-checkout', function (Request $request) {
    return $request->user()
        ->newSubscription('default', 'price_monthly')
        ->checkout([
            'success_url' => route('your-success-route'),
            'cancel_url' => route('your-cancel-route'),
        ]);
});
```
Por supuesto, también puedes activar códigos de promoción para las finalizaciones de suscripción:


```php
use Illuminate\Http\Request;

Route::get('/subscription-checkout', function (Request $request) {
    return $request->user()
        ->newSubscription('default', 'price_monthly')
        ->allowPromotionCodes()
        ->checkout();
});
```
> [!WARNING]
Desafortunadamente, Stripe Checkout no admite todas las opciones de facturación de suscripción al iniciar suscripciones. Utilizar el método `anchorBillingCycleOn` en el constructor de suscripciones, establecer el comportamiento de prorrateo o configurar el comportamiento de pago no tendrá ningún efecto durante las sesiones de Stripe Checkout. Por favor, consulta [la documentación de la API de la sesión de Stripe Checkout](https://stripe.com/docs/api/checkout/sessions/create) para revisar qué parámetros están disponibles.

<a name="stripe-checkout-trial-periods"></a>
#### Stripe Checkout y Períodos de Prueba

Por supuesto, puedes definir un período de prueba al crear una suscripción que se completará utilizando Stripe Checkout:


```php
$checkout = Auth::user()->newSubscription('default', 'price_monthly')
    ->trialDays(3)
    ->checkout();
```
Sin embargo, el período de prueba debe ser de al menos 48 horas, que es la cantidad mínima de tiempo de prueba admitida por Stripe Checkout.

<a name="stripe-checkout-subscriptions-and-webhooks"></a>
#### Suscripciones y Webhooks

Recuerda que Stripe y Cashier actualizan los estados de suscripción a través de webhooks, por lo que existe la posibilidad de que una suscripción aún no esté activa cuando el cliente regresa a la aplicación después de ingresar su información de pago. Para manejar este escenario, es posible que desees mostrar un mensaje informando al usuario que su pago o suscripción está pendiente.

<a name="collecting-tax-ids"></a>
### Recolección de ID de impuestos

El checkout también admite la recopilación del ID de impuestos de un cliente. Para habilitar esto en una sesión de checkout, invoca el método `collectTaxIds` al crear la sesión:


```php
$checkout = $user->collectTaxIds()->checkout('price_tshirt');
```
Cuando se invoque este método, habrá una nueva casilla de verificación disponible para el cliente que les permitirá indicar si están comprando como una empresa. Si es así, tendrán la oportunidad de proporcionar su número de identificación fiscal.
> [!WARNING]
Si ya has configurado la [recolección de impuestos automática](#tax-configuration) en el proveedor de servicios de tu aplicación, entonces esta función se habilitará automáticamente y no es necesario invocar el método `collectTaxIds`.

<a name="guest-checkouts"></a>
### Checkouts de Invitados

Usando el método `Checkout::guest`, puedes iniciar sesiones de checkout para los invitados de tu aplicación que no tienen una "cuenta":


```php
use Illuminate\Http\Request;
use Laravel\Cashier\Checkout;

Route::get('/product-checkout', function (Request $request) {
    return Checkout::guest()->create('price_tshirt', [
        'success_url' => route('your-success-route'),
        'cancel_url' => route('your-cancel-route'),
    ]);
});
```
De manera similar a cuando se crean sesiones de pago para usuarios existentes, puedes utilizar métodos adicionales disponibles en la instancia `Laravel\Cashier\CheckoutBuilder` para personalizar la sesión de pago de invitados:


```php
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
```
Después de que se haya completado un pago como invitado, Stripe puede enviar un evento webhook `checkout.session.completed`, así que asegúrate de [configurar tu webhook de Stripe](https://dashboard.stripe.com/webhooks) para que realmente envíe este evento a tu aplicación. Una vez que el webhook haya sido habilitado dentro del panel de control de Stripe, puedes [manejar el webhook con Cashier](#handling-stripe-webhooks). El objeto contenido en la carga útil del webhook será un objeto [`checkout`](https://stripe.com/docs/api/checkout/sessions/object) que puedes inspeccionar para cumplir con el pedido de tu cliente.

<a name="handling-failed-payments"></a>
## Manejo de Pagos Fallidos

A veces, los pagos por suscripciones o cargos únicos pueden fallar. Cuando esto sucede, Cashier lanzará una excepción `Laravel\Cashier\Exceptions\IncompletePayment` que te informa que esto ocurrió. Después de capturar esta excepción, tienes dos opciones sobre cómo proceder.
Primero, puedes redirigir a tu cliente a la página de confirmación de pago dedicada que se incluye con Cashier. Esta página ya tiene una ruta nombrada asociada que está registrada a través del proveedor de servicios de Cashier. Así que puedes capturar la excepción `IncompletePayment` y redirigir al usuario a la página de confirmación de pago:


```php
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
```
En la página de confirmación de pago, se pedirá al cliente que introduzca nuevamente su información de tarjeta de crédito y realice cualquier acción adicional requerida por Stripe, como la confirmación de "3D Secure". Después de confirmar su pago, el usuario será redirigido a la URL proporcionada por el parámetro `redirect` especificado arriba. Al ser redirigido, se añadirán las variables de cadena de consulta `message` (cadena) y `success` (entero) a la URL. La página de pago actualmente admite los siguientes tipos de métodos de pago:
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
Alternativamente, podrías permitir que Stripe maneje la confirmación de pago por ti. En este caso, en lugar de redirigir a la página de confirmación de pago, puedes [configurar los correos electrónicos de facturación automáticos de Stripe](https://dashboard.stripe.com/account/billing/automatic) en tu panel de control de Stripe. Sin embargo, si se captura una excepción `IncompletePayment`, aún debes informar al usuario que recibirá un correo electrónico con más instrucciones de confirmación de pago.
Se pueden lanzar excepciones de pago para los siguientes métodos: `charge`, `invoiceFor` e `invoice` en modelos que utilizan el trait `Billable`. Al interactuar con suscripciones, el método `create` en el `SubscriptionBuilder`, y los métodos `incrementAndInvoice` y `swapAndInvoice` en los modelos `Subscription` y `SubscriptionItem` pueden lanzar excepciones de pago incompletas.
Determinar si una suscripción existente tiene un pago incompleto se puede realizar utilizando el método `hasIncompletePayment` en el modelo facturable o en una instancia de suscripción:


```php
if ($user->hasIncompletePayment('default')) {
    // ...
}

if ($user->subscription('default')->hasIncompletePayment()) {
    // ...
}
```
Puedes derivar el estado específico de un pago incompleto inspeccionando la propiedad `payment` en la instancia de la excepción:


```php
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
```

<a name="confirming-payments"></a>
### Confirmando Pagos

Algunos métodos de pago requieren datos adicionales para confirmar los pagos. Por ejemplo, los métodos de pago SEPA requieren datos de "mandato" adicionales durante el proceso de pago. Puedes proporcionar estos datos a Cashier utilizando el método `withPaymentConfirmationOptions`:


```php
$subscription->withPaymentConfirmationOptions([
    'mandate_data' => '...',
])->swap('price_xxx');
```
Puedes consultar la [documentación de la API de Stripe](https://stripe.com/docs/api/payment_intents/confirm) para revisar todas las opciones aceptadas al confirmar pagos.

<a name="strong-customer-authentication"></a>
## Autenticación Fuerte de Clientes

Si tu negocio o uno de tus clientes está basado en Europa, necesitarás cumplir con las regulaciones de Autenticación Fuerte de Clientes (SCA) de la UE. Estas regulaciones fueron impuestas en septiembre de 2019 por la Unión Europea para prevenir el fraude en los pagos. Afortunadamente, Stripe y Cashier están preparados para construir aplicaciones que cumplan con SCA.
> [!WARNING]
Antes de comenzar, revisa [la guía de Stripe sobre PSD2 y SCA](https://stripe.com/guides/strong-customer-authentication) así como su [documentación sobre las nuevas API de SCA](https://stripe.com/docs/strong-customer-authentication).

<a name="payments-requiring-additional-confirmation"></a>
### Pagos que requieren confirmación adicional

Las regulaciones de SCA a menudo requieren verificación adicional para confirmar y procesar un pago. Cuando esto sucede, Cashier lanzará una excepción `Laravel\Cashier\Exceptions\IncompletePayment` que te informa que se necesita verificación adicional. Puedes encontrar más información sobre cómo manejar estas excepciones en la documentación sobre [manejo de pagos fallidos](#handling-failed-payments).
Las pantallas de confirmación de pago presentadas por Stripe o Cashier pueden adaptarse al flujo de pago de un banco o emisor de tarjetas específico y pueden incluir confirmación adicional de la tarjeta, un cargo pequeño temporal, autenticación en un dispositivo separado u otras formas de verificación.

<a name="incomplete-and-past-due-state"></a>
#### Estado Incompleto y Vencido

Cuando un pago necesita confirmación adicional, la suscripción permanecerá en un estado `incomplete` o `past_due` como lo indica su columna `stripe_status` en la base de datos. Cashier activará automáticamente la suscripción del cliente tan pronto como la confirmación del pago esté completa y tu aplicación sea notificada por Stripe a través del webhook de su finalización.
Para obtener más información sobre los estados `incomplete` y `past_due`, consulta [nuestra documentación adicional sobre estos estados](#incomplete-and-past-due-status).

<a name="off-session-payment-notifications"></a>
### Notificaciones de Pago Fuera de Sesión

Dado que las regulaciones de SCA requieren que los clientes verifiquen ocasionalmente sus detalles de pago incluso mientras su suscripción esté activa, Cashier puede enviar una notificación al cliente cuando se requiera la confirmación de pago fuera de sesión. Por ejemplo, esto puede ocurrir cuando se renueva una suscripción. La notificación de pago de Cashier se puede habilitar configurando la variable de entorno `CASHIER_PAYMENT_NOTIFICATION` a una clase de notificación. Por defecto, esta notificación está desactivada. Por supuesto, Cashier incluye una clase de notificación que puedes usar para este propósito, pero puedes proporcionar tu propia clase de notificación si lo deseas:


```ini
CASHIER_PAYMENT_NOTIFICATION=Laravel\Cashier\Notifications\ConfirmPayment

```
Para asegurarte de que se entreguen las notificaciones de confirmación de pago fuera de sesión, verifica que [los webhooks de Stripe estén configurados](#handling-stripe-webhooks) para tu aplicación y que el webhook `invoice.payment_action_required` esté habilitado en tu panel de control de Stripe. Además, tu modelo `Billable` también debería utilizar el trait `Illuminate\Notifications\Notifiable` de Laravel.
> [!WARNING]
Las notificaciones se enviarán incluso cuando los clientes estén realizando un pago manual que requiere una confirmación adicional. Desafortunadamente, no hay forma de que Stripe sepa que el pago se realizó de manera manual o "fuera de sesión". Pero, un cliente verá simplemente un mensaje de "Pago Exitoso" si visita la página de pago después de haber confirmado su pago. El cliente no podrá confirmar accidentalmente el mismo pago dos veces e incurrir en un segundo cargo accidental.

<a name="stripe-sdk"></a>
## SDK de Stripe

Muchos de los objetos de Cashier son envoltorios alrededor de los objetos del SDK de Stripe. Si deseas interactuar con los objetos de Stripe directamente, puedes recuperarlos de forma conveniente utilizando el método `asStripe`:


```php
$stripeSubscription = $subscription->asStripeSubscription();

$stripeSubscription->application_fee_percent = 5;

$stripeSubscription->save();
```
También puedes usar el método `updateStripeSubscription` para actualizar una suscripción de Stripe directamente:


```php
$subscription->updateStripeSubscription(['application_fee_percent' => 5]);
```
Puedes invocar el método `stripe` en la clase `Cashier` si deseas usar directamente el cliente `Stripe\StripeClient`. Por ejemplo, podrías usar este método para acceder a la instancia de `StripeClient` y recuperar una lista de precios de tu cuenta de Stripe:


```php
use Laravel\Cashier\Cashier;

$prices = Cashier::stripe()->prices->all();
```

<a name="testing"></a>
## Pruebas

Al probar una aplicación que utiliza Cashier, puedes simular las solicitudes HTTP reales a la API de Stripe; sin embargo, esto requiere que reimplements parcialmente el comportamiento de Cashier. Por lo tanto, recomendamos permitir que tus pruebas accedan a la API real de Stripe. Aunque esto es más lento, proporciona más confianza en que tu aplicación está funcionando como se espera y cualquier prueba lenta puede colocarse dentro de su propio grupo de pruebas Pest / PHPUnit.
Al realizar pruebas, recuerda que Cashier ya tiene una excelente suite de pruebas, así que deberías centrarte únicamente en probar el flujo de suscripción y pago de tu propia aplicación y no en cada comportamiento subyacente de Cashier.
Para comenzar, añade la versión **de prueba** de tu secreto de Stripe a tu archivo `phpunit.xml`:


```php
<env name="STRIPE_SECRET" value="sk_test_<your-key>"/>
```
Ahora, cada vez que interactúes con Cashier mientras realizas pruebas, enviará solicitudes API reales a tu entorno de prueba de Stripe. Para mayor comodidad, deberías rellenar previamente tu cuenta de prueba de Stripe con suscripciones / precios que puedas usar durante las pruebas.
> [!NOTA]
Para probar una variedad de escenarios de facturación, como denegaciones y fallos de tarjeta de crédito, puedes usar la amplia gama de [números de tarjeta y tokens de prueba](https://stripe.com/docs/testing) proporcionados por Stripe.