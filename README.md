## 概要

4価のゴールドバーグ多面体の頂点計算プログラム  
背景はこの辺り
- https://www.nature.com/articles/nature20771
- http://www.jst.go.jp/pr/announce/20161222/index.html

キラリティの考慮は難しいため(グラフとしては同一のため不可能か？)、x座標を-1倍するなりして対応すること。

## 使い方
```
ruby main.rb
```
で実行。その後にh, kの値を聞かれるので標準入力で答えると計算が始まる。
結果はcsv/に"#{timestamp}MnL2n.csv"という形で出力され、index.htmlをローカルで開くと、見た目の確認ができる。
