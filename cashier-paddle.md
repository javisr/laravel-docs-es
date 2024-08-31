# Laravel Cashier (Paddle)

- [Introducción](#introduction)
- [Actualizando Cashier](#upgrading-cashier)
- [Instalación](#installation)
  - [Paddle Sandbox](#paddle-sandbox)
- [Configuración](#configuration)
  - [Modelo Facturable](#billable-model)
  - [API Keys](#api-keys)
  - [Paddle JS](#paddle-js)
  - [Configuración de Moneda](#currency-configuration)
  - [Sobrescribir Modelos por Defecto](#overriding-default-models)
- [Inicio Rápido](#quickstart)
  - [Vender Productos](#quickstart-selling-products)
  - [Vender Suscripciones](#quickstart-selling-subscriptions)
- [Sesiones de Pago](#checkout-sessions)
  - [Pago Overlay](#overlay-checkout)
  - [Pago Inline](#inline-checkout)
  - [Pagos de Invitados](#guest-checkouts)
- [Vistas Previas de Precios](#price-previews)
  - [Vistas Previas de Precios para Clientes](#customer-price-previews)
  - [Descuentos](#price-discounts)
- [Clientes](#customers)
  - [Configuraciones Predeterminadas del Cliente](#customer-defaults)
  - [Recuperar Clientes](#retrieving-customers)
  - [Crear Clientes](#creating-customers)
- [Suscripciones](#subscriptions)
  - [Crear Suscripciones](#creating-subscriptions)
  - [Verificar Estado de Suscripción](#checking-subscription-status)
  - [Cargos Únicos de Suscripción](#subscription-single-charges)
  - [Actualizar Información de Pago](#updating-payment-information)
  - [Cambiar Planes](#changing-plans)
  - [Cantidad de Suscripciones](#subscription-quantity)
  - [Suscripciones con Múltiples Productos](#subscriptions-with-multiple-products)
  - [Múltiples Suscripciones](#multiple-subscriptions)
  - [Pausar Suscripciones](#pausing-subscriptions)
  - [Cancelar Suscripciones](#canceling-subscriptions)
- [Pruebas de Suscripción](#subscription-trials)
  - [Con Método de Pago Adelante](#with-payment-method-up-front)
  - [Sin Método de Pago Adelante](#without-payment-method-up-front)
  - [Extender o Activar una Prueba](#extend-or-activate-a-trial)
- [Manejo de Webhooks de Paddle](#handling-paddle-webhooks)
  - [Definir Manejadores de Eventos de Webhook](#defining-webhook-event-handlers)
  - [Verificar Firmas de Webhook](#verifying-webhook-signatures)
- [Cargos Únicos](#single-charges)
  - [Cargar Productos](#charging-for-products)
  - [Reembolsar Transacciones](#refunding-transactions)
  - [Acreditar Transacciones](#crediting-transactions)
- [Transacciones](#transactions)
  - [Pagos Pasados y Próximos](#past-and-upcoming-payments)
- [Pruebas](#testing)

<a name="introduction"></a>
## Introducción

> [!WARNING]
Esta documentación es para la integración de Cashier Paddle 2.x con Paddle Billing. Si aún estás utilizando Paddle Classic, deberías usar [Cashier Paddle 1.x](https://github.com/laravel/cashier-paddle/tree/1.x).
[Laravel Cashier Paddle](https://github.com/laravel/cashier-paddle) proporciona una interfaz fluida y expresiva a los servicios de facturación por suscripción de [Paddle](https://paddle.com). Maneja casi todo el código de facturación por suscripción que temes. Además de la gestión básica de suscripciones, Cashier puede manejar: intercambio de suscripciones, "cantidades" de suscripción, pauso de suscripciones, períodos de gracia de cancelación y más.
Antes de profundizar en Cashier Paddle, te recomendamos que también revises las [guías conceptuales](https://developer.paddle.com/concepts/overview) y la [documentación de la API](https://developer.paddle.com/api-reference/overview) de Paddle.

<a name="upgrading-cashier"></a>
## Actualizando Cashier

Al actualizar a una nueva versión de Cashier, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/cashier-paddle/blob/master/UPGRADE.md).

<a name="installation"></a>
## Instalación

Primero, instala el paquete Cashier para Paddle utilizando el gestor de paquetes Composer:


```shell
composer require laravel/cashier-paddle

```
A continuación, deberías publicar los archivos de migración de Cashier utilizando el comando Artisan `vendor:publish`:


```shell
php artisan vendor:publish --tag="cashier-migrations"

```
Entonces, deberías ejecutar las migraciones de la base de datos de tu aplicación. Las migraciones de Cashier crearán una nueva tabla `customers`. Además, se crearán nuevas tablas `subscriptions` y `subscription_items` para almacenar todas las suscripciones de tus clientes. Por último, se creará una nueva tabla `transactions` para almacenar todas las transacciones de Paddle asociadas con tus clientes:


```shell
php artisan migrate

```
> [!WARNING]
Para asegurarte de que Cashier maneje correctamente todos los eventos de Paddle, recuerda [configurar el manejo de webhooks de Cashier](#handling-paddle-webhooks).

<a name="paddle-sandbox"></a>
### Paddle Sandbox

Durante el desarrollo local y de staging, deberías [registrar una cuenta de Paddle Sandbox](https://sandbox-login.paddle.com/signup). Esta cuenta te proporcionará un entorno sandbox para probar y desarrollar tus aplicaciones sin realizar pagos reales. Puedes usar los [números de tarjeta de prueba de Paddle](https://developer.paddle.com/concepts/payment-methods/credit-debit-card) para simular varios escenarios de pago.
Al utilizar el entorno de Sandbox de Paddle, debes establecer la variable de entorno `PADDLE_SANDBOX` en `true` dentro del archivo `.env` de tu aplicación:


```ini
PADDLE_SANDBOX=true

```
Después de haber terminado de desarrollar tu aplicación, puedes [solicitar una cuenta de vendedor de Paddle](https://paddle.com). Antes de que tu aplicación sea puesta en producción, Paddle necesitará aprobar el dominio de tu aplicación.

<a name="configuration"></a>
## Configuración


<a name="billable-model"></a>
### Modelo Facturable

Antes de usar Cashier, debes añadir el trait `Billable` a la definición de tu modelo de usuario. Este trait proporciona varios métodos que te permiten realizar tareas de facturación comunes, como crear suscripciones y actualizar información del método de pago:


```php
use Laravel\Paddle\Billable;

class User extends Authenticatable
{
    use Billable;
}
```
Si tienes entidades facturables que no son usuarios, también puedes añadir el trait a esas clases:


```php
use Illuminate\Database\Eloquent\Model;
use Laravel\Paddle\Billable;

class Team extends Model
{
    use Billable;
}
```

<a name="api-keys"></a>
### Claves API

A continuación, debes configurar tus claves de Paddle en el archivo `.env` de tu aplicación. Puedes recuperar tus claves API de Paddle desde el panel de control de Paddle:


```ini
PADDLE_CLIENT_SIDE_TOKEN=your-paddle-client-side-token
PADDLE_API_KEY=your-paddle-api-key
PADDLE_RETAIN_KEY=your-paddle-retain-key
PADDLE_WEBHOOK_SECRET="your-paddle-webhook-secret"
PADDLE_SANDBOX=true

```
La variable de entorno `PADDLE_SANDBOX` debe configurarse en `true` cuando estés utilizando el [entorno Sandbox de Paddle](#paddle-sandbox). La variable `PADDLE_SANDBOX` debe configurarse en `false` si estás desplegando tu aplicación en producción y estás utilizando el entorno de vendedor en vivo de Paddle.
La `PADDLE_RETAIN_KEY` es opcional y solo debe configurarse si estás utilizando Paddle con [Retain](https://developer.paddle.com/paddlejs/retain).

<a name="paddle-js"></a>
### Paddle JS

Paddle depende de su propia biblioteca JavaScript para iniciar el widget de checkout de Paddle. Puedes cargar la biblioteca JavaScript colocando la directiva `@paddleJS` justo antes de la etiqueta de cierre `</head>` de tu layout de aplicación:


```blade
<head>
    ...

    @paddleJS
</head>

```

<a name="currency-configuration"></a>
### Configuración de Moneda

Puedes especificar un locale que se utilizará al formatear valores monetarios para su visualización en facturas. Internamente, Cashier utiliza la [clase `NumberFormatter` de PHP](https://www.php.net/manual/en/class.numberformatter.php) para establecer la configuración regional de la moneda:


```ini
CASHIER_CURRENCY_LOCALE=nl_BE

```
> [!WARNING]
Para utilizar locales diferentes a `en`, asegúrate de que la extensión PHP `ext-intl` esté instalada y configurada en tu servidor.

<a name="overriding-default-models"></a>
### Sobrescribiendo Modelos Predeterminados

Puedes extender los modelos utilizados internamente por Cashier definiendo tu propio modelo y extendiendo el modelo correspondiente de Cashier:


```php
use Laravel\Paddle\Subscription as CashierSubscription;

class Subscription extends CashierSubscription
{
    // ...
}
```
Después de definir tu modelo, puedes instruir a Cashier para que utilice tu modelo personalizado a través de la clase `Laravel\Paddle\Cashier`. Típicamente, debes informar a Cashier sobre tus modelos personalizados en el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:


```php
use App\Models\Cashier\Subscription;
use App\Models\Cashier\Transaction;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Cashier::useSubscriptionModel(Subscription::class);
    Cashier::useTransactionModel(Transaction::class);
}
```

<a name="quickstart"></a>
## Inicio Rápido


<a name="quickstart-selling-products"></a>
### Vendiendo Productos

Para cobrar a los clientes por productos de un solo cargo y no recurrentes, utilizaremos Cashier para cobrar a los clientes con el Overlay de Pago de Paddle, donde proporcionarán sus detalles de pago y confirmarán su compra. Una vez que se haya realizado el pago a través del Overlay de Pago, el cliente será redirigido a una URL de éxito de su elección dentro de su aplicación:


```php
use Illuminate\Http\Request;

Route::get('/buy', function (Request $request) {
    $checkout = $request->user()->checkout('pri_deluxe_album')
        ->returnTo(route('dashboard'));

    return view('buy', ['checkout' => $checkout]);
})->name('checkout');
```
Como puedes ver en el ejemplo anterior, utilizaremos el método `checkout` proporcionado por Cashier para crear un objeto de pago que presente al cliente el Overlay de Checkout de Paddle para un "identificador de precio" dado. Al usar Paddle, los "precios" se refieren a [precios definidos para productos específicos](https://developer.paddle.com/build/products/create-products-prices).
Si es necesario, el método `checkout` creará automáticamente un cliente en Paddle y conectará ese registro de cliente de Paddle al usuario correspondiente en la base de datos de tu aplicación. Después de completar la sesión de pago, el cliente será redirigido a una página de éxito dedicada donde puedes mostrar un mensaje informativo al cliente.
En la vista `buy`, incluiremos un botón para mostrar la Superposición de Checkout. El componente Blade `paddle-button` se incluye con Cashier Paddle; sin embargo, también puedes [renderizar manualmente un checkout en overlay](#manually-rendering-an-overlay-checkout):


```html
<x-paddle-button :checkout="$checkout" class="px-8 py-4">
    Buy Product
</x-paddle-button>

```

<a name="providing-meta-data-to-paddle-checkout"></a>
#### Proporcionando Metadatos a Paddle Checkout

Al vender productos, es común realizar un seguimiento de los pedidos completados y los productos comprados a través de modelos `Cart` y `Order` definidos por tu propia aplicación. Al redirigir a los clientes a la Superficie de Pago de Paddle para completar una compra, es posible que necesites proporcionar un identificador de pedido existente para que puedas asociar la compra completada con el pedido correspondiente cuando el cliente sea redirigido de vuelta a tu aplicación.
Para lograr esto, puedes proporcionar un array de datos personalizados al método `checkout`. Imaginemos que se crea una `Order` pendiente dentro de nuestra aplicación cuando un usuario comienza el proceso de pago. Recuerda, los modelos `Cart` y `Order` en este ejemplo son ilustrativos y no son proporcionados por Cashier. Eres libre de implementar estos conceptos según las necesidades de tu propia aplicación:


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

    $checkout = $request->user()->checkout($order->price_ids)
        ->customData(['order_id' => $order->id]);

    return view('billing', ['checkout' => $checkout]);
})->name('checkout');
```
Como puedes ver en el ejemplo anterior, cuando un usuario comienza el proceso de pago, proporcionaremos todos los identificadores de precio de Paddle asociados al carrito / pedido a el método `checkout`. Por supuesto, tu aplicación es responsable de asociar estos elementos con el "carrito de compras" o pedido a medida que el cliente los añade. También proporcionamos la ID del pedido al Overlay de Paddle Checkout a través del método `customData`.
Por supuesto, es probable que desees marcar el pedido como "completo" una vez que el cliente haya terminado el proceso de pago. Para lograr esto, puedes escuchar los webhooks despachados por Paddle y levantados a través de eventos por Cashier para almacenar la información del pedido en tu base de datos.
Para comenzar, escucha el evento `TransactionCompleted` despachado por Cashier. Típicamente, debes registrar el escuchador de eventos en el método `boot` del `AppServiceProvider` de tu aplicación:


```php
use App\Listeners\CompleteOrder;
use Illuminate\Support\Facades\Event;
use Laravel\Paddle\Events\TransactionCompleted;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Event::listen(TransactionCompleted::class, CompleteOrder::class);
}
```
En este ejemplo, el listener `CompleteOrder` podría verse de la siguiente manera:


```php
namespace App\Listeners;

use App\Models\Order;
use Laravel\Paddle\Cashier;
use Laravel\Paddle\Events\TransactionCompleted;

class CompleteOrder
{
    /**
     * Handle the incoming Cashier webhook event.
     */
    public function handle(TransactionCompleted $event): void
    {
        $orderId = $event->payload['data']['custom_data']['order_id'] ?? null;

        $order = Order::findOrFail($orderId);

        $order->update(['status' => 'completed']);
    }
}
```
Por favor, consulta la documentación de Paddle para obtener más información sobre los [datos contenidos en el evento `transaction.completed`](https://developer.paddle.com/webhooks/transactions/transaction-completed).

<a name="quickstart-selling-subscriptions"></a>
### Vendiendo Suscripciones

> [!NOTA]
Antes de utilizar Paddle Checkout, debes definir Productos con precios fijos en tu panel de control de Paddle. Además, debes [configurar el manejo de webhooks de Paddle](#handling-paddle-webhooks).
Ofrecer facturación de productos y suscripciones a través de tu aplicación puede ser intimidante. Sin embargo, gracias a Cashier y [el Checkout Overlay de Paddle](https://www.paddle.com/billing/checkout), puedes construir fácilmente integraciones de pago modernas y robustas.
Para aprender cómo vender suscripciones utilizando Cashier y el Checkout Overlay de Paddle, consideremos el escenario simple de un servicio de suscripción con un plan mensual básico (`price_basic_monthly`) y un plan anual (`price_basic_yearly`). Estos dos precios podrían agruparse bajo un producto "Básico" (`pro_basic`) en nuestro panel de control de Paddle. Además, nuestro servicio de suscripción podría ofrecer un plan Experto como `pro_expert`.
Primero, descubramos cómo un cliente puede suscribirse a nuestros servicios. Por supuesto, puedes imaginar que el cliente podría hacer clic en un botón de "suscribirse" para el plan Básico en la página de precios de nuestra aplicación. Este botón invocará un Paddle Checkout Overlay para su plan elegido. Para comenzar, iniciemos una sesión de pago a través del método `checkout`:


```php
use Illuminate\Http\Request;

Route::get('/subscribe', function (Request $request) {
    $checkout = $request->user()->checkout('price_basic_monthly')
        ->returnTo(route('dashboard'));

    return view('subscribe', ['checkout' => $checkout]);
})->name('subscribe');
```
En la vista `subscribe`, incluiremos un botón para mostrar la Superposición de Checkout. El componente Blade `paddle-button` se incluye con Cashier Paddle; sin embargo, también puedes [renderizar un checkout de superposición de forma manual](#manually-rendering-an-overlay-checkout):
Ahora, cuando se haga clic en el botón Suscribirse, el cliente podrá ingresar sus datos de pago e iniciar su suscripción. Para saber cuándo ha comenzado realmente su suscripción (ya que algunos métodos de pago requieren unos segundos para procesarse), también debes [configurar el manejo de webhook de Cashier](#handling-paddle-webhooks).
Ahora que los clientes pueden iniciar sus suscripciones, necesitamos restringir ciertas partes de nuestra aplicación para que solo los usuarios suscritos puedan acceder a ellas. Por supuesto, siempre podemos determinar el estado de suscripción actual de un usuario a través del método `subscribed` proporcionado por el trait `Billable` de Cashier:


```blade
@if ($user->subscribed())
    <p>You are subscribed.</p>
@endif

```
Incluso podemos determinar fácilmente si un usuario está suscrito a un producto o precio específico:


```blade
@if ($user->subscribedToProduct('pro_basic'))
    <p>You are subscribed to our Basic product.</p>
@endif

@if ($user->subscribedToPrice('price_basic_monthly'))
    <p>You are subscribed to our monthly Basic plan.</p>
@endif

```

<a name="quickstart-building-a-subscribed-middleware"></a>
#### Construyendo un Middleware Suscrito

Por conveniencia, es posible que desees crear un [middleware](/docs/%7B%7Bversion%7D%7D/middleware) que determine si la solicitud entrante proviene de un usuario suscrito. Una vez que se haya definido este middleware, puedes asignarlo fácilmente a una ruta para evitar que los usuarios que no están suscritos accedan a la ruta:


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
            return redirect('/subscribe');
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
#### Permitiendo a los Clientes Gestionar Su Plan de Facturación

Por supuesto, los clientes pueden querer cambiar su plan de suscripción a otro producto o "nivel". En nuestro ejemplo de arriba, queremos permitir que el cliente cambie su plan de una suscripción mensual a una suscripción anual. Para esto, necesitarás implementar algo como un botón que conduzca a la ruta de abajo:


```php
use Illuminate\Http\Request;

Route::put('/subscription/{price}/swap', function (Request $request, $price) {
    $user->subscription()->swap($price); // With "$price" being "price_basic_yearly" for this example.

    return redirect()->route('dashboard');
})->name('subscription.swap');
```
Además de cambiar de planes, también necesitarás permitir que tus clientes cancelen su suscripción. Al igual que al cambiar de planes, proporciona un botón que conduzca a la siguiente ruta:


```php
use Illuminate\Http\Request;

Route::put('/subscription/cancel', function (Request $request, $price) {
    $user->subscription()->cancel();

    return redirect()->route('dashboard');
})->name('subscription.cancel');
```
Y ahora tu suscripción se cancelará al final de su período de facturación.
> [!NOTA]
Mientras hayas configurado el manejo de webhooks de Cashier, Cashier mantendrá automáticamente las tablas de base de datos relacionadas con Cashier de tu aplicación en sincronía, inspeccionando los webhooks entrantes de Paddle. Así que, por ejemplo, cuando canceles la suscripción de un cliente a través del panel de control de Paddle, Cashier recibirá el webhook correspondiente y marcará la suscripción como "cancelada" en la base de datos de tu aplicación.

<a name="checkout-sessions"></a>
## Sesiones de Pago

La mayoría de las operaciones para facturar a los clientes se realizan utilizando "checkouts" a través del [widget de Overlay de Checkout](https://developer.paddle.com/build/checkout/build-overlay-checkout) de Paddle o utilizando [checkout en línea](https://developer.paddle.com/build/checkout/build-branded-inline-checkout).
Antes de procesar pagos de checkout utilizando Paddle, debes definir el [enlace de pago predeterminado](https://developer.paddle.com/build/transactions/default-payment-link#set-default-link) de tu aplicación en el panel de configuración de checkout de Paddle.

<a name="overlay-checkout"></a>
### Checkout de superposición

Antes de mostrar el widget de Checkout Overlay, debes generar una sesión de pago utilizando Cashier. Una sesión de pago informará al widget de pago sobre la operación de facturación que se debe realizar:
Cashier incluye un componente `paddle-button` [de Blade](/docs/%7B%7Bversion%7D%7D/blade#components). Puedes pasar la sesión de pago a este componente como una "prop". Luego, cuando se haga clic en este botón, se mostrará el widget de pago de Paddle:


```html
<x-paddle-button :checkout="$checkout" class="px-8 py-4">
    Subscribe
</x-paddle-button>

```
Por defecto, esto mostrará el widget utilizando el estilo predeterminado de Paddle. Puedes personalizar el widget añadiendo [atributos soportados por Paddle](https://developer.paddle.com/paddlejs/html-data-attributes) como el atributo `data-theme='light'` al componente:


```html
<x-paddle-button :url="$payLink" class="px-8 py-4" data-theme="light">
    Subscribe
</x-paddle-button>

```
El widget de checkout de Paddle es asincrónico. Una vez que el usuario crea una suscripción dentro del widget, Paddle enviará a tu aplicación un webhook para que puedas actualizar correctamente el estado de la suscripción en la base de datos de tu aplicación. Por lo tanto, es importante que configures adecuadamente [webhooks](#handling-paddle-webhooks) para acomodar los cambios de estado de Paddle.
> [!WARNING]
Después de un cambio en el estado de una suscripción, el retraso para recibir el webhook correspondiente es típicamente mínimo, pero debes tener esto en cuenta en tu aplicación considerando que la suscripción de tu usuario podría no estar disponible de inmediato después de completar la compra.

<a name="manually-rendering-an-overlay-checkout"></a>
#### Renderizando Manualmente un Checkout de Overlay

También puedes renderizar manualmente un checkout en overlay sin usar los componentes Blade integrados de Laravel. Para comenzar, genera la sesión de checkout [como se demostró en ejemplos anteriores](#overlay-checkout):
A continuación, puedes usar Paddle.js para inicializar el checkout. En este ejemplo, crearemos un enlace que tenga la clase `paddle_button`. Paddle.js detectará esta clase y mostrará el checkout en overlay cuando se haga clic en el enlace:


```blade
<?php
$items = $checkout->getItems();
$customer = $checkout->getCustomer();
$custom = $checkout->getCustomData();
?>

<a
    href='#!'
    class='paddle_button'
    data-items='{!! json_encode($items) !!}'
    @if ($customer) data-customer-id='{{ $customer->paddle_id }}' @endif
    @if ($custom) data-custom-data='{{ json_encode($custom) }}' @endif
    @if ($returnUrl = $checkout->getReturnUrl()) data-success-url='{{ $returnUrl }}' @endif
>
    Buy Product
</a>

```

<a name="inline-checkout"></a>
### Pago Inline

Si no deseas utilizar el widget de checkout con estilo "overlay" de Paddle, Paddle también ofrece la opción de mostrar el widget de forma inline. Aunque este enfoque no te permite ajustar ninguno de los campos HTML del checkout, te permite incrustar el widget dentro de tu aplicación.
Para facilitarte el inicio con el checkout en línea, Cashier incluye un componente Blade `paddle-checkout`. Para comenzar, debes [generar una sesión de checkout](#overlay-checkout):
Entonces, puedes pasar la sesión de pago al atributo `checkout` del componente:


```blade
<x-paddle-checkout :checkout="$checkout" class="w-full" />

```
Para ajustar la altura del componente de pago en línea, puedes pasar el atributo `height` al componente Blade:


```blade
<x-paddle-checkout :checkout="$checkout" class="w-full" height="500" />

```
Por favor, consulta la [guía de Paddle sobre Inline Checkout](https://developer.paddle.com/build/checkout/build-branded-inline-checkout) y las [opciones de configuración de checkout disponibles](https://developer.paddle.com/build/checkout/set-up-checkout-default-settings) para obtener más detalles sobre las opciones de personalización del checkout en línea.

<a name="manually-rendering-an-inline-checkout"></a>
#### Renderizando un Checkout en Línea de Manera Manual

También puedes renderizar manualmente un pago en línea sin usar los componentes Blade incorporados de Laravel. Para comenzar, genera la sesión de pago [como se demostró en ejemplos anteriores](#inline-checkout):


```php
use Illuminate\Http\Request;

Route::get('/buy', function (Request $request) {
    $checkout = $user->checkout('pri_34567')
        ->returnTo(route('dashboard'));

    return view('billing', ['checkout' => $checkout]);
});
```
A continuación, puedes usar Paddle.js para inicializar el proceso de pago. En este ejemplo, demostraremos esto usando [Alpine.js](https://github.com/alpinejs/alpine); sin embargo, puedes modificar este ejemplo para tu propia pila de frontend:


```blade
<?php
$options = $checkout->options();

$options['settings']['frameTarget'] = 'paddle-checkout';
$options['settings']['frameInitialHeight'] = 366;
?>

<div class="paddle-checkout" x-data="{}" x-init="
    Paddle.Checkout.open(@json($options));
">
</div>

```

<a name="guest-checkouts"></a>
### Compras como Invitado

A veces, es posible que necesites crear una sesión de pago para usuarios que no necesitan una cuenta con tu aplicación. Para hacerlo, puedes usar el método `guest`:


```php
use Illuminate\Http\Request;
use Laravel\Paddle\Checkout;

Route::get('/buy', function (Request $request) {
    $checkout = Checkout::guest('pri_34567')
        ->returnTo(route('home'));

    return view('billing', ['checkout' => $checkout]);
});
```
Entonces, puedes proporcionar la sesión de pago al botón [Paddle](#overlay-checkout) o a los componentes Blade de [pago en línea](#inline-checkout).

<a name="price-previews"></a>
## Previews de Precios

Paddle te permite personalizar precios por moneda, lo que esencialmente te permite configurar diferentes precios para diferentes países. Cashier Paddle te permite recuperar todos estos precios utilizando el método `previewPrices`. Este método acepta los ID de precios para los cuales deseas recuperar precios:


```php
use Laravel\Paddle\Cashier;

$prices = Cashier::previewPrices(['pri_123', 'pri_456']);
```
La moneda se determinará en función de la dirección IP de la solicitud; sin embargo, puedes proporcionar opcionalmente un país específico para recuperar precios:


```php
use Laravel\Paddle\Cashier;

$prices = Cashier::previewPrices(['pri_123', 'pri_456'], ['address' => [
    'country_code' => 'BE',
    'postal_code' => '1234',
]]);
```
Después de recuperar los precios, puedes mostrarlos como desees:
También puedes mostrar el precio subtotal y el monto del impuesto por separado:


```blade
<ul>
    @foreach ($prices as $price)
        <li>{{ $price->product['name'] }} - {{ $price->subtotal() }} (+ {{ $price->tax() }} tax)</li>
    @endforeach
</ul>

```
Para obtener más información, [consulta la documentación de la API de Paddle sobre las vistas previas de precios](https://developer.paddle.com/api-reference/pricing-preview/preview-prices).

<a name="customer-price-previews"></a>
### Previews de Precios para Clientes

Si un usuario ya es cliente y deseas mostrar los precios que se aplican a ese cliente, puedes hacerlo recuperando los precios directamente de la instancia del cliente:


```php
use App\Models\User;

$prices = User::find(1)->previewPrices(['pri_123', 'pri_456']);
```
Internamente, Cashier utilizará el ID del cliente del usuario para recuperar los precios en su moneda. Así que, por ejemplo, un usuario que vive en Estados Unidos verá precios en dólares estadounidenses, mientras que un usuario en Bélgica verá precios en euros. Si no se puede encontrar una moneda coincidente, se utilizará la moneda predeterminada del producto. Puedes personalizar todos los precios de un producto o plan de suscripción en el panel de control de Paddle.

<a name="price-discounts"></a>
### Descuentos

También puedes optar por mostrar precios después de un descuento. Al llamar al método `previewPrices`, proporcionas el ID de descuento a través de la opción `discount_id`:


```php
use Laravel\Paddle\Cashier;

$prices = Cashier::previewPrices(['pri_123', 'pri_456'], [
    'discount_id' => 'dsc_123'
]);
```
Entonces, muestra los precios calculados:


```blade
<ul>
    @foreach ($prices as $price)
        <li>{{ $price->product['name'] }} - {{ $price->total() }}</li>
    @endforeach
</ul>

```

<a name="customers"></a>
## Clientes


<a name="customer-defaults"></a>
### Defectos del Cliente

Cashier te permite definir algunos valores predeterminados útiles para tus clientes al crear sesiones de pago. Establecer estos valores predeterminados te permite rellenar automáticamente la dirección de correo electrónico y el nombre de un cliente para que puedan avanzar de inmediato a la porción de pago del widget de pago. Puedes establecer estos valores predeterminados sobrescribiendo los siguientes métodos en tu modelo facturable:


```php
/**
 * Get the customer's name to associate with Paddle.
 */
public function paddleName(): string|null
{
    return $this->name;
}

/**
 * Get the customer's email address to associate with Paddle.
 */
public function paddleEmail(): string|null
{
    return $this->email;
}
```
Estos valores predeterminados se utilizarán para cada acción en Cashier que genere una [sesión de pago](#checkout-sessions).

<a name="retrieving-customers"></a>
### Recuperando Clientes

Puedes recuperar un cliente por su ID de cliente de Paddle utilizando el método `Cashier::findBillable`. Este método devolverá una instancia del modelo facturable:


```php
use Laravel\Paddle\Cashier;

$user = Cashier::findBillable($customerId);
```

<a name="creating-customers"></a>
### Creando Clientes

Ocasionalmente, es posible que desees crear un cliente de Paddle sin iniciar una suscripción. Puedes lograr esto utilizando el método `createAsCustomer`:


```php
$customer = $user->createAsCustomer();
```
Se devuelve una instancia de `Laravel\Paddle\Customer`. Una vez que el cliente ha sido creado en Paddle, puedes comenzar una suscripción en una fecha posterior. Puedes proporcionar un array opcional `$options` para pasar cualquier parámetro adicional de [creación de clientes que son compatibles con la API de Paddle](https://developer.paddle.com/api-reference/customers/create-customer):


```php
$customer = $user->createAsCustomer($options);
```

<a name="subscriptions"></a>
## Suscripciones


<a name="creating-subscriptions"></a>
### Creando Suscripciones

Para crear una suscripción, primero recupera una instancia de tu modelo facturable de tu base de datos, que típicamente será una instancia de `App\Models\User`. Una vez que hayas recuperado la instancia del modelo, puedes usar el método `subscribe` para crear la sesión de pago del modelo:


```php
use Illuminate\Http\Request;

Route::get('/user/subscribe', function (Request $request) {
    $checkout = $request->user()->subscribe($premium = 12345, 'default')
        ->returnTo(route('home'));

    return view('billing', ['checkout' => $checkout]);
});
```
El primer argumento dado al método `subscribe` es el precio específico al que el usuario se está suscribiendo. Este valor debe corresponder al identificador del precio en Paddle. El método `returnTo` acepta una URL a la que se redirigirá a tu usuario después de que complete con éxito el proceso de pago. El segundo argumento pasado al método `subscribe` debe ser el "tipo" interno de la suscripción. Si tu aplicación solo ofrece una sola suscripción, podrías llamarlo `default` o `primary`. Este tipo de suscripción es solo para uso interno de la aplicación y no está destinado a ser mostrado a los usuarios. Además, no debe contener espacios y nunca debe cambiarse después de crear la suscripción.
También puedes proporcionar un array de metadatos personalizados sobre la suscripción utilizando el método `customData`:


```php
$checkout = $request->user()->subscribe($premium = 12345, 'default')
    ->customData(['key' => 'value'])
    ->returnTo(route('home'));
```
Una vez que se ha creado una sesión de pago de suscripción, la sesión de pago puede ser proporcionada al componente `paddle-button` [Blade](#overlay-checkout) que se incluye con Cashier Paddle:


```blade
<x-paddle-button :checkout="$checkout" class="px-8 py-4">
    Subscribe
</x-paddle-button>

```
Después de que el usuario haya completado su compra, se enviará un webhook `subscription_created` desde Paddle. Cashier recibirá este webhook y configurará la suscripción para tu cliente. Para asegurarte de que todos los webhooks se reciban y manejen correctamente en tu aplicación, asegúrate de haber [configurado correctamente el manejo de webhooks](#handling-paddle-webhooks).

<a name="checking-subscription-status"></a>
### Comprobando el Estado de la Suscripción

Una vez que un usuario está suscrito a tu aplicación, puedes comprobar su estado de suscripción utilizando una variedad de métodos convenientes. Primero, el método `subscribed` devuelve `true` si el usuario tiene una suscripción válida, incluso si la suscripción está actualmente dentro de su período de prueba:


```php
if ($user->subscribed()) {
    // ...
}
```
Si tu aplicación ofrece múltiples suscripciones, puedes especificar la suscripción al invocar el método `subscribed`:


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
        if ($request->user() && ! $request->user()->subscribed()) {
            // This user is not a paying customer...
            return redirect('/billing');
        }

        return $next($request);
    }
}
```
Si deseas determinar si un usuario todavía está dentro de su período de prueba, puedes usar el método `onTrial`. Este método puede ser útil para determinar si debes mostrar una advertencia al usuario de que todavía está en su período de prueba:


```php
if ($user->subscription()->onTrial()) {
    // ...
}
```
El método `subscribedToPrice` se puede usar para determinar si el usuario está suscrito a un plan dado basado en un ID de precio de Paddle dado. En este ejemplo, determinaremos si la suscripción `default` del usuario está activamente suscrita al precio mensual:


```php
if ($user->subscribedToPrice($monthly = 'pri_123', 'default')) {
    // ...
}
```
El método `recurring` se puede utilizar para determinar si el usuario está actualmente en una suscripción activa y ya no se encuentra dentro de su período de prueba o en un período de gracia:


```php
if ($user->subscription()->recurring()) {
    // ...
}
```

<a name="canceled-subscription-status"></a>
#### Estado de suscripción cancelada

Para determinar si el usuario fue una vez un suscriptor activo pero ha cancelado su suscripción, puedes usar el método `canceled`:


```php
if ($user->subscription()->canceled()) {
    // ...
}
```
También puedes determinar si un usuario ha cancelado su suscripción, pero aún está en su "período de gracia" hasta que la suscripción expire por completo. Por ejemplo, si un usuario cancela una suscripción el 5 de marzo que estaba programada para expirar el 10 de marzo, el usuario está en su "período de gracia" hasta el 10 de marzo. Además, el método `subscribed` seguirá devolviendo `true` durante este tiempo:

<a name="past-due-status"></a>
#### Estado de Vencimiento

Si un pago falla para una suscripción, se marcará como `past_due`. Cuando tu suscripción esté en este estado, no estará activa hasta que el cliente haya actualizado su información de pago. Puedes determinar si una suscripción está en mora utilizando el método `pastDue` en la instancia de la suscripción:


```php
if ($user->subscription()->pastDue()) {
    // ...
}
```
Cuando una suscripción está vencida, debes instruir al usuario a [actualizar su información de pago](#updating-payment-information).
Si deseas que las suscripciones sigan siendo consideradas válidas cuando están `past_due`, puedes usar el método `keepPastDueSubscriptionsActive` proporcionado por Cashier. Típicamente, este método debe llamarse en el método `register` de tu `AppServiceProvider`:


```php
use Laravel\Paddle\Cashier;

/**
 * Register any application services.
 */
public function register(): void
{
    Cashier::keepPastDueSubscriptionsActive();
}
```
> [!WARNING]
Cuando una suscripción está en un estado `past_due`, no puede ser cambiada hasta que se haya actualizado la información de pago. Por lo tanto, los métodos `swap` y `updateQuantity` lanzarán una excepción cuando la suscripción esté en un estado `past_due`.

<a name="subscription-scopes"></a>
#### Alcances de Suscripción

La mayoría de los estados de suscripción también están disponibles como scopes de consulta para que puedas consultar fácilmente tu base de datos por suscripciones que se encuentran en un estado dado:


```php
// Get all valid subscriptions...
$subscriptions = Subscription::query()->valid()->get();

// Get all of the canceled subscriptions for a user...
$subscriptions = $user->subscriptions()->canceled()->get();
```
A continuación se muestra una lista completa de los ámbitos disponibles:


```php
Subscription::query()->valid();
Subscription::query()->onTrial();
Subscription::query()->expiredTrial();
Subscription::query()->notOnTrial();
Subscription::query()->active();
Subscription::query()->recurring();
Subscription::query()->pastDue();
Subscription::query()->paused();
Subscription::query()->notPaused();
Subscription::query()->onPausedGracePeriod();
Subscription::query()->notOnPausedGracePeriod();
Subscription::query()->canceled();
Subscription::query()->notCanceled();
Subscription::query()->onGracePeriod();
Subscription::query()->notOnGracePeriod();
```

<a name="subscription-single-charges"></a>
### Cargos Únicos de Suscripción

Los cargos únicos de suscripción te permiten cobrar a los suscriptores con un cargo único además de sus suscripciones. Debes proporcionar uno o múltiples ID de precio al invocar el método `charge`:


```php
// Charge a single price...
$response = $user->subscription()->charge('pri_123');

// Charge multiple prices at once...
$response = $user->subscription()->charge(['pri_123', 'pri_456']);
```
El método `charge` no cobrará realmente al cliente hasta el próximo intervalo de facturación de su suscripción. Si deseas facturar al cliente de inmediato, puedes usar el método `chargeAndInvoice` en su lugar:


```php
$response = $user->subscription()->chargeAndInvoice('pri_123');
```

<a name="updating-payment-information"></a>
### Actualizando Información de Pago

Paddle siempre guarda un método de pago por suscripción. Si deseas actualizar el método de pago predeterminado para una suscripción, debes redirigir a tu cliente a la página de actualización del método de pago alojada por Paddle utilizando el método `redirectToUpdatePaymentMethod` en el modelo de suscripción:


```php
use Illuminate\Http\Request;

Route::get('/update-payment-method', function (Request $request) {
    $user = $request->user();

    return $user->subscription()->redirectToUpdatePaymentMethod();
});
```
Cuando un usuario ha terminado de actualizar su información, se enviará un webhook `subscription_updated` por Paddle y los detalles de la suscripción se actualizarán en la base de datos de tu aplicación.

<a name="changing-plans"></a>
### Cambiando Planes

Después de que un usuario se haya suscrito a tu aplicación, puede que ocasionalmente quiera cambiar a un nuevo plan de suscripción. Para actualizar el plan de suscripción de un usuario, debes pasar el identificador del precio de Paddle al método `swap` de la suscripción:


```php
use App\Models\User;

$user = User::find(1);

$user->subscription()->swap($premium = 'pri_456');
```
Si deseas cambiar de plan e facturar inmediatamente al usuario en lugar de esperar su próximo ciclo de facturación, puedes usar el método `swapAndInvoice`:


```php
$user = User::find(1);

$user->subscription()->swapAndInvoice($premium = 'pri_456');
```

<a name="prorations"></a>
#### Prorrateos

Por defecto, Paddle prorratea los cargos al cambiar entre planes. El método `noProrate` se puede usar para actualizar las suscripciones sin prorratear los cargos:


```php
$user->subscription('default')->noProrate()->swap($premium = 'pri_456');
```
Si deseas desactivar la prorrateación e facturar a los clientes de inmediato, puedes usar el método `swapAndInvoice` en combinación con `noProrate`:


```php
$user->subscription('default')->noProrate()->swapAndInvoice($premium = 'pri_456');
```
O, para no cobrar a tu cliente por un cambio de suscripción, puedes utilizar el método `doNotBill`:


```php
$user->subscription('default')->doNotBill()->swap($premium = 'pri_456');
```
Para obtener más información sobre las políticas de prorrateo de Paddle, consulta la [documentación de prorrateo de Paddle](https://developer.paddle.com/concepts/subscriptions/proration).

<a name="subscription-quantity"></a>
### Cantidad de Suscripción

A veces las suscripciones se ven afectadas por la "cantidad". Por ejemplo, una aplicación de gestión de proyectos podría cobrar $10 por mes por proyecto. Para aumentar o disminuir fácilmente la cantidad de tu suscripción, utiliza los métodos `incrementQuantity` y `decrementQuantity`:


```php
$user = User::find(1);

$user->subscription()->incrementQuantity();

// Add five to the subscription's current quantity...
$user->subscription()->incrementQuantity(5);

$user->subscription()->decrementQuantity();

// Subtract five from the subscription's current quantity...
$user->subscription()->decrementQuantity(5);
```
Alternativamente, puedes establecer una cantidad específica utilizando el método `updateQuantity`:


```php
$user->subscription()->updateQuantity(10);
```
El método `noProrate` se puede usar para actualizar la cantidad de la suscripción sin prorratear los cargos:


```php
$user->subscription()->noProrate()->updateQuantity(10);
```

<a name="quantities-for-subscription-with-multiple-products"></a>
#### Cantidades para Suscripciones con Múltiples Productos

Si tu suscripción es una [suscripción con múltiples productos](#subscriptions-with-multiple-products), debes pasar el ID del precio cuya cantidad deseas incrementar o decrementar como segundo argumento a los métodos de incremento / decremento:


```php
$user->subscription()->incrementQuantity(1, 'price_chat');
```

<a name="subscriptions-with-multiple-products"></a>
### Suscripciones con Múltiples Productos

[Las suscripciones con múltiples productos](https://developer.paddle.com/build/subscriptions/add-remove-products-prices-addons) te permiten asignar múltiples productos de facturación a una sola suscripción. Por ejemplo, imagina que estás construyendo una aplicación de "helpdesk" para servicio al cliente que tiene un precio de suscripción base de $10 al mes, pero ofrece un producto adicional de chat en vivo por $15 más al mes.
Al crear sesiones de pago de suscripción, puedes especificar múltiples productos para una suscripción dada pasando un array de precios como primer argumento al método `subscribe`:


```php
use Illuminate\Http\Request;

Route::post('/user/subscribe', function (Request $request) {
    $checkout = $request->user()->subscribe([
        'price_monthly',
        'price_chat',
    ]);

    return view('billing', ['checkout' => $checkout]);
});
```
En el ejemplo anterior, el cliente tendrá dos precios asociados a su suscripción `default`. Ambos precios se cobrarán en sus respectivos intervalos de facturación. Si es necesario, puedes pasar un array asociativo de pares clave / valor para indicar una cantidad específica para cada precio:


```php
$user = User::find(1);

$checkout = $user->subscribe('default', ['price_monthly', 'price_chat' => 5]);
```
Si deseas añadir otro precio a una suscripción existente, debes utilizar el método `swap` de la suscripción. Al invocar el método `swap`, también debes incluir los precios y cantidades actuales de la suscripción:


```php
$user = User::find(1);

$user->subscription()->swap(['price_chat', 'price_original' => 2]);
```
El ejemplo anterior añadirá el nuevo precio, pero el cliente no será facturado por él hasta su próximo ciclo de facturación. Si deseas facturar al cliente de inmediato, puedes usar el método `swapAndInvoice`:


```php
$user->subscription()->swapAndInvoice(['price_chat', 'price_original' => 2]);
```
Puedes eliminar precios de las suscripciones utilizando el método `swap` y omitiendo el precio que deseas eliminar:


```php
$user->subscription()->swap(['price_original' => 2]);
```
> [!WARNING]
No puedes eliminar el último precio en una suscripción. En su lugar, simplemente debes cancelar la suscripción.

<a name="multiple-subscriptions"></a>
### Múltiples Suscripciones

Paddle permite que tus clientes tengan múltiples suscripciones simultáneamente. Por ejemplo, puedes gestionar un gimnasio que ofrece una suscripción de natación y una suscripción de levantamiento de pesas, y cada suscripción puede tener precios diferentes. Por supuesto, los clientes deben poder suscribirse a uno o ambos planes.
Cuando tu aplicación crea suscripciones, puedes proporcionar el tipo de la suscripción al método `subscribe` como segundo argumento. El tipo puede ser cualquier cadena que represente el tipo de suscripción que el usuario está iniciando:


```php
use Illuminate\Http\Request;

Route::post('/swimming/subscribe', function (Request $request) {
    $checkout = $request->user()->subscribe($swimmingMonthly = 'pri_123', 'swimming');

    return view('billing', ['checkout' => $checkout]);
});
```
En este ejemplo, iniciamos una suscripción de natación mensual para el cliente. Sin embargo, es posible que quiera cambiar a una suscripción anual más adelante. Al ajustar la suscripción del cliente, simplemente podemos cambiar el precio en la suscripción `swimming`:


```php
$user->subscription('swimming')->swap($swimmingYearly = 'pri_456');
```
Por supuesto, también puedes cancelar la suscripción por completo:


```php
$user->subscription('swimming')->cancel();
```

<a name="pausing-subscriptions"></a>
### Pausando Suscripciones

Para pausar una suscripción, llama al método `pause` en la suscripción del usuario:


```php
$user->subscription()->pause();
```
Cuando una suscripción está en pausa, Cashier automáticamente establecerá la columna `paused_at` en tu base de datos. Esta columna se utiliza para determinar cuándo el método `paused` debe comenzar a devolver `true`. Por ejemplo, si un cliente pausa una suscripción el 1 de marzo, pero la suscripción no estaba programada para renovarse hasta el 5 de marzo, el método `paused` seguirá devolviendo `false` hasta el 5 de marzo. Esto se debe a que típicamente se permite a un usuario continuar utilizando una aplicación hasta el final de su ciclo de facturación.
Por defecto, la pausa ocurre en el siguiente intervalo de facturación para que el cliente pueda usar el resto del período por el que pagó. Si deseas pausar una suscripción de inmediato, puedes usar el método `pauseNow`:


```php
$user->subscription()->pauseNow();
```
Usando el método `pauseUntil`, puedes pausar la suscripción hasta un momento específico en el tiempo:


```php
$user->subscription()->pauseUntil(now()->addMonth());
```
O, puedes usar el método `pauseNowUntil` para pausar inmediatamente la suscripción hasta un punto en el tiempo dado:


```php
$user->subscription()->pauseNowUntil(now()->addMonth());
```
Puedes determinar si un usuario ha pausado su suscripción pero aún está en su "período de gracia" utilizando el método `onPausedGracePeriod`:


```php
if ($user->subscription()->onPausedGracePeriod()) {
    // ...
}
```
Para reanudar una suscripción en pausa, puedes invocar el método `resume` en la suscripción:


```php
$user->subscription()->resume();
```
> [!WARNING]
No se puede modificar una suscripción mientras está en pausa. Si deseas cambiar a un plan diferente o actualizar cantidades, primero debes reanudar la suscripción.

<a name="canceling-subscriptions"></a>
### Cancelando Suscripciones

Para cancelar una suscripción, llama al método `cancel` en la suscripción del usuario:


```php
$user->subscription()->cancel();
```
Cuando una suscripción es cancelada, Cashier automáticamente establecerá la columna `ends_at` en tu base de datos. Esta columna se utiliza para determinar cuándo el método `subscribed` debe comenzar a devolver `false`. Por ejemplo, si un cliente cancela una suscripción el 1 de marzo, pero la suscripción no estaba programada para finalizar hasta el 5 de marzo, el método `subscribed` seguirá devolviendo `true` hasta el 5 de marzo. Esto se hace porque a un usuario típicamente se le permite continuar usando una aplicación hasta el final de su ciclo de facturación.
Puedes determinar si un usuario ha cancelado su suscripción pero aún está en su "período de gracia" utilizando el método `onGracePeriod`:


```php
if ($user->subscription()->onGracePeriod()) {
    // ...
}
```
Si deseas cancelar una suscripción de inmediato, puedes llamar al método `cancelNow` en la suscripción:


```php
$user->subscription()->cancelNow();
```
Para detener una suscripción en su período de gracia de la cancelación, puedes invocar el método `stopCancelation`:


```php
$user->subscription()->stopCancelation();
```
> [!WARNING]
Las suscripciones de Paddle no se pueden reanudar después de la cancelación. Si tu cliente desea reanudar su suscripción, tendrá que crear una nueva suscripción.

<a name="subscription-trials"></a>
## Pruebas de Suscripción


<a name="with-payment-method-up-front"></a>
### Con Método de Pago por Adelantado

Si deseas ofrecer períodos de prueba a tus clientes mientras aún recopilas información del método de pago por adelantado, debes establecer un tiempo de prueba en el panel de Paddle en el precio al que se está suscribiendo tu cliente. Luego, inicia la sesión de pago como de costumbre:


```php
use Illuminate\Http\Request;

Route::get('/user/subscribe', function (Request $request) {
    $checkout = $request->user()->subscribe('pri_monthly')
                ->returnTo(route('home'));

    return view('billing', ['checkout' => $checkout]);
});
```
Cuando tu aplicación recibe el evento `subscription_created`, Cashier establecerá la fecha de finalización del período de prueba en el registro de la suscripción dentro de la base de datos de tu aplicación, así como instruir a Paddle para que no comience a facturar al cliente hasta después de esta fecha.
> [!WARNING]
Si la suscripción del cliente no se cancela antes de la fecha de finalización de la prueba, se les cobrará tan pronto como expire la prueba, así que debes asegurarte de notificar a tus usuarios sobre la fecha de finalización de su prueba.
Puedes determinar si el usuario está dentro de su período de prueba utilizando el método `onTrial` de la instancia del usuario o el método `onTrial` de la instancia de la suscripción. Los dos ejemplos a continuación son equivalentes:


```php
if ($user->onTrial()) {
    // ...
}

if ($user->subscription()->onTrial()) {
    // ...
}
```
Para determinar si una prueba existente ha expirado, puedes usar los métodos `hasExpiredTrial`:


```php
if ($user->hasExpiredTrial()) {
    // ...
}

if ($user->subscription()->hasExpiredTrial()) {
    // ...
}
```
Para determinar si un usuario está en prueba por un tipo de suscripción específico, puedes proporcionar el tipo a los métodos `onTrial` o `hasExpiredTrial`:


```php
if ($user->onTrial('default')) {
    // ...
}

if ($user->hasExpiredTrial('default')) {
    // ...
}
```

<a name="without-payment-method-up-front"></a>
### Sin Método de Pago Por Adelantado

Si deseas ofrecer períodos de prueba sin recopilar la información del método de pago del usuario por adelantado, puedes establecer la columna `trial_ends_at` en el registro del cliente asociado a tu usuario en la fecha de finalización de prueba deseada. Esto se hace típicamente durante el registro del usuario:


```php
use App\Models\User;

$user = User::create([
    // ...
]);

$user->createAsCustomer([
    'trial_ends_at' => now()->addDays(10)
]);
```
Cashier se refiere a este tipo de prueba como una "prueba genérica", ya que no está vinculada a ninguna suscripción existente. El método `onTrial` en la instancia de `User` devolverá `true` si la fecha actual no ha pasado el valor de `trial_ends_at`:


```php
if ($user->onTrial()) {
    // User is within their trial period...
}
```
Una vez que estés listo para crear una suscripción real para el usuario, puedes usar el método `subscribe` como de costumbre:


```php
use Illuminate\Http\Request;

Route::get('/user/subscribe', function (Request $request) {
    $checkout = $user->subscribe('pri_monthly')
        ->returnTo(route('home'));

    return view('billing', ['checkout' => $checkout]);
});
```
Para recuperar la fecha de finalización de la prueba del usuario, puedes usar el método `trialEndsAt`. Este método devolverá una instancia de fecha Carbon si un usuario está en una prueba o `null` si no lo está. También puedes pasar un parámetro opcional de tipo de suscripción si deseas obtener la fecha de finalización de la prueba para una suscripción específica que no sea la predeterminada:


```php
if ($user->onTrial('default')) {
    $trialEndsAt = $user->trialEndsAt();
}
```
Puedes usar el método `onGenericTrial` si deseas saber específicamente que el usuario está dentro de su período de prueba "genérico" y aún no ha creado una suscripción real:


```php
if ($user->onGenericTrial()) {
    // User is within their "generic" trial period...
}
```

<a name="extend-or-activate-a-trial"></a>
### Extender o Activar una Prueba

Puedes extender un período de prueba existente en una suscripción invocando el método `extendTrial` y especificando el momento en el que debe finalizar la prueba:


```php
$user->subscription()->extendTrial(now()->addDays(5));
```
O bien, puedes activar una suscripción de inmediato finalizando su prueba al llamar al método `activate` en la suscripción:


```php
$user->subscription()->activate();
```

<a name="handling-paddle-webhooks"></a>
## Manejo de Webhooks de Paddle

Paddle puede notificar a tu aplicación sobre una variedad de eventos a través de webhooks. Por defecto, se registra una ruta que apunta al controlador de webhooks de Cashier mediante el proveedor de servicios de Cashier. Este controlador manejará todas las solicitudes de webhook entrantes.
Por defecto, este controlador manejará automáticamente la cancelación de suscripciones que tienen demasi cargos fallidos, actualizaciones de suscripción y cambios en el método de pago; sin embargo, como pronto descubriremos, puedes extender este controlador para manejar cualquier evento de webhook de Paddle que desees.
Para asegurarte de que tu aplicación pueda manejar los webhooks de Paddle, asegúrate de [configurar la URL del webhook en el panel de control de Paddle](https://vendors.paddle.com/alerts-webhooks). Por defecto, el controlador de webhook de Cashier responde a la ruta URL `/paddle/webhook`. La lista completa de todos los webhooks que debes habilitar en el panel de control de Paddle es:
- Cliente Actualizado
- Transacción Completa
- Transacción Actualizada
- Suscripción Creada
- Suscripción Actualizada
- Suscripción Pausada
- Suscripción Cancelada
> [!WARNING]
Asegúrate de proteger las solicitudes entrantes con el middleware de verificación de firmas de webhook incluido en Cashier [verificación de firmas de webhook](/docs/%7B%7Bversion%7D%7D/cashier-paddle#verifying-webhook-signatures).

<a name="webhooks-csrf-protection"></a>
#### Webhooks y Protección CSRF

Dado que los webhooks de Paddle necesitan eludir la [protección CSRF](/docs/%7B%7Bversion%7D%7D/csrf) de Laravel, debes asegurarte de que Laravel no intente verificar el token CSRF para los webhooks de Paddle entrantes. Para lograr esto, debes excluir `paddle/*` de la protección CSRF en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->validateCsrfTokens(except: [
        'paddle/*',
    ]);
})
```

<a name="webhooks-local-development"></a>
#### Webhooks y Desarrollo Local

Para que Paddle pueda enviar webhooks de tu aplicación durante el desarrollo local, necesitarás exponer tu aplicación a través de un servicio de compartición de sitios como [Ngrok](https://ngrok.com/) o [Expose](https://expose.dev/docs/introduction). Si estás desarrollando tu aplicación localmente utilizando [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail), puedes usar el [comando de compartición de sitios de Sail](/docs/%7B%7Bversion%7D%7D/sail#sharing-your-site).

<a name="defining-webhook-event-handlers"></a>
### Definiendo Controladores de Eventos de Webhook

Cashier maneja automáticamente la cancelación de suscripciones en cargos fallidos y otros webhooks comunes de Paddle. Sin embargo, si tienes eventos de webhook adicionales que te gustaría manejar, puedes hacerlo escuchando los siguientes eventos que son despachados por Cashier:
- `Laravel\Paddle\Events\WebhookReceived`
- `Laravel\Paddle\Events\WebhookHandled`
Ambos eventos contienen la carga útil completa del webhook de Paddle. Por ejemplo, si deseas manejar el webhook `transaction.billed`, puedes registrar un [oyente](/docs/%7B%7Bversion%7D%7D/events#defining-listeners) que manejará el evento:


```php
<?php

namespace App\Listeners;

use Laravel\Paddle\Events\WebhookReceived;

class PaddleEventListener
{
    /**
     * Handle received Paddle webhooks.
     */
    public function handle(WebhookReceived $event): void
    {
        if ($event->payload['event_type'] === 'transaction.billed') {
            // Handle the incoming event...
        }
    }
}
```
Cashier también emite eventos dedicados al tipo de webhook recibido. Además de la carga útil completa de Paddle, también contienen los modelos relevantes que se utilizaron para procesar el webhook, como el modelo facturable, la suscripción o el recibo:
<div class="content-list" markdown="1">

- `Laravel\Paddle\Events\CustomerUpdated`
- `Laravel\Paddle\Events\TransactionCompleted`
- `Laravel\Paddle\Events\TransactionUpdated`
- `Laravel\Paddle\Events\SubscriptionCreated`
- `Laravel\Paddle\Events\SubscriptionUpdated`
- `Laravel\Paddle\Events\SubscriptionPaused`
- `Laravel\Paddle\Events\SubscriptionCanceled`
</div>
También puedes anular la ruta de webhook incorporada predeterminada definiendo la variable de entorno `CASHIER_WEBHOOK` en el archivo `.env` de tu aplicación. Este valor debe ser la URL completa a tu ruta de webhook y necesita coincidir con la URL establecida en tu panel de control de Paddle:


```ini
CASHIER_WEBHOOK=https://example.com/my-paddle-webhook-url

```

<a name="verifying-webhook-signatures"></a>
### Verificando Firmas de Webhook

Para asegurar tus webhooks, puedes usar [las firmas de webhook de Paddle](https://developer.paddle.com/webhook-reference/verifying-webhooks). Para mayor comodidad, Cashier incluye automáticamente un middleware que valida que la solicitud de webhook de Paddle entrante sea válida.
Para habilitar la verificación del webhook, asegúrate de que la variable de entorno `PADDLE_WEBHOOK_SECRET` esté definida en el archivo `.env` de tu aplicación. El secreto del webhook se puede obtener desde el panel de control de tu cuenta de Paddle.

<a name="single-charges"></a>
## Cargos Únicos


<a name="charging-for-products"></a>
### Cobrando por Productos

Si deseas iniciar una compra de producto para un cliente, puedes usar el método `checkout` en una instancia de modelo facturable para generar una sesión de pago para la compra. El método `checkout` acepta uno o múltiples ID de precio. Si es necesario, se puede usar un array asociativo para proporcionar la cantidad del producto que se está comprando:


```php
use Illuminate\Http\Request;

Route::get('/buy', function (Request $request) {
    $checkout = $request->user()->checkout(['pri_tshirt', 'pri_socks' => 5]);

    return view('buy', ['checkout' => $checkout]);
});
```
Después de generar la sesión de pago, puedes usar el componente `paddle-button` [Blade](#overlay-checkout) proporcionado por Cashier para permitir que el usuario vea el widget de pago de Paddle y complete la compra:


```blade
<x-paddle-button :checkout="$checkout" class="px-8 py-4">
    Buy
</x-paddle-button>

```
Una sesión de pago tiene un método `customData`, lo que te permite pasar cualquier dato personalizado que desees a la creación de la transacción subyacente. Por favor, consulta [la documentación de Paddle](https://developer.paddle.com/build/transactions/custom-data) para aprender más sobre las opciones disponibles para ti al pasar datos personalizados:


```php
$checkout = $user->checkout('pri_tshirt')
    ->customData([
        'custom_option' => $value,
    ]);
```

<a name="refunding-transactions"></a>
### Reembolsando Transacciones

Las transacciones de reembolso devolverán el monto reembolsado al método de pago de su cliente que se utilizó en el momento de la compra. Si necesita reembolsar una compra de Paddle, puede usar el método `refund` en un modelo `Cashier\Paddle\Transaction`. Este método acepta una razón como primer argumento, uno o más ID de precio para reembolsar con montos opcionales como un array asociativo. Puede recuperar las transacciones para un modelo facturable dado utilizando el método `transactions`.
Por ejemplo, imagina que queremos reembolsar una transacción específica por los precios `pri_123` y `pri_456`. Queremos reembolsar completamente `pri_123`, pero solo reembolsar dos dólares por `pri_456`:


```php
use App\Models\User;

$user = User::find(1);

$transaction = $user->transactions()->first();

$response = $transaction->refund('Accidental charge', [
    'pri_123', // Fully refund this price...
    'pri_456' => 200, // Only partially refund this price...
]);
```
El ejemplo anterior reembolsa elementos de línea específicos en una transacción. Si deseas reembolsar toda la transacción, simplemente proporciona una razón:


```php
$response = $transaction->refund('Accidental charge');
```
Para obtener más información sobre reembolsos, consulta [la documentación de reembolsos de Paddle](https://developer.paddle.com/build/transactions/create-transaction-adjustments).
> [!WARNING]
Los reembolsos deben siempre ser aprobados por Paddle antes de ser procesados completamente.

<a name="crediting-transactions"></a>
### Acreditando Transacciones

Al igual que con los reembolsos, también puedes acreditar transacciones. Acreditar transacciones añadirá los fondos al saldo del cliente para que se puedan usar en compras futuras. Las transacciones de crédito solo se pueden hacer para transacciones recolectadas manualmente y no para transacciones recolectadas automáticamente (como suscripciones), ya que Paddle maneja los créditos de suscripción de forma automática:


```php
$transaction = $user->transactions()->first();

// Credit a specific line item fully...
$response = $transaction->credit('Compensation', 'pri_123');
```
Para obtener más información, [consulta la documentación de Paddle sobre la acreditación](https://developer.paddle.com/build/transactions/create-transaction-adjustments).
> [!WARNING]
Los créditos solo se pueden aplicar a transacciones recopiladas manualmente. Las transacciones recopiladas automáticamente son acreditadas por Paddle.

<a name="transactions"></a>
## Transacciones

Puedes recuperar fácilmente un array de las transacciones de un modelo facturable a través de la propiedad `transactions`:


```php
use App\Models\User;

$user = User::find(1);

$transactions = $user->transactions;
```
Las transacciones representan pagos por tus productos y compras, y van acompañadas de facturas. Solo se almacenan en la base de datos de tu aplicación las transacciones completadas.
Al listar las transacciones de un cliente, puedes usar los métodos de la instancia de la transacción para mostrar la información de pago relevante. Por ejemplo, es posible que desees listar cada transacción en una tabla, permitiendo al usuario descargar fácilmente cualquiera de las facturas:


```html
<table>
    @foreach ($transactions as $transaction)
        <tr>
            <td>{{ $transaction->billed_at->toFormattedDateString() }}</td>
            <td>{{ $transaction->total() }}</td>
            <td>{{ $transaction->tax() }}</td>
            <td><a href="{{ route('download-invoice', $transaction->id) }}" target="_blank">Download</a></td>
        </tr>
    @endforeach
</table>

```
La ruta `download-invoice` puede verse de la siguiente manera:


```php
use Illuminate\Http\Request;
use Laravel\Paddle\Transaction;

Route::get('/download-invoice/{transaction}', function (Request $request, Transaction $transaction) {
    return $transaction->redirectToInvoicePdf();
})->name('download-invoice');
```

<a name="past-and-upcoming-payments"></a>
### Pagos Pasados y Futuros

Puedes usar los métodos `lastPayment` y `nextPayment` para recuperar y mostrar los pagos pasados o próximos de un cliente para suscripciones recurrentes:


```php
use App\Models\User;

$user = User::find(1);

$subscription = $user->subscription();

$lastPayment = $subscription->lastPayment();
$nextPayment = $subscription->nextPayment();
```
Ambos métodos devolverán una instancia de `Laravel\Paddle\Payment`; sin embargo, `lastPayment` devolverá `null` cuando las transacciones aún no han sido sincronizadas por webhooks, mientras que `nextPayment` devolverá `null` cuando el ciclo de facturación ha finalizado (como cuando se ha cancelado una suscripción):


```blade
Next payment: {{ $nextPayment->amount() }} due on {{ $nextPayment->date()->format('d/m/Y') }}

```

<a name="testing"></a>
## Pruebas

Mientras pruebas, deberías probar manualmente tu flujo de facturación para asegurarte de que tu integración funcione como se espera.
Para pruebas automatizadas, incluidas las que se ejecutan dentro de un entorno CI, puedes usar [el cliente HTTP de Laravel](/docs/%7B%7Bversion%7D%7D/http-client#testing) para simular llamadas HTTP realizadas a Paddle. Aunque esto no prueba las respuestas reales de Paddle, proporciona una manera de probar tu aplicación sin llamar realmente a la API de Paddle.