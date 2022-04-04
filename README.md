# docker-legacy-workspace

ForteFibre旧開発環境コンテナです。
今までに書かれたコード(特にMDなどのファームウェア)をビルドできます。

## コンテナイメージの取得

まず、GitHub Container Registryにログインする必要があります。

```bash
docker login ghcr.io
```

この時、GitHubのユーザ名とパスワードの入力を求められます。パスワードにはPersonal Access Token(PAT)を入力する必要があります。PATの作成の手順は[このドキュメント](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)を参照してください。

コンテナイメージをダウンロードして利用する場合、PAT作成時に選択しておく権限は`read:packages`のみです。コンテナイメージのアップロードや削除を行う場合は必要に応じて`write:packages`、`delete:packages`を追加してください。

GitHub Container Registryへの認証についての詳細は[このドキュメント](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry)を参照してください。

ログイン出来れば、コンテナイメージを取得出来るようになります。

```bash
docker pull ghcr.io/fortefibre/legacy-workspace:latest
```

## 基板への書き込み

ビルド成果物を基板に書き込むにはDockerコンテナを立ち上げる際に以下のコマンドを使う必要があります。

```bash
docker run -v /dev:/dev --device-cgroup-rule 'c 188:* rw' --device-cgroup-rule 'c 189:* rw' ghcr.io/fortefibre/legacy-workspace
```
