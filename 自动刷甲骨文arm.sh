#!/bin/bash
trap 'onCtrlC' INT
#===========================================��д��������1====================================================#
# 0=�½� 1=���� Ĭ��Ϊ0�����½�ʵ��
Flag=0
# ����ID				��availability_domain��
Available_Domain='tkdz:AP-TOKYO-1-AD-1'
# ����				����source_id����
Image_ID='ocid1.image.oc1.ap-tokyo-1.aaaaaaaal7aowbiferbp6osj7uutzx3okjxbab54kbp4n3fllebcyqfv3gbq'
# ����ID				��subnet-id��
Subnet_ID='ocid1.subnet.oc1.ap-tokyo-1.aaaaaaaa5v4duqa2r7vhu6mmsnfuwhhd2ypqh32qcf7ebd4ac4oz6d6mlnwq'
# Ĭ������ARM ��������������޸ģ�������
Shape='VM.Standard.A1.Flex'
# ��Ĺ�Կ			��ssh_authorized_keys��
SSH_Key_PUB="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA8WRtU1KlhOiR9L6u4zhO/CE+7ndRtBGdd12LRmfe3C2ZpOP+PZb13u1UFJmGLxRmzuencZuT93gSuWXzjqYLgEpvXlcjYsYXGIpBjHZ1vpb7lSpqjD5ko9b3e/jgKxF64eYWaWT1AlxUufDPQ5QuxkpZ+v2UWA4zRHFlJVGrk7H/i3cGc2roX2gRKGXHSfDrJ1NJ7fzNf53eh7jTCQ8LBgwfOvBTzaLXlaufuLOwzPbS2bgS7iw9URiTFdD+sm8u17yvBcvYXCU2RrruZF+i8878FB6IcDFL6pPxTG5zrtLUQzcJnHULvsBuuPwFsJjbco3CnJg3nyPTqne5RhJ6yw== rsa 2048-083121"
# �⻧ID				��compartment_id��
Compartment_ID='ocid1.tenancy.oc1..aaaaaaaaut52tjoclotucjscunfdcg5rgi3mxcu3tmihak2phqomyqwr4fcq'
# ʵ��CPU��Ŀ
xCPU=4
# ʵ���ڴ��СGB
xRAM=24
# Ӳ��Ĭ��100GB
xHD=100
# �½�ʵ�����֣�ϲ��ȡʲô��ȡʲô������Ӣ���������
Instance_Name="ARM"
# ����ʱ��Ҫ�������Ҫ�����ʵ��ID�����û����ű�����ֹ��������Ҫ�������� ʵ��ID CPU �ڴ�
InstanceID="ocid1.instance.oc1.ap-xxxxx-1.xxxxxxxxxxxxxx"

#===========================================��д��������2====================================================#
# ��Ϣ֪ͨ������,������Ļ�����token
TOKEN=1849549411:AAFl7fNsW_5mR6bub6QwuA-Z3vnH9qMAMOo
# ֪ͨ�����˵�Telegram ID һ�����Լ���
CHAT_ID=854906231
# Telegram API �������
URL="https://api.telegram.org/bot${TOKEN}/sendMessage"

#===========================================�����޹�����=====================================================#
Font_Red="\033[31m";
Font_Green="\033[32m";
Font_Yellow="\033[33m";
Font_Blue="\033[34m";
Font_White="\033[37m";
Font_SkyBlue="\033[36m";
Font_Suffix="\033[0m";
#==========================================================================================================#
function api_launch(){
/root/bin/oci compute instance launch \
--availability-domain $Available_Domain \
--image-id $Image_ID \
--subnet-id $Subnet_ID \
--shape $Shape \
--assign-public-ip true \
--metadata '{"ssh_authorized_keys": "'"${SSH_Key_PUB}"'"}' \
--compartment-id $Compartment_ID \
--shape-config '{"ocpus":'$xCPU',"memory_in_gbs":'$xRAM',"boot_volume_size_in_gbs":'$xHD'}' \
--display-name $Instance_Name
}
#==========================================================================================================#
function api_update(){
	/root/bin/oci compute instance update \
	--instance-id $InstanceID \
	--shape-config '{"ocpus":'$xCPU',"memory_in_gbs":'$xRAM'}' \
	--force
}
#==========================================================================================================#
function InstallJQ() {
	current_time=`date +"%Y-%m-%d %H:%M:%S"`
    if [ -e "/etc/redhat-release" ];then
        echo -e "["$current_time"]" "${Font_Green}���ڰ�װ����: epel-release${Font_Suffix}";
        yum install epel-release -y -q > /dev/null;
        echo -e "["$current_time"]" "${Font_Green}���ڰ�װ����: jq${Font_Suffix}";
        yum install jq -y -q > /dev/null;
    elif [[ $(cat /etc/os-release | grep '^ID=') =~ ubuntu ]] || [[ $(cat /etc/os-release | grep '^ID=') =~ debian ]];then
        echo -e "["$current_time"]" "${Font_Green}���ڸ���������б�...${Font_Suffix}";
        apt-get update -y > /dev/null;
        echo -e "["$current_time"]" "${Font_Green}���ڰ�װ����: jq${Font_Suffix}";
        apt-get install jq -y > /dev/null;
    elif [[ $(cat /etc/issue | grep '^ID=') =~ alpine ]];then
        apk update > /dev/null;
        echo -e "["$current_time"]" "${Font_Green}���ڰ�װ����: jq${Font_Suffix}";
        apk add jq > /dev/null;
    else
        echo -e "["$current_time"]" "${Font_Red}���ֶ���װjq${Font_Suffix}";
        exit;
    fi
}
#==========================================================================================================#
function InstallLOG(){
	current_time=`date +"%Y-%m-%d %H:%M:%S"`
	if ! [[ -d /root/success/ ]]; then
		echo -e "["$current_time"]" "${Font_Green}���ڴ�����־Ŀ¼...${Font_Suffix}";
		mkdir /root/success
	else
		echo > /dev/null
	fi
	if ! [[ -f /root/success/success.log ]]; then
		echo -e "["$current_time"]" "${Font_Green}���ڴ�����־�ļ�...${Font_Suffix}";
		touch /root/success/success.log
	else
		echo > /dev/null
	fi
	if ! [[ -f /root/oci_error.log ]]; then
		echo -e "["$current_time"]" "${Font_Green}���ڴ�����־�ļ�...${Font_Suffix}";
		touch /root/oci_error.log
	else
		echo > /dev/null
	fi
}
function onCtrlC(){
    current_time=`date +"%Y-%m-%d %H:%M:%S"`
    echo -e "["$current_time"]" "${Font_Red}��⵽��Ctrl+C����ֹ����......${Font_Suffix}"
    echo -e "["$current_time"]" "${Font_Red}������ֹ�ű�......${Font_Suffix}"
    Msg_success="���׹�����Ϣ����${Instance_Name} ${xCPU}c${xRAM}g ����ű���ֹͣ"
    curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_success}"
    exit 0
}
#==========================================================================================================#
function InstanceUpate(){
	current_time=`date +"%Y-%m-%d %H:%M:%S"`
	if [[ Flag == 1  ]]; then
		if [[ $InstanceID == "" ]]; then
			echo -e "["$current_time"]" "${Font_Red}��������Ҫ�����ʵ��ID, ��ǰʵ��IDΪ�ա�${Font_Suffix}"
			echo -e "["$current_time"]" "${Font_Red}��������Ҫ�����ʵ��ID, ��ǰʵ��IDΪ�ա�${Font_Suffix}" >> /root/oci_error.log 2>&1
			Msg_warning="���׹�����Ϣ������������Ҫ�����ʵ��ID����ǰIDΪ�ա�"
			curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_warning}"
			exit 0
		else
			echo -e "["$current_time"]" "${Font_Yellow}��ǰ����ʵ��IDΪ��${InstanceID}${Font_Suffix}"
		fi
	fi
}
#==========================================================================================================#
function CheckInit(){
	current_time=`date +"%Y-%m-%d %H:%M:%S"`
	echo -e "["$current_time"]" "${Font_Green}֩���Ӥνű����������С�������${Font_Suffix}";
	sleep 1
	if ! [ -x "$(command -v jq)" ]; then
		InstallJQ
	else
		current_time=`date +"%Y-%m-%d %H:%M:%S"`
		echo -e "["$current_time"]" "${Font_Green}��⵽���� JQ �Ѱ�װ${Font_Suffix}";
		sleep 1
	fi
	InstallLOG
	current_time=`date +"%Y-%m-%d %H:%M:%S"`
	if [[ $Flag == 0 ]]; then
		echo -e "["$current_time"]" "${Font_SkyBlue}����ģʽ���½�ģʽ${Font_Suffix}"
		sleep 1
		echo -e "["$current_time"]" "${Font_SkyBlue}����������, ����Ϊ${Instance_Name} ${xCPU}c${xRAM}g${Font_Suffix}"
		sleep 1
		Msg_success="���׹�����Ϣ����${Instance_Name} ${xCPU}c${xRAM}g ��ʼ�½�ʵ��"
		curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_success}"
		echo -e "\n"
		api_launch > /root/result.json 2>&1
	elif [[ $Flag == 1 ]]; then
		echo -e "["$current_time"]" "${Font_Yellow}����ģʽ������ģʽ${Font_Suffix}"
		sleep 1
		echo -e "["$current_time"]" "${Font_Yellow}����������, ����Ϊ${Instance_Name} ${xCPU}c${xRAM}g${Font_Suffix}"
		sleep 1
		Msg_success="���׹�����Ϣ����${Instance_Name} ${xCPU}c${xRAM}g ��ʼ����ʵ��"
		curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_success}"
		echo -e "\n"
		api_update > /root/result.json 2>&1
	fi
}
#==========================================================================================================#
CheckInit
while [[ true ]]; do
	current_time=`date +"%Y-%m-%d %H:%M:%S"`
	outcome=500 # ��Ctrl + C ��
	if [[ $Flag == 0 ]]; then
		echo -e "["$current_time"]" "${Font_SkyBlue}���ڳ����½�ʵ���С�������${Font_Suffix}"
		api_launch > /root/result.json 2>&1
	elif [[ $Flag == 1 ]]; then
		echo -e "["$current_time"]" "${Font_Yellow}���ڳ�������ʵ���С�������${Font_Suffix}"
		api_update > /root/result.json 2>&1
	fi
	current_time=`date +"%Y-%m-%d %H:%M:%S"`
	sed -i '1d' /root/result.json
	outcome="$(cat /root/result.json | jq '.status')"
	case $outcome in
    500)
		echo -e "["$current_time"]" "ʵ��״̬��${Font_White}Out of host capacity${Font_Suffix}, ����״̬��""${Font_White}${outcome}${Font_Suffix}"
		echo -e "["$current_time"]" "ʵ��״̬��${Font_White}Out of host capacity${Font_Suffix}, ����״̬��""${Font_White}${outcome}${Font_Suffix}" >> /root/oci_error.log
    ;;
    429)
		echo -e "["$current_time"]" "ʵ��״̬��${Font_White}Too many requests for the user${Font_Suffix}, ����״̬��""${Font_White}${outcome}${Font_Suffix}"
		echo -e "["$current_time"]" "ʵ��״̬��${Font_White}Too many requests for the user${Font_Suffix}, ����״̬��""${Font_White}${outcome}${Font_Suffix}" >> /root/oci_error.log
    ;;
    409)
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}Apply conflict${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}"  
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}Apply conflict${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}" >> /root/oci_error.log
    	Msg_error="���׹�����Ϣ����${Instance_Name}����ű���ֹͣ��������ϢΪApply conflict"
		curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_error}"
		break
    ;;
    404)
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}InvalidParameter or LimitExceed${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}"
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}InvalidParameter or LimitExceed${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}" >> /root/oci_error.log
		Msg_error="���׹�����Ϣ����${Instance_Name}����ű���ֹͣ��������ϢΪInvalidParameter or LimitExceed"
		curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_error}"
		break	
    ;;
    401)
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}InvalidParameter or LimitExceed${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}"
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}InvalidParameter or LimitExceed${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}" >> /root/oci_error.log
		Msg_error="���׹�����Ϣ����${Instance_Name}����ű���ֹͣ��������ϢΪInvalidParameter or LimitExceed"
		curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_error}"
		break
    ;;
    503)
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}InvalidParameter or LimitExceed${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}"
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}InvalidParameter or LimitExceed${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}" >> /root/oci_error.log
		Msg_error="���׹�����Ϣ����${Instance_Name}����ű���ֹͣ��������ϢΪInvalidParameter or LimitExceed"
		curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_error}"
		break
    ;;
    400)
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}InvalidParameter or LimitExceed${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}"
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}InvalidParameter or LimitExceed${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}" >> /root/oci_error.log
		Msg_error="���׹�����Ϣ����${Instance_Name}����ű���ֹͣ��������ϢΪInvalidParameter or LimitExceed"
		curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_error}"
		break
    ;;
    401)
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}NotAuthenticated${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}"
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}NotAuthenticated${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}" >> /root/oci_error.log
		Msg_warning="���׹�����Ϣ����${Instance_Name}����ű���ֹͣ��������ϢΪNotAuthenticated"
		curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_warning}"
		break
    ;;
    502)
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}Bad Gateway${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}"
		echo -e "["$current_time"]" "ʵ��״̬��${Font_Red}Bad Gateway${Font_Suffix}, ����״̬��""${Font_Red}${outcome}${Font_Suffix}" >> /root/oci_error.log
		Msg_warning="���׹�����Ϣ����${Instance_Name}����ű���ֹͣ��������ϢΪBad Gateway"
		curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_warning}"
		break
    ;;
    *)
		if [[ $Flag == 0 ]]; then
			echo -e "["$current_time"]" "${Font_SkyBlue}${Instance_Name} ${xCPU}c${xRAM}g �ɹ��½�ʵ�������ڷ���֪ͨ��������${Font_Suffix}"
			echo -e "["$current_time"]" "${Font_SkyBlue}${Instance_Name} ${xCPU}c${xRAM}g �ɹ��½�ʵ�������ڷ���֪ͨ��������${Font_Suffix}" >> /root/success/success.log
			Msg_success="���׹�����Ϣ����${Instance_Name} ${xCPU}c${xRAM}g �½�ʵ���ɹ�"
			curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_success}"
			echo -e "\n"
		elif [[ $Flag == 1 ]]; then
			echo -e "["$current_time"]" "${Font_Yellow}${Instance_Name} ${xCPU}c${xRAM}g �ɹ�����ʵ�������ڷ���֪ͨ��������${Font_Suffix}"
			echo -e "["$current_time"]" "${Font_Yellow}${Instance_Name} ${xCPU}c${xRAM}g �ɹ�����ʵ�������ڷ���֪ͨ��������${Font_Suffix}" >> /root/success/success.log
			Msg_success="���׹�����Ϣ����${Instance_Name} ${xCPU}c${xRAM}g ʵ�������ɹ�"
			curl -s -X POST $URL -d chat_id=${CHAT_ID} -d text="${Msg_success}"
			echo -e "\n"
		fi
		cp /root/result.json /root/success
		sleep 30
		break
		exit 0
    ;;
	esac
done