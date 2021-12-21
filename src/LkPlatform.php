<?php

declare(strict_types=1);

namespace Lkrms\Wp;

if (!defined('ABSPATH'))
{
    exit;
}

if (!class_alias("\Lkrms\Wp\LkPlatform\LkPlatform", "\Lkrms\Wp\LkPlatform"))
{
    /**
     * @ignore
     */
    class LkPlatform extends LkPlatform\LkPlatform
    {
    }
}

