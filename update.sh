#!/bin/bash

#拉取文件
#/usr/bin/git pull

#git拉取的代码地址
source_dir="/data/gitCodes/lz_new/lz"
#推送代码的目录地址
dest_dir="/data/html/"
#远程服务器的地址
o_server_info="root@47.99.111.121"

real_path=${source_dir}
cd ${real_path}


#同步文件
push_sdk() {

        rsync -vaP --exclude="config.php" --exclude="cache.php"  --exclude="runtime/" ${source_dir}/lzsdk ${dest_dir}
}

push_manage() {

	#rsync -vaP --exclude="config.php" --exclude=".env"  --exclude="database.php" --exclude="database_sdk.php" --exclude="IAd/" --exclude="runtime/" ${source_dir}/manage ${dest_dir}
	rsync -vaP --exclude="config.php" --exclude=".env"  --exclude="database.php" --exclude="database_sdk.php" --exclude="iad_config.php" --exclude="runtime/" ${source_dir}/manage ${dest_dir}
}

#同步外网文件
push_sdk_o() {

        rsync -vahP -e"ssh -p 22" --exclude="config.php" --exclude="cache.php"  --exclude="runtime/" ${source_dir}/lzsdk ${o_server_info}:${dest_dir}

}

push_manage_o() {

        #rsync -vahP -e"ssh -p 22" --exclude="config.php" --exclude=".env"  --exclude="database.php" --exclude="database_sdk.php" --exclude="IAd/"  --exclude="runtime/" ${source_dir}/manage ${o_server_info}:${dest_dir}
        rsync -vahP -e"ssh -p 22" --exclude="config.php" --exclude=".env"  --exclude="database.php" --exclude="database_sdk.php" --exclude="iad_config.php" --exclude="runtime/" ${source_dir}/manage ${o_server_info}:${dest_dir}

}

sshto(){
    ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=10 $@
}

change_per(){
    echo "修改目标web目录的权限"
    chown -R www:www ${dest_dir} && chmod -R 700 ${dest_dir}
}

change_per_o(){
    echo "修改目标web目录的权限"
    sshto -p 22 47.99.111.121  "chown -R www:www ${dest_dir} && chmod -R 700 ${dest_dir}"
}


do_exit(){
    echo -e "\e[0;31;1m$1\e[0m\n"
    exit $2
}

#拉取文件
do_pull() {
    /usr/bin/git pull
}

if [ $# -lt 1 ];then
  echo -e "\033[31m没有选择更新项目,请选择sdk,manage,比如
	内网SDK    uback sdk
        内网后台   uback manage
	外网SDK    uback sdk_o
        外网后台   uback manage_o
	\033[0m"  
  exit 1
fi

case $1 in
    sdk)
	do_pull
    	push_sdk
	change_per
    ;;
    manage)
	do_pull
	push_manage
	change_per
    ;;
    sdk_o)
        do_pull
        push_sdk_o
	change_per_o
    ;;
    manage_o)
        do_pull
        push_manage_o
	change_per_o
    ;;
    *)
        do_exit "输入项错误 $1,请输入sdk or manage" 1
    ;;
esac

#\cp -rf lzsdk ../../html/
