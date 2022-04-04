# docker-legacy-workspace

ForteFibre旧開発環境コンテナです。
今までに書かれたコード(特にMDなどのファームウェア)をビルドできます。

ビルド成果物を基板に書き込むにはDockerコンテナを立ち上げる際に以下のコマンドを使う必要があります。

```bash
docker run -v /dev:/dev --device-cgroup-rule 'c 188:* rw' --device-cgroup-rule 'c 189:* rw' ghcr.io/fortefibre/legacy-workspace
```
