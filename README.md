packetter
================

[My SoftBank][msb]から自分のパケット代を取得してTwitterにツイートするRubyスクリプト。

[msb]: http://my.softbank.jp/

必要なもの
----------------
* My SoftBankのアカウント(携帯電話番号 / パスワード)
* Twitterのapplication(Consumer key / Consumer secret)
* applicationを認証したTwitterのアカウント(Access token / Access token secret) ※Read and write
* RubyGemsで以下を入れておく
    * Mechanize
    * OAuth
    * Twitter

使い方
----------------
1. **config.rb** に情報を記入
1. **packetter.rb** をcronにでも登録して毎日実行するようにする
