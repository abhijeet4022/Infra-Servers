#!/bin/bash

## Source Common Functions
source ./common-functions.sh

## Checking Root User or not.
CheckRoot

## Checking SELINUX Enabled or not.
CheckSELinux

## Checking Firewall on the Server.
CheckFirewall

# Check if Java is installed
which java &>/dev/null
if [ $? -ne 0 ]; then
    yum install -y java wget &>/dev/null
    if [ $? -eq 0 ]; then
        echo "[SUCCESS] JAVA Installed Successfully"
    else
        echo "[ERROR] JAVA Installation Failure!"
        exit 1
    fi
else
    echo "[SUCCESS] Java already Installed"
fi

# Install required dependency
dnf install -y https://kojipkgs.fedoraproject.org/packages/python-html2text/2020.1.16/5.el9/noarch/python3-html2text-2020.1.16-5.el9.noarch.rpm &>/dev/null

# Download Nexus
#URL="https://download.sonatype.com/nexus/3/nexus-3.64.0-04-unix.tar.gz"
URL="https://sonatype-download.global.ssl.fastly.net/repository/downloads-prod-group/3/nexus-3.78.1-02-unix.tar.gz"
NEXUSFILE=$(basename "$URL")                            # nexus-3.64.0-04-unix.tar.gz
NEXUSDIR=$(echo $NEXUSFILE | sed 's/-unix.tar.gz//')    # nexus-3.64.0-04
TARGETFILE="/opt/$NEXUSFILE"

curl -L -o "$TARGETFILE" "$URL" &>/dev/null
if [ $? -eq 0 ]; then
    echo "[SUCCESS] NEXUS Downloaded Successfully"
else
    echo "[ERROR] NEXUS Downloading Failed"
    exit 1
fi

# Create Nexus user if not exists
id nexus &>/dev/null
if [ $? -ne 0 ]; then
    useradd nexus
    if [ $? -eq 0 ]; then
        echo "[SUCCESS] Added NEXUS User"
    else
        echo "[ERROR] Failed to add NEXUS User"
        exit 1
    fi
fi

# Extract Nexus as nexus user
if [ ! -d "/home/nexus/$NEXUSDIR" ]; then
    cp "$TARGETFILE" /home/nexus/
    chown nexus:nexus /home/nexus/$(basename "$TARGETFILE")
    su - nexus -c "cd /home/nexus && tar xf $NEXUSFILE"
    if [ $? -eq 0 ]; then
        echo "[SUCCESS] Extracted Nexus"
    else
        echo "[ERROR] Failed to Extract Nexus"
        exit 1
    fi
fi

# Configure Nexus service
unlink /etc/init.d/nexus &>/dev/null
ln -s /home/nexus/$NEXUSDIR/bin/nexus /etc/init.d/nexus

echo "run_as_user=nexus" > /home/nexus/$NEXUSDIR/bin/nexus.rc

CONFIG_FILE=$(find /home/nexus/ -name nexus-default.properties)
sed -i '/nexus.scripts.allowCreation/d' "$CONFIG_FILE"
echo "nexus.scripts.allowCreation=true" >> "$CONFIG_FILE"

# Install Nexus CLI
pip3 install nexus3-cli &>/tmp/nexus-install.log

# Enable and start Nexus service
systemctl enable nexus &>/dev/null
systemctl start nexus
if [ $? -eq 0 ]; then
    echo "[SUCCESS] Nexus service started"
else
    echo "[ERROR] Nexus service failed to start"
    exit 1
fi
