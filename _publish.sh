target=`date "+%Y-%m-%d"`-$(basename $1)
`git mv $1 _posts\$target`
