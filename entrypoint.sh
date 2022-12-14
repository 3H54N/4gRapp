#!/bin/sh

# Global variables
DIR_CONFIG="/etc/yaR2V"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write yaR2V configuration
cat << EOF > ${DIR_TMP}/heroku.json
{
    "inbounds": [{
        "port": ${PORT},
        "protocol": "vmess",
        "settings": {
            "clients": [{
                "id": "${ID}",
                "alterId": ${AID}
            }]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": "${WSPATH}"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF

# Get yaR2V executable release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/3H54N/4gRapp/yaR2V-linux-64.zip -o ${DIR_TMP}/yaR2V_dist.zip
busybox unzip ${DIR_TMP}/yaR2V_dist.zip -d ${DIR_TMP}

# Convert to protobuf format configuration
mkdir -p ${DIR_CONFIG}
${DIR_TMP}/v2ctl config ${DIR_TMP}/heroku.json > ${DIR_CONFIG}/config.pb

# Install yaR2V
install -m 755 ${DIR_TMP}/yaR2V ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

# Run yaR2V
${DIR_RUNTIME}/yaR2V -config=${DIR_CONFIG}/config.pb
