# Contratos

- [Introducción](#introduction)
  - [Contratos vs. Facades](#contracts-vs-facades)
- [Cuándo Usar Contratos](#when-to-use-contracts)
- [Cómo Usar Contratos](#how-to-use-contracts)
- [Referencia de Contrato](#contract-reference)

<a name="introduction"></a>
## Introducción

Los "contratos" de Laravel son un conjunto de interfaces que definen los servicios centrales proporcionados por el framework. Por ejemplo, un contrato `Illuminate\Contracts\Queue\Queue` define los métodos necesarios para encolar trabajos, mientras que el contrato `Illuminate\Contracts\Mail\Mailer` define los métodos necesarios para enviar correos electrónicos.
Cada contrato tiene una implementación correspondiente proporcionada por el framework. Por ejemplo, Laravel ofrece una implementación de cola con una variedad de controladores, y una implementación de correo que está alimentada por [Symfony Mailer](https://symfony.com/doc/7.0/mailer.html).
Todos los contratos de Laravel viven en [su propio repositorio de GitHub](https://github.com/illuminate/contracts). Esto proporciona un punto de referencia rápido para todos los contratos disponibles, así como un paquete único y desacoplado que se puede utilizar al construir paquetes que interactúan con los servicios de Laravel.

<a name="contracts-vs-facades"></a>
### Contratos vs. Facades

Las [facades](/docs/%7B%7Bversion%7D%7D/facades) y las funciones helper de Laravel proporcionan una forma sencilla de utilizar los servicios de Laravel sin necesidad de utilizar type-hinting y resolver contratos del contenedor de servicios. En la mayoría de los casos, cada facade tiene un contrato equivalente.
A diferencia de las facades, que no requieren que las incluyas en el constructor de tu clase, los contratos te permiten definir dependencias explícitas para tus clases. Algunos desarrolladores prefieren definir sus dependencias de esta manera y, por lo tanto, prefieren usar contratos, mientras que otros desarrolladores disfrutan de la conveniencia de las facades. **En general, la mayoría de las aplicaciones pueden usar facades sin problemas durante el desarrollo.**

<a name="when-to-use-contracts"></a>
## Cuándo Usar Contratos

La decisión de usar contratos o fachadas dependerá del gusto personal y de los gustos de tu equipo de desarrollo. Tanto los contratos como las fachadas se pueden utilizar para crear aplicaciones Laravel robustas y bien probadas. Los contratos y las fachadas no son mutuamente excluyentes. Algunas partes de tus aplicaciones pueden usar fachadas mientras que otras dependen de contratos. Siempre que mantengas las responsabilidades de tu clase enfocadas, notarás muy pocas diferencias prácticas entre el uso de contratos y fachadas.
En general, la mayoría de las aplicaciones pueden usar facades sin problemas durante el desarrollo. Si estás creando un paquete que se integra con múltiples frameworks PHP, es posible que desees usar el paquete `illuminate/contracts` para definir tu integración con los servicios de Laravel sin necesidad de requerir las implementaciones concretas de Laravel en el archivo `composer.json` de tu paquete.

<a name="how-to-use-contracts"></a>
## Cómo Usar Contratos

Entonces, ¿cómo obtienes una implementación de un contrato? En realidad, es bastante simple.
Many tipos de clases en Laravel se resuelven a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container), incluyendo controladores, oyentes de eventos, middleware, trabajos en cola e incluso funciones anónimas de ruta. Así que, para obtener una implementación de un contrato, solo puedes "sugerir el tipo" de la interfaz en el constructor de la clase que se está resolviendo.
Por ejemplo, echa un vistazo a este listener de eventos:


```php
<?php

namespace App\Listeners;

use App\Events\OrderWasPlaced;
use App\Models\User;
use Illuminate\Contracts\Redis\Factory;

class CacheOrderInformation
{
    /**
     * Create a new event handler instance.
     */
    public function __construct(
        protected Factory $redis,
    ) {}

    /**
     * Handle the event.
     */
    public function handle(OrderWasPlaced $event): void
    {
        // ...
    }
}
```
Cuando se resuelve el listener del evento, el contenedor de servicios leerá las indicaciones de tipo en el constructor de la clase y inyectará el valor apropiado. Para aprender más sobre cómo registrar cosas en el contenedor de servicios, consulta [su documentación](/docs/%7B%7Bversion%7D%7D/container).

<a name="contract-reference"></a>
## Referencia de Contrato

Esta tabla proporciona una referencia rápida a todos los contratos de Laravel y sus equivalentes en facades:
<div class="overflow-auto">

| Contrato | Referencias Facade |
| --- | --- |
| [Illuminate\Contracts\Auth\Access\Authorizable](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/Access/Authorizable.php) |   |
| [Illuminate\Contracts\Auth\Access\Gate](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/Access/Gate.php) | `Gate` |
| [Illuminate\Contracts\Auth\Authenticatable](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/Authenticatable.php) |   |
| [Illuminate\Contracts\Auth\CanResetPassword](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/CanResetPassword.php) |   |
| [Illuminate\Contracts\Auth\Factory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/Factory.php) | `Auth` |
| [Illuminate\Contracts\Auth\Guard](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/Guard.php) | `Auth::guard()` |
| [Illuminate\Contracts\Auth\PasswordBroker](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/PasswordBroker.php) | `Password::broker()` |
| [Illuminate\Contracts\Auth\PasswordBrokerFactory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/PasswordBrokerFactory.php) | `Password` |
| [Illuminate\Contracts\Auth\StatefulGuard](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/StatefulGuard.php) |   |
| [Illuminate\Contracts\Auth\SupportsBasicAuth](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/SupportsBasicAuth.php) |   |
| [Illuminate\Contracts\Auth\UserProvider](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Auth/UserProvider.php) |   |
| [Illuminate\Contracts\Broadcasting\Broadcaster](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Broadcasting/Broadcaster.php) | `Broadcast::connection()` |
| [Illuminate\Contracts\Broadcasting\Factory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Broadcasting/Factory.php) | `Broadcast` |
| [Illuminate\Contracts\Broadcasting\ShouldBroadcast](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Broadcasting/ShouldBroadcast.php) |   |
| [Illuminate\Contracts\Broadcasting\ShouldBroadcastNow](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Broadcasting/ShouldBroadcastNow.php) |   |
| [Illuminate\Contracts\Bus\Dispatcher](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Bus/Dispatcher.php) | `Bus` |
| [Illuminate\Contracts\Bus\QueueingDispatcher](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Bus/QueueingDispatcher.php) | `Bus::dispatchToQueue()` |
| [Illuminate\Contracts\Cache\Factory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Cache/Factory.php) | `Cache` |
| [Illuminate\Contracts\Cache\Lock](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Cache/Lock.php) |   |
| [Illuminate\Contracts\Cache\LockProvider](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Cache/LockProvider.php) |   |
| [Illuminate\Contracts\Cache\Repository](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Cache/Repository.php) | `Cache::driver()` |
| [Illuminate\Contracts\Cache\Store](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Cache/Store.php) |   |
| [Illuminate\Contracts\Config\Repository](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Config/Repository.php) | `Config` |
| [Illuminate\Contracts\Console\Application](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Console/Application.php) |   |
| [Illuminate\Contracts\Console\Kernel](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Console/Kernel.php) | `Artisan` |
| [Illuminate\Contracts\Container\Container](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Container/Container.php) | `App` |
| [Illuminate\Contracts\Cookie\Factory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Cookie/Factory.php) | `Cookie` |
| [Illuminate\Contracts\Cookie\QueueingFactory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Cookie/QueueingFactory.php) | `Cookie::queue()` |
| [Illuminate\Contracts\Database\ModelIdentifier](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Database/ModelIdentifier.php) |   |
| [Illuminate\Contracts\Debug\ExceptionHandler](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Debug/ExceptionHandler.php) |   |
| [Illuminate\Contracts\Encryption\Encrypter](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Encryption/Encrypter.php) | `Crypt` |
| [Illuminate\Contracts\Events\Dispatcher](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Events/Dispatcher.php) | `Event` |
| [Illuminate\Contracts\Filesystem\Cloud](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Filesystem/Cloud.php) | `Storage::cloud()` |
| [Illuminate\Contracts\Filesystem\Factory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Filesystem/Factory.php) | `Storage` |
| [Illuminate\Contracts\Filesystem\Filesystem](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Filesystem/Filesystem.php) | `Storage::disk()` |
| [Illuminate\Contracts\Foundation\Application](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Foundation/Application.php) | `App` |
| [Illuminate\Contracts\Hashing\Hasher](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Hashing/Hasher.php) | `Hash` |
| [Illuminate\Contracts\Http\Kernel](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Http/Kernel.php) |   |
| [Illuminate\Contracts\Mail\Mailable](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Mail/Mailable.php) |   |
| [Illuminate\Contracts\Mail\Mailer](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Mail/Mailer.php) | `Mail` |
| [Illuminate\Contracts\Mail\MailQueue](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Mail/MailQueue.php) | `Mail::queue()` |
| [Illuminate\Contracts\Notifications\Dispatcher](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Notifications/Dispatcher.php) | `Notification` |
| [Illuminate\Contracts\Notifications\Factory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Notifications/Factory.php) | `Notification` |
| [Illuminate\Contracts\Pagination\LengthAwarePaginator](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Pagination/LengthAwarePaginator.php) |   |
| [Illuminate\Contracts\Pagination\Paginator](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Pagination/Paginator.php) |   |
| [Illuminate\Contracts\Pipeline\Hub](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Pipeline/Hub.php) |   |
| [Illuminate\Contracts\Pipeline\Pipeline](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Pipeline/Pipeline.php) | `Pipeline` |
| [Illuminate\Contracts\Queue\EntityResolver](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Queue/EntityResolver.php) |   |
| [Illuminate\Contracts\Queue\Factory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Queue/Factory.php) | `Queue` |
| [Illuminate\Contracts\Queue\Job](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Queue/Job.php) |   |
| [Illuminate\Contracts\Queue\Monitor](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Queue/Monitor.php) | `Queue` |
| [Illuminate\Contracts\Queue\Queue](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Queue/Queue.php) | `Queue::connection()` |
| [Illuminate\Contracts\Queue\QueueableCollection](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Queue/QueueableCollection.php) |   |
| [Illuminate\Contracts\Queue\QueueableEntity](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Queue/QueueableEntity.php) |   |
| [Illuminate\Contracts\Queue\ShouldQueue](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Queue/ShouldQueue.php) |   |
| [Illuminate\Contracts\Redis\Factory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Redis/Factory.php) | `Redis` |
| [Illuminate\Contracts\Routing\BindingRegistrar](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Routing/BindingRegistrar.php) | `Route` |
| [Illuminate\Contracts\Routing\Registrar](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Routing/Registrar.php) | `Route` |
| [Illuminate\Contracts\Routing\ResponseFactory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Routing/ResponseFactory.php) | `Response` |
| [Illuminate\Contracts\Routing\UrlGenerator](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Routing/UrlGenerator.php) | `URL` |
| [Illuminate\Contracts\Routing\UrlRoutable](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Routing/UrlRoutable.php) |   |
| [Illuminate\Contracts\Session\Session](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Session/Session.php) | `Session::driver()` |
| [Illuminate\Contracts\Support\Arrayable](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Support/Arrayable.php) |   |
| [Illuminate\Contracts\Support\Htmlable](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Support/Htmlable.php) |   |
| [Illuminate\Contracts\Support\Jsonable](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Support/Jsonable.php) |   |
| [Illuminate\Contracts\Support\MessageBag](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Support/MessageBag.php) |   |
| [Illuminate\Contracts\Support\MessageProvider](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Support/MessageProvider.php) |   |
| [Illuminate\Contracts\Support\Renderable](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Support/Renderable.php) |   |
| [Illuminate\Contracts\Support\Responsable](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Support/Responsable.php) |   |
| [Illuminate\Contracts\Translation\Loader](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Translation/Loader.php) |   |
| [Illuminate\Contracts\Translation\Translator](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Translation/Translator.php) | `Lang` |
| [Illuminate\Contracts\Validation\Factory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Validation/Factory.php) | `Validator` |
| [Illuminate\Contracts\Validation\ValidatesWhenResolved](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Validation/ValidatesWhenResolved.php) |   |
| [Illuminate\Contracts\Validation\ValidationRule](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Validation/ValidationRule.php) |   |
| [Illuminate\Contracts\Validation\Validator](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/Validation/Validator.php) | `Validator::make()` |
| [Illuminate\Contracts\View\Engine](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/View/Engine.php) |   |
| [Illuminate\Contracts\View\Factory](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/View/Factory.php) | `View` |
| [Illuminate\Contracts\View\View](https://github.com/illuminate/contracts/blob/%7B%7Bversion%7D%7D/View/View.php) | `View::make()` |
</div>