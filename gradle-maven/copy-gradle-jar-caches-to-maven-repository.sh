#!/bin/sh

gradle_jar_cache_dir=~/.gradle/caches/modules-2/files-2.1
mvn_repo=~/.m2/repository

gradle_prop=~/.gradle/gradle.properties
if test -f $gradle_prop ; then
    while IFS='=' read -r key value
     do
        if [ "$key" = "systemProp.gradle.user.home" ]
         then 
            gradle_jar_cache_dir="$value/caches/modules-2/files-2.1"
        fi
    done < "$gradle_prop"
    
    echo $gradle_jar_cache_dir
fi

#if test -f ~/.m2/settings.xml ; then
#    echo $mvn_repo
#fi

function traverse_copy(){
    for file in `ls $gradle_jar_cache_dir"/"$1`
    do
        if test -d $gradle_jar_cache_dir"/"$1"/"$file ; then
            traverse_copy $1"/"$file
        else
            IFS='/' read -ra ARR <<< "$1"
            group_id=`echo ${ARR[1]} | tr . /`
            artifact_id=${ARR[2]}
            version=${ARR[3]}
            
            from_file="$gradle_jar_cache_dir$1/$file"
            to_dir="$mvn_repo/$group_id/$artifact_id/$version"
            
            if ! test -f $to_dir"/"$file ; then
                if ! test -d $to_dir; then
                    mkdir -p $to_dir
                fi
                
                cp $from_file $to_dir"/"

                echo "from: $from_file"
                echo "to: $to_dir/"
                echo
            else
                echo $to_dir"/"$file" exists."
            fi
        fi
    done
}

#set -x
traverse_copy  