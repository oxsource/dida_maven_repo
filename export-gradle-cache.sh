#!/bin/bash

SRC="files-2.1"
DEST="maven-repo"

mkdir -p "$DEST"

find "$SRC" -type f \( -name "*.aar" -o -name "*.jar" \) | while read file; do
    # 路径解析
    rel=${file#"$SRC/"}
    
    group=$(echo "$rel" | cut -d'/' -f1)
    artifact=$(echo "$rel" | cut -d'/' -f2)
    version=$(echo "$rel" | cut -d'/' -f3)
    
    filename=$(basename "$file")
    
    # group 转路径
    group_path=$(echo "$group" | tr '.' '/')
    
    target_dir="$DEST/$group_path/$artifact/$version"
    mkdir -p "$target_dir"
    
    # 目标文件
    target_file="$target_dir/$artifact-$version.${filename##*.}"
    
    echo "Processing: $group:$artifact:$version"
    
    # 拷贝
    cp "$file" "$target_file"
    
    # 生成 pom
    pom_file="$target_dir/$artifact-$version.pom"
    
    if [ ! -f "$pom_file" ]; then
        cat > "$pom_file" <<EOF
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>$group</groupId>
  <artifactId>$artifact</artifactId>
  <version>$version</version>
</project>
EOF
    fi

done

echo "Done! Maven repo at: $DEST"