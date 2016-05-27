<?php
use Zend\Expressive\Container\ApplicationFactory;
use Pawon\Session;

return [
    'dependencies' => [
        'factories' => [
            Pawon\Http\Routing\DispatchRoute::class
                => Pawon\Http\Routing\RoutingServiceFactory::class,
            Pawon\Http\Routing\RoutingMiddleware::class
                => Pawon\Http\Routing\RoutingServiceFactory::class,
            Pawon\Http\Routing\RoutedMiddlewareResolver::class
                => Pawon\Http\Routing\RoutingServiceFactory::class,
            Session\SessionMiddleware::class
                => Session\SessionMiddlewareFactory::class,
            Pawon\Cookie\QueueMiddleware::class
                => Pawon\Cookie\QueueMiddlewareFactory::class,
            Pawon\Middleware\Csrf::class =>
                Pawon\Middleware\GenericMiddlewareFactory::class,
            Pawon\Middleware\ContextProcessor::class =>
                Pawon\Middleware\GenericMiddlewareFactory::class,
            'Pawon\Contrib\Http\WebMiddleware' =>
                'App\Http\Middleware\WebMiddlewareFactory',
            'Pawon\Middleware\ErrorHandler' =>
                Pawon\Middleware\GenericMiddlewareFactory::class,
        ],
    ],
    // This can be used to seed pre- and/or post-routing middleware
    'middleware_pipeline' => [
        'always' => [
            'middleware' => [
                // Add more middleware here that you want to execute on
                // every request:
                // - bootstrapping
                // - pre-conditions
                // - modifications to outgoing responses
                'Pawon\Middleware\ErrorHandler',
                'Pawon\Database\CapsuleMiddleware',
                Pawon\Middleware\ServerUrlMiddleware::class,
            ],
            'priority' => 10000,
        ],

        'routing' => [
            'middleware' => [
                Pawon\Http\Routing\RoutingMiddleware::class,
                Pawon\Middleware\UrlHelperMiddleware::class,
                // Add more middleware here that needs to introspect the routing
                // results; this might include:
                // - route-based authentication
                // - route-based validation
                // - etc.
                'Pawon\Contrib\Http\WebMiddleware',
                Pawon\Http\Routing\DispatchRoute::class,
            ],
            'priority' => 1,
        ],
    ],
];
