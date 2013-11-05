# Serf-munin

Serfを利用して、自動で監視対象のmunin-nodeを追加/削除スクリプト

 * thanks @zembutsu
 * refs [https://github.com/zembutsu/serf-munin](https://github.com/zembutsu/serf-munin)
 * refs [serf-muninでmunin-nodeの監視自動追加/削除 \| Pocketstudio.jp log3](http://pocketstudio.jp/log3/2013/11/01/serf-munin-eventhander-auto-monitorin/)

## munin(manager)側

`SERF_ROLE`はmuninのconfでグループ名に利用。任意の値に変更して下さい。
munin(manage)側で`init_munin-node.sh`を流す必要はありません。

``` sh
export SERF_ROLE=manage
sh init_munin.sh
```

## munin-node側

監視されるクライアント全台で実行する必要があります。
`SERF_ROLE`はmuninのconfでグループ名に利用し、
`MUNIN_SERVER`は`serf join`のjoin先として利用しているので、任意の値に変更してください。

``` sh
export SERF_ROLE=web
export MUNIN_SERVER=manage001.hogemoge.lan
sh init_munin-node.sh
```

## Serfの起動、停止方法

munin(manage)側、munin-node側ともに`/etc/init/serf.conf`という起動スクリプトを用意しているので、
Serfの起動、停止コマンドは同じになっています。

起動

``` sh
sudo start serf
```

停止

```
sudo stop serf
```

## 生成されるmuninのconfの説明

serf join/leaveの際に`/etc/munin/conf.d/`配下に`/etc/munin/conf.d/<ホストネーム>.conf`という形で
追加/削除されます。

生成されるconfは下記のような形

``` conf
[<ロール名(グループ名)>;<ホスト名>]
    address <IPアドレス>
    use_node_name yes
```

`serf members`の結果とmuninのconfの状態

``` sh
[root@manage001 serf-munin-setup]# serf members
manage001.pb.foobar.jp    172.18.100.102    alive    manage
web001.pb.foobar.jp    172.18.100.109    alive    web
web002.pb.foobar.jp    172.18.100.106    alive    web
db001.pb.foobar.jp    172.18.100.104    alive    db
db002.pb.foobar.jp    172.18.100.105    alive    db
backup001.pb.foobar.jp    172.18.100.103    alive    backup

[root@manage001 serf-munin-setup]# ll /etc/munin/conf.d/*
-rw-r--r-- 1 root root 84 Nov  5 21:18 /etc/munin/conf.d/backup001.pb.foobar.jp.conf
-rw-r--r-- 1 root root 76 Nov  5 20:40 /etc/munin/conf.d/db001.pb.foobar.jp.conf
-rw-r--r-- 1 root root 76 Nov  5 21:24 /etc/munin/conf.d/db002.pb.foobar.jp.conf
-rw-r--r-- 1 root root 84 Nov  5 20:35 /etc/munin/conf.d/manage001.pb.foobar.jp.conf
-rw-r--r-- 1 root root 78 Nov  5 20:35 /etc/munin/conf.d/web001.pb.foobar.jp.conf
-rw-r--r-- 1 root root 78 Nov  5 20:38 /etc/munin/conf.d/web002.pb.foobar.jp.conf
```

生成されるmuninのconf

``` sh
[root@manage001 serf-munin-setup]# cat /etc/munin/conf.d/manage001.pb.foobar.jp.conf
[manage;manage001.pb.foobar.jp]
    address 172.18.100.102
    use_node_name yes

[root@manage001 serf-munin-setup]# cat /etc/munin/conf.d/web002.pb.foobar.jp.conf
[web;web002.pb.foobar.jp]
    address 172.18.100.106
    use_node_name yes

[root@manage001 serf-munin-setup]# cat /etc/munin/conf.d/backup001.pb.foobar.jp.conf
[backup;backup001.pb.foobar.jp]
    address 172.18.100.103
    use_node_name yes
```

## 要件

 * munin 2.0以上
 * serf 0.2.0以上
 * Serfをeth1でbindしているので、LAN用のeth1が必要
