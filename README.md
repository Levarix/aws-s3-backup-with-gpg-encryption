# aws-s3-backup-with-gpg-encryption
Script to archive and encrypt or unarchive and decrypt Github dirs and push them to S3 bucket. Script use tar to archive and GPG with Passphrase to encrypt

Before using the script, export REPO_GPG_PASS, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, S3_BUCKET_NAME variables.

For your comfort, you can use screen to run the script. It may take a lot time in case of archive-all or unarchive-all

## Archive All Dirs
`./dirs-archive.sh archive-all`

## Archive Single Dir
`./dirs-archive.sh archive <dir_name>`

## Unarchive All Dirs
`./dirs-archive.sh unarchive-all`

## Unarchive Single Dirs
`./dirs-archive.sh unarchive <file_name>.gz.gpg`


## Archiving
When you run the script, archived files will be copied to S3 Bucket automatically.

Script run in a directory with dirs that you want to archive. For example:
```
Repos
|
|--- repo-archive.sh <--- (OUR SCRIPT)
|--- repo_to_archive1
|--- repo_to_archive2
|--- repo_to_archive3
```
Outputs are files tgz.gpg located in output directory
```
Repos
|
|--- repo-archive.sh <--- (OUR SCRIPT)
|--- repo_to_archive1
|--- repo_to_archive2
|--- repo_to_archive3
|--- output
       |
       |--- repo_to_archive1.tgz.gpg
       |--- repo_to_archive2.tgz.gpg
       |--- repo_to_archive3.tgz.gpg
```
## Unarchiving
When you run the script, repos will be download automatically from S3 to the current directory.

Script run in a directory with dirs that you want to unarchive. For example:
```
Repos
|
|--- repo-archive.sh <--- (OUR SCRIPT)
|--- repo_to_unarchive1.tgz.gpg
|--- repo_to_unarchive2.tgz.gpg
|--- repo_to_unarchive3.tgz.gpg
```
Outputs are dirs located in output directory
```
Repos
|
|--- repo-archive.sh <--- (OUR SCRIPT)
|--- repo_to_unarchive1.tgz.gpg
|--- repo_to_unarchive2.tgz.gpg
|--- repo_to_unarchive3.tgz.gpg
|--- output
       |
       |--- repo_to_unarchive1
       |--- repo_to_unarchive2
       |--- repo_to_unarchive3
```
