#!/bin/bash

echo -e "##- Generate an encryption key -##\n"
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
echo -e "$ENCRYPTION_KEY\n\n"

echo "##- Create the encryption-config.yaml encryption config file -##"
{
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
}

if [[ -e ./encryption-config.yaml ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    encryption-config.yaml\n"
else
   echo "\nError...\n"
fi

