<?php

declare(strict_types=1);

namespace Lkrms\Wp\LkPlatform;

use WP_User;

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

    /**
     * @var bool
     */
    private $UserSwitchingLimited = false;

    /**
     * @var bool
     */
    private $UserSwitchRedirected = false;

    /**
     * @var string
     */
    private $NextLoginRedirect;

    private function __construct()
    {
    }

    /**
     * @return LkPlatform
     */
    public static function GetInstance(): LkPlatform
    {
        if (!self::$Instance)
        {
            self::$Instance = new LkPlatform();
        }

        return self::$Instance;
    }

    public function Load()
    {
        if (!(defined('WP_CLI') && WP_CLI))
        {
            $this->IgnoreCronJobs();

            if (is_admin())
            {
                $this->HidePlugin(plugin_basename(LKWP_FILE));
                $this->HidePlugin('user-switching/user-switching.php');
                $this->HidePlugin('wp-cli-login-server/wp-cli-login-server.php');
            }

            if (is_plugin_active('user-switching/user-switching.php'))
            {
                $this->LimitUserSwitching();
                $this->RedirectUserSwitch();
            }
        }
    }

    public function GetUser($user): WP_User
    {
        if ($user instanceof WP_User)
        {
            return $user;
        }

        return get_userdata($user);
    }

    public function UserIsVendor(WP_User $user = null): bool
    {
        if (is_null($user))
        {
            $user = wp_get_current_user();
        }

        return (bool)preg_match(LKWP_VENDOR_EMAIL_REGEX, $user->user_email);
    }

    public function UserHasRole(string $role, WP_User $user = null): bool
    {
        if (is_null($user))
        {
            $user = wp_get_current_user();
        }

        return in_array($role, $user->roles);
    }

    public function IgnoreCronJobs()
    {
        if (!$this->CronJobsIgnored)
        {
            add_filter('pre_get_ready_cron_jobs', [$this, '_IgnoreCronJobs_Filter']);
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
        if ($this->UserIsVendor())
        {
            return;
        }

        global $wp_list_table;

        foreach (array_intersect($this->HiddenPlugins, array_keys($wp_list_table->items)) as $plugin)
        {
            unset($wp_list_table->items[$plugin]);
        }
    }

    public function LimitUserSwitching()
    {
        if (!$this->UserSwitchingLimited)
        {
            add_filter('user_has_cap', [$this, '_LimitUserSwitching_Filter'], 9, 4);
            $this->UserSwitchingLimited = true;
        }
    }

    public function _LimitUserSwitching_Filter($allcaps, $caps, $args, $user)
    {
        if ('switch_to_user' === $args[0] && !$this->UserIsVendor($user))
        {
            $allcaps['switch_users'] = false;
        }

        return $allcaps;
    }

    public function RedirectUserSwitch()
    {
        if (!$this->UserSwitchRedirected)
        {
            add_action('switch_to_user', [$this, '_RedirectSwitchToUser_Action']);
            add_action('switch_back_user', [$this, '_RedirectSwitchBackUser_Action'], 10, 2);
            add_filter('login_redirect', [$this, '_RedirectUserSwitch_Filter']);
            $this->UserSwitchRedirected = true;
        }
    }

    public function _RedirectSwitchToUser_Action($user_id)
    {
        if ($this->UserHasRole('administrator', $this->GetUser($user_id)))
        {
            $this->NextLoginRedirect = admin_url();
        }
        else
        {
            $this->NextLoginRedirect = home_url();
        }
    }

    public function _RedirectSwitchBackUser_Action($user_id, $old_user_id)
    {
        $user = $this->GetUser($old_user_id);
        $this->NextLoginRedirect = self_admin_url("users.php" .
            ($user && $user->display_name ? "?s=" . urlencode($user->display_name) : ""));
    }

    public function _RedirectUserSwitch_Filter($redirect_to)
    {
        $redirect_to = $this->NextLoginRedirect ?: $redirect_to;
        $this->NextLoginRedirect = null;

        return $redirect_to;
    }
}

