<?php

return [
    'dependencies' => [
        'factories' => [
            'Pawon\Auth\ModelBackend' => 'Pawon\Auth\AuthServiceFactory',
            'Pawon\Auth\Authenticator' => 'Pawon\Auth\AuthServiceFactory',
            'Pawon\Auth\AuthenticationMiddleware' => 'Pawon\Auth\AuthServiceFactory',
            'Pawon\Auth\Password\TokenRepositoryInterface'
                => 'Pawon\Auth\Password\PasswordResetServiceFactory',
            'Illuminate\Contracts\Auth\PasswordBroker'
                => 'Pawon\Auth\Password\PasswordResetServiceFactory',
        ]
    ],
    'auth' => [
        'model' => 'App\User',
        'backends' => [
            'Pawon\Auth\ModelBackend'
        ],
        'passwords' => [
            'user' => [
                'table' => 'password_resets',
                'template' => 'app::auth/email/reset',
                'expire' => 60
            ]
        ]
    ]
];
