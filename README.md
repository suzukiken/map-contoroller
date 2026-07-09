https://tech.alpsalpine.com/j/products/detail/RKJXT1F42001/

https://wiki.seeedstudio.com/ja/XIAO-RP2040/

を使った基板に

https://qmk.fm

で作ったソフトウェアを書き込んで

androidディレクトリに入れた、地図アプリのコントローラーとして使う。


## 基板の配線について

基板は、CNC切削で行う。エンドミルは0.5mm。
2層ではなく、Bottomだけの1層基板つまり片面基板でなければならない。
GNDはベタグラウンドではなく、トレースを使う。

配線は垂直、または水平、または45度の直線。
幅は0.5mm 配線と配線の間の空間は0.5mm
ただし、直角で曲がるのは禁止。
もし直角方向に向きを変えるためには、45度の曲がりを２回行うこと。そしてもしそのように繰り返し45度で曲がる場合は、１つの線分の長さは目視できる程度（例えば0.5mm程度）であること。

## 回路について

片面基板という制約があるため、配線が交差しないような、回路設計が必要。

例えば、このような回路は配線が交差しないのではないかと思う。
（ただし実際に配線が可能か未確認）
例：
Switch A - P7
Switch B - P27
Switch C - P28
Switch D - P6
Encorder A - P29
Encorder B - P26
Push - P0
Com - GND
Encorder Com - GND
GND - GND