#!/bin/bash

EntryPoint(){

    #Default Variables
    blank=""
    cseVersionDefault="2.0.2"
    cseIdpProviderDefault="Google"
    cseTakeoutClaim="cse_takeout"
    csePort="443"
    cseJWTAudAuthzKeyDefault="authz"
    cseJWTAudAuthzValueDefault="cse-authorization"
    cseACMUrl="https://api.virtru.com/acm/api"
    cseAccountsUrl="https://api.virtru.com/accounts/api"
    cseUseSSL="true"
    cseAuthnIssuersKeyDefault="https://accounts.google.com"
    cseAuthnIssuersValueDefault="https://www.googleapis.com/oauth2/v3/certs"
    cseAuthzIssuersKeyDefault="gsuitecse-tokenissuer-drive@system.gserviceaccount.com"
    cseAuthzIssuersValueDefault="https://www.googleapis.com/service_accounts/v1/jwk/gsuitecse-tokenissuer-drive@system.gserviceaccount.com"
    cseJWTAudAuthnKeyDefault="authn"
    cseJWTAudAuthnValueDefault="000000000000000000000000000000000.apps.googleusercontent.com"
    cseHMACTokenIdDefault="000000000"
    cseHMACTokenSecretDefault="000000000"
    cksHMACTokenIdDefault="000000000"
    cksHMACTokenSecretDefault="000000000"
    cseServerFqdnDefault="cse-server.example.domain"
    cksServerFqdnDefault="cks.example.domain"
    cseIdpOtherInputAuthnDefault="Now"




    #Final Variables
    cseVersion=""
    cseIdpProvider=""
    cseAuthnIssuersKey=""
    cseAuthnIssuersValue=""
    cseJWKSAuthnIssuers=""
    cseAuthzIssuersKey=""
    cseAuthzIssuersValue=""
    cseJWKSAuthzIssuers=""
    cseJWTAudAuthnKey=""
    cseJWTAudAuthnValue=""
    cseJWTAudAuthzKey=""
    cseJWTAudAuthzValue=""
    cseJWTAud=""
    cseHMACTokenId=""
    cseHMACTokenSecret=""
    cksHMACTokenId=""
    cksHMACTokenSecret=""
    cseServerFqdn=""
    cksServerFqdn=""
    cseIdpOtherInputAuthn=""

    #Actions
    ShowLogo
    GetCseVersion $cseVersionDefault
    GetCseDomain $cseServerFqdnDefault
    GetCseHmacId $cseHMACTokenIdDefault
    GetCseHmacSecret $cseHMACTokenSecretDefault
    GetCksDomain $cksServerFqdnDefault
    GetCksHmacId $cksHMACTokenIdDefault
    GetCksHmacSecret $cksHMACTokenSecretDefault
    GetIdpProvier $cseIdpProviderDefault
    if [ "$cseIdpProvider" = "Google" ]; then
        GetGoogleAuthString $cseJWTAudAuthnValueDefault
    else
        InputAuthnNowLater $cseIdpOtherInputAuthnDefault
        if [ "$cseIdpOtherInputAuthn" = "Now" ]; then
            GetAuthnIssuersKey $cseAuthnIssuersKeyDefault 
            GetAuthnIssuersValue $cseAuthnIssuersValueDefault
            GetJWTAudAuthn $cseJWTAudAuthnValueDefault
        fi  
        
    fi

    MakeDirectories
    GenerateB64Variables
    MakeEnv
    MakeRunScript
    clear
    ShowLogo
    ShowNextSteps
}



    GetCseVersion(){
        local input=""
        read -p "CSE Version [$1]: " input


        case "$input" in
            $blank )
                cseVersion=$1
            ;;
            * )
                cseVersion=$input
            ;;
        esac
        echo " "
    }

    GetIdpProvier(){
        local input=""
        echo "IDP Provider"
        echo "  Options"
        echo "  1 - Google"
        echo "  2 - Other"
        echo " "
        read -p "Enter 1-2 [$1]: " input


        case "$input" in
            $blank )
                cseIdpProvider=$cseIdpProviderDefault
                cseAuthnIssuersKey="\"$cseAuthnIssuersKeyDefault\""
                cseAuthnIssuersValue="\"$cseAuthnIssuersValueDefault\""
                cseAuthzIssuersKey="\"$cseAuthzIssuersKeyDefault\""
                cseAuthzIssuersValue="\"$cseAuthzIssuersValueDefault\""
                cseJWTAudAuthnKey="\"$cseJWTAudAuthnKeyDefault\""
                cseJWTAudAuthzKey="\"$cseJWTAudAuthzKeyDefault\""
                cseJWTAudAuthzValue="\"$cseJWTAudAuthzValueDefault\""
            ;;
            1 )
                cseIdpProvider=$cseIdpProviderDefault
                cseAuthnIssuersKey="\"$cseAuthnIssuersKeyDefault\""
                cseAuthnIssuersValue="\"$cseAuthnIssuersValueDefault\""
                cseAuthzIssuersKey="\"$cseAuthzIssuersKeyDefault\""
                cseAuthzIssuersValue="\"$cseAuthzIssuersValueDefault\""
                cseJWTAudAuthnKey="\"$cseJWTAudAuthnKeyDefault\""
                cseJWTAudAuthzKey="\"$cseJWTAudAuthzKeyDefault\""
                cseJWTAudAuthzValue="\"$cseJWTAudAuthzValueDefault\""
            ;;
            2 )
                cseIdpProvider="Other"
                cseAuthzIssuersKey="\"$cseAuthzIssuersKeyDefault\""
                cseAuthzIssuersValue="\"$cseAuthzIssuersValueDefault\""
                cseJWTAudAuthnKey="\"$cseJWTAudAuthnKeyDefault\""
                cseJWTAudAuthzKey="\"$cseJWTAudAuthzKeyDefault\""
                cseJWTAudAuthzValue="\"$cseJWTAudAuthzValueDefault\""
            ;;
            * )
                cseIdpProvider=$input
                cseAuthzIssuersKey="\"$cseAuthzIssuersKeyDefault\""
                cseAuthzIssuersValue="\"$cseAuthzIssuersValueDefault\""
                cseJWTAudAuthnKey="\"$cseJWTAudAuthnKeyDefault\""
                cseJWTAudAuthzKey="\"$cseJWTAudAuthzKeyDefault\""
                cseJWTAudAuthzValue="\"$cseJWTAudAuthzValueDefault\""
            ;;
        esac
        echo " "    


    }



    #Write Directory Structure
    MakeDirectories(){
        mkdir -p /var/virtru/cse
        mkdir -p /var/virtru/cse/ssl
    }


    GenerateB64Variables(){
        #Authz Issuers
        cseJWKSAuthzIssuers="{ ${cseAuthzIssuersKey}: $cseAuthzIssuersValue }"
        cseJWKSAuthzIssuers=$(echo $cseJWKSAuthzIssuers | base64 -w 0)


        #Authn Issuers
        if [ -n "${cseAuthnIssuersKey}" ]; then
            cseJWKSAuthnIssuers="{ $cseAuthnIssuersKey: $cseAuthnIssuersValue }"
            cseJWKSAuthnIssuers=$(echo $cseJWKSAuthnIssuers | base64 -w 0)
            
            #JWT Aud Variable
            cseJWTAud="{ $cseJWTAudAuthnKey: $cseJWTAudAuthnValue, $cseJWTAudAuthzKey: $cseJWTAudAuthzValue }"
            cseJWTAud=$(echo $cseJWTAud | base64 -w 0)

        else
            cseJWKSAuthnIssuers=""
        fi
        


    }

    GetCseHmacId(){
        local input=""
        read -p "Enter your CSE HMAC ID [$1]: " input


        case "$input" in
            $blank )
                cseHMACTokenId=$1
            ;;
            * )
                cseHMACTokenId=$input
            ;;
            esac
            echo " "
    }


    GetCseHmacSecret(){
        local input=""
        read -p "Enter your CSE HMAC Secret [$1]: " input


        case "$input" in
            $blank )
                cseHMACTokenSecret=$1
            ;;
            * )
                cseHMACTokenSecret=$input
            ;;
            esac
            echo " "
    }


    GetCksHmacId(){
        local input=""
        read -p "Enter your CKS HMAC ID [$1]: " input


        case "$input" in
            $blank )
                cksHMACTokenId=$1
            ;;
            * )
                cksHMACTokenId=$input
            ;;
            esac
            echo " "
    }


    GetCksHmacSecret(){
        local input=""
        read -p "Enter your CKS HMAC Secret [$1]: " input


        case "$input" in
            $blank )
                cksHMACTokenSecret=$1
            ;;
            * )
                cksHMACTokenSecret=$input
            ;;
            esac
            echo " "
    }

    GetCseDomain(){
        local input=""
        read -p "CSE Domain [$1]: " input




        case "$input" in
            $blank )
                cseServerFqdn="https://$1"
            ;;
            * )
                cseServerFqdn="https://$input"
            ;;
        esac
        echo " "
    }


    GetCksDomain(){
        local input=""
        read -p "CKS Domain [$1]: " input




        case "$input" in
            $blank )
                cksServerFqdn="https://$1"
            ;;
            * )
                cksServerFqdn="https://$input"
            ;;
        esac
        echo " "
    }
    
    GetGoogleAuthString(){
        local input=""
        read -p "Enter your Google OAuth Client ID String [$1]: " input




        case "$input" in
            $blank )
                cseJWTAudAuthnValue="\"$1\""
            ;;
            * )
                cseJWTAudAuthnValue="\"$input\""
            ;;
        esac
        echo " "
    }

    GetAuthnIssuersKey(){
        local input=""
        read -p "Enter your AuthN Key [$1]: " input




        case "$input" in
            $blank )
                cseAuthnIssuersKey="\"$1\""
            ;;
            * )
                cseAuthnIssuersKey="\"$input\""
            ;;
        esac
        echo " "
    }
    
    GetAuthnIssuersValue(){
        local input=""
        read -p "Enter your AuthN Value [$1]: " input




        case "$input" in
            $blank )
                cseAuthnIssuersValue="\"$1\""
            ;;
            * )
                cseAuthnIssuersValue="\"$input\""
            ;;
        esac
        echo " "
    }
    
    
    GetJWTAudAuthn(){
        local input=""
        read -p "Enter your JWT AuthN Value [$1]: " input




        case "$input" in
            $blank )
                cseJWTAudAuthnValue="\"$1\""
            ;;
            * )
                cseJWTAudAuthnValue="\"$input\""
            ;;
        esac
        echo " "
    }
    
    
    InputAuthnNowLater(){
        local input=""
        echo "Enter AuthN Now?"
        echo "  Options"
        echo "  1 - Now"
        echo "  2 - Later"
        echo " "
        read -p "Enter AuthN now or later? [$1]: " input




        case "$input" in
            $blank )
                cseIdpOtherInputAuthn="$1"
            ;;
            1 )
                cseIdpOtherInputAuthn="Now"
            ;;
            2 )
                cseIdpOtherInputAuthn="Later"
            ;;
            * )
                cseIdpOtherInputAuthn="$input"
            ;;
        esac
        echo " "
    }

    MakeEnv(){
        envFile=/var/virtru/cse/cse.env








        /bin/cat <<EOM >$envFile
    
HMAC_TOKEN_ID=$cseHMACTokenId
HMAC_TOKEN_SECRET=$cseHMACTokenSecret
CKS_HMAC_TOKEN_ID=$cksHMACTokenId
CKS_HMAC_TOKEN_SECRET=$cksHMACTokenSecret
JWKS_AUTHN_ISSUERS=$cseJWKSAuthnIssuers
JWKS_AUTHZ_ISSUERS=$cseJWKSAuthzIssuers
JWT_AUD=$cseJWTAud
JWT_KACLS_URL=$cseServerFqdn
TAKEOUT_CLAIM=cse_takeout
ACM_URL=https://api.virtru.com/acm/api
ACCOUNTS_URL=https://api.virtru.com/accounts/api
CKS_URL=$cksServerFqdn
PORT=443
USE_SSL=true
        
EOM

    }




    MakeRunScript(){
        runScript=/var/virtru/cse/run.sh



        /bin/cat <<EOM >$runScript

docker run --detach \\
--env-file ./cse.env \\
-p 443:443 \\
-v /var/virtru/cse/server.cert:/run/secrets/server.cert \\
-v /var/virtru/cse/server.key:/run/secrets/server.key \\
--restart unless-stopped \\
--name cse-$cseVersion \\
virtru/cse:v$cseVersion


EOM

chmod +x $runScript

    }



    
    ShowLogo() {
    echo " "
    echo "                      +++                '++."
    echo "                      +++                ++++"
    echo "                                         ++++"
    echo "     ,:::      +++    +++     :+++++++   +++++++    .+++++++   .++     '++"
    echo "     ++++     .+++.  '+++    ++++++++++  ++++++++  ++++++++++  ++++    ++++"
    echo "     ++++     ++++   ++++    +++++''++   +++++++   +++++++++   ++++    ++++"
    echo "     ++++   .++++    ++++    ++++        ++++      ++++        ++++    ++++"
    echo "     ++++  .++++     ++++    ++++        ++++      ++++        ++++    ++++"
    echo "     ++++ ++++       ++++    ++++        ++++      ++++        ++++    ++++"
    echo "     ++++++          ;+++    ++++        ++++      ++++          ++++++++"
    echo "     ++++             +++     ++'         ++        ++'           .++++"
    echo " "
    echo "   S   i   m   p   l   e      E   m   a   i   l      P   r   i   v   a   c   y"
    echo " "
    echo " "








    }

    ShowNextSteps() {
        echo "next steps"
        echo "-----------------------"
        echo " Deploy Successful!"
        echo " Next Steps:"
        echo " "
        echo " run: cd /var/virtru/cse"
        echo " add: ssl certificate information"
        if [ "$cseIdpOtherInputAuthn" != "Now" ]; then
            echo " add: base64 encoded AuthN values and base64 encoded JWT_AUD value"
        fi
        echo " run: sh run.sh"
        echo "-----------------------"
    }


clear
EntryPoint