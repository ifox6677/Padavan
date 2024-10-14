
#!/bin/bash

set -e  # 如果任何命令失败，脚本将退出

# 参数：克隆的仓库路径，目标项目路径
SOURCE_REPO=$1
TARGET_DIR=$2

# 定义需要替换的文件或目录映射
declare -A file_map=(
  ["trunk/libc/uClibc-ng-1.0.48"]="trunk/libc/uClibc-ng-1.0.48"
  ["trunk/user/xray"]="trunk/user/xray"
  ["trunk/user/shadowsocks"]="trunk/user/shadowsocks"
  ["trunk/user/dnsproxy"]="trunk/user/dnsproxy"
  ["trunk/user/chinadns-ng"]="trunk/user/chinadns-ng"
  #["trunk/user/ttyd"]="trunk/user/ttyd"
  ["trunk/user/trojan"]="trunk/user/trojan"
  ["trunk/libs/boost"]="trunk/libs/boost"  
  #["trunk/libs/libwebsockets"]="trunk/libs/libwebsockets"
  ["trunk/libs/libcares"]="trunk/libs/c-ares"  
  #["trunk/libs/libjson-c"]="trunk/libs/libjson-c"  
  # 根据需要添加更多文件或目录映射
)

# 检查来源仓库是否存在
if [ ! -d "$SOURCE_REPO" ]; then
  echo "来源仓库路径 $SOURCE_REPO 不存在。"
  exit 1
fi

# 执行替换
for src in "${!file_map[@]}"; do
  dest=${file_map[$src]}
  src_file="$SOURCE_REPO/$src"
  dest_file="$TARGET_DIR/$dest"
  dest_dir=$(dirname "$dest_file")

  if [ -e "$src_file" ]; then
    echo "正在替换 $dest_file"
    # 创建目标目录（如果不存在）
    mkdir -p "$dest_dir"
    # 如果是目录，则递归复制
    if [ -d "$src_file" ]; then
      rm -rf "$dest_file"  # 先删除目标目录
      cp -r "$src_file" "$dest_file"
    else
      cp "$src_file" "$dest_file"
    fi
  else
    echo "源文件或目录 $src_file 不存在，跳过替换。"
  fi
done

echo "所有文件或目录替换完成。"
