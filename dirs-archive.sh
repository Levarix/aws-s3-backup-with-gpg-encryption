#!/bin/bash

REPO_GPG_PASS=$REPO_GPG_PASS
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
S3_BUCKET_NAME=$S3_BUCKET_NAME
OUTPUT_DIR=output

if [ ! -d $OUTPUT_DIR ]; then
        mkdir -p $OUTPUT_DIR
fi

run_gpg_in_docker () {
    docker run -i --rm \
    -v $PWD:/data \
    -w /data \
    sergeyzh/gpg:latest \
    $@
}

run_tar_in_docker () {
    docker run -i --rm \
    -v $PWD:/data \
    -w /data \
    alpine:latest \
    $@
}

run_aws_in_docker () {
    docker run -i --rm \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -v $PWD:/data \
    garland/aws-cli-docker:latest \
    $@
}

archive_all () {
  for filename in `ls -1 $PWD |grep -v ".sh"`
    do
     run_tar_in_docker tar -cvzf $OUTPUT_DIR/$filename.tgz $filename
     run_gpg_in_docker  gpg --yes --batch --passphrase=$REPO_GPG_PASS -c "$OUTPUT_DIR/${filename}.tgz"
    done
    rm -rf $OUTPUT_DIR/*.tgz

    run_aws_in_docker aws s3 cp /data/output/*.tgz.gpg s3://$S3_BUCKET_NAME/ --recursive
}

archive () {
  filename=$1
  run_tar_in_docker tar cvzf $OUTPUT_DIR/$filename.tgz $filename
  run_gpg_in_docker gpg --yes --batch --passphrase=$REPO_GPG_PASS -c $OUTPUT_DIR/$filename.tgz
  rm -rf $OUTPUT_DIR/*.tgz

  run_aws_in_docker aws s3 cp /data/$OUTPUT_DIR/$filename.tgz.gpg s3://$S3_BUCKET_NAME/
}

unarchive_all () {

    run_aws_in_docker aws s3 cp s3://$S3_BUCKET_NAME/ /data --recursive

for filename in `ls -1 $PWD |grep "tgz.gpg"`
    do
     FILENAME_WITHOUT_PGP_EXT=$(basename $filename .gpg)
     run_gpg_in_docker  gpg --yes --batch --passphrase=$REPO_GPG_PASS -d $filename > $OUTPUT_DIR/$FILENAME_WITHOUT_PGP_EXT
     run_tar_in_docker tar xvzf $OUTPUT_DIR/$FILENAME_WITHOUT_PGP_EXT -C $OUTPUT_DIR
    done
    rm -rf $OUTPUT_DIR/*.tgz
    rm -rf $OUTPUT_DIR/*.tgz.gpg
}

unarchive () {
    filename=$1

     run_aws_in_docker aws s3 cp s3://$S3_BUCKET_NAME/$filename /data

     FILENAME_WITHOUT_PGP_EXT=$(basename $filename .gpg)
     run_gpg_in_docker gpg --yes --batch --passphrase=$REPO_GPG_PASS -d $filename > $OUTPUT_DIR/$FILENAME_WITHOUT_PGP_EXT
     run_tar_in_docker tar xvzf $OUTPUT_DIR/$FILENAME_WITHOUT_PGP_EXT -C $OUTPUT_DIR
     rm -rf $OUTPUT_DIR/$FILENAME_WITHOUT_PGP_EXT
     rm -rf $OUTPUT_DIR/$filename
}

case $1 in
        "archive-all") archive_all ;;
        "archive") archive $2 ;;
        "unarchive-all") unarchive_all ;;
        "unarchive") unarchive $2 ;;
        *) echo "Unexpected parameter"
esac
