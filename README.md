# Getting Started

tfstateを置くバケットを作成します（既存のものがあればやらなくてもOK）

```
~/go/src/github.com/pei0804/terraform-template init
❯ aws2 --version
aws-cli/2.0.0dev4 Python/3.7.4 Darwin/17.7.0 botocore/2.0.0dev3
❯ aws2 s3api create-bucket --bucket hoge-sandbox-tfstate --region ap-northeast-1
```

[Makefileのパラメーターをいじる](./Makefile)

作成したバケット

```
TFSTATE_BUCKET := hoge-sandbox-tfstate
```

プロファイルを設定してください。 `~/.aws/config`

```
AWS_PROFILE := default or your profilename
```

設定を適用

```
❯ make plan SCOPE=sandbox_bootup/ #良さそうならapplyもしよう
❯ make apply SCOPE=sandbox_bootup/
```
