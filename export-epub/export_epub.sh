#!/usr/bin/env bash

str_nav="nav"
str_theme="theme"
str_md=".md"
str_epub=".epub"
str_colon=":"
dir=$1"docs/"
begin_md=0
merge_dir="./EpubMerge/epubmerge.py"
str_title=""


echo $dir

# npm install git://github.com/Alisahhh/remark-details.git
npx remark $1 -o
node -r esm index.js 


for line in `cat $1mkdocs.yml`
do
    # echo $line
    if [[ $line =~ $str_nav ]]
    then
        begin_md=1
        # echo $begin_md
    fi

    if [[ $line =~ $str_theme ]]
    then
        begin_md=0
        break
    fi

    if [[ $line =~ $str_colon ]]
    then
        str_title=${line/:/}
        echo $str_title
    fi

    if [ $begin_md -eq 1 ];
    then
        if [[ $line =~ $str_md ]];
        then
            dest_file=${line/.md/.epub}
            # echo $line
            resource_path=${line%/*.md}
            pandoc --webtex=http://127.0.0.1:8888/svg.latex? --self-contained --resource-path $dir$resource_path --metadata title=$str_title -f markdown+tex_math_dollars $dir$line -o $dir$dest_file 
            # echo $line
        fi
    fi
done

order=""

for line in `cat mkdocs.yml`
do
    if [[ $line =~ $str_nav ]]
    then
        begin_md=1
        # echo $begin_md
    fi

    if [[ $line =~ $str_theme ]]
    then
        begin_md=0
        break
    fi

    if [ $begin_md -eq 1 ];
    then
        if [[ $line =~ $str_md ]];
        then
            dest_file=${line/.md/.epub}
            order="$order $dir$dest_file"
            # pandoc  --mathjax -f markdown+tex_math_dollars $dir$line -o $dir$dest_file 
            # echo $line
        fi
    fi
done

order="$merge_dir $order"

$order -o test.epub