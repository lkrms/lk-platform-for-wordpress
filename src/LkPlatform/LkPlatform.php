<?php

declare(strict_types=1);

namespace Lkrms\Wp\LkPlatform;

class LkPlatform
{
    /**
     * @var LkPlatform
     */
    private static $Instance;

    /**
     * @var bool
     */
    private $CronJobsIgnored = false;

    /**
     * @var string[]
     */
    private $HiddenPlugins;

    private function __construct()
    {
    }

    /**
     * @return LkPlatform
     */
    public static function GetInstance()
    {
        if (!self::$Instance)
        {
            self::$Instance = new LkPlatform();
        }

        return self::$Instance;
    }

    public function Init()
    {
        if (!(defined('WP_CLI') && WP_CLI))
        {
            $this->IgnoreCronJobs();

            if (is_admin())
            {
                $this->HidePlugin(plugin_basename(LKWP_FILE));
                $this->HidePlugin('wp-cli-login-server/wp-cli-login-server.php');
            }
        }
    }

    public function IgnoreCronJobs()
    {
        if (!$this->CronJobsIgnored)
        {
            add_filter('pre_get_ready_cron_jobs', '_IgnoreCronJobs_Filter');
            $this->CronJobsIgnored = true;
        }
    }

    public function _IgnoreCronJobs_Filter()
    {
        return [];
    }

    public function HidePlugin(string $plugin)
    {
        if (is_null($this->HiddenPlugins))
        {
            $this->HiddenPlugins = [];
            add_action('pre_current_active_plugins', [$this, '_HidePlugin_Action']);
        }

        $this->HiddenPlugins[] = $plugin;
    }

    public function _HidePlugin_Action()
    {
        if (preg_match('/' . defined('LKWP_VENDOR_EMAIL_REGEX')
            ? LKWP_VENDOR_EMAIL_REGEX
            : '@linacreative\\.com$' . '/', wp_get_current_user()->user_email))
        {
            return;
        }

        global $wp_list_table;

        foreach (array_intersect($this->HiddenPlugins, array_keys($wp_list_table->items)) as $plugin)
        {
            unset($wp_list_table->items[$plugin]);
        }
    }
}

