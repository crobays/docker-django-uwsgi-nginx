#!/bin/bash

function find_replace_add_string_to_file() {
	find="$1"
	replace="$2"
	replace_escaped="${2//\//\\/}"
	file="$3"
	label="$4"
	if grep -q ";$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
	then
		action="Uncommented"
		sed -i "s/;$find/$replace_escaped/" "$file"
	elif grep -q "#$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
	then
		action="Uncommented"
		sed -i "s/#$find/$replace_escaped/" "$file"
	elif grep -q "$replace" "$file"
	then
		action="Already set"
	elif grep -q "$find" "$file"
	then
		action="Overwritten"
		sed -i "s/$find/$replace_escaped/" "$file"
	else
		action="Added"
		echo -e "\n$replace\n" >> "$file"
	fi
	echo " ==> Setting $label ($action) [$replace in $file]"
}

# if [ ! -f $SRC_PATH/uwsgi.ini ]
# then
# 	mkdir -p $SRC_PATH
# 	cp /conf/uwsgi.ini $SRC_PATH/uwsgi.ini
# 	if [ "$APP_NAME" ]
# 	then
# 		find_replace_add_string_to_file "chdir = .*" "chdir = $SRC_PATH" $SRC_PATH/uwsgi.ini "UWSGI project path"
# 		find_replace_add_string_to_file "module = .*" "module = $APP_NAME.wsgi:application" $SRC_PATH/uwsgi.ini "UWSGI app module"
# 	fi
# fi

if [ -f $PROJECT_PATH/uwsgi_params ]
then
	cp -f $PROJECT_PATH/uwsgi_params /conf/uwsgi_params
fi

while read -r e
do
	strlen="${#e}"
	if [ "${e:$strlen-1:1}" == "=" ] || [ "$e" == "${e/=/}" ] || [ $strlen -gt 100 ]
	then
		continue
	fi
	if [ "${e/ /}" != "$e" ]
	then
		continue
	fi

	echo -e "uwsgi_param   ${e/=/   };" >> /conf/uwsgi_params
done <<< "$(env)"
