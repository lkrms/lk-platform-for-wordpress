<?php

/**
 * Plugin Name:     lk-platform integration for WordPress
 * Plugin URI:      https://github.com/lkrms/lk-platform-for-wordpress
 * Description:     Integrate WordPress with lk-platform's provisioning features.
 * Author:          Luke Arms
 * Author URI:      https://github.com/lkrms
 * License:         MIT
 * Text Domain:     lk-platform-for-wordpress
 * Domain Path:     /languages
 * Version:         0.1.0
 */

use Lkrms\Wp\LkPlatform\LkPlatform;

require __DIR__ . '/vendor/autoload.php';

define('LKWP_FILE', __FILE__);

if (!defined('LKWP_VENDOR_EMAIL_REGEX'))
{
    define('LKWP_VENDOR_EMAIL_REGEX', '/@linacreative\\.com$/');
}

/**
 * @return LkPlatform
 */
function LKWP()
{
    return LkPlatform::GetInstance();
}

LKWP()->Load();
