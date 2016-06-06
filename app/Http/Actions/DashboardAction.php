<?php

namespace App\Http\Actions;

use Pawon\Http\Middleware\FrameInterface;
use Pawon\Auth\Access\LoginRequiredTrait;
use Psr\Http\Message\ServerRequestInterface as Request;

class DashboardAction extends Action
{
    use LoginRequiredTrait;
    /**
     *
     */
    public function handlePermissionPassed(Request $request, FrameInterface $frame)
    {
        $html = $this->renderer->render('app::dashboard');

        return $frame->getResponseFactory()->make($html, 200, [
            'Content-Type'  => 'text/html; charset=utf-8'
        ]);
    }

    /**
     * Give the user an helpfull message here.
     *
     * @return string
     */
    protected function getPermissionDeniedMessage()
    {
        return trans()->has('auth.login.required')
        ? trans()->get('auth.login.required')
        : 'You can\'t access that page without logged in';
    }
}
