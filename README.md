# devmem-edge-detecter

## 概要
組込みLinux開発向けのレジスタ確認簡易ツールです。パワーマネジメントによりアクティブな瞬間のみレジスタ値が有効になるケースでは、devmem2コマンドなどで値を見るのが少々面倒になります。このツールはレジスタ値の変化をポーリングループで監視し、変化前後の値を標準出力します。

## 使い方
~~~shell
$ sudo bash ./devmem_edge_detect.sh 0xE0007000 5
~~~
第１引数：物理アドレス

第２引数：検知回数

1. devmem2コマンドをインストールしておきます
1. 上記の様にツールを起動する。検知待ちに入る
1. 別端末でテストプログラムを実行する
1. 検知回数に達するとツール終了。それ以外はCtrl+Cで終了

## サンプル
SoCのSPIのレジスタを確認する。ただし、通信中のみ値が有効になるので、ダミー通信を行う。

レジスタアドレス：0xE0007000  
検知回数：５回まで(３回イベント後、手動停止)

**フォーマット**  
elapsed_time[sec]=経過時間  
event[1-0]diff_time[sec]=前回イベントからの時間  
before= レジスタ変更前の値 16進数表示 2進数表示  
after= レジスタ変更後の値 16進数表示 2進数表示

~~~shell
user@hoge:~$ sudo bash ./devmem_edge_detect.sh 0xE0007000 5
paddr= 0xE0007000
total_detections= 5
Wait reg value change event...

event= 1
elapsed_time[sec]= 5.2701  event[1-0]diff_time[sec]= 5.2701
before= 0x00000000    0b0000 0000 0000 0000 0000 0000 0000 0000
after=  0x0000781F    0b0000 0000 0000 0000 0111 1000 0001 1111

event= 2
elapsed_time[sec]= 5.5026  event[2-1]diff_time[sec]= .2325
before= 0x0000781F    0b0000 0000 0000 0000 0111 1000 0001 1111
after=  0x00007C1F    0b0000 0000 0000 0000 0111 1100 0001 1111

event= 3
elapsed_time[sec]= 9.0214  event[3-2]diff_time[sec]= 3.5188
before= 0x00007C1F    0b0000 0000 0000 0000 0111 1100 0001 1111
after=  0x00000000    0b0000 0000 0000 0000 0000 0000 0000 0000

^C
user@hoge:~$
~~~