#!/bin/bash

NOTICE_COLOR="\033[33m"
WARNING_COLOR="\033[31m"
RESET_COLOR="\033[0m"

current_date=$(date +%s)

certs=$(sudo certbot certificates 2>/dev/null)

echo "$certs" | while read line; do
    if [[ "$line" =~ "Domains:" ]]; then
        domain=$(echo $line | sed 's/.*Domains: \(.*\)/\1/')
    fi
    
    if [[ "$line" =~ "Expiry Date:" ]]; then
        # "Expiry Date: 2025-05-17 09:00:04+00:00"에서 날짜만 추출
        expiry_date=$(echo $line | sed 's/.*Expiry Date: \([0-9-]*\).*/\1/')
        expiry_timestamp=$(date -d "$expiry_date" +%s)
        
        days_left=$(( (expiry_timestamp - current_date) / 86400 ))

        echo -e "${NOTICE_COLOR}[Notice] The SSL certificate for $domain will expire in $days_left days (Expiry Date: $expiry_date).${RESET_COLOR}"

        if [ "$days_left" -le 30 ]; then
            echo -e "${WARNING_COLOR}[Notice] WARNING: The SSL certificate for $domain is expiring in $days_left days!${RESET_COLOR}"
        fi
    fi
done
