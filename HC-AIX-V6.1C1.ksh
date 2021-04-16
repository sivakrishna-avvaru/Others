####################################################################################################
#                                        HC-AIX-V6.1C.ksh               	                  	   #
# 			Script for Health Check on AIX servers               	                   #
# 			Developped by: G Pavani Soumya (pavaniga@in.ibm.com)                       #
#                                                                                                  #
####################################################################################################

#!/usr/bin/ksh

ScriptName="HC-AIX-V6.1C.ksh"
Account="Honda-India"
Description="Script is for Health Check on AIX servers"
Author="G Pavani Soumya"
Version="6.1"
ReleaseDate="30th-April-2020"

header_info()
{
	echo "#################################"
	echo "Script       : 	$ScriptName"
	echo "Version      : 	$Version"
	echo "Description  : 	$Description"
	echo "Developed by : 	$Author"
	echo "Released on  : 	$ReleaseDate"  
	echo "#################################"
}

account_info()
{
	echo "###################################"
	printf "ACCOUNT: %50s\n" $Account
	printf "Customization_Date: %50s\n" $ReleaseDate
	printf "SCAN-VERSION: %50s" $Version
	echo "###################################"
}

Delay()
{
	sleep $1
}

account_info > `hostname`_unifermhc.csv

# Password Requirements Section

echo "Script is executing Password Requirements parameters"

printf "%30s\n" "TEST" >p1
printf "%30s\n" "PARAMETER" >p2
printf "%30s\n" "CURRENT_VALUE" >p3
z=`hostname`
printf "%30s\n" "SECTION-D" >p12
printf "%30s\n" "HOST-NAME" >p6
printf "%30s\n" "TEST-PASSED" >p4
printf "%30s\n" "SCAN-DATE" >p5
printf "%30s\n" "IP-ADDRESS" >en2

c=`date | awk '{print $1"-"$2"-"$3"-"$6}'`

z=`hostname`
ipAddress=`lsattr -El en0 -a netaddr | awk '{print $2}'`



cat /etc/passwd | awk -F":" '{print $1}' > temp_uid
sort temp_uid | uniq -d > temp_uid1
sp=`cat temp_uid1 | wc -c`
if [ $sp == 0 ]
then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "UID" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "No_duplicate_userid_found" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.1.0" >>p12
else
	for i in `cat temp_uid1`
	do
		printf "%30s\n" "Password_requirements" >>p1
                printf "%30s\n" "UID" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "Duplicate_user_id_exist_for_$i" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.1.0" >>p12
	done
fi

cat /etc/group | awk -F":" '{print $3}' > temp_gid
sort temp_gid | uniq -d > temp_gid1
sa=`cat temp_gid1 | wc -c`
if [ $sa == 0 ]
then
                printf "%30s\n" "Password_requirements" >>p1
                printf "%30s\n" "gid_validation" >>p2
		printf "%30s\n" "$ipAddress" >>en2
                printf "%30s\n" "no-duplicate-values_found_in_/etc/goup" >>p3
                printf "%30s\n" "yes" >>p4
                printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.1.1" >>p12

else
	for i in `cat temp_gid1`
	do
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "gid_validation-duplicate-value" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "Duplicate_group_exist_for_$i" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.1.1" >>p12
	done
fi

res=`cat /etc/security/user | grep -p default: | grep -i maxage | awk -F= '{print $2}'`
if [ $res == 13 ]
then
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "default_maxage" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "maxage = $res" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.2.1" >>p12
else
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "default_maxage" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "maxage = $res" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.2.1" >>p12
fi



cat /etc/passwd | awk -F":" '{print $1}' > temp_users 
while IFS= read -r line
do
	sz=`lsuser -a maxage $line | awk -F"=" '{print $2}'`
	if [ $sz == 13 ]
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "max_age" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$line=$sz" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.2.2" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "max_age" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$line=$sz" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.2.2" >>p12
	fi
done < temp_users 


cat /etc/passwd | awk -F":" '{print $1}' > temp_users
while IFS= read -r line
do
	sz=`lsuser -a histexpire $line | awk -F"=" '{print $2}'`
	if [ $sz == 105 ] 
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/passwd" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "histexpire" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.3.2" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/passwd" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "histexpire" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.3.2" >>p12
	fi
done < temp_users > /dev/null 2>&1



cat /etc/passwd | awk -F":" '{print $1}' > temp_users1
while IFS= read -r line
do
	sz1=`lsuser -a minage $line | awk -F"=" '{print $2}'`
	if [ $sz1 == 1 ]
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "min_age" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$line=$sz1" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.3.1" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "min_age" >>p2
		printf "%30s\n" "$ipAddress" >>en2
	        printf "%30s\n" "$line=$sz1" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.3.1" >>p12
	fi
done < temp_users1 > /dev/null 2>&1

res=`cat /etc/security/user | grep -p default: | grep "minalpha" | awk -F"=" '{print $2}'`
if [ $res == 1 ]
then
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "minalpha" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "minalpha=$res" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.4" >>p12
else
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "minalpha" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "$line=$res" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.4" >>p12
fi

res=`cat /etc/security/user | grep -p default: | grep "minother" | awk -F"=" '{print $2}'`
if [ $res == 1 ]
then
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "minother" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "minother=$res" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.5.0" >>p12
else
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "minother" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "minother=$res" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.5.0" >>p12
fi

version=`uname -v`
if [ $version -ge 7 ]
then
	if [ -f /usr/share/dict/words ]
	then
		while IFS= read -r line
		do
			cat /usr/share/dict/words | grep -p $line	
			if [ $? -eq 0 ]
			then
				printf "%30s\n" "Password_requirements" >>p1
				printf "%30s\n" "/usr/share/dict/words" >>p2
				printf "%30s\n" "$ipAddress" >>en2
				printf "%30s\n" "$line_exist_in_/usr/share/dict/words" >>p3
				printf "%30s\n" "$c" >> p5
				printf "%30s\n" "$z" >>p6
				printf "%30s\n" "yes" >>p4
				printf "%30s\n" "E.1.1.5.1" >>p12
			else
				printf "%30s\n" "Password_requirements" >>p1
				printf "%30s\n" "/usr/share/dict/words" >>p2
				printf "%30s\n" "$ipAddress" >>en2
				printf "%30s\n" "$line_doesnot_exist_in_/usr/share/dict/words" >>p3
				printf "%30s\n" "$c" >> p5
				printf "%30s\n" "$z" >>p6
				printf "%30s\n" "no" >>p4
				printf "%30s\n" "E.1.1.5.1" >>p12
			fi
		done <temp_users1 > /dev/null 2>&1
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/usr/share/dict/words" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "/usr/share/dict/words_doesnot_exist" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "N/A" >>p4
		printf "%30s\n" "E.1.1.5.1" >>p12
	fi
fi


version=`uname -v`
if [ $version -ge 7 ]
then
	cat /etc/security/user | grep -p default: | grep -i "dictionlist = /usr/share/dict/words"	
	if [ $? -eq 0 ]
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/security/user" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "dictionlist=/usr/share/dict/words" >>p3
		printf "%30s\n" "$c" >> p5
	        printf "%30s\n" "$z" >>p6
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "E.1.1.5.2" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/security/user" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "dictionlist_doesnt_exist" >>p3
		printf "%30s\n" "$c" >> p5
	        printf "%30s\n" "$z" >>p6
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "E.1.1.5.2" >>p12
	fi
fi


version=`uname -v`
if [ $version -ge 7 ]
then
	if [ -f /usr/share/dict/words ]
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/usr/share/dict/words" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "/usr/share/dict/words_exist" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "E.1.1.5.3" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/usr/share/dict/words" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "/usr/share/dict/words_doesnot_exist" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "E.1.1.5.3" >>p12
	fi
fi


res=`cat /etc/security/user | grep -p default: | grep "minlen" | awk -F"=" '{print $2}'`
if [ $res == 8 ]
then
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "minlen" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "minlen=$res" >>p3
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "E.1.1.6.0" >>p12
else
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "minlen" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "minlen=$res" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.6.0" >>p12
fi


zks=`cat  /etc/security/login.cfg | grep -p "usw" | grep "pwd_algorithm = " | egrep 'ssha512|ssha256|ssha1|smd5' | awk -F"=" '{print $2}'`
cat  /etc/security/login.cfg | grep -p "usw" | grep "pwd_algorithm = " | egrep 'ssha512|ssha256|ssha1|smd5' > /dev/null 2>&1
if [ $? == 0 ]
then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "usw" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "pwd_algorithm=$zks" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.6.1" >>p12
else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "usw" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "value_not_found_for_pwd_algorithm" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.6.1" >>p12
fi

while IFS= read -r line
do
	sk=`cat /etc/security/passwd | grep -p $line | grep -w "password" |awk -F"=" '{print $2}'| wc -c`		
	if [ $sk -gt 0 ]
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/security/passwd" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "password_attribute_is_not_null_for_$line" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "E.1.1.6.2" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/security/user" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "password_attribute_isnull_for_$line" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "E.1.1.6.2" >>p12
	fi
done <temp_users1 > /dev/null 2>&1



while IFS= read -r line
do
	res=`cat /etc/passwd | grep $line | awk -F":" '{print $2}' | wc -c`
	if [ $res == 1 ]
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/passwd" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "second_field_of_/etc/passwd_is_null_for_$line" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "E.1.1.6.3" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/passwd" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "second_field_of_/etc/passwd_is_not_null_for_$line" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "E.1.1.6.3" >>p12
	fi
done <temp_users1 > /dev/null 2>&1


while IFS= read -r line
do	
	sk=`lsuser -a mindiff $line | awk -F= '{print $2}'`			
	if [ $sk == 4 ]
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/security/user" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "mindiff_is_set_for_$line" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "E.1.1.7.2" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/security/user" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "mindiff_is_not_set_for_$line" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "E.1.1.7.2" >>p12
	fi
done <temp_users1 > /dev/null 2>&1


while IFS= read -r line
do
	cat /etc/security/passwd | grep -p $line | grep password | awk -F"=" '{print $2}'
	if [ $? == 0 ]
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/security/passwd" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "password_is_*_for_$line" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "E.1.1.17.1" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/security/user" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "password_is_not_*_for_$line" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "E.1.1.17.1" >>p12
	fi
done <temp_users1 > /dev/null 2>&1

cat /etc/passwd | awk -F":" '{print $1}' > temp_users1

while IFS= read -r line
do
	sk=`cat /etc/security/passwd | grep -p $line | grep -w "flags=NOCHECK"`	
	if [ "$sk" -ne 0 ]
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/security/passwd" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "flags=NOCHECK_for_$line" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "E.1.1.8" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "/etc/security/user" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "flags=NOCHECK_is_set_for_$line" >>p3
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "E.1.1.8" >>p12
	fi
done <temp_users1 > /dev/null 2>&1


sz5=`cat /etc/security/user | grep -p default: | grep "loginretries" | awk -F"=" '{print $2}'`
if [ $sz5 -eq 5 ]
then
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "login-retries" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "$line=$sz5" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.9" >>p12
else
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "login-retries" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "$line=$sz5" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.9" >>p12
fi


szl=`lsuser -a maxage root| awk '{print $2}' | awk -F"=" '{print $2}'`
if [ $szl -eq 0 ]
then
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "root-passwd-is_set_to_non-expiry" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "$szl"  >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.10.1" >>p12
	
else
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "root-passwd-is_set_to-expiry" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "$szl" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.10.1" >>p12
fi


res=`cat /etc/ssh/sshd_config| grep -i "^PermitRootLogin" | awk '{print $2}'`
if [ $res == "false" ]
then
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "default_remote_access" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "remote_login_is_disabled" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.10.2" >>p12
else
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "default_remote_access" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "remote_login_is_enabled" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.10.2" >>p12
fi

cat /etc/passwd | egrep -v "/usr/bin/ksh|/usr/bin/rksh|/usr/bin/psh|/usr/bin/tsh|/usr/bin/csh|/bin/ksh|/bin/rksh|/bin/psh|/bin/tsh|/bin/csh|/bin/sh|/usr/bin/sh|/bin/false|/usr/bin/false" >list-shell-info
if [ -f list-shell-info ]
then
	for i in `cat list-shell-info`
	do
		printf "%30s\n" "system_settings" >>p1
		printf "%30s\n" "login_shell" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$i | awk -F":" '{print $1"login_shell_value_value_is_valid"$7}'" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.10.1.4.10" >>p12
	done
else 	
	printf "%30s\n" "system_settings" >>p1
	printf "%30s\n" "login_shell" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "$i | awk -F":" '{print $1"login_shell_value_invalid_current_value_is"$7}'" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.10.1.4.10" >>p12
fi
rm -rf list-shell-info

cat /etc/passwd | grep -i "/bin/false" >list-shell-info
if [ -f list-shell-info ]
then
	for i in `cat list-shell-info`
	do
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "direct_or_remote_login" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$i | awk -F":" '{print $1 "allowed_to_have_non_expiring_passsword"}'" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.18.0" >>p12
	done
else 	
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "direct_or_remote_login" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "$i | awk -F":" '{print $1 "not allowed_to_have_non_expiring_passsword"}'" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.18.0" >>p12
fi
rm -rf list-shell-info 
 
cat /etc/passwd | grep -i "/bin/false" >list-shell-info
if [ -f list-shell-info ]
then
	for i in `cat list-shell-info`
	do
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "direct_or_remote_login" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$i | awk -F":" '{print $1"login_shell_value_valid_current_value_is"$7}'" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.18.1" >>p12
	done
else 	
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "direct_or_remote_login" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "$i | awk -F":" '{print $1"login_shell_value_invalid_current_value_is"$7}'" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.18.1" >>p12
fi
rm -rf list-shell-info

# Logging Section

echo "Script is executing Logging parameters"
if [ -f /var/adm/wtmp ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/var/adm/wtmp" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FILE-EXIST" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.1" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/var/adm/wtmp" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FILE-DOESNT-EXIST" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.1" >>p12
fi

if [ -f /var/adm/sulog ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/var/adm/sulog" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FILE-EXIST" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.2" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/var/adm/sulog" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FILE-DOESNT-EXIST" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.2" >>p12
fi

if [ -f /etc/security/failedlogin ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/failedlogin" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FILE-EXIST" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.3" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/failedlogin" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FILE-DOESNT-EXIST" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.3" >>p12
fi

res=`cat /etc/syslog.conf |grep -i "rotate time" | awk '{print $6}' | sed 's/.$//'`
if [ "$res" == 90 ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/syslog.conf" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "Log_record_retention_time_frame-$res" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.4" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/syslog.conf" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "Log_record_retention_time_frame-$res" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.4" >>p12
fi

if [ -f /var/adm/secure ] || [ -f /var/log/secure ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/var/adm/secure" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FILE-EXIST" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.5.4" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/var/log/secure" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FILE-DOESNT-EXIST" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.5.4" >>p12
fi

lssrc -ls xntpd | grep "active" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/syslog.conf" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "Synchronized_clocks_active_service_is_active" >>p3
	printf "%30s\n" "yes">>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.6.1/E.1.2.6.2" >>p12	
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/syslog.conf" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "Synchronized_clocks_active_service_is_not_active" >>p3
	printf "%30s\n" "no">>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.6.1/E.1.2.6.2" >>p12
fi
	
cat /etc/syslog.conf | egrep -i "auth.info /var/adm/messages |auth.debug /var/log/messages" > /dev/null 2>&1 
if [ $? -eq 0 ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/syslog.conf" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "auth.info(or)auth.debug_should_exist_in_/etc/syslog.conf" >>p3
	printf "%30s\n" "yes">>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.5.1" >>p12	
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/syslog.conf" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "auth.info(or)auth.debug_should_exist_in_/etc/syslog.conf" >>p3
	printf "%30s\n" "no">>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.5.1" >>p12
fi

cat /etc/syslog.conf | egrep -i "authpriv.info /var/adm/secure|authpriv.debug /var/log/secure" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/syslog.conf" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "authpriv.info(or)authpriv.debug_should_exist_in_/etc/syslog.conf" >>p3
	printf "%30s\n" "yes">>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.5.3" >>p12	
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/syslog.conf" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "authpriv.info(or)authpriv.debug_should_exist_in_/etc/syslog.conf" >>p3
	printf "%30s\n" "no">>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.5.3" >>p12
fi

#fs_f1()
#{
 #       local VarName="$1"
  #      local IFS="$2"
   #     eval a\=\(${!VarName}\)
    #    eval VarName\=\(${!VarName}\)
#}

fs_f1()
{
local VarName="$1"
local IFS="$2"
eval a\=${VarName}
eval VarName\=${VarName}
}

password_set(){
        fs_list="daemon, bin, sys, adm, uucp, nuucp, lpd, imnadm, ipsec, ldap, lp, snapp, invscout, pconsole, nobody "
       fs_f1 "fs_list" ","
	cat /etc/passwd | awk -F":" '{print $1"_"$2}' > psw_temp
	for i in "${fs_list[@]}"
	do
		sk=`grep -i $i psw_temp`
		sc=`echo $sk | awk -F"_" '{print $2}'` 
		if [ $sc -ne '*' ]
		then
			printf "%30s\n" "Password_requirements" >>p1
			printf "%30s\n" "/etc/passwd" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "password_not_set_for_systemid_$i" >> p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
                        printf "%30s\n" "$z" >>p6	
			printf "%30s\n" "E.1.1.10.3" >>p12
		else
			printf "%30s\n" "Password_requirements" >>p1
			printf "%30s\n" "/etc/passwd" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "password_flag_set_for_system_id_$i" >> p3
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
               		printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.1.1.10.3" >>p12
		fi
	done
}
while true;do password_set;break;done



str="E.1.1.14.0/E.5.0.3.0/E.5.0.3.1/E.5.0.3.2/E.5.0.3.3/E.5.0.3.4/E.5.0.3.5/E.5.0.3.6/E.5.0.3.7/E.5.0.3.8/E.5.0.3.9/E.5.0.3.10/E.5.0.3.11/E.5.0.3.12/E.5.0.3.13/E.5.0.3.14/E.5.0.3.15/E.5.0.3.16/E.5.0.3.16/E.5.0.4.0/E.5.0.4.1/E.5.0.4.2/E.5.0.4.3/E.5.0.4.4/E.5.0.4.5/E.5.0.4.6/E.5.0.4.7/E.5.0.4.8/E.5.0.4.9/E.5.0.4.10/E.5.0.4.11/E.5.0.4.12/E.5.0.4.13/E.5.0.4.14/E.5.0.4.15/E.5.0.4.16/E.5.0.4.17/E.5.0.4.18/E.5.0.4.19/E.5.0.4.20"

echo "adm,bin,daemon,imnadm,invscout,ipsec,ldap,lp,lpd,nuucp,root,snapp,sys,uucp,pconsole,esaadmin,srvproxy,group ids,adm,audit,bin,cron,ecs,hacmp,haemrm,imnadm,ipsec,ldap,lp,mail,pconsole,printq,security,shutdown,snapp,sys,system,uucp" > list-check
tr "," "\n" < list-check > list-check1
while IFS= read -r line
do
	slp=`cat /etc/passwd | grep -w "^$line" | awk -F":" '{print $2}'`
	if [ $? -eq 0 ]
	then
	#	cat /etc/passwd | grep -w "^$line" | awk -F":" '{print $2}'
		if [ "$slp" != '*' ] 
		then
			ntr=`lsuser -a maxage $line | awk '{print $2}' | awk -F"=" '{print $2}'`
			if [ "$ntr" == 0 ]
			then
				printf "%30s\n" "password-requirements" >>p1
				printf "%30s\n" "maxage_value_shouldnt_be_zero" >>p2
				printf "%30s\n" "$ipAddress" >>en2
				printf "%30s\n" "$line=$ntr" >>p3
				printf "%30s\n" "no" >>p4
				printf "%30s\n" "$c" >>p5
				printf "%30s\n" "$z" >>p6
				printf "%30s\n" "$str" >>p12
			else
				printf "%30s\n" "password-requirements" >>p1
				printf "%30s\n" "maxage_is_not_zero_for_$line" >>p2
				printf "%30s\n" "$ipAddress" >>en2
				printf "%30s\n" "$line=$ntr" >>p3
				printf "%30s\n" "yes" >>p4
				printf "%30s\n" "$c" >>p5
				printf "%30s\n" "$z" >>p6
				printf "%30s\n" "$str" >>p12
			fi
		else
			printf "%30s\n" "password-requirements" >>p1
			printf "%30s\n" "maxage_value_shouldnt_be_zero" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "passwd_is_set_for_$line" >>p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >>p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "$str" >>p12
		fi
	fi
done < list-check1 > /dev/null 2>&1


`cat /etc/passwd | awk -F":" '{print $1}' > ulist`
cat ulist
while IFS= read -r line
do
	slp=`cat /etc/passwd | grep -w "^$line" | awk -F":" '{print $2}'`
	cat /etc/passwd | grep -w "^$line" | awk -F":" '{print $2}'
	if [ $slp -eq '*' ]
	then
		ntr=`lsuser -a maxage $line | awk '{print $2}' | awk -F"=" '{print $2}'`
		if [ $ntr -eq 0 ]
		then
			printf "%30s\n" "password-requirements" >>p1
			printf "%30s\n" "maxage_value_can_be_zero_if_id_has_password_not_set" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "$line=$ntr" >>p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >>p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.1.1.14.1" >>p12
		else
			printf "%30s\n" "password-requirements" >>p1
			printf "%30s\n" "maxage_value_cannot_be_zero_if_id_has_password_set" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "$line=$ntr" >>p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >>p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.1.1.14.1" >>p12
		fi
	else
		printf "%30s\n" "password-requirements" >>p1
		printf "%30s\n" "id_password_has_set" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$line=$slp" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.14.1" >>p12
	fi

done < ulist
rm ulist

cat /etc/passwd | awk -F":" '{print $1}'> pasd_usr
while IFS= read -r line
do
	szm=`cat /etc/passwd | grep -w "^$line" | awk -F":" '{print $2}'`   
	if [ "$szm" == '*' ]
	then
		cat /etc/security/user | grep -p $line: | grep -i maxage | awk -F= '{print $2}' > /dev/null 2>&1
		if [ $? -eq 0 ] 
		then
			printf "%30s\n" "Password_requirements" >>p1
			printf "%30s\n" "$line-Exemption_to_passwords_rules" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "maxage = $?" >>p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.1.1.16.0" >>p12
		else
			printf "%30s\n" "Password_requirements" >>p1
			printf "%30s\n" "$line-no_Exemptions_to_passwords_rules" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "maxage = $?" >>p3
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.1.1.16.0" >>p12
		fi
	else	
		printf "%30s\n" "password-requirements" >>p1
		printf "%30s\n" "$line-not_allowed_to_have_non_expiring_passwords" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "maxage" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.16.0" >>p12
	fi
done <pasd_usr > /dev/null 2>&1

	
cat /etc/passwd | awk -F":" '{print $1}'> pasd_usr
while IFS= read -r line
do
	szm=`cat /etc/passwd | grep -w "^$line" | awk -F":" '{print $2}'`   
	if [ "$szm" == '*' ]
	then
		printf "%30s\n" "password-requirements" >>p1
		printf "%30s\n" "password-not-set" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$line=$szm" >> p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.16.1/E.1.1.17.0" >>p12
	else	
		printf "%30s\n" "password-requirements" >>p1
		printf "%30s\n" "password-set" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$line=$szm" >> p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.16.1/E.1.1.17.0" >>p12
	fi
done <pasd_usr > /dev/null 2>&1

grep -i "^ftp" /etc/inetd.conf > /dev/null 2>&1
if [ $? -eq 0 ]
then
	while IFS= read -r line
	do
		f=`cat /etc/ftpusers | grep -i $line`
		if [ $? -ne 0 ]
		then
				printf "%30s\n" "password-requirements" >>p1
				printf "%30s\n" "no_entry_of_user_$line _in_the_file_/etc/ftpusers" >> p3
				printf "%30s\n" "$ipAddress" >>en2
				printf "%30s\n" "/etc/ftpusers" >>p2
				printf "%30s\n" "no" >> p4				
				printf "%30s\n" "$c" >> p5
				printf "%30s\n" "$z" >>p6
				printf "%30s\n" "E.1.1.11/E.1.1.15.3" >>p12
		else
				printf "%30s\n" "password-requirements" >>p1
				printf "%30s\n" "$line-id-exist-in-/etc/ftpusers" >>p3
				printf "%30s\n" "$ipAddress" >>en2
				printf "%30s\n" "/etc/ftpusers" >>p2
				printf "%30s\n" "yes" >> p4
				printf "%30s\n" "$c" >> p5
				printf "%30s\n" "$z" >>p6
				printf "%30s\n" "E.1.1.11/E.1.1.15.3" >>p12
		fi
		done <list-check1 > /dev/null 2>&1


else
	printf "%30s\n" "password-requirements" >>p1
	printf "%30s\n" "ftpd_service_check" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "ftpd_service_is_disabled" >> p3
	printf "%30s\n" "yes" >> p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.11/E.1.1.15.3" >>p12

fi


cat /etc/passwd | awk -F":" '{print $1}' > temp_users
while IFS= read -r line
do
	sz=`lsuser -a maxage $line | awk -F"=" '{print $2}'`
	if [ $sz -eq 0 ]
	then
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "$line-allowed_to_non-expiring_password" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$line=$sz" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.15.0" >>p12
	else
		printf "%30s\n" "Password_requirements" >>p1
		printf "%30s\n" "$line-not_allowed_to_non-expiring_password" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$line=$sz" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.15.0" >>p12
	fi
done < temp_users > /dev/null 2>&1

while IFS= read -r line
do
res=`lsuser -a login $line | awk -F= '{print $2}'` 
if [ "$res" == "false" ]
then
		printf "%30s\n" "password-requirements" >>p1
		printf "%30s\n" "Direct-login" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "login=false" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.15.1" >>p12
else
		printf "%30s\n" "password-requirements" >>p1
		printf "%30s\n" "Direct-login" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "login=true" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.1.15.1" >>p12
fi
done < list-check1 > /dev/null 2>&1



while IFS= read -r line
do
	res=`lsuser -a rlogin $line | awk -F= '{print $2}'` 
	if [ "$res" == "false" ]
	then
			printf "%30s\n" "password-requirements" >>p1
			printf "%30s\n" "Remote-login" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "rlogin=false" >> p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
		        printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.1.1.15.2" >>p12
	else
			printf "%30s\n" "password-requirements" >>p1
			printf "%30s\n" "Remote-login" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "rlogin=true" >> p3
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
		        printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.1.1.15.2" >>p12
	fi
done < list-check1 > /dev/null 2>&1

# Network Settings

echo "Script is executing Network settings parameters"

if [ -f /etc/snmp.conf ] || [ -f /etc/snmpdv3.conf ]
then
	res=`awk 'BEGIN {IGNORECASE = 1} /community/ && /public/' /etc/snmpd.conf /etc/snmpdv3.conf | wc -c`
	if [ $res -eq 0 ]
	then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "SNMP-Service" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "Community_names_are_not_voilated" >> p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
	        printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.26" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "SNMP-Service" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "Community_names_are_voilated" >> p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
	        printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.26" >>p12
	fi
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "SNMP-Service" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "SNMP-Service_is_disabled" >> p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.12.26" >>p12
fi


res=`lssrc -a | grep -i yppasswd | awk '{print $3}'`
if [ "$res" == "inoperative" ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "yppasswd-daemon" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "yppasswd_service_is_disabled" >> p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.13" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "yppasswd-daemon" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "yppasswd_service_is_enabled" >> p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.13" >>p12
fi


str="E.1.5.12.1/E.1.5.12.2/E.1.5.12.3/E.1.5.12.4/E.1.5.12.5/E.1.5.1.0/E.1.5.1.1/E.1.5.22.2/E.1.5.22.3/E.1.5.22.4/E.1.5.12.6/E.1.5.12.7/E.1.5.12.8/E.1.5.12.9/E.1.5.12.10/E.1.5.12.11/E.1.5.12.12/E.1.5.12.13/E.1.5.12.14/E.1.5.12.15/E.1.5.12.16/E.1.5.12.17/E.1.5.12.18/E.1.5.12.19/E.1.5.12.20/E.1.5.12.21/E.1.5.12.22/E.1.5.12.23/E.1.5.12.24/E.1.5.12.25/E.1.5.12.26/E.1.5.12.27/E.1.5.12.28/E.1.5.12.29/E.1.5.12.31/E.1.5.12.30/E.1.5.13.1/E.1.5.13.2/E.1.5.13.3/E.1.5.18.0/E.1.5.21/E.1.5.23.1/E.1.5.23.2/E.1.5.23.3/E.1.5.23.4/E.1.5.23.5/E.1.5.23.6/E.1.5.23.7/E.1.5.23.8/E.1.5.23.9/E.1.5.23.10/E.1.5.23.11/E.1.5.23.12/E.1.5.23.13/E.1.5.23.14/E.1.5.23.15/E.1.5.23.16/E.1.5.23.17/E.1.5.23.18/E.1.5.23.19/E.1.5.23.20/E.1.5.23.21/E.1.5.23.22/E.1.5.23.23/E.1.5.23.24/E.1.5.23.25/E.1.5.23.26/E.1.5.23.27/E.1.5.23.28/E.1.5.24.1/E.1.5.26.2/E.1.5.26.3/E.1.5.26.4/E.1.5.7"



fi_name()
{
                local VarName="$1"
                local IFS="$2"
                eval a\=${VarName}
                eval $VarName\=${VarName}

}


file_sys1(){       fs_list="CHARGEN,DAYTIME,DISCARD,ECHO,FINGER,SYSTAT,RWHO,NETSTAT,ftp,CHARGEN,RSTATD,TFTP,RWALLD,RUSERSD,DISCARD,BOOTPS,SPRAYD,PCNFSD,NETSTAT,RWHO,
	 CMSD,DTSPCD,TTDBSERVER,rlogin,rsh,sendmail,exec,time,timed,yppasswd,ypbind,ypserv,nfs,sshd
	 qdaemon,lpd,piobe,dt,snmpd,dhcpcd,dhcprd,dhcpsd,autoconf6,gated,mrouted,named,routed,dpid2,hostmibd,snmpmibd,aixmibd,ndpd-host,ndpd-router,uucp,talk,
	 ntalk,kshell,rquoted,tftp,imap2,pop3,instsrv,httpdlite,pmd,writesrv,syslogd,rexd,telnetd"

        fi_name "fs_list" ","
	for i in "${fs_list[@]}"
	do
		cat /etc/services | grep -i $i > /dev/null 2>&1 
		if [ $? -ne 0 ]
		then
			printf "%30s\n" "network-settings" >>p1
			printf "%30s\n" "disabling-inetd-values" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "$i" >> p3
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
                	printf "%30s\n" "$z" >>p6
			printf "%30s\n" "$str" >>p12
		else
			printf "%30s\n" "network-settings" >>p1
			printf "%30s\n" "disabling-inetd-values" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "$i" >> p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
                	printf "%30s\n" "$z" >>p6
			printf "%30s\n" "$str" >>p12
		fi
	done
}
while true;do file_sys1;break;done

`grep -i ftp /etc/passwd` > /dev/null 2>&1
if [ $? -eq 0 ]
then
	cat /etc/passwd | awk -F":" '{print $6}' > ftp_users
	while IFS= read -r line
	do
		sz=`ls -ld $line | cut -c2,3`
		if [ $sz -eq "rw" ]
		then
			printf "%30s\n" "Password_requirements" >>p1
			printf "%30s\n" "FTP" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "$line=$sz" >>p3
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
		        printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.1.5.14/E.1.5.16" >>p12
		else
			if [ $sz -eq "r" ] || [ $sz -eq "w" ]
			then
				printf "%30s\n" "Password_requirements" >>p1
				printf "%30s\n" "FTP" >>p2
				printf "%30s\n" "$ipAddress" >>en2
				printf "%30s\n" "$line=$sz" >>p3
				printf "%30s\n" "yes" >>p4
				printf "%30s\n" "$c" >> p5
				printf "%30s\n" "$z" >>p6
				printf "%30s\n" "E.1.5.14/E.1.5.16" >>p12
			else
				printf "%30s\n" "Password_requirements" >>p1
				printf "%30s\n" "FTP" >>p2
				printf "%30s\n" "$ipAddress" >>en2
				printf "%30s\n" "$line=$sz" >>p3
				printf "%30s\n" "no" >>p4
				printf "%30s\n" "$c" >> p5
				printf "%30s\n" "$z" >>p6
				printf "%30s\n" "E.1.5.14/E.1.5.16" >>p12
			fi	
		fi
	done < ftp_users > /dev/null 2>&1
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "Anynomous_ftp_is_not_enabled">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.14/E.1.5.16" >>p12
	printf "%30s\n" "$z" >>p6
fi

sc=`ls -ld /tftpboot | awk '{print $3}'`
if [ "$sc" == "root" ]
then	
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "tftpboot-directory">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "valid-ownership">>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.17" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "tftpboot-directory">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "invalid-ownership">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.17" >>p12
	printf "%30s\n" "$z" >>p6
fi


cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	if [ -f /home/ftp ]
	then
		sc=`ls -ld /home/ftp | awk '{print $3}'`
		if [ $sc -eq "root" ]
		then	
			printf "%30s\n" "network-settings" >>p1
			printf "%30s\n" "ftp_home-directory">>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "valid-ownership">>p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >>p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.1.5.1.2" >>p12
		else
			printf "%30s\n" "network-settings" >>p1
			printf "%30s\n" "ftp_home-directory">>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "invalid-ownership">>p3
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >>p5
			printf "%30s\n" "E.1.5.1.2" >>p12
			printf "%30s\n" "$z" >>p6
		fi
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "Ftp_service">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "FTP_Directory_is_not_found">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.1.2" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.1.2" >>p12
	printf "%30s\n" "$z" >>p6
fi	

cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp/bin | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_bin_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.1.3" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_bin_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.1.3" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.1.3" >>p12
	printf "%30s\n" "$z" >>p6
fi	


cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp/lib | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_lib_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.1.4" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_lib_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.1.4" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.1.4" >>p12
	printf "%30s\n" "$z" >>p6
fi	


cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp/etc | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_etc_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.1.5" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_etc_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.1.5" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.1.5" >>p12
	printf "%30s\n" "$z" >>p6
fi

cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp/etc/Passwd | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_etc_Passwd_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.1.6" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_etc_Passwd_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.1.6" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.1.6" >>p12
	printf "%30s\n" "$z" >>p6
fi


cat /etc/inetd.conf | grep "^ftp"  > /dev/null 2>&1
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.1.7" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.1.7" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.1.7" >>p12
	printf "%30s\n" "$z" >>p6
fi

cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp/ | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_sub-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.1.8" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_sub-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.1.8" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.1.8" >>p12
	printf "%30s\n" "$z" >>p6
fi

cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	res=`[[ $(grep -c "^ftp[[:blank:]]" /etc/inetd.conf) -gt 0 ]] && grep "^ftp[[:blank:]]" /etc/inetd.conf |awk '{print $6 " " $7 " " $8 " " $9}' || RC=0`
	if [ "$res" == "/usr/sbin/ftpd ftpd -l -u077" ]
	then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "ftpd_daemon" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "ftp-directories will be made writable" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.2.1" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "ftpd_daemon" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "ftp-directories will be not writable" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.2.1" >>p12
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.2.1" >>p12
	printf "%30s\n" "$z" >>p6
fi

cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.2.2" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.2.2" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.2.2" >>p12
	printf "%30s\n" "$z" >>p6
fi


cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp/bin | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_bin_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.2.3" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.2.3" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.2.3" >>p12
	printf "%30s\n" "$z" >>p6
fi

cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp/lib | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_lib_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.2.4" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.2.4" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.2.4" >>p12
	printf "%30s\n" "$z" >>p6
fi

cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1 
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp/etc | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_etc_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.2.5" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_etc_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.2.5" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.2.5" >>p12
	printf "%30s\n" "$z" >>p6
fi

cat /etc/inetd.conf | grep "^ftp" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	sc=`ls -ld /home/ftp | awk '{print $3}'` > /dev/null 2>&1
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "valid-ownership">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.2.6" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "ftp_home-directory">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.2.6" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Ftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "FTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.2.6" >>p12
	printf "%30s\n" "$z" >>p6
fi


res=`lssrc -a| grep -i tftp | awk '{print $3}'`
if [ "$res" != "inoperative" ]
then
	if [ -f /etc/tftpaccess.ctl ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "/etc/tftpaccess.ctl">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "/etc/tftpaccess.ctl_file_exist">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.3.1" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "/etc/tftpaccess.ctl">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "/etc/tftpaccess.ctl_file_not_found">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.3.1" >>p12
	fi
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "Tftp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "TFTP_is_not_enabled_on_server">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.3.1" >>p12
	printf "%30s\n" "$z" >>p6
fi


if [ -f /etc/tftpaccess.ctl ]
then
	cat  /etc/tftpaccess.ctl | grep -v '^#' | grep -v "access"
	if [ $? -eq 0 ]
	then
			printf "%30s\n" "Network_Settings" >>p1
		        printf "%30s\n" "/etc/tftpaccess.ctl" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "other_than_access_statements_are_existing" >>p3
			printf "%30s\n" "yes" >>p4	
			printf "%30s\n" "E.1.5.3.2">>p12
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	else
			printf "%30s\n" "Network_Settings" >>p1
		        printf "%30s\n" "/etc/tftpaccess.ctl" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "only_access_statements_are_existing" >>p3
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "E.1.5.3.2">>p12
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "Network_Settings" >>p1
        printf "%30s\n" "/etc/tftpaccess.ctl" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "file-deosnt-exist" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "E.1.5.3.2">>p12
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
fi


if [ -f /etc/hosts.equiv ]
then	
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "/etc/hosts.equiv">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "remote_access_commands_are_active">>p3
	printf "%30s\n" "no">>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.6" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "/etc/hosts.equiv">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "remote_access_commands_are_disabled">>p3
	printf "%30s\n" "yes">>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.6" >>p12
fi


sc=`$(lpstat -W | grep -w bsh)`
if [ "$sc" == "0" ]
then	
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "lpd_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "bsh_queue_is_disabled">>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.8" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "lpd_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "bsh_queue_is_enabled">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.8" >>p12
	printf "%30s\n" "$z" >>p6
fi


`lssrc -a | grep -i nntp`
if [ $? -eq 0 ]
then	
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "nntp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "nntp_service_is_enabled">>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.9" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "nntp_service">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "nntp_service_is_disabled">>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.9" >>p12
	printf "%30s\n" "$z" >>p6
fi





if [ -f /usr/bin/X11/xhost ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/usr/bin/X11/xhost" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "xhost_is_not_disabled" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.11.1" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/usr/bin/X11/xhost" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "xhost_is_disabled" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.11.1" >>p12
fi



version=`uname -v`
if [ $version -le 7 ]
then
	sc=`ls -ld /var/ifor/i4ls.ini | awk '{print $3}'`
	if [ "$sc" == "root" ]
	then	
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "/var/ifor/i4ls.ini">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "write_access_by_root">>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.10.3" >>p12
	else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "/var/ifor/i4ls.ini">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "invalid-ownership">>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.10.3" >>p12
		printf "%30s\n" "$z" >>p6
	fi
else
		printf "%30s\n" "network-settings" >>p1
		printf "%30s\n" "/var/ifor/i4ls.ini">>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "iFOR/LS_is_not_supported_on_$version">>p3
		printf "%30s\n" "N/A" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "E.1.5.10.3" >>p12
		printf "%30s\n" "$z" >>p6

fi


# sc=`$(ps -ef | grep -c dt)`
sc=`ps -ef | grep -c dt`
if [ "$sc" == "0" ]
then	
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "CDE">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "CDE_is_not_installed">>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.11.2" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "CDE">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "CDE_is_installed">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.11.2" >>p12
	printf "%30s\n" "$z" >>p6
fi

sc=`ls -ld /etc/exports | awk '{print $3}'`
if [ "$sc" == "root" ]
then	
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "etc_exports-directory">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "valid-ownership">>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.18.1/E.1.5.18.2/E.1.5.18.3/E.1.5.18.4" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "etc_exports-directory">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "invalid-ownership">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.18.1/E.1.5.18.2/E.1.5.18.3/E.1.5.18.4" >>p12
	printf "%30s\n" "$z" >>p6
fi

if [ -f /etc/exports ]
then
	cat  /etc/exports | grep "root=overrides" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		printf "%30s\n" "Network_Settings" >>p1
	        printf "%30s\n" "NFS" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "Disallow_no_root_squash" >>p3
		printf "%30s\n" "E.1.5.18.6">>p12
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
	else
		printf "%30s\n" "Network_Settings" >>p1
	        printf "%30s\n" "NFS" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "allow no_root_squash" >>p3
		printf "%30s\n" "E.1.5.18.6">>p12
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "Network_Settings" >>p1
        printf "%30s\n" "NFS" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "/etc/exports-deosnt-exist" >>p3
	printf "%30s\n" "E.1.5.18.6">>p12
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
fi

if [ -f /etc/exports ]
then
	cat  /etc/exports | grep "anon=overrides" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
			printf "%30s\n" "Network_Settings" >>p1
		        printf "%30s\n" "NFS" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "anon=overriden" >>p3
			printf "%30s\n" "E.1.5.18.7">>p12
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	else
			printf "%30s\n" "Network_Settings" >>p1
		        printf "%30s\n" "NFS" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "anon_is_not_set" >>p3
			printf "%30s\n" "E.1.5.18.7">>p12
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "Network_Settings" >>p1
        printf "%30s\n" "NFS" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "/etc/exports-deosnt-exist" >>p3
	printf "%30s\n" "E.1.5.18.7">>p12
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
fi

res=`awk -F: '{print $2}' /etc/shadow | grep -c ^\\$` > /dev/null 2>&1
if [ "$res" == 0 ]
then
		printf "%30s\n" "Network_Settings" >>p1
	        printf "%30s\n" "NIS_maps" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "No_hashed_user_passwords" >>p3
		printf "%30s\n" "E.1.5.19">>p12
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
else
		printf "%30s\n" "Network_Settings" >>p1
	        printf "%30s\n" "NIS_maps" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "hashed_user_passwords_is_set" >>p3
		printf "%30s\n" "E.1.5.19">>p12
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
fi

sc=`ls -ld /var/yp | awk '{print $3}'`
if [ "$sc" == "root" ]
then	
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "var_yp_directory">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "valid-ownership">>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.19" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "var_yp_directory">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "invalid-ownership">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.19" >>p12
	printf "%30s\n" "$z" >>p6
fi

sc=`ls -ld /var/nis/data | awk '{print $3}'` > /dev/null 2>&1
if [ "$sc" == "root" ]
then	
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "var_nis_data_directory">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "valid-ownership">>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.20" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "var_nis_data_directory">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "invalid-ownership">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.20" >>p12
	printf "%30s\n" "$z" >>p6
fi

sc=`ls -ld /etc/inetd.conf | awk '{print $3}'`
if [ "$sc" == "root" ]

then	
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "etc-inetd.conf_file">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "valid-ownership">>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.22.0" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "etc-inetd.conf_file">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "invalid-ownership">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.22.0" >>p12
	printf "%30s\n" "$z" >>p6
fi

res=`lscore -d | grep "corefile location" | awk -F: '{print $2}'`
if [ "$res" == "not set" ]
then	
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "core_dumps">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "Disable_core_dumps_by_default">>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.25.1" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "core_dumps">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "Enable_core_dumps_by_default">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "E.1.5.25.1" >>p12
	printf "%30s\n" "$z" >>p6
fi

rcncs=`lsitab -a |grep "/etc/rc.ncs" | cut -f1 -d:`
if [ "$rcncs" == 0 ]
then
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "/etc/rc.ncs">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "ncs_service_is_enabled">>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.26.1" >>p12
else
	printf "%30s\n" "network-settings" >>p1
	printf "%30s\n" "/etc/rc.ncs">>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "ncs_service_is_disabled">>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.26.1" >>p12
fi

#E.1.8.2/E.1.8.3.1/E.1.8.3.2/E.1.8.3.3/E.1.8.3.4/E.1.8.3.5/E.1.8.3.6/E.1.8.3.7/E.1.8.3.8.1/E.1.8.3.8.2/E.1.8.4.0/E.1.8.4.1.1/E.1.8.4.1.2/E.1.8.4.1.3/E.1.8.4.1.4/E.1.8.4.1.5/E.1.8.4.1.6/E.1.8.4.1.7/E.1.8.4.1.8/E.1.8.4.1.9/E.1.8.4.1.10/E.1.8.4.2.1/E.1.8.4.2.2/E.1.8.4.2.3/E.1.8.4.2.4/E.1.8.4.2.5/E.1.8.5.1/E.1.8.5.2/E.1.8.4.4/E.1.8.6.1/E.1.8.6.2/E.1.8.6.3.1/E.1.8.6.3.2/E.1.8.6.3.3/E.1.8.6.4.1/E.1.8.6.4.2/E.1.8.6.4.3/E.1.8.7.1/E.1.8.7.2/E.1.8.8.3/E.1.8.8.4/E.1.8.8.5/E.1.8.8.6/E.1.8.9.1/E.1.8.9.2/E.1.8.9.3/E.1.8.9.4/E.1.8.9.5/E.1.8.10/E.1.8.11/E.1.8.12.0/E.1.8.12.1.1/E.1.8.12.1.2/E.1.8.12.2/E.1.8.12.3/E.1.8.12.4/E.1.8.13.1/E.1.8.13.2/E.1.8.13.3/E.1.8.14.1/E.1.8.14.2/E.1.8.14.3/E.1.8.16.2/E.1.8.16.3/E.1.8.17


str="E.1.8.2/E.1.8.3.1/E.1.8.3.2/E.1.8.3.3/E.1.8.3.4/E.1.8.3.5/E.1.8.3.6/E.1.8.3.7/E.1.8.3.8.1/E.1.8.3.8.2/E.1.8.4.0/E.1.8.4.1.1/E.1.8.4.1.2/E.1.8.4.1.3/E.1.8.4.1.4/E.1.8.4.1.5/E.1.8.4.1.6/E.1.8.4.1.7/E.1.8.4.1.8/E.1.8.4.1.9/E.1.8.4.1.10/E.1.8.4.2.1/E.1.8.4.2.2/E.1.8.4.2.3/E.1.8.4.2.4/E.1.8.4.2.5/E.1.8.5.1/E.1.8.5.2/E.1.8.4.4/E.1.8.6.1/E.1.8.6.2/E.1.8.6.3.1/E.1.8.6.3.2/E.1.8.6.3.3/E.1.8.6.4.1/E.1.8.6.4.2/E.1.8.6.4.3/E.1.8.7.1/E.1.8.7.2/E.1.8.8.3/E.1.8.8.4/E.1.8.8.5/E.1.8.8.6/E.1.8.9.1/E.1.8.9.2/E.1.8.9.3/E.1.8.9.4/E.1.8.9.5/E.1.8.10/E.1.8.11/E.1.8.12.0/E.1.8.12.1.1/E.1.8.12.1.2/E.1.8.12.2/E.1.8.12.3/E.1.8.12.4/E.1.8.13.1/E.1.8.13.2/E.1.8.13.3/E.1.8.14.1/E.1.8.14.2/E.1.8.14.3/E.1.8.16.2/E.1.8.16.3/E.1.8.17"


filesperm(){
find / -type f -perm -o+w >world-writable-test
find / -type d -perm -o+w >world-writable-test1
for i in `cat world-writable-test`
do
	ls -lrt $i >> f1
done
for i in `cat world-writable-test1`
do
	ls -ld $i >> f1
done

cat f1 | grep -v ^drwxrwxrwt | egrep -v "^s|^l" | grep -v "total"  > newestlist

while IFS= read -r line
do
	echo $line | awk '{print $1"_"$9}' >>f6
done < newestlist 

sk=`cat newestlist | wc -l`
if [ "$sk" == 0 ]
then
	printf "%30s\n" "protecting-resource-osr" >>p1
        printf "%30s\n" "file-permissions-wwf" >>p2
        printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "violatiions-not-found-wwf" >>p3
        printf "%30s\n" "yes" >>p4
        printf "%30s\n" "$str" >>p12
	printf "%30s\n" "$c" >>p5
        printf "%30s\n" "$z" >>p6
else
	while IFS= read -r line
	do
		z1=`echo $line | cut -c9`
		if [ "$z1" == "w" ]
		then
			printf "%30s\n" "protecting-resource-osr" >>p1
                        printf "%30s\n" "file-permissions-wwf" >>p2
                        printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "$line" >>p3
			printf "%30s\n" "$str" >>p12
                        printf "%30s\n" "no" >>p4
                        printf "%30s\n" "$c" >>p5
                        printf "%30s\n" "$z" >>p6
		fi
	done < f6
fi
rm -rf f6 newestlist world-writable-test world-writable-test1
}
while true;do filesperm ; break ;done 

stq=`ls -lrt /root/.rhost | awk '{print $1}'`
if [ -f /home/root/rhost ]
then
	if [ "$stq" == "-rw------" ]
	then
		printf "%30s\n" "protecting-resources-osr" >>p1
		printf "%30s\n" "/home/root/rhosts" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$st1" >> p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.8.8.1" >>p12
	else
		printf "%30s\n" "protecting-resources-osr" >>p1
		printf "%30s\n" "/home/root/rhosts" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$st1" >> p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
                printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.8.8.1" >>p12
	fi
else
	printf "%30s\n" "protecting-resources-osr" >>p1
	printf "%30s\n" "/home/root/rhosts" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "file-doesnt-exist" >> p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.8.8.1" >>p12
fi

std=`ls -lrt /root/.netrc | awk '{print $1}'`
if [ -f /home/root/rhost ]
then
	if [ "$stq" == "-rw------" ]
	then
		printf "%30s\n" "protecting-resources-osr" >>p1
		printf "%30s\n" "/home/root/.netrc" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$std" >> p3
		printf "%30s\n" "yes" >>p4
 	        printf "%30s\n" "$c" >> p5
 	        printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.8.8.2" >>p12
	else
		printf "%30s\n" "protecting-resources-osr" >>p1
		printf "%30s\n" "/home/root/.netrc" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "$std" >> p3
		printf "%30s\n" "no" >>p4
 	        printf "%30s\n" "$c" >> p5
 	        printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.8.8.2" >>p12

	fi
else
	printf "%30s\n" "protecting-resources-osr" >>p1
	printf "%30s\n" "/home/root/.netrc" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "file-doesnt-exist" >> p3
	printf "%30s\n" "yes" >>p4
        printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.8.8.2" >>p12
fi

if [ -f /var/adm/messages ]
then
	printf "%30s\n" "protecting-resources-osr" >>p1
	printf "%30s\n" "/var/adm/messages" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "file-exist" >> p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.5.2" >>p12

else
	printf "%30s\n" "protecting-resources-osr" >>p1
	printf "%30s\n" "/var/adm/messages" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "file-doesnt-exist" >> p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.2.5.2" >>p12

fi


if [ -f /var/log/eprise ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/var/log/eprise" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "file-exist" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.1" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/var/log/eprise" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "file-doesnt-exist" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.1" >>p12
fi

cat /etc/rc | grep "/usr/sbin/audit start" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/rc" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "no-error" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.2" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/rc" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "error:(/usr/sbin/audit)_is_missing_from_/etc/rc" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.2" >>p12
fi

cat /etc/security/audit/config | grep -p classes | grep -i "puma = USER_SU,PASSWORD_Change,USER_Change,USER_Remove,USER_Create,GROUP_Change,GROUP_Create,GROUP_Remove,PROC_Reboot,USER_Reboot,DEV_Change,DEV_Configure,DEV_Create,DEV_Remove,DEV_Start,DEV_Stop,DEV_UnConfigure,ACCT_Disable,ACCT_Enable,PORT_Change,PORT_Locked,TCPIP_config,TCPIP_kconfig,TCPIP_kroute,TCPIP_route,ENQUE_exec,FS_Extend,FS_Mount,FS_Umount,FS_Chroot,RESTORE_Import,AUD_Events,AUD_Objects,AUD_Proc,AUD_It,INSTALLP_Inst,TCPIP_set_time,PROC_Adjtime,PROC_Sysconfig,TCPIP_host_id" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/config" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "no-error" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.3" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/config" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "error:refer(E.20.1.2.3)_in_tech_sepcs" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.3" >>p12
fi

cat /etc/security/audit/config | grep -p users | grep "root = general" > /dev/null 2>&1
if [ $? -eq 0 ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/config" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "value_reended:default=objects/puma_insteda_of_root=general" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.4" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/config" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "value_reended:default=objects_exists" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.4" >>p12
fi

X=`cat /etc/security/audit/events | grep -w "Obj_READ = printf "%s"" | wc -l`
Y=`cat /etc/security/audit/events | grep -w "Obj_WRITE = printf "%s"" | wc -l`
Z=`cat /etc/security/audit/events | grep -w "Obj_EXECUTE = printf "%s"" | wc -l`
if [ "$X" == "0" ] && [ "$Y" == "0" ] && [ "$Z" == "0" ]
then
		printf "%30s\n" "Logging" >>p1
		printf "%30s\n" "/etc/security/audit/events" >>p2
		printf "%30s\n" "$ipAddress" >>en2	
		printf "%30s\n" "values_missing_for(Obj_READ,Obj_WRITE,Obj_EXECUTE)" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.20.1.2.5" >>p12
		
else
		printf "%30s\n" "Logging" >>p1
		printf "%30s\n" "/etc/security/audit/events" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "value-exists" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.20.1.2.5" >>p12
fi




W=`cat /etc/security/audit/objects | grep -p "/etc/sudoers" | grep -w "r = "Obj_READ"" | wc -l `
U=`cat /etc/security/audit/objects | grep -p "/etc/sudoers" | grep -w "w = "Obj_WRITE"" | wc -l`
if [ "$W" == "0" ] && [ "$U" == "0" ]
then
		printf "%30s\n" "Logging" >>p1
		printf "%30s\n" "/etc/security/audit/objects" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "values_missing_under_etc/sudoers_staza(r=Obj_READ,w=Obj_WRITE)" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.20.1.2.6.1" >>p12
else
		printf "%30s\n" "Logging" >>p1
		printf "%30s\n" "/etc/security/audit/objects" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "values_exist_under_etc/sudoers_staza(r=Obj_READ,w=Obj_WRITE)" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.20.1.2.6.1" >>p12
fi


Y=`cat /etc/security/audit/objects | grep -p "/etc/security/environ" | grep -i "w = "S_ENVIRON_WRITE"" | wc -l`
if [ "$Y" == "0" ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_missing_under_/etc/security/environ_staza(W=S_ENVIRON_WRITE)" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.2" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_exist_under_/etc/security/environ_staza(W=S_ENVIRON_WRITE)" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.2" >>p12
fi


M=`cat /etc/security/audit/objects | grep -p "/etc/security/group" | grep -i "w = "S_GROUP_WRITE"" | wc -l`
if [ "$M" == "0" ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_missing_under_/etc/security/group_staza(w=S_GROUP_WRITE)" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.3" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_exist_under_/etc/security/group_staza(w=S_GROUP_WRITE)" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.3" >>p12
fi


P=`cat /etc/security/audit/objects | grep -p "/etc/security/limits" | grep -i "w = "S_LIMITS_WRITE"" | wc -l`
if [ "$P" == "0" ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_missing_under_/etc/security/LIMITS_staza(w=S_LIMITS_WRITE)" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.4" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_exist_under_/etc/security/LIMITS_staza(w=S_LIMITS_WRITE)" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.4" >>p12
fi


Q=`cat /etc/security/audit/objects | grep -p "/etc/security/login.cfg" | grep -i "w = "S_LOGIN_WRITE"" | wc -l`
if [ "$Q" == "0" ]
then
	printf "%30s\n" "Logging" >>p1


	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_missing_under_/etc/security/login.cfg_staza(w=S_LOGIN_WRITE)" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.5" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_exist_under_/etc/security/LOGIN.CFG_staza(w=S_LOGIN_WRITE)" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.5" >>p12
fi


R=`cat /etc/security/audit/objects | grep -p "/etc/security/passwd" | grep -w "r = "S_PASSWD_READ"" | wc -l `
S=`cat /etc/security/audit/objects | grep -p "/etc/security/passwd" | grep -w "w = "S_PASSWD_WRITE"" | wc -l`
if [ "$R" == "0" ] && [ "$S" == "0" ]
then
		printf "%30s\n" "Logging" >>p1
		printf "%30s\n" "/etc/security/audit/objects" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "values_missing_under_etc/security/passwd_staza(r=S_PASSWD_READ,w=S_PASSWD_WRITE)" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.20.1.2.6.6" >>p12
else
		printf "%30s\n" "Logging" >>p1
		printf "%30s\n" "/etc/security/audit/objects" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "values_exist_under_etc/security/passwd_staza(r=S_PASSWD_READ,w=S_PASSWD_WRITE)" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >>p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.20.1.2.6.6" >>p12
fi


N=`cat /etc/security/audit/objects | grep -p "/etc/security/users" | grep -i "w = "S_USER_WRITE"" | wc -l`
if [ "$N" == "0" ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_missing_under_/etc/security/users_staza(w=S_USER_WRITE)" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.7" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_exist_under_/etc/security/users_staza(w=S_USER_WRITE)" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.7" >>p12
fi


K=`cat /etc/security/audit/objects | grep -p "/etc/security/audit/config" | grep -i "w = "AUD_CONFIG_WR"" | wc -l`
if [ "$K" == "0" ]
then
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_missing_under_/etc/security/audit/config_staza(w=AUD_CONFIG_WR)" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.8" >>p12
else
	printf "%30s\n" "Logging" >>p1
	printf "%30s\n" "/etc/security/audit/objects" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "values_exist_under_/etc/security/audit/config_staza(w=AUD_CONFIG_WR)" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >>p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.20.1.2.6.8" >>p12
fi



cat  /etc/profile | grep "TMOUT=1800" > /dev/null 2>&1
if [ $? -eq 0 ]
then
		printf "%30s\n" "System_Settings" >>p1
                printf "%30s\n" "/etc/profile" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "Timeout=1800" >>p3
		printf "%30s\n" "E.10.1.4.1">>p12
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
else
		printf "%30s\n" "System_Settings" >>p1
                printf "%30s\n" "Timeout" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "/etc/profile-TIMEOUT_value_invalid_correct_value_shouled_be_1800" >>p3
		printf "%30s\n" "E.10.1.4.1">>p12
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
fi


if [ -f /etc/tsh_profile ]
then
	cat  /etc/tsh_profile | grep "TMOUT=1800" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
			printf "%30s\n" "System_Settings" >>p1
		        printf "%30s\n" "/etc/tsh_profile" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "Timeout=1800" >>p3
			printf "%30s\n" "E.10.1.4.5">>p12
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	else
			printf "%30s\n" "System_Settings" >>p1
		        printf "%30s\n" "Timeout" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "/etc/tsh_profile-TIMEOUT_value_invalid_correct_value_shouled_be_1800" >>p3
			printf "%30s\n" "E.10.1.4.5">>p12
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "System_Settings" >>p1
        printf "%30s\n" "/etc/tsh_profile" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "file-deosnt-exist" >>p3
	printf "%30s\n" "E.10.1.4.5">>p12
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
fi


if [ -f /etc/csh.login ]
then
	cat /etc/csh.login | grep "set autologout=30" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
			printf "%30s\n" "System_Settings" >>p1
		        printf "%30s\n" "/etc/csh.login" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "set_autologout=30" >>p3
			printf "%30s\n" "E.10.1.4.6">>p12
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	else
			printf "%30s\n" "System_Settings" >>p1
		        printf "%30s\n" "Timeout" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "/etc/csh.login-set_autologout_invalid_correct_value_shouled_be_30" >>p3
			printf "%30s\n" "E.10.1.4.6">>p12
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	fi
else 
	printf "%30s\n" "System_Settings" >>p1
        printf "%30s\n" "/etc/csh.login" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "file-deosnt-exist" >>p3
	printf "%30s\n" "E.10.1.4.6">>p12
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
fi


if [ -f /etc/security/.login ]
then
	cat /etc/security/.login | grep "TMOUT=1800" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
			printf "%30s\n" "System_Settings" >>p1
		        printf "%30s\n" "/etc/security/.login" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "Timeout=1800" >>p3
			printf "%30s\n" "E.10.1.4.7">>p12
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	else
			printf "%30s\n" "System_Settings" >>p1
		        printf "%30s\n" "Timeout" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "/etc/security/.login-TIMEOUT_value_invalid_correct_value_shouled_be_1800" >>p3
			printf "%30s\n" "E.10.1.4.7">>p12
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "System_Settings" >>p1
        printf "%30s\n" "/etc/security/.login" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "/etc/security/.login-file-doesnt-exist" >>p3
	printf "%30s\n" "E.10.1.4.7">>p12
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
fi	


if [ -f /etc/security/mkuser.sys ]
then
	cat  /etc/security/mkuser.sys | grep "set autologout=30" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
			printf "%30s\n" "System_Settings" >>p1
		        printf "%30s\n" "/etc/security/mkuser.sys" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "set_autologout=30" >>p3
			printf "%30s\n" "E.10.1.4.8">>p12
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	else
			printf "%30s\n" "System_Settings" >>p1
		        printf "%30s\n" "Timeout" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "/etc/security/mkuser.sys-set_autologout_invalid_correct_value_shouled_be_30" >>p3
			printf "%30s\n" "E.10.1.4.8">>p12
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	fi
else
	printf "%30s\n" "System_Settings" >>p1
        printf "%30s\n" "/etc/security/mkuser.sys" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "file-doesnt-exist" >>p3
	printf "%30s\n" "E.10.1.4.8">>p12
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
fi


if [ -f /etc/security/mkuser.sys.custom ]
then
	cat  /etc/security/mkuser.sys.custom | grep "set autologout=30"
	if [ $? -eq 0 ]
	then
			printf "%30s\n" "System_Settings" >>p1
		        printf "%30s\n" "/etc/security/mkuser.sys.custom" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "set_autologout=30" >>p3
			printf "%30s\n" "E.10.1.4.9">>p12
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	else
			printf "%30s\n" "System_Settings" >>p1
		        printf "%30s\n" "Timeout" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "/etc/security/mkuser.sys.custom-set_autologout_invalid_correct_value_shouled_be_30" >>p3
			printf "%30s\n" "E.10.1.4.9">>p12
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
	fi
else
		printf "%30s\n" "System_Settings" >>p1
                printf "%30s\n" "/etc/security/mkuser.sys.custom_file_doesnt_exist" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "set_autologout=30" >>p3
		printf "%30s\n" "E.10.1.4.9">>p12
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
fi




lssec -f /etc/security/user -s default -a minage | awk -F= '{print $2}' > /dev/null 2>&1
if [ $? == "1" ]
then
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "default_minage" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "minage = $?" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.3.0" >>p12
else
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "default_minage" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "minage = $?" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.3.0" >>p12
fi


res=`lssec -f /etc/security/user -s default -a histsize | awk -F= '{print $2}'`
if [ $res == "8" ]
then
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "default_histsize" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "histsize = $res" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.7" >>p12
else
	printf "%30s\n" "Password_requirements" >>p1
	printf "%30s\n" "default_histsize" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "histsize = $res" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.1.7" >>p12
fi



res=`lssrc -g nfs | grep "rpc.lockd" | awk '{print $4}'`
if [ $res == "active" ]
then
	if [ -f /etc/exports ]
	then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "nfs_service" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "/etc/exports_is_existing" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.4" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "nfs_service" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "/etc/exports_is_not_existing" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.4" >>p12
	fi
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "nfs_service" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "nfs_service_disabled" >>p3
	printf "%30s\n" "N/A" >>p4
	printf "%30s\n" "$c" >> p5
        printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.4" >>p12
fi


`grep "^#echo[[:blank:]]" /etc/inetd.conf` > /dev/null 2>&1
if [ $? -eq "0" ]
then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "echo_have_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.18" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "echo_have_no_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.18" >>p12
fi 

`grep "^#chargen[[:blank:]]" /etc/inetd.conf` > /dev/null 2>&1
if [ $? -eq "0" ]
then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "chargen_have_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.19" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "chargen_have_no_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.19" >>p12
fi



`grep "^#finger[[:blank:]]" /etc/inetd.conf` > /dev/null 2>&1
if [ $? -eq "0" ]
then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "finger_have_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.20" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "finger_have_no_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.20" >>p12
fi


`grep "^#discard[[:blank:]]" /etc/inetd.conf` > /dev/null 2>&1
if [ $? -eq "0" ]
then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "discard_have_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.21" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "discard_have_no_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.21" >>p12
fi

`grep "^#systat[[:blank:]]" /etc/inetd.conf` > /dev/null 2>&1
if [ $? -eq "0" ]
then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "systat_have_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.22" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "systat_have_no_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.22" >>p12
fi


`grep "^#daytime[[:blank:]]" /etc/inetd.conf` > /dev/null 2>&1
if [ $? -eq "0" ]
then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "daytime_have_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.23" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "daytime_have_no_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.23" >>p12
fi
 
`grep "^#netstat[[:blank:]]" /etc/inetd.conf` > /dev/null 2>&1
if [ $? -eq "0" ]
then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "netstat_have_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.24" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "netstat_have_no_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.24" >>p12
fi

`grep "^#who[[:blank:]]" /etc/inetd.conf` > /dev/null 2>&1
if [ $? -eq "0" ]
then
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "who_have_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.25" >>p12
	else
		printf "%30s\n" "Network Settings" >>p1
		printf "%30s\n" "/etc/inetd.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "who_have_no_entry_/etc/inetd.conf" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.1.5.12.25" >>p12
fi



#*******HIPPA PARAMS************************************************************************************************************


res=`grep "TMOUT" /etc/profile | awk -F= '{print $2}'`
if [ "$res" == "21600" ]
then
		printf "%30s\n" "Password Requirements" >>p1
		printf "%30s\n" "/etc/profile" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "OS_Automatic_Logoff_TMOUT_is_$res" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.1.2" >>p12
	else
		printf "%30s\n" "Password Requirements" >>p1
		printf "%30s\n" "/etc/profile" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "OS_Automatic_Logoff_TMOUT_is_$res" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.1.2" >>p12
fi


res=`grep "TMOUT" /etc/tsh_profile | awk -F= '{print $2}'`
if [ "$res" == "21600" ]
then
		printf "%30s\n" "Password Requirements" >>p1
		printf "%30s\n" "/etc/tsh_profile" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "OS_Automatic_Logoff_TMOUT_is_$res" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.1.3" >>p12
	else
		printf "%30s\n" "Password Requirements" >>p1
		printf "%30s\n" "/etc/tsh_profile" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "OS_Automatic_Logoff_TMOUT_is_$res" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.1.3" >>p12
fi


res=`grep "autologout" /etc/csh.login | awk -F= '{print $2}'`
if [ "$res" == "360" ]
then
		printf "%30s\n" "Password Requirements" >>p1
		printf "%30s\n" "/etc/csh.login" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "autologout_$res" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.1.4" >>p12
	else
		printf "%30s\n" "Password Requirements" >>p1
		printf "%30s\n" "/etc/csh.login" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "autologout_$res" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.1.4" >>p12
fi



if [ -f /etc/security/.profile ]
then
	res=`grep "TMOUT" /etc/security/.profile | awk -F= '{print $2}'`
	if [ "$res" == "21600" ]
	then
			printf "%30s\n" "Password Requirements" >>p1
			printf "%30s\n" "/etc/security/.profile" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "OS_Automatic_Logoff_TMOUT_is_$res" >>p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.30.0.1.5" >>p12
		else
			printf "%30s\n" "Password Requirements" >>p1
			printf "%30s\n" "/etc/security/.profile" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "OS_Automatic_Logoff_TMOUT_is_$res" >>p3
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.30.0.1.5" >>p12
	fi
else
	printf "%30s\n" "Password Requirements" >>p1
	printf "%30s\n" "/etc/security/.profile" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "/etc/security/.profile_is_not_existing" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.30.0.1.5" >>p12

fi


`grep "autologout" /etc/security/.profile`
if [ $? -eq 0 ]
then
	res=`grep "autologout" /etc/security/.profile | awk -F= '{print $2}'`
	if [ $res -eq "360" ]
	then
			printf "%30s\n" "Password Requirements" >>p1
			printf "%30s\n" "$home/.login" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "autologout_$res" >>p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.30.0.1.6/E.30.0.1.7" >>p12
	else
			printf "%30s\n" "Password Requirements" >>p1
			printf "%30s\n" "$home/.login" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "autologout_$res" >>p3
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.30.0.1.6/E.30.0.1.7" >>p12
	fi
else
	printf "%30s\n" "Password Requirements" >>p1
	printf "%30s\n" "$home/.login" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "no_autologout_option" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.30.0.1.6/E.30.0.1.7" >>p12
fi

res=`grep -w "^TMOUT" /etc/profile | awk F= '{print $2}'`
if [ "$res" == "21600" ]
then
		printf "%30s\n" "Password Requirements" >>p1
		printf "%30s\n" "/etc/profile" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "TMOUT_is_set_to_$res" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.1.8" >>p12
	else
		printf "%30s\n" "Password Requirements" >>p1
		printf "%30s\n" "/etc/profile" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "TMOUT_is_set_to_$res" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.1.8" >>p12
fi

`grep -w "auth" /etc/syslog.conf` > /dev/null 2>&1
if [ $? -eq "0" ]
then
		printf "%30s\n" "Logging" >>p1
		printf "%30s\n" "/etc/syslog.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "set_\"auth\"_data_to_remote_server" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.2.1" >>p12
	else
		printf "%30s\n" "Logging" >>p1
		printf "%30s\n" "/etc/syslog.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "unset_\"auth\"_data_to_remote_server" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.2.1" >>p12
fi


`grep -w "authpriv" /etc/syslog.conf`
if [ $? -eq "0" ]
then
		printf "%30s\n" "Logging" >>p1
		printf "%30s\n" "/etc/syslog.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "set_\"authpriv\"_data_to_remote_server" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.2.2" >>p12
	else
		printf "%30s\n" "Logging" >>p1
		printf "%30s\n" "/etc/syslog.conf" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "unset_\"authpriv\"_data_to_remote_server" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.30.0.2.2" >>p12
fi


`lslpp -l bos.rte.commands` > /dev/null 2>&1
res1=$?
`lslpp -l openssl.base` > /dev/null 2>&1
res2=$?

version=`uname -v`
if [ $version -ge "5.3" ]
then
	if [ $res1 -eq "0" ] || [ $res2 -eq "0" ]
	then
			printf "%30s\n" "System Settings" >>p1
			printf "%30s\n" "Checksum" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "Checksum_algorithm_is_installed" >>p3
			printf "%30s\n" "yes" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.10.1.4.3" >>p12
		else
			printf "%30s\n" "System Settings" >>p1
			printf "%30s\n" "Checksum" >>p2
			printf "%30s\n" "$ipAddress" >>en2
			printf "%30s\n" "Checksum_algorithm_is_not_installed" >>p3
			printf "%30s\n" "no" >>p4
			printf "%30s\n" "$c" >> p5
			printf "%30s\n" "$z" >>p6
			printf "%30s\n" "E.10.1.4.3" >>p12
	fi
fi


if [ -f /etc/motd ]
then
	printf "%30s\n" "Business Use Notice" >>p1
	printf "%30s\n" "/etc/motd" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "/etc/motd_file_is_existing" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.2.0.1/E.2.0.2" >>p12
else
	printf "%30s\n" "Business Use Notice" >>p1
	printf "%30s\n" "/etc/motd" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "/etc/motd_file_is_not_existing" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.2.0.1/E.2.0.2" >>p12
fi



Buss_Notice="This system should be used for conducting IBM's business or for purposes authorized by IBM management. It is mandatory to comply with all the requirements listed in the applicable security policy and only process or store the data classes approved for this asset type. Use is subject to audit at any time by IBM management."

if [ -f /etc/motd ]
then
	`grep  "$Buss_Notice" /etc/motd`
	if [ $? -eq "0" ]
	then
		printf "%30s\n" "Business Use Notice" >>p1
		printf "%30s\n" "/etc/motd" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "Bussiness_note_fovvund" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.40.0.1" >>p12
	else
		printf "%30s\n" "Business Use Notice" >>p1
		printf "%30s\n" "/etc/motd" >>p2
		printf "%30s\n" "$ipAddress" >>en2
		printf "%30s\n" "Bussiness_note_not_found" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.40.0.1" >>p12
	fi
else
	printf "%30s\n" "Business Use Notice" >>p1
	printf "%30s\n" "/etc/motd" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "/etc/motd_file_not_found" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.40.0.1" >>p12
fi


if [ -f /usr/dt/bin/dthello ]
then
	printf "%30s\n" "Business Use Notice" >>p1
	printf "%30s\n" "/usr/dt/bin/dthello" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "dthello_is_found" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.40.0.2" >>p12
else
	printf "%30s\n" "Business Use Notice" >>p1
	printf "%30s\n" "/usr/dt/bin/dthello" >>p2
	printf "%30s\n" "$ipAddress" >>en2
	printf "%30s\n" "dthello_is_not_found" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.40.0.2" >>p12
fi


*********************************************************************************************************************************************


`egrep 'TMOUT=|[[:space:]][[:space:]]*TMOUT[[:space:]]|[[:space:]][[:space:]]*TMOUT$' /etc/profile`
if [ $? -eq 0 ]
then
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/profile" >>p2
	printf "%30s\n" "TMOUT" >>en2
	printf "%30s\n" "TMOUT_environment_variable_has_been_set_for_$TMOUT" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.1" >>p12
else
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/profile" >>p2
	printf "%30s\n" "TMOUT" >>en2
	printf "%30s\n" "TMOUT_environment_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.1" >>p12
fi


`egrep 'TMOUT=|[[:space:]][[:space:]]*TMOUT[[:space:]]|[[:space:]][[:space:]]*TMOUT$' /etc/tsh_profile`
if [ $? -eq 0 ]
then
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/tsh_profile" >>p2
	printf "%30s\n" "TMOUT" >>en2
	printf "%30s\n" "TMOUT_environment_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.2" >>p12
else
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/tsh_profile" >>p2
	printf "%30s\n" "TMOUT" >>en2
	printf "%30s\n" "TMOUT_environment_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.2" >>p12
fi



`grep -v '^[[:space:]]*#' /etc/csh.login | grep 'set[[:space:]]*autologout'`
if [ $? -eq 0 ]
then
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/csh.login" >>p2
	printf "%30s\n" "autologout" >>en2
	printf "%30s\n" "autologout_environment_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.3" >>p12
else
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/csh.login" >>p2
	printf "%30s\n" "autologout" >>en2
	printf "%30s\n" "autologout_environment_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.3" >>p12
fi




`egrep 'TMOUT=|[[:space:]][[:space:]]*TMOUT[[:space:]]|[[:space:]][[:space:]]*TMOUT$'  /etc/security/.profile`
if [ $? -eq 0 ]
then
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/security/.profile" >>p2
	printf "%30s\n" "TMOUT" >>en2
	printf "%30s\n" "TMOUT_environment_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.4" >>p12
else
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/security/.profile" >>p2
	printf "%30s\n" "TMOUT" >>en2
	printf "%30s\n" "TMOUT_environment_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.4" >>p12
fi




`grep -v "^[[:space:]]*#" /etc/security/mkuser.sys | grep 'autologout'`
if [ $? -eq 0 ]
then
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/security/mkuser.sys" >>p2
	printf "%30s\n" "autologout" >>en2
	printf "%30s\n" "autologout_environment_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.5" >>p12
else
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/security/mkuser.sys" >>p2
	printf "%30s\n" "autologout" >>en2
	printf "%30s\n" "autologout_environment_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.5" >>p12
fi



`grep -v "^[[:space:]]*#" /etc/security/mkuser.sys.custom | grep 'autologout'`
if [ $? -eq 0 ]
then
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/security/mkuser.sys.custom" >>p2
	printf "%30s\n" "autologout" >>en2
	printf "%30s\n" "autologout_environment_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.6" >>p12
else
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/security/mkuser.sys.custom" >>p2
	printf "%30s\n" "autologout" >>en2
	printf "%30s\n" "autologout_environment_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.6" >>p12
fi



<<Comm
login_shell_timeout()
{
	file=/etc/passwd
	shells='/usr/bin/ksh|/usr/bin/rksh|/usr/bin/psh|/usr/bin/tsh|/usr/bin/csh|/bin/ksh|/bin/rksh|/bin/psh|/bin/tsh|/bin/csh|/bin/sh|/usr/bin/sh|/bin/false|/usr/bin/false|/bin/ksh93|/usr/rksh93|/usr/bin/ksh93|/usr/bin/rksh93'
	cat $file | egrep -v '^uucp:|^nuucp:|^snapp:|sliplogin$' |
	while read ENTRY
	do
	SHELL=$(echo $ENTRY | awk -F: '{print $7}')
	UID=$(echo $ENTRY | awk -F: '{print $1}')
	[[ "$SHELL" != @($shells) ]] && print " WARNING: Verify shell supports autologout/TMOUT inactivity timeout - id: $UID - shell: $SHELL"
	done
}



login_shell_timeout
if [ $? -eq 0 ]
then
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/security/mkuser.sys.custom" >>p2
	printf "%30s\n" "autologout" >>en2
	printf "%30s\n" "autologout_environment_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.7" >>p12
else
	printf "%30s\n" "System Settings" >>p1
	printf "%30s\n" "/etc/security/mkuser.sys.custom" >>p2
	printf "%30s\n" "autologout" >>en2
	printf "%30s\n" "autologout_environment_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.4.7" >>p12
fi




<<Comm
`cat /etc/tunables/nextboot | grep -w "ipsrcrouteforward"`
if [ $? -eq 0 ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipsrcrouteforward" >>en2
	printf "%30s\n" "ipsrcrouteforward_variable_has_been_set_to_$ipsrcrouteforward" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.1" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipsrcrouteforward" >>en2
	printf "%30s\n" "ipsrcrouteforward_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.1" >>p12
fi
Comm



res=`no -a |grep "ipsrcrouteforward[[:blank:]]=[[:blank:]]0"`
if [ $res == "ipsrcrouteforward = 0" ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipsrcrouteforward" >>en2
	printf "%30s\n" "ipsrcrouteforward_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.1" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipsrcrouteforward" >>en2
	printf "%30s\n" "ipsrcrouteforward_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.1" >>p12
fi



res=`no -a |grep "ipignoreredirects[[:blank:]]=[[:blank:]]1"`
if [ $res == "ipignoreredirects = 1" ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipignoreredirects" >>en2
	printf "%30s\n" "ipignoreredirects_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.2" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipignoreredirects" >>en2
	printf "%30s\n" "ipignoreredirects_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.2" >>p12
fi


res=`no -a |grep "clean_partial_conns[[:blank:]]=[[:blank:]]1"`
if [ $res == "clean_partial_conns = 1" ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "clean_partial_connsparameter" >>en2
	printf "%30s\n" "clean_partial_connsparameter_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.3" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "clean_partial_connsparameter" >>en2
	printf "%30s\n" "clean_partial_connsparameter_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.3" >>p12
fi



res=`no -a |grep "ipsrcroutesend[[:blank:]]=[[:blank:]]0" `
if [ $res == "ipsrcroutesend = 0" ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipsrcroutesend" >>en2
	printf "%30s\n" "ipsrcroutesend_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.4" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipsrcroutesend" >>en2
	printf "%30s\n" "ipsrcroutesend_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.4" >>p12
fi


res=`no -a |grep "ipforwarding[[:blank:]]=[[:blank:]]0"`
if [ $res == "ipforwarding = 0" ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipforwarding" >>en2
	printf "%30s\n" "ipforwarding_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.5" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipforwarding" >>en2
	printf "%30s\n" "ipforwarding_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.5" >>p12
fi




res=`no -a |grep "ipsendredirects[[:blank:]]=[[:blank:]]0"`
if [ $res == "ipsendredirects = 0" ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipsendredirects" >>en2
	printf "%30s\n" "ipsendredirects_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.6" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ipsendredirects" >>en2
	printf "%30s\n" "ipsendredirects_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.6" >>p12
fi



res=`no -a |grep "ip6srcrouteforward[[:blank:]]=[[:blank:]]0"`
if [ $res == "ip6srcrouteforward = 0" ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ip6srcrouteforward" >>en2
	printf "%30s\n" "ip6srcrouteforward_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.7" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ip6srcrouteforward" >>en2
	printf "%30s\n" "ip6srcrouteforward_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.7" >>p12
fi


res=`no -a |grep "ip6forwarding[[:blank:]]=[[:blank:]]0"`
if [ $res == "ip6forwarding = 0" ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ip6forwarding" >>en2
	printf "%30s\n" "ip6forwarding_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.8" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "ip6forwarding" >>en2
	printf "%30s\n" "ip6forwarding_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.8" >>p12
fi



res=`no -a |grep "bcastping[[:blank:]]=[[:blank:]]0"`
if [ $res == "bcastping = 0" ]
then
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "bcastping" >>en2
	printf "%30s\n" "bcastping_variable_has_been_set" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.9" >>p12
else
	printf "%30s\n" "Network Settings" >>p1
	printf "%30s\n" "/etc/tunables/nextboot" >>p2
	printf "%30s\n" "bcastping" >>en2
	printf "%30s\n" "bcastping_variable_is_not_set" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.1.5.27.9" >>p12
fi




res=`lssrc -s portmap | grep -w "portmap" | awk '{print $4}'`
if [ $res == "active" ]
then
	`rpcinfo -p localhost | grep -v portmapper`
	if [ $? -eq 0 ]
	then
		printf "%30s\n" "Portmap" >>p1
		printf "%30s\n" "/etc/rc.tcpip" >>p2
		printf "%30s\n" "Portmap" >>en2
		printf "%30s\n" "RPC_services_are_enabled" >>p3
		printf "%30s\n" "no" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.C.1.1.1" >>p12
	else
		printf "%30s\n" "Portmap" >>p1
		printf "%30s\n" "/etc/rc.tcpip" >>p2
		printf "%30s\n" "Portmap" >>en2
		printf "%30s\n" "RPC_services_are_disabled" >>p3
		printf "%30s\n" "yes" >>p4
		printf "%30s\n" "$c" >> p5
		printf "%30s\n" "$z" >>p6
		printf "%30s\n" "E.C.1.1.1" >>p12
	fi
else
	printf "%30s\n" "Portmap" >>p1
	printf "%30s\n" "/etc/rc.tcpip" >>p2
	printf "%30s\n" "Portmap" >>en2
	printf "%30s\n" "Portmap_is_$res" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.C.1.1.1" >>p12
fi



root_permissions()
{
echo "/:${PATH}" | tr ':' '\n' | grep "^/" | sort -u | while read DIR
do
DIR=${DIR:-$(pwd)}
while [[ -d ${DIR} ]]
do [[ "$(ls -ld ${DIR})" = @(d???????w? *) ]] && print " WARNING ${DIR} is world writable"
[[ "$(ls -ld ${DIR})" = @(d????w???? *) ]] && [[ ${DIR} != "/usr/ucb" ]] && print " WARNING ${DIR} is group writable"
[[ "$(ls -ld ${DIR} |awk '{print $3}')" != @(root|bin) ]] && print " WARNING ${DIR} is not owned by root or bin"
DIR=${DIR%/*}
done
done
}

res=`root_permissions`
if [ $res == " " ]
then
	printf "%30s\n" "Permissions_and_Ownership" >>p1
	printf "%30s\n" "root" >>p2
	printf "%30s\n" "world_group_writable_directory_in_root_PATH" >>en2
	printf "%30s\n" "permissions_valid" >>p3
	printf "%30s\n" "yes" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.C.1.1.2" >>p12
else
	printf "%30s\n" "Permissions_and_Ownership" >>p1
	printf "%30s\n" "root" >>p2
	printf "%30s\n" "world_group_writable_directory_in_root_PATH" >>en2
	printf "%30s\n" "permissions_invalid" >>p3
	printf "%30s\n" "no" >>p4
	printf "%30s\n" "$c" >> p5
	printf "%30s\n" "$z" >>p6
	printf "%30s\n" "E.C.1.1.2" >>p12
fi

#header_info

#*******************************************************************************************************************

/usr/bin/clear

echo "Generating the output file....."

paste p6	p1	p12	p2	p3	p4	p5	en2 >> `hostname`_unifermhc.csv

# rm -rf temp_shadow temp_shadow1 psw_temp temp_uid temp_uid1 temp_gid temp_gid1 pasd_temp p5 p4 p3 p2 p1 p6 temp_users1 temp_users pasd_usr f1 list-check list-check1 p12

rm -rf temp_shadow temp_shadow1 psw_temp temp_uid temp_uid1 temp_gid temp_gid1 pasd_temp p5 en2 p4 p3 p2 p1 p6 temp_users1 temp_users pasd_usr f1 list-check list-check1 p12

echo "HC scan script has been executed successfully and output is saved in a .csv file in current folder." 
