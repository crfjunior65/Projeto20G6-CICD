<?php
class DB extends DBmysql {
   public $dbhost = 'YOUR_DB_HOST';
   public $dbuser = 'YOUR_DB_USER';
   public $dbpassword = 'YOUR_DB_PASSWORD';
   public $dbdefault = 'YOUR_DB_NAME';
   public $use_timezones = true;
   public $use_utf8mb4 = true;
   public $allow_myisam = false;
   public $allow_datetime = false;
   public $allow_signed_keys = false;
}
