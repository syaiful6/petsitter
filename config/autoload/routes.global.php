<?php

return [
    'dependencies' => [
        'invokables' => [
            Zend\Expressive\Router\RouterInterface::class => Zend\Expressive\Router\FastRouteRouter::class,
        ],
        // Map middleware -> factories here
        'factories' => [

        ],
    ],

    'routes' => [
        [
            'name'  => 'welcome',
            'path'  => '/',
            'middleware' => 'App\Http\Actions\WelcomeAction',
            'allowed_methods' => ['GET'],
        ],
        [
            'name' => 'login',
            'path' => '/login',
            'middleware' => 'App\Http\Actions\Auth\LoginAction',
            'allowed_methods' => ['GET', 'POST']
        ],
        [
            'name' => 'logout',
            'path' => '/logout',
            'middleware' => 'Pawon\Contrib\Auth\LogoutAction',
            'allowed_methods' => ['GET']
        ],
        [
            'name' => 'register',
            'path' => '/register',
            'middleware' => 'App\Http\Actions\Auth\RegisterAction',
            'allowed_methods' => ['GET', 'POST']
        ],
        [
            'name' => 'reset_password',
            'path' => '/password/reset',
            'middleware' => 'App\Http\Actions\Auth\ResetsPasswords',
            'allowed_methods' => ['GET', 'POST']
        ],
        [
            'name' => 'reset_confirm',
            'path' => '/password/confirm/{token}/{email}',
            'middleware' => 'App\Http\Actions\Auth\ResetPasswordConfirm',
            'allowed_methods' => ['GET', 'POST']
        ],
    ],
];
