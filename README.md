# Tetravalent Goldberg Polyhedron

Ceres Solverを使ったよりまともなものを，https://github.com/eduidl/tgp-ceres に置いているので，そちらを参照のこと．

## 概要

4価のゴールドバーグ多面体の頂点計算プログラムです．  
背景は以下を参照のこと．
- https://www.nature.com/articles/nature20771
- http://www.jst.go.jp/pr/announce/20161222/index.html

キラリティの考慮は難しいため(グラフとしては同一のため不可能か？)，x座標を-1倍するなりして対応すること．

結果の一部は https://eduidl.github.io/polyhedron/ で確認可能．

## Requirements

- Ruby 2.7.0
- Node.js

## 使い方
```
ruby main.rb
```
で実行．その後にh, kの値を聞かれるので標準入力で答えると計算が始まる．
結果はcsv/に"#{timestamp}MnL2n.csv"という形で出力される．

```sh
npm i
npm run start
```

で `webpack-dev-server` が立ち上がり，結果の可視化ができる．
