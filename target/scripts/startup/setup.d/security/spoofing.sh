#!/bin/bash

function _setup_spoof_protection
{
  if [[ ${SPOOF_PROTECTION} -eq 1 ]]
  then
    _log 'trace' 'Enabling and configuring spoof protection'

    sed -i \
      's|smtpd_sender_restrictions =|smtpd_sender_restrictions = reject_authenticated_sender_login_mismatch,|' \
      /etc/postfix/main.cf

    if [[ ${ACCOUNT_PROVISIONER} == 'LDAP' ]]
    then
      if [[ -z ${LDAP_QUERY_FILTER_SENDERS} ]]
      then
        postconf 'smtpd_sender_login_maps = ldap:/etc/postfix/ldap-users.cf ldap:/etc/postfix/ldap-aliases.cf ldap:/etc/postfix/ldap-groups.cf'
      else
        postconf 'smtpd_sender_login_maps = ldap:/etc/postfix/ldap-senders.cf'
      fi
    else
      if [[ -f /etc/postfix/regexp ]]
      then
        postconf 'smtpd_sender_login_maps = unionmap:{ texthash:/etc/postfix/virtual, hash:/etc/aliases, pcre:/etc/postfix/maps/sender_login_maps.pcre, pcre:/etc/postfix/regexp }'
      else
        postconf 'smtpd_sender_login_maps = texthash:/etc/postfix/virtual, hash:/etc/aliases, pcre:/etc/postfix/maps/sender_login_maps.pcre'
      fi
    fi
  else
    _log 'debug' 'Spoof protection is disabled'
  fi
}
